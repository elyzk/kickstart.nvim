local M = {}

local function get_pkg_path(pkg)
  return vim.fn.stdpath 'data' .. '/mason/packages/' .. pkg
end

M.setup = function()
  local SYSTEM

  if vim.fn.has 'mac' then
    SYSTEM = 'mac'
  else
    SYSTEM = 'linux'
  end

  local function get_jdtls()
    local jdtls_path = get_pkg_path 'jdtls'
    local lombok_config = jdtls_path .. '/lombok.jar'

    local launcher = vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar')

    local config = jdtls_path .. '/config_' .. SYSTEM

    return launcher, config, lombok_config
  end

  local function get_bundles()
    local java_debug = get_pkg_path 'java-debug-adapter'

    local bundles = {
      vim.fn.glob(java_debug .. '/extension/server/com.microsoft.java.debug.plugin-*.jar', true),
    }

    local java_test = get_pkg_path 'java-test'
    vim.list_extend(bundles, vim.split(vim.fn.glob(java_test .. '/extension/server/*.jar', true), '\n'))

    return bundles
  end

  local function get_workspace()
    local home = os.getenv 'HOME'
    local workspace_path = home .. '/java/workspaces/'
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
    local workspace_dir = workspace_path .. project_name
    return workspace_dir
  end

  local jdtls = require 'jdtls'
  local launcher, os_config, lombok = get_jdtls()
  local workspace_dir = get_workspace()
  local bundles = get_bundles()
  local root_markers = { 'gradlew', 'mvnw', '.git', 'pom.xml', 'build.gradle', 'settings.gradle', 'build.xml' }
  local root_dir = require('jdtls.setup').find_root(root_markers)

  local capabilities = {
    workspace = {
      configuration = true,
    },
    textDocument = {
      completion = {
        snippetSupport = false,
      },
    },
  }

  local extendedClientCapabilities = jdtls.extendedClientCapabilities
  extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

  local cmd = {
    'java',
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xmx1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens',
    'java.base/java.util=ALL-UNNAMED',
    '--add-opens',
    'java.base/java.lang=ALL-UNNAMED',
    '-javaagent:' .. lombok,
    '-jar',
    launcher,
    '-configuration',
    os_config,
    '-data',
    workspace_dir,
  }

  -- Configure settings in the JDTLS server
  local settings = {
    java = {
      -- Enable code formatting
      format = {
        enabled = true,
        -- source = "absolute/path/to/formatter.xml"
        settings = {
          url = 'https://raw.githubusercontent.com/google/styleguide/gh-pages/eclipse-java-google-style.xml',
        },
      },
      -- Enable downloading archives from eclipse automatically
      eclipse = {
        downloadSource = true,
      },
      -- Enable downloading archives from maven automatically
      maven = {
        downloadSources = true,
      },
      -- Enable method signature help
      signatureHelp = {
        enabled = true,
      },
      -- Use the fernflower decompiler when using the javap command to decompile byte code back to java code
      contentProvider = {
        preferred = 'fernflower',
      },
      -- Setup automatical package import oranization on file save
      saveActions = {
        organizeImports = true,
      },
      -- Customize completion options
      completion = {
        -- When using an unimported static method, how should the LSP rank possible places to import the static method from
        favoriteStaticMembers = {
          'org.junit.jupiter.api.Assertions.*',
          'org.mockito.Mockito.*',
        },
        -- Try not to suggest imports from these packages in the code action window
        filteredTypes = {
          'com.sun.*',
          'io.micrometer.shaded.*',
          'java.awt.*',
          'jdk.*',
          'sun.*',
        },
        -- Set the order in which the language server should organize imports
        -- "" is all others, "#" is static imports
        importOrder = {
          'com',
          'lombok',
          'org',
          'jakarta',
          'javax',
          'java',
          '',
          '#',
        },
      },
      sources = {
        -- How many classes from a specific package should be imported before automatic imports combine them all into a single import
        organizeImports = {
          starThreshold = 9999,
          staticThreshold = 9999,
        },
      },
      -- How should different pieces of code be generated?
      codeGeneration = {
        -- When generating toString use a json format
        toString = {
          template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}',
        },
        -- When generating hashCode and equals methods use the java 7 objects method
        hashCodeEquals = {
          useJava7Objects = true,
        },
        -- When generating code use code blocks
        useBlocks = true,
      },
      -- If changes to the project will require the developer to update the projects configuration advise the developer before accepting the change
      configuration = {
        runtimes = {
          -- will most likely have a different path on other systems
          {
            name = 'JavaSE-21',
            path = os.getenv 'JAVA_HOME',
          },
        },
        updateBuildConfiguration = 'interactive',
      },
      -- enable code lens in the lsp
      referencesCodeLens = {
        enabled = true,
      },
      -- enable inlay hints for parameter names,
      inlayHints = {
        parameterNames = {
          enabled = 'all',
        },
      },
    },
  }

  local init_options = {
    bundles = bundles,
    extendedClientCapabilities = extendedClientCapabilities,
  }

  local on_attach = function(_, bufnr)
    local ts_indent = require 'nvim-treesitter.indent'
    ts_indent.detach(bufnr)
    -- Enable jdtls commands to be used in Neovim
    vim.lsp.codelens.refresh()

    -- Setup a function that automatically runs every time a java file is saved to refresh the code lens
    vim.api.nvim_create_autocmd('BufWritePost', {
      pattern = { '*.java' },
      callback = function()
        local _, _ = pcall(vim.lsp.codelens.refresh)
      end,
    })
  end

  local config = {
    name = 'jdtls',
    cmd = cmd,
    root_dir = root_dir,
    settings = settings,
    capabilities = capabilities,
    init_options = init_options,
    on_attach = on_attach,
  }

  vim.keymap.set('n', '<leader>r', function()
    local root = vim.fs.root(0, root_markers)
    if root then
      vim.cmd(string.format("TermExec cmd='mvn spring-boot:run' dir='%s'", root))
    else
      vim.cmd "TermExec cmd='mvn spring-boot:run'"
    end
  end, { desc = 'Java [R]un at Root' })
  vim.keymap.set('n', '<leader>dc', require('dap').continue, { desc = 'Java [D]ebug [C]ontinue' })
  vim.keymap.set('n', '<leader>dt', function()
    require('dap').terminate()
    require('dapui').close()
  end, { desc = 'Java [D]ebug [T]erminate' })
  vim.keymap.set('n', '<leader>db', require('dap').toggle_breakpoint, { desc = 'Java Toggle [B]reakpoint' })
  vim.keymap.set('n', '<leader>du', function()
    require('dapui').toggle()
  end, { desc = 'Toggle DAP [U]I' })

  require('jdtls').start_or_attach(config)
end

return M

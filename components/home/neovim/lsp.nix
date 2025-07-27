{ pkgs, ... }: {

  programs.neovim.extraPackages = with pkgs; [
    bash-language-server
    gopls
    htmx-lsp
    lua-language-server
    nil
    pyright
    ruff
    typescript-language-server
    vscode-langservers-extracted
  ];

  programs.neovim.plugins = with pkgs.vimPlugins; [

    nvim-lspconfig

    {
      plugin = lspsaga-nvim;
      type = "lua";
      config = /*lua*/ ''
        do
          require('lspsaga').setup {
            symbol_in_winbar = { enable = false },
            code_action = { keys = { quit = '<ESC>', } },
            lightbulb = { enable = false, },
            rename = { keys = { quit = '<ESC>', }, },
          }

          -- set's LSP bindings only when a server attaches to a buffer
          vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('UserLspConfig', {}),
            callback = function(event)
              vim.bo[event.buf].omnifunc = 'v:lua.MiniCompletion.completefunc_lsp'

              local opts = { buffer = event.buf, silent = true }
              vim.keymap.set('n',        '<leader>D',       vim.diagnostic.setqflist, opts)
              vim.keymap.set({'n', 'v'}, '<leader>nd',      '<CMD>Lspsaga diagnostic_jump_next<CR>', opts)
              vim.keymap.set('n',        '<leader>gt',      '<CMD>Lspsaga goto_type_definition<CR>', opts)
              vim.keymap.set('n',        '<leader>kt',      '<CMD>Lspsaga peek_type_definition<CR>', opts)
              vim.keymap.set('n',        '<leader>gd',      '<CMD>Lspsaga goto_definition<CR>', opts)
              vim.keymap.set('n',        '<leader>kd',      '<CMD>Lspsaga peek_definition<CR>', opts)
              vim.keymap.set({'n', 'v'}, 'K',               '<CMD>Lspsaga hover_doc<CR>', opts)
              vim.keymap.set('n',        '<leader>F',       '<CMD>Lspsaga finder<CR>', opts)
              vim.keymap.set('n',        '<leader>O',       '<CMD>Lspsaga outline<CR>', opts)
              vim.keymap.set('n',        '<leader>nn',      '<CMD>Lspsaga rename<CR>', opts)
              vim.keymap.set('n',        '<leader>lf',      function() vim.lsp.buf.format { async = true } end, opts)
              vim.keymap.set('n',        '<leader>chi',     '<CMD>Lspsaga incoming_calls<CR>', opts)
              vim.keymap.set('n',        '<leader>cho',     '<CMD>Lspsaga outgoing_calls<CR>', opts)
              vim.keymap.set({'n', 'v'}, '<leader><space>', '<CMD>Lspsaga code_action<CR>', opts)
            end
          })

          local function make_client_capabilities(user_options)
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            return vim.tbl_deep_extend("force", capabilities, user_options or {})
          end

          local langserver_configs = {  -- can i get this from nix somehow?
            bashls = {     -- shell
              filetypes = {"sh", "bash", "zsh"},
            },
            cssls = {},    -- css (vscode-langservers-extracted)
            eslint = {},   -- javascript (vscode-langservers-extracted)
            gopls = {      -- go
              settings = {
                templateExtensions = { 'html', 'templ' },
              },
            },
            html = {       -- html (vscode-langservers-extracted)
              capabilities = make_client_capabilities{
                textDocument = {
                  completion = { completionItem = { snippetSupport = true } },
                },
              }
            },
            htmx = {},     -- htmx
            jsonls = {},   -- json (vscode-langservers-extracted)
            lua_ls = {},   -- lua
            nil_ls = {},   -- nix
            pyright = {    -- python
              settings = make_client_capabilities {
                pyright = { disableOrganizeImports = true, },
              },
              on_new_config = function(config, root_dir)
                -- use the python version and venv managed by poetry
                local Path = require 'plenary.path'
                local pyright_config = Path:new(root_dir, "pyrightconfig.json")

                local settings = {}
                if pyright_config:is_file() then
                  settings = vim.json.decode(pyright_config:read())
                end

                -- already sufficiently configured
                if settings.pythonPath ~= nil or settings.venv ~= nil or settings.venvPath ~= nil then
                  return
                end

                -- find python path
                settings.pythonPath = vim.trim(vim.fn.system('which python'))

                -- find venv dir:
                -- 1. check poetry env info
                -- 2. otherwise default to .venv
                local venv_path = vim.trim(vim.fn.system('cd "'..root_dir..'"; poetry env info -p 2>/dev/null'))
                if venv_path:len() == 0 then
                  venv_path = root_dir .. '/.venv'
                end

                -- check if the venv actually exists
                if vim.fn.isdirectory(venv_path) then
                  settings.venvPath, settings.venv = venv_path:match('^(.*/)([^/]+)$')
                  config.settings.python = vim.tbl_extend('force', config.settings.python, settings)
                end

                -- write settings
                pyright_config:write(vim.json.encode(settings), 'w')
              end,
            },
            ruff = {       -- also python
              on_attach = function(client)
                client.server_capabilities.hoverProvider = false
              end,
            },
            ts_ls = {},    -- typescript
          }

          if vim.fn.has('nvim-0.11') == 1 then
            vim.lsp.config["*"] = { root_markers = { ".git", ".jj" } }
            for server, config in pairs(langserver_configs) do
              if type(config) == "table" and next(config) then

                -- emulate on_new_config callback
                if config.on_new_config then
                  config.before_init = function(params, config)
                    config.on_new_config(config, config.root_dir)
                  end
                end

                vim.lsp.config[server] = vim.tbl_deep_extend("force", vim.lsp.config[server], config)
              end
            end
            vim.lsp.enable(vim.tbl_keys(langserver_configs))
          else
            -- legacy setup with lspconfig
            for server, config in pairs(langserver_configs) do
              (require 'lspconfig')[server].setup(config)
            end
          end
        end
      '';
    }

  ];

  programs.neovim.extraLuaConfig = /*lua*/''
    do
      local signs = {Error = " ", Warn  = " ", Hint  = " ", Info  = " "}
      if vim.fn.has('nvim-0.11') then
        vim.diagnostic.config{
          signs = {
            text = {
              [vim.diagnostic.severity.ERROR] = signs.Error,
              [vim.diagnostic.severity.WARN] = signs.Warn,
              [vim.diagnostic.severity.HINT] = signs.Hint,
              [vim.diagnostic.severity.INFO] = signs.Info,
            },
          },
          virtual_text = true,
          severity_sort = true,
        }
      else
        for type, icon in pairs(signs) do
          local hl = "DiagnosticSign" .. type
          vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
        end
      end
    end
  '';
}

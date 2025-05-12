{
  pkgs,
  ...
}: {

  programs.neovim.extraPackages = with pkgs; [
    bash-language-server
    gopls
    htmx-lsp
    lua-language-server
    nil
    pylyzer
    ruff
    typescript-language-server
    vscode-langservers-extracted
  ];

  programs.neovim.plugins = with pkgs.vimPlugins; [

    nvim-lspconfig
    popfix

    {
      plugin = lspsaga-nvim;  # TODO: check navigator
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
              -- NOTE: this overwrites the `l` movement key
              vim.keymap.set({'n', 'v'}, '<leader>nd',      '<CMD>Lspsaga diagnostic_jump_next<CR>', opts)
              vim.keymap.set('n',        '<leader>D',       vim.diagnostic.setloclist, opts)
              vim.keymap.set('n',        '<leader>gt',      '<CMD>Lspsaga goto_type_definition<CR>', opts)
              vim.keymap.set('n',        '<leader>kt',      '<CMD>Lspsaga peek_type_definition<CR>', opts)
              vim.keymap.set('n',        '<leader>gd',      '<CMD>Lspsaga goto_definition<CR>', opts)
              vim.keymap.set('n',        '<leader>kd',      '<CMD>Lspsaga peek_definition<CR>', opts)
              vim.keymap.set({'n', 'v'}, 'K',               '<CMD>Lspsaga hover_doc<CR>', opts)
              vim.keymap.set('n',        '<leader>F',       '<CMD>Lspsaga finder<CR>', opts)
              vim.keymap.set('n',        '<leader>nn',      '<CMD>Lspsaga rename<CR>', opts)
              vim.keymap.set('n',        '<leader>lf',      function() vim.lsp.buf.format { async = true } end, opts)
              vim.keymap.set('n',        '<leader>chi',     '<CMD>Lspsaga incoming_call<CR>', opts)
              vim.keymap.set('n',        '<leader>cha',     '<CMD>Lspsaga outgoing_call<CR>', opts)
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
            pylyzer = {    -- python
              settings = {
                python = {
                 checkOnType = true,
                },
              },
            },
            ruff = {},     -- also python
            ts_ls = {},    -- typescript
          }

          if vim.fn.has('nvim-0.11') == 1 then
            for server, config in pairs(langserver_configs) do
              if type(config) == "table" and next(config) then
                vim.lsp.config[server] = vim.tbl_deep_extend("force", vim.lsp.config[server], config)
              end
            end
            vim.lsp.enable(vim.tbl_keys(langserver_configs))
          else
            for server, config in pairs(langserver_configs) do
              (require 'lspconfig')[server].setup(config)
            end
          end
        end
      '';
    }

    {
      plugin = nvim-lsputils;
      type = "lua";
      config = /*lua*/ ''
        do
          local codeAction = require 'lsputil.codeAction'
          local locations = require 'lsputil.locations'
          local symbols = require 'lsputil.symbols'

          local handlers = vim.lsp.handlers
          handlers['textDocument/codeAction'] = codeAction.code_action_handler
          handlers['textDocument/references'] = locations.references_handler
          handlers['textDocument/definition'] = locations.definition_handler
          handlers['textDocument/declaration'] = locations.declaration_handler
          handlers['textDocument/typeDefinition'] = locations.typeDefinition_handler
          handlers['textDocument/implementation'] = locations.implementation_handler
          handlers['textDocument/documentSymbol'] = symbols.document_handler
          handlers['workspace/symbol'] = symbols.workspace_handler

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
  ];
}

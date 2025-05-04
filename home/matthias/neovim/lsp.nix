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
              vim.keymap.set({'n', 'v'}, '<space>e', '<CMD>Lspsaga diagnostic_jump_next<CR>', opts)
              vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)
              vim.keymap.set('n', 'gD', '<CMD>Lspsaga goto_type_definition<CR>', opts)
              vim.keymap.set('n', '<leader>gD', '<CMD>Lspsaga peek_type_definition<CR>', opts)
              vim.keymap.set('n', 'gd', '<CMD>Lspsaga goto_definition<CR>', opts)
              vim.keymap.set('n', '<leader>gd', '<CMD>Lspsaga peek_definition<CR>', opts)
              vim.keymap.set({'n', 'v'}, 'K', '<CMD>Lspsaga hover_doc<CR>', opts)
              vim.keymap.set('n', 'gr', '<CMD>Lspsaga finder<CR>', opts)
              vim.keymap.set('n', '<leader>rn', '<CMD>Lspsaga rename<CR>', opts)
              vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, opts)
              vim.keymap.set('n', '<leader>chi', '<CMD>Lspsaga incoming_call<CR>', opts)
              vim.keymap.set('n', '<leader>cha', '<CMD>Lspsaga outgoing_call<CR>', opts)
              vim.keymap.set({ 'n', 'v' }, '<leader>ca', '<CMD>Lspsaga code_action<CR>', opts)
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
                  -- NOTE: needs a snippet engine -> does not work right now
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

          for type, icon in pairs {
            Error = " ",
            Warn  = " ",
            Hint  = " ",
            Info  = " "
          } do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
          end
        end
      '';
    }
  ];
}

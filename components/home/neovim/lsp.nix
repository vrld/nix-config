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

  programs.neovim.plugins = with pkgs.vimPlugins; [ nvim-lspconfig ];

  programs.neovim.extraLuaConfig = /*lua*/''
    do

      -- set's LSP bindings only when a server attaches to a buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client:supports_method('textDocument/completion') then
            vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true, })
          end

          local opts = { buffer = event.buf, silent = true }
          -- default bindings:
          -- [d and ]d     jump between diagnostics
          -- <C-w>d        show diagnostic under cursor
          -- gO            opens symbols in quickfix window vim.lsp.buf.document_symbol()
          -- grn           rename
          -- gra           code action
          -- grr           references
          -- grt           go to type definition -- overwritten to reuse window
          vim.keymap.set('n', 'grt', function() vim.lsp.buf.type_definition{ reuse_win=true } end, opts)
          -- gri           go to implementation

          -- added bindings
          -- gre           populate quickfix list with diagonstics (jump with [d and ]d)
          vim.keymap.set('n', 'gre', vim.diagnostic.setqflist, opts)
          -- grd           go to definition; tagfunc is set to vim.lsp.tagfunc(), so <C-W>] and :tjump also work
          vim.keymap.set('n', 'grd', '<C-]>', opts)
          -- gro           lsp format ("order")
          vim.keymap.set('n', 'gro', function() vim.lsp.buf.format { async = true } end, opts)

          -- highlight symbol under cursor
          vim.keymap.set('n', 'gr*', function()
            vim.lsp.buf.clear_references()
            pcall(vim.lsp.buf.document_highlight)
          end)
        end
      })

      -- snippet completion did not work out of the box for gopls, so we do it ourselves
      -- this also applies additonal text edits provided by the lsp
      vim.api.nvim_create_autocmd("CompleteDone", {
        callback = function()
          local completion_item = vim.tbl_get(vim, "v", "completed_item", "user_data", "nvim", "lsp", "completion_item")
          if completion_item == nil then
            return
          end

          local bufnr = vim.api.nvim_get_current_buf()
          if vim.tbl_get(vim, "v", "completed_item", "kind") == "Snippet" then
            local snippet_text = vim.tbl_get(completion_item, "textEdit", "newText") or completion_item.insertText
            if snippet_text == nil then
              return
            end

            -- remove completed word
            local row, col = unpack(vim.api.nvim_win_get_cursor(0))
            vim.api.nvim_buf_set_text(bufnr, row - 1, col - #vim.v.completed_item.word, row - 1, col, {})

            -- expand snippet
            vim.lsp.util.apply_text_edits(completion_item.additionalTextEdits, bufnr, "utf-8")
            vim.snippet.expand(snippet_text)
          elseif completion_item.additionalTextEdits ~= nil then
            -- might still have text edits
            vim.lsp.util.apply_text_edits(completion_item.additionalTextEdits, bufnr, "utf-8")
          end
        end,
      })

      -- map <Tab> to omnifunc when it's sensible to complete the token before the cursor
      local types_to_complete = {
        "identifier",
        "field_expression",
        "property_identifier",
        "method_identifier",
        "variable_declaration",
        "parameter",
        "type_identifier",
        "struct_field_identifier",
        "function_identifier"
      }
      local function smart_tab()
        -- if in completion, cycle to next item
        if vim.fn.pumvisible() ~= 0 then
          return "<C-n>"
        end

        local bufnr = vim.api.nvim_get_current_buf()
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        local ts = vim.treesitter.get_node{ bufnr=bufnr, pos={row - 1, math.max(0, col - 1)} }

        if ts and vim.tbl_contains(types_to_complete, ts:type()) then
          vim.lsp.completion.get()
          return ""
        else
          return "<Tab>"
        end
      end
      vim.keymap.set('i', '<Tab>', smart_tab, {expr = true, silent=true})

      -- TODO: user command / menu with lsp functions?

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
        html = {},     -- html (vscode-langservers-extracted)
        htmx = {},     -- htmx
        jsonls = {},   -- json (vscode-langservers-extracted)
        lua_ls = {},   -- lua
        nil_ls = {},   -- nix
        pyright = {    -- python
          settings = { pyright = { disableOrganizeImports = true, }, },
          before_init = function(_, config)
            -- generate a config file that makes pyright aware of a project's venv
            local Path = require 'plenary.path'
            local pyright_config = Path:new(config.root_dir, "pyrightconfig.json")

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
            local venv_path = vim.trim(vim.fn.system('cd "'..config.root_dir..'"; poetry env info -p 2>/dev/null'))
            if venv_path:len() == 0 then
              venv_path = config.root_dir .. '/.venv'
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

      vim.lsp.config["*"] = {
        root_markers = { ".git", ".jj" },
        capabilities = {
          -- enable snippets for all servers
          textDocument = { completion = { completionItem = { snippetSupport = true } }, },
        }
      }
      for server, config in pairs(langserver_configs) do
        if type(config) == "table" and next(config) then
          vim.lsp.config[server] = config
        end
      end
      vim.lsp.enable(vim.tbl_keys(langserver_configs))

      -- lsp diagnostic display
      local signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = " ",
          [vim.diagnostic.severity.WARN] = " ",
          [vim.diagnostic.severity.HINT] = " ",
          [vim.diagnostic.severity.INFO] = " ",
        },
      }

      local noise_levels = {
        off     = { signs = false, underline = false, virtual_text = false },
        minimal = { signs = signs, underline = false, virtual_text = false },
        reduced = { signs = signs, underline = true, virtual_text = false },
        normal  = { signs = signs, underline = true, severity_sort=true, virtual_text = { current_line = true }, virtual_lines = false },
        fancy   = { signs = signs, underline = true, severity_sort=true, virtual_text = false, virtual_lines = { current_line = true } },
        loud    = { signs = signs, underline = true, severity_sort=true, virtual_text = true, virtual_lines = false, underline = true  },
        louder  = { signs = signs, underline = true, severity_sort=true, virtual_text = true, virtual_lines = { current_line = true } },
        loudest = { signs = signs, underline = true, severity_sort=true, virtual_text = true, virtual_lines = true },
      }
      vim.diagnostic.config(noise_levels.normal)

      -- :Noise [level] -- sets one of the levels above
      local function noise_command(opts)
        local level = noise_levels[opts.fargs[1] or "normal"]
        if level ~= nil then
          vim.diagnostic.config(level)
        else
          nvim.api.nvim_err_writeln("Invalid level")
        end
      end

      -- command completion
      local command_opts = {
        nargs = "?",
        desc = "Noise level",
        complete = function(lead)
          local res = {}
          for _, name in ipairs({"off", "minimal", "reduced", "normal", "fancy", "loud", "louder", "loudest"}) do
            if name:sub(1, #lead) == lead then
              res[#res + 1] = name
            end
          end
          return res
        end
      }

      vim.api.nvim_create_user_command("Noise", noise_command, command_opts)
    end
  '';
}

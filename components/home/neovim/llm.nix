{ pkgs, lib, ... }: {

  programs.neovim.extraPackages = with pkgs; [
    llm-ls
  ];

  programs.neovim.plugins = with pkgs.vimPlugins; [

    # completion
    {
      plugin = llm-nvim;
      type = "lua";
      config = /*lua*/''
        require 'llm'.setup{
          model = "codegemma:7b-code",
          url = "http://localhost:11434",
          request_body = {
            parameters = {
              think=false,
            },
          },
          fim = {
            enabled = true,
            prefix = "<|fim_prefix|>",
            middle = "<|fim_middle|>",
            suffix = "<|fim_suffix|>",
          },
          lsp = {
            bin_path = "${lib.getExe' pkgs.llm-ls "llm-ls"}",
          },
          enable_suggestions_on_startup = false,
        }
      '';
    }

    # chat with ollama
    {
      plugin = gen-nvim;
      type = "lua";
      config = /*lua*/''
        require'gen'.setup{
          model = "gemma3:12b",
          show_prompt = true, -- shows 3 lines
          -- show_prompt = "full",
          show_model = true,
        }
      '';
    }
  ];

}

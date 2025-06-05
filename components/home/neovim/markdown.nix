{ pkgs, ... }: {

  programs.neovim.plugins = with pkgs.vimPlugins; [

    {
      plugin = markdown-preview-nvim;
      config = /*vim*/''
        let g:mkdp_auto_close = 1
        let g:mkdp_filetypes = ['markdown']
      '';
    }

  ];
}

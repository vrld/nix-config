{ pkgs }:
pkgs.buildNpmPackage {
  pname = "context-hub";
  version = "0.1.3";

  src = pkgs.fetchFromGitHub {
    owner = "andrewyng";
    repo = "context-hub";
    rev = "02ba375c4deb4ba1d54550609bcd8b0e98ecf79c";
    hash = "sha256-a51EY8+RXAkCHfKv5uULKZA8Ur07yJXiP2HTqJ0GgUY=";
  };

  npmDepsHash = "sha256-vQLCT8I4w4/5DXR1+3R4ZQ+DPSypQX3CpQNxrVp+E0I=";

  dontNpmBuild = true;

  # Root package.json is missing "version", which npm requires.
  postPatch = ''
    ${pkgs.lib.getExe pkgs.jq} '. + {version: "0.1.3"}' package.json > tmp.json && mv tmp.json package.json
  '';

  # The repo is a workspace monorepo with package-lock.json at root and the
  # CLI package in cli/. npm install from root resolves the workspace.
  # After install, we manually set up the binaries from cli/bin/.
  postInstall = ''
    mkdir -p $out/bin
    ln -s $out/lib/node_modules/context-hub/cli/bin/chub $out/bin/chub
    ln -s $out/lib/node_modules/context-hub/cli/bin/chub-mcp $out/bin/chub-mcp
  '';

  meta = {
    description = "CLI for Context Hub - search and retrieve LLM-optimized docs and skills";
    homepage = "https://github.com/andrewyng/context-hub";
    license = pkgs.lib.licenses.mit;
    mainProgram = "chub";
  };
}

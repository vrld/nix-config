{ pkgs }: pkgs.writeShellApplication {
  name = "term-cache";
  runtimeInputs = [ pkgs.sqlite pkgs.bash ];
  text = builtins.readFile ./term-cache.sh;
}

{ pkgs, lib, config, inputs, ... }:

{
  env.GREET = "devenv";
  packages = [ pkgs.nvfetcher pkgs.git ];
}

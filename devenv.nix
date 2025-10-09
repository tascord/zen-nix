{ pkgs, lib, config, inputs, ... }:

{
  env.GREET = "devenv";
  packages = [
    pkgs.nvfetcher
    pkgs.git
    pkgs.pre-commit  # Add pre-commit to packages instead of using git-hooks integration
  ];
}

{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: 
    let
      sources = import ./_sources/generated.nix {
        inherit (nixpkgs.legacyPackages.x86_64-linux) fetchurl fetchFromGitHub fetchgit dockerTools;
      };
  
  mkPackages = system: 
    let
      pkgs = nixpkgs.legacyPackages.${system};
      
      # AppImage package (Linux x86_64 and aarch64)
      mkAppImage = source: pkgs.appimageTools.wrapType2 {
        inherit (source) pname version src;
        extraInstallCommands = ''
          mv $out/bin/${source.pname} $out/bin/zen-browser
        '';
      };
      
      # DMG package (macOS)
      mkDMG = source: pkgs.stdenv.mkDerivation {
        inherit (source) pname version src;
        nativeBuildInputs = [ pkgs.undmg ];
        sourceRoot = "Zen Browser.app";
        installPhase = ''
          mkdir -p $out/Applications
          cp -r "Zen Browser.app" $out/Applications/
        '';
      };

  meta = {
    description = "Privacy-focused browser that blocks trackers; ads; and other unwanted content while offering the best browsing experience!";
    homepage = "https://github.com/zen-browser/desktop";
    platforms = [ "aarch64-darwin" "aarch64-linux" "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    license = lib.licenses.mpl20;
  };
}

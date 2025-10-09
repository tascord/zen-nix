{
  description = "Zen Browser for multiple platforms";

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
            meta = {
              description = "Privacy-focused browser that blocks trackers, ads, and other unwanted content while offering the best browsing experience!";
              homepage = "https://github.com/zen-browser/desktop";
              platforms = [ "aarch64-linux" "x86_64-linux" ];
              sourceProvenance = with pkgs.lib.sourceTypes; [ binaryNativeCode ];
              license = pkgs.lib.licenses.mpl20;
            };
          };
          
          # DMG package (macOS) - using undmg
          mkDMG = source: pkgs.stdenv.mkDerivation {
            inherit (source) pname version src;
            nativeBuildInputs = [ pkgs.undmg ];
            sourceRoot = "Zen Browser.app";
            installPhase = ''
              mkdir -p $out/Applications
              cp -r "Zen Browser.app" $out/Applications/
              mkdir -p "$out/Applications/Zen Browser.app/Contents/Resources/distribution"
            '';
            meta = {
              description = "Privacy-focused browser that blocks trackers, ads, and other unwanted content while offering the best browsing experience!";
              homepage = "https://github.com/zen-browser/desktop";
              platforms = [ "aarch64-darwin" "x86_64-darwin" ];
              sourceProvenance = with pkgs.lib.sourceTypes; [ binaryNativeCode ];
              license = pkgs.lib.licenses.mpl20;
            };
          };
          
        in {
          zen-browser = 
            if system == "x86_64-linux" then mkAppImage sources.x64
            else if system == "aarch64-linux" then mkAppImage sources.aarch64  
            else if system == "aarch64-darwin" || system == "x86_64-darwin" then mkDMG sources.darwin
            else throw "Unsupported system: ${system}";
        };
    in
    {
      packages = {
        x86_64-linux = mkPackages "x86_64-linux" // { default = (mkPackages "x86_64-linux").zen-browser; };
        aarch64-linux = mkPackages "aarch64-linux" // { default = (mkPackages "aarch64-linux").zen-browser; };
        aarch64-darwin = mkPackages "aarch64-darwin" // { default = (mkPackages "aarch64-darwin").zen-browser; };
        x86_64-darwin = mkPackages "x86_64-darwin" // { default = (mkPackages "x86_64-darwin").zen-browser; };
      };
    };
}

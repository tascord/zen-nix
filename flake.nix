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
          mkAppImage = source:
            let
              desktopItem = pkgs.makeDesktopItem {
                name = "zen-browser";
                desktopName = "Zen Browser";
                comment = "Privacy-focused browser that blocks trackers, ads, and other unwanted content";
                genericName = "Web Browser";
                exec = "zen-browser %U";
                icon = "zen-browser";
                terminal = false;
                type = "Application";
                mimeTypes = [
                  "text/html"
                  "text/xml"
                  "application/xhtml+xml"
                  "application/xml"
                  "application/rss+xml"
                  "application/rdf+xml"
                  "image/gif"
                  "image/jpeg"
                  "image/png"
                  "x-scheme-handler/http"
                  "x-scheme-handler/https"
                  "x-scheme-handler/ftp"
                  "x-scheme-handler/chrome"
                  "video/webm"
                  "application/x-xpinstall"
                ];
                categories = [ "Network" "WebBrowser" ];
                keywords = [ "Internet" "WWW" "Browser" "Web" "Explorer" ];
                startupWMClass = "zen-browser";
                startupNotify = true;
              };

              icon = pkgs.writeText "zen-browser.svg" ''
                <?xml version="1.0" encoding="UTF-8"?>
                <svg width="64" height="64" viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg">
                  <circle cx="32" cy="32" r="30" fill="#4a90e2"/>
                  <text x="32" y="40" font-family="Arial" font-size="24" fill="white" text-anchor="middle">Z</text>
                </svg>
              '';
            in
            pkgs.appimageTools.wrapType2 {
              inherit (source) pname version src;
              extraInstallCommands = ''
                mv $out/bin/${source.pname} $out/bin/zen-browser

                # Ensure share directories exist and install the .desktop file
                mkdir -p $out/share/applications
                install -Dm644 ${desktopItem}/share/applications/zen-browser.desktop $out/share/applications/zen-browser.desktop

                # Install fallback icon (ensure parent dirs first)
                mkdir -p $out/share/icons/hicolor/scalable/apps
                install -Dm644 ${icon} $out/share/icons/hicolor/scalable/apps/zen-browser.svg
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

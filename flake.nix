{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems =
        let
          unsupportedSystems = [
            # GHC not supported
            "armv5tel-linux"
            "armv6l-linux"
            "powerpc64le-linux"
            "riscv64-linux"

            # "error: attribute 'busybox' missing" when building
            # `bootstrap-tools`
            "mipsel-linux"
          ];
        in nixpkgs.lib.subtractLists unsupportedSystems nixpkgs.lib.systems.flakeExposed;

      perSystem = nixpkgs.lib.genAttrs supportedSystems;
      pkgsFor = system: import nixpkgs { inherit system; };

      # Builder for all formats (HTML, PDF, DOCX, RTF)
      buildAllFormats = system:
        let
          pkgs = pkgsFor system;
          mainDocName = "cv"; # Adjust if your main markdown is e.g. resume.md
        in pkgs.runCommand "all-formats-artifact" {
          nativeBuildInputs = with pkgs; [ pandoc texlive.combined.scheme-context findutils ];
        } ''
          # Build resume documents using Make; output will be in $out
          cd ${self}
          make OUT_DIR="$out" html pdf docx rtf

          # Rename main HTML document to index.html for convenience if needed locally
          if [ -f "$out/${mainDocName}.html" ]; then
            mv "$out/${mainDocName}.html" "$out/index.html"
          else
            echo "Warning: $out/${mainDocName}.html not found to rename to index.html."
            echo "Files in $out:"
            ls -la $out
          fi

          # Copy static assets from ./www (e.g., style.css), excluding www/index.html
          # This part is kept for the 'default' build if you want local preview with styles
          if [ -d "${self}/www" ]; then
            echo "Copying static assets from ${self}/www to $out"
            find ${self}/www -mindepth 1 -maxdepth 1 -not -name "index.html" -exec cp -r {} $out/ \;
          fi
        '';

      # Builder for web-only (GitHub Pages) output
      buildWebOnly = system:
        let
          pkgs = pkgsFor system;
          # Assuming your Makefile has a target like 'resume.html' or similar
          # or that 'make html' produces 'cv.html'
          mainHtmlFile = "resume.html"; # This should be the direct output of make html
                                      # before any renaming by make itself.
                                      # If make renames it to resume.html, use that.
                                      # Let's assume make produces cv.html from cv.md
        in pkgs.runCommand "github-pages-web-artifact" {
          nativeBuildInputs = with pkgs; [ pandoc ]; # Only pandoc needed if make handles HTML directly
        } ''
          cd ${self}
          # Ensure the output directory exists
          mkdir -p $out

          # Build only the HTML version, assuming 'make cv.html' or similar exists
          # Or, if 'make html' produces the correct file in $out:
          make OUT_DIR="$out" html 

          # Rename the specific HTML file to index.html
          # Adjust 'cv.html' if your make target produces a different name (e.g., resume.html)
          if [ -f "$out/${mainHtmlFile}" ]; then
            mv "$out/${mainHtmlFile}" "$out/index.html"
            echo "Moved $out/${mainHtmlFile} to $out/index.html"
          else
            echo "Error: $out/${mainHtmlFile} not found after build."
            echo "Files in $out:"
            ls -la $out
            exit 1 # Fail the build if the expected HTML isn't there
          fi
          
          # No other files (PDF, DOCX, RTF) are built or copied for this package.
          # No static assets from ./www are copied for this package.
        '';

    in {
      packages = perSystem (system:
        let
          allFormats = buildAllFormats system;
          webPackage = buildWebOnly system;
        in
        {
          default = allFormats; # 'nix build' will build all formats
          web = webPackage;     # 'nix build .#web' will build only the web version
          # Deprecated: githubPages = buildAllFormats system;
        });

      devShells = perSystem (system: {
        default = import ./shell.nix { pkgs = pkgsFor system; };
      });

      devShell = perSystem (system: self.devShells.${system}.default);

      defaultPackage = perSystem (system: self.packages.${system}.default);
    };
}

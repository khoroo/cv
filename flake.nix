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

      buildGithubPagesFor = system:
        let
          pkgs = pkgsFor system;
          mainDocName = "cv"; # Adjust if your main markdown is e.g. resume.md
        in pkgs.runCommand "github-pages-artifact" {
          nativeBuildInputs = with pkgs; [ pandoc texlive.combined.scheme-context findutils ];
        } ''
          # Build resume documents using Make; output will be in $out
          cd ${self}
          make OUT_DIR="$out" html pdf docx rtf

          # Rename main HTML document to index.html
          if [ -f "$out/${mainDocName}.html" ]; then
            mv "$out/${mainDocName}.html" "$out/index.html"
          else
            echo "Warning: $out/${mainDocName}.html not found to rename to index.html."
            echo "Files in $out:"
            ls -la $out
          fi

          # Copy static assets from ./www (e.g., style.css), excluding www/index.html
          if [ -d "${self}/www" ]; then
            echo "Copying static assets from ${self}/www to $out"
            # Copy files and directories from www, but not www/index.html itself
            find ${self}/www -mindepth 1 -maxdepth 1 -not -name "index.html" -exec cp -r {} $out/ \;
          fi
        '';
    in {
      packages = perSystem (system:
        let
          githubPages = buildGithubPagesFor system;
        in
        {
          inherit githubPages;
          # You might want a 'resume' package as well if you build it differently locally
          # For now, githubPages is the primary build product.
          default = githubPages; 
        });

      devShells = perSystem (system: {
        default = import ./shell.nix { pkgs = pkgsFor system; };
      });

      devShell = perSystem (system: self.devShells.${system}.default);

      defaultPackage = perSystem (system: self.packages.${system}.default);
    };
}

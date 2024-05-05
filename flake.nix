{
  inputs = {
    systems.url = "github:nix-systems/default";
  };

  outputs = {
    systems,
    nixpkgs,
    ...
  } : let
    eachSystem = f:
      nixpkgs.lib.genAttrs (import systems) (
        system:
          f nixpkgs.legacyPackages.${system}
      );
  in {
    packages = eachSystem (pkgs: {
    });

    devShells = eachSystem (pkgs: {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [
            tectonic
            (writeScriptBin "build" ''
              #!/usr/bin/env bash
              function buildit {
                ${pkgs.pandoc}/bin/pandoc -V colorlinks=true -V monofont="DejaVu Sans Mono" --pdf-engine tectonic --include-in-header inline.tex "resume.md" -o "resume.pdf"
              }

              buildit "resume.md"
              ${pkgs.inotify-tools}/bin/inotifywait -qm -e close_write "resume.md" |
              while read
              do
                buildit "resume.md"
              done
            '')
        ];
      };
    });
  };
}

{}:

let
  nodejsOverlay = self: super: {
    nodejs = super.nodejs-13_x;
    yarn = super.yarn // {
      buildInputs = [ self.nodejs ];
    };
  };

  pythonousEnvOverlay = self: super: {
    pythonous-env = super.buildEnv {
      name = "pythonous-env";
      paths = with super; [
        docker-compose
        gnumake

        nodejs
        yarn
        purescript
        spago

        libiconv
        zlib
        ruby_2_6
        poppler_utils
        poppler_data

        stack
        haskellPackages.ghcid
        haskellPackages.hpack

        postgresql_12
      ];
    };
  };

  overlays = [
    nodejsOverlay
    pythonousEnvOverlay
  ];

in

import <nixpkgs> { inherit overlays; }

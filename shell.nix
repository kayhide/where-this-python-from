{ pkgs ? import ./. {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
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
}

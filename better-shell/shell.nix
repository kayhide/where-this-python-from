{ pkgs ? import ./. {}
}:

pkgs.mkShell {
  buildInputs = [ pkgs.pythonous-env ];
}

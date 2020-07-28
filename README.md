# Where this python from?

With this nix setup, python command is available in a nix shell as:

```console
$ nix-shell --pure --run "python --version"
Python 3.8.3
```

While there is no `python` package listed explicitly.

How can we find out where this `python` from?

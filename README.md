# Where this python from?

With this nix setup, python command is available in a nix shell as:

```console
$ nix-shell --pure --run "python --version"
Python 3.8.3
```

While there is no `python` package listed explicitly.

How can we find out where this `python` from?

## Solution

Let's find out the store path of the python first:

```consle
$ nix-shell --run "which python"
/nix/store/f87w21b91cws0wbsvyfn5vnlyv491czi-python3-3.8.3/bin/python
```


Then re-write the `shell.nix` using `buildEnv` instead of `mkShell`.

Naming `better-shell.nix`:

```nix
pkgs.buildEnv {
  name = "pythonous-env";
  paths = with pkgs; [
    # ...
  ];
}
```

The important difference between them is that:
- `mkShell` cannot be built nor be named
- `buildEnv` can be built and be named

To move your `mkShell` to `buildEnv`:
- add `name` attribute
- replace `buildInputs` with `paths`


And write a wrapper to make the env an attribute so that we can refer to it by the attribute path:

`wrapper.nix`
```nix
{ 
  pythonous-shell = import ./better-shell.nix {};
}
```


Now, you are ready to hit `why-depends` and see where the python comes from:

```console
$ nix why-depends -f wrapper.nix pythonous-shell /nix/store/f87w21b91cws0wbsvyfn5vnlyv491czi-python3-3.8.3/bin/python
/nix/store/lphynajzb664gnp7s018b3ns47v1rw57-pythonous-env
╚═══bin/node -> /nix/store/3qal7zbfbx43fcm77s2cy73pw1yaqfw2-nodejs-13.14.0/bin/node
    => /nix/store/3qal7zbfbx43fcm77s2cy73pw1yaqfw2-nodejs-13.14.0
    ╚═══lib/node_modules/npm/node_modules/node-gyp/gyp/gyp_main.py: …#!/nix/store/f87w21b91cws0wbsvyfn>
        => /nix/store/f87w21b91cws0wbsvyfn5vnlyv491czi-python3-3.8.3

```


## Where it the python now?

Let's see where the python is in a better-shell:

```console
$ nix-shell better-shell.nix --run "which python"
which: no python in (/nix/store/x4gd806afbgx0ag1jf8y7blzrrhiyx8q-bash-interactive-4.4-p23/bin:...)

```

It looks the python is gone...

See you, python.

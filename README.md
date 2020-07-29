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


Then re-write the `shell.nix` in terms of `buildEnv` instead of `mkShell`.

The important difference between `mkShell` and `buildEnv` is that:
- `mkShell` cannot be built nor be named
- `buildEnv` can be built and be named


From now on, we will work under the `better-shell` directory.
First, let's move build input packages from `shell.nix` to `default.nix` and make it a derivation for a *env* where depending packages are loaded.

Since we want to use `default.nix` as our custom version of `<nixpkgs>`, make the env an overlay.

`default.nix` have something like:

```nix
pythonousEnvOverlay = self: super: {
  pythonous-env = super.buildEnv {
    name = "pythonous-env";
    paths = with pkgs; [
      # ...
    ];
  };
};
```

Then load it in the `shell.nix`:

```nix
{ pkgs ? import ./. {}
}:

pkgs.mkShell {
  buildInputs = [ pkgs.pythonous-env ];
}
```

Note that `import ./. {}` loads `default.nix` which contains the `pythonous-env` we defined.

Now packages are packed in the `pythonous-env` and we can inspect it by name.

Hit `why-depends` and see where the python comes from:

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
$ nix-shell --run "which python"
which: no python in (/nix/store/x4gd806afbgx0ag1jf8y7blzrrhiyx8q-bash-interactive-4.4-p23/bin:...)

```

Well, the python looks already gone...

See you, python.


## Tips

You can also enumerate depending packages on the python as:

```console
$ nix-store -q --referrers $(which python)
/nix/store/f87w21b91cws0wbsvyfn5vnlyv491czi-python3-3.8.3
/nix/store/mn2klp7l3kn0lfd8f0scb0yc7svmgjyk-python3.8-six-1.15.0
/nix/store/rz9xfa9m4p97v3vwp82alkp5jfh8g7y9-python3.8-idna-2.9
/nix/store/yb06nkcvl6qp6xcw77q1ar46b09mz6q7-python3.8-pycparser-2.20
/nix/store/51jszsalapss28mpjfyd9dj9ghz676q8-python3.8-cffi-1.14.0-dev
/nix/store/ckcgnq2k8p2pb40pfx0x4qnzwsr0b14y-python3.8-pyparsing-2.4.6
/nix/store/h9k9l3crdnvg31g911rdh3232l899y9g-python3.8-packaging-20.4
/nix/store/ybcckqgi75y5pir3dim23wbvk4al00rq-python3.8-cryptography-2.9.2-dev
/nix/store/ynqy5k0lqixqiqshm2id2yl1gwlcs72f-python3.8-pyasn1-0.4.8
/nix/store/3w3sbhamhq7cbbl8hw7p5wqr9g9pdy1q-python3.8-pyOpenSSL-19.1.0-dev
...
```

Although it tends to be a big list, it may help if you have some idea.

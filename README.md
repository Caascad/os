# os

Thin wrapper around `openstack`. Uses `vault` and `caascad-zones` repository to retrieve secrets needed to
authenticate to the `openstack` API.

## Use

First choose an environment to issue `openstack` command:

```sh
os switch <myenv>
```

Now you can issue `openstack` commands against this environment:

```sh
os token issue
```

To get some help:

```sh
os ch
# or
os os_help
```

The help command will retrieve `openstack` command help topic:

```sh
os help
```

You can also display the API RC variable:

```sh
os p -u # -u will also print the password
```

The caascad zones files is retrieved via the environment variable CAASCAD_ZONES_URL.
This variable can be overrided to be a local json file.

```sh
CAASCAD_ZONES_URL=/path/to/my/file os switch bravo
```

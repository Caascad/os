# caos

Thin wrapper around `openstack`. Uses `vault` to retrieve secrets needed to
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

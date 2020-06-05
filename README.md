# caos

Thin wrapper around openstack. Uses vault to retrieve secrets needed to authenticate to the openstack api.

## Use
First choose an environment to issue openstack command:
```
caos switch myenv
```

Now you can issue openstack commands against this environment:
```
caos token issue
```

To get some help:
```
caos ch
# or
caos caos_help
```

The help command will retrieve openstack command help topic:
```
caos help
```

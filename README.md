puppet-loadbalancer
===================

Puppet modules for deployment of nginx based loadbalancer or reverse proxy

General remarks
-------------


Parameters
-------------


Classes
-------------
- loadbalancer

Dependencies
-------------
- voxpupili/puppet-nginx




Examples
-------------
Hiera yaml



Puppet code
```
class { loadbalancer: }
```
Result
-------------
nginx based loadbalancer


Limitations
-------------
This module has been built on and tested against Puppet 5 and higher.


The module has been tested on:
- Ubuntu 18.04LTS


Authors
-------------
Author Name <hugo.vanduijn@naturalis.nl>


# TCP Loadbalancer / reverse proxy
#
#
#
#
#

class loadbalancer::haproxy (

  $config_file = 'rdsgw_haproxy.cfg',

){

# install packages
 ensure_packages(['haproxy'], { ensure => 'present' })

# reload webservice when cert is installed
  exec {'reload haproxy':
    command      => 'service haproxy reload',
    path         => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    refreshonly  => true
  }

  file { "/etc/haproxy/haproxy.cfg":
    source       => "puppet:///modules/loadbalancer/$config_file",
    require      => Package['haproxy'],
    notify       => Exec['reload haproxy'],
  }

}




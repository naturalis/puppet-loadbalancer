# Linnaeus Loadbalancer / reverse proxy
#
#
#
#
#

class loadbalancer (

  nginx::nginx_cfg_prepend:
    include: '/etc/nginx/modules-enabled/*.conf',


# cert_array makes use of letsencryptssl::installcert class
  $cert_array        = ['testcert.naturalis.nl','site1.naturalis.nl'],
  Hash $server       = { 'default_server'      => { 'proxy' => 'http://default_server',
                                                    'server_name'  => ['_'],
                                                    'ssl'          => true,
                                                    'ssl_cert'     => '/etc/letsencrypt/live/testcert.naturalis.nl/fullchain.pem',
                                                    'ssl_key'      => '/etc/letsencrypt/live/testcert.naturalis.nl/privkey.pem',
                                                    'location_cfg_append' => { 'rewrite' => '^ https://testcert.naturalis.nl permanent'},
                                                   },
                   'site1'                     => { 'proxy' => 'http://site1',
                                                    'server_name'  => ['site1.naturalis.nl'],
                                                    'ssl'          => true,
                                                    'ssl_cert'     => '/etc/letsencrypt/live/site1.naturalis.nl/fullchain.pem',
                                                    'ssl_key'      => '/etc/letsencrypt/live/site1.naturalis.nl/privkey.pem',
                                                    'location_cfg_append' => { 'rewrite' => '^ https://site1.naturalis.nl$request_uri permanent'},
                                                   },
                       },
  Hash $location    = {'loc_site1'       => { 'location' => '/admin/',
                                                    'location_cfg_append' => { 'rewrite' => '^ https://$host/otherURL/$request_uri? permanent' },
                                                    'server' => 'site1',
                                                    'proxy' => 'https://site1'},
                     },
  Hash $streamhost = {'stream1'        => {  'ensure'                 => 'present',
                                             'listen_port'            => 8443,
                                             'listen_options'         => '',
                                             'proxy'                  => 'stream1',
                                             'proxy_read_timeout'     => '1',
                                             'proxy_connect_timeout'  => '1'
                                           }
                      },
  Hash $upstream    = { 'site1'          => { 'members' => {
                                                '172.16.1.1:80' => {
                                                   'server' => '172.16.1.1',
                                                   'port'   => 80,
                                                 },
                                              },
                                            },
                         'stream1'        => {'context' => 'stream',
                                              'members' => {
                                                '172.16.1.1:8443' => {
                                                   'server' => '172.16.1.1',
                                                   'port'   => 80,
                                                 },
                                              },
                                            },
                         'default_server' => { 'members' => {
                                                'default_server:80' => {
                                                   'server' => '172.16.1.2',
                                                   'port'   => 80,
                                                 }
                                              },
                                            },
                      }

){

  class { 'letsencryptssl::installcert':
    cert_array             => $cert_array,
    cert_webservice        => 'nginx',
  }


  class { 'nginx':
    names_hash_bucket_size => 512,
    client_max_body_size   => '100M'
  }

#  create_resources
  create_resources(nginx::resource::server,$server,{})
  create_resources(nginx::resource::location,$location,{})
  create_resources(nginx::resource::streamhost,$streamhost,{})
  create_resources(nginx::resource::upstream,$upstream,{})
}


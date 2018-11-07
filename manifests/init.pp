# Linnaeus Loadbalancer / reverse proxy
#
#
#
#
#
class loadbalancer (


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
  Hash $upstream    = { 'site1'               => { 'members' => ['172.16.1.1'] },
                        'default_server'      => { 'members' => ['172.16.1.2'] },
                      },

){

  class { 'letsencryptssl::installcert':
    cert_array             => $cert_array,
    cert_webservice        => 'nginx',
  }


  class { 'nginx':
    names_hash_bucket_size => '512',
    client_max_body_size   => '100M'
  }

#  create_resources
  create_resources(nginx::resource::server,$server,{})
  create_resources(nginx::resource::location,$location,{})
  create_resources(nginx::resource::upstream,$upstream,{})
}


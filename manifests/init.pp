# TCP Loadbalancer / reverse proxy
#
#
#
#
#

class loadbalancer (

  $cert_array        = [],

  Hash $server =   { 'rdsgw.naturalis.nl' => {
                        ensure              => present,
                        location_cfg_append => { 'rewrite' => '^(.*) https://$server_name$request_uri? permanent' },
                        },
                    },


  Hash $streamhost = {'stream'        => {  'ensure'                 => 'present',
                                            'listen_port'           => 443,
                                            'listen_options'        => '',
                                            'proxy'                 => 'stream',
                                            'proxy_read_timeout'    => '1',
                                            'proxy_connect_timeout' => '1'
                                          },
                      },



  Hash $location    = { },

# 'location'       => { 'location'            => '/',
#                                             'location_cfg_append' => { 'rewrite' => '^(.*) https://$host/otherURL/$request_uri? permanent' },
#                                             'server'              => 'rdsgw.naturalis.nl',
#
#                                           },
#                      },


  Hash $upstream    = { 'stream'   => { 'context' => 'stream',
                                        'members' =>
                                                {
                                                '172.16.51.169:443' => {
                                                'server' => '172.16.51.169',
                                                'port'   => 443,
                                                },
                                              },
                                            },
                      },




){


  class { 'nginx':
    names_hash_bucket_size => 512,
    client_max_body_size   => '100M',
    dynamic_modules        => [ '/usr/lib/nginx/modules/ngx_stream_module.so' ],
    stream                 => true
    }

  class { 'letsencryptssl::installcert':
    cert_array             =>  $cert_array,
    cert_webservice        =>  'nginx',
  }


#  create_resources
  create_resources(nginx::resource::server,$server,{})
  create_resources(nginx::resource::location,$location,{})
  create_resources(nginx::resource::streamhost,$streamhost,{})
  create_resources(nginx::resource::upstream,$upstream,{})
}


server 'localhost', user: 'vagrant', roles: %w{app db web}

set :ssh_options, {
    keys: %w(~/.ssh/vagrant_rsa),
    port: 2222,
  }
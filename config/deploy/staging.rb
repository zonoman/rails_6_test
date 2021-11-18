set :branch, 'master'

server '13.113.58.86', user: 'deploy', roles: %w{app web}

set :node_env, 'staging'
set :ssh_options, {
  keys: %w(~/.ssh/b-engineer/deploy/id_rsa),
  forward_agent: true,
  auth_methods: %w(publickey)
}

# Test out the deploy mechanism
include_recipe 'git::default'

one_time_pad = (0...8).map { (65 + rand(26)).chr }.join
log 'password' do
  message one_time_pad
  level   :info
  action  :nothing
end

user 'dfinninger' do
  comment   'main user'
  home      '/home/dfinninger'
  shell     '/bin/bash'
  password  one_time_pad
  notifies  :write, 'log[password]', :delayed
end

%w{
  /var/code
  /var/code/shared
  /var/code/shared/config
}.each { |dir| directory dir }
file '/var/code/shared/config/database.yml' do
  action :touch
end

deploy_revision 'deploy_test' do
  repo      'https://github.com/dfinninger/lita-cmd.git'
  user      'dfinninger'
  deploy_to '/var/code'
  symlinks({}) # nil
  symlink_before_migrate({}) # nil
  action    :deploy
end

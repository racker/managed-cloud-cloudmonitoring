#
# Cookbook Name:: raxmon-cli
# Recipe:: default
#
# Copyright 2012, Rackspace Hosting
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
include_recipe "python"

#Install all our pre-reqs
case node['platform']
when "ubuntu","debian"
  package( "libxslt-dev" ).run_action( :install )
  package( "libxml2-dev" ).run_action( :install )
  package( "ruby-dev" ).run_action( :install )
  package( "rubygems" ).run_action( :install )

when "redhat","centos","fedora", "amazon","scientific"
  package( "libxslt-devel" ).run_action( :install )
  package( "libxml2-devel" ).run_action( :install )
  package( "ruby-devel" ).run_action( :install )
  package( "rubygems" ).run_action( :install )

  major_version = node['platform_version'].split('.').first.to_i
  if platform_family?('rhel') && major_version < 6
   package( "python-setuptools" ).run_action( :install )
   package( "python26-devel" ).run_action( :install )
   package( "python26-distribute" ).run_action( :install )
   
   execute "install_pip2.6" do
      command "easy_install-2.6 pip" 
      action :run
   end
  end
end

#Install ruby gems into Chef ruby env
chef_gem "rackspace-fog" do
  action :install
end

chef_gem"rackspace-monitoring" do
  version node['cloud_monitoring']['rackspace_monitoring_version']
  action :install
end

require 'rubygems'
Gem.clear_paths
require 'rackspace-monitoring'
require 'rackspace-fog'

#Create the .raxrc with credentials in /root
template "/root/.raxrc" do
  source "raxrc.erb"
  owner "root"
  group "root"
  mode 0600
  variables(
    :raxusername => node['cloud_monitoring']['rackspace_username'],
    :raxapikey => node['cloud_monitoring']['rackspace_api_key'],
    :raxauthurl => node['cloud_monitoring']['rackspace_auth_url'] 
  )
end

case node['platform']
when "ubuntu","debian"

execute "install_raxmon" do
      command "pip install rackspace-monitoring-cli"
      user "root"
end

when "redhat","centos","fedora"

  major_version = node['platform_version'].split('.').first.to_i
  if platform_family?('rhel') && major_version < 6

    execute "install_raxmon" do
      command "pip install rackspace-monitoring-cli"
      user "root"
    end
  else
    python_pip "rackspace-monitoring-cli" do
      action :upgrade
    end
  end
end

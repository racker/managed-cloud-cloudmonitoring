#
# Cookbook Name:: cloud_monitoring
# Recipe:: default
#
# Copyright 2012, Rackspace
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

if File.exists?("/root/.noupdate") 
  Chef::Log.info "The customer does not want the monitoring agent."
else

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

    execute "install_pip26" do
        command "easy_install-2.6 pip"
        user "root"
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

#TODO - This should find the correct endpoint based on the rackspace::datacenter recipe
  if node['cloud_monitoring']['rackspace_auth_region'] == 'us'
    node.set['cloud_monitoring']['rackspace_auth_url'] = 'https://identity.api.rackspacecloud.com/v2.0'
  elsif node['cloud_monitoring']['rackspace_auth_region']  == 'uk'
    node.set['cloud_monitoring']['rackspace_auth_url'] = 'https://lon.identity.api.rackspacecloud.com/v2.0'
  else
    Chef::Log.info "Using the encrypted data bag for rackspace cloud but no raxregion attribute was set (or it was set to something other then 'us' or 'uk'). Assuming 'us'. If you have a 'uk' account make sure to set the raxregion in your data bag"
    node.set['cloud_monitoring']['rackspace_auth_url'] = 'https://identity.api.rackspacecloud.com/v2.0'
  end

  #Calling the other recipes needed for a full install. This could be moved to a role or run_list. 
  include_recipe "cloudmonitoring::raxmon"
  include_recipe "cloudmonitoring::agent"
  include_recipe "cloudmonitoring::checks"

end

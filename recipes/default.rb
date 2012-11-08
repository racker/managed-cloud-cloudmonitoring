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
  Chef::Log.info "The customer does not want the MC kick or our agents."
else

  case node['platform']
  when "ubuntu","debian"

  execute "update package index" do
    command "apt-get update"
    ignore_failure true
    action :nothing
  end.run_action(:run)

    package( "libxslt1-dev" ).run_action( :upgrade )
    package( "libxml2-dev" ).run_action( :upgrade )
    package( "ruby-dev" ).run_action( :upgrade )
    package( "build-essential" ).run_action( :upgrade )
  
  when "redhat","centos","fedora"
    include_recipe 'yum::epel'
    package( "libxslt1-devel" ).run_action( :upgrade )
    package( "libxml2-devel" ).run_action( :upgrade )  
  end


  r = gem_package "rackspace-monitoring" do
    version node['cloud_monitoring']['rackspace_monitoring_version']
    action :nothing
  end

  r.run_action(:install)

  require 'rubygems'
  Gem.clear_paths
  require 'rackspace-monitoring'

  if node['cloud_monitoring']['rackspace_auth_region'] == 'us'
    node['cloud_monitoring']['rackspace_auth_url'] = 'https://identity.api.rackspacecloud.com/v2.0'
  elsif node['cloud_monitoring']['rackspace_auth_region']  == 'uk'
    node['cloud_monitoring']['rackspace_auth_url'] = 'https://lon.identity.api.rackspacecloud.com/v2.0'
  else
   Chef::Log.info "Rackspace Monitoring Region: US"
    node['cloud_monitoring']['rackspace_auth_url'] = 'https://identity.api.rackspacecloud.com/v2.0'
  end

  if node[:cloud_monitoring][:rackspace_username] == 'your_rackspace_username' || node['cloud_monitoring']['rackspace_api_key'] == 'your_rackspace_api_key'
    Chef::Log.info "Username, API Key or Region has not been set."
  end

  include_recipe "cloudmonitoring::raxmon"
  include_recipe "cloudmonitoring::agent"
  include_recipe "cloudmonitoring::checks"
end

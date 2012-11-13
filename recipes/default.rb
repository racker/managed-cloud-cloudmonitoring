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

  case node[:platform]
when "redhat","centos"

   cookbook_file "/etc/yum.repos.d/raxmon.repo" do
    source "raxmon.repo"
    action :create
   end

   major_version = node['platform_version'].split('.').first.to_i
   if platform_family?('rhel') && major_version < 6

      cookbook_file "/etc/yum.repos.d/raxmon.repo" do
         source "raxmon5.repo"
         action :create
      end
   end

  execute "yum -q makecache"
  ruby_block "reload-internal-yum-cache" do
    block do
      Chef::Provider::Package::Yum::YumCache.instance.reload
    end
  end
when "ubuntu"
  keyfile = cookbook_file "/tmp/signing-key.asc" do
    source "signing-key.asc"
    action :nothing
  end
  keyfile.run_action(:create)

  aptkey = execute "apt-key add /tmp/signing-key.asc" do
    action :nothing
  end
  aptkey.run_action(:run)

  list = cookbook_file "/etc/apt/sources.list.d/raxmon.list" do
    source "raxmon.list"
    action :nothing
  end
  list.run_action(:create)

  apt = execute "update apt" do
    command "apt-get update"
    ignore_failure true
    action :nothing
  end
  begin
    apt.run_action(:run)
  rescue
    Chef::Log.warn("apt-get exited with non-0")
  end
end



node.set['cloud_monitoring']['datacenter'] = File.open('/etc/rackspace/datacenter') {|f| f.readline}
Chef::Log.info "Datacenter: #{node['cloud_monitoring']['datacenter']}"

case node['cloud_monitoring']['datacenter']
   when "SAT1", "SAT2", "IAD1", "IAD2", "DFW1", "ORD1"
      node.set['cloud_monitoring']['rackspace_auth_region'] == 'us'
      node.set['cloud_monitoring']['rackspace_auth_url'] = 'https://identity.api.rackspacecloud.com/v2.0'

   when "LON3" 
      node.set['cloud_monitoring']['rackspace_auth_region']  == 'uk'
      node.set['cloud_monitoring']['rackspace_auth_url'] = 'https://lon.identity.api.rackspacecloud.com/v2.0'
   end

  #Calling the other recipes needed for a full install. This could be moved to a role or run_list. 
  include_recipe "cloudmonitoring::agent"
  include_recipe "cloudmonitoring::checks"

end

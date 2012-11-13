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


#Pull entity id from list of active identities
cloudmonitoring_entity "#{node.hostname}" do
  agent_id            node['cloud_monitoring']['agent']['id']
  rackspace_username  node['cloud_monitoring']['rackspace_username']
  rackspace_api_key   node['cloud_monitoring']['rackspace_api_key']
  action :create
end

##Install Agent
package "rackspace-monitoring-agent" do
  if node['cloud_monitoring']['agent']['version'] == 'latest'
    action :upgrade
  else
    version node['cloud_monitoring']['agent']['version']
    action :install
  end

  notifies :restart, "service[rackspace-monitoring-agent]"
end

#TODO: Not returning the agent token
cloudmonitoring_agent_token "#{node.hostname}" do
  rackspace_username  node['cloud_monitoring']['rackspace_username']
  rackspace_api_key   node['cloud_monitoring']['rackspace_api_key']
  action :create
end

#Place Agent config file 
template "/etc/rackspace-monitoring-agent.cfg" do
  source "rackspace-monitoring-agent.erb"
  owner "root"
  group "root"
  mode 0600
  variables(
    :monitoring_id => node['cloud_monitoring']['agent']['id'],
    :monitoring_token => node['cloud_monitoring']['agent']['token']
  )
end

#TODO - BANDAID for the agent_token not returning an id
#execute "create_token" do
#   command "TOKEN=`raxmon-agent-tokens-create --label=#{node['cloud_monitoring']['agent']['id']} | awk '{print $4}'` && sed -i \"s/monitoring_token ChangeMe/monitoring_token $TOKEN/g\" /etc/rackspace-monitoring-agent.cfg"      
#   user "root"
#end

#Set to start on boot
service "rackspace-monitoring-agent" do
  case node["platform"]
  when "centos","redhat","fedora"
    supports :restart => true, :status => true
  when "debian","ubuntu"
    supports :restart => true, :reload => true, :status => true
  end
  action [:enable, :start]
  action [:restart]  
end

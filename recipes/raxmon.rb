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

#
# Cookbook Name:: cloudmonitoring
# Recipe:: checks
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

if node['cloud_monitoring']['rackspace_service_level'] == "managed" 
	cloudmonitoring_check  "Root Filesystem Check" do
	  target_alias          'default'
	  type                  'agent.filesystem'
	  period                30
	  timeout               10
	  rackspace_username    node['cloudmonitoring']['rackspace_username']
	  rackspace_api_key     node['cloudmonitoring']['rackspace_api_key']
	  action :create
	end

	cloudmonitoring_alarm  "Root File System Alarm" do
	  check_label           'Root Filesystem Check'
	  example_id            'agent.managed_low_filesystem_avail'
	  metadata            	'template_name' => 'agent.managed_low_filesystem_avail'
	  notification_plan_id  'npManaged'
	  action :create
	end

	cloudmonitoring_check  "Server Load Check" do
	  target_alias          'default'
	  type                  'agent.managed_high_load_average'
	  period                30
	  timeout               10
	  rackspace_username    node['cloudmonitoring']['rackspace_username']
	  rackspace_api_key     node['cloudmonitoring']['rackspace_api_key']
	  action :create
	end

	cloudmonitoring_check  "Server Swap Check" do
	  target_alias          'default'
	  type                  'agent.managed_low_swap_free'
	  period                30
	  timeout               10
	  rackspace_username    node['cloudmonitoring']['rackspace_username']
	  rackspace_api_key     node['cloudmonitoring']['rackspace_api_key']
	  action :create
	end

else
	cloudmonitoring_check  "Filesystem Check" do
	  target_alias          'default'
	  type                  'agent.filesystem'
	  details               'target' => '/'
	  period                30
	  timeout               10
	  rackspace_username    node['cloudmonitoring']['rackspace_username']
	  rackspace_api_key     node['cloudmonitoring']['rackspace_api_key']
	  action :create
	end

	cloudmonitoring_alarm  "File System Alarm" do
	  check_label           'Filesystem Check'
	  example_id            'agent.filesystem_usage'
	  example_values		'mount_point' => '/', 'critical_threshold' => "99", 'warning_threshold' => "90"
	  notification_plan_id  'npTechnicalContactsEmail'
	  action :create
	end
end
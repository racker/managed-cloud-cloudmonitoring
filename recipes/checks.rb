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

cloudmonitoring_check  "Filesystem Check" do
  target_alias          'default'
  type                  'agent.filesystem'
  details               'target' => '/'
  period                30
  timeout               10
  rackspace_username    node['cloud_monitoring']['rackspace_username']
  rackspace_api_key     node['cloud_monitoring']['rackspace_api_key']
  action :create
end

#cloudmonitoring_check  "Server Load Check" do
#  target_alias          'default'
#  type                  'agent.load_average'
#  period                30
#  timeout               10
#  rackspace_username    node['cloud_monitoring']['rackspace_username']
#  rackspace_api_key     node['cloud_monitoring']['rackspace_api_key']
#  action :create
#end


#cloudmonitoring_check  "Server Swap Check" do
#  target_alias          'default'
#  type                  'agent.memory'
#  period                30
#  timeout               10
#  rackspace_username    node['cloud_monitoring']['rackspace_username']
#  rackspace_api_key     node['cloud_monitoring']['rackspace_api_key']
#  action :create
#end

cloudmonitoring_alarm  "File System Alarm" do
  check_label           'Filesystem Check'
  metadata            	'template_name' => 'agent.managed_low_filesystem_avail'
  example_id            'agent.managed_low_filesystem_avail'
  notification_plan_id  node['cloud_monitoring']['notification_plan']
  action :create
end

#cloudmonitoring_alarm  "Server Load Alarm" do
#  check_label           'Server Load Check'
#  metadata            	'template_name' => 'agent.managed_high_load_average'
#  example_id            'agent.managed_high_load_average'
#  notification_plan_id  node['cloud_monitoring']['notification_plan']
#  action :create
#end

#cloudmonitoring_alarm  "Server Swap Alarm" do
#  check_label           'Server Swap Check'
#  metadata            	'template_name' => 'agent.managed_low_swap_free'
#  example_id            'agent.managed_low_swap_free'
#  notification_plan_id  node['cloud_monitoring']['notification_plan']
#  action :create
#end

#  Copyright 2012 Rackspace
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

import urllib2 
import argparse
import socket

try:
    import json
except ImportError:
    import simplejson as json


class RestHTTPErrorProcessor(urllib2.BaseHandler):
    def http_error_201(self, request, response, code, message, headers):
        return response

    def http_error_204(self, request, response, code, message, headers):
        return response


def request(url, auth_token=None, data=None):
    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json"
    }

    if auth_token:
        headers['X-Auth-Token'] = auth_token
    if data:
        data = json.dumps(data)

    req = urllib2.Request(url, data, headers)
    res = urllib2.build_opener(RestHTTPErrorProcessor).open(req)

    if res.code == 200:
        return json.loads(res.read())
    elif res.code == 201 or res.code == 204:
        return res.headers['Location'].rsplit("/")[-1]
    

def auth(username, api_key, uk=False):
    url = None

    if uk:
        url = 'https://lon.identity.api.rackspacecloud.com/v2.0/tokens'
    else:
        url = 'https://identity.api.rackspacecloud.com/v2.0/tokens'

    data = {
        "auth": {
            "RAX-KSKEY:apiKeyCredentials": {
                "username": username,
                "apiKey": api_key
            }
        }
    }

    return request(url, data=data)


class CloudMonitoring:
    def __init__(self, username, api_key, uk=False):
        auth_access = auth(username, api_key, uk)["access"]
        self.token = auth_access["token"]["id"]
        self.base_url = filter(lambda entry: entry["name"] == "cloudMonitoring", auth_access["serviceCatalog"])[0]["endpoints"][0]["publicURL"]

    def __request(self, path, data=None):
        return request(self.base_url + path, self.token, data)

    def get_agent_tokens(self):
        return self.__request("/agent_tokens")

    def create_token(self, data):
        return self.__request("/agent_tokens/", data)

    def get_my_token(self, hostname):
        my_key = ''
        d = self.get_agent_tokens()['values']
        for v in d:
            if v['label'] == hostname: 
                my_key = v['id']
        return my_key
        
if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='Get Agent Token.')

    parser.add_argument('--username', dest='username', help='Rackspace Cloud Username', required=True)
    parser.add_argument('--api_key', dest='api_key', help='Rackspace Cloud API Key', required=True)
    parser.add_argument('--region', dest='region', help='Cloud Server Region (us or uk)')
    parser.add_argument('--hostname', dest='hostname', help='Hostname of Cloud Server')

    args = parser.parse_args()
    
    hostname = args.hostname
    region = args.region
    username = args.username
    api_key = args.api_key

    if not hostname:
        hostname = socket.gethostname()

    uk_user = False
    if region == 'uk':
        uk_user = True

    cm = CloudMonitoring(username, api_key, uk_user)
    agent_token = cm.get_my_token(hostname)


    if not agent_token:
        new_token = cm.create_token({"label": hostname})
        print new_token
    else:
        print agent_token



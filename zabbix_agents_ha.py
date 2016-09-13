#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import requests
from pprint import pprint
import json
import base64
import sys

pass_path = '/home/gvpuser/scripts/'
xml_path = '/home/gvpuser/scripts/templates/'
zabbix_url = 'http://10.26.192.48'
api = zabbix_url + '/api_jsonrpc.php'
hostgroup = sys.argv[1]
item = sys.argv[2]
#number_servers_get_up = int(sys.argv[3])

#Get passwd from file

def GetPasswd():
    filename = open(pass_path + 'pass.txt','r')
    lines = filename.read().splitlines()
    u = lines[0]
    p = lines[1]
    filename.close()
    return u,p

gp = GetPasswd()
u = base64.b64decode(gp[0])
p = base64.b64decode(gp[1])

#login to zabbix
load = {
    "jsonrpc" : "2.0",
    "method" : "user.login",
    "params": {
      "user": u,
      "password": p,
    },
    "auth" : None,
    "id" : 0,
}
headers = {
    "content-type": "application/json",
}
res = requests.post(api, data=json.dumps(load), headers=headers)
res = res.json()

def GetGroupId(hostgroup):
	load = {
		"jsonrpc" : "2.0",
		"method" : "hostgroup.get",
		"params": {
			"output": [
			  "groupid"
			],
		    "filter": {
              "name": [ hostgroup ]
            }        
		},
		"auth" : res['result'],
		"id" : 1,
	}
	res1 = requests.post(api, data=json.dumps(load), headers=headers)
	res1 = res1.json()

	groupid = [ u['groupid'] for u in res1['result'] ]

	return groupid[0]
	
def GetHost(groupid):
	load = {
		"jsonrpc" : "2.0",
		"method" : "host.get",
		"params": {
			"output": [
			  "name"
			],
			"groupids": [ groupid ]      
		},
		"auth" : res['result'],
		"id" : 2,
	}
	res2 = requests.post(api, data=json.dumps(load), headers=headers)
	res2 = res2.json()

	servers = [ u['name'] for u in res2['result'] ]
		
	return servers
	
def GetHostId(groupid):
	load = {
		"jsonrpc" : "2.0",
		"method" : "host.get",
		"params": {
			"output": [
			  "hostid"
			],
			"groupids": [ groupid ]      
		},
		"auth" : res['result'],
		"id" : 3,
	}
	res3 = requests.post(api, data=json.dumps(load), headers=headers)
	res3 = res3.json()

	hostids = [ u['hostid'] for u in res3['result'] ]
	
	return hostids
	
def GetItemId(item):
	load = {
		"jsonrpc" : "2.0",
		"method" : "item.get",
		"params": {
			"output": [
			  "itemid",
			  "name"
			],
			"filter": {
              "name": [ item ]
            }
#			"groupids": [ groupid ]      
		},
		"auth" : res['result'],
		"id" : 4,
	}
	res4 = requests.post(api, data=json.dumps(load), headers=headers)
	res4 = res4.json()

#	itemids = [ u['itemid'] for u in res4['result'] ]
	itemids = res4['result']
	
	return itemids	

def GetHistory(hostids):
	load = {
		"jsonrpc" : "2.0",
		"method" : "history.get",
		"params": {
#			"output": [
#			  "hostid"
#			],
			"hostids": [ hostids ]      
		},
		"auth" : res['result'],
		"id" : 5,
	}
	res5 = requests.post(api, data=json.dumps(load), headers=headers)
	res5 = res5.json()

#	history = [ u['hostids'] for u in res5['result'] ]
	history = res5['result']
	
	return history

groupid = GetGroupId(hostgroup)
print groupid

servers = GetHost(groupid)
print servers

hostids = GetHostId(groupid)
print hostids

itemids = GetItemId(item)
print itemids

history = GetHistory(hostids)
print history
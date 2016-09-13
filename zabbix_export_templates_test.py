#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import requests
from pprint import pprint
import json
#from xml.sax.saxutils import unescape
import base64

zabbix_url = 'http://172.20.0.5/zabbix'
api = zabbix_url + '/api_jsonrpc.php'

def GetPasswd():
    filename = open('/root/scripts/pass.txt','r')
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
      'user': u,
      'password': p,
    },
    "auth" : None,
    "id" : 0,
}
headers = {
    'content-type': 'application/json',
}
res = requests.post(api, data=json.dumps(load), headers=headers)
res = res.json()

# read all templates ids and names
load = {
    "jsonrpc" : "2.0",
    "method" : "template.get",
    "params": {
      'output': [
         'templateid',
	     'name'
	 ]
    },
    "auth" : res['result'],
    "id" : 2,
}
res2 = requests.post(api, data=json.dumps(load), headers=headers)
res2 = res2.json()
#pprint(res2['result'])

#export all templates to xml files
for i in res2['result']:
	load = {
		"jsonrpc" : "2.0",
		"method" : "configuration.export",
		"params": {
		  'options': {
			  'templates': [ 
			  i['templateid']
			  ]
		   },
		   "format": "xml"
		},
		"auth" : res['result'],
		"id" : 3,
	}
	res3 = requests.post(api, data=json.dumps(load), headers=headers)
	res3 = res3.json()

	file = open('/root/scripts/templates/' + i['name'] + '.xml', 'w')
#	file.write(unescape(res3['result'].encode('utf-8'),{"&apos;": "'", "&quot;": '"'}))
    file.write(res3['result'].encode('utf-8'))
	file.close()

#for i in res2['result']:
#    pprint(i['name'])

#pprint(res4['result'])
#pprint(res4)

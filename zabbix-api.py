#!/usr/bin/python

import requests
from pprint import pprint
import json
from xml.sax.saxutils import unescape
import base64


ZABIX_ROOT = 'http://172.20.0.5/zabbix'
url = ZABIX_ROOT + '/api_jsonrpc.php'

u = base64.b64decode("QWRtaW4=")
p = base64.b64decode("aDFwcGowa2s=")

print u
print p

########################################
# user.login
########################################
load = {
    "jsonrpc" : "2.0",
    "method" : "user.login",
    "params": {
      'user': u,
      'password':p,
    },
    "auth" : None,
    "id" : 0,
}
headers = {
    'content-type': 'application/json',
}
res = requests.post(url, data=json.dumps(load), headers=headers)
res = res.json()
#print 'user.login response'
#pprint(res)

########################################
# host.get
########################################
load = {
    "jsonrpc" : "2.0",
    "method" : "host.get",
    "params": {
      'output': [
          'hostid',
          'name'],
    },
    "auth" : res['result'],
    "id" : 2,
}
res2 = requests.post(url, data=json.dumps(load), headers=headers)
res2 = res2.json()
#print 'host.get response'
#pprint(res2)

########################################
# template.get
########################################
load = {
    "jsonrpc" : "2.0",
    "method" : "template.get",
    "params": {
      'output': [
          'templateid',
          'name'],
    },
    "auth" : res['result'],
    "id" : 3,
}
res3 = requests.post(url, data=json.dumps(load), headers=headers)
res3 = res3.json()
#print 'template.get response'
#pprint(res3)

########################################
# configuration.export
########################################
load = {
    "jsonrpc" : "2.0",
    "method" : "configuration.export",
    "params": {
      'options': {
          'templates': [ 
          '10139'
		  ]
	   },
       "format": "xml"
    },
    "auth" : res['result'],
    "id" : 4,
}
res4 = requests.post(url, data=json.dumps(load), headers=headers)
res4 = res4.json()
file = open('/root/scripts/GVP Template SEO' + '.xml', 'w')
#file.write(str(res4['result'].encode('utf-8')))
file.write(unescape(res4['result'].encode('utf-8'),{"&apos;": "'", "&quot;": '"'}))
file.close()



#print 'configuration.export response'
#pprint(res4)

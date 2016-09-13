########################################################################################
#                                                                                      #
# NAME:     agents_ha.py                                                               #
#                                                                                      #
# AUTHOR:   Jose Manuel Murillo Martinez, David Alonso                                 #
# COMPANY:  TCP Sistemas e Ingenieria, S.L.                                            #
# EMAIL:    jmmurillo@tcpsi.es, dalonso@tcpsi.es                                       #
#                                                                                      #
# DESCRIPTION:  Script to Restart a service in another server of a hostgroup           #
#           @Param:                                                                    #
#               -h|hostgroup: Hostgroup with high availability service                 #
#               -s|service: service name in high availability                          #
#               -n: Number of services have to be running on differents servers        #
#                                                                                      #
#           @Return:                                                                   #
#                                                                                      #
#           @Error:                                                                    #
#                                                                                      #
#           @Usage:                                                                    #
#               ./agents_ha.py "Zabbix server" "prueba servicio nfs"                   #
#                                                                                      #
# CHANGELOG:                                                                           #
# 1.0 2016-04-18 - Initial version                                                     #
#                                                                                      #
########################################################################################

#!/usr/bin/env python

import random
import string
import ConfigParser
import sys
import signal
import ldap
import base64
import binascii
import pickle
import zabbix_api
import ast
import os
from docopt import docopt

class ZabbixConn(object):
    """
    Zabbix connector class

    Defines methods for managing Zabbix users and groups

    """
    def __init__(self, server, username, password):
        self.server   = server
        self.username = username
        self.password = password

    def connect(self):
        """
        Establishes a connection to the Zabbix server

        Raises:
            SystemExit

        """
        self.conn = zabbix_api.ZabbixAPI(server=self.server)


        try:
            self.conn.login(user=self.username, password=self.password)
        except zabbix_api.ZabbixAPIException as e:
            raise SystemExit, '3'
            #raise SystemExit, 'Cannot login to Zabbix server: %s' % e
    
    def get_group_id(self, group):
        """
        Retrieves the groupid of a specified group

        Args:
            group (str): The Zabbix group to lookup

        Returns:
            The groupid of the specified group

        """
        req = self.conn.json_obj(method='hostgroup.get', params={'output': 'extend'})
        result = self.conn.do_request(req)

        groupid = [u['groupid'] for u in result['result'] if u['name'] == group].pop()

        return groupid


    def host_get(self, group):
        """
        Retrieves the existing hosts belong a group

        Returns:
            A list of the existing Zabbix hosts

        """
	groupid =self.get_group_id(group)

        req = self.conn.json_obj(method='host.get', params={'groupids': groupid})
        result = self.conn.do_request(req)

        servers = [u['name'] for u in result['result']]

        return servers

    def get_host_id(self, host):
        """
        Retrieves the hostid of a specified item

        Args:
            host (str): The Zabbix item to lookup

        Returns:
            The hostid of the specified host

        """
        req = self.conn.json_obj(method='host.get', params={'output': 'extend'})
        result = self.conn.do_request(req)

        hostid = [u['hostid'] for u in result['result'] if u['name'] == host].pop()

        return hostid


    def get_item_id(self, item, host):
        """
        Retrieves the itemid of a specified item

        Args:
            item (str): The Zabbix item to lookup

        Returns:
            The itemid of the specified item

        """
	hostid =self.get_host_id(host)
        req = self.conn.json_obj(method='item.get', params={'output': 'extend', 'hostids': hostid})
        result = self.conn.do_request(req)

        for u in result['result']:
          if u['name']== item:
            itemid = [u['itemid']].pop()
            return itemid
          else:
            continue
        #itemid = [u['itemid'] for u in result['result'] if u['name'] == item].pop()

        #return itemid

    def get_history(self, item, host, itemid):
        """
        Retrieves the latest value of a specified item

        Args:
            itemid (str): The Zabbix itemid to lookup

        Returns:
            The latest value of the specified itemid

        """
        itemid =self.get_item_id(item, host)
        req = self.conn.json_obj(method='history.get', params={'output': 'extend', 'history': '3','itemids': itemid, 'sortfield': 'clock','sortorder': 'DESC','limit': '2'})
        result = self.conn.do_request(req)
	
	clock = [u['clock'] for u in result['result']]
	value = [u['value'] for u in result['result']]
	total = [clock,value]

        return total

    def get_hostinterface(self, hostid, host):
        """
        Retrieves the ip of a hostid given

        Args:
            hostid (str): The Zabbix hostid to lookup

        Returns:
            Teh ip of a hostid given

        """
        hostid =self.get_host_id(host)
        req = self.conn.json_obj(method='hostinterface.get', params={'output': 'extend','hostids': hostid})
        result = self.conn.do_request(req)
        ip = [u['ip'] for u in  result['result']]
        return ip

# declare variables
hostgroup = sys.argv[1]
item = sys.argv[2]
number_servers_get_up = int(sys.argv[3])
list_possible_servers = []
list_ip_possible_servers = []
i = 0
number_servers_ok = 0

zabbix_conn = ZabbixConn("http://172.20.0.5/zabbix/", "Admin","h1ppj0kk")
zabbix_conn.connect()
servers=zabbix_conn.host_get(hostgroup)

for u in servers:
  
  itemid=zabbix_conn.get_item_id(item, u)
  if itemid is None:
    continue
  print "host: %s" % (u) 
  host=zabbix_conn.get_host_id(u)
  print "hostid: %s" % host
  #itemid=zabbix_conn.get_item_id(sys.argv[2], u)
  print "itemid: %s" % itemid
  ip=zabbix_conn.get_hostinterface(host, u)
  print "ip: %s" % ip[0]
  history=zabbix_conn.get_history(sys.argv[2], u, itemid)
  #testing#
  #print history[0][0]
  #print history[0][1]
  print history[1][0]
  print history[1][1]
  print "clock %s" % history[0][0]
  print "value %s" % history[1][0]
  if history[1][0]=='0' and history[1][1]=='0':
    list_possible_servers.insert(i,u)
    list_ip_possible_servers.insert(i,ip[0])
    i = i + 1
  if history[1][1] =='1':
    number_servers_ok = number_servers_ok + 1
  
print "%s" %list_possible_servers
number_servers_get_up = number_servers_get_up - number_servers_ok

for num in range(0,number_servers_get_up):
  print "server levantado: %s y su ip %s" % (list_possible_servers[num],list_ip_possible_servers[num])
#  command = "/usr/bin/zabbix_get -s %s -k agent.version" % list_ip_possible_servers[num]
  command = "/usr/bin/zabbix_get -s %s -k system.run['sudo service ntpd start']" % list_ip_possible_servers[num]
  os.system(command)

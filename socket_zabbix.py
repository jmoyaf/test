#!/usr/bin/env python                                                                                           
#like zabbix_get
                                                                                                                
import socket                                                                                                   
import struct                                                                                                   
import sys, getopt                                                                                              
                                                                                                                
                                                                                                                
                                                                                                                
HOST = '10.26.192.51'           # Set the remote host, for testing it is localhost                              
PORT = 10050            # The same port as used by the server                                                   
KEY = ''                                                                                                        
                                                                                                                
                                                                                                                
def __pack(request):                                                                                            
	header = struct.pack('<4sBQ', 'ZBXD', 1, len(request))                                                      
	return header + request                                                                                     
                                                                                                                
def __unpack(response):                                                                                         
	header, version, length = struct.unpack('<4sBQ', response[:13])                                             
	(data, ) = struct.unpack('<%ds'%length, response[13:13+length])                                             
	return data                                                                                                 
                                                                                                                
                                                                                                                
def _do_request(keys):                                                                                          
	s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)                                                       
	s.connect((HOST, int(PORT)))                                                                                
	s.sendall(__pack(keys))                                                                                     
	total_data = ''                                                                                             
	while True:                                                                                                 
		data = s.recv(8192)                                                                                     
		if not data: break                                                                                      
		total_data += data                                                                                      
	print __unpack(total_data)                                                                                  
	return __unpack(total_data)                                                                                 
                                                                                                                
def main(argv):                                                                                                 
	global HOST                                                                                                 
	global PORT                                                                                                 
	global KEY                                                                                                  
	try:                                                                                                        
		                                                                                                        
		                                                                                                        
		opts, args = getopt.getopt(argv,"hs:p:k:",["host=", "port=", "key="])                                   
		if not opts:                                                                                            
			print 'Usage:\n' + __file__ + ' [-h] [-s <host name or IP>] [-p <port>] -k <key>'                   
			print """                                                                                           
Options:                                                                                                        
-s, --host <host name or IP>                                                                                    
	Specify host name or IP address of a host. Default value is 127.0.0.1                                       
-p, --port <port>                                                                                               
	Specify port number of agent running on the host. Default value is 10050                                    
-k, --key <key of metric>                                                                                       
	Specify key of item to retrieve value for                                                                   
-h, --help                                                                                                      
	Display help information                                                                                    
Example: ./socket_zabbix.py -s 10.50.0.1 -p 10050 -k agent.ping                                                 
Be sure that IP is in Server inside of /etc/zabbix/zabbix_agentd.conf                                           
				"""                                                                                             
			sys.exit(-1)                                                                                        
		                                                                                                        
		#print "Opts", opts                                                                                     
	except getopt.GetoptError, e:                                                                               
		print 'Error option parsing' + str(e)                                                                   
		sys.exit(2)                                                                                             
		                                                                                                        
	for opt, arg in opts:                                                                                       
		#print "opt", opt                                                                                       
		#print "arg", arg                                                                                       
		if opt == '-h':                                                                                         
			print 'Usage:\n' + __file__ + ' [-h] [-s <host name or IP>] [-p <port>] -k <key>'                   
			print """                                                                                           
Options:                                                                                                        
-s, --host <host name or IP>                                                                                    
	Specify host name or IP address of a host. Default value is 127.0.0.1                                       
-p, --port <port>                                                                                               
	Specify port number of agent running on the host. Default value is 10050                                    
-k, --key <key of metric>                                                                                       
	Specify key of item to retrieve value for                                                                   
-h, --help                                                                                                      
	Display help information                                                                                    
Example: ./socket_zabbix.py -s 10.50.0.1 -p 10050 -k agent.ping                                                 
Be sure that IP is in Server inside of /etc/zabbix/zabbix_agentd.conf                                           
			"""                                                                                                 
                                                                                                                
			sys.exit()                                                                                          
		elif opt in ("-s", "--host"):                                                                           
			HOST = arg                                                                                          
		elif opt in ("-p", "--port"):                                                                           
			PORT = arg                                                                                          
		elif opt in ("-k", "--key"):                                                                            
			KEY = arg                                                                                           
                                                                                                                
	return _do_request(KEY)                                                                                     
                                                                                                                
if __name__ == '__main__':                                                                                      
	main(sys.argv[1:])                                                                                          
                                                                                                                

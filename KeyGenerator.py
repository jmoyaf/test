#!/usr/bin/env python
# -*- encoding: utf-8 -*-

'''
Created on 21 de oct. de 2015

Developed by Juan Francisco Huete Verdejo

Email: juanfrancisco.huete@centum.es
Team Email: gvp.tools@tid.es

GVP Tools Team
Telefonica I+D - Delivery
'''

import base64, binascii
import os
try:  
    import cPickle as pickle  
except ImportError:  
    import pickle
import getpass

__version__ = '2.0'

class KeyGenerator:
    
    def CreateKey(self,pssw,key,KeyFileName):
        dec_pass = int(binascii.hexlify(pssw),16)
        dec_key = int(binascii.hexlify(key),16)
        token = dec_pass+dec_key
        hash_key = base64.b64encode(bin(token))
        FileKey= open(KeyFileName,'wb')
        pickle.dump(hash_key, FileKey, protocol=2)
        FileKey.close()
    
    def DictionaryKey(self,dicPass,key,KeyFileName):
        for user in dicPass.keys():
            pssw=dicPass[user]
            dec_pass = int(binascii.hexlify(pssw),16)
            dec_key = int(binascii.hexlify(key),16)
            token = dec_pass+dec_key
            hash_key = base64.b64encode(bin(token))
            dicPass[user]=hash_key
        FileKey= open(KeyFileName,'wb')
        pickle.dump(dicPass, FileKey, protocol=2)
        FileKey.close()
            
if __name__ == '__main__':
    if os.name == 'nt':
        os.system('cls')
    else:
        os.system('clear')
    print 'The password and key it not show when you write it:\n'+'-'*51+'-'
    user='a'
    dicPass={}
    print "If you only want to save the password press enter without user in the first iteration"
    while user!='':
        print "Press enter without any user to finish."
        user = raw_input('Enter the user: ')
        if user=='': break
        pssw = getpass.getpass('Enter the password that you want to encrypt: ')
        dicPass[user]=pssw.rstrip('\r')
    if len(dicPass.keys()) == 0:
        print 'Warning Only the password will be saved!!'
        pssw = getpass.getpass('Enter the password that you want to encrypt: ')
    key  = getpass.getpass('Enter the key to decrypt password: ')
    FileName = raw_input('Enter the file name where the key will be saved: ')
    key = key.rstrip('\r')
    kg = KeyGenerator()
    if len(dicPass.keys()) > 0:
        kg.DictionaryKey(dicPass, key, FileName)
    else:
        kg.CreateKey(pssw, key, FileName)

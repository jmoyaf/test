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

try:  
    import cPickle as pickle  
except ImportError:  
    import pickle
    
__version__ = '2.0'

class GetPassword:
    
    def GetPassword(self,key,KeyFilePath):
        FileKey = open(KeyFilePath,'rb')
        Data = pickle.load(FileKey)
        if type(Data) == dict:
            for user in Data.keys():
                hash_key = int(base64.b64decode(Data[user]),2)
                dec_key = int(binascii.hexlify(key),16)
                dec_pssw = str(hex(hash_key-dec_key)).rstrip("L").lstrip("0x")
                Data[user]=binascii.unhexlify(dec_pssw)
        else:
            hash_key = int(base64.b64decode(Data),2)
            dec_key = int(binascii.hexlify(key),16)
            dec_pssw = str(hex(hash_key-dec_key)).rstrip("L").lstrip("0x")
            Data=binascii.unhexlify(dec_pssw)
        return str(Data).strip()
    
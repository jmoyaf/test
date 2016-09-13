#!/usr/bin/python
import urllib
import re
import datetime
import calendar
import smtplib
from email.MIMEMultipart import MIMEMultipart
from email.MIMEText import MIMEText

#Get dates
def getToday():
  datetoday = datetime.datetime.today().strftime("%Y%m%d")
  return datetoday

def getYesterday():
  dateyesterday = (datetime.datetime.today() - datetime.timedelta(days = 1)).strftime("%Y%m%d")
  return dateyesterday

def getDayWeek():
#  dayweek = datetime.datetime.today().strftime("%w")
  dayweek = datetime.datetime.today().isoweekday()
  return int(dayweek)

def getDateWeek():
  dateweek = (datetime.datetime.today() - datetime.timedelta(days = 7)).strftime("%Y%m%d")
  return dateweek

def getMonth():
  month = int(datetime.datetime.today().strftime("%m"))
  year = int(datetime.datetime.today().strftime("%Y"))
  lastdaymonth = calendar.monthrange(year, month)
  return lastdaymonth[1]

def getDayMonth():
  daymonth = datetime.datetime.today().strftime("%d")
  return int(daymonth)

def getDateMonth(x):
  datemonth = (datetime.datetime.today() - datetime.timedelta(days = x)).strftime("%Y%m%d")
  return datemonth

# Get raw data
def rawData():
  url = urllib.urlopen("http://root:aaaaaa@192.168.100.219/printer/infotosave.htm")
  raw = url.read()
  url.close()
  return raw

# Get pattern and format results
def getColor(x):
  color = re.findall('Color:\d+', x)
  colornum = re.sub(r'Color:','',color[0])
  return colornum

def getMono(x):
  mono = re.findall('Mono:\d+', x)
  mononum = re.sub(r'Mono:','',mono[0])
  return mononum

#Open files and write data
def writeData(x,y,z):
  colorfile = open('/home/jesus/Scripts/Python/empos/colorfile' + x + '.219', 'w')
  monofile = open('/home/jesus/Scripts/Python/empos/monofile' + x + '.219', 'w')
  colorfile.write(y)
  monofile.write(z)
  colorfile.close()
  monofile.close()
 
#Get copies
def getCopies(x,y):
  firstfilecolor = open('/home/jesus/Scripts/Python/empos/colorfile' + y + '.219', 'r')
  firstfilemono = open('/home/jesus/Scripts/Python/empos/monofile' + y + '.219', 'r')
  todayfilecolor = open('/home/jesus/Scripts/Python/empos/colorfile' + x + '.219', 'r')
  todayfilemono = open('/home/jesus/Scripts/Python/empos/monofile' + x + '.219', 'r')
  firstnumcolor = firstfilecolor.read()
  firstnummono = firstfilemono.read()
  todaynumcolor = todayfilecolor.read()
  todaynummono = todayfilemono.read()
  resultcolor = (int(todaynumcolor) - int(firstnumcolor))
  resultmono = (int(todaynummono) - int(firstnummono))
  firstfilecolor.close()
  firstfilemono.close()
  todayfilecolor.close()
  todayfilemono.close()
  return resultcolor,resultmono,todaynumcolor,todaynummono

#Send mail
def sendMail(x,y,z):
  msg = MIMEMultipart()
  msg['From'] = 'impresora_empos2@seres.es'
  msg['To'] = 'us-sistemas2@seres.es'
  msg['Cc'] = 'us-sistemas2@seres.es'
  msg['Subject'] = z + 'copias empos2 ' + y
  message = 'Copias Color totales: ' + str(x[2]) + '\nCopias Mono totales: ' + str(x[3]) + '\n\nCopias Color: ' + str(x[0]) + '\nCopias Mono: ' + str(x[1])
  msg.attach(MIMEText(message))
  mailserver = smtplib.SMTP('62.37.231.71',25)
  mailserver.ehlo()
  mailserver.sendmail('impresora_empos2@seres.es',('us-sistemas2@seres.es','us-sistemas2@seres.es'),msg.as_string())
  mailserver.quit()

datetoday = getToday()
dateyesterday = getYesterday()
dayweek = getDayWeek()
lastdaymonth = getMonth()
daymonth = getDayMonth()
datemonth = getDateMonth(daymonth)
dateweek = getDateWeek()
raw = rawData()
colornum = getColor(raw)
mononum = getMono(raw)

#Reports
writeData(datetoday,colornum,mononum)
copieslist = getCopies(datetoday,dateyesterday)
subjectmail = "Reporte diario "
sendMail(copieslist,datetoday,subjectmail)

if dayweek == 7:
  writeData(datetoday,colornum,mononum)
  copieslist = getCopies(datetoday,dateweek)
  subjectmail = "Reporte semanal "
  sendMail(copieslist,datetoday,subjectmail)
  
if lastdaymonth == daymonth:
  writeData(datetoday,colornum,mononum)
  copieslist = getCopies(datetoday,datemonth)
  subjectmail = "Reporte mensual "
  sendMail(copieslist,datetoday,subjectmail)
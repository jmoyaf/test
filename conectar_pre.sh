#!/bin/bash
clear
PS3='Elige una opcion: '
options=("CloudServer" "OpenCloud" "LoadBalancer" "DataBase" "Salir")
cloudserver=("pre-br-cs-fe01" "pre-br-cs-fe02" "pre-br-cs-be01" "pre-br-cs-be02" "pre-mx-cs-fe01" "pre-mx-cs-fe02" "pre-mx-cs-be01" "pre-mx-cs-be02" "Atras")
opencloud=("pre-br-oc-fe01" "pre-br-oc-fe02" "pre-br-oc-be01" "pre-br-oc-be02" "pre-mx-oc-fe01" "pre-mx-oc-fe02" "pre-mx-oc-be01" "pre-mx-oc-be02" "Atras")
loadbalancer=("PortalNginx07" "PortalNginx08" "Atras")
database=("pre-cs-db-01" "pre-cs-db-02" "Atras")

select opt in "${options[@]}"
do
  case $opt in
  "CloudServer")
    select opt2 in "${cloudserver[@]}"
    do
      case $opt2 in
      "pre-br-cs-fe01")
      ssh csadmin@pre-br-cs-fe01
      ;;
      "pre-br-cs-fe02")
      ssh csadmin@pre-br-cs-fe02
      ;;
	  "pre-br-cs-be01")
      ssh csadmin@pre-br-cs-be01
      ;;
	  "pre-br-cs-be02")
      ssh csadmin@pre-br-cs-be02
      ;;
	  "pre-mx-cs-fe01")
      ssh csadmin@pre-mx-cs-fe01
      ;;
      "pre-mx-cs-fe02")
      ssh csadmin@pre-mx-cs-fe02
      ;;
	  "pre-mx-cs-be01")
      ssh csadmin@pre-mx-cs-be01
      ;;
	  "pre-mx-cs-be02")
      ssh csadmin@pre-mx-cs-be02
      ;;
      "Atras")
      break
      ;;
      esac
    done
  ;;             
  "OpenCloud")
    select opt3 in "${opencloud[@]}"
    do
      case $opt3 in
      "pre-br-oc-fe01")
      ssh ocadmin@pre-br-oc-fe01
      ;;
      "pre-br-oc-fe02")
      ssh ocadmin@pre-br-oc-fe02
      ;;
	  "pre-br-oc-be01")
      ssh ocadmin@pre-br-oc-be01
      ;;
	  "pre-br-oc-be02")
      ssh ocadmin@pre-br-oc-be02
      ;;
	  "pre-mx-oc-fe01")
      ssh ocadmin@pre-mx-oc-fe01
      ;;
      "pre-mx-oc-fe02")
      ssh ocadmin@pre-mx-oc-fe02
      ;;
	  "pre-mx-oc-be01")
      ssh ocadmin@pre-mx-oc-be01
      ;;
	  "pre-mx-oc-be02")
      ssh ocadmin@pre-mx-oc-be02
      ;;
      "Atras")
      break
      ;;
      esac
    done
  ;;
  "LoadBalancer")
  select opt4 in "${loadbalancer[@]}"
    do
      case $opt4 in
      "PortalNginx07")
      ssh onframework@PortalNginx07
      ;;
	  "PortalNginx08")
      ssh onframework@PortalNginx08
      ;;
      "Atras")
      break
      ;;
      esac
    done
  ;;
  "DataBase")
  select opt5 in "${database[@]}"
    do
      case $opt5 in
      "pre-cs-db-01")
      ssh csadmin@pre-cs-db-01
      ;;
	  "pre-cs-db-02")
      ssh csadmin@pre-cs-db-02
      ;;
      "Atras")
      break
      ;;
      esac
    done
  ;;
  "Salir")
  exit
  ;;
  *) echo Opcion invalida
  ;;
  esac
done
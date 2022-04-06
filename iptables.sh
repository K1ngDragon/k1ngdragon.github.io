#!/bin/bash

#Limpiamos tablas
iptables -F
iptables -X
# Limpiamos NAT
iptables -t nat -F
iptables -t nat -X
# tabla mangle para cosas como PPPoE, PPP, and ATM
iptables -t mangle -F
iptables -t mangle -X
# Politicas Pienso que este es la mejor forma para principiantes y
# aun así no esta mal, te explico output(salida) todo porque son conexiones
# salientes, input descartamos todo, y ningun servidor debería hacer forward.
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -P FORWARD DROP

#Intranet LAN
intranet=eth0

#Extranet wan
extranet=eth1

# Keep state. Todo lo que ya esta conectado (establecido) lo dejamos asi
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Loop device.
iptables -A INPUT -i lo -j ACCEPT

# http, https, no especificamos la interfaz por que
# queremos que sea por todas
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# ssh solo internamente y desde este rango de ip's
iptables -A INPUT -p tcp -s 10.10.x.x/24 -i $intranet --dport 7659 -j ACCEPT

# monitoreo por ejemplo si tienen zabbix o algun otro servicio snmp
iptables -A INPUT -p tcp -s 10.10.x.x/24 -i $intranet --dport 10050 -j ACCEPT

# icmp, ping bueno es decisión tuya
iptables -A INPUT -p icmp -s 10.10.x.x/24 -i $intranet -j ACCEPT

#mysql con postgres es el puerto 5432
iptables -A INPUT -p tcp -s 10.10.x.x --sport 3306 -i $intranet -j ACCEPT

#sendmail bueeeh si quieres enviar algún correo
#iptables -A OUTPUT -p tcp --dport 25 -j ACCEPT

#Anti-SPOOFING 09/07/2014
#
#SERVER_IP="190.x.x.x" # server IP - la ip wan real de tu servidor
#LAN_RANGE="192.168.x.x/21" # Rango LAN de tu red o de tu vlan

# Ip's que no deberian entrar por la extranet nunca, es usar un poco de
# lógica si tenemos una interfaz netamente WAN no debería jamas entrar
# trafico tipo LAN por esa interfaz
SPOOF_IPS="0.0.0.0/8 127.0.0.0/8 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16"

# Acción por defecto - que se realizara cuando haga match alguna regla
ACTION="DROP"

# Paquetes con la misma ip de mi servidor por la wan
iptables -A INPUT -i $extranet -s $SERVER_IP -j $ACTION
#iptables -A OUTPUT -o $extranet -s $SERVER_IP -j $ACTION

# Paquetes con el Rango LAN por la wan, lo coloco así por si tienes
# alguna red particular, pero esto es redundante con la siguiente
# regla dentro del bucle "for"
iptables -A INPUT -i $extranet -s $LAN_RANGE -j $ACTION
iptables -A OUTPUT -o $extranet -s $LAN_RANGE -j $ACTION

## Todas las Redes SPOOF no permitidas por la wan
for ip in $SPOOF_IPS
do
iptables -A INPUT -i $extranet -s $ip -j $ACTION
iptables -A OUTPUT -o $extranet -s $ip -j $ACTION
done

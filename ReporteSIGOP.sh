#!/bin/sh
#
#  Script %name:        ReporteSIGOP.sh%
#  %version:            1 %
#  Description:
# =========================================================================================================
#  %created_by:         Diego Villegas (TCS) %
#  %date_created:       Tue Jul 28 16:20:18 ECT 2015 %
# =========================================================================================================
# change log
# =========================================================================================================
# Mod.ID         Who                            When                                    Description
# =========================================================================================================
# =========================================================================================================

#Definicion de variables.

HOSTNAME=`uname -n`
OStype=`uname -s`
MAILADD=''
HEAD='Equipo;SistemaOperativo;Particiones;FabricanteSO;ArquitecturaSO;Procesador;NumProcesador;Marca;FabricanteSistema;Modelo;Velocidad;SerialNumber;Ram;IP;Mask;MACC;GW'
Partition=""
echo $HEAD>$HOSTNAME.csv

## OS selection
if [ $OStype = "Linux" ];
then
	Partition=`cat /etc/fstab |grep "/dev" |awk '{print $1}' |grep -v "#"`
	count=0
	for e in `echo $Partition`;
	do
		Sizes=`fdisk -l $e |grep Disco | grep -v "Disk identifier" |awk '{print $2," ",$3," ",$4}'|tr -d ' '|tr -d ','`
		lista[$count]=$Sizes
		count=`expr $count + 1`
	done
	#echo ${lista[@]}
	FabricanteSO="Red Hat"
	ArquitecturaSO=`uname -i`
	Procesador=`cat /proc/cpuinfo | grep "model name" |tail -1 | awk -F: '{print $2}'`
	NumProcesador=`cat /proc/cpuinfo | grep "model name" |wc -l`
	Marca=`dmidecode -s system-manufacturer`
	FabricanteSistema=`dmidecode -s system-manufacturer`
	Modelo=`dmidecode -s system-product-name`
	Velocidad=`dmidecode -s processor-frequency | tail -1`
	SerialNumber=`dmidecode -s system-serial-number |tr -d ' '`
	Ram=`cat /proc/meminfo |grep MemTotal|awk -F: '{print $2}'|tr -d ' '`
	Intfc=`route |grep default |awk '{print $8}'`
	IP=`ifconfig $Intfc |grep "inet addr" | awk -F: '{print $2}' | tr -d '  Bcast'`
	Mask=`ifconfig eth0 |grep "inet addr" | awk -F: '{print $4}'`
	MACC=`ifconfig eth0 |grep HWaddr |awk '{print $5}'`
	GW=`route |grep default |awk '{print $2}'`
	echo "$HOSTNAME;$OStype;${lista[@]};$FabricanteSO;$ArquitecturaSO;$Procesador;$NumProcesador;$Marca;$FabricanteSistema;$Modelo;$Velocidad;$SerialNumber;$Ram;$IP;$Mask;$MACC;$GW">>$HOSTNAME.csv
	
elif [ $OStype = "SunOS" ];
	then
	Partition=`cat /etc/mnttab |awk '{print $1}' |grep "/" |grep -v "platform"`
	count=0
	for e in `echo $Partition`;
	do
		Sizes=`df -h $e | grep -v Filesystem |awk '{print $1,":",$2}'`
		lista[$count]=$Sizes
		count=`expr $count + 1`
	done
	#echo ${lista[@]}
	FabricanteSO="Oracle Corporation"
	ArquitecturaSO=`showrev |grep "Application architecture" |awk -F: '{print $2}'|tr -d ' '`
	Procesador=`psrinfo -pv |grep chip |tail -1 |awk '{print $1}' |tr -d ' '`
	NumProcesador=`psrinfo -p`
	Marca=`SUN`
	FabricanteSistema=`showrev |grep "Hardware provider" |awk -F: '{print $2}'|tr -d ' '`
	Modelo=`uname -a | awk -F, '{print $2}'`
	Velocidad=`psrinfo -pv |grep chip |tail -1 |awk '{print $5,$6}' | tr -d '}'`
	SerialNumber=``
	Ram=`prtconf | grep Memory | awk -F: '{print $2}'`
	
	IP=""
	Mask=""
	MACC=""
	GW=""
	echo "$HOSTNAME;$OStype;${lista[@]};$FabricanteSO;$ArquitecturaSO;$Procesador;$NumProcesador;$Marca;$FabricanteSistema;$Modelo;$Velocidad;$SerialNumber;$Ram;$IP;$Mask;$MACC;$GW">>$HOSTNAME.csv
              
elif [ $OStype = "AIX" ];
	then
	Partition=`df -gt | grep -v "Filesystem" |grep -v "/proc" | awk '{print $1,":",$2,"GB"}' |tr -d ' '|tr '\n' ' '`	
	prtconf>salidaPrtconf.txt
	FabricanteSO="IBM"
	ArquitecturaSO=`cat salidaPrtconf.txt |grep "CPU Type" |awk -F: '{print $2}' |tr -d ' '`
	Procesador=`cat salidaPrtconf.txt |grep "Processor Type" |awk -F: '{print $2}' |tr -d ' '`
	NumProcesador=`lscfg | grep proc |wc -l |tr -d ' '`
	Marca=`uname -s`
	FabricanteSistema="IBM"
	Modelo=`cat salidaPrtconf.txt |grep "System Model" |awk -F: '{print $2}' |tr -d ' '`
	Velocidad=`cat salidaPrtconf.txt |grep "Processor Clock Speed:" |awk -F: '{print $2}' |tr -d ' '`
	SerialNumber=`cat salidaPrtconf.txt |grep "Machine Serial Number:" |awk -F: '{print $2}' |tr -d ' '`
	Ram=`cat salidaPrtconf.txt |grep "Memory Size" | grep -v "Good"|awk -F: '{print $2}' |tr -d ' '`
	IP=`cat salidaPrtconf.txt |grep "IP Address" |awk -F: '{print $2}' |tr -d ' '|tr '\n' ' '`
	Mask=`cat salidaPrtconf.txt |grep "Sub Netmask" |awk -F: '{print $2}' |tr -d ' '|tr '\n' ' '`
	MACC="N/A"
	GW=`cat salidaPrtconf.txt |grep "Gateway" |awk -F: '{print $2}' |tr -d ' '|tr '\n' ' '`
	echo "$HOSTNAME;$OStype;$Partition;$FabricanteSO;$ArquitecturaSO;$Procesador;$NumProcesador;$Marca;$FabricanteSistema;$Modelo;$Velocidad;$SerialNumber;$Ram;$IP;$Mask;$MACC;$GW">>$HOSTNAME.csv
	rm salidaPrtconf.txt
elif [ $OStype = "HP-UX" ];
	then
	Partition=`bdf -l |grep "/dev" |awk '{print $1}'`
	count=0
	for e in `echo $Partition`;
	do
		Sizes=`bdf $e |grep -v "Filesystem" |tr -d "$e" |awk '{print $1}' |tail -1`
		Filesystem="$e:$Sizes"
		lista[$count]=$Filesystem
		count=`expr $count + 1`
	done
	print_manifest>salidaPrtconf.txt
	FabricanteSO="HP"
	ArquitecturaSO=`cat salidaPrtconf.txt |grep "OS mode" |awk -F: '{print $2}' |tr -d ' '`
	Procesador=`uname -m`
	NumProcesador=`cat salidaPrtconf.txt |grep "Processors" |awk -F: '{print $2}' |tr -d ' '`
	Marca=`uname -s`
	FabricanteSistema="HP"
	Modelo=`cat salidaPrtconf.txt |grep "Model" |awk -F: '{print $2}'`
	Velocidad=`cat salidaPrtconf.txt |grep GHz |awk '{print $(NF - 3), $(NF - 2)}' |tr -d '(' |tr -d ','`
	SerialNumber=`getconf MACHINE_SERIAL`
	Ram=`cat salidaPrtconf.txt |grep "Main Memory" |awk -F: '{print $2}' |tr -d ' '`
	IP=`cat salidaPrtconf.txt |grep "IP address"|grep -v "gateway"|awk -F: '{print $2}'|tr -d ' '|tr '\n' ' '`
	Mask=`cat salidaPrtconf.txt |grep "subnet mask" |awk -F: '{print $2}' |tr -d ' '|tr '\n' ' '`
	MACC="N/A"
	GW=`cat salidaPrtconf.txt |grep "gateway IP address" |awk -F: '{print $2}' |tr -d ' '|tr '\n' ' '`
	echo "$HOSTNAME;$OStype;${lista[@]};$FabricanteSO;$ArquitecturaSO;$Procesador;$NumProcesador;$Marca;$FabricanteSistema;$Modelo;$Velocidad;$SerialNumber;$Ram;$IP;$Mask;$MACC;$GW">>$HOSTNAME.csv
	rm salidaPrtconf.txt
else echo "ERROR: OS not found. Stopping."
fi

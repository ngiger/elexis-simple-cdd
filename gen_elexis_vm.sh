#!/bin/bash
# Copyright 2011 Niklaus Giger <niklaus.giger@member.fsf.org>
# License: GPL 3.0
#
# configure here
start_mac_id="00:60:13:87:52"

# TODO: configure nrCpus, memory, hd for each VM here
nrCpus=2
memory=2048
hdSpace=20 # in GB
arch=amd64
isoName="debian-unstable-${arch}-CD-1.iso"
origin="http://somewhere/on/the/net/${isoName}"

# from here there is usually nothing to configure

declare -i elexisIdr
declare -i j
declare mac_id
elexisId=1
j=101
confDir='.'
newConf=${j}.conf
fName='xxx'
while [ -f /etc/qemu-server/${j}.conf ]
do
  confDir="/etc/qemu-server"
  # echo "Fand /etc/qemu-server/${j}.conf"
  j=$((${j}+1))
done

Tgt="/var/lib/vz/template/iso/"
if [ -d ${Tgt} ]
then
  echo "${Tgt} exists"
  cd  ${Tgt}
  wget ${origin}
else
  Tgt='.'
fi
cmd=''
fName="ss"

set_mac_id()
{
  mac_id="${start_mac_id}:`echo \"obase=16;16+${elexisId}\" | bc`"
}

ok_to_create_qemu_conf()
{
  elexisId=$1
  confId=$2
  fName=$3
  cmd="grep -i ${mac_id} ${confDir}/*.conf"
  found=`$cmd`
  if [ "$found" ]
  then
      echo "MAC ${mac_id} already specified!"
      $cmd
      return 1
  fi
  if test -f ${confDir}/`basename ${fName}`
  then
      echo "found conffile ${confDir} for ${fName}"
  else
      echo "No conf file found, will create ${fName}"
  fi
  return 0
}


set_mac_id $j
fName=${confDir}/${j}.conf


#-----------------------------------------------------------------------------------------------------
# create main server
#-----------------------------------------------------------------------------------------------------
if ( ok_to_create_qemu_conf ${elexisId} $j $fName )
then
  cmd="/usr/sbin/qm create $j -cdrom ${isoName} --name elexis-${elexisId}"
  cmd="$cmd  --vlan0 rtl8139=${mac_id} -smp 1 --bootdisk ide0 --ide0 ${hdSpace} --ostype l26 --onboot yes --format qcow2 --cache writeback"
  cmd="$cmd --smp $nrCpus --memory ${memory} "
  echo $cmd
  $cmd
  # description cannot be passed to the qm command (or I don't know how)
  echo "description: elexis-${elexisId} (main server, db, wiki) with puppet. MAC-id is ${mac_id}" >> ${fName}
else
  echo "Cannot generate ${fName} as MAC-ID already taken!"
fi

exit

#-----------------------------------------------------------------------------------------------------
# create x2go server
#-----------------------------------------------------------------------------------------------------
j=$((${j}+1))
elexisId=$((${elexisId}+1))
if ( ok_to_create_qemu_conf ${elexisId} $j $fName )
then
  cmd="/usr/sbin/qm create $j -cdrom ${isoName} --name elexis-${elexisId}"
  cmd="$cmd  --vlan0 rtl8139=${mac_id} -smp 1 --bootdisk ide0 --ide0 ${hdSpace} --ostype l26 --onboot yes --format qcow2 --cache writeback"
  cmd="$cmd --smp $nrCpus --memory ${memory} "
  echo $cmd
  $cmd
  # description cannot be passed to the qm command (or I don't know how)
  echo "description: elexis-${elexisId} (X2go-Server) with puppet. MAC-id is ${mac_id}"  >>  ${fName}
else
  echo "Skipping ${fName}"
fi

#-----------------------------------------------------------------------------------------------------
# create backup server, e.g. for tests
#-----------------------------------------------------------------------------------------------------
j=$((${j}+1))
elexisId=$((${elexisId}+1))
if ( ok_to_create_qemu_conf ${elexisId} $j $fName )
then
  cmd="/usr/sbin/qm create $j -cdrom ${isoName} --name elexis-${elexisId}"
  cmd="$cmd  --vlan0 rtl8139=${mac_id} -smp 1 --bootdisk ide0 --ide0 ${hdSpace} --ostype l26 --onboot yes --format qcow2 --cache writeback"
  cmd="$cmd --smp $nrCpus --memory ${memory} "
  echo $cmd
  $cmd
  # description cannot be passed to the qm command (or I don't know how)
  echo "description: elexis-${elexisId} (Backup-Sserver) with puppet. MAC-id is ${mac_id}"  >>  ${fName}
else
  echo "Skipping ${fName}"
fi



#!/bin/bash

#<<tels_inboundfilerun_start.sh>>

#-------------------------------------------------------------
# Date               Author                 Version
#-------------------------------------------------------------
# 12/06/2015        Callidus                1.0     
#
# Description : 
# On-Demand Integrator (ODI) component.
# Common file handler script for logging filehandler start summary to tels_InboundFileRun table.
# Invoked by all the Standard file handler script.
#
# Command line: tels_inboundfilerun_start.sh <Filehandler Name>
##############################################################################################

num_params=$#
filehandlername=$1
batchname=$2

filehandler=`echo $filehandlername | cut -d "/" -f6`

. /apps/Callidus/tels/integrator/tels_setenv_variables.sh

if [ $num_params != 2 ]; then
    echo "[CallScript] Error - Invalid Arguments passed to tels_inboundfilerun_start.sh"
    exit 1
fi

l_insfilehandlername="'""$filehandler""'"
l_insbatchname="'""$batchname""'"

OUTPUT=`sqlplus -s $lpdb_username/$lpdb_password <<! 
    set heading off feedback off verify off 
    set serveroutput on size 100000
    declare
    l_filehandlername varchar2(255);
    l_batchname varchar2(255);
    begin
    l_filehandlername := $l_insfilehandlername;
    l_batchname := $l_insbatchname;
    insert into TELS_CORE_INBOUND_FILE_RUN (filehandlername,batchname,starttime)
    values(l_filehandlername,l_batchname,sysdate);
    if sql%found then
    dbms_output.put_line('recordinserted');
    end if;
    commit;
    exception 
    when others then
    dbms_output.put_line(sqlerrm);
    end;
    /
!`

valcnt=`echo $OUTPUT | awk '{ print $1 }'`

if [ "${valcnt}" != "recordinserted" ]; then
   echo "[CallScript] Error - Error in TELS_CORE_INBOUND_FILE_RUN insert"
   echo $OUTPUT
   exit 1
else
   exit 0
fi
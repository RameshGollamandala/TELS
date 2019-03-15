#!/bin/bash

#<<tels_inboundfilerun_end.sh>>

#-------------------------------------------------------------
# Date               Author                 Version
#-------------------------------------------------------------
#12/06/2015         Callidus                1.0
#
# Description : 
# On-Demand Integrator (ODI) component.
# Common file handler script for logging end summary to tels_InboundFileRun table.
# Invoked by all the Standard file handler script.
#
# Command line: tels_inboundfilerun_end.sh <Filehandler Name> <Return Code>
##############################################################################################

num_params=$#

filehandlername=$1
batchname=$2
returncode=$3

. /apps/Callidus/tels/integrator/tels_setenv_variables.sh

if [ $num_params != 3 ]; then
   echo "Error - Invalid Arguments passed to inboundfilerun_end.sh, pass <Filehandler Name> <Batchname> <Returncode> as arguments"
   exit 1
fi

filehandler=`echo $filehandlername | cut -d "/" -f6`

l_insfilehandlername="'""$filehandler""'"
l_insbatchname="'""$batchname""'"
l_insreturncode="'""$returncode""'"

OUTPUT=`sqlplus -s $lpdb_username/$lpdb_password <<! 
    set heading off feedback off verify off 
    set serveroutput on size 100000
    declare
    l_filehandlername  varchar2(255) ;
    l_batchname        varchar2(255);
    l_retcode          number ;
    begin
    l_filehandlername := $l_insfilehandlername ;
    l_batchname       := $l_insbatchname;
    l_retcode         := $l_insreturncode ;
    update TELS_CORE_INBOUND_FILE_RUN
    set filehandlerreturncode=l_retcode, 
    endtime=sysdate 
    where inboundfilerunkey = (select max(inboundfilerunkey) 
    from   TELS_CORE_INBOUND_FILE_RUN 
    where  filehandlername = l_filehandlername and batchname = l_batchname) ;
    if sql%found then
    dbms_output.put_line('recordupdated');
    end if ;
    commit;
    exception 
    when others then
    dbms_output.put_line(sqlerrm);
    end;
    /
!`

valcnt=`echo $OUTPUT | awk '{ print $1 }'`

if [ "${valcnt}" != "recordupdated" ]; then
    echo "1 - Error in TELS_CORE_INBOUND_FILE_RUN update"
    echo $OUTPUT
    exit 1
else
    exit 0
fi
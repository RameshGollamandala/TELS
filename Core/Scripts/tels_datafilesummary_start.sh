#!/bin/bash

#<<tels_datafilesummary_start.sh>>

#-------------------------------------------------------------
# Date               Author                  Version
#-------------------------------------------------------------
# 12/06/2015        Callidus        		 1.0	
#
# Description : 
# On-Demand Integrator (ODI) component.
# Common file handler script Called at beginning of creation of any batch for any staging table for any file.
# Invoked by all the Standard file handler script.
#
# Command line: tels_datafilesummary_start.sh <Filehandler Name>, <filename>, <stagetablename>, <batchname>
##############################################################################################################################

filehandler=$1
filename=$2
stagetablename=$3
batchname=$4

. /apps/Callidus/tels/integrator/tels_setenv_variables.sh

cd $infasrcdir

l_insfilehandlername="'""$filehandler""'"
l_insfilename="'""$filename""'"
l_insstagetablename="'""$stagetablename""'"
l_insbatchname="'""$batchname""'"

output=`sqlplus -s $lpdb_username/$lpdb_password <<! 
set heading off feedback off verify off 
set serveroutput on size 100000
declare
l_filehandlername varchar2(255);
l_filename        varchar2(255);
l_stagetablename  varchar2(255);
l_batchname       varchar2(255);
begin
l_filehandlername :=$l_insfilehandlername;
l_filename        :=$l_insfilename;
l_stagetablename  :=$l_insstagetablename;
l_batchname       :=$l_insbatchname;
insert into TELS_CORE_DATA_FILE_SUMMARY (inboundfilerunkey, filename, filehandlername, stagetablename, batchname, processingstarttime ) 
values (
(select max(inboundfilerunkey) from TELS_CORE_INBOUND_FILE_RUN where filehandlername = l_filehandlername), 
l_filename,
l_filehandlername,
l_stagetablename, 
l_batchname, 
sysdate
);
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

valcnt=`echo $output | awk '{ print $1 }'`

if [ "${valcnt}" != "recordinserted" ]; then
   echo "[CallScript] ***ERROR*** 1 - Error in TELS_CORE_DATA_FILE_SUMMARY insert"
   echo "[CallScript] ***ERROR*** valcnt = [${valcnt}]"
   echo "[CallScript] ***ERROR*** output = [${output}]"
   exit 1
else
   exit 0
fi
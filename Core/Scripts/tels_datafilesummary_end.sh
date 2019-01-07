#!/bin/bash

#<<tels_datafilesummary_end.sh>>

#-------------------------------------------------------------
# Date               Author                  Version
#-------------------------------------------------------------
# 12/06/2015		Callidus		 1.0
#
# Description : 
# On-Demand Integrator (ODI) component.
# Common file handler script Called at end of all processing of a single batch.
# Invoked by all the Standard file handler script.
#
# Command line: tels_datafilesummary_end.sh <Filehandler Name>, <filename>, <stagetablename>, <batchname> <reccount>
######################################################################################################

filehandler=$1
filename=$2
stagetablename=$3
batchname=$4
retcode=$5
reccount=$6

. /apps/Callidus/tels/integrator/tels_setenv_variables.sh

l_insfilehandlername="'""$filehandler""'"
l_insfilename="'""$filename""'"
l_insstagetablename="'""$stagetablename""'"
l_insbatchname="'""$batchname""'"
l_insretcode="'""$retcode""'"
l_insreccount="'""$reccount""'"

OUTPUT=`sqlplus -s $lpdb_username/$lpdb_password <<! 
	set heading off feedback off verify off 
	set serveroutput on size 100000
	declare
	l_filehandlername varchar2(255) ;
	l_filename        varchar2(255) ;
	l_stagetablename  varchar2(255) ;
	l_batchname       varchar2(255) ;
	l_retcode			number(2) ;
	l_reccount         varchar2 (10);
	begin
	l_filehandlername :=$l_insfilehandlername;
	l_filename        :=$l_insfilename;
	l_stagetablename  :=$l_insstagetablename;
	l_batchname       :=$l_insbatchname;
	l_retcode         :=$l_insretcode;
	l_reccount        :=$l_insreccount;
	update TELS_CORE_DATA_FILE_SUMMARY
	set processingendtime = sysdate,
	returncode        = l_retcode,
	filerecordcount   = l_reccount,
	errorcount        = l_retcode,
	tcvalidationreturncode = l_retcode,
	tctransferreturncode =  l_retcode
	where inboundfilerunkey = (select max(inboundfilerunkey) 
	from TELS_CORE_INBOUND_FILE_RUN 
	where filehandlername = l_filehandlername and 
	filename        = l_filename and 
	stagetablename  = l_stagetablename and 
	batchname       = l_batchname) ;
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
	echo $valcnt
	echo "1 - Error in TELS_CORE_DATA_FILE_SUMMARY update"
	echo $OUTPUT
	exit 1
else
	exit 0
fi
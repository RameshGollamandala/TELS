#!/bin/bash

#<<tels_datasummary.sh>>

#---------------------------------------------------------------------------------------------------------------------------------------------------
# Date			Author                  Version		Comments
#---------------------------------------------------------------------------------------------------------------------------------------------------
# 12/06/204000		Callidus        	1.0	
# 29/08/2016		D. Harsojo			1.1 		Changed error count handling to add "sed" call to remove header row from the count
#
#
# Description : 
# Common file handler script Called at beginning of creation of any batch for any staging table for any file.
# Invoked by all the Standard file handler script.
#
# Command line: tels_datasummary_start.sh <filehandler>, <filename>, <tgtfilename1>, <tgtcount>, <errfilename>, <filesrc>
##############################################################################################################################

filehandler=$1
filename=$2
#filereccount=$3
filereccount=""
tgtfilename1=$3
tgtcount=$4
errfilename=$5
filesrc=$6
tgtfilenamecount1=0
errfilenamecount=0

. /apps/Callidus/tels/integrator/tels_setenv_variables.sh

cd /apps/Informatica/PowerCenter10.1.1/server/infa_shared/TgtFiles
chmod 777 /apps/Informatica/PowerCenter10.1.1/server/infa_shared/TgtFiles/$tgtfilename1
chmod 777 /apps/Informatica/PowerCenter10.1.1/server/infa_shared/TgtFiles/$errfilename

errfilenamecount=`sed 1d /apps/Informatica/PowerCenter10.1.1/server/infa_shared/TgtFiles/$errfilename | wc -lwc | awk '{print$1}' | tail -1 | head -1`

echo "[CallFunc-DataSummary] Parameters: <filehandler>$filehandler, <filename>$filename, <tgtfilename1>$tgtfilename1, <tgtcount>$tgtcount, <errfilename>$errfilename, <filesrc>$filesrc"
echo "[CallFunc-DataSummary] Number of records in $errfilename : $errfilenamecount"

l_insfilehandlername="'""$filehandler""'"
l_insfilename="'""$filename""'"
l_insfilereccount="'""$filereccount""'"
l_instgtfilename1="'""$tgtfilename1""'"
l_inserrfilename="'""$errfilename""'"
l_insfilesrc="'""$filesrc""'"
l_instgtfilecount1="'""$tgtcount""'"
l_inserrfilecount="'""$errfilenamecount""'"

OUTPUT=`sqlplus -s $lpdb_username/$lpdb_password <<! 
	set heading off feedback off verify off 
	set serveroutput on size 100000
	declare
	l_filehandlername varchar2(255) ;
	l_filename        varchar2(255) ;
	l_filereccount    varchar2(255) ;
	l_tgtfilename1    varchar2(4000) ;
	l_errfilename     varchar2(255) ;
	l_filesrc         varchar2(255) ;
	l_tgtfilecount1   varchar2(255) ;
	l_errfilecount    varchar2(255) ;
	begin
	l_filehandlername :=$l_insfilehandlername;
	l_filename        :=$l_insfilename;
	l_filereccount    :=$l_insfilereccount;
	l_tgtfilename1    :=$l_instgtfilename1;
	l_errfilename     :=$l_inserrfilename;
	l_filesrc         :=$l_insfilesrc;
	l_tgtfilecount1   :=$l_instgtfilecount1;
	l_errfilecount    :=$l_inserrfilecount;
	delete from TELS_CORE_DATA_SUMMARY where sourcefilename=l_filename;
	commit;
	insert into TELS_CORE_DATA_SUMMARY (businessunitname,filehandlername,sourcefilename,filerecordcount,targetfilename_1,targetrecordcount_1,targetfilename_2,targetrecordcount_2,errorfilename,errorcount,batchprocessdate ) 
	values (l_filesrc,l_filehandlername,l_filename,l_filereccount,l_tgtfilename1,l_tgtfilecount1,'','',l_errfilename,l_errfilecount,to_char(sysdate,'yyyy/mm/dd hh24:mi:ss')) ;
	if sql%found then
	dbms_output.put_line('recordinserted');
	end if ;
	commit;
	exception 
	when others then
	dbms_output.put_line(sqlerrm);
	end;
	/
!`

valcnt=`echo $OUTPUT | awk '{ print $1 }'`

if [ $valcnt != "recordinserted" ]; then
	echo "[CallScript-DataSummary]  1 - Error in TELS_CORE_DATA_SUMMARY insert"
	echo $OUTPUT
	exit 1
else
	exit 0
fi

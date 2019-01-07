#!/bin/bash

#<<tels_core_job_processor.sh>>

#-------------------------------------------------------------------------------
# Date        Author          Version  Comments
#-------------------------------------------------------------------------------
# 28/05/2018  Simon Marsh    v00
#
# Description:
#   Job processor script
#
# Invoked By: CRON
#   Name: 
#   Parameters: None
#
# Command Line: tels_core_job_processor.sh <Trigger File Name>
#
################################################################################

set -x

# Import Environment Variables
. /apps/Callidus/tels/integrator/tels_setenv_variables.sh
. /apps/Callidus/tels/integrator/tels_utility_functions.sh

#####################################################################
# PROGRAM BEGIN                                                     #
#####################################################################
echo "[CallScript-OutboundOEPayConfirm]"
echo "[CallScript-OutboundOEPayConfirm]  === [$timestamp]:: START:: tels_core_job_processor.sh ]===" 
echo "[CallScript-OutboundOEPayConfirm]"

################################################################################
#Exit the process, if the workflow not found for filetype;
if [ "$outboundwfname" = "" -o "$wftype" = "" ]; then
    echo "[WorkflowNotFound] Script not found for filetype=$filetype, exiting..."
    echo "wfret=1" > $tempdir/wfreturncode.txt
    exit 1
fi

################################################################################
# Get the next due item in the queue and parse the results
nextjob=`sqlplus -s $lpdb_username/$lpdb_password <<!
set heading off feedback off verify off
set serveroutput on size 100000
SET LINESIZE 32767
declare
  l_nextjob varchar2(4000);
begin
	SELECT * FROM(
	SELECT JOB_ID||'|'||JOB_NAME||'|'||JOB_TYPE||'|'||DUE_DATETIME||'|'||CALLSCRIPT||'|'||STATUS
	FROM TELS_CORE_JOB_QUEUE
	WHERE DUE_DATETIME < SYSTIMESTAMP AND STATUS = 'QUEUED' ORDER BY DUE_DATETIME
	) WHERE ROWNUM = 1;
  dbms_output.put_line(nextjob);
end;
/
!`	

nextjob=${nextjob//$'\n'/}  #Strip any newline chars

jobid=`cat $nextjob | cut -d "|" -f1`
jobname=`cat $nextjob | cut -d "|" -f2`
jobtype=`cat $nextjob | cut -d "|" -f3`
jobduetime=`cat $nextjob | cut -d "|" -f4`
jobcallscript==`cat $nextjob | cut -d "|" -f5`
jobstatus==`cat $nextjob | cut -d "|" -f6`

################################################################################
# TO DO
# 1. Update the job queue record we just found using JOB_ID and set the STATUS to 'STARTED'
# 2. Start the job by running the callscript with arguments
# 3. On execution completion, delete the job from the queue using job id
# 4. Insert a record into the job history table and note the status from the callscript return code
# 5. Exit
	
echo "[CallScript-OutboundOEPayConfirm]"
echo "[CallScript-OutboundOEPayConfirm]  === [$timestamp]::END:: tels_core_job_processor.sh ] ==="
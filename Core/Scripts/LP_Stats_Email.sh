#!/bin/bash

#<<LP_Stats_Email.sh>>

#-------------------------------------------------------------------------------
# Date        Author          Version  Comments
#-------------------------------------------------------------------------------
# 19/07/2018  Simon Marsh     v01
#
# Description:
#
#
#
################################################################################

set -x

# Import Environment Variables
. /apps/Callidus/tels/integrator/tels_setenv_variables.sh
. /apps/Callidus/tels/integrator/tels_utility_functions.sh

# variables
#EMAIL_LIST="simarsh@calliduscloud.com, amills@calliduscloud.com";
EMAIL_LIST="simarsh@calliduscloud.com";
LOG_FILE="/apps/Callidus/tels/temp/_Simon/TELS_LP_Stats_Email.log";
SUBJECT=$tenantid_uc"-"$custinst_uc" LND System Statistics "$timestamp;
SENDMAIL="/usr/sbin/sendmail";

STYLESHEET="<style type='text/css'>
	body {font:10pt Arial,Helvetica,sans-serif; color:black; background:White;}
	p {font:10pt Arial,Helvetica,sans-serif; color:black; background:White;}
	table,tr,td {border:1px #1C6EA4 font:10pt Arial,Helvetica,sans-serif; color:Black; background:#eeeeee;}
	th {font:bold 10pt Arial,Helvetica,sans-serif; color:#ffffff; background:#9b9b9b; padding:0px 0px 0px 0px;}
	h1 {font:16pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White;}
	h2 {font:bold 10pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; margin-top:4pt; margin-bottom:0pt;}
	a {font:9pt Arial,Helvetica,sans-serif; color:#663300; background:#ffffff; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
</style>"

# create header
echo "To: ${EMAIL_LIST}" > ${LOG_FILE};
echo "Subject: ${SUBJECT}" >> ${LOG_FILE};
echo "Content-Type: text/html; charset="us-ascii"" >> ${LOG_FILE};
echo "" >> ${LOG_FILE};

# message Starts
echo "<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">" >> ${LOG_FILE};
echo "<html>" >> ${LOG_FILE};
echo "<head>" >> ${LOG_FILE};
echo $STYLESHEET >> ${LOG_FILE};
echo "<title></title>" >> ${LOG_FILE};
echo "</head>" >> ${LOG_FILE};
echo "<img src="https://$tenantid-$custinst.callidusondemand.com/CallidusPortal/brandingImage.do">" >> ${LOG_FILE};

################################################################################
# Inbound / Outbound Activity Report
################################################################################
echo "<h1>Inbound / Outbound Activity (Last 24 Hours):</h1>" >> ${LOG_FILE};

sqlplus -s $lpdb_username/$lpdb_password >> ${LOG_FILE} <<EOF
set feedback off
set markup html on
set pagesize 50000
COLUMN DIRECTION FORMAT a10

SELECT
  CASE WHEN column_value <> 1 THEN '' ELSE BATCHPROCESSDATE END BATCHPROCESSDATE,
  CASE WHEN column_value <> 1 THEN '' ELSE DIRECTION END DIRECTION,
  CASE WHEN column_value <> 1 THEN '' ELSE SOURCEFILE END SOURCEFILE,
  TARGETFILE
FROM(
SELECT ds.BATCHPROCESSDATE,
  CASE WHEN ds.FILEHANDLERNAME LIKE '%inbound%' THEN 'Inbound' WHEN ds.FILEHANDLERNAME LIKE '%outbound%' THEN 'Outbound' ELSE 'Unknown' END DIRECTION,
  ds.SOURCEFILENAME SOURCEFILE,
  levels.column_value,
  trim(regexp_substr(ds.TARGETFILENAME_1, '[^,]+', 1, levels.column_value)) TARGETFILE
FROM TELS_CORE_DATA_SUMMARY ds,
  table(cast(multiset(select level from dual connect by  level <= length (regexp_replace(ds.TARGETFILENAME_1, '[^,]+'))  + 1) as sys.OdciNumberList)) levels
WHERE TO_DATE(ds.BATCHPROCESSDATE,'YYYY/MM/DD HH24:MI:SS') > SYSDATE - 1
  AND ds.BATCHPROCESSDATE LIKE '2019%'
ORDER BY ds.BATCHPROCESSDATE DESC
);
EOF

################################################################################
# Disk Space Report
################################################################################
echo "<h1>Disk Space Report:</h1>" >> ${LOG_FILE};
echo "<table border = 1 cellpadding = 1 width='90%' align='center'>" >> ${LOG_FILE};
echo "<tr>" >> ${LOG_FILE};
echo "<td><span style=font-size:8.0pt;font-family:"Arial"><b>Filesystem</b></span></td>" >> ${LOG_FILE};
echo "<td><span style=font-size:8.0pt;font-family:"Arial"><b>Mount</b></span></td>" >> ${LOG_FILE};
echo "<td><span style=font-size:8.0pt;font-family:"Arial"><b>Size</b></span></td>" >> ${LOG_FILE};
echo "<td><span style=font-size:8.0pt;font-family:"Arial"><b>Used</b></span></td>" >> ${LOG_FILE};
echo "<td><span style=font-size:8.0pt;font-family:"Arial"><b>Available</b></span></td>" >> ${LOG_FILE};
echo "<td><span style=font-size:8.0pt;font-family:"Arial"><b>Used %</b></span></td>" >> ${LOG_FILE};
echo "</tr>" >> ${LOG_FILE};

echo `df -h | tail -n +2 | grep -v ^none | ( read header ; echo "$header" ; sort -rn -k 5) | awk '{print "<tr><td>" $1 "</td><td>" $6 "</td><td>" $2 "</td><td>" $3 "</td><td>" $4 "</td><td>" $5 "</td></tr>"}'` >> ${LOG_FILE};

echo "</table>" >> ${LOG_FILE};
echo "<br>" >> ${LOG_FILE};

################################################################################
# Tablespace Size Report
################################################################################
echo "<h1>Tablespace Size Report:</h1>" >> ${LOG_FILE};

sqlplus -s $lpdb_username/$lpdb_password >> ${LOG_FILE} <<EOF
set markup html on
set feedback off
set pagesize 50000

SELECT RANK() OVER (PARTITION BY 1 ORDER BY d.USED DESC) RANK, d.tablespace_name, d.USED_MB, d.FREE_MB, d.USED||'%' USED
FROM(
select  b.tablespace_name, tbs_size USED_MB, a.free_space FREE_MB, TO_CHAR(((tbs_size-a.free_space)/tbs_size)*100,'99.99') USED
from  (select tablespace_name, round(sum(bytes)/1024/1024 ,2) as free_space
       from dba_free_space
       group by tablespace_name) a,
      (select tablespace_name, sum(bytes)/1024/1024 as tbs_size
       from dba_data_files
       group by tablespace_name) b
where a.tablespace_name(+)=b.tablespace_name
ORDER BY TO_CHAR(((tbs_size-a.free_space)/tbs_size)*100,'99.99') DESC
) d;
EOF

################################################################################
# Table Size Report
################################################################################
echo "<h1>Table Size Report:</h1>" >> ${LOG_FILE};

sqlplus -s $lpdb_username/$lpdb_password >> ${LOG_FILE} <<EOF
set markup html on
set feedback off
set pagesize 50000

COLUMN PCT_OF_TABLESPACE FORMAT a20
SELECT RANK, TABLESPACE_NAME, SEGMENT_NAME OBJECT_NAME, SEGMENT_TYPE OBJECT_TYPE, SIZE_MB,
  TO_CHAR((SIZE_MB / sum(SIZE_MB) OVER(PARTITION BY TABLESPACE_NAME))*100,'99.99')||'%' PCT_OF_TABLESPACE
FROM(
    SELECT
      s.TABLESPACE_NAME, s.SEGMENT_NAME, s.SEGMENT_TYPE, (s.BYTES/1048576) SIZE_MB, RANK() OVER (PARTITION BY TABLESPACE_NAME ORDER BY s.BYTES DESC) RANK
    FROM DBA_SEGMENTS s
    WHERE s.OWNER = 'TELSADMIN' AND s.TABLESPACE_NAME <> 'USERS' AND (s.BYTES/1048576) > 1
)WHERE RANK <=10
ORDER BY TABLESPACE_NAME, SIZE_MB DESC;
EOF

# finish message
echo "</body>" >> ${LOG_FILE};
echo "</html>" >> ${LOG_FILE};

# mail the logfile results
${SENDMAIL} ${EMAIL_LIST} < ${LOG_FILE};

#rm $LOG_FILE;

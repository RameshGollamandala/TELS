set heading on
set verify on
set term on
set serveroutput on size 100000
set wrap on
set linesize 200
set pagesize 1000


/*************************  START REPORT  **********************************/
/* Run dynamic spool output name */
spool /tmp/latest_healthreport.txt


set feedback off
set heading on


select 'Report Date: '||to_char(sysdate,'Monthdd, yyyy hh:mi')
from dual;

set heading on
prompt =============================================================
prompt .                      DATABASE (V$DATABASE) (V$VERSION)
prompt =============================================================
select NAME "Database Name",
 CREATED "Created",
 LOG_MODE "Status"
  from sys.v_$database;
select banner "Current Versions"
  from sys.v_$version;

  set heading on
prompt ============================================================
prompt .                      UPTIME (V$DATABASE) (V$INSTANCE)
prompt =============================================================

SELECT NAME, ' Database Started on ',TO_CHAR(STARTUP_TIME,'DD-MON-YYYY "at" HH24:MI')
FROM V$INSTANCE, v$database;

set heading on
prompt .
prompt =============================================================
prompt .          TABLESPACE USAGE (DBA_DATA_FILES, DBA_FREE_SPACE)
prompt =============================================================
column Tablespace format a30
column Size  format 999999,99999,99999,99999
column Used  format 99999,99999,9,9999
column Free  format 99999,99999,99999,99999
column "% Used"  format 99999.9999
select tablespace_name  "Tablesapce",
        bytes   "Size",
        nvl(bytes-free,bytes) "Used",
        nvl(free,0)  "Free",
        nvl(100*(bytes-free)/bytes,100) "% Used"
  from(
 select ddf.tablespace_name, sum(dfs.bytes) free, ddf.bytes bytes
 FROM (select tablespace_name, sum(bytes) bytes
 from dba_data_files group by tablespace_name) ddf, dba_free_space dfs
 where ddf.tablespace_name = dfs.tablespace_name(+)
 group by ddf.tablespace_name, ddf.bytes)
  order by 5 desc;
  
set feedback off
set heading on
select rpad('Total',30,'.')  "Tablespace",
   sum(bytes)   "Size",
        sum(nvl(bytes-free,bytes)) "Used",
        sum(nvl(free,0))  "Free",
        (100*(sum(bytes)-sum(free))/sum(bytes)) "% Used"
  from(
 select ddf.tablespace_name, sum(dfs.bytes) free, ddf.bytes bytes
 FROM (select tablespace_name, sum(bytes) bytes
 from dba_data_files group by tablespace_name) ddf, dba_free_space dfs
 where ddf.tablespace_name = dfs.tablespace_name(+)
 group by ddf.tablespace_name, ddf.bytes);


 
prompt**====================================================================================================**
prompt**    **Database Parameters Details**         
prompt**====================================================================================================**


set pagesize 50;
set line 200;
column "SGA Pool"format a33;
col "m_bytes" format 999999.9999999;
select pool "SGA Pool", m_bytes from ( select  pool, to_char( trunc(sum(bytes)/1024/1024,2), '99999.99' ) as M_bytes
    from v$sgastat
    where pool is not null   group  by pool
    union
    select name as pool, to_char( trunc(bytes/1024/1024,3), '99999.99' ) as M_bytes
    from v$sgastat
    where pool is null  order     by 2 desc
    ) UNION ALL
    select    'TOTAL' as pool, to_char( trunc(sum(bytes)/1024/1024,3), '99999.99' ) from v$sgastat;
set heading on
column sttime format A30


prompt .
prompt ============================================================
prompt .      SUMMARY OF INVALID OBJECTS (DBA_OBJECTS)
prompt ============================================================

set pagesize 50;
Select owner "USERNAME", object_type, count(*) INVALID from dba_objects 
where status='INVALID' group by  owner, object_type;

prompt
SELECT dt.owner, dt.table_name "Table Change > 10%",
       ROUND ( (DELETES + UPDATES + INSERTS) / num_rows * 100) PERCENTAGE
FROM   dba_tables dt, all_tab_modifications atm
WHERE  dt.owner = atm.table_owner
       AND dt.table_name = atm.table_name
       AND num_rows > 0
       AND ROUND ( (DELETES + UPDATES + INSERTS) / num_rows * 100) >= 10
	   AND dt.owner not in ('SYS','SYSTEM') ORDER BY 3 desc;
	   

prompt
prompt List of Invalid objects of database:
prompt -----------------------------------------------------------------------**

set feedback off
set heading on
set pages 10000 lines 1000
select owner, object_type, substr(object_name,1,30) object_name, status
from dba_objects
where status='INVALID'
order by object_type;	   

	   
prompt
prompt Object Modified in last 7 days:
prompt -----------------------------------------------------------------------**

set line 200;
col owner format a15;
col object_name format a25;
col object_type format a15;
col last_modified format a20;
col created format a20;
col status format a10;
select owner, object_name, object_type, to_char(LAST_DDL_TIME,'MM/DD/YYYY HH24:MI:SS') last_modified,
    to_char(CREATED,'MM/DD/YYYY HH24:MI:SS') created, status
from  dba_objects
where (SYSDATE - LAST_DDL_TIME) < 7 and owner IN( 'HRMS', 'ORAFIN', 'HRTRAIN')
order by last_ddl_time DESC;

prompt
set pagesize 0;
SELECT 'Object Created in this Week: '|| count(1) from user_objects
where created >= sysdate -7;


prompt
prompt    DATABASE ACTIVE/INACTIVE SESSIONS:
prompt -----------------------------------------------------------------------**

prompt  ACTIVE
set pages 1000 lines 1000
select inst_id, USERNAME,OSUSER, MACHINE, MODULE,status, count(*) from gv$session
where status='ACTIVE' group by inst_id, USERNAME,OSUSER, MACHINE, MODULE,status order by count(*);

prompt  INACTIVE
select inst_id, USERNAME,OSUSER, MACHINE, MODULE,status, count(*) from gv$session
where status='INACTIVE' group by inst_id, USERNAME,OSUSER, MACHINE, MODULE,status order by count(*);
set heading on

prompt
prompt     TABLES AND INDEXES STATS DETAILS (STALE_STATS)
prompt -----------------------------------------------------------------------**

prompt  TABLES
set heading on
select owner,table_name,last_analyzed, global_stats from dba_tab_statistics
where owner not in ('SYS','SYSTEM')  AND STALE_STATS='YES'
order by owner,table_name;

prompt  INDEXES
select owner,table_name,last_analyzed, global_stats from dba_ind_statistics
where owner not in ('SYS','SYSTEM')  AND STALE_STATS='YES'
order by owner,table_name;

prompt
prompt     LOCKED DATABASE OBJECTS
prompt -----------------------------------------------------------------------**

set feedback off
set heading on
SELECT B.Owner, B.Object_Name, A.Oracle_Username, A.OS_User_Name  
FROM V$Locked_Object A, All_Objects B
WHERE A.Object_ID = B.Object_ID;



set feedback off
set heading on
prompt .
prompt ========================================================
prompt .       FREE SPACE FRAGMENTATION (DBA_FREE_SPACE)
prompt ========================================================
set feedback off
set heading on
set pages 1000 lines 1000
column Tablespace format a30
column "Available Size" format 99,999,999,999
column "Fragmentation" format 99,999
column "Average Size" format 9,999,999,999
column "   Max"  format 9,999,999,999
column "   Min"  format 9,999,999,999
column "blocks" format 99999,99999,99999
select owner,table_name,blocks,num_rows,avg_row_len,round(((blocks*8/1024)),2)||'MB' "TOTAL_SIZE",
round((num_rows*avg_row_len/1024/1024),2)||'Mb' "ACTUAL_SIZE",
round(((blocks*8/1024)-(num_rows*avg_row_len/1024/1024)),2) ||'MB' "FRAGMENTED_SPACE"
from all_tables  WHERE Owner='TCMP' and round(((blocks*8/1024)-(num_rows*avg_row_len/1024/1024)),2) > 2048;
 
 
prompt .
prompt ============================================================
prompt .     ERROR- These segments will fail during NEXT EXTENT (DBA_SEGMENTS)
prompt ============================================================
column Tablespaces format a30
column Segment  format a40
column "NEXT Needed" format 99999,99999,99999
column "MAX Available" format 99999,999,99999
select a.tablespace_name "Tablespaces",
 a.owner   "Owner",
 a.segment_name  "Segment",
 a.next_extent  "NEXT Needed",
 b.next_ext  "MAX Available"
  from sys.dba_segments a,
 (select tablespace_name,max(bytes) next_ext
 from sys.dba_free_space
 group by tablespace_name) b
 where a.tablespace_name=b.tablespace_name(+)
   and b.next_ext < a.next_extent;
set feedback off
set heading on

prompt =============================================================
prompt .        WARNING- These segments > 70% of MAX EXTENT (DBA_SEGMENTS)
prompt =============================================================
column Tablespace format a30
column Segment  format a40
column Used  format 99999999
column Max  format 9999999
select tablespace_name "Tablespace",
 owner  "Owner",
 segment_name "Segment",
 extents  "Used",
 max_extents "Max"
  from sys.dba_segments
 where (extents/decode(max_extents,0,1,max_extents))*100 > 70
   and max_extents >0;
set feedback off
set heading on

#prompt ============================================================
prompt .          LIST OF OBJECTS HAVING > 12 EXTENTS (DBA_EXTENTS)
prompt ============================================================
column Tablespace_ext format a30
column Segment  format a40
column Count  format 9999
break on "Tablespace_ext" skip 1
select tablespace_name "Tablespace_ext" ,
 owner  "Owner",
 segment_name    "Segment",
 count(*)        "Count"
  from sys.dba_extents
 group by tablespace_name,owner,segment_name
 having count(*)>12
 order by 1,3 desc;#
set feedback off
set heading on

prompt
prompt Monitor TOP CPU  Usage and Logical I/O Process:
prompt*-----------------------------------------------------------------------**
set pages 10000 lines 1000
set heading on
col resource_name heading "Resource|Name";
col current_utilization  heading "current|utiliz";
col max_utilization  heading "Max|utiliz";
col initial_allocation  heading "Initial|Alloc";
col limit_value  heading "Limit|Value";
set heading on
select resource_name, current_utilization, max_utilization, initial_allocation, limit_value
from v$resource_limit where resource_name in ('processes','sessions', 'transactions', 'max_rollback_segments');

col name format a30;
set heading on
select * from (select a.sid, c.username, c.osuser, c.machine,  logon_time, b.name,  a.value
from   v$sesstat  a, v$statname b,  v$session  c
where a.STATISTIC# = b.STATISTIC#
and   a.sid = c.sid
and   b.name like '%CPU used by this session%'
order by a.value desc)
where rownum < 5;
 

prompt
prompt *** Most I/O operation for particualr Query:
prompt*-----------------------------------------------------------------------**
set heading on
col sql_text format a60;
col reads_per_exe format 99999999 heading 'reads|per_exe';
col "exe" format 99999;
col "sorts" format 99999;
col buffer_gets heading 'buffer|gets';
col disk_reads heading  'disk|reads';
SELECT * FROM   (SELECT Substr(a.sql_text,1,50) sql_text, 
Trunc(a.disk_reads/Decode(a.executions,0,1,a.executions)) reads_per_exe, 
a.buffer_gets, a.disk_reads, a.executions "exe", a.sorts "sorts", a.address "address"
FROM   v$sqlarea a
ORDER BY 2 DESC)
WHERE  rownum <= 5;



prompt .
prompt ==============================================================
prompt .                      SGA SIZE (V$SGA) (V$SGASTAT)
prompt ==============================================================
set feedback off
set heading on
column Size format 999999,9999,99999,9999
select decode(name, 'Database Buffers',
  'Database Buffers (DB_BLOCK_SIZE*DB_BLOCK_BUFFERS)',
  'Redo Buffers',
  'Redo Buffers     (LOG_BUFFER)', name) "Memory",
  value  "Size"
 from sys.v_$sga
UNION ALL
 select '------------------------------------------------------' "Memory",
  to_number(null)  "Size"
   from dual
UNION ALL
 select 'Total Memory' "Memory",
  sum(value) "Size"
   from sys.v_$sga;


prompt .

declare
 h_char          varchar2(100);
 h_char2  varchar(50);
 h_num1          number(25);
 result1         varchar2(50);
 result2         varchar2(50);


 cursor c1 is
        select lpad(namespace,17)||': gets(pins)='||rpad(to_char(pins),9)||
                                     ' misses(reloads)='||rpad(reloads,9)||
               ' Ratio='||decode(reloads,0,0,to_char((reloads/pins)*100,999.999))||'%'
        from v$librarycache;


begin
    dbms_output.put_line('========================================');
    dbms_output.put_line('.  SHARED POOL: LIBRARY CACHE (V$LIBRARYCACHE)');
    dbms_output.put_line('========================================');
    dbms_output.put_line('.');
    dbms_output.put_line('.         Goal: The library cache ratio < 1%' );
    dbms_output.put_line('.');
  
    Begin
     SELECT 'Current setting: '||substr(value,1,30) INTO result1
     FROM V$PARAMETER 
     WHERE NUM = 23;
     SELECT 'Current setting: '||substr(value,1,30) INTO result2
     FROM V$PARAMETER 
     WHERE NUM = 325;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
      h_num1 :=1;
    END;
    dbms_output.put_line('Recommendation: Increase SHARED_POOL_SIZE '||rtrim(result1));
    dbms_output.put_line('.                        OPEN_CURSORS '    ||rtrim(result2));
    dbms_output.put_line('.               Also write identical sql statements.');
    dbms_output.put_line('.');
      
    open c1;
    loop
 fetch c1 into h_char;
 exit when c1%notfound;
 
 dbms_output.put_line('.'||h_char);
    end loop;
    close c1;


    dbms_output.put_line('.');


    select lpad('Total',17)||': gets(pins)='||rpad(to_char(sum(pins)),9)||
                                 ' misses(reloads)='||rpad(sum(reloads),9),
               ' Your library cache ratio is '||
                decode(sum(reloads),0,0,to_char((sum(reloads)/sum(pins))*100,999.999))||'%'
    into h_char,h_char2
    from v$librarycache;
    dbms_output.put_line('.'||h_char);
    dbms_output.put_line('.           ..............................................');
    dbms_output.put_line('.           '||h_char2);
    dbms_output.put_line('.');
end;
/



declare
        h_num1          number(25);
        h_num2          number(25);
        h_num3          number(25);
        result1         varchar2(50);


begin
    dbms_output.put_line  ('==========================================');
        dbms_output.put_line('.    SHARED POOL: DATA DICTIONARY (V$ROWCACHE)');
    dbms_output.put_line   ('==========================================');
        dbms_output.put_line('.');
        dbms_output.put_line('.         Goal: The row cache ratio should be < 10% or 15%' );
        dbms_output.put_line('.');
        dbms_output.put_line('.         Recommendation: Increase SHARED_POOL_SIZE '||result1);
        dbms_output.put_line('.');


        select sum(gets) "gets", sum(getmisses) "misses", round((sum(getmisses)/sum(gets))*100 ,3)
        into h_num1,h_num2,h_num3
        from v$rowcache;


        dbms_output.put_line('.');
        dbms_output.put_line('.             Gets sum: '||h_num1);
        dbms_output.put_line('.        Getmisses sum: '||h_num2);


        dbms_output.put_line('         .......................................');
        dbms_output.put_line('.        Your row cache ratio is '||h_num3||'%');


end;
/

declare
        h_char          varchar2(100);
        h_num1          number(25);
        h_num2          number(25);
        h_num3          number(25);
        h_num4          number(25);
        result1         varchar2(50);
begin
    dbms_output.put_line('.');
    dbms_output.put_line ('===============================================');
        dbms_output.put_line('.          BUFFER CACHE (V$SYSSTAT)');
    dbms_output.put_line ('===============================================');
        dbms_output.put_line('.');
        dbms_output.put_line('.         Goal: The buffer cache ratio should be > 70% ');
        dbms_output.put_line('.');
 Begin
      SELECT 'Current setting: '||substr(value,1,30) INTO result1
      FROM V$PARAMETER 
      WHERE NUM = 125;
     EXCEPTION
     WHEN NO_DATA_FOUND THEN
      result1 := 'Unknown parameter';
 END;
        dbms_output.put_line('.          Recommendation: Increase DB_BLOCK_BUFFERS '||result1);
        dbms_output.put_line('.');


        select lpad(name,15)  ,value
        into h_char,h_num1
        from v$sysstat
        where name ='db block gets';
        dbms_output.put_line('.         '||h_char||': '||h_num1);


        select lpad(name,15)  ,value
        into h_char,h_num2
        from v$sysstat
        where name ='consistent gets';
        dbms_output.put_line('.         '||h_char||': '||h_num2);


        select lpad(name,15)  ,value
        into h_char,h_num3
        from v$sysstat
        where name ='physical reads';
        dbms_output.put_line('.         '||h_char||': '||h_num3);


        h_num4:=round(((1-(h_num3/(h_num1+h_num2))))*100,3);


        dbms_output.put_line('.          .......................................');
        dbms_output.put_line('.          Your buffer cache ratio is '||h_num4||'%');


    dbms_output.put_line('.');
end;
/

declare
        h_char          varchar2(100);
        h_num1          number(25);
        h_num2          number(25);
        h_num3          number(25);


        cursor buff2 is
        SELECT name
                ,consistent_gets+db_block_gets, physical_reads
                ,DECODE(consistent_gets+db_block_gets,0,TO_NUMBER(null)
                ,to_char((1-physical_reads/(consistent_gets+db_block_gets))*100, 999.999))
        FROM v$buffer_pool_statistics;
begin
     dbms_output.put_line  ('==========================================');
        dbms_output.put_line('.  BUFFER CACHE (V$buffer_pool_statistics)');
    dbms_output.put_line   ('==========================================');


        dbms_output.put_line('.');
        dbms_output.put_line('.');
        dbms_output.put_line('Buffer Pool:         Logical_Reads     Physical_Reads        HIT_RATIO');
        dbms_output.put_line('.');


        open buff2;
        loop
            fetch buff2 into h_char, h_num1, h_num2, h_num3;
            exit when buff2%notfound;


     dbms_output.put_line(rpad(h_char, 15, '.')||'         '||lpad(h_num1, 10, ' ')||'         '||
      lpad(h_num2, 10, ' ')||'       '||lpad(h_num3, 10, ' '));


        end loop;
        close buff2;


    dbms_output.put_line('.');
end;
/

declare
        h_char          varchar2(100);
        h_num1          number(25);
        result1         varchar2(50);


        cursor c2 is
        select name,value
        from v$sysstat
        where name in ('sorts (memory)','sorts (disk)')
        order by 1 desc;


begin
  dbms_output.put_line  ('==============================================');
        dbms_output.put_line('.       SORT STATUS (V$SYSSTAT)');
 dbms_output.put_line  ('==============================================');
        dbms_output.put_line('.');
        dbms_output.put_line('.         Goal: Very low sort (disk)' );
        dbms_output.put_line('.');
        BEGIN
      SELECT 'Current setting: '||substr(value,1,30) INTO result1
      FROM V$PARAMETER 
      WHERE NUM = 320;
     EXCEPTION
      WHEN NO_DATA_FOUND THEN
       result1 := 'Unknown parameter';
     END;
        dbms_output.put_line('           Recommendation: Increase SORT_AREA_SIZE '||result1);
        dbms_output.put_line('.');
        dbms_output.put_line('.');
        dbms_output.put_line(rpad('Name',30)||'Count');
        dbms_output.put_line(rpad('-',25,'-')||'     -----------');


        open c2;
        loop
        fetch c2 into h_char,h_num1;
        exit when c2%notfound;
                dbms_output.put_line(rpad(h_char,30)||h_num1);
        end loop;
        close c2;
end;
/

prompt .
prompt ============================================================
prompt .       LAST REFRESH OF SNAPSHOTS (DBA_SNAPSHOTS)
prompt ============================================================


select owner, name, last_refresh
from dba_snapshots
where last_refresh < (SYSDATE - 1);


prompt .
prompt ============================================================
prompt .               LAST JOBS SCHEDULED (DBA_JOBS)
prompt ============================================================

set heading on
set arraysize 10
set linesize 65
col what format a65
col log_user format a10
col job format 9999
select job, log_user, last_date, last_sec, next_date, next_sec,
failures, what
from dba_jobs
where failures > 0;


set linesize 100


prompt .
prompt .
prompt Current Break Down of (SGA) Variable Size
prompt ------------------------------------------
set heading on
column Bytes  format 9999999,99999,999999
column "% Used"  format 999999.999999
column "Var. Size" format 999999,999999,9999999


select a.name   "Name",
 bytes   "Bytes",
 (bytes / b.value) * 100 "% Used",
 b.value   "Var. Size"
from sys.v_$sgastat a,
 sys.v_$sga b
where a.name in ('db_block_buffers','fixed_sga','log_buffer')
and b.name='Variable Size'
order by 3 desc;

prompt =============================================================
prompt End of Report


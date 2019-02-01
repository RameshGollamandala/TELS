--tablespace usage;
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


--Space usage by tablespace and table;
SELECT RANK, TABLESPACE_NAME, SEGMENT_NAME OBJECT_NAME, SEGMENT_TYPE OBJECT_TYPE, SIZE_MB, 
  TO_CHAR((SIZE_MB / sum(SIZE_MB) OVER(PARTITION BY TABLESPACE_NAME))*100,'99.99')||'%' PCT_TBLSPACE
FROM(
    SELECT 
      s.TABLESPACE_NAME, s.SEGMENT_NAME, s.SEGMENT_TYPE, (s.BYTES/1048576) SIZE_MB, RANK() OVER (PARTITION BY TABLESPACE_NAME ORDER BY s.BYTES DESC) RANK
    FROM DBA_SEGMENTS s 
    WHERE s.OWNER = 'TELSADMIN' AND s.TABLESPACE_NAME <> 'USERS' AND (s.BYTES/1048576) > 1
)WHERE RANK <=10 
ORDER BY TABLESPACE_NAME, SIZE_MB DESC;

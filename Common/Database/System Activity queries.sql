SELECT * FROM TELS_CORE_DATA_SUMMARY;

--Landing Pad processes in the last 24hours;
SELECT 
  CASE WHEN column_value <> 1 THEN '' ELSE BATCHPROCESSDATE END BATCHPROCESSDATE, 
  CASE WHEN column_value <> 1 THEN '' ELSE DIRECTION END DIRECTION, 
  CASE WHEN column_value <> 1 THEN '' ELSE SOURCEFILE END SOURCEFILE, 
  TARGETFILE
FROM(
SELECT ds.BATCHPROCESSDATE, 
  CASE WHEN ds.FILEHANDLERNAME LIKE '%inbound%' THEN 'Inbound' WHEN ds.FILEHANDLERNAME LIKE '%outbound%' THEN 'Outbound' END DIRECTION, 
  ds.SOURCEFILENAME SOURCEFILE, 
  levels.column_value,
  trim(regexp_substr(ds.TARGETFILENAME_1, '[^,]+', 1, levels.column_value)) TARGETFILE
--  TARGETRECORDCOUNT_1 TARGETRECORDCOUNT,  ERRORFILENAME, ERRORCOUNT 
FROM TELS_CORE_DATA_SUMMARY ds, 
  table(cast(multiset(select level from dual connect by  level <= length (regexp_replace(ds.TARGETFILENAME_1, '[^,]+'))  + 1) as sys.OdciNumberList)) levels
WHERE TO_DATE(ds.BATCHPROCESSDATE,'YYYY/MM/DD HH24:MI:SS') > SYSDATE - 1
  AND ds.BATCHPROCESSDATE LIKE '2019%'
ORDER BY ds.BATCHPROCESSDATE DESC
);

SELECT 
    stg.TABLENAME, tcds.sourcefilename, substr(stg.batchname,1,length(stg.batchname)-4) batchname, stg.STAGEPROCESSDATE,
    sum(case when stg.stageprocessflag = 0 then 1 else 0 end) as NOT_VALIDATED, 
    sum(case when stg.stageprocessflag = 1 then 1 else 0 end) as ERROR, 
    sum(case when stg.stageprocessflag = 2 then 1 else 0 end) as WARNING, 
    sum(case when stg.stageprocessflag = 3 then 1 else 0 end) as TRANSFERRED, 
    sum(case when stg.stageprocessflag = 4 then 1 else 0 end) as VALIDATED_NEW_RECORD, 
    sum(case when stg.stageprocessflag = 5 then 1 else 0 end) as VALIDATED_MATCH_RECORD 
FROM TELS_CORE_DATA_SUMMARY tcds
  JOIN 
    (SELECT 'CS_STAGESALESTRANSACTION' TABLENAME, batchname, stageprocessdate, stageprocessflag FROM cs_stagesalestransaction
    UNION ALL SELECT 'CS_STAGETRANSACTIONASSIGN' TABLENAME, batchname, stageprocessdate, stageprocessflag FROM CS_STAGETRANSACTIONASSIGN
    UNION ALL SELECT 'CS_STAGEPARTICIPANT' TABLENAME, batchname, stageprocessdate, stageprocessflag FROM CS_STAGEPARTICIPANT) stg ON 
    tcds.TARGETFILENAME_1 LIKE '%'||stg.BATCHNAME||'%'
--WHERE 
GROUP BY stg.TABLENAME, tcds.sourcefilename, substr(stg.batchname,1,length(stg.batchname)-4), stg.STAGEPROCESSDATE
ORDER BY stg.TABLENAME, tcds.sourcefilename, substr(stg.batchname,1,length(stg.batchname)-4), stg.STAGEPROCESSDATE;

SELECT * FROM TELS_CORE_DATA_SUMMARY;

SELECT * FROM CS_STAGEERROR;
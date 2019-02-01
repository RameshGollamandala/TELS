CREATE OR REPLACE PACKAGE TEST_STAGE_RCRM_PPE_PKG AS
  PROCEDURE TEST_STAGE_RCRM_PPE_LOAD(IN_TEST_NAME VARCHAR2, IN_PPE_FILE_NAME VARCHAR2, IN_RCRM_FILE_NAME VARCHAR2);
END TEST_STAGE_RCRM_PPE_PKG;
/

CREATE OR REPLACE PACKAGE BODY TEST_STAGE_RCRM_PPE_PKG AS

  PROCEDURE TEST_STAGE_RCRM_PPE_LOAD(IN_TEST_NAME VARCHAR2, IN_PPE_FILE_NAME VARCHAR2, IN_RCRM_FILE_NAME VARCHAR2)
  AS
    V_TEST_NAME VARCHAR2(255);
    V_PPE_FILE_NAME VARCHAR2(255);
    V_RCRM_FILE_NAME VARCHAR2(255);
    V_MAX_ROW_COUNT INTEGER;
    TYPE ARRAY IS TABLE OF TEST_STAGE_RCRM_PPE%ROWTYPE;
    A_DATA ARRAY;
    V_SQL_1 VARCHAR2(32767) := '';
    V_SQL_2 VARCHAR2(32767) := '';
    V_SQL_3 VARCHAR2(32767) := '';
    V_SQL_4 VARCHAR2(32767) := '';
    V_SQL_5 VARCHAR2(32767) := '';
    V_SQL VARCHAR2(32767) := '';
    TYPE CUR_TYPE IS REF CURSOR;
    C CUR_TYPE;
    V_SOURCE_PPE VARCHAR2(240) := 'PPE';
    V_SOURCE_RCRM VARCHAR2(240) := 'RCRM';
  BEGIN

    V_TEST_NAME := IN_TEST_NAME;
    V_PPE_FILE_NAME := IN_PPE_FILE_NAME;
    V_RCRM_FILE_NAME := IN_RCRM_FILE_NAME;
    
-- TODO: Duplicates DONE

-- TODO: Missing DONE

-- TODO: Compare fields DONE

-- TODO: Ignore fields DONE

    DELETE FROM TEST_STAGE_RCRM_PPE WHERE TEST_NAME = V_TEST_NAME;
    COMMIT;

    -- PPE Duplicates
    
    SELECT NVL(MAX(TEST_RESULT_NUMBER),0) INTO V_MAX_ROW_COUNT FROM TEST_STAGE_RCRM_PPE WHERE TEST_NAME = V_TEST_NAME;

    INSERT INTO TEST_STAGE_RCRM_PPE
      (TEST_NAME, TEST_RESULT_NUMBER, KEY_SOURCE, KEY_ORDER_NUMBER, KEY_COLI_ROW_ID, KEY_COMMISSION_PRODUCT_TYPE, FILE1_NAME, FILE1_DATE, RESULT, ROW_COUNT)
    SELECT
        V_TEST_NAME AS "TEST_NAME"
      , V_MAX_ROW_COUNT + ROWNUM AS "TEST_RESULT_NUMBER"
      , V_SOURCE_PPE
      , DC.KEY_ORDER_NUMBER
      , DC.KEY_COLI_ROW_ID
      , DC.KEY_COMMISSION_PRODUCT_TYPE
      , V_PPE_FILE_NAME
      , DC.BATCHPROCESSDATE
      , 'DUPLICATE' AS "RESULT"
      , DC.ROW_COUNT
    FROM (
      SELECT
          RW.ATTRIBUTE25 AS "KEY_ORDER_NUMBER"
        , RW.ATTRIBUTE46 AS "KEY_COLI_ROW_ID"
        , RW.ATTRIBUTE88 AS "KEY_COMMISSION_PRODUCT_TYPE"
        , COUNT(1) AS "ROW_COUNT"
        , RW.FILENAME
        , RW.BATCHPROCESSDATE
      FROM TELS_STAGE_RCRM_PPE RW
      WHERE (1=1)
      AND RW.FILENAME = V_PPE_FILE_NAME
      AND FILE_NAME LIKE 'SIEBEL-R_%'
      GROUP BY RW.ATTRIBUTE25, RW.ATTRIBUTE46, RW.ATTRIBUTE88, RW.FILENAME, RW.BATCHPROCESSDATE
    ) DC
    WHERE (1=1)
    AND DC.ROW_COUNT > 1;
    COMMIT;

    -- RCRM Duplicates
    
    SELECT NVL(MAX(TEST_RESULT_NUMBER),0) INTO V_MAX_ROW_COUNT FROM TEST_STAGE_RCRM_PPE WHERE TEST_NAME = V_TEST_NAME;

    INSERT INTO TEST_STAGE_RCRM_PPE
      (TEST_NAME, TEST_RESULT_NUMBER, KEY_SOURCE, KEY_ORDER_NUMBER, KEY_COLI_ROW_ID, KEY_COMMISSION_PRODUCT_TYPE, FILE1_NAME, FILE1_DATE, RESULT, ROW_COUNT)
    SELECT
        V_TEST_NAME AS "TEST_NAME"
      , V_MAX_ROW_COUNT + ROWNUM AS "TEST_RESULT_NUMBER"
      , V_SOURCE_RCRM
      , DC.KEY_ORDER_NUMBER
      , DC.KEY_COLI_ROW_ID
      , DC.KEY_COMMISSION_PRODUCT_TYPE
      , V_RCRM_FILE_NAME
      , DC.BATCHPROCESSDATE
      , 'DUPLICATE' AS "RESULT"
      , DC.ROW_COUNT
    FROM (
      SELECT
          RW.ATTRIBUTE25 AS "KEY_ORDER_NUMBER"
        , RW.ATTRIBUTE46 AS "KEY_COLI_ROW_ID"
        , RW.ATTRIBUTE88 AS "KEY_COMMISSION_PRODUCT_TYPE"
        , COUNT(1) AS "ROW_COUNT"
        , RW.FILENAME
        , RW.BATCHPROCESSDATE
      FROM TELS_STAGE_RCRM_PPE RW
      WHERE (1=1)
      AND RW.FILENAME = V_RCRM_FILE_NAME
      GROUP BY RW.ATTRIBUTE25, RW.ATTRIBUTE46, RW.ATTRIBUTE88, RW.FILENAME, RW.BATCHPROCESSDATE
    ) DC
    WHERE (1=1)
    AND DC.ROW_COUNT > 1;
    COMMIT;

    -- Missing from RCRM
    
    SELECT NVL(MAX(TEST_RESULT_NUMBER),0) INTO V_MAX_ROW_COUNT FROM TEST_STAGE_RCRM_PPE WHERE TEST_NAME = V_TEST_NAME;

    INSERT INTO TEST_STAGE_RCRM_PPE
      (TEST_NAME, TEST_RESULT_NUMBER, KEY_SOURCE, KEY_ORDER_NUMBER, KEY_COLI_ROW_ID, KEY_COMMISSION_PRODUCT_TYPE, FILE1_NAME, FILE1_DATE, FILE2_NAME, RESULT, ROW_COUNT)
    WITH PPE_FILE AS (
      SELECT
          ATTRIBUTE25 AS "KEY_ORDER_NUMBER"
        , ATTRIBUTE46 AS "KEY_COLI_ROW_ID"
        , ATTRIBUTE88 AS "KEY_COMMISSION_PRODUCT_TYPE"
        , FILENAME
        , BATCHPROCESSDATE
        , RECORDNUMBER
        , IS_FILTERED
        , QUERY_SRC
      FROM TELS_STAGE_RCRM_PPE
      WHERE (1=1)
      AND FILENAME = V_PPE_FILE_NAME -- PL/SQL
--      AND FILENAME = 'CCB-COMM_0216_PREPROCCOMMISSIONS_20181101_052139_nus974pd_EXT_11080452.dat' -- SQL
      AND FILE_NAME LIKE 'SIEBEL-R_%'
    ),
    RCRM_FILE AS (
      SELECT
          ATTRIBUTE25 AS "KEY_ORDER_NUMBER"
        , ATTRIBUTE46 AS "KEY_COLI_ROW_ID"
        , ATTRIBUTE88 AS "KEY_COMMISSION_PRODUCT_TYPE"
        , FILENAME
        , BATCHPROCESSDATE
        , RECORDNUMBER
        , IS_FILTERED
        , QUERY_SRC
      FROM TELS_STAGE_RCRM_PPE
      WHERE (1=1)
      AND FILENAME = V_RCRM_FILE_NAME -- PL/SQL
--      AND FILENAME = 'CCB-RCRM_OrderDataExtract_20181101_053525_EXT_11080452.dat' -- SQL
    )
    SELECT
        V_TEST_NAME AS "TEST_NAME" -- PL/SQL
--        'TEST_NAME' AS "TEST_NAME" -- SQL
      , V_MAX_ROW_COUNT + ROWNUM AS TEST_RESULT_NUMBER -- PL/SQL
--      , ROWNUM AS TEST_RESULT_NUMBER -- SQL
      , V_SOURCE_PPE
      , A.KEY_ORDER_NUMBER
      , A.KEY_COLI_ROW_ID
      , A.KEY_COMMISSION_PRODUCT_TYPE
      , V_PPE_FILE_NAME
      , A.BATCHPROCESSDATE
      , V_RCRM_FILE_NAME
      , 'MISSING FROM RCRM' AS "RESULT"
      , 1 AS "ROW_COUNT"
    FROM PPE_FILE A
    WHERE (1=1)
    AND NOT EXISTS (
      SELECT 1
      FROM RCRM_FILE B
      WHERE (1=1)
      AND B.KEY_ORDER_NUMBER = A.KEY_ORDER_NUMBER
      AND B.KEY_COLI_ROW_ID = A.KEY_COLI_ROW_ID
      AND B.KEY_COMMISSION_PRODUCT_TYPE = A.KEY_COMMISSION_PRODUCT_TYPE
    );
    COMMIT;
  
    -- Missing from PPE
    
    SELECT NVL(MAX(TEST_RESULT_NUMBER),0) INTO V_MAX_ROW_COUNT FROM TEST_STAGE_RCRM_PPE WHERE TEST_NAME = V_TEST_NAME;

    INSERT INTO TEST_STAGE_RCRM_PPE
      (TEST_NAME, TEST_RESULT_NUMBER, KEY_SOURCE, KEY_ORDER_NUMBER, KEY_COLI_ROW_ID, KEY_COMMISSION_PRODUCT_TYPE, FILE1_NAME, FILE1_DATE, FILE2_NAME, RESULT, ROW_COUNT)
    WITH PPE_FILE AS (
      SELECT
          ATTRIBUTE25 AS "KEY_ORDER_NUMBER"
        , ATTRIBUTE46 AS "KEY_COLI_ROW_ID"
        , ATTRIBUTE88 AS "KEY_COMMISSION_PRODUCT_TYPE"
        , FILENAME
        , BATCHPROCESSDATE
        , RECORDNUMBER
        , IS_FILTERED
        , QUERY_SRC
      FROM TELS_STAGE_RCRM_PPE
      WHERE (1=1)
      AND FILENAME = V_PPE_FILE_NAME -- PL/SQL
--      AND FILENAME = 'CCB-COMM_0216_PREPROCCOMMISSIONS_20181101_052139_nus974pd_EXT_11080452.dat' -- SQL
      AND FILE_NAME LIKE 'SIEBEL-R_%'
    ),
    RCRM_FILE AS (
      SELECT
          ATTRIBUTE25 AS "KEY_ORDER_NUMBER"
        , ATTRIBUTE46 AS "KEY_COLI_ROW_ID"
        , ATTRIBUTE88 AS "KEY_COMMISSION_PRODUCT_TYPE"
        , FILENAME
        , BATCHPROCESSDATE
        , RECORDNUMBER
        , IS_FILTERED
        , QUERY_SRC
      FROM TELS_STAGE_RCRM_PPE
      WHERE (1=1)
      AND FILENAME = V_RCRM_FILE_NAME -- PL/SQL
--      AND FILENAME = 'CCB-RCRM_OrderDataExtract_20181101_053525_EXT_11080452.dat' -- SQL
    )
    SELECT
        V_TEST_NAME AS "TEST_NAME" -- PL/SQL
--        'TEST_NAME' AS "TEST_NAME" -- SQL
      , V_MAX_ROW_COUNT + ROWNUM AS TEST_RESULT_NUMBER -- PL/SQL
--      , ROWNUM AS TEST_RESULT_NUMBER -- SQL
      , V_SOURCE_RCRM
      , A.KEY_ORDER_NUMBER
      , A.KEY_COLI_ROW_ID
      , A.KEY_COMMISSION_PRODUCT_TYPE
      , V_RCRM_FILE_NAME
      , A.BATCHPROCESSDATE
      , V_PPE_FILE_NAME
      , 'MISSING FROM PPE' AS "RESULT"
      , 1 AS "ROW_COUNT"
    FROM RCRM_FILE A
    WHERE (1=1)
    AND NOT EXISTS (
      SELECT 1
      FROM PPE_FILE B
      WHERE (1=1)
      AND B.KEY_ORDER_NUMBER = A.KEY_ORDER_NUMBER
      AND B.KEY_COLI_ROW_ID = A.KEY_COLI_ROW_ID
      AND B.KEY_COMMISSION_PRODUCT_TYPE = A.KEY_COMMISSION_PRODUCT_TYPE
    );
    COMMIT;
  
-- COMPARE COLUMNS PPE TO RCRM

    SELECT NVL(MAX(TEST_RESULT_NUMBER),0) INTO V_MAX_ROW_COUNT FROM TEST_STAGE_RCRM_PPE WHERE TEST_NAME = V_TEST_NAME;

V_SQL_1 := '' ||
'WITH PPE_FILE AS ( ' ||
'SELECT ' ||
'X.ATTRIBUTE25 AS "KEY_ORDER_NUMBER" ' ||
', X.ATTRIBUTE46 AS "KEY_COLI_ROW_ID" ' ||
', X.ATTRIBUTE88 AS "KEY_COMMISSION_PRODUCT_TYPE" ' ||
', X.* ' ||
'FROM TELS_STAGE_RCRM_PPE X ' ||
'WHERE (1=1) ' ||
'AND FILENAME = ''' || V_PPE_FILE_NAME || ''' ' ||
'AND FILE_NAME LIKE ''SIEBEL-R_%'' ' ||
'), ' ||
'RCRM_FILE AS ( ' ||
'SELECT ' ||
'X.ATTRIBUTE25 AS "KEY_ORDER_NUMBER" ' ||
', X.ATTRIBUTE46 AS "KEY_COLI_ROW_ID" ' ||
', X.ATTRIBUTE88 AS "KEY_COMMISSION_PRODUCT_TYPE" ' ||
', X.* ' ||
'FROM TELS_STAGE_RCRM_PPE X ' ||
'WHERE (1=1) ' ||
'AND FILENAME = ''' || V_RCRM_FILE_NAME || ''' ' ||
') ' ||
'SELECT ' ||
'''' || V_TEST_NAME  || ''' ' ||
', ' || V_MAX_ROW_COUNT || ' + ROWNUM ' ||
', ''' || V_SOURCE_PPE || ''' ' ||
', A.KEY_ORDER_NUMBER ' ||
', A.KEY_COLI_ROW_ID ' ||
', A.KEY_COMMISSION_PRODUCT_TYPE ' ||
', ''' || V_PPE_FILE_NAME || ''' ' ||
', A.BATCHPROCESSDATE ' ||
', ''' || V_RCRM_FILE_NAME || ''' ' ||
', B.BATCHPROCESSDATE ' ||
',''MISMATCH'' ' ||
', 1 ';

FOR REC IN (
SELECT
A.COLUMN_NAME AS "COLUMN_NAME"
, NVL2(B.COLUMN_NAME,1,0) AS "IGNORE_FLAG"
FROM ALL_TAB_COLUMNS A
LEFT JOIN TEST_IGNORE_COLUMN B
ON B.COLUMN_NAME = A.COLUMN_NAME
WHERE (1=1)
AND A.TABLE_NAME = 'TELS_STAGE_RCRM_PPE'
ORDER BY A.COLUMN_ID ASC
)
LOOP
  IF REC.IGNORE_FLAG = 1 THEN
--    V_SQL_2 := V_SQL_2 || ', NULL AS "' || REC.COLUMN_NAME || '"';
    V_SQL_2 := V_SQL_2 || ', NULL ';
  ELSE
--    V_SQL_2 := V_SQL_2 || ', DECODE(A.' || REC.COLUMN_NAME || ',B.' || REC.COLUMN_NAME || ',NULL,A.' || REC.COLUMN_NAME || ') AS "' || REC.COLUMN_NAME || '"';
    V_SQL_2 := V_SQL_2 || ', DECODE(A.' || REC.COLUMN_NAME || ',B.' || REC.COLUMN_NAME || ',NULL,A.' || REC.COLUMN_NAME || ') ';
    V_SQL_4 := V_SQL_4 || 'OR A.' || REC.COLUMN_NAME || ' <> B.' || REC.COLUMN_NAME || ' ';
  END IF;
END LOOP;

V_SQL_3 := '' ||
'FROM PPE_FILE A ' ||
'JOIN RCRM_FILE B ' ||
'ON A.KEY_ORDER_NUMBER = B.KEY_ORDER_NUMBER ' ||
'AND A.KEY_COLI_ROW_ID = B.KEY_COLI_ROW_ID ' ||
'AND A.KEY_COMMISSION_PRODUCT_TYPE = B.KEY_COMMISSION_PRODUCT_TYPE ' ||
'WHERE (1=1) ' ||
'AND ( ' ||
'1 = 0 ';

V_SQL_5 := ')';

V_SQL := V_SQL_1 || V_SQL_2 || V_SQL_3 || V_SQL_4 || V_SQL_5;

OPEN C FOR V_SQL;
LOOP
  FETCH C BULK COLLECT INTO A_DATA;
  FORALL I IN 1..A_DATA.COUNT
    INSERT INTO TEST_STAGE_RCRM_PPE VALUES A_DATA(I);
  EXIT WHEN C%NOTFOUND;
END LOOP;
CLOSE C;
COMMIT;

    -- COMPARE COLUMNS - RCRM TO PPE
      
    SELECT NVL(MAX(TEST_RESULT_NUMBER),0) INTO V_MAX_ROW_COUNT FROM TEST_STAGE_RCRM_PPE WHERE TEST_NAME = V_TEST_NAME;

V_SQL_1 := '' ||
'WITH PPE_FILE AS ( ' ||
'SELECT ' ||
'X.ATTRIBUTE25 AS "KEY_ORDER_NUMBER" ' ||
', X.ATTRIBUTE46 AS "KEY_COLI_ROW_ID" ' ||
', X.ATTRIBUTE88 AS "KEY_COMMISSION_PRODUCT_TYPE" ' ||
', X.* ' ||
'FROM TELS_STAGE_RCRM_PPE X ' ||
'WHERE (1=1) ' ||
'AND FILENAME = ''' || V_PPE_FILE_NAME || ''' ' ||
'AND FILE_NAME LIKE ''SIEBEL-R_%'' ' ||
'), ' ||
'RCRM_FILE AS ( ' ||
'SELECT ' ||
'X.ATTRIBUTE25 AS "KEY_ORDER_NUMBER" ' ||
', X.ATTRIBUTE46 AS "KEY_COLI_ROW_ID" ' ||
', X.ATTRIBUTE88 AS "KEY_COMMISSION_PRODUCT_TYPE" ' ||
', X.* ' ||
'FROM TELS_STAGE_RCRM_PPE X ' ||
'WHERE (1=1) ' ||
'AND FILENAME = ''' || V_RCRM_FILE_NAME || ''' ' ||
') ' ||
'SELECT ' ||
'''' || V_TEST_NAME  || ''' ' ||
', ' || V_MAX_ROW_COUNT || ' + ROWNUM ' ||
', ''' || V_SOURCE_RCRM || ''' ' ||
', A.KEY_ORDER_NUMBER ' ||
', A.KEY_COLI_ROW_ID ' ||
', A.KEY_COMMISSION_PRODUCT_TYPE ' ||
', ''' || V_RCRM_FILE_NAME || ''' ' ||
', A.BATCHPROCESSDATE ' ||
', ''' || V_PPE_FILE_NAME || ''' ' ||
', B.BATCHPROCESSDATE ' ||
',''MISMATCH'' ' ||
', 1 ';

V_SQL_3 := '' ||
'FROM RCRM_FILE A ' ||
'JOIN PPE_FILE B ' ||
'ON A.KEY_ORDER_NUMBER = B.KEY_ORDER_NUMBER ' ||
'AND A.KEY_COLI_ROW_ID = B.KEY_COLI_ROW_ID ' ||
'AND A.KEY_COMMISSION_PRODUCT_TYPE = B.KEY_COMMISSION_PRODUCT_TYPE ' ||
'WHERE (1=1) ' ||
'AND ( ' ||
'1 = 0 ';

V_SQL := V_SQL_1 || V_SQL_2 || V_SQL_3 || V_SQL_4 || V_SQL_5;

OPEN C FOR V_SQL;
LOOP
  FETCH C BULK COLLECT INTO A_DATA;
  FORALL I IN 1..A_DATA.COUNT
    INSERT INTO TEST_STAGE_RCRM_PPE VALUES A_DATA(I);
  EXIT WHEN C%NOTFOUND;
END LOOP;
CLOSE C;
COMMIT;
  
  END TEST_STAGE_RCRM_PPE_LOAD;

END TEST_STAGE_RCRM_PPE_PKG;
/

SHOW ERRORS
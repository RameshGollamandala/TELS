CREATE OR REPLACE PACKAGE TELS_PRESTAGE_RCRM_PKG
AS
  PROCEDURE TELS_PRESTAGE_RCRM_PRE_LOAD;
  PROCEDURE TELS_PRESTAGE_RCRM_POST_LOAD;
END TELS_PRESTAGE_RCRM_PKG;
/

CREATE OR REPLACE PACKAGE BODY TELS_PRESTAGE_RCRM_PKG
AS

PROCEDURE TELS_PRESTAGE_RCRM_PRE_LOAD
AS
BEGIN

  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE TELS_PRESTAGE_RCRM DROP PRIMARY KEY CASCADE';
  EXCEPTION
    WHEN OTHERS
    THEN NULL;
  END;

  BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX TELS_PRESTAGE_RCRM';
  EXCEPTION
    WHEN OTHERS
    THEN NULL;
  END;

  BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE TELS_PRESTAGE_RCRM REUSE STORAGE';
  EXCEPTION
    WHEN OTHERS
    THEN NULL;
  END;

END TELS_PRESTAGE_RCRM_PRE_LOAD;

PROCEDURE TELS_PRESTAGE_RCRM_POST_LOAD
AS
BEGIN

  BEGIN
    EXECUTE IMMEDIATE 'CREATE UNIQUE INDEX TELS_PRESTAGE_RCRM ON TELS_PRESTAGE_RCRM '
      || '(FILENAME,BATCHPROCESSDATE,RECORDNUMBER) '
      || 'TABLESPACE TELS_SOURCES';
  EXCEPTION
    WHEN OTHERS
    THEN NULL;
  END;

  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE TELS_PRESTAGE_RCRM ADD ('
      || 'CONSTRAINT TELS_PRESTAGE_RCRM'
      || 'PRIMARY KEY'
      || '(FILENAME,BATCHPROCESSDATE,RECORDNUMBER)'
      || 'USING INDEX TELS_PRESTAGE_RCRM)';
  EXCEPTION
    WHEN OTHERS
    THEN NULL;
  END;

  BEGIN
    SYS.DBMS_STATS.GATHER_TABLE_STATS(
        OwnName        => 'TELSADMIN'
       ,TabName        => 'TELS_PRESTAGE_RCRM'
      ,Estimate_Percent  => NULL
      ,Method_Opt        => 'FOR ALL INDEXED COLUMNS SIZE AUTO'
      ,Degree            => NULL
      ,Cascade           => TRUE
      ,No_Invalidate     => FALSE);
  EXCEPTION
    WHEN OTHERS
    THEN NULL;
  END;

END TELS_PRESTAGE_RCRM_POST_LOAD;

END;
/

SHOW ERRORS
/********************************************************************
  ** TELS_CORE_JOB_QUEUE
  **
  ** Version: 1.0
  ** Author: Simon Marsh
  ** Created: June 2018
  ** Description:
  **
  ** Date       Modified By   Description
  ** ------------------------------------------------------------------
  ** 20180619   Simon Marsh   Initial Version
  ********************************************************************/
--DROP TABLE TELS_CORE_JOB_QUEUE;
CREATE TABLE TELS_CORE_JOB_QUEUE 
(
    JOB_ID              NUMBER(25,0),
    JOB_NAME            VARCHAR2(255 BYTE),
    JOB_TYPE            VARCHAR2(255 BYTE),
    DUE_DATETIME        TIMESTAMP(6),
    CALLSCRIPT          VARCHAR2(255 BYTE),
    STATUS              VARCHAR2(127 BYTE) --QUEUED, STARTED
);

CREATE SEQUENCE TELS_CORE_JOB_QUEUE_SEQ  MINVALUE 0 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 NOCACHE  NOORDER  NOCYCLE ;

CREATE OR REPLACE TRIGGER TELS_CORE_JOB_QUEUE_TRG BEFORE
    INSERT ON TELS_CORE_JOB_QUEUE
    FOR EACH ROW
BEGIN
    SELECT
        TELS_CORE_JOB_QUEUE_SEQ.NEXTVAL
    INTO
        :new.JOB_ID
    FROM
        dual;
END;
/
ALTER TRIGGER TELS_CORE_JOB_QUEUE_TRG ENABLE;
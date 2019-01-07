/********************************************************************
  ** TELS_CORE_JOB_HISTORY
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
--DROP TABLE TELS_CORE_JOB_HISTORY;
CREATE TABLE TELS_CORE_JOB_HISTORY 
(
    JOB_ID              NUMBER(25,0),
    JOB_NAME            VARCHAR2(255 BYTE),
    JOB_TYPE            VARCHAR2(255 BYTE),
    DUE_DATETIME        TIMESTAMP(6),
    CALLSCRIPT          VARCHAR2(255 BYTE),
    JOB_STARTTIME       TIMESTAMP(6),
    JOB_ENDTIME         TIMESTAMP(6),
    JOB_STATUS          VARCHAR2(255 BYTE),
    JOB_MESSAGE         TIMESTAMP(6)
);

/********************************************************************
  ** TELS_CORE_JOB_TEMPLATE
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
--DROP TABLE TELS_CORE_JOB_TEMPLATE;
CREATE TABLE TELS_CORE_JOB_TEMPLATE
(
    JOB_NAME            VARCHAR2(255 BYTE), 
    JOB_TYPE            VARCHAR2(255 BYTE), --Import, Outbound, Pipeline
    CALLSCRIPT          VARCHAR2(4000 BYTE)
);
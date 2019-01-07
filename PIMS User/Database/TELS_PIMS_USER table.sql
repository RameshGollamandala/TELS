/********************************************************************
  ** TELS_PIMS_USER
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
--DROP TABLE TELS_PIMS_USER;
CREATE TABLE TELS_PIMS_USER (
    FILENAME         VARCHAR(50) NOT NULL ENABLE,
    RECORD_NUMBER    NUMBER(15,0) NOT NULL ENABLE,
    USERID           VARCHAR(255),
    USERNAME         VARCHAR(255),
    EMAIL            VARCHAR(255),
    PARTNER_CODE     VARCHAR(255),
    ROLE             VARCHAR(255),
    START_DATE       VARCHAR(255),
    TERMINATION_DATE VARCHAR(255),
    STATUS           VARCHAR(255)
--    ,CONSTRAINT TELS_PIMS_USER PRIMARY KEY (FILENAME, RECORD_NUMBER)
);
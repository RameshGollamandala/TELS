/********************************************************************
  ** TELS_CCG_USER
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
--DROP TABLE TELS_CCG_USER;
CREATE TABLE TELS_CCG_USER
(
    USER_ID                   varchar(255),
    USER_NAME                 varchar(50),
    START_DATE                timestamp(9),
    END_DATE                  timestamp(9),
    EMAIL_ADDRESS             varchar(50),
    DESCRIPTION               varchar(255),
    APPLICATION_NAME          varchar(50),
    RESPONSIBILITY_NAME       varchar(50),
    SECURITY_GROUP_NAME       varchar(50),
    RESPONSIBILITY_START_DATE timestamp(9),
    RESPONSIBILITY_END_DATE   timestamp(9),
    Import_Date               timestamp(9)
);

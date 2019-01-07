/********************************************************************
  ** TELS_REPOSITORYEXPORT_CONFIG
  **
  ** Version: 1.0
  ** Author: Simon Marsh
  ** Created: September 2018
  ** Description:
  **
  ** Date       Modified By   Description
  ** ------------------------------------------------------------------
  ** 20180910   Simon Marsh   Initial Version
  ********************************************************************/
--DROP TABLE TELS_REPOSITORYEXPORT_CONFIG;
CREATE TABLE TELS_REPOSITORYEXPORT_CONFIG
(
    OWNER               varchar(50),
    TABLE_NAME          varchar(50),
    EXPORT_SCHEDULE     varchar(10),
    COLUMN_LIST         varchar(4000),
    DB_LINK             varchar(50),
    TABLE_FILTER        varchar(4000)
);

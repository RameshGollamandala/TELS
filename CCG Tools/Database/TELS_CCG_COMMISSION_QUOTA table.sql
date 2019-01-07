/********************************************************************
  ** TELS_CCG_COMMISSION_QUOTA
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
--DROP TABLE TELS_CCG_COMMISSION_QUOTA;
CREATE TABLE TELS_CCG_COMMISSION_QUOTA
(
    QUOTA_ID                 varchar(38),
    TRANSACTION_TYPE         varchar(10),
    INTERVAL_TYPE_ID         varchar(10),
    CALC_FORMULA_ID          varchar(38),
    PLAN_ELEMENT_DESCRIPTION varchar(255),
    CALC_FORMULA_NAME        varchar(255),
    CALC_FORMULA_DESCRIPTION varchar(255)
);
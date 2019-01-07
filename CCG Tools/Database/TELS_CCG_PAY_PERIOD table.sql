/********************************************************************
  ** TELS_CCG_PAY_PERIOD
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
--DROP TABLE TELS_CCG_PAY_PERIOD;
CREATE TABLE TELS_CCG_PAY_PERIOD
(
    PERIOD_NAME       varchar(50),
    POSTING_DATE      varchar(19),
    START_DATE        varchar(19),
    END_DATE          varchar(19),
    PERIOD_YEAR       varchar(10),
    PERIOD_NUM        varchar(255),
    PAY_PERIOD_ID     varchar(255),
    PAY_RUN_ID        varchar(28),
    PAY_GROUP_NAME    varchar(255),
    PAY_GROUP_ID      varchar(50),
    TRANSACTION_COUNT varchar(50),
    CreatedDateTime   varchar(19)
);
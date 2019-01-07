/********************************************************************
  ** TELS_TEMPLATE_TXTR_TXNREP
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
--DROP TABLE TELS_TEMPLATE_TXTR_TXNREP;
CREATE TABLE TELS_TEMPLATE_TXTR_TXNREP
(
    FILENAME          varchar2(255) NOT NULL,
    RECORDNUMBER      number(10) NOT NULL,
    BATCHPROCESSDATE  varchar2(255),
    ORDERID           varchar2(255),
    LINENUMBER        varchar2(255),
    SUBLINENUMBER     varchar2(255),
    EVENTTYPEID       varchar2(255),
    PAGENUMBER        varchar2(255),
    REPORTATTRIBUTE1  varchar2(255),
    REPORTATTRIBUTE2  varchar2(255),
    REPORTATTRIBUTE3  varchar2(255),
    REPORTATTRIBUTE4  varchar2(255),
    REPORTATTRIBUTE5  varchar2(255),
    REPORTATTRIBUTE6  varchar2(255),
    REPORTATTRIBUTE7  varchar2(255),
    REPORTATTRIBUTE8  varchar2(255),
    REPORTATTRIBUTE9  varchar2(255),
    REPORTATTRIBUTE10 varchar2(255),
    REPORTATTRIBUTE11 varchar2(255),
    REPORTATTRIBUTE12 varchar2(255),
    REPORTATTRIBUTE13 varchar2(255),
    REPORTATTRIBUTE14 varchar2(255),
    REPORTATTRIBUTE15 varchar2(255),
    REPORTATTRIBUTE16 varchar2(255),
    REPORTATTRIBUTE17 varchar2(255),
    REPORTATTRIBUTE18 varchar2(255),
    REPORTATTRIBUTE19 varchar2(255),
    REPORTATTRIBUTE20 varchar2(255)
);


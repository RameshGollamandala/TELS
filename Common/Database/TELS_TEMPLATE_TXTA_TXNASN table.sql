/********************************************************************
  ** TELS_TEMPLATE_TXTA_TXNASN
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
--DROP TABLE TELS_TEMPLATE_TXTA_TXNASN;
CREATE TABLE TELS_TEMPLATE_TXTA_TXNASN
(
    FILENAME                  varchar2(255) NOT NULL,
    RECORDNUMBER              number(10) NOT NULL,
    BATCHPROCESSDATE          varchar2(255),
    ORDERID                   varchar2(255),
    LINENUMBER                varchar2(255),
    SUBLINENUMBER             varchar2(255),
    EVENTTYPEID               varchar2(255),
    PAYEEID                   varchar2(255),
    PAYEETYPE                 varchar2(255),
    POSITIONNAME              varchar2(255),
    TITLENAME                 varchar2(255),
    GENERICATTRIBUTE1         varchar2(255),
    GENERICATTRIBUTE2         varchar2(255),
    GENERICATTRIBUTE3         varchar2(255),
    GENERICATTRIBUTE4         varchar2(255),
    GENERICATTRIBUTE5         varchar2(255),
    GENERICATTRIBUTE6         varchar2(255),
    GENERICATTRIBUTE7         varchar2(255),
    GENERICATTRIBUTE8         varchar2(255),
    GENERICATTRIBUTE9         varchar2(255),
    GENERICATTRIBUTE10        varchar2(255),
    GENERICATTRIBUTE11        varchar2(255),
    GENERICATTRIBUTE12        varchar2(255),
    GENERICATTRIBUTE13        varchar2(255),
    GENERICATTRIBUTE14        varchar2(255),
    GENERICATTRIBUTE15        varchar2(255),
    GENERICATTRIBUTE16        varchar2(255),
    GENERICNUMBER1            varchar2(255),
    UNITTYPEFORGENERICNUMBER1 varchar2(255),
    GENERICNUMBER2            varchar2(255),
    UNITTYPEFORGENERICNUMBER2 varchar2(255),
    GENERICNUMBER3            varchar2(255),
    UNITTYPEFORGENERICNUMBER3 varchar2(255),
    GENERICNUMBER4            varchar2(255),
    UNITTYPEFORGENERICNUMBER4 varchar2(255),
    GENERICNUMBER5            varchar2(255),
    UNITTYPEFORGENERICNUMBER5 varchar2(255),
    GENERICNUMBER6            varchar2(255),
    UNITTYPEFORGENERICNUMBER6 varchar2(255),
    GENERICDATE1              varchar2(255),
    GENERICDATE2              varchar2(255),
    GENERICDATE3              varchar2(255),
    GENERICDATE4              varchar2(255),
    GENERICDATE5              varchar2(255),
    GENERICDATE6              varchar2(255),
    GENERICBOOLEAN1           varchar2(255),
    GENERICBOOLEAN2           varchar2(255),
    GENERICBOOLEAN3           varchar2(255),
    GENERICBOOLEAN4           varchar2(255),
    GENERICBOOLEAN5           varchar2(255),
    GENERICBOOLEAN6           varchar2(255)
);

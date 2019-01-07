/********************************************************************
  ** TELS_MIF_PRESTAGE
  **
  ** Version: 1.0
  ** Author: Simon Marsh
  ** Created: October 2018
  ** Description:
  **
  ** Date       Modified By   Description
  ** ------------------------------------------------------------------
  ** 20181001   Simon Marsh   Initial Version
  ********************************************************************/
--DROP TABLE TELS_ORDEREXPRESS_MIF_PRESTAGE;
CREATE TABLE TELS_ORDEREXPRESS_MIF_PRESTAGE
(
    FILENAME                  varchar2(255) not null,
    RECORDNUMBER              number(10) not null,
    BATCHPROCESSDATE          varchar(255),
    IS_FILTERED               varchar(255),
    ORDERNUMBER               varchar(255),
    RECORDSEQUENCE            varchar(255),
    EVENTTYPE                 varchar(255),
    ORDERLINENUMBER           varchar(255),
    EFFECTIVEDATE             varchar(255),
    DEALERCODE                varchar(255),
    SERVICEIDENTIFIER         varchar(255),
    CUSTOMERNAME              varchar(255),
    CUSTOMERBU                varchar(255),
    BILLINGACCOUNT            varchar(255),
    COMMISSIONTYPE            varchar(255),
    COMMISSIONPERCENTAGE      varchar(255),
    COMMISSIONTOTAL           varchar(255),
    PRODUCTCATEGORY           varchar(255),
    PRODUCTCODE               varchar(255),
    PRODUCTDESCRIPTION        varchar(255),
    SALEPRICE                 varchar(255),
    QUANTITY                  varchar(255),
    COMMENTS                  varchar(255),
    SOURCESYSTEM              varchar(255),
    ORDERTYPE                 varchar(255),
    SUBORDERTYPE              varchar(255),
    SALESTYPE                 varchar(255),
    MMC                       varchar(255),
    CONTRACTSTARTDATE         varchar(255),
    CONTRACTTERM              varchar(255),
    PREVIOUSPRODUCTCODE       varchar(255),
    PREVIOUSMMC               varchar(255),
    PREVIOUSCONTRACTSTARTDATE varchar(255),
    PREVIOUSCONTRACTTERM      varchar(255),
    ACCESSTYPE                varchar(255),
    REPAYMENTMETHOD           varchar(255),
    IMEI_SERIALNO             varchar(255),
    COSTCENTREOVERRIDE        varchar(255),
    GSTOVERRIDE               varchar(255),
    ATTRIBUTE1                varchar(255),
    ATTRIBUTE2                varchar(255),
    ATTRIBUTE3                varchar(255),
    ATTRIBUTE4                varchar(255),
    ATTRIBUTE5                varchar(255),
    ATTRIBUTE6                varchar(255),
    ATTRIBUTE7                varchar(255),
    ATTRIBUTE8                varchar(255),
    ATTRIBUTE9                varchar(255),
    ATTRIBUTEDATE1            varchar(255),
    ATTRIBUTEDATE2            varchar(255),
    ATTRIBUTEDATE3            varchar(255),
    ATTRIBUTEDATE4            varchar(255),
    ATTRIBUTEDATE5            varchar(255),
    ATTRIBUTEBOOLEAN1         varchar(255),
    ATTRIBUTEBOOLEAN2         varchar(255),
    ATTRIBUTEBOOLEAN3         varchar(255),
    ATTRIBUTEBOOLEAN4         varchar(255),
    ATTRIBUTEBOOLEAN5         varchar(255),
    ATTRIBUTENUM1             varchar(255),
    ATTRIBUTENUM2             varchar(255),
    ATTRIBUTENUM3             varchar(255),
    ATTRIBUTENUM4             varchar(255),
    ATTRIBUTENUM5             varchar(255),
    ATTRIBUTENUM6             varchar(255),
    ATTRIBUTENUM7             varchar(255),
    ATTRIBUTENUM8             varchar(255),
    ATTRIBUTENUM9             varchar(255)
);

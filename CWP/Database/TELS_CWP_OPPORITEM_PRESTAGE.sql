DROP TABLE TELS_CWP_OPPORITEM_PRESTAGE CASCADE CONSTRAINTS PURGE
/

CREATE TABLE TELS_CWP_OPPORITEM_PRESTAGE
(
  FILENAME                       VARCHAR2(255 BYTE) NOT NULL,
  BATCHPROCESSDATE               DATE           NOT NULL,
  RECORDNUMBER                   NUMBER(15)     NOT NULL,
  IS_FILTERED                    NUMBER(1)      NOT NULL,
  B2B_KEY                        VARCHAR2(255 BYTE),
  B2B_INSERT_TIMESTAMP           VARCHAR2(255 BYTE),
  B2B_BATCH_ID                   VARCHAR2(255 BYTE),
  SOURCE_SYSTEM_KEY              VARCHAR2(255 BYTE),
  SOURCE_SYSTEM_OPPORTUNITY_KEY  VARCHAR2(255 BYTE),
  OPPITEM_NAME                   VARCHAR2(255 BYTE),
  QUANTITY                       VARCHAR2(255 BYTE),
  TOTAL_PRICE                    VARCHAR2(255 BYTE),
  UNIT_PRICE                     VARCHAR2(255 BYTE),
  LIST_PRICE                     VARCHAR2(255 BYTE),
  DESCRIPTION                    VARCHAR2(255 BYTE),
  IS_DELETED                     VARCHAR2(255 BYTE),
  ACQUISITION_REVENUE            VARCHAR2(255 BYTE),
  AVG_ACQUISITION_REVENUE        VARCHAR2(255 BYTE),
  CHANNEL                        VARCHAR2(255 BYTE),
  COMPETITOR                     VARCHAR2(255 BYTE),
  CONTRACT_TERMS                 VARCHAR2(255 BYTE),
  CURRENT_REVENUE                VARCHAR2(255 BYTE),
  DEALER                         VARCHAR2(255 BYTE),
  DOMAIN                         VARCHAR2(255 BYTE),
  INCREMENTAL_REVENUE            VARCHAR2(255 BYTE),
  NEW_INCOME_REVENUE             VARCHAR2(255 BYTE),
  ONCE_OFF_REVENUE               VARCHAR2(255 BYTE),
  PRODUCT_CODE                   VARCHAR2(255 BYTE),
  PRODUCT_NAME                   VARCHAR2(255 BYTE),
  PRODUCT_STATUS                 VARCHAR2(255 BYTE),
  RENEWAL_REVENUE                VARCHAR2(255 BYTE),
  SRM                            VARCHAR2(255 BYTE),
  TOTAL_CUSTOM_PRICE             VARCHAR2(255 BYTE),
  PRODUCT_FAMILY                 VARCHAR2(255 BYTE),
  PRODUCT_GROUP                  VARCHAR2(255 BYTE),
  ULTIMATE_PRODUCT               VARCHAR2(255 BYTE)
)
TABLESPACE TELS_SOURCES
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING
/


CREATE UNIQUE INDEX TELS_PRESTAGE_OPPORITEM_PK ON TELS_CWP_OPPORITEM_PRESTAGE
(FILENAME, BATCHPROCESSDATE, RECORDNUMBER)
LOGGING
TABLESPACE TELS_SOURCES
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL
/

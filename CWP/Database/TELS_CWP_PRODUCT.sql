DROP TABLE TELS_CWP_PRODUCT CASCADE CONSTRAINTS PURGE
/

CREATE TABLE TELS_CWP_PRODUCT
(
  FILENAME                        VARCHAR2(255 BYTE) NOT NULL,
  BATCHPROCESSDATE                DATE          NOT NULL,
  RECORDNUMBER                    NUMBER(15)    NOT NULL,
  IS_FILTERED                     NUMBER(1)     NOT NULL,
  PRODUCT_SOURCE                  VARCHAR2(255 BYTE),
  PHOENIX_BILLING_ACCOUNT_NUMBER  VARCHAR2(255 BYTE),
  SOURCE_SYS_CUSTOMER_KEY         VARCHAR2(255 BYTE),
  SOURCE_SYS_CUSTOMER_ORDER_KEY   VARCHAR2(255 BYTE),
  SOURCE_SYSTEM_OFFER_KEY         VARCHAR2(255 BYTE),
  SOURCE_SYSTEM_SITE_KEY          VARCHAR2(255 BYTE),
  SOURCE_SYS_PRODUCT_OFFER_KEY    VARCHAR2(255 BYTE),
  SOURCE_SYSTEM_KEY               VARCHAR2(255 BYTE),
  IS_DELETED                      INTEGER,
  PRODUCT_NAME                    VARCHAR2(255 BYTE),
  SOURCE_SYSTEM_CREATED_DATE      DATE,
  ORDER_IDENTIFICATION            VARCHAR2(255 BYTE),
  PRODUCT_STATUS                  VARCHAR2(255 BYTE),
  TOTAL_ONE_OFF_CHARGE            NUMBER(25,10),
  TOTAL_RECURRING_CHARGE          NUMBER(25,10),
  TOTAL_SERVICE_ONE_OFF_CHARGE    NUMBER(25,10),
  TOTAL_SERVICE_RECURR_CHARGE     NUMBER(25,10),
  TOTAL_SL_ITEM_ONE_OFF_CHARGE    NUMBER(25,10),
  CHANGE_TYPE                     VARCHAR2(255 BYTE),
  IS_REPLACED                     VARCHAR2(255 BYTE),
  REPLACED_PRODUCT_KEY            VARCHAR2(255 BYTE),
  REPLACEMENT_PRODUCT_KEY         VARCHAR2(255 BYTE),
  SUBSCRIPTION_SEQUENCE_NUMBER    VARCHAR2(255 BYTE),
  SUBSCRIPTION_NUMBER             VARCHAR2(255 BYTE),
  RIGHT_TO_BILL_DATE              DATE,
  SUB_STATUS                      VARCHAR2(255 BYTE),
  PRODUCT_EVENTID                 VARCHAR2(255 BYTE),
  RESPONSE_STATUS_CODE            NUMBER(25,10),
  FORECASTED_DELIVERY_DATE        DATE,
  TELSTRA_COMMITTED_DATE          DATE,
  B2B_INSERT_TIMESTAMP            DATE,
  B2B_KEY                         VARCHAR2(255 BYTE),
  B2B_BATCH_ID                    VARCHAR2(255 BYTE)
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


CREATE UNIQUE INDEX TELS_PRODUCT_PK ON TELS_CWP_PRODUCT
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
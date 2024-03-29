ALTER TABLE TELS_RCRM_PRESTAGE_LINE DROP PRIMARY KEY CASCADE;

DROP TABLE TELS_RCRM_PRESTAGE_LINE CASCADE CONSTRAINTS;

CREATE TABLE TELS_RCRM_PRESTAGE_LINE
(
    FILENAME VARCHAR2(255) NOT NULL
  , BATCHPROCESSDATE DATE NOT NULL
  , RECORDNUMBER NUMBER(15) NOT NULL
  , IS_FILTERED NUMBER(1) NOT NULL
  , ORDER_NUMBER VARCHAR2(30)
  , BILLING_ACCOUNT VARCHAR2(100)
  , CUSTOMER_LAST_NAME VARCHAR2(100)
  , CUSTOMER_FIRST_NAME VARCHAR2(50)
  , ORDER_TYPE VARCHAR2(50)
  , ORDER_SUB_TYPE VARCHAR2(30)
  , CREATED_DATE VARCHAR2(25)
  , PARTNER_CODE VARCHAR2(30)
  , CAMPAIGN_NAME VARCHAR2(100)
  , CAMPAIGN_NUMBER VARCHAR2(30)
  , CAMPAIGN_TYPE VARCHAR2(30)
  , CHANNEL_TYPE VARCHAR2(30)
  , CAMPAIGN_START_DATE VARCHAR2(25)
  , BUSINESS_UNIT VARCHAR2(1)
  , SALES_FORCE_ID VARCHAR2(30)
  , CUSTOMER_ID VARCHAR2(15)
  , ORDER_REVISION_NUMBER VARCHAR2(30)
  , SUBMITTED_DATE VARCHAR2(25)
  , STATUS_HEADER VARCHAR2(30)
  , REASON_CODE VARCHAR2(30)
  , COMMISSION_TRANSACTION_TYPE VARCHAR2(15)
  , SOURCE_SYSTEM VARCHAR2(8)
  , ROW_ID VARCHAR2(15)
  , PRODUCT VARCHAR2(100)
  , PART_NUMBER VARCHAR2(50)
  , ACTION_CODE VARCHAR2(30)
  , TRANSFER_TYPE VARCHAR2(30)
  , EVENT_SOURCE VARCHAR2(100)
  , PROD_PROM_ID VARCHAR2(15)
  , PROVISIONED_DATE VARCHAR2(25)
  , NET_PRICE VARCHAR2(30)
  , COMMISSION_PRODUCT_TYPE VARCHAR2(50)
  , COMMISSIONABLE VARCHAR2(30)
  , STATUS_ORDER_LINE_ITEM VARCHAR2(30)
  , ORIGINAL_ORDER_NUMBER VARCHAR2(30)
  , HARDWARE_SUPPLIED_FLAG VARCHAR2(1)
  , SUB_ACTION_CODE VARCHAR2(30)
  , PROMOTION_INTEGRATION_ID VARCHAR2(30)
  , NGB_PROD_TYPE VARCHAR2(30)
  , PROMOTION_PART_NUMBER VARCHAR2(50)
  , PRODUCT_ID VARCHAR2(30)
  , O2A_STATUS VARCHAR2(30)
  , PARENT_ITEM_ROW_ID VARCHAR2(15)
  , ROOT_ITEM_ROW_ID VARCHAR2(15)
  , CONTRACT_START_DATE VARCHAR2(25)
  , CONTRACT_END_DATE VARCHAR2(25)
  , LIST_PRICE VARCHAR2(30)
  , HARDWARE_ASSOCIATION_ID VARCHAR2(15)
)
TABLESPACE TELS_TRANSFORMS;

CREATE UNIQUE INDEX TELS_RCRM_PRESTAGE_LINE_PK ON TELS_RCRM_PRESTAGE_LINE
(FILENAME,BATCHPROCESSDATE,RECORDNUMBER)
TABLESPACE TELS_TRANSFORMS;

ALTER TABLE TELS_RCRM_PRESTAGE_LINE ADD (
  CONSTRAINT TELS_RCRM_PRESTAGE_LINE_PK
  PRIMARY KEY
  (FILENAME,BATCHPROCESSDATE,RECORDNUMBER)
  USING INDEX TELS_RCRM_PRESTAGE_LINE_PK);

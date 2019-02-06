DROP TABLE TELS_RCRM_RELEASE_ORDERS;

CREATE TABLE TELS_RCRM_RELEASE_ORDERS (
    REC_TYPE                      VARCHAR2(30 BYTE),
    FILENAME                      VARCHAR2(255 BYTE),
    BATCHPROCESSDATE              DATE,
    RECORDNUMBER                  NUMBER(15,0),
    IS_FILTERED                   NUMBER(1,0),
    ORDER_NUMBER                  VARCHAR2(30 BYTE),
    BILLING_ACCOUNT               VARCHAR2(100 BYTE),
    CUSTOMER_LAST_NAME            VARCHAR2(100 BYTE),
    CUSTOMER_FIRST_NAME           VARCHAR2(50 BYTE),
    ORDER_TYPE                    VARCHAR2(50 BYTE),
    ORDER_SUB_TYPE                VARCHAR2(30 BYTE),
    CREATED_DATE                  VARCHAR2(25 BYTE),
    PARTNER_CODE                  VARCHAR2(30 BYTE),
    CAMPAIGN_NAME                 VARCHAR2(100 BYTE),
    CAMPAIGN_NUMBER               VARCHAR2(30 BYTE),
    CAMPAIGN_TYPE                 VARCHAR2(30 BYTE),
    CHANNEL_TYPE                  VARCHAR2(30 BYTE),
    CAMPAIGN_START_DATE           VARCHAR2(25 BYTE),
    BUSINESS_UNIT                 VARCHAR2(1 BYTE),
    SALES_FORCE_ID                VARCHAR2(30 BYTE),
    CUSTOMER_ID                   VARCHAR2(15 BYTE),
    ORDER_REVISION_NUMBER         VARCHAR2(30 BYTE),
    SUBMITTED_DATE                VARCHAR2(25 BYTE),
    STATUS_HEADER                 VARCHAR2(30 BYTE),
    REASON_CODE                   VARCHAR2(30 BYTE),
    COMMISSION_TRANSACTION_TYPE   VARCHAR2(15 BYTE),
    SOURCE_SYSTEM                 VARCHAR2(8 BYTE),
    ROW_ID                        VARCHAR2(15 BYTE),
    PRODUCT                       VARCHAR2(100 BYTE),
    PART_NUMBER                   VARCHAR2(50 BYTE),
    ACTION_CODE                   VARCHAR2(30 BYTE),
    TRANSFER_TYPE                 VARCHAR2(30 BYTE),
    EVENT_SOURCE                  VARCHAR2(100 BYTE),
    PROD_PROM_ID                  VARCHAR2(15 BYTE),
    PROVISIONED_DATE              VARCHAR2(25 BYTE),
    NET_PRICE                     VARCHAR2(30 BYTE),
    COMMISSION_PRODUCT_TYPE       VARCHAR2(50 BYTE),
    COMMISSIONABLE                VARCHAR2(30 BYTE),
    STATUS_ORDER_LINE_ITEM        VARCHAR2(30 BYTE),
    ORIGINAL_ORDER_NUMBER         VARCHAR2(30 BYTE),
    HARDWARE_SUPPLIED_FLAG        VARCHAR2(1 BYTE),
    SUB_ACTION_CODE               VARCHAR2(30 BYTE),
    PROMOTION_INTEGRATION_ID      VARCHAR2(30 BYTE),
    NGB_PROD_TYPE                 VARCHAR2(30 BYTE),
    PROMOTION_PART_NUMBER         VARCHAR2(50 BYTE),
    PRODUCT_ID                    VARCHAR2(30 BYTE),
    O2A_STATUS                    VARCHAR2(30 BYTE),
    PARENT_ITEM_ROW_ID            VARCHAR2(15 BYTE),
    ROOT_ITEM_ROW_ID              VARCHAR2(15 BYTE),
    CONTRACT_START_DATE           VARCHAR2(25 BYTE),
    CONTRACT_END_DATE             VARCHAR2(25 BYTE),
    LIST_PRICE                    VARCHAR2(30 BYTE),
    HARDWARE_ASSOCIATION_ID       VARCHAR2(15 BYTE),
    EFFECTIVE_DATE                VARCHAR2(25 BYTE)
);
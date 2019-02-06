CREATE OR REPLACE FORCE VIEW TELS_RCRM_ORDERS_VIEW (
    REC_TYPE,
    FILENAME,
    BATCHPROCESSDATE,
    RECORDNUMBER,
    IS_FILTERED,
    ORDER_NUMBER,
    BILLING_ACCOUNT,
    CUSTOMER_LAST_NAME,
    CUSTOMER_FIRST_NAME,
    ORDER_TYPE,
    ORDER_SUB_TYPE,
    CREATED_DATE,
    PARTNER_CODE,
    CAMPAIGN_NAME,
    CAMPAIGN_NUMBER,
    CAMPAIGN_TYPE,
    CHANNEL_TYPE,
    CAMPAIGN_START_DATE,
    BUSINESS_UNIT,
    SALES_FORCE_ID,
    CUSTOMER_ID,
    ORDER_REVISION_NUMBER,
    SUBMITTED_DATE,
    STATUS_HEADER,
    REASON_CODE,
    COMMISSION_TRANSACTION_TYPE,
    SOURCE_SYSTEM,
    ROW_ID,
    PRODUCT,
    PART_NUMBER,
    ACTION_CODE,
    TRANSFER_TYPE,
    EVENT_SOURCE,
    PROD_PROM_ID,
    PROVISIONED_DATE,
    NET_PRICE,
    COMMISSION_PRODUCT_TYPE,
    COMMISSIONABLE,
    STATUS_ORDER_LINE_ITEM,
    ORIGINAL_ORDER_NUMBER,
    HARDWARE_SUPPLIED_FLAG,
    SUB_ACTION_CODE,
    PROMOTION_INTEGRATION_ID,
    NGB_PROD_TYPE,
    PROMOTION_PART_NUMBER,
    PRODUCT_ID,
    O2A_STATUS,
    PARENT_ITEM_ROW_ID,
    ROOT_ITEM_ROW_ID,
    CONTRACT_START_DATE,
    CONTRACT_END_DATE,
    LIST_PRICE,
    HARDWARE_ASSOCIATION_ID,
    EFFECTIVE_DATE
) AS
    SELECT
        d.REC_TYPE,
        d.FILENAME,
        d.BATCHPROCESSDATE,
        d.RECORDNUMBER,
        d.IS_FILTERED,
        d.ORDER_NUMBER,
        d.BILLING_ACCOUNT,
        d.CUSTOMER_LAST_NAME,
        d.CUSTOMER_FIRST_NAME,
        d.ORDER_TYPE,
        d.ORDER_SUB_TYPE,
        d.CREATED_DATE,
        d.PARTNER_CODE,
        d.CAMPAIGN_NAME,
        d.CAMPAIGN_NUMBER,
        d.CAMPAIGN_TYPE,
        d.CHANNEL_TYPE,
        d.CAMPAIGN_START_DATE,
        d.BUSINESS_UNIT,
        d.SALES_FORCE_ID,
        d.CUSTOMER_ID,
        d.ORDER_REVISION_NUMBER,
        d.SUBMITTED_DATE,
        d.STATUS_HEADER,
        d.REASON_CODE,
        d.COMMISSION_TRANSACTION_TYPE,
        d.SOURCE_SYSTEM,
        d.ROW_ID,
        d.PRODUCT,
        d.PART_NUMBER,
        d.ACTION_CODE,
        d.TRANSFER_TYPE,
        d.EVENT_SOURCE,
        d.PROD_PROM_ID,
        d.PROVISIONED_DATE,
        d.NET_PRICE,
        d.COMMISSION_PRODUCT_TYPE,
        d.COMMISSIONABLE,
        d.STATUS_ORDER_LINE_ITEM,
        d.ORIGINAL_ORDER_NUMBER,
        d.HARDWARE_SUPPLIED_FLAG,
        d.SUB_ACTION_CODE,
        d.PROMOTION_INTEGRATION_ID,
        d.NGB_PROD_TYPE,
        d.PROMOTION_PART_NUMBER,
        d.PRODUCT_ID,
        d.O2A_STATUS,
        d.PARENT_ITEM_ROW_ID,
        d.ROOT_ITEM_ROW_ID,
        d.CONTRACT_START_DATE,
        d.CONTRACT_END_DATE,
        d.LIST_PRICE,
        d.HARDWARE_ASSOCIATION_ID,
        d.EFFECTIVE_DATE
    FROM
        TELS_RCRM_MV_LINE_ITEM d
--    WHERE NOT EXISTS(SELECT 1 FROM TELS_RCRM_HOLD_RECORDS h WHERE h.ROW_ID = d.ROW_ID) --Uncomment this line to prevent hold records from flowing forward
    UNION ALL
    SELECT
        REC_TYPE,
        FILENAME,
        BATCHPROCESSDATE,
        RECORDNUMBER,
        IS_FILTERED,
        ORDER_NUMBER,
        BILLING_ACCOUNT,
        CUSTOMER_LAST_NAME,
        CUSTOMER_FIRST_NAME,
        ORDER_TYPE,
        ORDER_SUB_TYPE,
        CREATED_DATE,
        PARTNER_CODE,
        CAMPAIGN_NAME,
        CAMPAIGN_NUMBER,
        CAMPAIGN_TYPE,
        CHANNEL_TYPE,
        CAMPAIGN_START_DATE,
        BUSINESS_UNIT,
        SALES_FORCE_ID,
        CUSTOMER_ID,
        ORDER_REVISION_NUMBER,
        SUBMITTED_DATE,
        STATUS_HEADER,
        REASON_CODE,
        COMMISSION_TRANSACTION_TYPE,
        SOURCE_SYSTEM,
        ROW_ID,
        PRODUCT,
        PART_NUMBER,
        ACTION_CODE,
        TRANSFER_TYPE,
        EVENT_SOURCE,
        PROD_PROM_ID,
        PROVISIONED_DATE,
        NET_PRICE,
        COMMISSION_PRODUCT_TYPE,
        COMMISSIONABLE,
        STATUS_ORDER_LINE_ITEM,
        ORIGINAL_ORDER_NUMBER,
        HARDWARE_SUPPLIED_FLAG,
        SUB_ACTION_CODE,
        PROMOTION_INTEGRATION_ID,
        NGB_PROD_TYPE,
        PROMOTION_PART_NUMBER,
        PRODUCT_ID,
        O2A_STATUS,
        PARENT_ITEM_ROW_ID,
        ROOT_ITEM_ROW_ID,
        CONTRACT_START_DATE,
        CONTRACT_END_DATE,
        LIST_PRICE,
        HARDWARE_ASSOCIATION_ID,
        EFFECTIVE_DATE
    FROM
        TELS_RCRM_RELEASE_HOLD_RECORDS;
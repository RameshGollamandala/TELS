WITH MOLI AS(
    SELECT
        d.FILENAME, d.BATCHPROCESSDATE, d.RECORDNUMBER, d.IS_FILTERED, d.ORDER_NUMBER, d.BILLING_ACCOUNT, d.CUSTOMER_LAST_NAME, d.CUSTOMER_FIRST_NAME, d.ORDER_TYPE, d.ORDER_SUB_TYPE, d.CREATED_DATE
      , d.PARTNER_CODE, d.CAMPAIGN_NAME, d.CAMPAIGN_NUMBER, d.CAMPAIGN_TYPE, d.CHANNEL_TYPE, d.CAMPAIGN_START_DATE, d.BUSINESS_UNIT, d.SALES_FORCE_ID, d.CUSTOMER_ID, d.ORDER_REVISION_NUMBER, d.SUBMITTED_DATE
      , d.STATUS_HEADER, d.REASON_CODE, d.COMMISSION_TRANSACTION_TYPE, d.SOURCE_SYSTEM, d.ROW_ID, d.PRODUCT, d.PART_NUMBER, d.ACTION_CODE, d.TRANSFER_TYPE, d.EVENT_SOURCE, d.PROD_PROM_ID, d.PROVISIONED_DATE
      , d.NET_PRICE, d.COMMISSION_PRODUCT_TYPE, d.COMMISSIONABLE, d.STATUS_ORDER_LINE_ITEM, d.ORIGINAL_ORDER_NUMBER, d.HARDWARE_SUPPLIED_FLAG, d.SUB_ACTION_CODE, d.PROMOTION_INTEGRATION_ID, d.NGB_PROD_TYPE
      , d.PROMOTION_PART_NUMBER, d.PRODUCT_ID, d.O2A_STATUS, d.PARENT_ITEM_ROW_ID, d.ROOT_ITEM_ROW_ID, d.CONTRACT_START_DATE, d.CONTRACT_END_DATE, d.LIST_PRICE, d.HARDWARE_ASSOCIATION_ID
      , d.ATTRIBUTE_ROW_ID, d.ATTRIBUTE_ACTION_CODE, d.ATTRIBUTE_DISPLAY_NAME, d.ATTRIBUTE_VALUE 
    FROM TELS_PRESTAGE_RCRM d
    WHERE 
      d.NGB_PROD_TYPE IN('MOC','Shared')
      AND d.COMMISSION_PRODUCT_TYPE <> 'Commissions Fixed Hardware'
      AND NOT EXISTS (
          SELECT 1 FROM TELS_PRESTAGE_RCRM ps
          WHERE ps.ORDER_NUMBER = d.ORDER_NUMBER
            AND ps.PROMOTION_INTEGRATION_ID = d.PROMOTION_INTEGRATION_ID
            AND ps.NGB_PROD_TYPE = 'MOC'
            AND ps.COMMISSION_PRODUCT_TYPE = 'Commissions Main Plan'
            AND ps.STATUS_HEADER = d.STATUS_HEADER)
      AND EXISTS (
          SELECT 1 FROM TELS_PRESTAGE_RCRM ps
          WHERE ps.ORDER_NUMBER = d.ORDER_NUMBER
            AND ps.PROMOTION_INTEGRATION_ID = d.PROMOTION_INTEGRATION_ID
            AND ps.NGB_PROD_TYPE = 'MOC')
      AND NOT EXISTS (
          SELECT 1 FROM TELS_PRESTAGE_RCRM ps
          WHERE ps.ORDER_NUMBER = d.ORDER_NUMBER
            AND ps.PROMOTION_INTEGRATION_ID = d.PROMOTION_INTEGRATION_ID
            AND ps.NGB_PROD_TYPE = 'MOC'
            AND ps.COMMISSION_PRODUCT_TYPE = 'Commissions Standalone')
      AND NOT EXISTS ( 
          SELECT 1 FROM TELS_PRESTAGE_RCRM ps
          WHERE ps.ORDER_NUMBER = d.ORDER_NUMBER
            AND ps.PROMOTION_INTEGRATION_ID = d.PROMOTION_INTEGRATION_ID
            AND ps.NGB_PROD_TYPE = 'MOC'
            AND ps.SUB_ACTION_CODE IN('Move-Add','Transition-Add'))
      AND NOT EXISTS ( /*Exclude records with errors*/
          SELECT 1 FROM TELS_CORE_PRESTAGEERROR pe
          WHERE pe.FILENAME = d.FILENAME
            AND pe.RECORDNUMBER = d.RECORDNUMBER
            AND pe.ISWARNINGONLY = 0)
), OLI AS(
    SELECT         
      o.FILENAME, o.BATCHPROCESSDATE, o.RECORDNUMBER, o.IS_FILTERED, o.ORDER_NUMBER, o.BILLING_ACCOUNT, o.CUSTOMER_LAST_NAME, o.CUSTOMER_FIRST_NAME, o.ORDER_TYPE, o.ORDER_SUB_TYPE, o.CREATED_DATE
      , o.PARTNER_CODE, o.CAMPAIGN_NAME, o.CAMPAIGN_NUMBER, o.CAMPAIGN_TYPE, o.CHANNEL_TYPE, o.CAMPAIGN_START_DATE, o.BUSINESS_UNIT, o.SALES_FORCE_ID, o.CUSTOMER_ID, o.ORDER_REVISION_NUMBER, o.SUBMITTED_DATE
      , o.STATUS_HEADER, o.REASON_CODE, o.COMMISSION_TRANSACTION_TYPE, o.SOURCE_SYSTEM, o.ROW_ID, o.PRODUCT, o.PART_NUMBER, o.ACTION_CODE, o.TRANSFER_TYPE, o.EVENT_SOURCE, o.PROD_PROM_ID, o.PROVISIONED_DATE
      , o.NET_PRICE, o.COMMISSION_PRODUCT_TYPE, o.COMMISSIONABLE, o.STATUS_ORDER_LINE_ITEM, o.ORIGINAL_ORDER_NUMBER, o.HARDWARE_SUPPLIED_FLAG, o.SUB_ACTION_CODE, o.PROMOTION_INTEGRATION_ID, o.NGB_PROD_TYPE
      , o.PROMOTION_PART_NUMBER, o.PRODUCT_ID, o.O2A_STATUS, o.PARENT_ITEM_ROW_ID, o.ROOT_ITEM_ROW_ID, o.CONTRACT_START_DATE, o.CONTRACT_END_DATE, o.LIST_PRICE, o.HARDWARE_ASSOCIATION_ID
      , o.ATTRIBUTE_ROW_ID, o.ATTRIBUTE_ACTION_CODE, o.ATTRIBUTE_DISPLAY_NAME, o.ATTRIBUTE_VALUE 
    FROM TELS_PRESTAGE_RCRM o
    JOIN MOLI m ON
      m.ROW_ID = o.ROOT_ITEM_ROW_ID
      AND m.STATUS_HEADER = o.STATUS_HEADER
    WHERE NOT EXISTS ( /*Exclude records with errors*/
          SELECT 1 FROM TELS_CORE_PRESTAGEERROR pe
          WHERE pe.FILENAME = o.FILENAME
            AND pe.RECORDNUMBER = o.RECORDNUMBER
            AND pe.ISWARNINGONLY = 0)
)
SELECT m.* FROM MOLI m
UNION ALL
SELECT o.* FROM OLI o;
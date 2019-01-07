DROP VIEW TELS_RCRM_VW_LINE_ITEM;

CREATE OR REPLACE FORCE VIEW TELS_RCRM_VW_LINE_ITEM
(
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
)
AS
WITH
  /*-- ROOT TYPES --*/
    MOLI AS ( SELECT M.* FROM TELS_RCRM_MV_MOLI_ROOT M )
  , OLI AS ( SELECT O.* FROM TELS_RCRM_MV_OLI_ROOT O )

  /*-- SIMPLE TYPES --*/
  , CONVERT_PLAN_OLI AS ( SELECT O.* FROM TELS_RCRM_MV_OLI_ROOT O
      WHERE O.COMMISSION_PRODUCT_TYPE = 'Commissions Convert Plan'
      AND O.ACTION_CODE IN('Add','-','Update')
    )
  , VAS_OLI AS ( SELECT O.* FROM TELS_RCRM_MV_OLI_ROOT O
      WHERE O.COMMISSION_PRODUCT_TYPE IN ('Commissions VAS')
      AND O.ACTION_CODE IN ('Add','-','Update')
      UNION
      SELECT O.* FROM CONVERT_PLAN_OLI O 
    )
  , DARO_OLI AS (
      SELECT O.* FROM TELS_RCRM_MV_OLI_ROOT O
      WHERE O.COMMISSION_PRODUCT_TYPE = 'Commissions DARO'
      AND O.PART_NUMBER = 'XC001007226'
    )
  , DARO_MOLI AS (
      SELECT M.* FROM TELS_RCRM_MV_MOLI_ROOT M
      WHERE M.COMMISSION_PRODUCT_TYPE = 'Commissions DARO'
    )
  , FHW_OLI AS ( SELECT O.* FROM TELS_RCRM_MV_OLI_ROOT O
      WHERE O.COMMISSION_PRODUCT_TYPE = 'Commissions Fixed Hardware'
      AND O.ACTION_CODE = 'Add'
      UNION
      SELECT M.* FROM TELS_RCRM_MV_MOLI_ROOT M
      WHERE M.COMMISSION_PRODUCT_TYPE = 'Commissions Fixed Hardware'
      AND M.ACTION_CODE = 'Add'
    )
  , MP_OLI AS ( SELECT O.* FROM TELS_RCRM_MV_OLI_ROOT O
      WHERE O.COMMISSION_PRODUCT_TYPE = 'Commissions Main Plan'
      AND O.ACTION_CODE IN ('Add','Update','-')
    )
  , MP_DEL_OLI AS ( SELECT O.* FROM TELS_RCRM_MV_OLI_ROOT O
      WHERE O.COMMISSION_PRODUCT_TYPE = 'Commissions Main Plan'
      AND O.ACTION_CODE = 'Delete'
      AND EXISTS ( SELECT 1 FROM TELS_RCRM_MV_ATTRIBUTE ATT
                   WHERE ATT.ROW_ID = O.ROW_ID
                     AND ATT.FILENAME = O.FILENAME
                     AND ATT.ATTRIBUTE_ACTION_CODE = 'Delete'
                     )
    ) 
  , SIM_OLI AS ( SELECT O.* FROM TELS_RCRM_MV_OLI_ROOT O
      WHERE O.COMMISSION_PRODUCT_TYPE = 'Commissions SIM'
    )
  , HW_OLI AS ( SELECT O.* FROM TELS_RCRM_MV_OLI_ROOT O
      WHERE O.COMMISSION_PRODUCT_TYPE = 'Commissions Hardware'
      AND O.ACTION_CODE = 'Add'
--      UNION 
--      SELECT M.* FROM TELS_RCRM_MV_MOLI_ROOT M
--      WHERE M.COMMISSION_PRODUCT_TYPE = 'Commissions Hardware'
--      AND M.ACTION_CODE = 'Add'
    )
  , CONTRACT_OLI AS ( SELECT O.* FROM TELS_RCRM_MV_OLI_ROOT O
      WHERE O.COMMISSION_PRODUCT_TYPE = 'Commissions Contract'
    )
  , MAIN_CONTRACT_OLI AS ( SELECT O.* FROM TELS_RCRM_MV_OLI_ROOT O
      WHERE O.COMMISSION_PRODUCT_TYPE = 'Commissions Main Contract'
    )

  , ACCESS_TYPE_OLI AS ( SELECT O.* FROM TELS_RCRM_MV_OLI_ROOT O
      WHERE O.COMMISSION_PRODUCT_TYPE = 'Commissions Access Type'
    )
  , SERVICE_MOLI AS ( SELECT M.* FROM TELS_RCRM_MV_MOLI_ROOT M
      WHERE M.COMMISSION_PRODUCT_TYPE = 'Commissions Service'
        AND M.ACTION_CODE IN('Add','-','Update')
    )

  /*-- COMPOSITE TYPES --*/
  , VAS_ASSOC_MOLI AS ( SELECT M.* FROM TELS_RCRM_MV_MOLI_ROOT M
      WHERE EXISTS ( SELECT 1 FROM VAS_OLI VO
                       WHERE VO.ROOT_ITEM_ROW_ID = M.ROW_ID
                       AND VO.STATUS_HEADER = M.STATUS_HEADER
                       AND VO.ORDER_NUMBER = M.ORDER_NUMBER
                       AND VO.FILENAME = M.FILENAME
                       )
    )
  , VAS_ASSOC_CONTRACT_OLI AS ( SELECT CO.* FROM CONTRACT_OLI CO
      JOIN VAS_OLI VO
        ON VO.ROOT_ITEM_ROW_ID = CO.ROOT_ITEM_ROW_ID
        AND VO.STATUS_HEADER = CO.STATUS_HEADER
        AND VO.ORDER_NUMBER = CO.ORDER_NUMBER
        AND VO.FILENAME = CO.FILENAME
      WHERE CO.ACTION_CODE IN ('Add', '-')
      AND NOT EXISTS ( SELECT 1 FROM TELS_RCRM_MV_ATTRIBUTE ATT
                         WHERE ATT.ROW_ID = CO.ROW_ID
                         AND ATT.FILENAME = CO.FILENAME
                         AND ATT.ATTRIBUTE_ACTION_CODE = 'Delete'
                         )
      AND EXISTS ( SELECT 1 FROM TELS_RCRM_MV_ATTRIBUTE ATT
                     WHERE ATT.ROW_ID = CO.ROW_ID
                     AND ATT.FILENAME = CO.FILENAME
                     AND ATT.ATTRIBUTE_DISPLAY_NAME = 'Plan ID'
                     AND ATT.ATTRIBUTE_VALUE = VO.PART_NUMBER
                     )
    )
  , HW_ASSOC_CONTRACT_OLI AS ( SELECT CO.* FROM CONTRACT_OLI CO
      JOIN HW_OLI HO
        ON HO.ROOT_ITEM_ROW_ID = CO.ROOT_ITEM_ROW_ID
        AND HO.STATUS_HEADER = CO.STATUS_HEADER
        AND HO.ORDER_NUMBER = CO.ORDER_NUMBER
        AND HO.FILENAME = CO.FILENAME
      WHERE CO.ACTION_CODE IN ('Add', '-')
      AND NOT EXISTS ( SELECT 1 FROM TELS_RCRM_MV_ATTRIBUTE ATT
                         WHERE ATT.ROW_ID = CO.ROW_ID
                         AND ATT.FILENAME = CO.FILENAME
                         AND ATT.ATTRIBUTE_ACTION_CODE = 'Delete'
                         )
      AND EXISTS ( SELECT 1 FROM TELS_RCRM_MV_ATTRIBUTE ATT
                     WHERE ATT.ROW_ID = CO.ROW_ID
                     AND ATT.FILENAME = CO.FILENAME
                     AND ATT.ATTRIBUTE_VALUE = HO.PART_NUMBER
                     )
    )
  , HW_ASSOC_PLAN_OLI AS ( SELECT O.* FROM TELS_RCRM_MV_OLI_ROOT O
      WHERE EXISTS ( SELECT 1 FROM HW_OLI HO
                       WHERE HO.ROOT_ITEM_ROW_ID = O.ROOT_ITEM_ROW_ID
                       AND HO.STATUS_HEADER = O.STATUS_HEADER
                       AND HO.ORDER_NUMBER = O.ORDER_NUMBER
                       AND HO.FILENAME = O.FILENAME
                       )
      AND O.COMMISSION_PRODUCT_TYPE = 'Commissions Main Plan'
      AND O.ACTION_CODE IN ('Add','-','Update')
    )
  , HW_ASSOC_MRO_OLI AS ( SELECT O.* FROM TELS_RCRM_MV_OLI_ROOT O
      WHERE EXISTS ( SELECT 1 FROM HW_OLI HO
                       WHERE HO.ROOT_ITEM_ROW_ID = O.ROOT_ITEM_ROW_ID
                       AND HO.STATUS_HEADER = O.STATUS_HEADER
                       AND HO.ORDER_NUMBER = O.ORDER_NUMBER
                       AND HO.FILENAME = O.FILENAME
                       )
      AND O.COMMISSION_PRODUCT_TYPE = 'Commissions MRO'
    )
  , FHW_ASSOC_MOLI AS ( SELECT M.* FROM TELS_RCRM_MV_MOLI_ROOT M
      WHERE EXISTS ( SELECT 1 FROM FHW_OLI FO
                       WHERE FO.ROOT_ITEM_ROW_ID = M.ROW_ID
                       AND FO.ORDER_NUMBER = M.ORDER_NUMBER
                       AND FO.STATUS_HEADER = M.STATUS_HEADER
                       AND FO.FILENAME = M.FILENAME
                       )
    )
  , HW_ASSOC_MOLI AS ( SELECT M.* FROM TELS_RCRM_MV_MOLI_ROOT M
      WHERE EXISTS ( SELECT 1 FROM HW_OLI HO
                       WHERE HO.ROOT_ITEM_ROW_ID = M.ROW_ID
                       AND HO.ORDER_NUMBER = M.ORDER_NUMBER
                       AND HO.STATUS_HEADER = M.STATUS_HEADER
                       AND HO.FILENAME = M.FILENAME
                       )
    )
  , MP_ASSOC_MOLI AS ( SELECT M.* FROM TELS_RCRM_MV_MOLI_ROOT M
      WHERE EXISTS ( SELECT 1 FROM MP_OLI MO
                       WHERE MO.ROOT_ITEM_ROW_ID = M.ROW_ID
                       AND MO.ORDER_NUMBER = M.ORDER_NUMBER
                       AND MO.STATUS_HEADER = M.STATUS_HEADER
                       AND MO.FILENAME = M.FILENAME
                       )
    )
  , FHW_ASSOC_VAS_OLI AS (
      SELECT VO.* FROM VAS_OLI VO
      WHERE EXISTS (
        SELECT 1
        FROM FHW_ASSOC_MOLI FAM
        JOIN VAS_ASSOC_MOLI VAM
          ON VAM.PROMOTION_INTEGRATION_ID = FAM.PROMOTION_INTEGRATION_ID
        WHERE FAM.ROW_ID = VO.ROOT_ITEM_ROW_ID
          AND FAM.STATUS_HEADER = VO.STATUS_HEADER
          AND FAM.ORDER_NUMBER = VO.ORDER_NUMBER
          AND FAM.FILENAME = VO.FILENAME
          AND VAM.ROW_ID = VO.ROOT_ITEM_ROW_ID
          AND VAM.STATUS_HEADER = VO.STATUS_HEADER
          AND VAM.ORDER_NUMBER = VO.ORDER_NUMBER
          AND VAM.FILENAME = VO.FILENAME
        )
      AND EXISTS (
        SELECT 1 FROM FHW_OLI FO
        WHERE FO.ROOT_ITEM_ROW_ID = VO.ROOT_ITEM_ROW_ID
        AND FO.ORDER_NUMBER = VO.ORDER_NUMBER
        AND FO.STATUS_HEADER = VO.STATUS_HEADER
        AND FO.FILENAME = VO.FILENAME
        )
    )
  , VAS_ASSOC_FHW_OLI AS ( SELECT FO.* FROM FHW_OLI FO
      WHERE (1=1)
      AND EXISTS (
        SELECT 1
        FROM FHW_ASSOC_MOLI FAM
        JOIN VAS_ASSOC_MOLI VAM
          ON VAM.PROMOTION_INTEGRATION_ID = FAM.PROMOTION_INTEGRATION_ID
        WHERE FAM.ROW_ID = FO.ROOT_ITEM_ROW_ID
          AND FAM.STATUS_HEADER = FO.STATUS_HEADER
          AND FAM.ORDER_NUMBER = FO.ORDER_NUMBER
          AND FAM.FILENAME = FO.FILENAME
          AND VAM.ROW_ID = FO.ROOT_ITEM_ROW_ID
          AND VAM.STATUS_HEADER = FO.STATUS_HEADER
          AND VAM.ORDER_NUMBER = FO.ORDER_NUMBER
          AND VAM.FILENAME = FO.FILENAME
        )
      AND EXISTS (
        SELECT 1 FROM VAS_OLI VO
        WHERE VO.ROOT_ITEM_ROW_ID = FO.ROOT_ITEM_ROW_ID
          AND VO.ORDER_NUMBER = FO.ORDER_NUMBER
          AND VO.STATUS_HEADER = FO.STATUS_HEADER
          AND VO.FILENAME = FO.FILENAME
        )
    )
  , VAS_ASSOC_OFFER_MOLI AS ( SELECT M.* FROM TELS_RCRM_MV_MOLI_ROOT M
      WHERE EXISTS ( SELECT 1 FROM VAS_ASSOC_MOLI VM
                       WHERE VM.PROMOTION_INTEGRATION_ID = M.PROMOTION_INTEGRATION_ID
                       AND VM.ORDER_NUMBER = M.ORDER_NUMBER
                       AND VM.STATUS_HEADER = M.STATUS_HEADER
                       AND VM.FILENAME = M.FILENAME
                       )
      AND M.COMMISSION_PRODUCT_TYPE IN ('Commissions Bundle','Commissions Standalone')
    )
  , MP_ASSOC_CONVERT_PLAN_OLI AS ( SELECT CO.* FROM CONVERT_PLAN_OLI CO
      WHERE EXISTS ( SELECT 1 FROM MP_OLI MO
                       WHERE MO.ROOT_ITEM_ROW_ID = CO.ROOT_ITEM_ROW_ID
                       AND MO.ORDER_NUMBER = CO.ORDER_NUMBER
                       AND MO.STATUS_HEADER = CO.STATUS_HEADER
                       AND MO.FILENAME = CO.FILENAME
                       )
      AND CO.ORDER_TYPE IN ('Add New Service','Modify')
    )
  , MP_ASSOC_SIM_OLI AS ( SELECT SO.* FROM SIM_OLI SO
      WHERE EXISTS ( SELECT 1 FROM MP_OLI MO
                       WHERE MO.ROOT_ITEM_ROW_ID = SO.ROOT_ITEM_ROW_ID
                       AND MO.ORDER_NUMBER = SO.ORDER_NUMBER
                       AND MO.STATUS_HEADER = SO.STATUS_HEADER
                       AND MO.FILENAME = SO.FILENAME
                       )
      AND SO.ACTION_CODE <> 'Delete'
      AND NOT EXISTS ( SELECT 1 FROM TELS_RCRM_MV_ATTRIBUTE ATT
                         WHERE ATT.ROW_ID = SO.ROW_ID
                         AND ATT.FILENAME = SO.FILENAME
                         AND ATT.ATTRIBUTE_ACTION_CODE = 'Delete')
    )
  , MP_ASSOC_MAIN_CONT_ADD_OLI AS ( SELECT MCO.* FROM MAIN_CONTRACT_OLI MCO
      WHERE EXISTS ( SELECT 1 FROM MP_OLI MO
                       WHERE MO.ROOT_ITEM_ROW_ID = MCO.ROOT_ITEM_ROW_ID
                         AND MO.ORDER_NUMBER     = MCO.ORDER_NUMBER
                         AND MO.STATUS_HEADER    = MCO.STATUS_HEADER
                         AND MO.FILENAME         = MCO.FILENAME
                       )
      AND MCO.ACTION_CODE IN ('Add','-')
      AND NOT EXISTS ( SELECT 1 FROM TELS_RCRM_MV_ATTRIBUTE ATT
                         WHERE ATT.ROW_ID   = MCO.ROW_ID
                           AND ATT.FILENAME = MCO.FILENAME
                           AND ATT.ATTRIBUTE_ACTION_CODE = 'Delete')
    )
  , MP_ASSOC_MAIN_CONT_DEL_OLI AS ( SELECT MCO.* FROM MAIN_CONTRACT_OLI MCO
      WHERE EXISTS ( SELECT 1 FROM MP_OLI MO
                       WHERE MO.ROOT_ITEM_ROW_ID = MCO.ROOT_ITEM_ROW_ID
                         AND MO.ORDER_NUMBER     = MCO.ORDER_NUMBER
                         AND MO.STATUS_HEADER    = MCO.STATUS_HEADER
                         AND MO.FILENAME         = MCO.FILENAME
                       )
      AND MCO.ACTION_CODE = 'Delete'
      AND EXISTS ( SELECT 1 FROM TELS_RCRM_MV_ATTRIBUTE ATT
                     WHERE ATT.ROW_ID   = MCO.ROW_ID
                       AND ATT.FILENAME = MCO.FILENAME
                       AND ATT.ATTRIBUTE_ACTION_CODE = 'Delete')
    )
  , MP_ASSOC_MAIN_PLAN_DEL_OLI AS ( SELECT DO.* FROM MP_DEL_OLI DO
      WHERE EXISTS ( SELECT 1 FROM MP_OLI MO
                       WHERE MO.ROOT_ITEM_ROW_ID = DO.ROOT_ITEM_ROW_ID
                         AND MO.ORDER_NUMBER     = DO.ORDER_NUMBER
                         AND MO.STATUS_HEADER    = DO.STATUS_HEADER
                         AND MO.FILENAME         = DO.FILENAME
                       )
    )
  , MP_ASSOC_CONTRACT_ADD_OLI AS ( SELECT CO.* FROM CONTRACT_OLI CO
      WHERE EXISTS ( SELECT 1 FROM MP_OLI MO
                       WHERE MO.ROOT_ITEM_ROW_ID = CO.ROOT_ITEM_ROW_ID
                         AND MO.ORDER_NUMBER     = CO.ORDER_NUMBER
                         AND MO.STATUS_HEADER    = CO.STATUS_HEADER
                         AND MO.FILENAME         = CO.FILENAME
                       )
      AND CO.ACTION_CODE IN ('Add','-')
      AND NOT EXISTS ( SELECT 1 FROM TELS_RCRM_MV_ATTRIBUTE ATT
                         WHERE ATT.ROW_ID   = CO.ROW_ID
                           AND ATT.FILENAME = CO.FILENAME
                           AND ATT.ATTRIBUTE_ACTION_CODE = 'Delete')
    )
  , MP_ASSOC_CONTRACT_DEL_OLI AS ( SELECT CO.* FROM CONTRACT_OLI CO
      WHERE EXISTS ( SELECT 1 FROM MP_OLI MO
                       WHERE MO.ROOT_ITEM_ROW_ID = CO.ROOT_ITEM_ROW_ID
                         AND MO.ORDER_NUMBER     = CO.ORDER_NUMBER
                         AND MO.STATUS_HEADER    = CO.STATUS_HEADER
                         AND MO.FILENAME         = CO.FILENAME
                       )
      AND CO.ACTION_CODE = 'Delete'
      AND EXISTS ( SELECT 1 FROM TELS_RCRM_MV_ATTRIBUTE ATT
                     WHERE ATT.ROW_ID   = CO.ROW_ID
                       AND ATT.FILENAME = CO.FILENAME
                       AND ATT.ATTRIBUTE_ACTION_CODE = 'Delete')
    )
  , MP_ASSOC_HW_OLI AS ( SELECT HO.* FROM HW_OLI HO
      WHERE EXISTS ( SELECT 1 FROM MP_OLI MO
                       WHERE MO.ROOT_ITEM_ROW_ID = HO.ROOT_ITEM_ROW_ID
                         AND MO.ORDER_NUMBER     = HO.ORDER_NUMBER
                         AND MO.STATUS_HEADER    = HO.STATUS_HEADER
                         AND MO.FILENAME         = HO.FILENAME
                       )
    )
  , MP_ASSOC_FHW_OLI AS ( SELECT FO.* FROM FHW_OLI FO
      WHERE (1=1)
      AND EXISTS (
        SELECT 1
        FROM FHW_ASSOC_MOLI FAM
        JOIN MP_ASSOC_MOLI MAM
          ON MAM.PROMOTION_INTEGRATION_ID = FAM.PROMOTION_INTEGRATION_ID
        WHERE FAM.ROW_ID = FO.ROOT_ITEM_ROW_ID
          AND FAM.STATUS_HEADER = FO.STATUS_HEADER
          AND FAM.ORDER_NUMBER = FO.ORDER_NUMBER
          AND FAM.FILENAME = FO.FILENAME
          AND MAM.ROW_ID = FO.ROOT_ITEM_ROW_ID
          AND MAM.STATUS_HEADER = FO.STATUS_HEADER
          AND MAM.ORDER_NUMBER = FO.ORDER_NUMBER
          AND MAM.FILENAME = FO.FILENAME
        )
      AND EXISTS (
        SELECT 1 FROM MP_OLI MO
        WHERE MO.ROOT_ITEM_ROW_ID = FO.ROOT_ITEM_ROW_ID
        AND MO.ORDER_NUMBER     = FO.ORDER_NUMBER
        AND MO.STATUS_HEADER    = FO.STATUS_HEADER
        AND MO.FILENAME         = FO.FILENAME
        )
    )
  , DARO_ASSOC_SERVICE_MOLI AS ( SELECT SM.* FROM SERVICE_MOLI SM
      WHERE EXISTS ( SELECT 1 FROM DARO_OLI DO
                       WHERE DO.ORDER_NUMBER     = SM.ORDER_NUMBER
                         AND DO.STATUS_HEADER    = SM.STATUS_HEADER
                         AND DO.FILENAME         = SM.FILENAME
                         AND DO.ROOT_ITEM_ROW_ID = SM.ROW_ID
                       )
    )
  , MP_ASSOC_SERVICE_MOLI AS ( SELECT SM.* FROM SERVICE_MOLI SM
      WHERE EXISTS ( SELECT 1 FROM MP_ASSOC_MOLI MO
                       WHERE MO.ORDER_NUMBER     = SM.ORDER_NUMBER
                         AND MO.STATUS_HEADER    = SM.STATUS_HEADER
                         AND MO.FILENAME         = SM.FILENAME
                         AND MO.PROMOTION_INTEGRATION_ID = SM.PROMOTION_INTEGRATION_ID
                       )
    )
  , SERVICE_ASSOC_ACCESS_TYPE_OLI AS ( SELECT ATO.* FROM ACCESS_TYPE_OLI ATO
      WHERE EXISTS ( SELECT 1 FROM SERVICE_MOLI SM
                       WHERE SM.ROOT_ITEM_ROW_ID = ATO.ROOT_ITEM_ROW_ID
                         AND SM.ORDER_NUMBER     = ATO.ORDER_NUMBER
                         AND SM.STATUS_HEADER    = ATO.STATUS_HEADER
                         AND SM.FILENAME         = ATO.FILENAME
                       )
      AND ATO.ACTION_CODE IN ('Add','-','Update')
    )
SELECT CAST('VAS_OLI' AS VARCHAR2(30)) AS "REC_TYPE", O.* FROM VAS_OLI O
  UNION ALL
SELECT CAST('DARO_OLI' AS VARCHAR2(30)) AS "REC_TYPE", O.* FROM DARO_OLI O
  UNION ALL
SELECT CAST('DARO_MOLI' AS VARCHAR2(30)) AS "REC_TYPE", M.* FROM DARO_MOLI M
  UNION ALL
SELECT CAST('FHW_OLI' AS VARCHAR2(30)) AS "REC_TYPE", O.* FROM FHW_OLI O
  UNION ALL
SELECT CAST('MP_OLI' AS VARCHAR2(30)) AS "REC_TYPE", O.* FROM MP_OLI O
  UNION ALL
SELECT CAST('MP_DEL_OLI' AS VARCHAR2(30)) AS "REC_TYPE", O.* FROM MP_DEL_OLI O
  UNION ALL
SELECT CAST('SIM_OLI' AS VARCHAR2(30)) AS "REC_TYPE", O.* FROM SIM_OLI O
  UNION ALL
SELECT CAST('HW_OLI' AS VARCHAR2(30)) AS "REC_TYPE", O.* FROM HW_OLI O
  UNION ALL
SELECT CAST('CONTRACT_OLI' AS VARCHAR2(30)) AS "REC_TYPE", O.* FROM CONTRACT_OLI O
  UNION ALL
SELECT CAST('MAIN_CONTRACT_OLI' AS VARCHAR2(30)) AS "REC_TYPE", O.* FROM MAIN_CONTRACT_OLI O
  UNION ALL
SELECT CAST('CONVERT_PLAN_OLI' AS VARCHAR2(30)) AS "REC_TYPE", O.* FROM CONVERT_PLAN_OLI O
  UNION ALL
SELECT CAST('ACCESS_TYPE_OLI' AS VARCHAR2(30)) AS "REC_TYPE", O.* FROM ACCESS_TYPE_OLI O
  UNION ALL
SELECT CAST('SERVICE_MOLI' AS VARCHAR2(30)) AS "REC_TYPE", M.* FROM SERVICE_MOLI M
  UNION ALL
SELECT CAST('VAS_ASSOC_MOLI' AS VARCHAR2(30)) AS "REC_TYPE", M.* FROM VAS_ASSOC_MOLI M
  UNION ALL
SELECT CAST('VAS_ASSOC_CONTRACT_OLI' AS VARCHAR2(30)) AS "REC_TYPE", O.* FROM VAS_ASSOC_CONTRACT_OLI O
  UNION ALL
SELECT CAST('HW_ASSOC_CONTRACT_OLI' AS VARCHAR2(30)) AS "REC_TYPE", O.* FROM HW_ASSOC_CONTRACT_OLI O
  UNION ALL
SELECT CAST('HW_ASSOC_PLAN_OLI' AS VARCHAR2(30)) AS "REC_TYPE", O.* FROM HW_ASSOC_PLAN_OLI O
  UNION ALL
SELECT CAST('HW_ASSOC_MRO_OLI' AS VARCHAR2(30)) AS "REC_TYPE", O.* FROM HW_ASSOC_MRO_OLI O
  UNION ALL
SELECT CAST('FHW_ASSOC_MOLI' AS VARCHAR2(30)) AS "REC_TYPE", M.* FROM FHW_ASSOC_MOLI M
  UNION ALL
SELECT CAST('HW_ASSOC_MOLI' AS VARCHAR2(30)) AS "REC_TYPE", M.* FROM HW_ASSOC_MOLI M
  UNION ALL
SELECT CAST('MP_ASSOC_MOLI' AS VARCHAR2(30)) AS "REC_TYPE", M.* FROM MP_ASSOC_MOLI M
  UNION ALL
SELECT CAST('FHW_ASSOC_VAS_OLI' AS VARCHAR2(30)) AS "REC_TYPE", O.* FROM FHW_ASSOC_VAS_OLI O
  UNION ALL
SELECT CAST('VAS_ASSOC_FHW_OLI' AS VARCHAR2(30)) AS "REC_TYPE", O.* FROM VAS_ASSOC_FHW_OLI O
  UNION ALL
SELECT CAST('VAS_ASSOC_OFFER_MOLI' AS VARCHAR2(30)) AS "REC_TYPE", M.* FROM VAS_ASSOC_OFFER_MOLI M
  UNION ALL
SELECT CAST('MP_ASSOC_CONVERT_PLAN_OLI' AS VARCHAR2(30)) AS "REC_TYPE", O.* FROM MP_ASSOC_CONVERT_PLAN_OLI O
  UNION ALL
SELECT CAST('MP_ASSOC_SIM_OLI' AS VARCHAR2(30)) AS "REC_TYPE", O.* FROM MP_ASSOC_SIM_OLI O
  UNION ALL
SELECT CAST('MP_ASSOC_MAIN_CONT_ADD_OLI' AS VARCHAR2(30)) AS "REC_TYPE", O.* FROM MP_ASSOC_MAIN_CONT_ADD_OLI O
  UNION ALL
SELECT CAST('MP_ASSOC_MAIN_CONT_DEL_OLI' AS VARCHAR2(30)) AS "REC_TYPE", O.* FROM MP_ASSOC_MAIN_CONT_DEL_OLI O
  UNION ALL
SELECT CAST('MP_ASSOC_MAIN_PLAN_DEL_OLI' AS VARCHAR2(30)) AS "REC_TYPE", O.* FROM MP_ASSOC_MAIN_PLAN_DEL_OLI O
  UNION ALL
SELECT CAST('MP_ASSOC_CONTRACT_ADD_OLI' AS VARCHAR2(30)) AS "REC_TYPE", O.* FROM MP_ASSOC_CONTRACT_ADD_OLI O
  UNION ALL
SELECT CAST('MP_ASSOC_CONTRACT_DEL_OLI' AS VARCHAR2(30)) AS "REC_TYPE", O.* FROM MP_ASSOC_CONTRACT_DEL_OLI O
  UNION ALL
SELECT CAST('MP_ASSOC_HW_OLI' AS VARCHAR2(30)) AS "REC_TYPE", O.* FROM MP_ASSOC_HW_OLI O
  UNION ALL
SELECT CAST('MP_ASSOC_FHW_OLI' AS VARCHAR2(30)) AS "REC_TYPE", O.* FROM MP_ASSOC_FHW_OLI O
  UNION ALL
SELECT CAST('MP_ASSOC_SERVICE_MOLI' AS VARCHAR2(30)) AS "REC_TYPE", M.* FROM MP_ASSOC_SERVICE_MOLI M
  UNION ALL
SELECT CAST('DARO_ASSOC_SERVICE_MOLI' AS VARCHAR2(30)) AS "REC_TYPE", M.* FROM DARO_ASSOC_SERVICE_MOLI M
  UNION ALL
SELECT CAST('SERVICE_ASSOC_ACCESS_TYPE_OLI' AS VARCHAR2(30)) AS "REC_TYPE", O.* FROM SERVICE_ASSOC_ACCESS_TYPE_OLI O
;

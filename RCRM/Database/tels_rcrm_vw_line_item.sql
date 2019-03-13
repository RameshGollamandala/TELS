DROP VIEW TELS_RCRM_VW_LINE_ITEM;

/* Formatted on 3/11/2019 5:02:12 PM (QP5 v5.163.1008.3004) */
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
   WITH                                                 /*-- SIMPLE TYPES --*/
       CONVERT_PLAN_OLI
        AS (SELECT O.*
              FROM TELS_RCRM_MV_OLI_ROOT O
             WHERE O.COMMISSION_PRODUCT_TYPE = 'Commissions Convert Plan'
                   AND O.ACTION_CODE IN ('Add', '-', 'Update')),
        VAS_OLI
        AS (SELECT O.*
              FROM TELS_RCRM_MV_OLI_ROOT O
             WHERE O.COMMISSION_PRODUCT_TYPE IN ('Commissions VAS')
                   AND O.ACTION_CODE IN ('Add', '-', 'Update')
            UNION
            SELECT O.*
              FROM CONVERT_PLAN_OLI O),
        DARO_MOLI
        AS (SELECT M.*
              FROM TELS_RCRM_MV_MOLI_ROOT M
             WHERE     (1 = 1)
                   AND M.COMMISSION_PRODUCT_TYPE = 'Commissions DARO'
                   AND M.ACTION_CODE = 'Add'
            UNION
            SELECT O.*
              FROM TELS_RCRM_MV_OLI_ROOT O
             WHERE     (1 = 1)
                   AND O.COMMISSION_PRODUCT_TYPE = 'Commissions DARO'
                   AND O.ACTION_CODE = 'Add'
                   AND O.PART_NUMBER = 'XC001007226'),
        FHW_OLI
        AS (SELECT O.*
              FROM TELS_RCRM_MV_OLI_ROOT O
             WHERE O.COMMISSION_PRODUCT_TYPE = 'Commissions Fixed Hardware'
                   AND O.ACTION_CODE = 'Add'
            UNION
            SELECT M.*
              FROM TELS_RCRM_MV_MOLI_ROOT M
             WHERE M.COMMISSION_PRODUCT_TYPE = 'Commissions Fixed Hardware'
                   AND M.ACTION_CODE = 'Add'),
        DARO_ASSOC_FHW_OLI
        AS (SELECT FO.*
              FROM FHW_OLI FO
             WHERE (1 = 1)
                   AND EXISTS
                          (SELECT 1
                             FROM DARO_MOLI DM
                            WHERE (1 = 1)
                                  AND DM.ROOT_ITEM_ROW_ID =
                                         FO.ROOT_ITEM_ROW_ID
                                  AND DM.STATUS_HEADER = FO.STATUS_HEADER
                                  AND DM.ORDER_NUMBER = FO.ORDER_NUMBER)),
        MP_OLI
        AS (SELECT O.*
              FROM TELS_RCRM_MV_OLI_ROOT O
             WHERE O.COMMISSION_PRODUCT_TYPE = 'Commissions Main Plan'
                   AND O.ACTION_CODE IN ('Add', '-', 'Update')),
        SIM_OLI
        AS (SELECT O.*
              FROM TELS_RCRM_MV_OLI_ROOT O
             WHERE O.COMMISSION_PRODUCT_TYPE = 'Commissions SIM'),
        HW_OLI
        AS (SELECT O.*
              FROM TELS_RCRM_MV_OLI_ROOT O
             WHERE O.COMMISSION_PRODUCT_TYPE = 'Commissions Hardware'
                   AND O.ACTION_CODE = 'Add'),
        CONTRACT_OLI
        AS (SELECT O.*
              FROM TELS_RCRM_MV_OLI_ROOT O
             WHERE O.COMMISSION_PRODUCT_TYPE = 'Commissions Contract'),
        MAIN_CONTRACT_OLI
        AS (SELECT O.*
              FROM TELS_RCRM_MV_OLI_ROOT O
             WHERE O.COMMISSION_PRODUCT_TYPE = 'Commissions Main Contract'),
        ACCESS_TYPE_OLI
        AS (SELECT O.*
              FROM TELS_RCRM_MV_OLI_ROOT O
             WHERE O.COMMISSION_PRODUCT_TYPE = 'Commissions Access Type'),
        SERVICE_MOLI
        AS (SELECT M.*
              FROM TELS_RCRM_MV_MOLI_ROOT M
             WHERE M.COMMISSION_PRODUCT_TYPE = 'Commissions Service') /*-- COMPOSITE TYPES --*/
                                                                     ,
        VAS_ASSOC_MOLI
        AS (SELECT M.*
              FROM TELS_RCRM_MV_MOLI_ROOT M
             WHERE EXISTS
                      (SELECT 1
                         FROM VAS_OLI VO
                        WHERE     VO.ROOT_ITEM_ROW_ID = M.ROW_ID
                              AND VO.STATUS_HEADER = M.STATUS_HEADER
                              AND VO.ORDER_NUMBER = M.ORDER_NUMBER)),
        VAS_ASSOC_CONTRACT_OLI
        AS (SELECT CO.*
              FROM    CONTRACT_OLI CO
                   JOIN
                      VAS_OLI VO
                   ON     VO.ROOT_ITEM_ROW_ID = CO.ROOT_ITEM_ROW_ID
                      AND VO.STATUS_HEADER = CO.STATUS_HEADER
                      AND VO.ORDER_NUMBER = CO.ORDER_NUMBER
             WHERE CO.ACTION_CODE IN ('Add', '-')
                   AND NOT EXISTS
                              (SELECT 1
                                 FROM TELS_RCRM_MV_ATTRIBUTE ATT
                                WHERE ATT.ROW_ID = CO.ROW_ID
                                      AND ATT.ATTRIBUTE_ACTION_CODE =
                                             'Delete')
                   AND EXISTS
                          (SELECT 1
                             FROM TELS_RCRM_MV_ATTRIBUTE ATT
                            WHERE     ATT.ROW_ID = CO.ROW_ID
                                  AND ATT.ATTRIBUTE_DISPLAY_NAME = 'Plan ID'
                                  AND ATT.ATTRIBUTE_VALUE = VO.PART_NUMBER)),
        HW_ASSOC_CONTRACT_OLI
        AS (SELECT CO.*
              FROM    CONTRACT_OLI CO
                   JOIN
                      HW_OLI HO
                   ON     HO.ROOT_ITEM_ROW_ID = CO.ROOT_ITEM_ROW_ID
                      AND HO.STATUS_HEADER = CO.STATUS_HEADER
                      AND HO.ORDER_NUMBER = CO.ORDER_NUMBER
             WHERE CO.ACTION_CODE IN ('Add', '-')
                   AND NOT EXISTS
                              (SELECT 1
                                 FROM TELS_RCRM_MV_ATTRIBUTE ATT
                                WHERE ATT.ROW_ID = CO.ROW_ID
                                      AND ATT.ATTRIBUTE_ACTION_CODE =
                                             'Delete')
                   AND EXISTS
                          (SELECT 1
                             FROM TELS_RCRM_MV_ATTRIBUTE ATT
                            WHERE ATT.ROW_ID = CO.ROW_ID
                                  AND ATT.ATTRIBUTE_VALUE = HO.PART_NUMBER)),
        HW_ASSOC_PLAN_OLI
        AS (SELECT O.*
              FROM TELS_RCRM_MV_OLI_ROOT O
             WHERE EXISTS
                      (SELECT 1
                         FROM HW_OLI HO
                        WHERE     HO.ROOT_ITEM_ROW_ID = O.ROOT_ITEM_ROW_ID
                              AND HO.STATUS_HEADER = O.STATUS_HEADER
                              AND HO.ORDER_NUMBER = O.ORDER_NUMBER)
                   AND O.COMMISSION_PRODUCT_TYPE = 'Commissions Main Plan'
                   AND O.ACTION_CODE IN ('Add', '-', 'Update')),
        HW_ASSOC_MRO_OLI
        AS (SELECT O.*
              FROM TELS_RCRM_MV_OLI_ROOT O
             WHERE EXISTS
                      (SELECT 1
                         FROM HW_OLI HO
                        WHERE     HO.ROOT_ITEM_ROW_ID = O.ROOT_ITEM_ROW_ID
                              AND HO.STATUS_HEADER = O.STATUS_HEADER
                              AND HO.ORDER_NUMBER = O.ORDER_NUMBER)
                   AND O.COMMISSION_PRODUCT_TYPE = 'Commissions MRO'),
        FHW_ASSOC_MOLI
        AS (SELECT M.*
              FROM TELS_RCRM_MV_MOLI_ROOT M
             WHERE EXISTS
                      (SELECT 1
                         FROM FHW_OLI FO
                        WHERE     FO.ROOT_ITEM_ROW_ID = M.ROW_ID
                              AND FO.ORDER_NUMBER = M.ORDER_NUMBER
                              AND FO.STATUS_HEADER = M.STATUS_HEADER)),
        HW_ASSOC_MOLI
        AS (SELECT M.*
              FROM TELS_RCRM_MV_MOLI_ROOT M
             WHERE EXISTS
                      (SELECT 1
                         FROM HW_OLI HO
                        WHERE     HO.ROOT_ITEM_ROW_ID = M.ROW_ID
                              AND HO.ORDER_NUMBER = M.ORDER_NUMBER
                              AND HO.STATUS_HEADER = M.STATUS_HEADER)),
        --        MP_ASSOC_MOLI
        --        AS (SELECT M.*
        --              FROM TELS_RCRM_MV_MOLI_ROOT M
        --             WHERE EXISTS
        --                      (SELECT 1
        --                         FROM MP_OLI MO
        --                        WHERE     MO.ROOT_ITEM_ROW_ID = M.ROW_ID
        --                              AND MO.ORDER_NUMBER = M.ORDER_NUMBER
        --                              AND MO.STATUS_HEADER = M.STATUS_HEADER))
        MP_ASSOC_MOLI_PRE_HOLD
        AS (SELECT M.*
              FROM TELS_RCRM_MV_MOLI_ROOT M
             WHERE (1 = 1)
                   AND EXISTS
                          (SELECT 1
                             FROM MP_OLI MO
                            WHERE     (1 = 1)
                                  AND MO.ROOT_ITEM_ROW_ID = M.ROW_ID
                                  AND MO.ORDER_NUMBER = M.ORDER_NUMBER
                                  AND MO.STATUS_HEADER = M.STATUS_HEADER)),
        FHW_ASSOC_VAS_OLI
        AS (SELECT VO.*
              FROM VAS_OLI VO
             WHERE EXISTS
                      (SELECT 1
                         FROM    FHW_ASSOC_MOLI FAM
                              JOIN
                                 VAS_ASSOC_MOLI VAM
                              ON VAM.PROMOTION_INTEGRATION_ID =
                                    FAM.PROMOTION_INTEGRATION_ID
                        WHERE     FAM.ROW_ID = VO.ROOT_ITEM_ROW_ID
                              AND FAM.STATUS_HEADER = VO.STATUS_HEADER
                              AND FAM.ORDER_NUMBER = VO.ORDER_NUMBER
                              AND VAM.ROW_ID = VO.ROOT_ITEM_ROW_ID
                              AND VAM.STATUS_HEADER = VO.STATUS_HEADER
                              AND VAM.ORDER_NUMBER = VO.ORDER_NUMBER)
                   AND EXISTS
                          (SELECT 1
                             FROM FHW_OLI FO
                            WHERE FO.ROOT_ITEM_ROW_ID = VO.ROOT_ITEM_ROW_ID
                                  AND FO.ORDER_NUMBER = VO.ORDER_NUMBER
                                  AND FO.STATUS_HEADER = VO.STATUS_HEADER)),
        VAS_ASSOC_FHW_OLI
        AS (SELECT FO.*
              FROM FHW_OLI FO
             WHERE (1 = 1)
                   AND EXISTS
                          (SELECT 1
                             FROM    FHW_ASSOC_MOLI FAM
                                  JOIN
                                     VAS_ASSOC_MOLI VAM
                                  ON VAM.PROMOTION_INTEGRATION_ID =
                                        FAM.PROMOTION_INTEGRATION_ID
                            WHERE     FAM.ROW_ID = FO.ROOT_ITEM_ROW_ID
                                  AND FAM.STATUS_HEADER = FO.STATUS_HEADER
                                  AND FAM.ORDER_NUMBER = FO.ORDER_NUMBER
                                  AND VAM.ROW_ID = FO.ROOT_ITEM_ROW_ID
                                  AND VAM.STATUS_HEADER = FO.STATUS_HEADER
                                  AND VAM.ORDER_NUMBER = FO.ORDER_NUMBER)
                   AND EXISTS
                          (SELECT 1
                             FROM VAS_OLI VO
                            WHERE VO.ROOT_ITEM_ROW_ID = FO.ROOT_ITEM_ROW_ID
                                  AND VO.ORDER_NUMBER = FO.ORDER_NUMBER
                                  AND VO.STATUS_HEADER = FO.STATUS_HEADER)),
        --VAS_ASSOC_OFFER_MOLI AS (
        --  SELECT M.*
        --  FROM TELS_RCRM_MV_MOLI_ROOT M
        --  WHERE EXISTS (
        --    SELECT 1
        --    FROM VAS_ASSOC_MOLI VAM
        --    WHERE VAM.PROMOTION_INTEGRATION_ID = M.PROMOTION_INTEGRATION_ID
        --    AND VAM.ORDER_NUMBER = M.ORDER_NUMBER
        --    AND VAM.STATUS_HEADER = M.STATUS_HEADER)
        --    AND M.COMMISSION_PRODUCT_TYPE IN ('Commissions Bundle', 'Commissions Standalone')
        --  )
        VAS_ASSOC_OFFER_MOLI
        AS (SELECT M.*
              FROM TELS_RCRM_MV_MOLI_ROOT M
             WHERE (1 = 1)
                   AND M.COMMISSION_PRODUCT_TYPE IN
                          ('Commissions Bundle', 'Commissions Standalone')
                   AND EXISTS
                          (SELECT 1
                             FROM VAS_ASSOC_MOLI VAM
                            WHERE (1 = 1)
                                  AND VAM.PROMOTION_INTEGRATION_ID =
                                         M.PROMOTION_INTEGRATION_ID
                                  AND VAM.ORDER_NUMBER = M.ORDER_NUMBER
                                  --    AND DECODE(VAM.STATUS_ORDER_LINE_ITEM, 'Complete', VAM.STATUS_ORDER_LINE_ITEM, VAM.STATUS_HEADER) = DECODE(VAM.STATUS_ORDER_LINE_ITEM, 'Complete', M.STATUS_ORDER_LINE_ITEM, M.STATUS_HEADER)
                                  --    AND DECODE(VAM.STATUS_ORDER_LINE_ITEM, 'Complete', 'Complete', VAM.STATUS_ORDER_LINE_ITEM) = DECODE(VAM.STATUS_ORDER_LINE_ITEM, 'Complete', 'Complete', M.STATUS_ORDER_LINE_ITEM)
                                  --commented prakash 20190308
                                  --AND CASE WHEN VAM.STATUS_ORDER_LINE_ITEM = 'Complete' THEN CASE WHEN VAM.STATUS_HEADER = 'In-transit' THEN VAM.STATUS_ORDER_LINE_ITEM WHEN VAM.STATUS_HEADER = 'Provisioning' THEN VAM.STATUS_ORDER_LINE_ITEM ELSE VAM.STATUS_HEADER END ELSE VAM.STATUS_HEADER END = CASE WHEN M.STATUS_ORDER_LINE_ITEM = 'Complete' THEN CASE WHEN M.STATUS_HEADER = 'In-transit' THEN M.STATUS_ORDER_LINE_ITEM WHEN M.STATUS_HEADER = 'Provisioning' THEN M.STATUS_ORDER_LINE_ITEM ELSE M.STATUS_HEADER END ELSE M.STATUS_HEADER END
                                  AND VAM.STATUS_ORDER_LINE_ITEM =
                                         M.STATUS_ORDER_LINE_ITEM)),
        MP_ASSOC_CONVERT_PLAN_OLI
        AS (SELECT CO.*
              FROM CONVERT_PLAN_OLI CO
             WHERE EXISTS
                      (SELECT 1
                         FROM MP_OLI MO
                        WHERE     MO.ROOT_ITEM_ROW_ID = CO.ROOT_ITEM_ROW_ID
                              AND MO.ORDER_NUMBER = CO.ORDER_NUMBER
                              AND MO.STATUS_HEADER = CO.STATUS_HEADER)
                   AND CO.ORDER_TYPE IN ('Add New Service', 'Modify')),
        MP_ASSOC_SIM_OLI
        AS (SELECT SO.*
              FROM SIM_OLI SO
             WHERE EXISTS
                      (SELECT 1
                         FROM MP_OLI MO
                        WHERE     MO.ROOT_ITEM_ROW_ID = SO.ROOT_ITEM_ROW_ID
                              AND MO.ORDER_NUMBER = SO.ORDER_NUMBER
                              AND MO.STATUS_HEADER = SO.STATUS_HEADER)
                   AND SO.ACTION_CODE <> 'Delete'
                   AND NOT EXISTS
                              (SELECT 1
                                 FROM TELS_RCRM_MV_ATTRIBUTE ATT
                                WHERE ATT.ROW_ID = SO.ROW_ID
                                      AND ATT.ATTRIBUTE_ACTION_CODE =
                                             'Delete')),
        MP_ASSOC_MAIN_CONT_ADD_OLI
        AS (SELECT MCO.*
              FROM MAIN_CONTRACT_OLI MCO
             WHERE EXISTS
                      (SELECT 1
                         FROM MP_OLI MO
                        WHERE     MO.ROOT_ITEM_ROW_ID = MCO.ROOT_ITEM_ROW_ID
                              AND MO.ORDER_NUMBER = MCO.ORDER_NUMBER
                              AND MO.STATUS_HEADER = MCO.STATUS_HEADER)
                   AND MCO.ACTION_CODE IN ('Add', '-')
                   AND NOT EXISTS
                              (SELECT 1
                                 FROM TELS_RCRM_MV_ATTRIBUTE ATT
                                WHERE ATT.ROW_ID = MCO.ROW_ID
                                      AND ATT.ATTRIBUTE_ACTION_CODE =
                                             'Delete')),
        MP_ASSOC_MAIN_CONT_DEL_OLI
        AS (SELECT MCO.*
              FROM MAIN_CONTRACT_OLI MCO
             WHERE EXISTS
                      (SELECT 1
                         FROM MP_OLI MO
                        WHERE     MO.ROOT_ITEM_ROW_ID = MCO.ROOT_ITEM_ROW_ID
                              AND MO.ORDER_NUMBER = MCO.ORDER_NUMBER
                              AND MO.STATUS_HEADER = MCO.STATUS_HEADER)
                   AND MCO.ACTION_CODE = 'Delete'
                   AND EXISTS
                          (SELECT 1
                             FROM TELS_RCRM_MV_ATTRIBUTE ATT
                            WHERE ATT.ROW_ID = MCO.ROW_ID
                                  AND ATT.ATTRIBUTE_ACTION_CODE = 'Delete')),
        MP_DEL_OLI
        AS (SELECT O.*
              FROM TELS_RCRM_MV_OLI_ROOT O
             WHERE O.COMMISSION_PRODUCT_TYPE = 'Commissions Main Plan'
                   AND O.ACTION_CODE = 'Delete'
                   AND EXISTS
                          (SELECT 1
                             FROM TELS_RCRM_MV_ATTRIBUTE ATT
                            WHERE ATT.ROW_ID = O.ROW_ID
                                  AND ATT.ATTRIBUTE_ACTION_CODE = 'Delete')),
        MP_ASSOC_MAIN_PLAN_DEL_OLI
        AS (SELECT MO1.*
              FROM MP_DEL_OLI MO1
             WHERE EXISTS
                      (SELECT 1
                         FROM MP_OLI MO2
                        WHERE     MO2.ROOT_ITEM_ROW_ID = MO1.ROOT_ITEM_ROW_ID
                              AND MO2.ORDER_NUMBER = MO1.ORDER_NUMBER
                              AND MO2.STATUS_HEADER = MO1.STATUS_HEADER)),
        MP_ASSOC_CONTRACT_ADD_OLI
        AS (SELECT CO.*
              FROM CONTRACT_OLI CO
             WHERE EXISTS
                      (SELECT 1
                         FROM MP_OLI MO
                        WHERE     MO.ROOT_ITEM_ROW_ID = CO.ROOT_ITEM_ROW_ID
                              AND MO.ORDER_NUMBER = CO.ORDER_NUMBER
                              AND MO.STATUS_HEADER = CO.STATUS_HEADER)
                   AND CO.ACTION_CODE IN ('Add', '-')
                   AND NOT EXISTS
                              (SELECT 1
                                 FROM TELS_RCRM_MV_ATTRIBUTE ATT
                                WHERE ATT.ROW_ID = CO.ROW_ID
                                      AND ATT.ATTRIBUTE_ACTION_CODE =
                                             'Delete')),
        MP_ASSOC_CONTRACT_DEL_OLI
        AS (SELECT CO.*
              FROM CONTRACT_OLI CO
             WHERE EXISTS
                      (SELECT 1
                         FROM MP_OLI MO
                        WHERE     MO.ROOT_ITEM_ROW_ID = CO.ROOT_ITEM_ROW_ID
                              AND MO.ORDER_NUMBER = CO.ORDER_NUMBER
                              AND MO.STATUS_HEADER = CO.STATUS_HEADER)
                   AND CO.ACTION_CODE = 'Delete'
                   AND EXISTS
                          (SELECT 1
                             FROM TELS_RCRM_MV_ATTRIBUTE ATT
                            WHERE ATT.ROW_ID = CO.ROW_ID
                                  AND ATT.ATTRIBUTE_ACTION_CODE = 'Delete')),
        MP_ASSOC_HW_OLI
        AS (SELECT HO.*
              FROM HW_OLI HO
             WHERE EXISTS
                      (SELECT 1
                         FROM MP_OLI MO
                        WHERE     MO.ROOT_ITEM_ROW_ID = HO.ROOT_ITEM_ROW_ID
                              AND MO.ORDER_NUMBER = HO.ORDER_NUMBER
                              AND MO.STATUS_HEADER = HO.STATUS_HEADER)),
        MP_ASSOC_FHW_OLI
        AS (SELECT FO.*
              FROM FHW_OLI FO
             WHERE (1 = 1)
                   AND EXISTS
                          (SELECT 1
                             FROM    FHW_ASSOC_MOLI FAM
                                  JOIN
                                     MP_ASSOC_MOLI_PRE_HOLD MAM
                                  ON MAM.PROMOTION_INTEGRATION_ID =
                                        FAM.PROMOTION_INTEGRATION_ID
                            WHERE     FAM.ROW_ID = FO.ROOT_ITEM_ROW_ID
                                  AND FAM.STATUS_HEADER = FO.STATUS_HEADER
                                  AND FAM.ORDER_NUMBER = FO.ORDER_NUMBER
                                  AND MAM.ROW_ID = FO.ROOT_ITEM_ROW_ID
                                  AND MAM.STATUS_HEADER = FO.STATUS_HEADER
                                  AND MAM.ORDER_NUMBER = FO.ORDER_NUMBER)
                   AND EXISTS
                          (SELECT 1
                             FROM MP_OLI MO
                            WHERE MO.ROOT_ITEM_ROW_ID = FO.ROOT_ITEM_ROW_ID
                                  AND MO.ORDER_NUMBER = FO.ORDER_NUMBER
                                  AND MO.STATUS_HEADER = FO.STATUS_HEADER)),
        --MP_ASSOC_SERVICE_MOLI AS (
        --  SELECT SM.*
        --  FROM SERVICE_MOLI SM
        --  WHERE EXISTS (
        --    SELECT 1
        --    FROM MP_ASSOC_MOLI_PRE_HOLD MO
        --    WHERE (1=1)
        --    AND MO.PROMOTION_INTEGRATION_ID = SM.PROMOTION_INTEGRATION_ID
        --    AND MO.ORDER_NUMBER = SM.ORDER_NUMBER
        --    AND MO.STATUS_HEADER = SM.STATUS_HEADER
        --  )
        MP_ASSOC_SERVICE_MOLI
        AS (SELECT SM.*
              FROM SERVICE_MOLI SM
             WHERE (1 = 1)
                   AND EXISTS
                          (SELECT 1
                             FROM MP_ASSOC_MOLI_PRE_HOLD MPAM
                            WHERE MPAM.PROMOTION_INTEGRATION_ID =
                                     SM.PROMOTION_INTEGRATION_ID
                                  AND MPAM.ORDER_NUMBER = SM.ORDER_NUMBER
                                  --    AND DECODE(MPAM.STATUS_ORDER_LINE_ITEM, 'Complete', MPAM.STATUS_ORDER_LINE_ITEM, MPAM.STATUS_HEADER) = DECODE(MPAM.STATUS_ORDER_LINE_ITEM, 'Complete', SM.STATUS_ORDER_LINE_ITEM, SM.STATUS_HEADER)
                                  --    AND DECODE(MPAM.STATUS_ORDER_LINE_ITEM, 'Complete', 'Complete', MPAM.STATUS_ORDER_LINE_ITEM) = DECODE(MPAM.STATUS_ORDER_LINE_ITEM, 'Complete', 'Complete', SM.STATUS_ORDER_LINE_ITEM)
                                  --commented prakash 20190308
                                  --AND CASE WHEN MPAM.STATUS_ORDER_LINE_ITEM = 'Complete' THEN CASE WHEN MPAM.STATUS_HEADER = 'In-transit' THEN MPAM.STATUS_ORDER_LINE_ITEM WHEN MPAM.STATUS_HEADER = 'Provisioning' THEN MPAM.STATUS_ORDER_LINE_ITEM ELSE MPAM.STATUS_HEADER END ELSE MPAM.STATUS_HEADER END = CASE WHEN SM.STATUS_ORDER_LINE_ITEM = 'Complete' THEN CASE WHEN SM.STATUS_HEADER = 'In-transit' THEN SM.STATUS_ORDER_LINE_ITEM WHEN SM.STATUS_HEADER = 'Provisioning' THEN SM.STATUS_ORDER_LINE_ITEM ELSE SM.STATUS_HEADER END ELSE SM.STATUS_HEADER END
                                  AND MPAM.STATUS_ORDER_LINE_ITEM =
                                         SM.STATUS_ORDER_LINE_ITEM)),
        SERVICE_ASSOC_ACCESS_TYPE_OLI
        AS (SELECT ATO.*
              FROM ACCESS_TYPE_OLI ATO
             WHERE EXISTS
                      (SELECT 1
                         FROM SERVICE_MOLI SM
                        WHERE     SM.ROOT_ITEM_ROW_ID = ATO.ROOT_ITEM_ROW_ID
                              AND SM.ORDER_NUMBER = ATO.ORDER_NUMBER
                              AND SM.STATUS_HEADER = ATO.STATUS_HEADER)
                   AND ATO.ACTION_CODE IN ('Add', '-', 'Update')
                   AND NOT EXISTS
                              (SELECT 1
                                 FROM TELS_RCRM_MV_ATTRIBUTE ATT
                                WHERE ATT.ROW_ID = ATO.ROW_ID
                                      AND ATT.ATTRIBUTE_ACTION_CODE =
                                             'Delete')),
        MP_ASSOC_MOLI
        AS (SELECT MPAM.*
              FROM MP_ASSOC_MOLI_PRE_HOLD MPAM
             WHERE NVL (MPAM.COMMISSION_PRODUCT_TYPE, 'NULL') NOT IN
                      ('Commissions Bundle', 'Commissions Standalone')
                   OR EXISTS
                         (SELECT 1
                            FROM MP_ASSOC_SERVICE_MOLI MASM
                           WHERE (1 = 1)
                                 AND MASM.ORDER_NUMBER = MPAM.ORDER_NUMBER
                                 --commented prakash 20190308
                                 --AND MASM.STATUS_HEADER            = MPAM.STATUS_HEADER
                                 AND MASM.PROMOTION_INTEGRATION_ID =
                                        MPAM.PROMOTION_INTEGRATION_ID
                                 --added prakash 20190308
                                 AND MASM.STATUS_ORDER_LINE_ITEM =
                                        MPAM.STATUS_ORDER_LINE_ITEM)),
        MP_ASSOC_MOLI_HOLD
        AS (SELECT MPAM.*
              FROM MP_ASSOC_MOLI_PRE_HOLD MPAM
             WHERE (1 = 1)
                   AND NVL (MPAM.COMMISSION_PRODUCT_TYPE, 'NULL') IN
                          ('Commissions Bundle', 'Commissions Standalone')
                   AND NOT EXISTS
                              (SELECT 1
                                 FROM MP_ASSOC_SERVICE_MOLI MASM
                                WHERE (1 = 1)
                                      AND MASM.ORDER_NUMBER =
                                             MPAM.ORDER_NUMBER
                                      --commented prakash 20190301
                                      --AND MASM.STATUS_HEADER            = MPAM.STATUS_HEADER
                                      AND MASM.PROMOTION_INTEGRATION_ID =
                                             MPAM.PROMOTION_INTEGRATION_ID
                                      --added prakash 20190301
                                      --commented prakash 20190308
                                      --AND CASE WHEN MPAM.STATUS_ORDER_LINE_ITEM = 'Complete' THEN CASE WHEN MPAM.STATUS_HEADER = 'In-transit' THEN MPAM.STATUS_ORDER_LINE_ITEM WHEN MPAM.STATUS_HEADER = 'Provisioning' THEN MPAM.STATUS_ORDER_LINE_ITEM ELSE MPAM.STATUS_HEADER END ELSE MPAM.STATUS_HEADER END = CASE WHEN MASM.STATUS_ORDER_LINE_ITEM = 'Complete' THEN CASE WHEN MASM.STATUS_HEADER = 'In-transit' THEN MASM.STATUS_ORDER_LINE_ITEM WHEN MASM.STATUS_HEADER = 'Provisioning' THEN MASM.STATUS_ORDER_LINE_ITEM ELSE MASM.STATUS_HEADER END ELSE MASM.STATUS_HEADER END
                                      AND MPAM.STATUS_ORDER_LINE_ITEM =
                                             MASM.STATUS_ORDER_LINE_ITEM)),
        DARO_ASSOC_SERVICE_MOLI
        AS (SELECT SM.*
              FROM SERVICE_MOLI SM
             WHERE EXISTS
                      (SELECT 1
                         FROM DARO_MOLI DO
                        WHERE     DO.ORDER_NUMBER = SM.ORDER_NUMBER
                              AND DO.STATUS_HEADER = SM.STATUS_HEADER
                              AND DO.FILENAME = SM.FILENAME
                              AND DO.ROOT_ITEM_ROW_ID = SM.ROW_ID))
   SELECT CAST ('ACCESS_TYPE_OLI' AS VARCHAR2 (30)) AS "REC_TYPE",
          O."FILENAME",
          O."BATCHPROCESSDATE",
          O."RECORDNUMBER",
          O."IS_FILTERED",
          O."ORDER_NUMBER",
          O."BILLING_ACCOUNT",
          O."CUSTOMER_LAST_NAME",
          O."CUSTOMER_FIRST_NAME",
          O."ORDER_TYPE",
          O."ORDER_SUB_TYPE",
          O."CREATED_DATE",
          O."PARTNER_CODE",
          O."CAMPAIGN_NAME",
          O."CAMPAIGN_NUMBER",
          O."CAMPAIGN_TYPE",
          O."CHANNEL_TYPE",
          O."CAMPAIGN_START_DATE",
          O."BUSINESS_UNIT",
          O."SALES_FORCE_ID",
          O."CUSTOMER_ID",
          O."ORDER_REVISION_NUMBER",
          O."SUBMITTED_DATE",
          O."STATUS_HEADER",
          O."REASON_CODE",
          O."COMMISSION_TRANSACTION_TYPE",
          O."SOURCE_SYSTEM",
          O."ROW_ID",
          O."PRODUCT",
          O."PART_NUMBER",
          O."ACTION_CODE",
          O."TRANSFER_TYPE",
          O."EVENT_SOURCE",
          O."PROD_PROM_ID",
          O."PROVISIONED_DATE",
          O."NET_PRICE",
          O."COMMISSION_PRODUCT_TYPE",
          O."COMMISSIONABLE",
          O."STATUS_ORDER_LINE_ITEM",
          O."ORIGINAL_ORDER_NUMBER",
          O."HARDWARE_SUPPLIED_FLAG",
          O."SUB_ACTION_CODE",
          O."PROMOTION_INTEGRATION_ID",
          O."NGB_PROD_TYPE",
          O."PROMOTION_PART_NUMBER",
          O."PRODUCT_ID",
          O."O2A_STATUS",
          O."PARENT_ITEM_ROW_ID",
          O."ROOT_ITEM_ROW_ID",
          O."CONTRACT_START_DATE",
          O."CONTRACT_END_DATE",
          O."LIST_PRICE",
          O."HARDWARE_ASSOCIATION_ID",
          O."EFFECTIVE_DATE"
     FROM ACCESS_TYPE_OLI O
   UNION ALL
   SELECT CAST ('CONTRACT_OLI' AS VARCHAR2 (30)) AS "REC_TYPE",
          O."FILENAME",
          O."BATCHPROCESSDATE",
          O."RECORDNUMBER",
          O."IS_FILTERED",
          O."ORDER_NUMBER",
          O."BILLING_ACCOUNT",
          O."CUSTOMER_LAST_NAME",
          O."CUSTOMER_FIRST_NAME",
          O."ORDER_TYPE",
          O."ORDER_SUB_TYPE",
          O."CREATED_DATE",
          O."PARTNER_CODE",
          O."CAMPAIGN_NAME",
          O."CAMPAIGN_NUMBER",
          O."CAMPAIGN_TYPE",
          O."CHANNEL_TYPE",
          O."CAMPAIGN_START_DATE",
          O."BUSINESS_UNIT",
          O."SALES_FORCE_ID",
          O."CUSTOMER_ID",
          O."ORDER_REVISION_NUMBER",
          O."SUBMITTED_DATE",
          O."STATUS_HEADER",
          O."REASON_CODE",
          O."COMMISSION_TRANSACTION_TYPE",
          O."SOURCE_SYSTEM",
          O."ROW_ID",
          O."PRODUCT",
          O."PART_NUMBER",
          O."ACTION_CODE",
          O."TRANSFER_TYPE",
          O."EVENT_SOURCE",
          O."PROD_PROM_ID",
          O."PROVISIONED_DATE",
          O."NET_PRICE",
          O."COMMISSION_PRODUCT_TYPE",
          O."COMMISSIONABLE",
          O."STATUS_ORDER_LINE_ITEM",
          O."ORIGINAL_ORDER_NUMBER",
          O."HARDWARE_SUPPLIED_FLAG",
          O."SUB_ACTION_CODE",
          O."PROMOTION_INTEGRATION_ID",
          O."NGB_PROD_TYPE",
          O."PROMOTION_PART_NUMBER",
          O."PRODUCT_ID",
          O."O2A_STATUS",
          O."PARENT_ITEM_ROW_ID",
          O."ROOT_ITEM_ROW_ID",
          O."CONTRACT_START_DATE",
          O."CONTRACT_END_DATE",
          O."LIST_PRICE",
          O."HARDWARE_ASSOCIATION_ID",
          O."EFFECTIVE_DATE"
     FROM CONTRACT_OLI O
   UNION ALL
   SELECT CAST ('CONVERT_PLAN_OLI' AS VARCHAR2 (30)) AS "REC_TYPE",
          O."FILENAME",
          O."BATCHPROCESSDATE",
          O."RECORDNUMBER",
          O."IS_FILTERED",
          O."ORDER_NUMBER",
          O."BILLING_ACCOUNT",
          O."CUSTOMER_LAST_NAME",
          O."CUSTOMER_FIRST_NAME",
          O."ORDER_TYPE",
          O."ORDER_SUB_TYPE",
          O."CREATED_DATE",
          O."PARTNER_CODE",
          O."CAMPAIGN_NAME",
          O."CAMPAIGN_NUMBER",
          O."CAMPAIGN_TYPE",
          O."CHANNEL_TYPE",
          O."CAMPAIGN_START_DATE",
          O."BUSINESS_UNIT",
          O."SALES_FORCE_ID",
          O."CUSTOMER_ID",
          O."ORDER_REVISION_NUMBER",
          O."SUBMITTED_DATE",
          O."STATUS_HEADER",
          O."REASON_CODE",
          O."COMMISSION_TRANSACTION_TYPE",
          O."SOURCE_SYSTEM",
          O."ROW_ID",
          O."PRODUCT",
          O."PART_NUMBER",
          O."ACTION_CODE",
          O."TRANSFER_TYPE",
          O."EVENT_SOURCE",
          O."PROD_PROM_ID",
          O."PROVISIONED_DATE",
          O."NET_PRICE",
          O."COMMISSION_PRODUCT_TYPE",
          O."COMMISSIONABLE",
          O."STATUS_ORDER_LINE_ITEM",
          O."ORIGINAL_ORDER_NUMBER",
          O."HARDWARE_SUPPLIED_FLAG",
          O."SUB_ACTION_CODE",
          O."PROMOTION_INTEGRATION_ID",
          O."NGB_PROD_TYPE",
          O."PROMOTION_PART_NUMBER",
          O."PRODUCT_ID",
          O."O2A_STATUS",
          O."PARENT_ITEM_ROW_ID",
          O."ROOT_ITEM_ROW_ID",
          O."CONTRACT_START_DATE",
          O."CONTRACT_END_DATE",
          O."LIST_PRICE",
          O."HARDWARE_ASSOCIATION_ID",
          O."EFFECTIVE_DATE"
     FROM CONVERT_PLAN_OLI O
   UNION ALL
   SELECT CAST ('DARO_MOLI' AS VARCHAR2 (30)) AS "REC_TYPE",
          M."FILENAME",
          M."BATCHPROCESSDATE",
          M."RECORDNUMBER",
          M."IS_FILTERED",
          M."ORDER_NUMBER",
          M."BILLING_ACCOUNT",
          M."CUSTOMER_LAST_NAME",
          M."CUSTOMER_FIRST_NAME",
          M."ORDER_TYPE",
          M."ORDER_SUB_TYPE",
          M."CREATED_DATE",
          M."PARTNER_CODE",
          M."CAMPAIGN_NAME",
          M."CAMPAIGN_NUMBER",
          M."CAMPAIGN_TYPE",
          M."CHANNEL_TYPE",
          M."CAMPAIGN_START_DATE",
          M."BUSINESS_UNIT",
          M."SALES_FORCE_ID",
          M."CUSTOMER_ID",
          M."ORDER_REVISION_NUMBER",
          M."SUBMITTED_DATE",
          M."STATUS_HEADER",
          M."REASON_CODE",
          M."COMMISSION_TRANSACTION_TYPE",
          M."SOURCE_SYSTEM",
          M."ROW_ID",
          M."PRODUCT",
          M."PART_NUMBER",
          M."ACTION_CODE",
          M."TRANSFER_TYPE",
          M."EVENT_SOURCE",
          M."PROD_PROM_ID",
          M."PROVISIONED_DATE",
          M."NET_PRICE",
          M."COMMISSION_PRODUCT_TYPE",
          M."COMMISSIONABLE",
          M."STATUS_ORDER_LINE_ITEM",
          M."ORIGINAL_ORDER_NUMBER",
          M."HARDWARE_SUPPLIED_FLAG",
          M."SUB_ACTION_CODE",
          M."PROMOTION_INTEGRATION_ID",
          M."NGB_PROD_TYPE",
          M."PROMOTION_PART_NUMBER",
          M."PRODUCT_ID",
          M."O2A_STATUS",
          M."PARENT_ITEM_ROW_ID",
          M."ROOT_ITEM_ROW_ID",
          M."CONTRACT_START_DATE",
          M."CONTRACT_END_DATE",
          M."LIST_PRICE",
          M."HARDWARE_ASSOCIATION_ID",
          M."EFFECTIVE_DATE"
     FROM DARO_MOLI M
   UNION ALL
   SELECT CAST ('FHW_ASSOC_MOLI' AS VARCHAR2 (30)) AS "REC_TYPE",
          M."FILENAME",
          M."BATCHPROCESSDATE",
          M."RECORDNUMBER",
          M."IS_FILTERED",
          M."ORDER_NUMBER",
          M."BILLING_ACCOUNT",
          M."CUSTOMER_LAST_NAME",
          M."CUSTOMER_FIRST_NAME",
          M."ORDER_TYPE",
          M."ORDER_SUB_TYPE",
          M."CREATED_DATE",
          M."PARTNER_CODE",
          M."CAMPAIGN_NAME",
          M."CAMPAIGN_NUMBER",
          M."CAMPAIGN_TYPE",
          M."CHANNEL_TYPE",
          M."CAMPAIGN_START_DATE",
          M."BUSINESS_UNIT",
          M."SALES_FORCE_ID",
          M."CUSTOMER_ID",
          M."ORDER_REVISION_NUMBER",
          M."SUBMITTED_DATE",
          M."STATUS_HEADER",
          M."REASON_CODE",
          M."COMMISSION_TRANSACTION_TYPE",
          M."SOURCE_SYSTEM",
          M."ROW_ID",
          M."PRODUCT",
          M."PART_NUMBER",
          M."ACTION_CODE",
          M."TRANSFER_TYPE",
          M."EVENT_SOURCE",
          M."PROD_PROM_ID",
          M."PROVISIONED_DATE",
          M."NET_PRICE",
          M."COMMISSION_PRODUCT_TYPE",
          M."COMMISSIONABLE",
          M."STATUS_ORDER_LINE_ITEM",
          M."ORIGINAL_ORDER_NUMBER",
          M."HARDWARE_SUPPLIED_FLAG",
          M."SUB_ACTION_CODE",
          M."PROMOTION_INTEGRATION_ID",
          M."NGB_PROD_TYPE",
          M."PROMOTION_PART_NUMBER",
          M."PRODUCT_ID",
          M."O2A_STATUS",
          M."PARENT_ITEM_ROW_ID",
          M."ROOT_ITEM_ROW_ID",
          M."CONTRACT_START_DATE",
          M."CONTRACT_END_DATE",
          M."LIST_PRICE",
          M."HARDWARE_ASSOCIATION_ID",
          M."EFFECTIVE_DATE"
     FROM FHW_ASSOC_MOLI M
   UNION ALL
   SELECT CAST ('FHW_ASSOC_VAS_OLI' AS VARCHAR2 (30)) AS "REC_TYPE",
          O."FILENAME",
          O."BATCHPROCESSDATE",
          O."RECORDNUMBER",
          O."IS_FILTERED",
          O."ORDER_NUMBER",
          O."BILLING_ACCOUNT",
          O."CUSTOMER_LAST_NAME",
          O."CUSTOMER_FIRST_NAME",
          O."ORDER_TYPE",
          O."ORDER_SUB_TYPE",
          O."CREATED_DATE",
          O."PARTNER_CODE",
          O."CAMPAIGN_NAME",
          O."CAMPAIGN_NUMBER",
          O."CAMPAIGN_TYPE",
          O."CHANNEL_TYPE",
          O."CAMPAIGN_START_DATE",
          O."BUSINESS_UNIT",
          O."SALES_FORCE_ID",
          O."CUSTOMER_ID",
          O."ORDER_REVISION_NUMBER",
          O."SUBMITTED_DATE",
          O."STATUS_HEADER",
          O."REASON_CODE",
          O."COMMISSION_TRANSACTION_TYPE",
          O."SOURCE_SYSTEM",
          O."ROW_ID",
          O."PRODUCT",
          O."PART_NUMBER",
          O."ACTION_CODE",
          O."TRANSFER_TYPE",
          O."EVENT_SOURCE",
          O."PROD_PROM_ID",
          O."PROVISIONED_DATE",
          O."NET_PRICE",
          O."COMMISSION_PRODUCT_TYPE",
          O."COMMISSIONABLE",
          O."STATUS_ORDER_LINE_ITEM",
          O."ORIGINAL_ORDER_NUMBER",
          O."HARDWARE_SUPPLIED_FLAG",
          O."SUB_ACTION_CODE",
          O."PROMOTION_INTEGRATION_ID",
          O."NGB_PROD_TYPE",
          O."PROMOTION_PART_NUMBER",
          O."PRODUCT_ID",
          O."O2A_STATUS",
          O."PARENT_ITEM_ROW_ID",
          O."ROOT_ITEM_ROW_ID",
          O."CONTRACT_START_DATE",
          O."CONTRACT_END_DATE",
          O."LIST_PRICE",
          O."HARDWARE_ASSOCIATION_ID",
          O."EFFECTIVE_DATE"
     FROM FHW_ASSOC_VAS_OLI O
   UNION ALL
   SELECT CAST ('FHW_OLI' AS VARCHAR2 (30)) AS "REC_TYPE",
          O."FILENAME",
          O."BATCHPROCESSDATE",
          O."RECORDNUMBER",
          O."IS_FILTERED",
          O."ORDER_NUMBER",
          O."BILLING_ACCOUNT",
          O."CUSTOMER_LAST_NAME",
          O."CUSTOMER_FIRST_NAME",
          O."ORDER_TYPE",
          O."ORDER_SUB_TYPE",
          O."CREATED_DATE",
          O."PARTNER_CODE",
          O."CAMPAIGN_NAME",
          O."CAMPAIGN_NUMBER",
          O."CAMPAIGN_TYPE",
          O."CHANNEL_TYPE",
          O."CAMPAIGN_START_DATE",
          O."BUSINESS_UNIT",
          O."SALES_FORCE_ID",
          O."CUSTOMER_ID",
          O."ORDER_REVISION_NUMBER",
          O."SUBMITTED_DATE",
          O."STATUS_HEADER",
          O."REASON_CODE",
          O."COMMISSION_TRANSACTION_TYPE",
          O."SOURCE_SYSTEM",
          O."ROW_ID",
          O."PRODUCT",
          O."PART_NUMBER",
          O."ACTION_CODE",
          O."TRANSFER_TYPE",
          O."EVENT_SOURCE",
          O."PROD_PROM_ID",
          O."PROVISIONED_DATE",
          O."NET_PRICE",
          O."COMMISSION_PRODUCT_TYPE",
          O."COMMISSIONABLE",
          O."STATUS_ORDER_LINE_ITEM",
          O."ORIGINAL_ORDER_NUMBER",
          O."HARDWARE_SUPPLIED_FLAG",
          O."SUB_ACTION_CODE",
          O."PROMOTION_INTEGRATION_ID",
          O."NGB_PROD_TYPE",
          O."PROMOTION_PART_NUMBER",
          O."PRODUCT_ID",
          O."O2A_STATUS",
          O."PARENT_ITEM_ROW_ID",
          O."ROOT_ITEM_ROW_ID",
          O."CONTRACT_START_DATE",
          O."CONTRACT_END_DATE",
          O."LIST_PRICE",
          O."HARDWARE_ASSOCIATION_ID",
          O."EFFECTIVE_DATE"
     FROM FHW_OLI O
   UNION ALL
   SELECT CAST ('HW_ASSOC_CONTRACT_OLI' AS VARCHAR2 (30)) AS "REC_TYPE",
          O."FILENAME",
          O."BATCHPROCESSDATE",
          O."RECORDNUMBER",
          O."IS_FILTERED",
          O."ORDER_NUMBER",
          O."BILLING_ACCOUNT",
          O."CUSTOMER_LAST_NAME",
          O."CUSTOMER_FIRST_NAME",
          O."ORDER_TYPE",
          O."ORDER_SUB_TYPE",
          O."CREATED_DATE",
          O."PARTNER_CODE",
          O."CAMPAIGN_NAME",
          O."CAMPAIGN_NUMBER",
          O."CAMPAIGN_TYPE",
          O."CHANNEL_TYPE",
          O."CAMPAIGN_START_DATE",
          O."BUSINESS_UNIT",
          O."SALES_FORCE_ID",
          O."CUSTOMER_ID",
          O."ORDER_REVISION_NUMBER",
          O."SUBMITTED_DATE",
          O."STATUS_HEADER",
          O."REASON_CODE",
          O."COMMISSION_TRANSACTION_TYPE",
          O."SOURCE_SYSTEM",
          O."ROW_ID",
          O."PRODUCT",
          O."PART_NUMBER",
          O."ACTION_CODE",
          O."TRANSFER_TYPE",
          O."EVENT_SOURCE",
          O."PROD_PROM_ID",
          O."PROVISIONED_DATE",
          O."NET_PRICE",
          O."COMMISSION_PRODUCT_TYPE",
          O."COMMISSIONABLE",
          O."STATUS_ORDER_LINE_ITEM",
          O."ORIGINAL_ORDER_NUMBER",
          O."HARDWARE_SUPPLIED_FLAG",
          O."SUB_ACTION_CODE",
          O."PROMOTION_INTEGRATION_ID",
          O."NGB_PROD_TYPE",
          O."PROMOTION_PART_NUMBER",
          O."PRODUCT_ID",
          O."O2A_STATUS",
          O."PARENT_ITEM_ROW_ID",
          O."ROOT_ITEM_ROW_ID",
          O."CONTRACT_START_DATE",
          O."CONTRACT_END_DATE",
          O."LIST_PRICE",
          O."HARDWARE_ASSOCIATION_ID",
          O."EFFECTIVE_DATE"
     FROM HW_ASSOC_CONTRACT_OLI O
   UNION ALL
   SELECT CAST ('HW_ASSOC_MOLI' AS VARCHAR2 (30)) AS "REC_TYPE",
          M."FILENAME",
          M."BATCHPROCESSDATE",
          M."RECORDNUMBER",
          M."IS_FILTERED",
          M."ORDER_NUMBER",
          M."BILLING_ACCOUNT",
          M."CUSTOMER_LAST_NAME",
          M."CUSTOMER_FIRST_NAME",
          M."ORDER_TYPE",
          M."ORDER_SUB_TYPE",
          M."CREATED_DATE",
          M."PARTNER_CODE",
          M."CAMPAIGN_NAME",
          M."CAMPAIGN_NUMBER",
          M."CAMPAIGN_TYPE",
          M."CHANNEL_TYPE",
          M."CAMPAIGN_START_DATE",
          M."BUSINESS_UNIT",
          M."SALES_FORCE_ID",
          M."CUSTOMER_ID",
          M."ORDER_REVISION_NUMBER",
          M."SUBMITTED_DATE",
          M."STATUS_HEADER",
          M."REASON_CODE",
          M."COMMISSION_TRANSACTION_TYPE",
          M."SOURCE_SYSTEM",
          M."ROW_ID",
          M."PRODUCT",
          M."PART_NUMBER",
          M."ACTION_CODE",
          M."TRANSFER_TYPE",
          M."EVENT_SOURCE",
          M."PROD_PROM_ID",
          M."PROVISIONED_DATE",
          M."NET_PRICE",
          M."COMMISSION_PRODUCT_TYPE",
          M."COMMISSIONABLE",
          M."STATUS_ORDER_LINE_ITEM",
          M."ORIGINAL_ORDER_NUMBER",
          M."HARDWARE_SUPPLIED_FLAG",
          M."SUB_ACTION_CODE",
          M."PROMOTION_INTEGRATION_ID",
          M."NGB_PROD_TYPE",
          M."PROMOTION_PART_NUMBER",
          M."PRODUCT_ID",
          M."O2A_STATUS",
          M."PARENT_ITEM_ROW_ID",
          M."ROOT_ITEM_ROW_ID",
          M."CONTRACT_START_DATE",
          M."CONTRACT_END_DATE",
          M."LIST_PRICE",
          M."HARDWARE_ASSOCIATION_ID",
          M."EFFECTIVE_DATE"
     FROM HW_ASSOC_MOLI M
   UNION ALL
   SELECT CAST ('HW_ASSOC_MRO_OLI' AS VARCHAR2 (30)) AS "REC_TYPE",
          O."FILENAME",
          O."BATCHPROCESSDATE",
          O."RECORDNUMBER",
          O."IS_FILTERED",
          O."ORDER_NUMBER",
          O."BILLING_ACCOUNT",
          O."CUSTOMER_LAST_NAME",
          O."CUSTOMER_FIRST_NAME",
          O."ORDER_TYPE",
          O."ORDER_SUB_TYPE",
          O."CREATED_DATE",
          O."PARTNER_CODE",
          O."CAMPAIGN_NAME",
          O."CAMPAIGN_NUMBER",
          O."CAMPAIGN_TYPE",
          O."CHANNEL_TYPE",
          O."CAMPAIGN_START_DATE",
          O."BUSINESS_UNIT",
          O."SALES_FORCE_ID",
          O."CUSTOMER_ID",
          O."ORDER_REVISION_NUMBER",
          O."SUBMITTED_DATE",
          O."STATUS_HEADER",
          O."REASON_CODE",
          O."COMMISSION_TRANSACTION_TYPE",
          O."SOURCE_SYSTEM",
          O."ROW_ID",
          O."PRODUCT",
          O."PART_NUMBER",
          O."ACTION_CODE",
          O."TRANSFER_TYPE",
          O."EVENT_SOURCE",
          O."PROD_PROM_ID",
          O."PROVISIONED_DATE",
          O."NET_PRICE",
          O."COMMISSION_PRODUCT_TYPE",
          O."COMMISSIONABLE",
          O."STATUS_ORDER_LINE_ITEM",
          O."ORIGINAL_ORDER_NUMBER",
          O."HARDWARE_SUPPLIED_FLAG",
          O."SUB_ACTION_CODE",
          O."PROMOTION_INTEGRATION_ID",
          O."NGB_PROD_TYPE",
          O."PROMOTION_PART_NUMBER",
          O."PRODUCT_ID",
          O."O2A_STATUS",
          O."PARENT_ITEM_ROW_ID",
          O."ROOT_ITEM_ROW_ID",
          O."CONTRACT_START_DATE",
          O."CONTRACT_END_DATE",
          O."LIST_PRICE",
          O."HARDWARE_ASSOCIATION_ID",
          O."EFFECTIVE_DATE"
     FROM HW_ASSOC_MRO_OLI O
   UNION ALL
   SELECT CAST ('HW_ASSOC_PLAN_OLI' AS VARCHAR2 (30)) AS "REC_TYPE",
          O."FILENAME",
          O."BATCHPROCESSDATE",
          O."RECORDNUMBER",
          O."IS_FILTERED",
          O."ORDER_NUMBER",
          O."BILLING_ACCOUNT",
          O."CUSTOMER_LAST_NAME",
          O."CUSTOMER_FIRST_NAME",
          O."ORDER_TYPE",
          O."ORDER_SUB_TYPE",
          O."CREATED_DATE",
          O."PARTNER_CODE",
          O."CAMPAIGN_NAME",
          O."CAMPAIGN_NUMBER",
          O."CAMPAIGN_TYPE",
          O."CHANNEL_TYPE",
          O."CAMPAIGN_START_DATE",
          O."BUSINESS_UNIT",
          O."SALES_FORCE_ID",
          O."CUSTOMER_ID",
          O."ORDER_REVISION_NUMBER",
          O."SUBMITTED_DATE",
          O."STATUS_HEADER",
          O."REASON_CODE",
          O."COMMISSION_TRANSACTION_TYPE",
          O."SOURCE_SYSTEM",
          O."ROW_ID",
          O."PRODUCT",
          O."PART_NUMBER",
          O."ACTION_CODE",
          O."TRANSFER_TYPE",
          O."EVENT_SOURCE",
          O."PROD_PROM_ID",
          O."PROVISIONED_DATE",
          O."NET_PRICE",
          O."COMMISSION_PRODUCT_TYPE",
          O."COMMISSIONABLE",
          O."STATUS_ORDER_LINE_ITEM",
          O."ORIGINAL_ORDER_NUMBER",
          O."HARDWARE_SUPPLIED_FLAG",
          O."SUB_ACTION_CODE",
          O."PROMOTION_INTEGRATION_ID",
          O."NGB_PROD_TYPE",
          O."PROMOTION_PART_NUMBER",
          O."PRODUCT_ID",
          O."O2A_STATUS",
          O."PARENT_ITEM_ROW_ID",
          O."ROOT_ITEM_ROW_ID",
          O."CONTRACT_START_DATE",
          O."CONTRACT_END_DATE",
          O."LIST_PRICE",
          O."HARDWARE_ASSOCIATION_ID",
          O."EFFECTIVE_DATE"
     FROM HW_ASSOC_PLAN_OLI O
   UNION ALL
   SELECT CAST ('HW_OLI' AS VARCHAR2 (30)) AS "REC_TYPE",
          O."FILENAME",
          O."BATCHPROCESSDATE",
          O."RECORDNUMBER",
          O."IS_FILTERED",
          O."ORDER_NUMBER",
          O."BILLING_ACCOUNT",
          O."CUSTOMER_LAST_NAME",
          O."CUSTOMER_FIRST_NAME",
          O."ORDER_TYPE",
          O."ORDER_SUB_TYPE",
          O."CREATED_DATE",
          O."PARTNER_CODE",
          O."CAMPAIGN_NAME",
          O."CAMPAIGN_NUMBER",
          O."CAMPAIGN_TYPE",
          O."CHANNEL_TYPE",
          O."CAMPAIGN_START_DATE",
          O."BUSINESS_UNIT",
          O."SALES_FORCE_ID",
          O."CUSTOMER_ID",
          O."ORDER_REVISION_NUMBER",
          O."SUBMITTED_DATE",
          O."STATUS_HEADER",
          O."REASON_CODE",
          O."COMMISSION_TRANSACTION_TYPE",
          O."SOURCE_SYSTEM",
          O."ROW_ID",
          O."PRODUCT",
          O."PART_NUMBER",
          O."ACTION_CODE",
          O."TRANSFER_TYPE",
          O."EVENT_SOURCE",
          O."PROD_PROM_ID",
          O."PROVISIONED_DATE",
          O."NET_PRICE",
          O."COMMISSION_PRODUCT_TYPE",
          O."COMMISSIONABLE",
          O."STATUS_ORDER_LINE_ITEM",
          O."ORIGINAL_ORDER_NUMBER",
          O."HARDWARE_SUPPLIED_FLAG",
          O."SUB_ACTION_CODE",
          O."PROMOTION_INTEGRATION_ID",
          O."NGB_PROD_TYPE",
          O."PROMOTION_PART_NUMBER",
          O."PRODUCT_ID",
          O."O2A_STATUS",
          O."PARENT_ITEM_ROW_ID",
          O."ROOT_ITEM_ROW_ID",
          O."CONTRACT_START_DATE",
          O."CONTRACT_END_DATE",
          O."LIST_PRICE",
          O."HARDWARE_ASSOCIATION_ID",
          O."EFFECTIVE_DATE"
     FROM HW_OLI O
   UNION ALL
   SELECT CAST ('MAIN_CONTRACT_OLI' AS VARCHAR2 (30)) AS "REC_TYPE",
          O."FILENAME",
          O."BATCHPROCESSDATE",
          O."RECORDNUMBER",
          O."IS_FILTERED",
          O."ORDER_NUMBER",
          O."BILLING_ACCOUNT",
          O."CUSTOMER_LAST_NAME",
          O."CUSTOMER_FIRST_NAME",
          O."ORDER_TYPE",
          O."ORDER_SUB_TYPE",
          O."CREATED_DATE",
          O."PARTNER_CODE",
          O."CAMPAIGN_NAME",
          O."CAMPAIGN_NUMBER",
          O."CAMPAIGN_TYPE",
          O."CHANNEL_TYPE",
          O."CAMPAIGN_START_DATE",
          O."BUSINESS_UNIT",
          O."SALES_FORCE_ID",
          O."CUSTOMER_ID",
          O."ORDER_REVISION_NUMBER",
          O."SUBMITTED_DATE",
          O."STATUS_HEADER",
          O."REASON_CODE",
          O."COMMISSION_TRANSACTION_TYPE",
          O."SOURCE_SYSTEM",
          O."ROW_ID",
          O."PRODUCT",
          O."PART_NUMBER",
          O."ACTION_CODE",
          O."TRANSFER_TYPE",
          O."EVENT_SOURCE",
          O."PROD_PROM_ID",
          O."PROVISIONED_DATE",
          O."NET_PRICE",
          O."COMMISSION_PRODUCT_TYPE",
          O."COMMISSIONABLE",
          O."STATUS_ORDER_LINE_ITEM",
          O."ORIGINAL_ORDER_NUMBER",
          O."HARDWARE_SUPPLIED_FLAG",
          O."SUB_ACTION_CODE",
          O."PROMOTION_INTEGRATION_ID",
          O."NGB_PROD_TYPE",
          O."PROMOTION_PART_NUMBER",
          O."PRODUCT_ID",
          O."O2A_STATUS",
          O."PARENT_ITEM_ROW_ID",
          O."ROOT_ITEM_ROW_ID",
          O."CONTRACT_START_DATE",
          O."CONTRACT_END_DATE",
          O."LIST_PRICE",
          O."HARDWARE_ASSOCIATION_ID",
          O."EFFECTIVE_DATE"
     FROM MAIN_CONTRACT_OLI O
   UNION ALL
   SELECT CAST ('MP_ASSOC_CONTRACT_ADD_OLI' AS VARCHAR2 (30)) AS "REC_TYPE",
          O."FILENAME",
          O."BATCHPROCESSDATE",
          O."RECORDNUMBER",
          O."IS_FILTERED",
          O."ORDER_NUMBER",
          O."BILLING_ACCOUNT",
          O."CUSTOMER_LAST_NAME",
          O."CUSTOMER_FIRST_NAME",
          O."ORDER_TYPE",
          O."ORDER_SUB_TYPE",
          O."CREATED_DATE",
          O."PARTNER_CODE",
          O."CAMPAIGN_NAME",
          O."CAMPAIGN_NUMBER",
          O."CAMPAIGN_TYPE",
          O."CHANNEL_TYPE",
          O."CAMPAIGN_START_DATE",
          O."BUSINESS_UNIT",
          O."SALES_FORCE_ID",
          O."CUSTOMER_ID",
          O."ORDER_REVISION_NUMBER",
          O."SUBMITTED_DATE",
          O."STATUS_HEADER",
          O."REASON_CODE",
          O."COMMISSION_TRANSACTION_TYPE",
          O."SOURCE_SYSTEM",
          O."ROW_ID",
          O."PRODUCT",
          O."PART_NUMBER",
          O."ACTION_CODE",
          O."TRANSFER_TYPE",
          O."EVENT_SOURCE",
          O."PROD_PROM_ID",
          O."PROVISIONED_DATE",
          O."NET_PRICE",
          O."COMMISSION_PRODUCT_TYPE",
          O."COMMISSIONABLE",
          O."STATUS_ORDER_LINE_ITEM",
          O."ORIGINAL_ORDER_NUMBER",
          O."HARDWARE_SUPPLIED_FLAG",
          O."SUB_ACTION_CODE",
          O."PROMOTION_INTEGRATION_ID",
          O."NGB_PROD_TYPE",
          O."PROMOTION_PART_NUMBER",
          O."PRODUCT_ID",
          O."O2A_STATUS",
          O."PARENT_ITEM_ROW_ID",
          O."ROOT_ITEM_ROW_ID",
          O."CONTRACT_START_DATE",
          O."CONTRACT_END_DATE",
          O."LIST_PRICE",
          O."HARDWARE_ASSOCIATION_ID",
          O."EFFECTIVE_DATE"
     FROM MP_ASSOC_CONTRACT_ADD_OLI O
   UNION ALL
   SELECT CAST ('MP_ASSOC_CONTRACT_DEL_OLI' AS VARCHAR2 (30)) AS "REC_TYPE",
          O."FILENAME",
          O."BATCHPROCESSDATE",
          O."RECORDNUMBER",
          O."IS_FILTERED",
          O."ORDER_NUMBER",
          O."BILLING_ACCOUNT",
          O."CUSTOMER_LAST_NAME",
          O."CUSTOMER_FIRST_NAME",
          O."ORDER_TYPE",
          O."ORDER_SUB_TYPE",
          O."CREATED_DATE",
          O."PARTNER_CODE",
          O."CAMPAIGN_NAME",
          O."CAMPAIGN_NUMBER",
          O."CAMPAIGN_TYPE",
          O."CHANNEL_TYPE",
          O."CAMPAIGN_START_DATE",
          O."BUSINESS_UNIT",
          O."SALES_FORCE_ID",
          O."CUSTOMER_ID",
          O."ORDER_REVISION_NUMBER",
          O."SUBMITTED_DATE",
          O."STATUS_HEADER",
          O."REASON_CODE",
          O."COMMISSION_TRANSACTION_TYPE",
          O."SOURCE_SYSTEM",
          O."ROW_ID",
          O."PRODUCT",
          O."PART_NUMBER",
          O."ACTION_CODE",
          O."TRANSFER_TYPE",
          O."EVENT_SOURCE",
          O."PROD_PROM_ID",
          O."PROVISIONED_DATE",
          O."NET_PRICE",
          O."COMMISSION_PRODUCT_TYPE",
          O."COMMISSIONABLE",
          O."STATUS_ORDER_LINE_ITEM",
          O."ORIGINAL_ORDER_NUMBER",
          O."HARDWARE_SUPPLIED_FLAG",
          O."SUB_ACTION_CODE",
          O."PROMOTION_INTEGRATION_ID",
          O."NGB_PROD_TYPE",
          O."PROMOTION_PART_NUMBER",
          O."PRODUCT_ID",
          O."O2A_STATUS",
          O."PARENT_ITEM_ROW_ID",
          O."ROOT_ITEM_ROW_ID",
          O."CONTRACT_START_DATE",
          O."CONTRACT_END_DATE",
          O."LIST_PRICE",
          O."HARDWARE_ASSOCIATION_ID",
          O."EFFECTIVE_DATE"
     FROM MP_ASSOC_CONTRACT_DEL_OLI O
   UNION ALL
   SELECT CAST ('MP_ASSOC_CONVERT_PLAN_OLI' AS VARCHAR2 (30)) AS "REC_TYPE",
          O."FILENAME",
          O."BATCHPROCESSDATE",
          O."RECORDNUMBER",
          O."IS_FILTERED",
          O."ORDER_NUMBER",
          O."BILLING_ACCOUNT",
          O."CUSTOMER_LAST_NAME",
          O."CUSTOMER_FIRST_NAME",
          O."ORDER_TYPE",
          O."ORDER_SUB_TYPE",
          O."CREATED_DATE",
          O."PARTNER_CODE",
          O."CAMPAIGN_NAME",
          O."CAMPAIGN_NUMBER",
          O."CAMPAIGN_TYPE",
          O."CHANNEL_TYPE",
          O."CAMPAIGN_START_DATE",
          O."BUSINESS_UNIT",
          O."SALES_FORCE_ID",
          O."CUSTOMER_ID",
          O."ORDER_REVISION_NUMBER",
          O."SUBMITTED_DATE",
          O."STATUS_HEADER",
          O."REASON_CODE",
          O."COMMISSION_TRANSACTION_TYPE",
          O."SOURCE_SYSTEM",
          O."ROW_ID",
          O."PRODUCT",
          O."PART_NUMBER",
          O."ACTION_CODE",
          O."TRANSFER_TYPE",
          O."EVENT_SOURCE",
          O."PROD_PROM_ID",
          O."PROVISIONED_DATE",
          O."NET_PRICE",
          O."COMMISSION_PRODUCT_TYPE",
          O."COMMISSIONABLE",
          O."STATUS_ORDER_LINE_ITEM",
          O."ORIGINAL_ORDER_NUMBER",
          O."HARDWARE_SUPPLIED_FLAG",
          O."SUB_ACTION_CODE",
          O."PROMOTION_INTEGRATION_ID",
          O."NGB_PROD_TYPE",
          O."PROMOTION_PART_NUMBER",
          O."PRODUCT_ID",
          O."O2A_STATUS",
          O."PARENT_ITEM_ROW_ID",
          O."ROOT_ITEM_ROW_ID",
          O."CONTRACT_START_DATE",
          O."CONTRACT_END_DATE",
          O."LIST_PRICE",
          O."HARDWARE_ASSOCIATION_ID",
          O."EFFECTIVE_DATE"
     FROM MP_ASSOC_CONVERT_PLAN_OLI O
   UNION ALL
   SELECT CAST ('MP_ASSOC_FHW_OLI' AS VARCHAR2 (30)) AS "REC_TYPE",
          O."FILENAME",
          O."BATCHPROCESSDATE",
          O."RECORDNUMBER",
          O."IS_FILTERED",
          O."ORDER_NUMBER",
          O."BILLING_ACCOUNT",
          O."CUSTOMER_LAST_NAME",
          O."CUSTOMER_FIRST_NAME",
          O."ORDER_TYPE",
          O."ORDER_SUB_TYPE",
          O."CREATED_DATE",
          O."PARTNER_CODE",
          O."CAMPAIGN_NAME",
          O."CAMPAIGN_NUMBER",
          O."CAMPAIGN_TYPE",
          O."CHANNEL_TYPE",
          O."CAMPAIGN_START_DATE",
          O."BUSINESS_UNIT",
          O."SALES_FORCE_ID",
          O."CUSTOMER_ID",
          O."ORDER_REVISION_NUMBER",
          O."SUBMITTED_DATE",
          O."STATUS_HEADER",
          O."REASON_CODE",
          O."COMMISSION_TRANSACTION_TYPE",
          O."SOURCE_SYSTEM",
          O."ROW_ID",
          O."PRODUCT",
          O."PART_NUMBER",
          O."ACTION_CODE",
          O."TRANSFER_TYPE",
          O."EVENT_SOURCE",
          O."PROD_PROM_ID",
          O."PROVISIONED_DATE",
          O."NET_PRICE",
          O."COMMISSION_PRODUCT_TYPE",
          O."COMMISSIONABLE",
          O."STATUS_ORDER_LINE_ITEM",
          O."ORIGINAL_ORDER_NUMBER",
          O."HARDWARE_SUPPLIED_FLAG",
          O."SUB_ACTION_CODE",
          O."PROMOTION_INTEGRATION_ID",
          O."NGB_PROD_TYPE",
          O."PROMOTION_PART_NUMBER",
          O."PRODUCT_ID",
          O."O2A_STATUS",
          O."PARENT_ITEM_ROW_ID",
          O."ROOT_ITEM_ROW_ID",
          O."CONTRACT_START_DATE",
          O."CONTRACT_END_DATE",
          O."LIST_PRICE",
          O."HARDWARE_ASSOCIATION_ID",
          O."EFFECTIVE_DATE"
     FROM MP_ASSOC_FHW_OLI O
   UNION ALL
   SELECT CAST ('MP_ASSOC_HW_OLI' AS VARCHAR2 (30)) AS "REC_TYPE",
          O."FILENAME",
          O."BATCHPROCESSDATE",
          O."RECORDNUMBER",
          O."IS_FILTERED",
          O."ORDER_NUMBER",
          O."BILLING_ACCOUNT",
          O."CUSTOMER_LAST_NAME",
          O."CUSTOMER_FIRST_NAME",
          O."ORDER_TYPE",
          O."ORDER_SUB_TYPE",
          O."CREATED_DATE",
          O."PARTNER_CODE",
          O."CAMPAIGN_NAME",
          O."CAMPAIGN_NUMBER",
          O."CAMPAIGN_TYPE",
          O."CHANNEL_TYPE",
          O."CAMPAIGN_START_DATE",
          O."BUSINESS_UNIT",
          O."SALES_FORCE_ID",
          O."CUSTOMER_ID",
          O."ORDER_REVISION_NUMBER",
          O."SUBMITTED_DATE",
          O."STATUS_HEADER",
          O."REASON_CODE",
          O."COMMISSION_TRANSACTION_TYPE",
          O."SOURCE_SYSTEM",
          O."ROW_ID",
          O."PRODUCT",
          O."PART_NUMBER",
          O."ACTION_CODE",
          O."TRANSFER_TYPE",
          O."EVENT_SOURCE",
          O."PROD_PROM_ID",
          O."PROVISIONED_DATE",
          O."NET_PRICE",
          O."COMMISSION_PRODUCT_TYPE",
          O."COMMISSIONABLE",
          O."STATUS_ORDER_LINE_ITEM",
          O."ORIGINAL_ORDER_NUMBER",
          O."HARDWARE_SUPPLIED_FLAG",
          O."SUB_ACTION_CODE",
          O."PROMOTION_INTEGRATION_ID",
          O."NGB_PROD_TYPE",
          O."PROMOTION_PART_NUMBER",
          O."PRODUCT_ID",
          O."O2A_STATUS",
          O."PARENT_ITEM_ROW_ID",
          O."ROOT_ITEM_ROW_ID",
          O."CONTRACT_START_DATE",
          O."CONTRACT_END_DATE",
          O."LIST_PRICE",
          O."HARDWARE_ASSOCIATION_ID",
          O."EFFECTIVE_DATE"
     FROM MP_ASSOC_HW_OLI O
   UNION ALL
   SELECT CAST ('MP_ASSOC_MAIN_CONT_ADD_OLI' AS VARCHAR2 (30)) AS "REC_TYPE",
          O."FILENAME",
          O."BATCHPROCESSDATE",
          O."RECORDNUMBER",
          O."IS_FILTERED",
          O."ORDER_NUMBER",
          O."BILLING_ACCOUNT",
          O."CUSTOMER_LAST_NAME",
          O."CUSTOMER_FIRST_NAME",
          O."ORDER_TYPE",
          O."ORDER_SUB_TYPE",
          O."CREATED_DATE",
          O."PARTNER_CODE",
          O."CAMPAIGN_NAME",
          O."CAMPAIGN_NUMBER",
          O."CAMPAIGN_TYPE",
          O."CHANNEL_TYPE",
          O."CAMPAIGN_START_DATE",
          O."BUSINESS_UNIT",
          O."SALES_FORCE_ID",
          O."CUSTOMER_ID",
          O."ORDER_REVISION_NUMBER",
          O."SUBMITTED_DATE",
          O."STATUS_HEADER",
          O."REASON_CODE",
          O."COMMISSION_TRANSACTION_TYPE",
          O."SOURCE_SYSTEM",
          O."ROW_ID",
          O."PRODUCT",
          O."PART_NUMBER",
          O."ACTION_CODE",
          O."TRANSFER_TYPE",
          O."EVENT_SOURCE",
          O."PROD_PROM_ID",
          O."PROVISIONED_DATE",
          O."NET_PRICE",
          O."COMMISSION_PRODUCT_TYPE",
          O."COMMISSIONABLE",
          O."STATUS_ORDER_LINE_ITEM",
          O."ORIGINAL_ORDER_NUMBER",
          O."HARDWARE_SUPPLIED_FLAG",
          O."SUB_ACTION_CODE",
          O."PROMOTION_INTEGRATION_ID",
          O."NGB_PROD_TYPE",
          O."PROMOTION_PART_NUMBER",
          O."PRODUCT_ID",
          O."O2A_STATUS",
          O."PARENT_ITEM_ROW_ID",
          O."ROOT_ITEM_ROW_ID",
          O."CONTRACT_START_DATE",
          O."CONTRACT_END_DATE",
          O."LIST_PRICE",
          O."HARDWARE_ASSOCIATION_ID",
          O."EFFECTIVE_DATE"
     FROM MP_ASSOC_MAIN_CONT_ADD_OLI O
   UNION ALL
   SELECT CAST ('MP_ASSOC_MAIN_CONT_DEL_OLI' AS VARCHAR2 (30)) AS "REC_TYPE",
          O."FILENAME",
          O."BATCHPROCESSDATE",
          O."RECORDNUMBER",
          O."IS_FILTERED",
          O."ORDER_NUMBER",
          O."BILLING_ACCOUNT",
          O."CUSTOMER_LAST_NAME",
          O."CUSTOMER_FIRST_NAME",
          O."ORDER_TYPE",
          O."ORDER_SUB_TYPE",
          O."CREATED_DATE",
          O."PARTNER_CODE",
          O."CAMPAIGN_NAME",
          O."CAMPAIGN_NUMBER",
          O."CAMPAIGN_TYPE",
          O."CHANNEL_TYPE",
          O."CAMPAIGN_START_DATE",
          O."BUSINESS_UNIT",
          O."SALES_FORCE_ID",
          O."CUSTOMER_ID",
          O."ORDER_REVISION_NUMBER",
          O."SUBMITTED_DATE",
          O."STATUS_HEADER",
          O."REASON_CODE",
          O."COMMISSION_TRANSACTION_TYPE",
          O."SOURCE_SYSTEM",
          O."ROW_ID",
          O."PRODUCT",
          O."PART_NUMBER",
          O."ACTION_CODE",
          O."TRANSFER_TYPE",
          O."EVENT_SOURCE",
          O."PROD_PROM_ID",
          O."PROVISIONED_DATE",
          O."NET_PRICE",
          O."COMMISSION_PRODUCT_TYPE",
          O."COMMISSIONABLE",
          O."STATUS_ORDER_LINE_ITEM",
          O."ORIGINAL_ORDER_NUMBER",
          O."HARDWARE_SUPPLIED_FLAG",
          O."SUB_ACTION_CODE",
          O."PROMOTION_INTEGRATION_ID",
          O."NGB_PROD_TYPE",
          O."PROMOTION_PART_NUMBER",
          O."PRODUCT_ID",
          O."O2A_STATUS",
          O."PARENT_ITEM_ROW_ID",
          O."ROOT_ITEM_ROW_ID",
          O."CONTRACT_START_DATE",
          O."CONTRACT_END_DATE",
          O."LIST_PRICE",
          O."HARDWARE_ASSOCIATION_ID",
          O."EFFECTIVE_DATE"
     FROM MP_ASSOC_MAIN_CONT_DEL_OLI O
   UNION ALL
   SELECT CAST ('MP_ASSOC_MAIN_PLAN_DEL_OLI' AS VARCHAR2 (30)) AS "REC_TYPE",
          O."FILENAME",
          O."BATCHPROCESSDATE",
          O."RECORDNUMBER",
          O."IS_FILTERED",
          O."ORDER_NUMBER",
          O."BILLING_ACCOUNT",
          O."CUSTOMER_LAST_NAME",
          O."CUSTOMER_FIRST_NAME",
          O."ORDER_TYPE",
          O."ORDER_SUB_TYPE",
          O."CREATED_DATE",
          O."PARTNER_CODE",
          O."CAMPAIGN_NAME",
          O."CAMPAIGN_NUMBER",
          O."CAMPAIGN_TYPE",
          O."CHANNEL_TYPE",
          O."CAMPAIGN_START_DATE",
          O."BUSINESS_UNIT",
          O."SALES_FORCE_ID",
          O."CUSTOMER_ID",
          O."ORDER_REVISION_NUMBER",
          O."SUBMITTED_DATE",
          O."STATUS_HEADER",
          O."REASON_CODE",
          O."COMMISSION_TRANSACTION_TYPE",
          O."SOURCE_SYSTEM",
          O."ROW_ID",
          O."PRODUCT",
          O."PART_NUMBER",
          O."ACTION_CODE",
          O."TRANSFER_TYPE",
          O."EVENT_SOURCE",
          O."PROD_PROM_ID",
          O."PROVISIONED_DATE",
          O."NET_PRICE",
          O."COMMISSION_PRODUCT_TYPE",
          O."COMMISSIONABLE",
          O."STATUS_ORDER_LINE_ITEM",
          O."ORIGINAL_ORDER_NUMBER",
          O."HARDWARE_SUPPLIED_FLAG",
          O."SUB_ACTION_CODE",
          O."PROMOTION_INTEGRATION_ID",
          O."NGB_PROD_TYPE",
          O."PROMOTION_PART_NUMBER",
          O."PRODUCT_ID",
          O."O2A_STATUS",
          O."PARENT_ITEM_ROW_ID",
          O."ROOT_ITEM_ROW_ID",
          O."CONTRACT_START_DATE",
          O."CONTRACT_END_DATE",
          O."LIST_PRICE",
          O."HARDWARE_ASSOCIATION_ID",
          O."EFFECTIVE_DATE"
     FROM MP_ASSOC_MAIN_PLAN_DEL_OLI O
   UNION ALL
   SELECT CAST ('MP_ASSOC_MOLI_PRE_HOLD' AS VARCHAR2 (30)) AS "REC_TYPE",
          M."FILENAME",
          M."BATCHPROCESSDATE",
          M."RECORDNUMBER",
          M."IS_FILTERED",
          M."ORDER_NUMBER",
          M."BILLING_ACCOUNT",
          M."CUSTOMER_LAST_NAME",
          M."CUSTOMER_FIRST_NAME",
          M."ORDER_TYPE",
          M."ORDER_SUB_TYPE",
          M."CREATED_DATE",
          M."PARTNER_CODE",
          M."CAMPAIGN_NAME",
          M."CAMPAIGN_NUMBER",
          M."CAMPAIGN_TYPE",
          M."CHANNEL_TYPE",
          M."CAMPAIGN_START_DATE",
          M."BUSINESS_UNIT",
          M."SALES_FORCE_ID",
          M."CUSTOMER_ID",
          M."ORDER_REVISION_NUMBER",
          M."SUBMITTED_DATE",
          M."STATUS_HEADER",
          M."REASON_CODE",
          M."COMMISSION_TRANSACTION_TYPE",
          M."SOURCE_SYSTEM",
          M."ROW_ID",
          M."PRODUCT",
          M."PART_NUMBER",
          M."ACTION_CODE",
          M."TRANSFER_TYPE",
          M."EVENT_SOURCE",
          M."PROD_PROM_ID",
          M."PROVISIONED_DATE",
          M."NET_PRICE",
          M."COMMISSION_PRODUCT_TYPE",
          M."COMMISSIONABLE",
          M."STATUS_ORDER_LINE_ITEM",
          M."ORIGINAL_ORDER_NUMBER",
          M."HARDWARE_SUPPLIED_FLAG",
          M."SUB_ACTION_CODE",
          M."PROMOTION_INTEGRATION_ID",
          M."NGB_PROD_TYPE",
          M."PROMOTION_PART_NUMBER",
          M."PRODUCT_ID",
          M."O2A_STATUS",
          M."PARENT_ITEM_ROW_ID",
          M."ROOT_ITEM_ROW_ID",
          M."CONTRACT_START_DATE",
          M."CONTRACT_END_DATE",
          M."LIST_PRICE",
          M."HARDWARE_ASSOCIATION_ID",
          M."EFFECTIVE_DATE"
     FROM MP_ASSOC_MOLI_PRE_HOLD M
   UNION ALL
   SELECT CAST ('MP_ASSOC_SERVICE_MOLI' AS VARCHAR2 (30)) AS "REC_TYPE",
          M."FILENAME",
          M."BATCHPROCESSDATE",
          M."RECORDNUMBER",
          M."IS_FILTERED",
          M."ORDER_NUMBER",
          M."BILLING_ACCOUNT",
          M."CUSTOMER_LAST_NAME",
          M."CUSTOMER_FIRST_NAME",
          M."ORDER_TYPE",
          M."ORDER_SUB_TYPE",
          M."CREATED_DATE",
          M."PARTNER_CODE",
          M."CAMPAIGN_NAME",
          M."CAMPAIGN_NUMBER",
          M."CAMPAIGN_TYPE",
          M."CHANNEL_TYPE",
          M."CAMPAIGN_START_DATE",
          M."BUSINESS_UNIT",
          M."SALES_FORCE_ID",
          M."CUSTOMER_ID",
          M."ORDER_REVISION_NUMBER",
          M."SUBMITTED_DATE",
          M."STATUS_HEADER",
          M."REASON_CODE",
          M."COMMISSION_TRANSACTION_TYPE",
          M."SOURCE_SYSTEM",
          M."ROW_ID",
          M."PRODUCT",
          M."PART_NUMBER",
          M."ACTION_CODE",
          M."TRANSFER_TYPE",
          M."EVENT_SOURCE",
          M."PROD_PROM_ID",
          M."PROVISIONED_DATE",
          M."NET_PRICE",
          M."COMMISSION_PRODUCT_TYPE",
          M."COMMISSIONABLE",
          M."STATUS_ORDER_LINE_ITEM",
          M."ORIGINAL_ORDER_NUMBER",
          M."HARDWARE_SUPPLIED_FLAG",
          M."SUB_ACTION_CODE",
          M."PROMOTION_INTEGRATION_ID",
          M."NGB_PROD_TYPE",
          M."PROMOTION_PART_NUMBER",
          M."PRODUCT_ID",
          M."O2A_STATUS",
          M."PARENT_ITEM_ROW_ID",
          M."ROOT_ITEM_ROW_ID",
          M."CONTRACT_START_DATE",
          M."CONTRACT_END_DATE",
          M."LIST_PRICE",
          M."HARDWARE_ASSOCIATION_ID",
          M."EFFECTIVE_DATE"
     FROM MP_ASSOC_SERVICE_MOLI M
   UNION ALL
   SELECT CAST ('MP_ASSOC_SIM_OLI' AS VARCHAR2 (30)) AS "REC_TYPE",
          O."FILENAME",
          O."BATCHPROCESSDATE",
          O."RECORDNUMBER",
          O."IS_FILTERED",
          O."ORDER_NUMBER",
          O."BILLING_ACCOUNT",
          O."CUSTOMER_LAST_NAME",
          O."CUSTOMER_FIRST_NAME",
          O."ORDER_TYPE",
          O."ORDER_SUB_TYPE",
          O."CREATED_DATE",
          O."PARTNER_CODE",
          O."CAMPAIGN_NAME",
          O."CAMPAIGN_NUMBER",
          O."CAMPAIGN_TYPE",
          O."CHANNEL_TYPE",
          O."CAMPAIGN_START_DATE",
          O."BUSINESS_UNIT",
          O."SALES_FORCE_ID",
          O."CUSTOMER_ID",
          O."ORDER_REVISION_NUMBER",
          O."SUBMITTED_DATE",
          O."STATUS_HEADER",
          O."REASON_CODE",
          O."COMMISSION_TRANSACTION_TYPE",
          O."SOURCE_SYSTEM",
          O."ROW_ID",
          O."PRODUCT",
          O."PART_NUMBER",
          O."ACTION_CODE",
          O."TRANSFER_TYPE",
          O."EVENT_SOURCE",
          O."PROD_PROM_ID",
          O."PROVISIONED_DATE",
          O."NET_PRICE",
          O."COMMISSION_PRODUCT_TYPE",
          O."COMMISSIONABLE",
          O."STATUS_ORDER_LINE_ITEM",
          O."ORIGINAL_ORDER_NUMBER",
          O."HARDWARE_SUPPLIED_FLAG",
          O."SUB_ACTION_CODE",
          O."PROMOTION_INTEGRATION_ID",
          O."NGB_PROD_TYPE",
          O."PROMOTION_PART_NUMBER",
          O."PRODUCT_ID",
          O."O2A_STATUS",
          O."PARENT_ITEM_ROW_ID",
          O."ROOT_ITEM_ROW_ID",
          O."CONTRACT_START_DATE",
          O."CONTRACT_END_DATE",
          O."LIST_PRICE",
          O."HARDWARE_ASSOCIATION_ID",
          O."EFFECTIVE_DATE"
     FROM MP_ASSOC_SIM_OLI O
   UNION ALL
   SELECT CAST ('MP_OLI' AS VARCHAR2 (30)) AS "REC_TYPE",
          O."FILENAME",
          O."BATCHPROCESSDATE",
          O."RECORDNUMBER",
          O."IS_FILTERED",
          O."ORDER_NUMBER",
          O."BILLING_ACCOUNT",
          O."CUSTOMER_LAST_NAME",
          O."CUSTOMER_FIRST_NAME",
          O."ORDER_TYPE",
          O."ORDER_SUB_TYPE",
          O."CREATED_DATE",
          O."PARTNER_CODE",
          O."CAMPAIGN_NAME",
          O."CAMPAIGN_NUMBER",
          O."CAMPAIGN_TYPE",
          O."CHANNEL_TYPE",
          O."CAMPAIGN_START_DATE",
          O."BUSINESS_UNIT",
          O."SALES_FORCE_ID",
          O."CUSTOMER_ID",
          O."ORDER_REVISION_NUMBER",
          O."SUBMITTED_DATE",
          O."STATUS_HEADER",
          O."REASON_CODE",
          O."COMMISSION_TRANSACTION_TYPE",
          O."SOURCE_SYSTEM",
          O."ROW_ID",
          O."PRODUCT",
          O."PART_NUMBER",
          O."ACTION_CODE",
          O."TRANSFER_TYPE",
          O."EVENT_SOURCE",
          O."PROD_PROM_ID",
          O."PROVISIONED_DATE",
          O."NET_PRICE",
          O."COMMISSION_PRODUCT_TYPE",
          O."COMMISSIONABLE",
          O."STATUS_ORDER_LINE_ITEM",
          O."ORIGINAL_ORDER_NUMBER",
          O."HARDWARE_SUPPLIED_FLAG",
          O."SUB_ACTION_CODE",
          O."PROMOTION_INTEGRATION_ID",
          O."NGB_PROD_TYPE",
          O."PROMOTION_PART_NUMBER",
          O."PRODUCT_ID",
          O."O2A_STATUS",
          O."PARENT_ITEM_ROW_ID",
          O."ROOT_ITEM_ROW_ID",
          O."CONTRACT_START_DATE",
          O."CONTRACT_END_DATE",
          O."LIST_PRICE",
          O."HARDWARE_ASSOCIATION_ID",
          O."EFFECTIVE_DATE"
     FROM MP_OLI O
   UNION ALL
   SELECT CAST ('SERVICE_ASSOC_ACCESS_TYPE_OLI' AS VARCHAR2 (30))
             AS "REC_TYPE",
          O."FILENAME",
          O."BATCHPROCESSDATE",
          O."RECORDNUMBER",
          O."IS_FILTERED",
          O."ORDER_NUMBER",
          O."BILLING_ACCOUNT",
          O."CUSTOMER_LAST_NAME",
          O."CUSTOMER_FIRST_NAME",
          O."ORDER_TYPE",
          O."ORDER_SUB_TYPE",
          O."CREATED_DATE",
          O."PARTNER_CODE",
          O."CAMPAIGN_NAME",
          O."CAMPAIGN_NUMBER",
          O."CAMPAIGN_TYPE",
          O."CHANNEL_TYPE",
          O."CAMPAIGN_START_DATE",
          O."BUSINESS_UNIT",
          O."SALES_FORCE_ID",
          O."CUSTOMER_ID",
          O."ORDER_REVISION_NUMBER",
          O."SUBMITTED_DATE",
          O."STATUS_HEADER",
          O."REASON_CODE",
          O."COMMISSION_TRANSACTION_TYPE",
          O."SOURCE_SYSTEM",
          O."ROW_ID",
          O."PRODUCT",
          O."PART_NUMBER",
          O."ACTION_CODE",
          O."TRANSFER_TYPE",
          O."EVENT_SOURCE",
          O."PROD_PROM_ID",
          O."PROVISIONED_DATE",
          O."NET_PRICE",
          O."COMMISSION_PRODUCT_TYPE",
          O."COMMISSIONABLE",
          O."STATUS_ORDER_LINE_ITEM",
          O."ORIGINAL_ORDER_NUMBER",
          O."HARDWARE_SUPPLIED_FLAG",
          O."SUB_ACTION_CODE",
          O."PROMOTION_INTEGRATION_ID",
          O."NGB_PROD_TYPE",
          O."PROMOTION_PART_NUMBER",
          O."PRODUCT_ID",
          O."O2A_STATUS",
          O."PARENT_ITEM_ROW_ID",
          O."ROOT_ITEM_ROW_ID",
          O."CONTRACT_START_DATE",
          O."CONTRACT_END_DATE",
          O."LIST_PRICE",
          O."HARDWARE_ASSOCIATION_ID",
          O."EFFECTIVE_DATE"
     FROM SERVICE_ASSOC_ACCESS_TYPE_OLI O
   UNION ALL
   SELECT CAST ('SERVICE_MOLI' AS VARCHAR2 (30)) AS "REC_TYPE",
          M."FILENAME",
          M."BATCHPROCESSDATE",
          M."RECORDNUMBER",
          M."IS_FILTERED",
          M."ORDER_NUMBER",
          M."BILLING_ACCOUNT",
          M."CUSTOMER_LAST_NAME",
          M."CUSTOMER_FIRST_NAME",
          M."ORDER_TYPE",
          M."ORDER_SUB_TYPE",
          M."CREATED_DATE",
          M."PARTNER_CODE",
          M."CAMPAIGN_NAME",
          M."CAMPAIGN_NUMBER",
          M."CAMPAIGN_TYPE",
          M."CHANNEL_TYPE",
          M."CAMPAIGN_START_DATE",
          M."BUSINESS_UNIT",
          M."SALES_FORCE_ID",
          M."CUSTOMER_ID",
          M."ORDER_REVISION_NUMBER",
          M."SUBMITTED_DATE",
          M."STATUS_HEADER",
          M."REASON_CODE",
          M."COMMISSION_TRANSACTION_TYPE",
          M."SOURCE_SYSTEM",
          M."ROW_ID",
          M."PRODUCT",
          M."PART_NUMBER",
          M."ACTION_CODE",
          M."TRANSFER_TYPE",
          M."EVENT_SOURCE",
          M."PROD_PROM_ID",
          M."PROVISIONED_DATE",
          M."NET_PRICE",
          M."COMMISSION_PRODUCT_TYPE",
          M."COMMISSIONABLE",
          M."STATUS_ORDER_LINE_ITEM",
          M."ORIGINAL_ORDER_NUMBER",
          M."HARDWARE_SUPPLIED_FLAG",
          M."SUB_ACTION_CODE",
          M."PROMOTION_INTEGRATION_ID",
          M."NGB_PROD_TYPE",
          M."PROMOTION_PART_NUMBER",
          M."PRODUCT_ID",
          M."O2A_STATUS",
          M."PARENT_ITEM_ROW_ID",
          M."ROOT_ITEM_ROW_ID",
          M."CONTRACT_START_DATE",
          M."CONTRACT_END_DATE",
          M."LIST_PRICE",
          M."HARDWARE_ASSOCIATION_ID",
          M."EFFECTIVE_DATE"
     FROM SERVICE_MOLI M
   UNION ALL
   SELECT CAST ('SIM_OLI' AS VARCHAR2 (30)) AS "REC_TYPE",
          O."FILENAME",
          O."BATCHPROCESSDATE",
          O."RECORDNUMBER",
          O."IS_FILTERED",
          O."ORDER_NUMBER",
          O."BILLING_ACCOUNT",
          O."CUSTOMER_LAST_NAME",
          O."CUSTOMER_FIRST_NAME",
          O."ORDER_TYPE",
          O."ORDER_SUB_TYPE",
          O."CREATED_DATE",
          O."PARTNER_CODE",
          O."CAMPAIGN_NAME",
          O."CAMPAIGN_NUMBER",
          O."CAMPAIGN_TYPE",
          O."CHANNEL_TYPE",
          O."CAMPAIGN_START_DATE",
          O."BUSINESS_UNIT",
          O."SALES_FORCE_ID",
          O."CUSTOMER_ID",
          O."ORDER_REVISION_NUMBER",
          O."SUBMITTED_DATE",
          O."STATUS_HEADER",
          O."REASON_CODE",
          O."COMMISSION_TRANSACTION_TYPE",
          O."SOURCE_SYSTEM",
          O."ROW_ID",
          O."PRODUCT",
          O."PART_NUMBER",
          O."ACTION_CODE",
          O."TRANSFER_TYPE",
          O."EVENT_SOURCE",
          O."PROD_PROM_ID",
          O."PROVISIONED_DATE",
          O."NET_PRICE",
          O."COMMISSION_PRODUCT_TYPE",
          O."COMMISSIONABLE",
          O."STATUS_ORDER_LINE_ITEM",
          O."ORIGINAL_ORDER_NUMBER",
          O."HARDWARE_SUPPLIED_FLAG",
          O."SUB_ACTION_CODE",
          O."PROMOTION_INTEGRATION_ID",
          O."NGB_PROD_TYPE",
          O."PROMOTION_PART_NUMBER",
          O."PRODUCT_ID",
          O."O2A_STATUS",
          O."PARENT_ITEM_ROW_ID",
          O."ROOT_ITEM_ROW_ID",
          O."CONTRACT_START_DATE",
          O."CONTRACT_END_DATE",
          O."LIST_PRICE",
          O."HARDWARE_ASSOCIATION_ID",
          O."EFFECTIVE_DATE"
     FROM SIM_OLI O
   UNION ALL
   SELECT CAST ('VAS_ASSOC_CONTRACT_OLI' AS VARCHAR2 (30)) AS "REC_TYPE",
          O."FILENAME",
          O."BATCHPROCESSDATE",
          O."RECORDNUMBER",
          O."IS_FILTERED",
          O."ORDER_NUMBER",
          O."BILLING_ACCOUNT",
          O."CUSTOMER_LAST_NAME",
          O."CUSTOMER_FIRST_NAME",
          O."ORDER_TYPE",
          O."ORDER_SUB_TYPE",
          O."CREATED_DATE",
          O."PARTNER_CODE",
          O."CAMPAIGN_NAME",
          O."CAMPAIGN_NUMBER",
          O."CAMPAIGN_TYPE",
          O."CHANNEL_TYPE",
          O."CAMPAIGN_START_DATE",
          O."BUSINESS_UNIT",
          O."SALES_FORCE_ID",
          O."CUSTOMER_ID",
          O."ORDER_REVISION_NUMBER",
          O."SUBMITTED_DATE",
          O."STATUS_HEADER",
          O."REASON_CODE",
          O."COMMISSION_TRANSACTION_TYPE",
          O."SOURCE_SYSTEM",
          O."ROW_ID",
          O."PRODUCT",
          O."PART_NUMBER",
          O."ACTION_CODE",
          O."TRANSFER_TYPE",
          O."EVENT_SOURCE",
          O."PROD_PROM_ID",
          O."PROVISIONED_DATE",
          O."NET_PRICE",
          O."COMMISSION_PRODUCT_TYPE",
          O."COMMISSIONABLE",
          O."STATUS_ORDER_LINE_ITEM",
          O."ORIGINAL_ORDER_NUMBER",
          O."HARDWARE_SUPPLIED_FLAG",
          O."SUB_ACTION_CODE",
          O."PROMOTION_INTEGRATION_ID",
          O."NGB_PROD_TYPE",
          O."PROMOTION_PART_NUMBER",
          O."PRODUCT_ID",
          O."O2A_STATUS",
          O."PARENT_ITEM_ROW_ID",
          O."ROOT_ITEM_ROW_ID",
          O."CONTRACT_START_DATE",
          O."CONTRACT_END_DATE",
          O."LIST_PRICE",
          O."HARDWARE_ASSOCIATION_ID",
          O."EFFECTIVE_DATE"
     FROM VAS_ASSOC_CONTRACT_OLI O
   UNION ALL
   SELECT CAST ('VAS_ASSOC_FHW_OLI' AS VARCHAR2 (30)) AS "REC_TYPE",
          O."FILENAME",
          O."BATCHPROCESSDATE",
          O."RECORDNUMBER",
          O."IS_FILTERED",
          O."ORDER_NUMBER",
          O."BILLING_ACCOUNT",
          O."CUSTOMER_LAST_NAME",
          O."CUSTOMER_FIRST_NAME",
          O."ORDER_TYPE",
          O."ORDER_SUB_TYPE",
          O."CREATED_DATE",
          O."PARTNER_CODE",
          O."CAMPAIGN_NAME",
          O."CAMPAIGN_NUMBER",
          O."CAMPAIGN_TYPE",
          O."CHANNEL_TYPE",
          O."CAMPAIGN_START_DATE",
          O."BUSINESS_UNIT",
          O."SALES_FORCE_ID",
          O."CUSTOMER_ID",
          O."ORDER_REVISION_NUMBER",
          O."SUBMITTED_DATE",
          O."STATUS_HEADER",
          O."REASON_CODE",
          O."COMMISSION_TRANSACTION_TYPE",
          O."SOURCE_SYSTEM",
          O."ROW_ID",
          O."PRODUCT",
          O."PART_NUMBER",
          O."ACTION_CODE",
          O."TRANSFER_TYPE",
          O."EVENT_SOURCE",
          O."PROD_PROM_ID",
          O."PROVISIONED_DATE",
          O."NET_PRICE",
          O."COMMISSION_PRODUCT_TYPE",
          O."COMMISSIONABLE",
          O."STATUS_ORDER_LINE_ITEM",
          O."ORIGINAL_ORDER_NUMBER",
          O."HARDWARE_SUPPLIED_FLAG",
          O."SUB_ACTION_CODE",
          O."PROMOTION_INTEGRATION_ID",
          O."NGB_PROD_TYPE",
          O."PROMOTION_PART_NUMBER",
          O."PRODUCT_ID",
          O."O2A_STATUS",
          O."PARENT_ITEM_ROW_ID",
          O."ROOT_ITEM_ROW_ID",
          O."CONTRACT_START_DATE",
          O."CONTRACT_END_DATE",
          O."LIST_PRICE",
          O."HARDWARE_ASSOCIATION_ID",
          O."EFFECTIVE_DATE"
     FROM VAS_ASSOC_FHW_OLI O
   UNION ALL
   SELECT CAST ('VAS_ASSOC_MOLI' AS VARCHAR2 (30)) AS "REC_TYPE",
          M."FILENAME",
          M."BATCHPROCESSDATE",
          M."RECORDNUMBER",
          M."IS_FILTERED",
          M."ORDER_NUMBER",
          M."BILLING_ACCOUNT",
          M."CUSTOMER_LAST_NAME",
          M."CUSTOMER_FIRST_NAME",
          M."ORDER_TYPE",
          M."ORDER_SUB_TYPE",
          M."CREATED_DATE",
          M."PARTNER_CODE",
          M."CAMPAIGN_NAME",
          M."CAMPAIGN_NUMBER",
          M."CAMPAIGN_TYPE",
          M."CHANNEL_TYPE",
          M."CAMPAIGN_START_DATE",
          M."BUSINESS_UNIT",
          M."SALES_FORCE_ID",
          M."CUSTOMER_ID",
          M."ORDER_REVISION_NUMBER",
          M."SUBMITTED_DATE",
          M."STATUS_HEADER",
          M."REASON_CODE",
          M."COMMISSION_TRANSACTION_TYPE",
          M."SOURCE_SYSTEM",
          M."ROW_ID",
          M."PRODUCT",
          M."PART_NUMBER",
          M."ACTION_CODE",
          M."TRANSFER_TYPE",
          M."EVENT_SOURCE",
          M."PROD_PROM_ID",
          M."PROVISIONED_DATE",
          M."NET_PRICE",
          M."COMMISSION_PRODUCT_TYPE",
          M."COMMISSIONABLE",
          M."STATUS_ORDER_LINE_ITEM",
          M."ORIGINAL_ORDER_NUMBER",
          M."HARDWARE_SUPPLIED_FLAG",
          M."SUB_ACTION_CODE",
          M."PROMOTION_INTEGRATION_ID",
          M."NGB_PROD_TYPE",
          M."PROMOTION_PART_NUMBER",
          M."PRODUCT_ID",
          M."O2A_STATUS",
          M."PARENT_ITEM_ROW_ID",
          M."ROOT_ITEM_ROW_ID",
          M."CONTRACT_START_DATE",
          M."CONTRACT_END_DATE",
          M."LIST_PRICE",
          M."HARDWARE_ASSOCIATION_ID",
          M."EFFECTIVE_DATE"
     FROM VAS_ASSOC_MOLI M
   UNION ALL
   SELECT CAST ('VAS_ASSOC_OFFER_MOLI' AS VARCHAR2 (30)) AS "REC_TYPE",
          M."FILENAME",
          M."BATCHPROCESSDATE",
          M."RECORDNUMBER",
          M."IS_FILTERED",
          M."ORDER_NUMBER",
          M."BILLING_ACCOUNT",
          M."CUSTOMER_LAST_NAME",
          M."CUSTOMER_FIRST_NAME",
          M."ORDER_TYPE",
          M."ORDER_SUB_TYPE",
          M."CREATED_DATE",
          M."PARTNER_CODE",
          M."CAMPAIGN_NAME",
          M."CAMPAIGN_NUMBER",
          M."CAMPAIGN_TYPE",
          M."CHANNEL_TYPE",
          M."CAMPAIGN_START_DATE",
          M."BUSINESS_UNIT",
          M."SALES_FORCE_ID",
          M."CUSTOMER_ID",
          M."ORDER_REVISION_NUMBER",
          M."SUBMITTED_DATE",
          M."STATUS_HEADER",
          M."REASON_CODE",
          M."COMMISSION_TRANSACTION_TYPE",
          M."SOURCE_SYSTEM",
          M."ROW_ID",
          M."PRODUCT",
          M."PART_NUMBER",
          M."ACTION_CODE",
          M."TRANSFER_TYPE",
          M."EVENT_SOURCE",
          M."PROD_PROM_ID",
          M."PROVISIONED_DATE",
          M."NET_PRICE",
          M."COMMISSION_PRODUCT_TYPE",
          M."COMMISSIONABLE",
          M."STATUS_ORDER_LINE_ITEM",
          M."ORIGINAL_ORDER_NUMBER",
          M."HARDWARE_SUPPLIED_FLAG",
          M."SUB_ACTION_CODE",
          M."PROMOTION_INTEGRATION_ID",
          M."NGB_PROD_TYPE",
          M."PROMOTION_PART_NUMBER",
          M."PRODUCT_ID",
          M."O2A_STATUS",
          M."PARENT_ITEM_ROW_ID",
          M."ROOT_ITEM_ROW_ID",
          M."CONTRACT_START_DATE",
          M."CONTRACT_END_DATE",
          M."LIST_PRICE",
          M."HARDWARE_ASSOCIATION_ID",
          M."EFFECTIVE_DATE"
     FROM VAS_ASSOC_OFFER_MOLI M
   UNION ALL
   SELECT CAST ('VAS_OLI' AS VARCHAR2 (30)) AS "REC_TYPE",
          O."FILENAME",
          O."BATCHPROCESSDATE",
          O."RECORDNUMBER",
          O."IS_FILTERED",
          O."ORDER_NUMBER",
          O."BILLING_ACCOUNT",
          O."CUSTOMER_LAST_NAME",
          O."CUSTOMER_FIRST_NAME",
          O."ORDER_TYPE",
          O."ORDER_SUB_TYPE",
          O."CREATED_DATE",
          O."PARTNER_CODE",
          O."CAMPAIGN_NAME",
          O."CAMPAIGN_NUMBER",
          O."CAMPAIGN_TYPE",
          O."CHANNEL_TYPE",
          O."CAMPAIGN_START_DATE",
          O."BUSINESS_UNIT",
          O."SALES_FORCE_ID",
          O."CUSTOMER_ID",
          O."ORDER_REVISION_NUMBER",
          O."SUBMITTED_DATE",
          O."STATUS_HEADER",
          O."REASON_CODE",
          O."COMMISSION_TRANSACTION_TYPE",
          O."SOURCE_SYSTEM",
          O."ROW_ID",
          O."PRODUCT",
          O."PART_NUMBER",
          O."ACTION_CODE",
          O."TRANSFER_TYPE",
          O."EVENT_SOURCE",
          O."PROD_PROM_ID",
          O."PROVISIONED_DATE",
          O."NET_PRICE",
          O."COMMISSION_PRODUCT_TYPE",
          O."COMMISSIONABLE",
          O."STATUS_ORDER_LINE_ITEM",
          O."ORIGINAL_ORDER_NUMBER",
          O."HARDWARE_SUPPLIED_FLAG",
          O."SUB_ACTION_CODE",
          O."PROMOTION_INTEGRATION_ID",
          O."NGB_PROD_TYPE",
          O."PROMOTION_PART_NUMBER",
          O."PRODUCT_ID",
          O."O2A_STATUS",
          O."PARENT_ITEM_ROW_ID",
          O."ROOT_ITEM_ROW_ID",
          O."CONTRACT_START_DATE",
          O."CONTRACT_END_DATE",
          O."LIST_PRICE",
          O."HARDWARE_ASSOCIATION_ID",
          O."EFFECTIVE_DATE"
     FROM VAS_OLI O
   UNION ALL
   SELECT CAST ('MP_ASSOC_MOLI' AS VARCHAR2 (30)) AS "REC_TYPE",
          M."FILENAME",
          M."BATCHPROCESSDATE",
          M."RECORDNUMBER",
          M."IS_FILTERED",
          M."ORDER_NUMBER",
          M."BILLING_ACCOUNT",
          M."CUSTOMER_LAST_NAME",
          M."CUSTOMER_FIRST_NAME",
          M."ORDER_TYPE",
          M."ORDER_SUB_TYPE",
          M."CREATED_DATE",
          M."PARTNER_CODE",
          M."CAMPAIGN_NAME",
          M."CAMPAIGN_NUMBER",
          M."CAMPAIGN_TYPE",
          M."CHANNEL_TYPE",
          M."CAMPAIGN_START_DATE",
          M."BUSINESS_UNIT",
          M."SALES_FORCE_ID",
          M."CUSTOMER_ID",
          M."ORDER_REVISION_NUMBER",
          M."SUBMITTED_DATE",
          M."STATUS_HEADER",
          M."REASON_CODE",
          M."COMMISSION_TRANSACTION_TYPE",
          M."SOURCE_SYSTEM",
          M."ROW_ID",
          M."PRODUCT",
          M."PART_NUMBER",
          M."ACTION_CODE",
          M."TRANSFER_TYPE",
          M."EVENT_SOURCE",
          M."PROD_PROM_ID",
          M."PROVISIONED_DATE",
          M."NET_PRICE",
          M."COMMISSION_PRODUCT_TYPE",
          M."COMMISSIONABLE",
          M."STATUS_ORDER_LINE_ITEM",
          M."ORIGINAL_ORDER_NUMBER",
          M."HARDWARE_SUPPLIED_FLAG",
          M."SUB_ACTION_CODE",
          M."PROMOTION_INTEGRATION_ID",
          M."NGB_PROD_TYPE",
          M."PROMOTION_PART_NUMBER",
          M."PRODUCT_ID",
          M."O2A_STATUS",
          M."PARENT_ITEM_ROW_ID",
          M."ROOT_ITEM_ROW_ID",
          M."CONTRACT_START_DATE",
          M."CONTRACT_END_DATE",
          M."LIST_PRICE",
          M."HARDWARE_ASSOCIATION_ID",
          M."EFFECTIVE_DATE"
     FROM MP_ASSOC_MOLI M
   UNION ALL
   SELECT CAST ('MP_ASSOC_MOLI_HOLD' AS VARCHAR2 (30)) AS "REC_TYPE",
          M."FILENAME",
          M."BATCHPROCESSDATE",
          M."RECORDNUMBER",
          M."IS_FILTERED",
          M."ORDER_NUMBER",
          M."BILLING_ACCOUNT",
          M."CUSTOMER_LAST_NAME",
          M."CUSTOMER_FIRST_NAME",
          M."ORDER_TYPE",
          M."ORDER_SUB_TYPE",
          M."CREATED_DATE",
          M."PARTNER_CODE",
          M."CAMPAIGN_NAME",
          M."CAMPAIGN_NUMBER",
          M."CAMPAIGN_TYPE",
          M."CHANNEL_TYPE",
          M."CAMPAIGN_START_DATE",
          M."BUSINESS_UNIT",
          M."SALES_FORCE_ID",
          M."CUSTOMER_ID",
          M."ORDER_REVISION_NUMBER",
          M."SUBMITTED_DATE",
          M."STATUS_HEADER",
          M."REASON_CODE",
          M."COMMISSION_TRANSACTION_TYPE",
          M."SOURCE_SYSTEM",
          M."ROW_ID",
          M."PRODUCT",
          M."PART_NUMBER",
          M."ACTION_CODE",
          M."TRANSFER_TYPE",
          M."EVENT_SOURCE",
          M."PROD_PROM_ID",
          M."PROVISIONED_DATE",
          M."NET_PRICE",
          M."COMMISSION_PRODUCT_TYPE",
          M."COMMISSIONABLE",
          M."STATUS_ORDER_LINE_ITEM",
          M."ORIGINAL_ORDER_NUMBER",
          M."HARDWARE_SUPPLIED_FLAG",
          M."SUB_ACTION_CODE",
          M."PROMOTION_INTEGRATION_ID",
          M."NGB_PROD_TYPE",
          M."PROMOTION_PART_NUMBER",
          M."PRODUCT_ID",
          M."O2A_STATUS",
          M."PARENT_ITEM_ROW_ID",
          M."ROOT_ITEM_ROW_ID",
          M."CONTRACT_START_DATE",
          M."CONTRACT_END_DATE",
          M."LIST_PRICE",
          M."HARDWARE_ASSOCIATION_ID",
          M."EFFECTIVE_DATE"
     FROM MP_ASSOC_MOLI_HOLD M
   UNION ALL
   SELECT CAST ('DARO_ASSOC_FHW_OLI' AS VARCHAR2 (30)) AS "REC_TYPE",
          O."FILENAME",
          O."BATCHPROCESSDATE",
          O."RECORDNUMBER",
          O."IS_FILTERED",
          O."ORDER_NUMBER",
          O."BILLING_ACCOUNT",
          O."CUSTOMER_LAST_NAME",
          O."CUSTOMER_FIRST_NAME",
          O."ORDER_TYPE",
          O."ORDER_SUB_TYPE",
          O."CREATED_DATE",
          O."PARTNER_CODE",
          O."CAMPAIGN_NAME",
          O."CAMPAIGN_NUMBER",
          O."CAMPAIGN_TYPE",
          O."CHANNEL_TYPE",
          O."CAMPAIGN_START_DATE",
          O."BUSINESS_UNIT",
          O."SALES_FORCE_ID",
          O."CUSTOMER_ID",
          O."ORDER_REVISION_NUMBER",
          O."SUBMITTED_DATE",
          O."STATUS_HEADER",
          O."REASON_CODE",
          O."COMMISSION_TRANSACTION_TYPE",
          O."SOURCE_SYSTEM",
          O."ROW_ID",
          O."PRODUCT",
          O."PART_NUMBER",
          O."ACTION_CODE",
          O."TRANSFER_TYPE",
          O."EVENT_SOURCE",
          O."PROD_PROM_ID",
          O."PROVISIONED_DATE",
          O."NET_PRICE",
          O."COMMISSION_PRODUCT_TYPE",
          O."COMMISSIONABLE",
          O."STATUS_ORDER_LINE_ITEM",
          O."ORIGINAL_ORDER_NUMBER",
          O."HARDWARE_SUPPLIED_FLAG",
          O."SUB_ACTION_CODE",
          O."PROMOTION_INTEGRATION_ID",
          O."NGB_PROD_TYPE",
          O."PROMOTION_PART_NUMBER",
          O."PRODUCT_ID",
          O."O2A_STATUS",
          O."PARENT_ITEM_ROW_ID",
          O."ROOT_ITEM_ROW_ID",
          O."CONTRACT_START_DATE",
          O."CONTRACT_END_DATE",
          O."LIST_PRICE",
          O."HARDWARE_ASSOCIATION_ID",
          O."EFFECTIVE_DATE"
     FROM DARO_ASSOC_FHW_OLI O
   UNION ALL
   SELECT CAST ('DARO_ASSOC_SERVICE_MOLI' AS VARCHAR2 (30)) AS "REC_TYPE",
          M."FILENAME",
          M."BATCHPROCESSDATE",
          M."RECORDNUMBER",
          M."IS_FILTERED",
          M."ORDER_NUMBER",
          M."BILLING_ACCOUNT",
          M."CUSTOMER_LAST_NAME",
          M."CUSTOMER_FIRST_NAME",
          M."ORDER_TYPE",
          M."ORDER_SUB_TYPE",
          M."CREATED_DATE",
          M."PARTNER_CODE",
          M."CAMPAIGN_NAME",
          M."CAMPAIGN_NUMBER",
          M."CAMPAIGN_TYPE",
          M."CHANNEL_TYPE",
          M."CAMPAIGN_START_DATE",
          M."BUSINESS_UNIT",
          M."SALES_FORCE_ID",
          M."CUSTOMER_ID",
          M."ORDER_REVISION_NUMBER",
          M."SUBMITTED_DATE",
          M."STATUS_HEADER",
          M."REASON_CODE",
          M."COMMISSION_TRANSACTION_TYPE",
          M."SOURCE_SYSTEM",
          M."ROW_ID",
          M."PRODUCT",
          M."PART_NUMBER",
          M."ACTION_CODE",
          M."TRANSFER_TYPE",
          M."EVENT_SOURCE",
          M."PROD_PROM_ID",
          M."PROVISIONED_DATE",
          M."NET_PRICE",
          M."COMMISSION_PRODUCT_TYPE",
          M."COMMISSIONABLE",
          M."STATUS_ORDER_LINE_ITEM",
          M."ORIGINAL_ORDER_NUMBER",
          M."HARDWARE_SUPPLIED_FLAG",
          M."SUB_ACTION_CODE",
          M."PROMOTION_INTEGRATION_ID",
          M."NGB_PROD_TYPE",
          M."PROMOTION_PART_NUMBER",
          M."PRODUCT_ID",
          M."O2A_STATUS",
          M."PARENT_ITEM_ROW_ID",
          M."ROOT_ITEM_ROW_ID",
          M."CONTRACT_START_DATE",
          M."CONTRACT_END_DATE",
          M."LIST_PRICE",
          M."HARDWARE_ASSOCIATION_ID",
          M."EFFECTIVE_DATE"
     FROM DARO_ASSOC_SERVICE_MOLI M;

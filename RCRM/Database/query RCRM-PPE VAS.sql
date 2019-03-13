WITH ATTRIBUTES AS(
    SELECT D.FILENAME, D.RECORDNUMBER, D.ORDER_NUMBER, D.ROW_ID ATTRIBUTE_OWNER_ROW_ID, D.ATTRIBUTE_ROW_ID, D.ATTRIBUTE_ACTION_CODE, D.ATTRIBUTE_DISPLAY_NAME, D.ATTRIBUTE_VALUE
    FROM TELS_RCRM_ATTRIBUTES_VIEW D
    WHERE D.ATTRIBUTE_ROW_ID IS NOT NULL AND NVL(D.ORDER_SUB_TYPE,'NULL') <> 'Transfer')
, VAS_OLI AS(
    SELECT * FROM TELS_RCRM_ORDERS_VIEW WHERE REC_TYPE = 'VAS_OLI')
, VAS_ASSOC_MOLI AS(
    SELECT * FROM TELS_RCRM_ORDERS_VIEW WHERE REC_TYPE = 'VAS_ASSOC_MOLI')
, VAS_ASSOC_CONTRACT_OLI AS(
    SELECT * FROM TELS_RCRM_ORDERS_VIEW WHERE REC_TYPE = 'VAS_ASSOC_CONTRACT_OLI')
,
VAS_ASSOC_FHW_OLI AS(
  SELECT * FROM (
    SELECT
      V.*
      , ROW_NUMBER() OVER (PARTITION BY V.ORDER_NUMBER, V.STATUS_HEADER, V.ROOT_ITEM_ROW_ID ORDER BY V.ROW_ID DESC) AS "ROW_NUMBER"
    FROM TELS_RCRM_ORDERS_VIEW V
    WHERE V.REC_TYPE = 'VAS_ASSOC_FHW_OLI'
    )
  WHERE ROW_NUMBER = 1
  )
,
VAS_ASSOC_OFFER_MOLI AS(
    SELECT * FROM TELS_RCRM_ORDERS_VIEW WHERE REC_TYPE = 'VAS_ASSOC_OFFER_MOLI')
, LT_PLAN_VAS_HW_RO AS(
    SELECT LT.STARTDATE, LT.ENDDATE, LT.DIM_NAME_0, LT.IDX_NAME_0, LT.DIM_NAME_1, LT.IDX_NAME_1, LT.STRINGVALUE
    FROM TELS_RCRM_MV_MDLT LT
    WHERE NAME = 'LT_Plan_VAS_HW_RO')
, LT_SALES_TYPE_VAS AS(
    SELECT LT.STARTDATE, LT.ENDDATE, LT.DIM_NAME_0, LT.IDX_NAME_0, LT.DIM_NAME_1, LT.IDX_NAME_1, LT.DIM_NAME_2, LT.IDX_NAME_2,LT.DIM_NAME_3, LT.IDX_NAME_3,LT.DIM_NAME_4, LT.IDX_NAME_4, LT.STRINGVALUE
    FROM TELS_RCRM_MV_MDLT LT
    WHERE NAME = 'LT_Sales_Type_VAS')
, LT_BASE_REM_VAS AS(
    SELECT LT.STARTDATE, LT.ENDDATE, LT.DIM_NAME_0, LT.IDX_NAME_0, LT.DIM_NAME_1, LT.IDX_NAME_1, LT.DIM_NAME_2, LT.IDX_NAME_2,LT.DIM_NAME_3, LT.IDX_NAME_3,LT.DIM_NAME_4, LT.IDX_NAME_4, LT.VALUE
    FROM TELS_RCRM_MV_MDLT LT
    WHERE NAME = 'LT_Base_Rem_VAS')
, LT_FOXTEL_PLAN_HW AS(
    SELECT LT.STARTDATE, LT.ENDDATE, LT.DIM_NAME_0, LT.IDX_NAME_0, LT.DIM_NAME_1, LT.IDX_NAME_1, LT.STRINGVALUE
    FROM TELS_RCRM_MV_MDLT LT
    WHERE NAME = 'LT_Foxtel_Plan_HW')
, PASS1 AS(
SELECT
    VO.FILENAME,
    VO.BATCHPROCESSDATE,
    VO.RECORDNUMBER,
    VAM.PROVISIONED_DATE PROCESSED_DATE,
    NULL PROCESSED_PERIOD_ID,
    VO.LIST_PRICE TRANSACTION_AMOUNT,
    '1' QUANTITY,
    VAM.CUSTOMER_LAST_NAME ATTRIBUTE1,
    VAM.CUSTOMER_FIRST_NAME ATTRIBUTE2,
    NULL ATTRIBUTE3,NULL ATTRIBUTE4,NULL ATTRIBUTE5,NULL ATTRIBUTE6,NULL ATTRIBUTE7,NULL ATTRIBUTE8,NULL ATTRIBUTE9,NULL ATTRIBUTE10,NULL ATTRIBUTE11,NULL ATTRIBUTE12,NULL ATTRIBUTE13,NULL ATTRIBUTE14,NULL ATTRIBUTE15,NULL ATTRIBUTE16,NULL ATTRIBUTE17,NULL ATTRIBUTE18,NULL ATTRIBUTE19,NULL ATTRIBUTE20,NULL ATTRIBUTE21,NULL ATTRIBUTE22,NULL ATTRIBUTE23,NULL ATTRIBUTE24,
    VAM.ORDER_NUMBER ATTRIBUTE25,
    VAM.BILLING_ACCOUNT ATTRIBUTE26,
    VAM.PARTNER_CODE ATTRIBUTE27,
    NULL ATTRIBUTE28,NULL ATTRIBUTE29,NULL ATTRIBUTE30,NULL ATTRIBUTE31,NULL ATTRIBUTE32,NULL ATTRIBUTE33,NULL ATTRIBUTE34,
    VAM.BUSINESS_UNIT ATTRIBUTE35,
    VAM.SALES_FORCE_ID ATTRIBUTE36,
    'COMMISSIONABLE TRANSACTION' ATTRIBUTE37,
    VAM.SOURCE_SYSTEM ATTRIBUTE38,
    VAM.PRODUCT ATTRIBUTE39,
    NULL ATTRIBUTE40,
    VAM.ACTION_CODE ATTRIBUTE41,
    VAM.TRANSFER_TYPE ATTRIBUTE42,
    VAM.EVENT_SOURCE ATTRIBUTE43,
    VAM.PROMOTION_PART_NUMBER ATTRIBUTE44,
    CASE WHEN VAM.ORDER_TYPE = 'Modify' AND VAM.SUB_ACTION_CODE IN('Transition-Add','Transition-Delete')
         THEN 'Transition'
         ELSE VAM.ORDER_SUB_TYPE
         END ATTRIBUTE45,
    VO.ROW_ID ATTRIBUTE46,
    VO.PRODUCT ATTRIBUTE47,
    NULL ATTRIBUTE48,
    VO.ACTION_CODE ATTRIBUTE49,
    VO.PROMOTION_PART_NUMBER ATTRIBUTE50,
    NULL ATTRIBUTE51,NULL ATTRIBUTE52,NULL ATTRIBUTE53,NULL ATTRIBUTE54,NULL ATTRIBUTE55,NULL ATTRIBUTE56,NULL ATTRIBUTE57,NULL ATTRIBUTE58,NULL ATTRIBUTE59,
    CASE WHEN VAM.ORDER_TYPE = 'Modify' AND VAM.SUB_ACTION_CODE IN('Move-Add','Move-Delete')
         THEN 'Move'
         WHEN VAM.ORDER_TYPE = 'Modify' AND VAM.SUB_ACTION_CODE IN('Transition-Add','Transition-Delete')
         THEN 'Add New Service'
         ELSE VAM.ORDER_TYPE
         END ATTRIBUTE60,
    VACO.ACTION_CODE ATTRIBUTE61,
    VACO.CONTRACT_START_DATE ATTRIBUTE62,
    NULL ATTRIBUTE63,NULL ATTRIBUTE64,
    A1.ATTRIBUTE_VALUE ATTRIBUTE65,
    NULL ATTRIBUTE66,
--    CASE WHEN a2.ATTRIBUTE_VALUE IS NOT NULL
--          AND EXISTS(SELECT 1 FROM LT_Plan_VAS_HW_RO lt WHERE lt.IDX_NAME_0 =   vo.PART_NUMBER AND lt.IDX_NAME_1 = 'VAS'    AND lt.STRINGVALUE = 'Yes' AND lt.STARTDATE <= TO_DATE(NVL(vo.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss') AND lt.ENDDATE > TO_DATE(NVL(vo.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss'))
--          AND EXISTS(SELECT 1 FROM LT_Plan_VAS_HW_RO lt WHERE lt.IDX_NAME_0 = vafo.PART_NUMBER AND lt.IDX_NAME_1 = 'VAS HW' AND lt.STRINGVALUE = 'Yes' AND lt.STARTDATE <= TO_DATE(NVL(vafo.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss') AND lt.ENDDATE > TO_DATE(NVL(vafo.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss'))
--         THEN a2.ATTRIBUTE_VALUE 
--         WHEN a3.ATTRIBUTE_VALUE IS NOT NULL
--         THEN a3.ATTRIBUTE_VALUE
--         WHEN a4.ATTRIBUTE_VALUE IS NOT NULL
--         THEN a4.ATTRIBUTE_VALUE
--         ELSE vo.HARDWARE_SUPPLIED_FLAG
--         END ATTRIBUTE67,
    CASE WHEN EXISTS(SELECT 1 FROM LT_PLAN_VAS_HW_RO LT WHERE LT.IDX_NAME_0 =   VO.PART_NUMBER AND LT.IDX_NAME_1 = 'VAS'    AND LT.STRINGVALUE = 'Yes' AND LT.STARTDATE <= TO_DATE(NVL(VO.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss') AND LT.ENDDATE > TO_DATE(NVL(VO.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss'))
          AND EXISTS(SELECT 1 FROM LT_PLAN_VAS_HW_RO LT WHERE LT.IDX_NAME_0 = VAFO.PART_NUMBER AND LT.IDX_NAME_1 = 'VAS HW' AND LT.STRINGVALUE = 'Yes' AND LT.STARTDATE <= TO_DATE(NVL(VAFO.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss') AND LT.ENDDATE > TO_DATE(NVL(VAFO.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss'))
         THEN CASE WHEN A2.ATTRIBUTE_VALUE IS NOT NULL
                   THEN A2.ATTRIBUTE_VALUE 
                   WHEN A2I.ATTRIBUTE_VALUE IS NOT NULL
                   THEN A2I.ATTRIBUTE_VALUE 
                   ELSE VAFO.HARDWARE_SUPPLIED_FLAG
              END
         WHEN A3.ATTRIBUTE_VALUE IS NOT NULL
         THEN A3.ATTRIBUTE_VALUE
         WHEN A4.ATTRIBUTE_VALUE IS NOT NULL
         THEN A4.ATTRIBUTE_VALUE
         ELSE VO.HARDWARE_SUPPLIED_FLAG
         END ATTRIBUTE67,
    NULL ATTRIBUTE68,NULL ATTRIBUTE69,NULL ATTRIBUTE70,NULL ATTRIBUTE71,NULL ATTRIBUTE72,NULL ATTRIBUTE73,NULL ATTRIBUTE74,NULL ATTRIBUTE75,NULL ATTRIBUTE76,NULL ATTRIBUTE77,
    CASE WHEN VO.ACTION_CODE IS NOT NULL 
         THEN NVL((SELECT STRINGVALUE FROM LT_SALES_TYPE_VAS LT 
                    WHERE LT.IDX_NAME_0 = NVL(VAM.ORDER_TYPE,'NULL')
                      AND LT.IDX_NAME_1 = NVL(VAM.ORDER_SUB_TYPE,'NULL')
                      AND LT.IDX_NAME_2 = NVL(VO.ACTION_CODE,'NULL')
                      AND LT.IDX_NAME_3 = NVL(VACO.ACTION_CODE,'NULL')
                      AND LT.STARTDATE <= TO_DATE(NVL(VO.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss') AND LT.ENDDATE > TO_DATE(NVL(VO.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss')
--                      AND EXISTS(SELECT 1 FROM LT_Base_Rem_VAS lt2 
--                                 WHERE lt2.IDX_NAME_0 = vo.PART_NUMBER
--                                   AND lt2.STARTDATE <= TO_DATE(NVL(vo.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss') AND lt2.ENDDATE > TO_DATE(NVL(vo.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss'))
                                   )
             ,'Non-Classified') 
         END ATTRIBUTE78, /*Override determined in Pass2*/
    NULL ATTRIBUTE79,NULL ATTRIBUTE80,
    VO.PART_NUMBER ATTRIBUTE81,
    NULL ATTRIBUTE82,NULL ATTRIBUTE83,NULL ATTRIBUTE84,NULL ATTRIBUTE85,NULL ATTRIBUTE86,NULL ATTRIBUTE87,
    CASE WHEN VO.COMMISSION_PRODUCT_TYPE = 'Commissions Convert Plan' 
         THEN 'Commissions VAS'
         ELSE VO.COMMISSION_PRODUCT_TYPE 
         END ATTRIBUTE88, /*Override determined in Pass2*/
    NULL ATTRIBUTE89,NULL ATTRIBUTE90,NULL ATTRIBUTE91,NULL ATTRIBUTE92,NULL ATTRIBUTE93,NULL ATTRIBUTE94,NULL ATTRIBUTE95,NULL ATTRIBUTE96,NULL ATTRIBUTE97,NULL ATTRIBUTE98,NULL ATTRIBUTE99,
    CASE WHEN VO.NGB_PROD_TYPE ='MOC' OR (VO.NGB_PROD_TYPE = 'Shared' AND VAOM.COMMISSION_PRODUCT_TYPE IS NOT NULL)
         THEN VAOM.COMMISSION_PRODUCT_TYPE 
         END ATTRIBUTE100,
    NULL LAST_UPDATE_DATE,NULL CREATION_DATE,
    VAM.CREATED_DATE BOOKED_DATE,
    'REVENUE' REVENUE_TYPE,
    NULL TYPE,NULL EMPLOYEE_NUMBER,NULL RECORD_STATUS,NULL ERROR_TYPE,NULL ERROR_MSG,
    VO.SOURCE_SYSTEM SOURCE,
    VAM.SUBMITTED_DATE SUBMITTED_DATE,
    VAM.STATUS_HEADER STATUS_HEADER,
    VAM.STATUS_ORDER_LINE_ITEM STATUS_ORDER_LINE_ITEM,
    VAM.ORIGINAL_ORDER_NUMBER,
    LT1.STRINGVALUE FOXTEL_HW,
    LT2.STRINGVALUE FOXTEL_PLAN
FROM VAS_OLI VO
    LEFT JOIN VAS_ASSOC_MOLI          VAM ON  VAM.ORDER_NUMBER = VO.ORDER_NUMBER AND  VAM.STATUS_HEADER = VO.STATUS_HEADER AND  VAM.ROW_ID = VO.ROOT_ITEM_ROW_ID
    LEFT JOIN VAS_ASSOC_CONTRACT_OLI VACO ON VACO.ORDER_NUMBER = VO.ORDER_NUMBER AND VACO.STATUS_HEADER = VO.STATUS_HEADER AND VACO.ROOT_ITEM_ROW_ID = VO.ROOT_ITEM_ROW_ID
    LEFT JOIN VAS_ASSOC_FHW_OLI      VAFO ON VAFO.ORDER_NUMBER = VO.ORDER_NUMBER AND VAFO.STATUS_HEADER = VO.STATUS_HEADER AND VAFO.ROOT_ITEM_ROW_ID = VO.ROOT_ITEM_ROW_ID
    LEFT JOIN VAS_ASSOC_OFFER_MOLI VAOM
       ON VAOM.ORDER_NUMBER = VAM.ORDER_NUMBER
      AND VAOM.STATUS_HEADER = VAM.STATUS_HEADER
      AND VAOM.PROMOTION_INTEGRATION_ID =  VAM.PROMOTION_INTEGRATION_ID
--      AND CASE WHEN VAOM.STATUS_ORDER_LINE_ITEM = 'Complete' THEN CASE WHEN VAOM.STATUS_HEADER = 'In-transit' THEN VAOM.STATUS_ORDER_LINE_ITEM WHEN VAOM.STATUS_HEADER = 'Provisioning' THEN VAOM.STATUS_ORDER_LINE_ITEM ELSE VAOM.STATUS_HEADER END ELSE VAOM.STATUS_HEADER END = CASE WHEN VAM.STATUS_ORDER_LINE_ITEM = 'Complete' THEN CASE WHEN VAM.STATUS_HEADER = 'In-transit' THEN VAM.STATUS_ORDER_LINE_ITEM WHEN VAM.STATUS_HEADER = 'Provisioning' THEN VAM.STATUS_ORDER_LINE_ITEM ELSE VAM.STATUS_HEADER END ELSE VAM.STATUS_HEADER END
      AND VAOM.STATUS_ORDER_LINE_ITEM = VAM.STATUS_ORDER_LINE_ITEM
    LEFT JOIN ATTRIBUTES               A1 ON A1.ATTRIBUTE_OWNER_ROW_ID = VACO.ROW_ID AND A1.ORDER_NUMBER = VACO.ORDER_NUMBER AND A1.ATTRIBUTE_DISPLAY_NAME = 'Contract Term'
    LEFT JOIN ATTRIBUTES               A2 ON A2.ATTRIBUTE_OWNER_ROW_ID = VAFO.ROW_ID AND A2.ORDER_NUMBER = VAFO.ORDER_NUMBER AND A2.ATTRIBUTE_DISPLAY_NAME LIKE 'Supplied in Store%'
    LEFT JOIN ATTRIBUTES              A2I ON A2I.ATTRIBUTE_OWNER_ROW_ID = VAFO.ROW_ID AND A2I.ORDER_NUMBER = VAFO.ORDER_NUMBER AND A2I.ATTRIBUTE_DISPLAY_NAME = 'Hardware Supplied'
    LEFT JOIN ATTRIBUTES               A3 ON A3.ATTRIBUTE_OWNER_ROW_ID = VO.ROW_ID AND A3.ORDER_NUMBER = VO.ORDER_NUMBER AND A3.ATTRIBUTE_DISPLAY_NAME LIKE 'Supplied in Store%'
    LEFT JOIN ATTRIBUTES               A4 ON A4.ATTRIBUTE_OWNER_ROW_ID = VO.ROW_ID AND A4.ORDER_NUMBER = VO.ORDER_NUMBER AND A4.ATTRIBUTE_DISPLAY_NAME = 'Hardware Supplied'
    LEFT JOIN LT_FOXTEL_PLAN_HW       LT1 ON LT1.IDX_NAME_0 = VO.PART_NUMBER AND LT1.IDX_NAME_1 = 'HW' AND LT1.STRINGVALUE = 'Yes' AND LT1.STARTDATE <= TO_DATE(NVL(VO.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss') AND LT1.ENDDATE > TO_DATE(NVL(VO.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss')
    LEFT JOIN LT_FOXTEL_PLAN_HW       LT2 ON LT2.IDX_NAME_0 = VO.PART_NUMBER AND LT2.IDX_NAME_1 = 'PLAN' AND LT2.STRINGVALUE = 'Yes' AND LT2.STARTDATE <= TO_DATE(NVL(VO.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss') AND LT2.ENDDATE > TO_DATE(NVL(VO.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss')
WHERE (1=1)
AND NVL(VO.ORDER_SUB_TYPE, 'NULL') <> 'Transfer'
AND VAM.ACTION_CODE IN('Add', '-', 'Update') 
--AND VO.ROW_ID = '1-O8X737B7'
)
SELECT 
    P1.FILENAME,P1.BATCHPROCESSDATE,P1.RECORDNUMBER,P1.PROCESSED_DATE,P1.PROCESSED_PERIOD_ID,P1.TRANSACTION_AMOUNT,P1.QUANTITY,P1.ATTRIBUTE1,P1.ATTRIBUTE2,P1.ATTRIBUTE3,P1.ATTRIBUTE4,P1.ATTRIBUTE5,P1.ATTRIBUTE6,P1.ATTRIBUTE7,P1.ATTRIBUTE8,P1.ATTRIBUTE9,P1.ATTRIBUTE10,P1.ATTRIBUTE11,
    P1.ATTRIBUTE12,P1.ATTRIBUTE13,P1.ATTRIBUTE14,P1.ATTRIBUTE15,P1.ATTRIBUTE16,P1.ATTRIBUTE17,P1.ATTRIBUTE18,P1.ATTRIBUTE19,P1.ATTRIBUTE20,P1.ATTRIBUTE21,P1.ATTRIBUTE22,P1.ATTRIBUTE23,P1.ATTRIBUTE24,P1.ATTRIBUTE25,P1.ATTRIBUTE26,P1.ATTRIBUTE27,P1.ATTRIBUTE28,P1.ATTRIBUTE29,P1.ATTRIBUTE30,
    P1.ATTRIBUTE31,P1.ATTRIBUTE32,P1.ATTRIBUTE33,P1.ATTRIBUTE34,P1.ATTRIBUTE35,P1.ATTRIBUTE36,P1.ATTRIBUTE37,P1.ATTRIBUTE38,P1.ATTRIBUTE39,P1.ATTRIBUTE40,P1.ATTRIBUTE41,P1.ATTRIBUTE42,P1.ATTRIBUTE43,P1.ATTRIBUTE44,P1.ATTRIBUTE45,P1.ATTRIBUTE46,P1.ATTRIBUTE47,P1.ATTRIBUTE48,P1.ATTRIBUTE49,
    P1.ATTRIBUTE50,P1.ATTRIBUTE51,P1.ATTRIBUTE52,P1.ATTRIBUTE53,P1.ATTRIBUTE54,P1.ATTRIBUTE55,P1.ATTRIBUTE56,P1.ATTRIBUTE57,P1.ATTRIBUTE58,P1.ATTRIBUTE59,P1.ATTRIBUTE60,P1.ATTRIBUTE61,P1.ATTRIBUTE62,P1.ATTRIBUTE63,P1.ATTRIBUTE64,P1.ATTRIBUTE65,P1.ATTRIBUTE66,P1.ATTRIBUTE67,P1.ATTRIBUTE68,
    P1.ATTRIBUTE69,P1.ATTRIBUTE70,P1.ATTRIBUTE71,P1.ATTRIBUTE72,P1.ATTRIBUTE73,P1.ATTRIBUTE74,P1.ATTRIBUTE75,P1.ATTRIBUTE76,P1.ATTRIBUTE77,
--    CASE WHEN p1.ATTRIBUTE88 = 'Commissions Convert Plan' 
--         THEN CASE WHEN p1.FOXTEL_HW IS NOT NULL
--                   THEN 'Non-Classified'
--                   WHEN p1.FOXTEL_PLAN IS NOT NULL AND p1.ATTRIBUTE41 <> 'Add'
--                   THEN 'Non-Classified'
--                   END
--         ELSE TO_CHAR(p1.ATTRIBUTE78)
--         END ATTRIBUTE78,
    CASE WHEN P1.ATTRIBUTE88 = 'Commissions Convert Plan' 
         THEN CASE WHEN P1.FOXTEL_HW IS NOT NULL
                   THEN 'Non-Classified'
                   END
         ELSE CASE WHEN P1.FOXTEL_PLAN IS NOT NULL AND P1.ATTRIBUTE41 <> 'Add'
                   THEN 'Non-Classified'
                   ELSE TO_CHAR(P1.ATTRIBUTE78)
                   END
         END ATTRIBUTE78,
    P1.ATTRIBUTE79,P1.ATTRIBUTE80,P1.ATTRIBUTE81,P1.ATTRIBUTE82,P1.ATTRIBUTE83,P1.ATTRIBUTE84,P1.ATTRIBUTE85,P1.ATTRIBUTE86,P1.ATTRIBUTE87,
    CASE WHEN P1.ATTRIBUTE88 = 'Commissions Convert Plan' 
         THEN 'Commissions VAS'
         ELSE P1.ATTRIBUTE88
         END ATTRIBUTE88,
    P1.ATTRIBUTE89,P1.ATTRIBUTE90,P1.ATTRIBUTE91,P1.ATTRIBUTE92,P1.ATTRIBUTE93,P1.ATTRIBUTE94,P1.ATTRIBUTE95,P1.ATTRIBUTE96,P1.ATTRIBUTE97,P1.ATTRIBUTE98,
    P1.ATTRIBUTE99,P1.ATTRIBUTE100,P1.LAST_UPDATE_DATE,P1.CREATION_DATE,P1.BOOKED_DATE,P1.REVENUE_TYPE,P1.TYPE,P1.EMPLOYEE_NUMBER,P1.RECORD_STATUS,P1.ERROR_TYPE,P1.ERROR_MSG,P1.SOURCE,P1.FILENAME,P1.RECORDNUMBER,P1.SUBMITTED_DATE,P1.STATUS_HEADER,P1.STATUS_ORDER_LINE_ITEM,P1.ORIGINAL_ORDER_NUMBER
FROM PASS1 P1
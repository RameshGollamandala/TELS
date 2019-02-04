
WITH ATTRIBUTES AS(
    SELECT d.FILENAME, d.RECORDNUMBER, d.ORDER_NUMBER, d.ROW_ID ATTRIBUTE_OWNER_ROW_ID, d.ATTRIBUTE_ROW_ID, d.ATTRIBUTE_ACTION_CODE, d.ATTRIBUTE_DISPLAY_NAME, d.ATTRIBUTE_VALUE
    FROM TELS_STAGE_RCRM d
    WHERE d.ATTRIBUTE_ROW_ID IS NOT NULL AND NVL(d.ORDER_SUB_TYPE,'NULL') <> 'Transfer')
, VAS_OLI AS(
    SELECT * FROM TELS_SUBMITTED_ORDERS_VIEW WHERE REC_TYPE = 'VAS_OLI')
, VAS_ASSOC_MOLI AS(
    SELECT * FROM TELS_SUBMITTED_ORDERS_VIEW WHERE REC_TYPE = 'VAS_ASSOC_MOLI')
, VAS_ASSOC_CONTRACT_OLI AS(
    SELECT * FROM TELS_SUBMITTED_ORDERS_VIEW WHERE REC_TYPE = 'VAS_ASSOC_CONTRACT_OLI')
, VAS_ASSOC_FHW_OLI AS(
    SELECT * FROM TELS_SUBMITTED_ORDERS_VIEW WHERE REC_TYPE = 'VAS_ASSOC_FHW_OLI')
, VAS_ASSOC_OFFER_MOLI AS(
    SELECT * FROM TELS_SUBMITTED_ORDERS_VIEW WHERE REC_TYPE = 'VAS_ASSOC_OFFER_MOLI')
, LT_Plan_VAS_HW_RO AS(
    SELECT lt.STARTDATE, lt.ENDDATE, lt.DIM_NAME_0, lt.IDX_NAME_0, lt.DIM_NAME_1, lt.IDX_NAME_1, lt.STRINGVALUE
    FROM TELS_RCRM_MV_MDLT lt
    WHERE NAME = 'LT_Plan_VAS_HW_RO')
, LT_Sales_Type_VAS AS(
    SELECT lt.STARTDATE, lt.ENDDATE, lt.DIM_NAME_0, lt.IDX_NAME_0, lt.DIM_NAME_1, lt.IDX_NAME_1, lt.DIM_NAME_2, lt.IDX_NAME_2,lt.DIM_NAME_3, lt.IDX_NAME_3,lt.DIM_NAME_4, lt.IDX_NAME_4, lt.STRINGVALUE
    FROM TELS_RCRM_MV_MDLT lt
    WHERE NAME = 'LT_Sales_Type_VAS')
, LT_Base_Rem_VAS AS(
    SELECT lt.STARTDATE, lt.ENDDATE, lt.DIM_NAME_0, lt.IDX_NAME_0, lt.DIM_NAME_1, lt.IDX_NAME_1, lt.DIM_NAME_2, lt.IDX_NAME_2,lt.DIM_NAME_3, lt.IDX_NAME_3,lt.DIM_NAME_4, lt.IDX_NAME_4, lt.VALUE
    FROM TELS_RCRM_MV_MDLT lt
    WHERE NAME = 'LT_Base_Rem_VAS')
, LT_Foxtel_Plan_HW AS(
    SELECT lt.STARTDATE, lt.ENDDATE, lt.DIM_NAME_0, lt.IDX_NAME_0, lt.DIM_NAME_1, lt.IDX_NAME_1, lt.STRINGVALUE
    FROM TELS_RCRM_MV_MDLT lt
    WHERE NAME = 'LT_Foxtel_Plan_HW')
, PASS1 AS(
SELECT
    vo.FILENAME,
    vo.BATCHPROCESSDATE,
    vo.RECORDNUMBER,
    vam.PROVISIONED_DATE PROCESSED_DATE,
    NULL PROCESSED_PERIOD_ID,
    vo.LIST_PRICE TRANSACTION_AMOUNT,
    '1' QUANTITY,
    vam.CUSTOMER_LAST_NAME ATTRIBUTE1,
    vam.CUSTOMER_FIRST_NAME ATTRIBUTE2,
    NULL ATTRIBUTE3,NULL ATTRIBUTE4,NULL ATTRIBUTE5,NULL ATTRIBUTE6,NULL ATTRIBUTE7,NULL ATTRIBUTE8,NULL ATTRIBUTE9,NULL ATTRIBUTE10,NULL ATTRIBUTE11,NULL ATTRIBUTE12,NULL ATTRIBUTE13,NULL ATTRIBUTE14,NULL ATTRIBUTE15,NULL ATTRIBUTE16,NULL ATTRIBUTE17,NULL ATTRIBUTE18,NULL ATTRIBUTE19,NULL ATTRIBUTE20,NULL ATTRIBUTE21,NULL ATTRIBUTE22,NULL ATTRIBUTE23,NULL ATTRIBUTE24,
    vam.ORDER_NUMBER ATTRIBUTE25,
    vam.BILLING_ACCOUNT ATTRIBUTE26,
    vam.PARTNER_CODE ATTRIBUTE27,
    NULL ATTRIBUTE28,NULL ATTRIBUTE29,NULL ATTRIBUTE30,NULL ATTRIBUTE31,NULL ATTRIBUTE32,NULL ATTRIBUTE33,NULL ATTRIBUTE34,
    vam.BUSINESS_UNIT ATTRIBUTE35,
    vam.SALES_FORCE_ID ATTRIBUTE36,
    'COMMISSIONABLE TRANSACTION' ATTRIBUTE37,
    vam.SOURCE_SYSTEM ATTRIBUTE38,
    vam.PRODUCT ATTRIBUTE39,
    NULL ATTRIBUTE40,
    vam.ACTION_CODE ATTRIBUTE41,
    vam.TRANSFER_TYPE ATTRIBUTE42,
    vam.EVENT_SOURCE ATTRIBUTE43,
    vam.PROMOTION_PART_NUMBER ATTRIBUTE44,
    vam.ORDER_SUB_TYPE ATTRIBUTE45,
    vo.ROW_ID ATTRIBUTE46,
    vo.PRODUCT ATTRIBUTE47,
    NULL ATTRIBUTE48,
    vo.ACTION_CODE ATTRIBUTE49,
    vo.PROMOTION_PART_NUMBER ATTRIBUTE50,
    NULL ATTRIBUTE51,NULL ATTRIBUTE52,NULL ATTRIBUTE53,NULL ATTRIBUTE54,NULL ATTRIBUTE55,NULL ATTRIBUTE56,NULL ATTRIBUTE57,NULL ATTRIBUTE58,NULL ATTRIBUTE59,
    vam.ORDER_TYPE ATTRIBUTE60,
    vaco.ACTION_CODE ATTRIBUTE61,
    vaco.CONTRACT_START_DATE ATTRIBUTE62,
    NULL ATTRIBUTE63,NULL ATTRIBUTE64,
    a1.ATTRIBUTE_VALUE ATTRIBUTE65,
    NULL ATTRIBUTE66,
    CASE WHEN a2.ATTRIBUTE_VALUE IS NOT NULL
          AND EXISTS(SELECT 1 FROM LT_Plan_VAS_HW_RO lt WHERE lt.IDX_NAME_0 =   vo.PART_NUMBER AND lt.IDX_NAME_1 = 'VAS'    AND lt.STRINGVALUE = 'Yes' AND lt.STARTDATE <= TO_DATE(NVL(vo.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss') AND lt.ENDDATE > TO_DATE(NVL(vo.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss'))
          AND EXISTS(SELECT 1 FROM LT_Plan_VAS_HW_RO lt WHERE lt.IDX_NAME_0 = vafo.PART_NUMBER AND lt.IDX_NAME_1 = 'VAS HW' AND lt.STRINGVALUE = 'Yes' AND lt.STARTDATE <= TO_DATE(NVL(vafo.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss') AND lt.ENDDATE > TO_DATE(NVL(vafo.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss'))
         THEN a2.ATTRIBUTE_VALUE 
         WHEN a3.ATTRIBUTE_VALUE IS NOT NULL
         THEN a3.ATTRIBUTE_VALUE
         WHEN a4.ATTRIBUTE_VALUE IS NOT NULL
         THEN a4.ATTRIBUTE_VALUE
         ELSE vo.HARDWARE_SUPPLIED_FLAG
         END ATTRIBUTE67,
    NULL ATTRIBUTE68,NULL ATTRIBUTE69,NULL ATTRIBUTE70,NULL ATTRIBUTE71,NULL ATTRIBUTE72,NULL ATTRIBUTE73,NULL ATTRIBUTE74,NULL ATTRIBUTE75,NULL ATTRIBUTE76,NULL ATTRIBUTE77,
    CASE WHEN vo.ACTION_CODE IS NOT NULL 
         THEN NVL((SELECT STRINGVALUE FROM LT_Sales_Type_VAS lt 
                    WHERE lt.IDX_NAME_0 = NVL(vam.ORDER_TYPE,'NULL')
                      AND lt.IDX_NAME_1 = NVL(vam.ORDER_SUB_TYPE,'NULL')
                      AND lt.IDX_NAME_2 = NVL(vo.ACTION_CODE,'NULL')
                      AND lt.IDX_NAME_3 = NVL(vaco.ACTION_CODE,'NULL')
                      AND lt.STARTDATE <= TO_DATE(NVL(vo.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss') AND lt.ENDDATE > TO_DATE(NVL(vo.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss')
--                      AND EXISTS(SELECT 1 FROM LT_Base_Rem_VAS lt2 
--                                 WHERE lt2.IDX_NAME_0 = vo.PART_NUMBER
--                                   AND lt2.STARTDATE <= TO_DATE(NVL(vo.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss') AND lt2.ENDDATE > TO_DATE(NVL(vo.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss'))
                                   )
             ,'Non-Classified') 
         END ATTRIBUTE78, /*Override determined in Pass2*/
    NULL ATTRIBUTE79,NULL ATTRIBUTE80,
    vo.PART_NUMBER ATTRIBUTE81,
    NULL ATTRIBUTE82,NULL ATTRIBUTE83,NULL ATTRIBUTE84,NULL ATTRIBUTE85,NULL ATTRIBUTE86,NULL ATTRIBUTE87,
    CASE WHEN vo.COMMISSION_PRODUCT_TYPE = 'Commissions Convert Plan' 
         THEN 'Commissions VAS'
         ELSE vo.COMMISSION_PRODUCT_TYPE 
         END ATTRIBUTE88, /*Override determined in Pass2*/
    NULL ATTRIBUTE89,NULL ATTRIBUTE90,NULL ATTRIBUTE91,NULL ATTRIBUTE92,NULL ATTRIBUTE93,NULL ATTRIBUTE94,NULL ATTRIBUTE95,NULL ATTRIBUTE96,NULL ATTRIBUTE97,NULL ATTRIBUTE98,NULL ATTRIBUTE99,
    CASE WHEN vo.NGB_PROD_TYPE ='MOC' OR (vo.NGB_PROD_TYPE = 'Shared' AND vaom.COMMISSION_PRODUCT_TYPE IS NOT NULL)
         THEN vaom.COMMISSION_PRODUCT_TYPE 
         END ATTRIBUTE100,
    NULL LAST_UPDATE_DATE,NULL CREATION_DATE,
    vam.CREATED_DATE BOOKED_DATE,
    'REVENUE' REVENUE_TYPE,
    NULL TYPE,NULL EMPLOYEE_NUMBER,NULL RECORD_STATUS,NULL ERROR_TYPE,NULL ERROR_MSG,
    vo.SOURCE_SYSTEM SOURCE,
    vam.SUBMITTED_DATE SUBMITTED_DATE,
    vam.STATUS_HEADER STATUS_HEADER,
    vam.STATUS_ORDER_LINE_ITEM STATUS_ORDER_LINE_ITEM,
    vam.ORIGINAL_ORDER_NUMBER,
    lt1.STRINGVALUE FOXTEL_HW,
    lt2.STRINGVALUE FOXTEL_PLAN
FROM VAS_OLI vo
    LEFT OUTER JOIN VAS_ASSOC_MOLI          vam ON  vam.ORDER_NUMBER = vo.ORDER_NUMBER AND  vam.STATUS_HEADER = vo.STATUS_HEADER AND  vam.ROW_ID = vo.ROOT_ITEM_ROW_ID-- AND vam.FILENAME = vo.FILENAME
    LEFT OUTER JOIN VAS_ASSOC_CONTRACT_OLI vaco ON vaco.ORDER_NUMBER = vo.ORDER_NUMBER AND vaco.STATUS_HEADER = vo.STATUS_HEADER AND vaco.ROOT_ITEM_ROW_ID = vo.ROOT_ITEM_ROW_ID-- AND vaco.FILENAME = vo.FILENAME
    LEFT OUTER JOIN VAS_ASSOC_FHW_OLI      vafo ON vafo.ORDER_NUMBER = vo.ORDER_NUMBER AND vafo.STATUS_HEADER = vo.STATUS_HEADER AND vafo.ROOT_ITEM_ROW_ID = vo.ROOT_ITEM_ROW_ID-- AND vafo.FILENAME = vo.FILENAME
    LEFT OUTER JOIN VAS_ASSOC_OFFER_MOLI   vaom ON vaom.ORDER_NUMBER = vam.ORDER_NUMBER AND vaom.STATUS_HEADER = vam.STATUS_HEADER AND vaom.PROMOTION_INTEGRATION_ID =  vam.PROMOTION_INTEGRATION_ID-- AND vaom.FILENAME = vam.FILENAME
    LEFT OUTER JOIN ATTRIBUTES               a1 ON a1.ATTRIBUTE_OWNER_ROW_ID = vaco.ROW_ID AND a1.ORDER_NUMBER = vaco.ORDER_NUMBER AND a1.ATTRIBUTE_DISPLAY_NAME = 'Contract Term'-- AND a1.FILENAME = vaco.FILENAME 
    LEFT OUTER JOIN ATTRIBUTES               a2 ON a2.ATTRIBUTE_OWNER_ROW_ID = vafo.ROW_ID AND a2.ORDER_NUMBER = vafo.ORDER_NUMBER AND a2.ATTRIBUTE_DISPLAY_NAME LIKE 'Supplied in Store%'
    LEFT OUTER JOIN ATTRIBUTES               a3 ON a3.ATTRIBUTE_OWNER_ROW_ID = vo.ROW_ID AND a3.ORDER_NUMBER = vo.ORDER_NUMBER AND a3.ATTRIBUTE_DISPLAY_NAME LIKE 'Supplied in Store%'
    LEFT OUTER JOIN ATTRIBUTES               a4 ON a4.ATTRIBUTE_OWNER_ROW_ID = vo.ROW_ID AND a4.ORDER_NUMBER = vo.ORDER_NUMBER AND a4.ATTRIBUTE_DISPLAY_NAME LIKE 'Hardware Supplied'
    LEFT OUTER JOIN LT_Foxtel_Plan_HW       lt1 ON lt1.IDX_NAME_0 = vo.PART_NUMBER AND lt1.IDX_NAME_1 = 'HW' AND lt1.STRINGVALUE = 'Yes' AND lt1.STARTDATE <= TO_DATE(NVL(vo.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss') AND lt1.ENDDATE > TO_DATE(NVL(vo.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss')
    LEFT OUTER JOIN LT_Foxtel_Plan_HW       lt2 ON lt2.IDX_NAME_0 = vo.PART_NUMBER AND lt2.IDX_NAME_1 = 'PLAN' AND lt2.STRINGVALUE = 'Yes' AND lt2.STARTDATE <= TO_DATE(NVL(vo.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss') AND lt2.ENDDATE > TO_DATE(NVL(vo.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss')
WHERE NVL(vo.ORDER_SUB_TYPE,'NULL') <> 'Transfer' AND vam.ACTION_CODE IN('Add','-','Update') 
--and vo.STATUS_HEADER = 'Complete'
--and vo.row_id = '1-O7NK9O7S'
)
SELECT 
    p1.FILENAME,p1.BATCHPROCESSDATE,p1.RECORDNUMBER,p1.PROCESSED_DATE,p1.PROCESSED_PERIOD_ID,p1.TRANSACTION_AMOUNT,p1.QUANTITY,p1.ATTRIBUTE1,p1.ATTRIBUTE2,p1.ATTRIBUTE3,p1.ATTRIBUTE4,p1.ATTRIBUTE5,p1.ATTRIBUTE6,p1.ATTRIBUTE7,p1.ATTRIBUTE8,p1.ATTRIBUTE9,p1.ATTRIBUTE10,p1.ATTRIBUTE11,
    p1.ATTRIBUTE12,p1.ATTRIBUTE13,p1.ATTRIBUTE14,p1.ATTRIBUTE15,p1.ATTRIBUTE16,p1.ATTRIBUTE17,p1.ATTRIBUTE18,p1.ATTRIBUTE19,p1.ATTRIBUTE20,p1.ATTRIBUTE21,p1.ATTRIBUTE22,p1.ATTRIBUTE23,p1.ATTRIBUTE24,p1.ATTRIBUTE25,p1.ATTRIBUTE26,p1.ATTRIBUTE27,p1.ATTRIBUTE28,p1.ATTRIBUTE29,p1.ATTRIBUTE30,
    p1.ATTRIBUTE31,p1.ATTRIBUTE32,p1.ATTRIBUTE33,p1.ATTRIBUTE34,p1.ATTRIBUTE35,p1.ATTRIBUTE36,p1.ATTRIBUTE37,p1.ATTRIBUTE38,p1.ATTRIBUTE39,p1.ATTRIBUTE40,p1.ATTRIBUTE41,p1.ATTRIBUTE42,p1.ATTRIBUTE43,p1.ATTRIBUTE44,p1.ATTRIBUTE45,p1.ATTRIBUTE46,p1.ATTRIBUTE47,p1.ATTRIBUTE48,p1.ATTRIBUTE49,
    p1.ATTRIBUTE50,p1.ATTRIBUTE51,p1.ATTRIBUTE52,p1.ATTRIBUTE53,p1.ATTRIBUTE54,p1.ATTRIBUTE55,p1.ATTRIBUTE56,p1.ATTRIBUTE57,p1.ATTRIBUTE58,p1.ATTRIBUTE59,p1.ATTRIBUTE60,p1.ATTRIBUTE61,p1.ATTRIBUTE62,p1.ATTRIBUTE63,p1.ATTRIBUTE64,p1.ATTRIBUTE65,p1.ATTRIBUTE66,p1.ATTRIBUTE67,p1.ATTRIBUTE68,
    p1.ATTRIBUTE69,p1.ATTRIBUTE70,p1.ATTRIBUTE71,p1.ATTRIBUTE72,p1.ATTRIBUTE73,p1.ATTRIBUTE74,p1.ATTRIBUTE75,p1.ATTRIBUTE76,p1.ATTRIBUTE77,
--    CASE WHEN p1.ATTRIBUTE88 = 'Commissions Convert Plan' 
--         THEN 
         CASE WHEN p1.FOXTEL_HW IS NOT NULL
               THEN 'Non-Classified'
               WHEN p1.FOXTEL_PLAN IS NOT NULL AND p1.ATTRIBUTE41 <> 'Add'
               THEN 'Non-Classified'
--               END
         ELSE TO_CHAR(p1.ATTRIBUTE78)
         END ATTRIBUTE78,
    p1.ATTRIBUTE79,p1.ATTRIBUTE80,p1.ATTRIBUTE81,p1.ATTRIBUTE82,p1.ATTRIBUTE83,p1.ATTRIBUTE84,p1.ATTRIBUTE85,p1.ATTRIBUTE86,p1.ATTRIBUTE87,
    CASE WHEN p1.ATTRIBUTE88 = 'Commissions Convert Plan' 
         THEN 'Commissions VAS'
         ELSE p1.ATTRIBUTE88
         END ATTRIBUTE88,
    p1.ATTRIBUTE89,p1.ATTRIBUTE90,p1.ATTRIBUTE91,p1.ATTRIBUTE92,p1.ATTRIBUTE93,p1.ATTRIBUTE94,p1.ATTRIBUTE95,p1.ATTRIBUTE96,p1.ATTRIBUTE97,p1.ATTRIBUTE98,
    p1.ATTRIBUTE99,p1.ATTRIBUTE100,p1.LAST_UPDATE_DATE,p1.CREATION_DATE,p1.BOOKED_DATE,p1.REVENUE_TYPE,p1.TYPE,p1.EMPLOYEE_NUMBER,p1.RECORD_STATUS,p1.ERROR_TYPE,p1.ERROR_MSG,p1.SOURCE,p1.FILENAME,p1.RECORDNUMBER,p1.SUBMITTED_DATE,p1.STATUS_HEADER,p1.STATUS_ORDER_LINE_ITEM,p1.ORIGINAL_ORDER_NUMBER
FROM PASS1 p1
--WHERE p1.FILENAME = '$$filename'
;

SELECT * FROM TELS_SUBMITTED_ORDERS_VIEW WHERE ORDER_NUMBER = '1-1881473295249' ORDER BY REC_TYPE;
SELECT * FROM TELS_PRESTAGE_RCRM WHERE ORDER_NUMBER = '1-1881473295249';
SELECT * FROM TELS_STAGE_RCRM_PPE WHERE ATTRIBUTE46 = '1-O7NK9O7S';
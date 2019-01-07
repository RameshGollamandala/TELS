--PPE Matrix
WITH ATTRIBUTES AS(
    SELECT d.FILENAME, d.RECORDNUMBER, d.ORDER_NUMBER, d.ROW_ID ATTRIBUTE_OWNER_ROW_ID, d.ATTRIBUTE_ROW_ID, d.ATTRIBUTE_ACTION_CODE, d.ATTRIBUTE_DISPLAY_NAME, d.ATTRIBUTE_VALUE
    FROM TELS_STAGE_RCRM d
    WHERE d.ATTRIBUTE_ROW_ID IS NOT NULL)
, MP_OLI AS(
    SELECT * FROM TELS_SUBMITTED_ORDERS_VIEW WHERE REC_TYPE = 'MP_OLI')
, MP_ASSOC_MOLI AS(
    SELECT * FROM TELS_SUBMITTED_ORDERS_VIEW WHERE REC_TYPE = 'MP_ASSOC_MOLI')
, MP_ASSOC_FHW_OLI AS(
    SELECT * FROM TELS_SUBMITTED_ORDERS_VIEW WHERE REC_TYPE = 'MP_ASSOC_FHW_OLI')
, MP_ASSOC_MAIN_CONT_ADD_OLI AS(
    SELECT * FROM TELS_SUBMITTED_ORDERS_VIEW WHERE REC_TYPE = 'MP_ASSOC_MAIN_CONT_ADD_OLI')
, MP_ASSOC_MAIN_CONT_DEL_OLI AS(
    SELECT * FROM TELS_SUBMITTED_ORDERS_VIEW WHERE REC_TYPE = 'MP_ASSOC_MAIN_CONT_DEL_OLI')
, MP_ASSOC_SERVICE_MOLI AS(
    SELECT * FROM TELS_SUBMITTED_ORDERS_VIEW WHERE REC_TYPE = 'MP_ASSOC_SERVICE_MOLI')
, SERVICE_ASSOC_ACCESS_TYPE_OLI AS(
    SELECT * FROM TELS_SUBMITTED_ORDERS_VIEW WHERE REC_TYPE = 'SERVICE_ASSOC_ACCESS_TYPE_OLI')
, LT_Allowable_Recon_Period AS(
    SELECT lt.STARTDATE, lt.ENDDATE, lt.DIM_NAME_0, lt.IDX_NAME_0, lt.DIM_NAME_1, lt.IDX_NAME_1, lt.VALUE
    FROM TELS_RCRM_MV_MDLT lt
    WHERE NAME = 'LT_Allowable_Recon_Period')
, LT_Service_Access_Type AS(
    SELECT lt.STARTDATE, lt.ENDDATE, lt.DIM_NAME_0, lt.IDX_NAME_0, lt.DIM_NAME_1, lt.IDX_NAME_1, lt.STRINGVALUE
    FROM TELS_RCRM_MV_MDLT lt
    WHERE NAME = 'LT_Service_Access_Type')
, LT_Plan_VAS_HW_RO AS(
    SELECT lt.STARTDATE, lt.ENDDATE, lt.DIM_NAME_0, lt.IDX_NAME_0, lt.DIM_NAME_1, lt.IDX_NAME_1, lt.STRINGVALUE
    FROM TELS_RCRM_MV_MDLT lt
    WHERE NAME = 'LT_Plan_VAS_HW_RO')
, LT_Sales_Type_Main_Plan AS(
    SELECT lt.STARTDATE, lt.ENDDATE, lt.DIM_NAME_0, lt.IDX_NAME_0, lt.DIM_NAME_1, lt.IDX_NAME_1, lt.DIM_NAME_2, lt.IDX_NAME_2, lt.DIM_NAME_3, lt.IDX_NAME_3, lt.DIM_NAME_4, lt.IDX_NAME_4, lt.DIM_NAME_5, lt.IDX_NAME_5, lt.DIM_NAME_6, lt.IDX_NAME_6, lt.DIM_NAME_7, lt.IDX_NAME_7, lt.DIM_NAME_8, lt.IDX_NAME_8, lt.STRINGVALUE
    FROM TELS_RCRM_MV_MDLT lt
    WHERE NAME = 'LT_Sales_Type_Main_Plan')
, PRODUCT AS(
    SELECT cls.NAME, prd.GENERICATTRIBUTE1 
    FROM   
      cs_CategoryTree@tc_link ctr 
      JOIN cs_Category_Classifiers@tc_link ccl ON
        ccl.removedate = TO_DATE('01-01-2200','DD-MM-YYYY')
        and ccl.categoryTreeSeq = ctr.categoryTreeSeq
        and ccl.TENANTID = ctr.TENANTID
      JOIN cs_classifier@tc_link cls ON
        cls.removedate = TO_DATE('01-01-2200','DD-MM-YYYY')
        and cls.classifierseq = ccl.classifierseq
        and cls.TENANTID = ccl.TENANTID
      JOIN CS_PRODUCT@TC_LINK prd ON
        prd.removedate = TO_DATE('01-01-2200','DD-MM-YYYY')
        and prd.classifierseq = cls.classifierseq
        and prd.TENANTID = cls.TENANTID
    WHERE
        ctr.removedate = TO_DATE('01-01-2200','DD-MM-YYYY')
        and ctr.TENANTID = 'TELS'
        and ctr.NAME = 'Product_Category'
    GROUP BY cls.NAME, prd.GENERICATTRIBUTE1) -- !!! Needs to be fixed for effective dating
, PASS1 AS (
SELECT
    mo.FILENAME,
    mo.BATCHPROCESSDATE,
    mo.RECORDNUMBER,
    mpam.PROVISIONED_DATE PROCESSED_DATE,
    NULL PROCESSED_PERIOD_ID,
    mo.LIST_PRICE TRANSACTION_AMOUNT,
    '1' QUANTITY,
    mpam.CUSTOMER_LAST_NAME ATTRIBUTE1,
    mpam.CUSTOMER_FIRST_NAME ATTRIBUTE2,
    NULL ATTRIBUTE3,NULL ATTRIBUTE4,NULL ATTRIBUTE5,NULL ATTRIBUTE6,NULL ATTRIBUTE7,NULL ATTRIBUTE8,NULL ATTRIBUTE9,NULL ATTRIBUTE10,NULL ATTRIBUTE11,NULL ATTRIBUTE12,NULL ATTRIBUTE13,NULL ATTRIBUTE14,NULL ATTRIBUTE15,NULL ATTRIBUTE16,NULL ATTRIBUTE17,NULL ATTRIBUTE18,NULL ATTRIBUTE19,NULL ATTRIBUTE20,NULL ATTRIBUTE21,NULL ATTRIBUTE22,NULL ATTRIBUTE23,NULL ATTRIBUTE24,
    mpam.ORDER_NUMBER ATTRIBUTE25,
    mpam.BILLING_ACCOUNT ATTRIBUTE26,
    mpam.PARTNER_CODE ATTRIBUTE27,
    NULL ATTRIBUTE28,NULL ATTRIBUTE29,NULL ATTRIBUTE30,NULL ATTRIBUTE31,NULL ATTRIBUTE32,NULL ATTRIBUTE33,NULL ATTRIBUTE34,
    mpam.BUSINESS_UNIT ATTRIBUTE35,
    mpam.SALES_FORCE_ID ATTRIBUTE36,
    'COMMISSIONABLE TRANSACTION' ATTRIBUTE37,
    mpam.SOURCE_SYSTEM ATTRIBUTE38,
    mpam.PRODUCT ATTRIBUTE39,
    NULL ATTRIBUTE40,
    mpam.ACTION_CODE ATTRIBUTE41,
    mpam.TRANSFER_TYPE ATTRIBUTE42,
    CASE WHEN masm_v.PRODUCT = 'Voice Service' 
         THEN masm_v.EVENT_SOURCE 
         END ATTRIBUTE43,
    mpam.PROMOTION_PART_NUMBER ATTRIBUTE44,
    CASE WHEN mpam.ORDER_TYPE = 'Modify' AND mpam.SUB_ACTION_CODE IN('Transition-Add','Transition-Delete')
         THEN 'Transition'
         ELSE mpam.ORDER_SUB_TYPE 
         END ATTRIBUTE45,
    mo.ROW_ID ATTRIBUTE46,
    mo.PRODUCT ATTRIBUTE47,
    NULL ATTRIBUTE48,
    mo.ACTION_CODE ATTRIBUTE49,
    mo.PROD_PROM_ID ATTRIBUTE50,
    NULL ATTRIBUTE51,NULL ATTRIBUTE52,NULL ATTRIBUTE53,NULL ATTRIBUTE54,NULL ATTRIBUTE55,NULL ATTRIBUTE56,NULL ATTRIBUTE57,NULL ATTRIBUTE58,NULL ATTRIBUTE59,
    CASE WHEN mpam.ORDER_TYPE = 'Modify' AND mpam.SUB_ACTION_CODE IN('Move-Add','Move-Delete')
         THEN 'Move'
         WHEN mpam.ORDER_TYPE = 'Modify' AND mpam.SUB_ACTION_CODE IN('Transition-Add','Transition-Delete')
         THEN 'Add New Service'
         ELSE mpam.ORDER_TYPE 
         END ATTRIBUTE60,
    mcao.ACTION_CODE ATTRIBUTE61, /*Override Determined in Pass2*/
    mcao.CONTRACT_START_DATE ATTRIBUTE62,
    lt_v.STRINGVALUE || CASE WHEN lt_i.STRINGVALUE IS NULL OR lt_v.STRINGVALUE IS NULL THEN NULL ELSE '+' END || lt_i.STRINGVALUE ATTRIBUTE63, 
    CASE WHEN masm_i.PRODUCT = 'Internet Service' 
         THEN sato_i.PRODUCT 
         ELSE CASE WHEN CASE WHEN mpam.ORDER_TYPE = 'Modify' AND mpam.SUB_ACTION_CODE IN('Transition-Add','Transition-Delete')
                         THEN 'Add New Service'
                         ELSE mpam.ORDER_TYPE 
                         END <> 'Move'
                   THEN 'MIXED'
                   END
         END ATTRIBUTE64,
    a1.ATTRIBUTE_VALUE ATTRIBUTE65, /*Determined in Pass2*/
    NULL ATTRIBUTE66,
    CASE WHEN a3.ATTRIBUTE_VALUE IS NOT NULL AND lt3.STRINGVALUE = 'Yes' AND lt4.STRINGVALUE = 'Yes'
         THEN a3.ATTRIBUTE_VALUE
         ELSE mo.HARDWARE_SUPPLIED_FLAG
         END ATTRIBUTE67, 
    NULL ATTRIBUTE68,
    mcdo.CONTRACT_START_DATE ATTRIBUTE69,
    mcdo.ROW_ID,
    NULL ATTRIBUTE70,NULL ATTRIBUTE71,
    a2.ATTRIBUTE_VALUE ATTRIBUTE72,
    NULL ATTRIBUTE73,NULL ATTRIBUTE74,NULL ATTRIBUTE75,NULL ATTRIBUTE76,NULL ATTRIBUTE77,
    NVL(lt.STRINGVALUE,'Non-Classified') ATTRIBUTE78,
    NULL ATTRIBUTE79, /*Determined in Pass2*/
    NULL ATTRIBUTE80,
    mo.PART_NUMBER ATTRIBUTE81,
    NULL ATTRIBUTE82,NULL ATTRIBUTE83,NULL ATTRIBUTE84,NULL ATTRIBUTE85,NULL ATTRIBUTE86,NULL ATTRIBUTE87,
    mo.COMMISSION_PRODUCT_TYPE ATTRIBUTE88,
    NULL ATTRIBUTE89,NULL ATTRIBUTE90,NULL ATTRIBUTE91,NULL ATTRIBUTE92,NULL ATTRIBUTE93,NULL ATTRIBUTE94,NULL ATTRIBUTE95,NULL ATTRIBUTE96,NULL ATTRIBUTE97,NULL ATTRIBUTE98,NULL ATTRIBUTE99,NULL ATTRIBUTE100,
    NULL LAST_UPDATE_DATE,NULL CREATION_DATE,
    mpam.CREATED_DATE BOOKED_DATE,
    'REVENUE' REVENUE_TYPE,
    NULL TYPE,NULL EMPLOYEE_NUMBER,NULL RECORD_STATUS,NULL ERROR_TYPE,NULL ERROR_MSG,
    mpam.SOURCE_SYSTEM SOURCE,
    mpam.SUBMITTED_DATE SUBMITTED_DATE,
    mpam.STATUS_HEADER STATUS_HEADER,
    mpam.STATUS_ORDER_LINE_ITEM STATUS_ORDER_LINE_ITEM,
    mo.EFFECTIVE_DATE EFFECTIVE_DATE
FROM 
  MP_OLI mo
  LEFT OUTER JOIN MP_ASSOC_MOLI                 mpam ON mpam.ORDER_NUMBER = mo.ORDER_NUMBER AND mpam.STATUS_HEADER = mo.STATUS_HEADER AND mpam.ROW_ID = mo.ROOT_ITEM_ROW_ID AND mpam.FILENAME = mo.FILENAME
  LEFT OUTER JOIN MP_ASSOC_FHW_OLI              mafo ON mafo.ORDER_NUMBER = mo.ORDER_NUMBER AND mafo.STATUS_HEADER = mo.STATUS_HEADER AND mafo.ROOT_ITEM_ROW_ID = mo.ROOT_ITEM_ROW_ID AND mafo.FILENAME = mo.FILENAME
  LEFT OUTER JOIN MP_ASSOC_MAIN_CONT_ADD_OLI    mcao ON mcao.ORDER_NUMBER = mo.ORDER_NUMBER AND mcao.STATUS_HEADER = mo.STATUS_HEADER AND mcao.ROOT_ITEM_ROW_ID = mo.ROOT_ITEM_ROW_ID AND mcao.FILENAME = mo.FILENAME
  LEFT OUTER JOIN MP_ASSOC_MAIN_CONT_DEL_OLI    mcdo ON mcdo.ORDER_NUMBER = mo.ORDER_NUMBER AND mcdo.STATUS_HEADER = mo.STATUS_HEADER AND mcdo.ROOT_ITEM_ROW_ID = mo.ROOT_ITEM_ROW_ID AND mcdo.FILENAME = mo.FILENAME
  LEFT OUTER JOIN MP_ASSOC_SERVICE_MOLI       masm_i ON masm_i.ORDER_NUMBER = mpam.ORDER_NUMBER AND masm_i.STATUS_HEADER = mpam.STATUS_HEADER AND masm_i.PROMOTION_INTEGRATION_ID = mpam.PROMOTION_INTEGRATION_ID AND masm_i.FILENAME = mpam.FILENAME AND masm_i.PRODUCT = 'Internet Service'
  LEFT OUTER JOIN MP_ASSOC_SERVICE_MOLI       masm_v ON masm_v.ORDER_NUMBER = mpam.ORDER_NUMBER AND masm_v.STATUS_HEADER = mpam.STATUS_HEADER AND masm_v.PROMOTION_INTEGRATION_ID = mpam.PROMOTION_INTEGRATION_ID AND masm_v.FILENAME = mpam.FILENAME AND masm_v.PRODUCT = 'Voice Service'
  LEFT OUTER JOIN SERVICE_ASSOC_ACCESS_TYPE_OLI sato_i ON sato_i.ORDER_NUMBER = masm_i.ORDER_NUMBER AND sato_i.STATUS_HEADER = masm_i.STATUS_HEADER AND sato_i.ROOT_ITEM_ROW_ID = masm_i.ROOT_ITEM_ROW_ID AND sato_i.FILENAME = masm_i.FILENAME AND sato_i.ACTION_CODE IN('Add','-','Update')
  LEFT OUTER JOIN SERVICE_ASSOC_ACCESS_TYPE_OLI sato_v ON sato_v.ORDER_NUMBER = masm_v.ORDER_NUMBER AND sato_v.STATUS_HEADER = masm_v.STATUS_HEADER AND sato_v.ROOT_ITEM_ROW_ID = masm_v.ROOT_ITEM_ROW_ID AND sato_v.FILENAME = masm_v.FILENAME AND sato_v.ACTION_CODE IN('Add','-','Update')
  LEFT OUTER JOIN ATTRIBUTES                    a1 ON a1.ATTRIBUTE_OWNER_ROW_ID = mcao.ROW_ID AND a1.ORDER_NUMBER = mcao.ORDER_NUMBER AND a1.FILENAME = mcao.FILENAME AND a1.ATTRIBUTE_DISPLAY_NAME = 'Contract Term'
  LEFT OUTER JOIN ATTRIBUTES                    a2 ON a2.ATTRIBUTE_OWNER_ROW_ID = mcdo.ROW_ID AND a2.ORDER_NUMBER = mcdo.ORDER_NUMBER AND a2.FILENAME = mcdo.FILENAME AND a2.ATTRIBUTE_DISPLAY_NAME = 'Contract Term'
  LEFT OUTER JOIN ATTRIBUTES                    a3 ON a3.ATTRIBUTE_OWNER_ROW_ID = mafo.ROW_ID AND a3.ORDER_NUMBER = mafo.ORDER_NUMBER AND a3.FILENAME = mafo.FILENAME AND a3.ATTRIBUTE_DISPLAY_NAME = 'Supplied in Store?'
  LEFT OUTER JOIN LT_Service_Access_Type      lt_i ON lt_i.IDX_NAME_0 = masm_i.PRODUCT AND lt_i.IDX_NAME_1 = sato_i.PRODUCT AND sato_i.ACTION_CODE = 'Add' AND NVL(masm_i.SUB_ACTION_CODE,'NULL') NOT IN('Transition-Add','Move-Add') AND lt_i.STARTDATE <= TO_DATE(NVL(masm_i.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss') AND lt_i.ENDDATE > TO_DATE(NVL(masm_i.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss')
  LEFT OUTER JOIN LT_Service_Access_Type      lt_v ON lt_v.IDX_NAME_0 = masm_v.PRODUCT AND lt_v.IDX_NAME_1 = sato_v.PRODUCT AND sato_v.ACTION_CODE = 'Add' AND NVL(masm_v.SUB_ACTION_CODE,'NULL') NOT IN('Transition-Add','Move-Add') AND lt_v.STARTDATE <= TO_DATE(NVL(masm_v.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss') AND lt_v.ENDDATE > TO_DATE(NVL(masm_v.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss')
  LEFT OUTER JOIN LT_Sales_Type_Main_Plan       lt ON   lt.IDX_NAME_0 = NVL(mpam.ORDER_TYPE,'NULL')    AND lt.IDX_NAME_1 = NVL(mpam.ORDER_SUB_TYPE,'NULL') 
                                                    AND lt.IDX_NAME_2 = NVL(mpam.TRANSFER_TYPE,'NULL') AND lt.IDX_NAME_3 = NVL(mpam.ACTION_CODE,'NULL') 
                                                    AND lt.IDX_NAME_4 = NVL(mo.ACTION_CODE,'NULL')     AND lt.IDX_NAME_5 = NVL(mcao.ACTION_CODE,'NULL') 
                                                    AND lt.IDX_NAME_6 = NVL(mcdo.ACTION_CODE,'NULL')   AND lt.IDX_NAME_7 = NVL(mo.COMMISSION_PRODUCT_TYPE,'NULL')
                                                    AND lt.IDX_NAME_8 = NVL(CASE WHEN mpam.PRODUCT = 'Mobile Service' AND mpam.REASON_CODE = 'Migration to Siebel' and mpam.ORDER_TYPE = 'Add New Service' THEN mpam.REASON_CODE ELSE NULL END,'NULL')
                                                    AND lt.STARTDATE <= TO_DATE(NVL(mo.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss') AND lt.ENDDATE > TO_DATE(NVL(mo.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss')
  LEFT OUTER JOIN LT_Plan_VAS_HW_RO            lt3 ON lt3.IDX_NAME_0 = mafo.PART_NUMBER AND lt3.IDX_NAME_1 = 'PLAN HW' AND lt3.STRINGVALUE = 'Yes' AND lt3.STARTDATE <= TO_DATE(NVL(mafo.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss') AND lt3.ENDDATE > TO_DATE(NVL(mafo.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss')
  LEFT OUTER JOIN LT_Plan_VAS_HW_RO            lt4 ON lt4.IDX_NAME_0 = mo.PART_NUMBER AND lt4.IDX_NAME_1 = 'PLAN' AND lt4.STRINGVALUE = 'Yes' AND lt4.STARTDATE <= TO_DATE(NVL(mafo.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss') AND lt4.ENDDATE > TO_DATE(NVL(mafo.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss')
WHERE NVL(mo.ORDER_SUB_TYPE,'NULL') <> 'Transfer' 
  AND mo.NGB_PROD_TYPE = 'MOC' 
  AND mpam.COMMISSION_PRODUCT_TYPE = 'Commissions Bundle'
--  AND mo.STATUS_HEADER = 'Complete'
--  and mo.row_id = '1-MQPWFSNM'
)
, PASS2 AS(
SELECT
    p1.FILENAME,p1.BATCHPROCESSDATE,p1.RECORDNUMBER,p1.PROCESSED_DATE,p1.PROCESSED_PERIOD_ID,p1.TRANSACTION_AMOUNT,p1.QUANTITY,p1.ATTRIBUTE1,p1.ATTRIBUTE2,p1.ATTRIBUTE3,p1.ATTRIBUTE4,p1.ATTRIBUTE5,p1.ATTRIBUTE6,p1.ATTRIBUTE7,p1.ATTRIBUTE8,p1.ATTRIBUTE9,p1.ATTRIBUTE10,p1.ATTRIBUTE11,
    p1.ATTRIBUTE12,p1.ATTRIBUTE13,p1.ATTRIBUTE14,p1.ATTRIBUTE15,p1.ATTRIBUTE16,p1.ATTRIBUTE17,p1.ATTRIBUTE18,p1.ATTRIBUTE19,p1.ATTRIBUTE20,p1.ATTRIBUTE21,p1.ATTRIBUTE22,p1.ATTRIBUTE23,p1.ATTRIBUTE24,p1.ATTRIBUTE25,p1.ATTRIBUTE26,p1.ATTRIBUTE27,p1.ATTRIBUTE28,p1.ATTRIBUTE29,p1.ATTRIBUTE30,
    p1.ATTRIBUTE31,p1.ATTRIBUTE32,p1.ATTRIBUTE33,p1.ATTRIBUTE34,p1.ATTRIBUTE35,p1.ATTRIBUTE36,p1.ATTRIBUTE37,p1.ATTRIBUTE38,p1.ATTRIBUTE39,p1.ATTRIBUTE40,p1.ATTRIBUTE41,p1.ATTRIBUTE42,p1.ATTRIBUTE43,p1.ATTRIBUTE44,p1.ATTRIBUTE45,p1.ATTRIBUTE46,p1.ATTRIBUTE47,p1.ATTRIBUTE48,p1.ATTRIBUTE49,
    p1.ATTRIBUTE50,p1.ATTRIBUTE51,p1.ATTRIBUTE52,p1.ATTRIBUTE53,p1.ATTRIBUTE54,p1.ATTRIBUTE55,p1.ATTRIBUTE56,p1.ATTRIBUTE57,p1.ATTRIBUTE58,p1.ATTRIBUTE59,p1.ATTRIBUTE60,
    CASE WHEN p1.ATTRIBUTE45 = 'Transition' AND prd.GENERICATTRIBUTE1 = 'Fixed Line' AND p1.ATTRIBUTE64 LIKE 'NBN%'
         THEN NULL
         ELSE p1.ATTRIBUTE61 
         END ATTRIBUTE61,
    p1.ATTRIBUTE62, p1.ATTRIBUTE63,p1.ATTRIBUTE64,
    CASE WHEN p1.ATTRIBUTE45 = 'Transition' AND prd.GENERICATTRIBUTE1 = 'Broadband Fixed' AND p1.ATTRIBUTE64 LIKE 'NBN%'
         THEN '24'
         ELSE p1.ATTRIBUTE65 
         END ATTRIBUTE65,
    p1.ATTRIBUTE66,p1.ATTRIBUTE67,p1.ATTRIBUTE68,
    p1.ATTRIBUTE69,p1.ATTRIBUTE70,p1.ATTRIBUTE71,p1.ATTRIBUTE72,p1.ATTRIBUTE73,p1.ATTRIBUTE74,p1.ATTRIBUTE75,p1.ATTRIBUTE76,p1.ATTRIBUTE77,p1.ATTRIBUTE78,
    p1.ATTRIBUTE80,p1.ATTRIBUTE81,p1.ATTRIBUTE82,p1.ATTRIBUTE83,p1.ATTRIBUTE84,p1.ATTRIBUTE85,p1.ATTRIBUTE86,p1.ATTRIBUTE87,p1.ATTRIBUTE88,p1.ATTRIBUTE89,p1.ATTRIBUTE90,p1.ATTRIBUTE91,p1.ATTRIBUTE92,p1.ATTRIBUTE93,p1.ATTRIBUTE94,p1.ATTRIBUTE95,p1.ATTRIBUTE96,p1.ATTRIBUTE97,p1.ATTRIBUTE98,
    p1.ATTRIBUTE99,p1.ATTRIBUTE100,p1.LAST_UPDATE_DATE,p1.CREATION_DATE,p1.BOOKED_DATE,p1.REVENUE_TYPE,p1.TYPE,p1.EMPLOYEE_NUMBER,p1.RECORD_STATUS,p1.ERROR_TYPE,p1.ERROR_MSG,p1.SOURCE,p1.SUBMITTED_DATE,p1.STATUS_HEADER,p1.STATUS_ORDER_LINE_ITEM
    ,prd.GENERICATTRIBUTE1 PRD_GA1, lt1.VALUE LT_Allowable_Recon_Period_VAL
FROM PASS1 p1
  LEFT OUTER JOIN PRODUCT                   prd ON prd.NAME = p1.ATTRIBUTE39
  LEFT OUTER JOIN LT_Allowable_Recon_Period lt1 ON lt1.IDX_NAME_0 = prd.GENERICATTRIBUTE1 AND lt1.IDX_NAME_1 = p1.ATTRIBUTE65 AND lt1.STARTDATE <= TO_DATE(NVL(p1.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss') AND lt1.ENDDATE > TO_DATE(NVL(p1.EFFECTIVE_DATE, '01/01/2200 00:00:00'),'dd/mm/yyyy hh24:mi:ss')
)
SELECT
    p2.FILENAME,p2.BATCHPROCESSDATE,p2.RECORDNUMBER,p2.PROCESSED_DATE,p2.PROCESSED_PERIOD_ID,p2.TRANSACTION_AMOUNT,p2.QUANTITY,p2.ATTRIBUTE1,p2.ATTRIBUTE2,p2.ATTRIBUTE3,p2.ATTRIBUTE4,p2.ATTRIBUTE5,p2.ATTRIBUTE6,p2.ATTRIBUTE7,p2.ATTRIBUTE8,p2.ATTRIBUTE9,p2.ATTRIBUTE10,p2.ATTRIBUTE11,
    p2.ATTRIBUTE12,p2.ATTRIBUTE13,p2.ATTRIBUTE14,p2.ATTRIBUTE15,p2.ATTRIBUTE16,p2.ATTRIBUTE17,p2.ATTRIBUTE18,p2.ATTRIBUTE19,p2.ATTRIBUTE20,p2.ATTRIBUTE21,p2.ATTRIBUTE22,p2.ATTRIBUTE23,p2.ATTRIBUTE24,p2.ATTRIBUTE25,p2.ATTRIBUTE26,p2.ATTRIBUTE27,p2.ATTRIBUTE28,p2.ATTRIBUTE29,p2.ATTRIBUTE30,
    p2.ATTRIBUTE31,p2.ATTRIBUTE32,p2.ATTRIBUTE33,p2.ATTRIBUTE34,p2.ATTRIBUTE35,p2.ATTRIBUTE36,p2.ATTRIBUTE37,p2.ATTRIBUTE38,p2.ATTRIBUTE39,p2.ATTRIBUTE40,p2.ATTRIBUTE41,p2.ATTRIBUTE42,p2.ATTRIBUTE43,p2.ATTRIBUTE44,p2.ATTRIBUTE45,p2.ATTRIBUTE46,p2.ATTRIBUTE47,p2.ATTRIBUTE48,p2.ATTRIBUTE49,
    p2.ATTRIBUTE50,p2.ATTRIBUTE51,p2.ATTRIBUTE52,p2.ATTRIBUTE53,p2.ATTRIBUTE54,p2.ATTRIBUTE55,p2.ATTRIBUTE56,p2.ATTRIBUTE57,p2.ATTRIBUTE58,p2.ATTRIBUTE59,p2.ATTRIBUTE60,p2.ATTRIBUTE61,
    CASE WHEN p2.ATTRIBUTE62 IS NULL AND p2.ATTRIBUTE61 = 'Add' AND p2.ATTRIBUTE65 = '24'
         THEN p2.PROCESSED_DATE
         ELSE p2.ATTRIBUTE62
         END ATTRIBUTE62,
    CASE WHEN p2.ATTRIBUTE65 = '0'
         THEN NULL 
         ELSE p2.ATTRIBUTE63
         END ATTRIBUTE63,
    p2.ATTRIBUTE64,p2.ATTRIBUTE65,p2.ATTRIBUTE66,p2.ATTRIBUTE67,p2.ATTRIBUTE68,p2.ATTRIBUTE69,p2.ATTRIBUTE70,p2.ATTRIBUTE71,p2.ATTRIBUTE72,p2.ATTRIBUTE73,p2.ATTRIBUTE74,p2.ATTRIBUTE75,p2.ATTRIBUTE76,p2.ATTRIBUTE77,p2.ATTRIBUTE78,
    CASE WHEN (p2.ATTRIBUTE62 IS NULL OR p2.ATTRIBUTE69 IS NULL OR p2.ATTRIBUTE72 IS NULL) 
              OR (trunc(TO_DATE(p2.ATTRIBUTE69,'dd/mm/yyyy hh24:mi:ss')) + ((p2.ATTRIBUTE72/12)*365) - trunc(TO_DATE(p2.ATTRIBUTE62,'dd/mm/yyyy hh24:mi:ss'))) <= p2.LT_Allowable_Recon_Period_VAL
         THEN 'No'
         ELSE 'Yes'
         END ATTRIBUTE79,   
    p2.ATTRIBUTE80,p2.ATTRIBUTE81,p2.ATTRIBUTE82,p2.ATTRIBUTE83,p2.ATTRIBUTE84,p2.ATTRIBUTE85,p2.ATTRIBUTE86,p2.ATTRIBUTE87,p2.ATTRIBUTE88,p2.ATTRIBUTE89,p2.ATTRIBUTE90,p2.ATTRIBUTE91,p2.ATTRIBUTE92,p2.ATTRIBUTE93,p2.ATTRIBUTE94,p2.ATTRIBUTE95,p2.ATTRIBUTE96,p2.ATTRIBUTE97,p2.ATTRIBUTE98,
    p2.ATTRIBUTE99,p2.ATTRIBUTE100,p2.LAST_UPDATE_DATE,p2.CREATION_DATE,p2.BOOKED_DATE,p2.REVENUE_TYPE,p2.TYPE,p2.EMPLOYEE_NUMBER,p2.RECORD_STATUS,p2.ERROR_TYPE,p2.ERROR_MSG,p2.SOURCE,p2.FILENAME,p2.RECORDNUMBER,p2.SUBMITTED_DATE,p2.STATUS_HEADER,p2.STATUS_ORDER_LINE_ITEM
FROM PASS2 p2
--WHERE p2.FILENAME = '$$filename'
--AND 
--WHERE p2.ATTRIBUTE46 = '1-MMJR3OVT'
;

SELECT C_ATTRIBUTE25, C_ATTRIBUTE46, O_ATTRIBUTE78, C_ATTRIBUTE78, O_ATTRIBUTE63, C_ATTRIBUTE63 FROM TEST_PREPROC_COMPARISON WHERE O_ATTRIBUTE88 = 'Commissions Main Plan' AND COMPARE_ATTRIBUTE63 = 0;

    SELECT lt.STARTDATE, lt.ENDDATE, lt.DIM_NAME_0, lt.IDX_NAME_0, lt.DIM_NAME_1, lt.IDX_NAME_1, lt.STRINGVALUE
    FROM TELS_RCRM_MV_MDLT lt
    WHERE NAME = 'LT_Service_Access_Type' AND lt.IDX_NAME_0 IN('Internet Service','Voice Service') 
    AND lt.IDX_NAME_1 like 'NBN FTTN Access%';
    
SELECT * FROM TELS_SUBMITTED_ORDERS_VIEW WHERE ORDER_NUMBER = '1-1781214299379' ORDER BY REC_TYPE;
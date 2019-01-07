--Pre paybatch
SELECT
    cdt.CREDITSEQ COMMISSION_HEADER_ID,
    cdt.CREDITSEQ CL_COMMISSION_HEADER_ID,
    cdt.CREDITSEQ CL_COMMISSION_LINE_ID,
    txn.COMPENSATIONDATE CH_PROCESSED_DATE,
    ord.ORDERID ORDER_NUMBER,
    etx.GENERICATTRIBUTE4 ORDER_LINE_ITEM,
    '-1000' CL_CREDIT_TYPE,
    'ROLL' CL_CREATE_DURING,
    cdt.VALUE CL_COMMISSION_AMOUNT,
    CASE WHEN cdt.GENERICATTRIBUTE11 = 'Sales Incentive' THEN cdt.GENERICNUMBER1 END CL_COMMISSION_RATE,
    txn.CHANNEL CH_PREMISE_ID,
    par.USERID PAY_POINT_ID,
    CASE WHEN pip.PIPELINERUNSEQ IS NOT NULL THEN 'POSTED' ELSE 'NOT POSTED' END CL_POSTING_STATUS,
    'CALC' CL_STATUS,
    NULL CL_ERROR_REASON,
    '1000' CL_ROLE_ID,
    cdt.RULESEQ CL_REVENUE_CLASS,
    cdt.RULESEQ CL_QUOTA_ID,
    cdt.RULESEQ CL_QUOTA_RULE_ID,
    'NNNN' PRE_PROCESSED_CODE,
    'ROLL' CH_STATUS,
    txn.DATASOURCE CH_SOURCE_SYSTEM,
    'COMMISSIONABLE TRANSACTION' CH_SYSTEM_PROCESS,
    etx.GENERICNUMBER4 CH_LIST_PRICE,
    NULL CH_SALE_STAFF_ID,
    cdt.RULESEQ CH_REVENUE_CLASS_ID,
    CASE WHEN txn.DATASOURCE = 'MAXIMPRM' THEN txn.GENERICDATE1 ELSE txn.COMPENSATIONDATE END MOLI_PROVISIONED_DATE,
    'NEW' CH_CH_ADJUST_STATUS,
    etx.GENERICATTRIBUTE2 || ' ' || etx.GENERICATTRIBUTE3 CUSTOMER_NAME,
    etx.GENERICATTRIBUTE1 CH_BILLING_ACCOUNT,
    txn.GENERICATTRIBUTE22 CH_IMEI,
    txn.COMMENTS CH_COMMENT,
    cdt.GENERICATTRIBUTE12 CH_PRODUCT_CATEGORY,
    CASE WHEN txn.DATASOURCE = 'MAXIMPRM' THEN cdt.GENERICATTRIBUTE8 ELSE txn.GENERICATTRIBUTE30 END CH_PRODUCT_DESCRIPTION,
    CASE WHEN txn.DATASOURCE = 'MAXIMPRM' THEN cdt.GENERICATTRIBUTE7 ELSE txn.PRODUCTID END CH_COLI_PART_NUMBER,
    txn.GENERICATTRIBUTE27 CH_NETWORK,
    txn.GENERICATTRIBUTE6 CH_PRODUCT_FAMILY_CODE,
    txn.GENERICATTRIBUTE30 CH_PRODUCT_FAMILY_DESCRIPTION,
    txn.GENERICATTRIBUTE11 CH_PRODUCT_ATTRIBUTE_1,
    txn.GENERICATTRIBUTE12 CH_PRODUCT_ATTRIBUTE_2,
    txn.GENERICATTRIBUTE13 CH_PRODUCT_ATTRIBUTE_3,
    txn.GENERICATTRIBUTE14 CH_PRODUCT_ATTRIBUTE_4,
    NULL CH_PRODUCT_REVIEW_NAME,
    txn.GENERICNUMBER1 CH_SUBMISSION_COMPLETION,
    'NOT SET' CH_PRODUCT_COL_REVIEW_1,
    'NOT SET' CH_PRODUCT_COL_REVIEW_2,
    CASE WHEN cdt.GENERICATTRIBUTE11 = 'Sales Incentive' THEN cdt.GENERICNUMBER1 END CH_PLAN_MMC,
    NULL CH_PRODUCT_CODE_PREMIUM_PLAN,
    txn.GENERICNUMBER3 CH_PREV_PLAN_MMC,
    txn.GENERICNUMBER1 CH_SUBCOMPLETION,
    txn.GENERICBOOLEAN4 CH_HARDWARE_SUPPLIED,
    txn.GENERICATTRIBUTE7 CH_ACCESS_TYPE,
    txn.GENERICBOOLEAN1 CH_SHAPED,
    'NULL' CH_CAMPAIGN_NAME,
    txn.GENERICATTRIBUTE28 CH_SUBSCRIPTION_CATEGORY,
    'NULL' CH_CAMPAIGN_NUM,
    txn.GENERICATTRIBUTE1 CH_SALES_TYPE
FROM
  CS_CREDIT@TC_LINK cdt
  JOIN CS_SALESTRANSACTION@TC_LINK txn ON
    txn.SALESTRANSACTIONSEQ = cdt.SALESTRANSACTIONSEQ
    AND txn.TENANTID = cdt.TENANTID
    AND txn.PROCESSINGUNITSEQ = cdt.PROCESSINGUNITSEQ
  JOIN CS_GASALESTRANSACTION@TC_LINK etx ON
    etx.SALESTRANSACTIONSEQ = txn.SALESTRANSACTIONSEQ
    AND etx.TENANTID = txn.TENANTID
    AND etx.PAGENUMBER = 0
    AND etx.PROCESSINGUNITSEQ = txn.PROCESSINGUNITSEQ
  JOIN CS_SALESORDER@TC_LINK ord ON
    ord.SALESORDERSEQ = txn.SALESORDERSEQ
    AND ord.TENANTID = txn.TENANTID
    AND ord.PROCESSINGUNITSEQ = txn.PROCESSINGUNITSEQ
    AND ord.REMOVEDATE = TO_DATE('01012200','DDMMYYYY')
  JOIN CS_PERIOD@TC_LINK per ON
    per.PERIODSEQ = cdt.PERIODSEQ
    AND per.TENANTID = cdt.TENANTID
    AND per.REMOVEDATE = TO_DATE('01012200','DDMMYYYY')
  JOIN CS_PARTICIPANT@TC_LINK par ON
    ((par.effectiveStartDate < per.endDate and par.effectiveEndDate >= per.endDate) or (par.effectiveEndDate < per.endDate and par.isLast=1))
    AND par.REMOVEDATE = TO_DATE('01012200','DDMMYYYY')
    AND par.PAYEESEQ = cdt.PAYEESEQ
    AND par.TENANTID = cdt.TENANTID
  LEFT OUTER JOIN CS_PIPELINERUN@TC_LINK pip ON
    pip.PROCESSINGUNITSEQ = cdt.PROCESSINGUNITSEQ
    AND pip.PERIODSEQ = cdt.PERIODSEQ
    AND pip.TENANTID = cdt.TENANTID
    AND pip.COMMAND = 'PipelineRun'
    AND pip.STATUS = 'Successful'
    AND pip.DESCRIPTION LIKE('%stage=Post%')
WHERE
  cdt.TENANTID = 'TELS'
  AND per.NAME = 'JULW1-FY19'
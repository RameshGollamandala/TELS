--Partner
WITH RAWDATA AS(
SELECT 
    cls.NAME DEALER_NAME,
    TO_CHAR(cus.GENERICDATE1,'YYYY-MM-DD HH24:MI:SS') DEALER_START_DATE,
    CASE WHEN TO_CHAR(cus.GENERICDATE2,'YYYY-MM-DD') = '2200-01-01' THEN NULL ELSE TO_CHAR(cus.GENERICDATE2,'YYYY-MM-DD HH24:MI:SS') END DEALER_END_DATE,
    TO_CHAR(cus.GENERICATTRIBUTE7) PARTNER_CODE,
    posSD.GENERICATTRIBUTE3 PARTNER_TYPE,
    cus.GENERICATTRIBUTE6 SITE,
    cus.GENERICATTRIBUTE1 STRATEGIC_ROLE,
    cus.GENERICATTRIBUTE5 PRIORITY,
    pos.GENERICATTRIBUTE2 VENDOR_CODE,
    cus.GENERICATTRIBUTE2 DISTRIBUTOR,
    cus.GENERICATTRIBUTE3 SUPER_DISTRIBUTOR,
    TO_CHAR(posSD.EFFECTIVESTARTDATE,'YYYY-MM-DD HH24:MI:SS') GROUP_START_DATE,
    CASE WHEN TO_CHAR(pos.EFFECTIVEENDDATE,'YYYY-MM-DD') = '2200-01-01' THEN NULL ELSE TO_CHAR(pos.EFFECTIVEENDDATE,'YYYY-MM-DD HH24:MI:SS') END GROUP_END_DATE,
    TO_CHAR(posSD.EFFECTIVESTARTDATE,'YYYY-MM-DD HH24:MI:SS') RELATION_START_DATE,
    CASE WHEN TO_CHAR(pos.EFFECTIVEENDDATE,'YYYY-MM-DD') = '2200-01-01' THEN NULL ELSE TO_CHAR(pos.EFFECTIVEENDDATE,'YYYY-MM-DD HH24:MI:SS') END RELATION_END_DATE,
    pos.GENERICBOOLEAN1 AS PAYPOINT_FLAG,
    pos.GENERICBOOLEAN2 AS PREMISE_FLAG,
    pos.GENERICBOOLEAN3 AS DISTRIBUTOR_FLAG,
    pos.GENERICBOOLEAN4 AS SUPDISTRIBUTOR_FLAG,
    (SELECT TO_CHAR(MAX(EVENTDATE),'YYYY-MM-DD HH24:MI:SS') FROM CS_AUDITLOG WHERE OBJECTSEQ IN(pos.RULEELEMENTOWNERSEQ,cus.CLASSIFIERSEQ)) LAST_UPDATED_DATE
FROM CS_PERIOD@TC_LINK per 
  JOIN CS_CALENDAR@TC_LINK cal ON
    cal.CALENDARSEQ = per.CALENDARSEQ 
    and cal.removedate = TO_DATE('01-01-2200','DD-MM-YYYY')
    and cal.NAME = 'Main Monthly Calendar'
    and cal.TENANTID = per.TENANTID
  JOIN CS_PERIODTYPE@TC_LINK prt ON
    prt.PERIODTYPESEQ = per.PERIODTYPESEQ
    and prt.removedate = TO_DATE('01-01-2200','DD-MM-YYYY')
    and prt.NAME = 'month'
    and prt.TENANTID = per.TENANTID
  JOIN cs_CategoryTree@tc_link ctr ON 
    ctr.removedate = TO_DATE('01-01-2200','DD-MM-YYYY')
    and ctr.TENANTID = prt.TENANTID
    and ctr.NAME = 'Premise'
  JOIN cs_Category_Classifiers@tc_link ccl ON
    ((ccl.effectiveStartDate < per.endDate and ccl.effectiveEndDate >= per.endDate) or (ccl.effectiveEndDate < per.endDate and ccl.isLast=1))
    and ccl.removedate = TO_DATE('01-01-2200','DD-MM-YYYY')
    and ccl.categoryTreeSeq = ctr.categoryTreeSeq
    and ccl.TENANTID = ctr.TENANTID
  JOIN cs_classifier@tc_link cls ON
    ((cls.effectiveStartDate < per.endDate and cls.effectiveEndDate >= per.endDate) or (cls.effectiveEndDate < per.endDate and cls.isLast=1))
    and cls.removedate = TO_DATE('01-01-2200','DD-MM-YYYY')
    and cls.classifierseq = ccl.classifierseq
    and cls.TENANTID = ccl.TENANTID
  JOIN CS_CUSTOMER@TC_LINK cus ON
    ((cus.effectiveStartDate < per.endDate and cus.effectiveEndDate >= per.endDate) or (cus.effectiveEndDate < per.endDate and cus.isLast=1))
    and cus.removedate = TO_DATE('01-01-2200','DD-MM-YYYY')
    and cus.classifierseq = cls.classifierseq
    and cus.TENANTID = cls.TENANTID
  LEFT OUTER JOIN CS_POSITION@TC_LINK pos ON
    ((pos.effectiveStartDate < per.endDate and pos.effectiveEndDate >= per.endDate) or (pos.effectiveEndDate < per.endDate and pos.isLast=1))
    and pos.removedate = TO_DATE('01-01-2200','DD-MM-YYYY')
    and pos.tenantid = per.tenantid
--    and pos.NAME = TO_CHAR(cls.CLASSIFIERID)
    and pos.NAME = TO_CHAR(cus.GENERICATTRIBUTE7)
  LEFT OUTER JOIN CS_POSITION@TC_LINK posSD ON
    ((posSD.effectiveStartDate < per.endDate and posSD.effectiveEndDate >= per.endDate) or (posSD.effectiveEndDate < per.endDate and posSD.isLast=1))
    and posSD.removedate = TO_DATE('01-01-2200','DD-MM-YYYY')
    and posSD.tenantid = per.tenantid
    and posSD.NAME = TO_CHAR(cus.GENERICATTRIBUTE3)
WHERE 
  per.STARTDATE < sysdate
  and per.enddate >= sysdate
  and per.removedate = TO_DATE('01-01-2200','DD-MM-YYYY')
  and per.tenantid = 'TELS'
ORDER BY
  cus.GENERICATTRIBUTE3,
  TO_CHAR(cls.CLASSIFIERID)
) 
, PREMISEPARTNER AS(
    SELECT DEALER_NAME, DEALER_START_DATE, DEALER_END_DATE, PARTNER_CODE, PARTNER_TYPE||' - Premise' PARTNER_TYPE, SITE, 
    STRATEGIC_ROLE, PRIORITY, 
    CASE WHEN PAYPOINT_FLAG = 1 AND SUPDISTRIBUTOR_FLAG = 0 AND DISTRIBUTOR_FLAG = 0 AND PREMISE_FLAG = 1 THEN VENDOR_CODE ELSE NULL END VENDOR_CODE, 
    DISTRIBUTOR, SUPER_DISTRIBUTOR, PARTNER_CODE||'_PR' PARTNER_CODE_LEVEL, 
    PARTNER_CODE||'_DI_CGROUP' GROUP_NAME, GROUP_START_DATE, GROUP_END_DATE, PARTNER_CODE||'_SD_PGROUP' PARENT_GROUP, 
    RELATION_START_DATE, RELATION_END_DATE, 1 SORTORDER, LAST_UPDATED_DATE,
    '' ROLE_TYPE, PARTNER_TYPE||' - Premise' ROLE1, DEALER_START_DATE ROLE1_START_DATE, DEALER_END_DATE ROLE1_END_DATE, 
    CASE WHEN PAYPOINT_FLAG = 1 THEN PARTNER_TYPE||' - Pay Point' END ROLE2, CASE WHEN PAYPOINT_FLAG = 1 THEN DEALER_START_DATE END ROLE2_START_DATE, CASE WHEN PAYPOINT_FLAG = 1 THEN DEALER_END_DATE END ROLE2_END_DATE
    FROM RAWDATA 
)
, DISTRIBUTOR AS(
    SELECT DEALER_NAME, DEALER_START_DATE, DEALER_END_DATE, PARTNER_CODE, PARTNER_TYPE||' - Distributor' PARTNER_TYPE, n'DISTRIBUTOR' SITE, 
    STRATEGIC_ROLE, PRIORITY, 
    CASE WHEN PAYPOINT_FLAG = 1 AND SUPDISTRIBUTOR_FLAG = 0 AND DISTRIBUTOR_FLAG = 1 THEN VENDOR_CODE ELSE NULL END VENDOR_CODE, 
    DISTRIBUTOR, SUPER_DISTRIBUTOR, PARTNER_CODE||'_DI' PARTNER_CODE_LEVEL, 
    PARTNER_CODE||'_DI_CGROUP' GROUP_NAME, GROUP_START_DATE, GROUP_END_DATE, PARTNER_CODE||'_SD_PGROUP' PARENT_GROUP,  
    RELATION_START_DATE, RELATION_END_DATE, 2 SORTORDER, LAST_UPDATED_DATE,
    '' ROLE_TYPE, PARTNER_TYPE||' - Distributor' ROLE1, DEALER_START_DATE ROLE1_START_DATE, DEALER_END_DATE ROLE1_END_DATE,
    CASE WHEN PAYPOINT_FLAG = 1 THEN PARTNER_TYPE||' - Pay Point' END ROLE2, CASE WHEN PAYPOINT_FLAG = 1 THEN DEALER_START_DATE END ROLE2_START_DATE, CASE WHEN PAYPOINT_FLAG = 1 THEN DEALER_END_DATE END ROLE2_END_DATE
    FROM RAWDATA 
    WHERE DISTRIBUTOR_FLAG IS NOT NULL
)
, SUPDISTRIBUTOR AS(
    SELECT DEALER_NAME, DEALER_START_DATE, DEALER_END_DATE, PARTNER_CODE, PARTNER_TYPE||' - Super Distributor' PARTNER_TYPE, n'SUPER DISTRIBUTOR' SITE, 
    STRATEGIC_ROLE, PRIORITY, 
    CASE WHEN PAYPOINT_FLAG = 1 AND SUPDISTRIBUTOR_FLAG = 1 THEN VENDOR_CODE ELSE NULL END VENDOR_CODE, 
    DISTRIBUTOR, SUPER_DISTRIBUTOR, PARTNER_CODE||'_SD' PARTNER_CODE_LEVEL, 
    PARTNER_CODE||'_SD_PGROUP' GROUP_NAME, GROUP_START_DATE, GROUP_END_DATE, NULL PARENT_GROUP,  
    RELATION_START_DATE, RELATION_END_DATE, 3 SORTORDER, LAST_UPDATED_DATE,
    '' ROLE_TYPE, PARTNER_TYPE||' - Super Distributor' ROLE1, DEALER_START_DATE ROLE1_START_DATE, DEALER_END_DATE ROLE1_END_DATE,
    CASE WHEN PAYPOINT_FLAG = 1 THEN PARTNER_TYPE||' - Pay Point' END ROLE2, CASE WHEN PAYPOINT_FLAG = 1 THEN DEALER_START_DATE END ROLE2_START_DATE, CASE WHEN PAYPOINT_FLAG = 1 THEN DEALER_END_DATE END ROLE2_END_DATE
    FROM RAWDATA 
    WHERE SUPDISTRIBUTOR_FLAG IS NOT NULL)
, ALL_LEVELS AS(
    SELECT * FROM PREMISEPARTNER
    UNION ALL 
    SELECT * FROM DISTRIBUTOR
    UNION ALL 
    SELECT * FROM SUPDISTRIBUTOR
) SELECT '' RESOURCE_ID, DEALER_NAME, DEALER_START_DATE, DEALER_END_DATE, '' PARTNER_ID, ALL_LEVELS.PARTNER_CODE, PARTNER_TYPE, '' PARTNER_TERRITORY, SITE, STRATEGIC_ROLE, 
  PRIORITY, VENDOR_CODE, SUPER_DISTRIBUTOR, PARTNER_CODE_LEVEL, GROUP_NAME, GROUP_START_DATE, GROUP_END_DATE, PARENT_GROUP, RELATION_START_DATE, RELATION_END_DATE, LAST_UPDATED_DATE,
  'Sales Compensation' ROLE_TYPE, ROLE1, ROLE1_START_DATE, ROLE1_END_DATE, ROLE2, ROLE2_START_DATE, ROLE2_END_DATE, 'Direct Payment' ROLE3, DEALER_START_DATE ROLE3_START_DATE, DEALER_END_DATE ROLE3_END_DATE,
  roles.ROLE4, roles.ROLE4_START_DATE, roles.ROLE4_END_DATE, roles.ROLE5, roles.ROLE5_START_DATE, roles.ROLE5_END_DATE, roles.ROLE6, roles.ROLE6_START_DATE, roles.ROLE6_END_DATE, 
  roles.ROLE7, roles.ROLE7_START_DATE, roles.ROLE7_END_DATE, roles.ROLE8, roles.ROLE8_START_DATE, roles.ROLE8_END_DATE, roles.ROLE9, roles.ROLE9_START_DATE, roles.ROLE9_END_DATE, 
  roles.ROLE10, roles.ROLE10_START_DATE, roles.ROLE10_END_DATE, NULL ROLE11, NULL ROLE11_START_DATE, NULL ROLE11_END_DATE, NULL ROLE12, NULL ROLE12_START_DATE, NULL ROLE12_END_DATE, 
  NULL ROLE13, NULL ROLE13_START_DATE, NULL ROLE13_END_DATE, NULL ROLE14, NULL ROLE14_START_DATE, NULL ROLE14_END_DATE, NULL ROLE15, NULL ROLE15_START_DATE, NULL ROLE15_END_DATE, 
  NULL ROLE16, NULL ROLE16_START_DATE, NULL ROLE16_END_DATE, NULL ROLE17, NULL ROLE17_START_DATE, NULL ROLE17_END_DATE, NULL ROLE18, NULL ROLE18_START_DATE, NULL ROLE18_END_DATE, 
  NULL ROLE19, NULL ROLE19_START_DATE, NULL ROLE19_END_DATE, NULL ROLE20, NULL ROLE20_START_DATE, NULL ROLE20_END_DATE
  FROM ALL_LEVELS 
    LEFT OUTER JOIN
      (SELECT 
          mdlt.IDX_NAME_0 PARTNER_CODE, 
          Max(CASE WHEN mdlt.IDX_NAME_1 = 'NCS' THEN 'NCS' END) ROLE4, Max(CASE WHEN mdlt.IDX_NAME_1 = 'NCS' THEN mdlt.STARTDATE END) ROLE4_START_DATE, Max(CASE WHEN mdlt.IDX_NAME_1 = 'NCS' THEN mdlt.ENDDATE END) ROLE4_END_DATE, 
          Max(CASE WHEN mdlt.IDX_NAME_1 = 'PTV' THEN 'Pay TV' END) ROLE5, Max(CASE WHEN mdlt.IDX_NAME_1 = 'PTV' THEN mdlt.STARTDATE END) ROLE5_START_DATE, Max(CASE WHEN mdlt.IDX_NAME_1 = 'PTV' THEN mdlt.ENDDATE END) ROLE5_END_DATE, 
          Max(CASE WHEN mdlt.IDX_NAME_1 = 'BBF' THEN 'Broadband Fixed' END) ROLE6, Max(CASE WHEN mdlt.IDX_NAME_1 = 'BBF' THEN mdlt.STARTDATE END) ROLE6_START_DATE, Max(CASE WHEN mdlt.IDX_NAME_1 = 'BBF' THEN mdlt.ENDDATE END) ROLE6_END_DATE, 
          Max(CASE WHEN mdlt.IDX_NAME_1 = 'CXD' THEN 'Complex Data' END) ROLE7, Max(CASE WHEN mdlt.IDX_NAME_1 = 'CXD' THEN mdlt.STARTDATE END) ROLE7_START_DATE, Max(CASE WHEN mdlt.IDX_NAME_1 = 'CXD' THEN mdlt.ENDDATE END) ROLE7_END_DATE, 
          Max(CASE WHEN mdlt.IDX_NAME_1 = 'PPM' THEN 'Post Paid Mobile' END) ROLE8, Max(CASE WHEN mdlt.IDX_NAME_1 = 'PPM' THEN mdlt.STARTDATE END) ROLE8_START_DATE, Max(CASE WHEN mdlt.IDX_NAME_1 = 'PPM' THEN mdlt.ENDDATE END) ROLE8_END_DATE, 
          Max(CASE WHEN mdlt.IDX_NAME_1 = 'FXL' THEN 'Fixed Line' END) ROLE9, Max(CASE WHEN mdlt.IDX_NAME_1 = 'FXL' THEN mdlt.STARTDATE END) ROLE9_START_DATE, Max(CASE WHEN mdlt.IDX_NAME_1 = 'FXL' THEN mdlt.ENDDATE END) ROLE9_END_DATE, 
          Max(CASE WHEN mdlt.IDX_NAME_1 = 'DARO' THEN 'DARO' END) ROLE10, Max(CASE WHEN mdlt.IDX_NAME_1 = 'DARO' THEN mdlt.STARTDATE END) ROLE10_START_DATE, Max(CASE WHEN mdlt.IDX_NAME_1 = 'DARO' THEN mdlt.ENDDATE END) ROLE10_END_DATE
        FROM TELS_MDLT_VIEW mdlt
        WHERE mdlt.NAME = 'LT_Paypoint_Eligibility'
          AND mdlt.ENDDATE = TO_DATE('01012200','DDMMYYYY')
        GROUP BY
          mdlt.IDX_NAME_0) roles ON
     roles.PARTNER_CODE = ALL_LEVELS.PARTNER_CODE 
  ORDER BY SUPER_DISTRIBUTOR, SORTORDER
;
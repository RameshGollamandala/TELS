--DTF
SELECT 
    TO_CHAR(cus.GENERICATTRIBUTE7) PARTICIPANT_ID,
--    pos.GENERICATTRIBUTE1 LEGACY_PARTNER_CODE,
    cus2.GENERICATTRIBUTE5 FIXED_MANUAL_PAYMENT_CODE,
    cls.NAME PARTICIPANT_NAME,
--    pos.GENERICATTRIBUTE4 PARTICIPANT_SITE
    cus.GENERICATTRIBUTE6 PARTICIPANT_SITE,
    cus.GENERICATTRIBUTE5 LEGACY_PARTNER_CODE
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
  JOIN CS_CUSTOMER@TC_LINK cus2 ON
    ((cus2.effectiveStartDate < per.endDate and cus2.effectiveEndDate >= per.endDate) or (cus2.effectiveEndDate < per.endDate and cus2.isLast=1))
    and cus2.removedate = TO_DATE('01-01-2200','DD-MM-YYYY')
    and cus.GENERICATTRIBUTE7 = cus2.GENERICATTRIBUTE4
    and cus2.TENANTID = cls.TENANTID
WHERE 
  per.STARTDATE < sysdate
  and per.enddate >= sysdate
  and per.removedate = TO_DATE('01-01-2200','DD-MM-YYYY')
  and per.tenantid = 'TELS'
ORDER BY
  cls.NAME
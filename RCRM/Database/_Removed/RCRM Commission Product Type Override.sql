    SELECT cls.NAME PRODUCTID, prd.GENERICATTRIBUTE1 COMMISSION_PRODUCT_TYPE, prd.GENERICDATE1 EFFECTIVESTARTDATE, prd.GENERICDATE2 EFFECTIVEENDDATE
    FROM cs_CategoryTree@tc_link ctr 
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
        and ctr.NAME = 'Product_Type_Override'
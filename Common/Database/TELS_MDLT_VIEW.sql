Drop VIEW TELS_MDLT_VIEW;
CREATE VIEW TELS_MDLT_VIEW AS
    With Index_List as(
        select
            t2.ruleelementseq,
            t2.dimensionslot as Dimension_Number,
            t2.name as Dimension_Name,
            t3.ordinal as Index_Number,
            Case when t3.minstring is null then to_char(t3.minvalue) else t3.minstring End as Index_Name,
            t3.effectivestartdate as Index_Start_Date,
            t3.effectiveenddate as Index_End_Date
        from CS_MDLTDimension@TC_LINK t2
        join CS_MDLTIndex@TC_LINK t3 on
            t3.ruleelementseq = t2.ruleelementseq
            and t3.DimensionSeq = t2.DimensionSeq
            and t3.removedate = TO_DATE('01012200','DDMMYYYY')
            and t2.removedate = TO_DATE('01012200','DDMMYYYY')
            and t3.effectivestartdate < t2.effectiveenddate
            and t3.effectiveenddate > t2.effectivestartdate
    )
    select
        tbl.name,
        cell.effectivestartdate as StartDate,
        cell.effectiveenddate as EndDate,
        t0.Dimension_Name as Dim_Name_0,
        t0.Index_Name as Idx_Name_0,
        t1.Dimension_Name as Dim_Name_1,
        t1.Index_Name as Idx_Name_1,
        t2.Dimension_Name as Dim_Name_2,
        t2.Index_Name as Idx_Name_2, 
        t3.Dimension_Name as Dim_Name_3,
        t3.Index_Name as Idx_Name_3,
        t4.Dimension_Name as Dim_Name_4,
        t4.Index_Name as Idx_Name_4,
        t5.Dimension_Name as Dim_Name_5,
        t5.Index_Name as Idx_Name_5, 
        t6.Dimension_Name as Dim_Name_6,
        t6.Index_Name as Idx_Name_6, 
        cell.value,
        cell.stringvalue,
        cell.datevalue
    from
    CS_RelationalMDLT@TC_LINK tbl
    join CS_MDLTCell@TC_LINK cell on
        cell.mdltseq = tbl.ruleelementseq
        and cell.removedate = TO_DATE('01012200','DDMMYYYY')
--        and tbl.name = 'LT_Payment_Date'
        and tbl.islast = 1 
        and tbl.removedate = TO_DATE('01012200','DDMMYYYY')
        and cell.effectivestartdate < tbl.effectiveenddate
        and cell.effectiveenddate > tbl.effectivestartdate
    join Index_List t0 on
        t0.Dimension_Number = 0
        and t0.ruleelementseq = tbl.ruleelementseq
        and t0.Index_Number = cell.dim0index
        and t0.Index_Start_Date < cell.effectiveenddate
        and t0.Index_End_Date > cell.effectivestartdate
    left join Index_List t1 on
        t1.Dimension_Number = 1
        and t1.ruleelementseq = tbl.ruleelementseq
        and t1.Index_Number = cell.dim1index
        and t1.Index_Start_Date < cell.effectiveenddate
        and t1.Index_End_Date > cell.effectivestartdate
    left join Index_List t2 on
        t2.Dimension_Number = 2
        and t2.ruleelementseq = tbl.ruleelementseq
        and t2.Index_Number = cell.dim2index
        and t2.Index_Start_Date < cell.effectiveenddate
        and t2.Index_End_Date > cell.effectivestartdate
    left join Index_List t3 on
        t3.Dimension_Number = 3
        and t3.ruleelementseq = tbl.ruleelementseq
        and t3.Index_Number = cell.dim3index
        and t3.Index_Start_Date < cell.effectiveenddate
        and t3.Index_End_Date > cell.effectivestartdate
    left join Index_List t4 on
        t4.Dimension_Number = 4
        and t4.ruleelementseq = tbl.ruleelementseq
        and t4.Index_Number = cell.dim4index
        and t4.Index_Start_Date < cell.effectiveenddate
        and t4.Index_End_Date > cell.effectivestartdate
    left join Index_List t5 on
        t5.Dimension_Number = 5
        and t5.ruleelementseq = tbl.ruleelementseq
        and t5.Index_Number = cell.dim5index
        and t5.Index_Start_Date < cell.effectiveenddate
        and t5.Index_End_Date > cell.effectivestartdate
    left join Index_List t6 on
        t6.Dimension_Number = 6
        and t6.ruleelementseq = tbl.ruleelementseq
        and t6.Index_Number = cell.dim6index
        and t6.Index_Start_Date < cell.effectiveenddate
        and t6.Index_End_Date > cell.effectivestartdate;
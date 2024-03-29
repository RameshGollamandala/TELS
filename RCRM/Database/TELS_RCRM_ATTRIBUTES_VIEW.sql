CREATE OR REPLACE FORCE VIEW TELS_RCRM_ATTRIBUTES_VIEW (
    FILENAME,
    BATCHPROCESSDATE,
    RECORDNUMBER,
    IS_FILTERED,
    ORDER_NUMBER,
    ORDER_SUB_TYPE,
    STATUS_HEADER,
    ROW_ID,
    ATTRIBUTE_ROW_ID,
    ATTRIBUTE_ACTION_CODE,
    ATTRIBUTE_DISPLAY_NAME,
    ATTRIBUTE_VALUE
) AS
    SELECT
        d.FILENAME,
        d.BATCHPROCESSDATE,
        d.RECORDNUMBER,
        d.IS_FILTERED,
        d.ORDER_NUMBER,
        d.ORDER_SUB_TYPE,
        d.STATUS_HEADER,
        d.ROW_ID,
        d.ATTRIBUTE_ROW_ID,
        d.ATTRIBUTE_ACTION_CODE,
        d.ATTRIBUTE_DISPLAY_NAME,
        d.ATTRIBUTE_VALUE
    FROM
        TELS_RCRM_MV_ATTRIBUTE d
--    WHERE NOT EXISTS(SELECT 1 FROM TELS_RCRM_HOLD_ATTRIBUTES h WHERE h.ROW_ID = d.ROW_ID) --Uncomment this line to prevent hold records from flowing forward
  UNION ALL
      SELECT
        d.FILENAME,
        d.BATCHPROCESSDATE,
        d.RECORDNUMBER,
        d.IS_FILTERED,
        d.ORDER_NUMBER,
        d.ORDER_SUB_TYPE,
        d.STATUS_HEADER,
        d.ROW_ID,
        d.ATTRIBUTE_ROW_ID,
        d.ATTRIBUTE_ACTION_CODE,
        d.ATTRIBUTE_DISPLAY_NAME,
        d.ATTRIBUTE_VALUE
    FROM
        TELS_RCRM_RELEASE_ATTRIBUTES d
;
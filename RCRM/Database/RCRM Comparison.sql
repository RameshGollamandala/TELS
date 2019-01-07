--1
DROP TABLE test_oic_preproc;

--2

CREATE TABLE test_oic_preproc
    AS
        SELECT
            filename o_filename,
            processed_date o_processed_date,
            transaction_amount o_transaction_amount,
            quantity o_quantity,
            attribute1 o_attribute1,
            attribute2 o_attribute2,
            attribute16 o_attribute16,
            attribute17 o_attribute17,
            attribute18 o_attribute18,
            attribute19 o_attribute19,
            attribute20 o_attribute20,
            attribute21 o_attribute21,
            attribute22 o_attribute22,
            attribute23 o_attribute23,
            attribute24 o_attribute24,
            attribute25 o_attribute25,
            attribute26 o_attribute26,
            attribute27 o_attribute27,
            attribute28 o_attribute28,
            attribute29 o_attribute29,
            attribute30 o_attribute30,
            attribute31 o_attribute31,
            attribute32 o_attribute32,
            attribute33 o_attribute33,
            attribute34 o_attribute34,
            attribute35 o_attribute35,
            attribute36 o_attribute36,
            attribute37 o_attribute37,
            attribute38 o_attribute38,
            attribute39 o_attribute39,
            attribute41 o_attribute41,
            attribute42 o_attribute42,
            attribute43 o_attribute43,
            attribute44 o_attribute44,
            attribute45 o_attribute45,
            attribute46 o_attribute46,
            attribute47 o_attribute47,
            attribute49 o_attribute49,
            attribute50 o_attribute50,
            attribute53 o_attribute53,
            attribute54 o_attribute54,
            attribute55 o_attribute55,
            attribute56 o_attribute56,
            attribute57 o_attribute57,
            attribute58 o_attribute58,
            attribute59 o_attribute59,
            attribute60 o_attribute60,
            attribute61 o_attribute61,
            attribute62 o_attribute62,
            attribute63 o_attribute63,
            attribute64 o_attribute64,
            attribute65 o_attribute65,
            attribute67 o_attribute67,
            attribute69 o_attribute69,
            attribute72 o_attribute72,
            attribute78 o_attribute78,
            attribute79 o_attribute79,
            attribute81 o_attribute81,
            attribute82 o_attribute82,
            attribute84 o_attribute84,
            attribute88 o_attribute88,
            attribute89 o_attribute89,
            attribute90 o_attribute90,
            attribute91 o_attribute91,
            attribute92 o_attribute92,
            attribute94 o_attribute94,
            attribute100 o_attribute100,
            booked_date o_booked_date,
            revenue_type o_revenue_type,
            record_status o_record_status,
            error_type o_error_type,
            error_msg o_error_msg,
            source o_source,
            submitted_date o_submitted_date,
            status_header o_status_header,
            status_order_line_item o_status_order_line_item
        FROM
            tels_stage_rcrm_ppe
        WHERE
                EXISTS (
                    SELECT
                        row_id
                    FROM
                        tels_prestage_rcrm
                    WHERE
--                            filename = 'CCB-RCRM_OrderDataExtract_20181122_053324.dat'
                            filename = 'CCB-RCRM_OrderDataExtract_20181208_053730.dat'
                        AND
                            row_id = tels_stage_rcrm_ppe.attribute46
                        AND
                            order_type = tels_stage_rcrm_ppe.attribute60
                        AND
                            status_header = 'Complete'
                )
            AND
                filename LIKE '%PREPROCCOMMISSIONS%'
            AND
                source = 'SIEBEL';
        
--3

DROP TABLE test_callidus_preproc;

--4

CREATE TABLE test_callidus_preproc
    AS
        SELECT
            filename c_filename,
            processed_date c_processed_date,
            transaction_amount c_transaction_amount,
            quantity c_quantity,
            attribute1 c_attribute1,
            attribute2 c_attribute2,
            attribute16 c_attribute16,
            attribute17 c_attribute17,
            attribute18 c_attribute18,
            attribute19 c_attribute19,
            attribute20 c_attribute20,
            attribute21 c_attribute21,
            attribute22 c_attribute22,
            attribute23 c_attribute23,
            attribute24 c_attribute24,
            attribute25 c_attribute25,
            attribute26 c_attribute26,
            attribute27 c_attribute27,
            attribute28 c_attribute28,
            attribute29 c_attribute29,
            attribute30 c_attribute30,
            attribute31 c_attribute31,
            attribute32 c_attribute32,
            attribute33 c_attribute33,
            attribute34 c_attribute34,
            attribute35 c_attribute35,
            attribute36 c_attribute36,
            attribute37 c_attribute37,
            attribute38 c_attribute38,
            attribute39 c_attribute39,
            attribute41 c_attribute41,
            attribute42 c_attribute42,
            attribute43 c_attribute43,
            attribute44 c_attribute44,
            attribute45 c_attribute45,
            attribute46 c_attribute46,
            attribute47 c_attribute47,
            attribute49 c_attribute49,
            attribute50 c_attribute50,
            attribute53 c_attribute53,
            attribute54 c_attribute54,
            attribute55 c_attribute55,
            attribute56 c_attribute56,
            attribute57 c_attribute57,
            attribute58 c_attribute58,
            attribute59 c_attribute59,
            attribute60 c_attribute60,
            attribute61 c_attribute61,
            attribute62 c_attribute62,
            attribute63 c_attribute63,
            attribute64 c_attribute64,
            attribute65 c_attribute65,
            attribute67 c_attribute67,
            attribute69 c_attribute69,
            attribute72 c_attribute72,
            attribute78 c_attribute78,
            attribute79 c_attribute79,
            attribute81 c_attribute81,
            attribute82 c_attribute82,
            attribute84 c_attribute84,
            attribute88 c_attribute88,
            attribute89 c_attribute89,
            attribute90 c_attribute90,
            attribute91 c_attribute91,
            attribute92 c_attribute92,
            attribute94 c_attribute94,
            attribute100 c_attribute100,
            booked_date c_booked_date,
            revenue_type c_revenue_type,
            record_status c_record_status,
            error_type c_error_type,
            error_msg c_error_msg,
            source c_source,
            submitted_date c_submitted_date,
            status_header c_status_header,
            status_order_line_item c_status_order_line_item
        FROM
            tels_stage_rcrm_ppe
        WHERE
--                filename = 'CCB-RCRM_OrderDataExtract_20181122_053324.dat'
                filename = 'CCB-RCRM_OrderDataExtract_20181208_053730.dat'
            AND
                status_header = 'Complete';

--5            

DROP TABLE test_preproc_comparison;

--6

CREATE TABLE test_preproc_comparison
    AS
        SELECT
            a.*,
            a.compare_processed_date + a.compare_transaction_amount + a.compare_quantity + a.compare_attribute1 + a.compare_attribute2 + a.compare_attribute21
+ a.compare_attribute22 + a.compare_attribute23 + a.compare_attribute25 + a.compare_attribute26 + a.compare_attribute27 + a.compare_attribute28
+ a.compare_attribute29 + a.compare_attribute30 + a.compare_attribute31 + a.compare_attribute33 + a.compare_attribute34 + a.compare_attribute35
+ a.compare_attribute36 + a.compare_attribute38 + a.compare_attribute39 + a.compare_attribute41 + a.compare_attribute42 + a.compare_attribute43
+ a.compare_attribute44 + a.compare_attribute45 + a.compare_attribute46 + a.compare_attribute47 + a.compare_attribute49 + a.compare_attribute50
+ a.compare_attribute53 + a.compare_attribute54 + a.compare_attribute55 + a.compare_attribute56 + a.compare_attribute57 + a.compare_attribute58
+ a.compare_attribute59 + a.compare_attribute60 + a.compare_attribute61 + a.compare_attribute62 + a.compare_attribute63 + a.compare_attribute64
+ a.compare_attribute65 + a.compare_attribute67 + a.compare_attribute69 + a.compare_attribute72 + a.compare_attribute78 + a.compare_attribute79
+ a.compare_attribute81 + a.compare_attribute82 + a.compare_attribute84 + a.compare_attribute88 + a.compare_attribute89 + a.compare_attribute90
+ a.compare_attribute91 + a.compare_attribute92 + a.compare_attribute94 + a.compare_attribute100 + a.compare_booked_date + a.compare_revenue_type
+ a.compare_record_status num_match
        FROM
            (
                SELECT
                    o.o_filename,
                    c.c_filename,
                    o.o_processed_date,
                    c.c_processed_date,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_processed_date,'NULL') = nvl(c.c_processed_date,'NULL')  THEN 1
                                WHEN nvl(o.o_processed_date,'NULL') <> nvl(c.c_processed_date,'NULL') THEN 0
                            END
                        )
                    ) compare_processed_date,
                    o.o_transaction_amount,
                    c.c_transaction_amount,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_transaction_amount,'NULL') = nvl(c.c_transaction_amount,'NULL')  THEN 1
                                WHEN nvl(o.o_transaction_amount,'NULL') <> nvl(c.c_transaction_amount,'NULL') THEN 0
                            END
                        )
                    ) compare_transaction_amount,
                    o.o_quantity,
                    c.c_quantity,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_quantity,'NULL') = nvl(c.c_quantity,'NULL')  THEN 1
                                WHEN nvl(o.o_quantity,'NULL') <> nvl(c.c_quantity,'NULL') THEN 0
                            END
                        )
                    ) compare_quantity,
                    o.o_attribute1,
                    c.c_attribute1,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(
                                    replace(
                                        o.o_attribute1,
                                        '#',
                                        ''
                                    ),
                                    'NULL'
                                ) = nvl(
                                    replace(
                                        c.c_attribute1,
                                        '#',
                                        ''
                                    ),
                                    'NULL'
                                ) THEN 1
                                WHEN nvl(
                                    replace(
                                        o.o_attribute1,
                                        '#',
                                        ''
                                    ),
                                    'NULL'
                                ) <> nvl(
                                    replace(
                                        c.c_attribute1,
                                        '#',
                                        ''
                                    ),
                                    'NULL'
                                ) THEN 0
                            END
                        )
                    ) compare_attribute1,
                    o.o_attribute2,
                    c.c_attribute2,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute2,'NULL') = nvl(c.c_attribute2,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute2,'NULL') <> nvl(c.c_attribute2,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute2,
                    o.o_attribute16,
                    c.c_attribute16,
                    o.o_attribute17,
                    c.c_attribute17,
                    o.o_attribute18,
                    c.c_attribute18,
                    o.o_attribute19,
                    c.c_attribute19,
                    o.o_attribute20,
                    c.c_attribute20,
                    o.o_attribute21,
                    c.c_attribute21,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute21,'NULL') = nvl(c.c_attribute21,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute21,'NULL') <> nvl(c.c_attribute21,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute21,
                    o.o_attribute22,
                    c.c_attribute22,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute22,'NULL') = nvl(c.c_attribute22,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute22,'NULL') <> nvl(c.c_attribute22,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute22,
                    o.o_attribute23,
                    c.c_attribute23,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute23,'NULL') = nvl(c.c_attribute23,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute23,'NULL') <> nvl(c.c_attribute23,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute23,
                    o.o_attribute24,
                    c.c_attribute24,
                    o.o_attribute25,
                    c.c_attribute25,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute25,'NULL') = nvl(c.c_attribute25,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute25,'NULL') <> nvl(c.c_attribute25,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute25,
                    o.o_attribute26,
                    c.c_attribute26,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute26,'NULL') = nvl(c.c_attribute26,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute26,'NULL') <> nvl(c.c_attribute26,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute26,
                    o.o_attribute27,
                    c.c_attribute27,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute27,'NULL') = nvl(c.c_attribute27,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute27,'NULL') <> nvl(c.c_attribute27,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute27,
                    o.o_attribute28,
                    c.c_attribute28,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute28,'NULL') = nvl(c.c_attribute28,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute28,'NULL') <> nvl(c.c_attribute28,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute28,
                    o.o_attribute29,
                    c.c_attribute29,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute29,'NULL') = nvl(c.c_attribute29,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute29,'NULL') <> nvl(c.c_attribute29,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute29,
                    o.o_attribute30,
                    c.c_attribute30,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute30,'NULL') = nvl(c.c_attribute30,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute30,'NULL') <> nvl(c.c_attribute30,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute30,
                    o.o_attribute31,
                    c.c_attribute31,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute31,'NULL') = nvl(c.c_attribute31,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute31,'NULL') <> nvl(c.c_attribute31,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute31,
                    o.o_attribute32,
                    c.c_attribute32,
                    o.o_attribute33,
                    c.c_attribute33,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute33,'NULL') = nvl(c.c_attribute33,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute33,'NULL') <> nvl(c.c_attribute33,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute33,
                    o.o_attribute34,
                    c.c_attribute34,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute34,'NULL') = nvl(c.c_attribute34,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute34,'NULL') <> nvl(c.c_attribute34,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute34,
                    o.o_attribute35,
                    c.c_attribute35,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute35,'NULL') = nvl(c.c_attribute35,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute35,'NULL') <> nvl(c.c_attribute35,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute35,
                    o.o_attribute36,
                    c.c_attribute36,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute36,'NULL') = nvl(c.c_attribute36,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute36,'NULL') <> nvl(c.c_attribute36,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute36,
                    o.o_attribute37,
                    c.c_attribute37,
                    o.o_attribute38,
                    c.c_attribute38,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute38,'NULL') = nvl(c.c_attribute38,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute38,'NULL') <> nvl(c.c_attribute38,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute38,
                    o.o_attribute39,
                    c.c_attribute39,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute39,'NULL') = nvl(c.c_attribute39,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute39,'NULL') <> nvl(c.c_attribute39,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute39,
                    o.o_attribute41,
                    c.c_attribute41,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute41,'NULL') = nvl(c.c_attribute41,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute41,'NULL') <> nvl(c.c_attribute41,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute41,
                    o.o_attribute42,
                    c.c_attribute42,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute42,'NULL') = nvl(c.c_attribute42,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute42,'NULL') <> nvl(c.c_attribute42,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute42,
                    o.o_attribute43,
                    c.c_attribute43,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute43,'NULL') = nvl(c.c_attribute43,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute43,'NULL') <> nvl(c.c_attribute43,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute43,
                    o.o_attribute44,
                    c.c_attribute44,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute44,'NULL') = nvl(c.c_attribute44,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute44,'NULL') <> nvl(c.c_attribute44,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute44,
                    o.o_attribute45,
                    c.c_attribute45,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute45,'NULL') = nvl(c.c_attribute45,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute45,'NULL') <> nvl(c.c_attribute45,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute45,
                    o.o_attribute46,
                    c.c_attribute46,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute46,'NULL') = nvl(c.c_attribute46,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute46,'NULL') <> nvl(c.c_attribute46,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute46,
                    o.o_attribute47,
                    c.c_attribute47,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute47,'NULL') = nvl(c.c_attribute47,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute47,'NULL') <> nvl(c.c_attribute47,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute47,
                    o.o_attribute49,
                    c.c_attribute49,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute49,'NULL') = nvl(c.c_attribute49,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute49,'NULL') <> nvl(c.c_attribute49,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute49,
                    o.o_attribute50,
                    c.c_attribute50,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute50,'NULL') = nvl(c.c_attribute50,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute50,'NULL') <> nvl(c.c_attribute50,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute50,
                    o.o_attribute53,
                    c.c_attribute53,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(
                                    TRIM(o.o_attribute53),
                                    'NULL'
                                ) = nvl(
                                    TRIM(c.c_attribute53),
                                    'NULL'
                                ) THEN 1
                                WHEN nvl(
                                    TRIM(o.o_attribute53),
                                    'NULL'
                                ) <> nvl(
                                    TRIM(c.c_attribute53),
                                    'NULL'
                                ) THEN 0
                            END
                        )
                    ) compare_attribute53,
                    o.o_attribute54,
                    c.c_attribute54,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute54,'NULL') = nvl(c.c_attribute54,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute54,'NULL') <> nvl(c.c_attribute54,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute54,
                    o.o_attribute55,
                    c.c_attribute55,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute55,'NULL') = nvl(c.c_attribute55,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute55,'NULL') <> nvl(c.c_attribute55,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute55,
                    o.o_attribute56,
                    c.c_attribute56,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute56,'NULL') = nvl(c.c_attribute56,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute56,'NULL') <> nvl(c.c_attribute56,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute56,
                    o.o_attribute57,
                    c.c_attribute57,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute57,'NULL') = nvl(c.c_attribute57,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute57,'NULL') <> nvl(c.c_attribute57,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute57,
                    o.o_attribute58,
                    c.c_attribute58,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute58,'NULL') = nvl(c.c_attribute58,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute58,'NULL') <> nvl(c.c_attribute58,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute58,
                    o.o_attribute59,
                    c.c_attribute59,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute59,'NULL') = nvl(c.c_attribute59,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute59,'NULL') <> nvl(c.c_attribute59,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute59,
                    o.o_attribute60,
                    c.c_attribute60,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute60,'NULL') = nvl(c.c_attribute60,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute60,'NULL') <> nvl(c.c_attribute60,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute60,
                    o.o_attribute61,
                    c.c_attribute61,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute61,'NULL') = nvl(c.c_attribute61,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute61,'NULL') <> nvl(c.c_attribute61,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute61,
                    o.o_attribute62,
                    c.c_attribute62,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute62,'NULL') = nvl(
                                    TO_CHAR(
                                        TO_DATE(c.c_attribute62,'dd/mm/yyyy hh24:mi:ss'),
                                        'DD-MON-YY'
                                    ),
                                    'NULL'
                                ) THEN 1
                                WHEN nvl(o.o_attribute62,'NULL') <> nvl(
                                    TO_CHAR(
                                        TO_DATE(c.c_attribute62,'dd/mm/yyyy hh24:mi:ss'),
                                        'DD-MON-YY'
                                    ),
                                    'NULL'
                                ) THEN 0
                            END
                        )
                    ) compare_attribute62,
                    o.o_attribute63,
                    c.c_attribute63,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute63,'NULL') = nvl(c.c_attribute63,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute63,'NULL') <> nvl(c.c_attribute63,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute63,
                    o.o_attribute64,
                    c.c_attribute64,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute64,'NULL') = nvl(c.c_attribute64,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute64,'NULL') <> nvl(c.c_attribute64,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute64,
                    o.o_attribute65,
                    c.c_attribute65,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute65,'NULL') = nvl(c.c_attribute65,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute65,'NULL') <> nvl(c.c_attribute65,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute65,
                    o.o_attribute67,
                    c.c_attribute67,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute67,'NULL') = nvl(
                                    DECODE(
                                        c.c_attribute67,
                                        'Yes',
                                        'Y',
                                        'No',
                                        'N',
                                        c.c_attribute67
                                    ),
                                    'NULL'
                                ) THEN 1
                                WHEN nvl(o.o_attribute67,'NULL') <> nvl(
                                    DECODE(
                                        c.c_attribute67,
                                        'Yes',
                                        'Y',
                                        'No',
                                        'N',
                                        c.c_attribute67
                                    ),
                                    'NULL'
                                ) THEN 0
                            END
                        )
                    ) compare_attribute67,
                    o.o_attribute69,
                    c.c_attribute69,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute69,'NULL') = nvl(
                                    TO_CHAR(
                                        TO_DATE(c.c_attribute69,'dd/mm/yyyy hh24:mi:ss'),
                                        'DD-MON-YY'
                                    ),
                                    'NULL'
                                ) THEN 1
                                WHEN nvl(o.o_attribute69,'NULL') <> nvl(
                                    TO_CHAR(
                                        TO_DATE(c.c_attribute69,'dd/mm/yyyy hh24:mi:ss'),
                                        'DD-MON-YY'
                                    ),
                                    'NULL'
                                ) THEN 0
                            END
                        )
                    ) compare_attribute69,
                    o.o_attribute72,
                    c.c_attribute72,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute72,'NULL') = nvl(c.c_attribute72,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute72,'NULL') <> nvl(c.c_attribute72,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute72,
                    o.o_attribute78,
                    c.c_attribute78,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute78,'NULL') = nvl(c.c_attribute78,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute78,'NULL') <> nvl(c.c_attribute78,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute78,
                    o.o_attribute79,
                    c.c_attribute79,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute79,'NULL') = nvl(c.c_attribute79,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute79,'NULL') <> nvl(c.c_attribute79,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute79,
                    o.o_attribute81,
                    c.c_attribute81,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute81,'NULL') = nvl(c.c_attribute81,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute81,'NULL') <> nvl(c.c_attribute81,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute81,
                    o.o_attribute82,
                    c.c_attribute82,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute82,'NULL') = nvl(c.c_attribute82,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute82,'NULL') <> nvl(c.c_attribute82,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute82,
                    o.o_attribute84,
                    c.c_attribute84,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute84,'NULL') = nvl(c.c_attribute84,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute84,'NULL') <> nvl(c.c_attribute84,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute84,
                    o.o_attribute88,
                    c.c_attribute88,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute88,'NULL') = nvl(c.c_attribute88,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute88,'NULL') <> nvl(c.c_attribute88,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute88,
                    o.o_attribute89,
                    c.c_attribute89,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute89,'NULL') = nvl(c.c_attribute89,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute89,'NULL') <> nvl(c.c_attribute89,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute89,
                    o.o_attribute90,
                    c.c_attribute90,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute90,'NULL') = nvl(c.c_attribute90,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute90,'NULL') <> nvl(c.c_attribute90,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute90,
                    o.o_attribute91,
                    c.c_attribute91,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute91,'NULL') = nvl(c.c_attribute91,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute91,'NULL') <> nvl(c.c_attribute91,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute91,
                    o.o_attribute92,
                    c.c_attribute92,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute92,'NULL') = nvl(c.c_attribute92,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute92,'NULL') <> nvl(c.c_attribute92,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute92,
                    o.o_attribute94,
                    c.c_attribute94,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute94,'NULL') = nvl(c.c_attribute94,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute94,'NULL') <> nvl(c.c_attribute94,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute94,
                    o.o_attribute100,
                    c.c_attribute100,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_attribute100,'NULL') = nvl(c.c_attribute100,'NULL')  THEN 1
                                WHEN nvl(o.o_attribute100,'NULL') <> nvl(c.c_attribute100,'NULL') THEN 0
                            END
                        )
                    ) compare_attribute100,
                    o.o_booked_date,
                    c.c_booked_date,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_booked_date,'NULL') = nvl(c.c_booked_date,'NULL')  THEN 1
                                WHEN nvl(o.o_booked_date,'NULL') <> nvl(c.c_booked_date,'NULL') THEN 0
                            END
                        )
                    ) compare_booked_date,
                    o.o_revenue_type,
                    c.c_revenue_type,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_revenue_type,'NULL') = nvl(c.c_revenue_type,'NULL')  THEN 1
                                WHEN nvl(o.o_revenue_type,'NULL') <> nvl(c.c_revenue_type,'NULL') THEN 0
                            END
                        )
                    ) compare_revenue_type,
                    o.o_record_status,
                    c.c_record_status,
                    DECODE(
                        nvl(c.c_filename,'x'),
                        'x',
                        1,
                        (
                            CASE
                                WHEN nvl(o.o_record_status,'NULL') = nvl(c.c_record_status,'NULL')  THEN 1
                                WHEN nvl(o.o_record_status,'NULL') <> nvl(c.c_record_status,'NULL') THEN 0
                            END
                        )
                    ) compare_record_status,
                    o.o_error_type,
                    c.c_error_type,
                    o.o_error_msg,
                    c.c_error_msg,
                    o.o_source,
                    c.c_source,
                    o.o_submitted_date,
                    c.c_submitted_date,
                    o.o_status_header,
                    c.c_status_header,
                    o.o_status_order_line_item,
                    c.c_status_order_line_item
                FROM
                    test_oic_preproc o,
                    test_callidus_preproc c
                WHERE
                        o.o_attribute46 = c.c_attribute46 (+)
                    AND
                        o.o_attribute60 = c.c_attribute60 (+)
            )

a;
                          
--7

SELECT
    DECODE(
        o_attribute88,
        'Commissions Main Plan',
        DECODE(
            o_attribute39,
            'Bundle Offering',
            o_attribute88
             || ' - Bundle',
            o_attribute88
             || ' - CPC'
        ),
        o_attribute88
    ) product_type,
    COUNT(1) expected_coli,
    SUM(
        CASE nvl(c_filename,'x')
            WHEN 'x'   THEN 0
            ELSE 1
        END
    ) coli_exists,
    SUM(
        CASE nvl(c_filename,'x')
            WHEN 'x'   THEN 1
            ELSE 0
        END
    ) coli_missing,
    (
        SELECT
            COUNT(column_name)
        FROM
            all_tab_columns
        WHERE
                table_name = 'TEST_PREPROC_COMPARISON'
            AND
                column_name LIKE upper('compare%')
    ) fields_compared,
    (
        CASE
            WHEN (
                COUNT(1) = SUM(compare_processed_date)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_transaction_amount)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_quantity)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute1)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute2)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute21)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute22)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute23)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute25)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute26)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute27)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute28)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute29)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute30)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute31)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute33)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute34)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute35)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute36)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute38)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute39)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute41)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute42)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute43)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute44)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute45)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute46)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute47)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute49)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute50)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute53)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute54)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute55)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute56)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute57)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute58)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute59)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute60)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute61)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute62)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute63)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute64)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute65)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute67)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute69)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute72)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute78)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute79)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute81)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute82)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute84)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute88)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute89)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute90)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute91)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute92)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute94)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_attribute100)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_booked_date)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_revenue_type)
            ) THEN 1
            ELSE 0
        END
    +
        CASE
            WHEN (
                COUNT(1) = SUM(compare_record_status)
            ) THEN 1
            ELSE 0
        END
    ) fields_match,
    COUNT(1) - SUM(compare_attribute1) customer_last_name_a1,
    COUNT(1) - SUM(compare_attribute2) customer_first_name_a2,
    COUNT(1) - SUM(compare_attribute21) new_minimum_spend_a21,
    COUNT(1) - SUM(compare_attribute22) previous_part_number_a22,
    COUNT(1) - SUM(compare_attribute23) previous_minimum_spend_a23,
    COUNT(1) - SUM(compare_attribute25) order_number_a25,
    COUNT(1) - SUM(compare_attribute26) billing_account_a26,
    COUNT(1) - SUM(compare_attribute27) partner_code_a27,
    COUNT(1) - SUM(compare_attribute28) campaign_name_a28,
    COUNT(1) - SUM(compare_attribute29) campaign_number_a29,
    COUNT(1) - SUM(compare_attribute30) campaign_type_a30,
    COUNT(1) - SUM(compare_attribute31) channel_type_a31,
    COUNT(1) - SUM(compare_attribute33) campaign_start_date_a33,
    COUNT(1) - SUM(compare_attribute34) welcome_credits_a34,
    COUNT(1) - SUM(compare_attribute35) business_unit_a35,
    COUNT(1) - SUM(compare_attribute36) sales_force_id_a36,
    COUNT(1) - SUM(compare_attribute38) source_system_a38,
    COUNT(1) - SUM(compare_attribute39) moli_porduct_a39,
    COUNT(1) - SUM(compare_attribute41) moli_action_code_a41,
    COUNT(1) - SUM(compare_attribute42) moli_transfer_type_a42,
    COUNT(1) - SUM(compare_attribute43) service_identifier_a43,
    COUNT(1) - SUM(compare_attribute44) moli_prom_id_a44,
    COUNT(1) - SUM(compare_attribute45) order_sub_type_a45,
    COUNT(1) - SUM(compare_attribute46) coli_row_id_a46,
    COUNT(1) - SUM(compare_attribute47) product_description_a47,
    COUNT(1) - SUM(compare_attribute49) coli_action_code_a49,
    COUNT(1) - SUM(compare_attribute50) coli_prom_id_a50,
    COUNT(1) - SUM(compare_attribute53) comments_a53,
    COUNT(1) - SUM(compare_attribute54) mdpm__a54,
    COUNT(1) - SUM(compare_attribute55) carrier_selection_code_a55,
    COUNT(1) - SUM(compare_attribute56) carrier_selection_value_a56,
    COUNT(1) - SUM(compare_attribute57) network_type_action_code_a57,
    COUNT(1) - SUM(compare_attribute58) network_type_value_a58,
    COUNT(1) - SUM(compare_attribute59) imei_a59,
    COUNT(1) - SUM(compare_attribute60) order_type_a60,
    COUNT(1) - SUM(compare_attribute61) contract_add_action_code_a61,
    COUNT(1) - SUM(compare_attribute62) contract_add_start_date_a62,
    COUNT(1) - SUM(compare_attribute63) bundle_service_added_a63,
    COUNT(1) - SUM(compare_attribute64) access_type_a64,
    COUNT(1) - SUM(compare_attribute65) contract_add_term_a65,
    COUNT(1) - SUM(compare_attribute67) hardware_supplied_flag_a67,
    COUNT(1) - SUM(compare_attribute69) contract_delete_start_date_a69,
    COUNT(1) - SUM(compare_attribute72) contract_delete_term_a72,
    COUNT(1) - SUM(compare_attribute78) sales_type_a78,
    COUNT(1) - SUM(compare_attribute79) parp_a79,
    COUNT(1) - SUM(compare_attribute81) part_number_a81,
    COUNT(1) - SUM(compare_attribute82) mro_amount_a82,
    COUNT(1) - SUM(compare_attribute84) rebate_amount_a84,
    COUNT(1) - SUM(compare_attribute88) commission_product_type_a88,
    COUNT(1) - SUM(compare_attribute89) main_plan_id_a89,
    COUNT(1) - SUM(compare_attribute90) main_plan_name_a90,
    COUNT(1) - SUM(compare_attribute91) hardware_id_a91,
    COUNT(1) - SUM(compare_attribute92) hardware_name_a92,
    COUNT(1) - SUM(compare_attribute94) recontract_month_a94,
    COUNT(1) - SUM(compare_attribute100) vas_offer_type_100,
    COUNT(1) - SUM(compare_booked_date) AS compare_booked_date,
    COUNT(1) - SUM(compare_processed_date) AS compare_processed_date,
    COUNT(1) - SUM(compare_quantity) AS compare_quantity,
    COUNT(1) - SUM(compare_record_status) AS compare_record_status,
    COUNT(1) - SUM(compare_revenue_type) AS compare_revenue_type,
    COUNT(1) - SUM(compare_transaction_amount) AS compare_transaction_amount
FROM
    test_preproc_comparison
GROUP BY
    DECODE(
        o_attribute88,
        'Commissions Main Plan',
        DECODE(
            o_attribute39,
            'Bundle Offering',
            o_attribute88 || ' - Bundle',
            o_attribute88 || ' - CPC'
        ),
        o_attribute88
    );
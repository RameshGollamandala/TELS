DROP TABLE TELS_CWP_CUSTOMERBILL CASCADE CONSTRAINTS PURGE
/

CREATE TABLE TELS_CWP_CUSTOMERBILL
(
  FILENAME                        VARCHAR2(255 BYTE) NOT NULL,
  BATCHPROCESSDATE                DATE          NOT NULL,
  RECORDNUMBER                    NUMBER(15)    NOT NULL,
  IS_FILTERED                     NUMBER(1)     NOT NULL,
  SOURCE_SYSTEM                   VARCHAR2(255 BYTE),
  SOURCE_SYSTEM_KEY               VARCHAR2(255 BYTE),
  SOURCE_SYS_BILLING_ACCOUNT_KEY  VARCHAR2(255 BYTE),
  BILLING_ACCOUNT_NUMBER          VARCHAR2(255 BYTE),
  INVOICE_NUMBER                  VARCHAR2(255 BYTE),
  TRANSACTION_TYPE                VARCHAR2(255 BYTE),
  INVOICE_TYPE                    VARCHAR2(255 BYTE),
  INVOICE_FROM_DATE               DATE,
  INVOICE_TO_DATE                 DATE,
  USAGE_BILL_FROM_DATE            DATE,
  USAGE_BILL_THROUGH_DATE         DATE,
  INVOICE_AMOUNT                  NUMBER(25,10),
  BILL_DATE                       DATE,
  DUE_DATE                        DATE,
  CURRENCY                        VARCHAR2(255 BYTE),
  BALANCE_FORWARD                 NUMBER(25,10),
  TOTAL_DUE                       NUMBER(25,10),
  INVOICE_COMMENTS                VARCHAR2(255 BYTE),
  VOIDING_EVENT_NUMBER            VARCHAR2(255 BYTE),
  B2B_INSERT_TIMESTAMP            DATE,
  B2B_BATCH_ID                    VARCHAR2(255 BYTE),
  B2B_KEY                         VARCHAR2(255 BYTE)
)
TABLESPACE TELS_SOURCES
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING
/


CREATE UNIQUE INDEX TELS_CUSTOMERBILL_PK ON TELS_CWP_CUSTOMERBILL
(FILENAME, BATCHPROCESSDATE, RECORDNUMBER)
LOGGING
TABLESPACE TELS_SOURCES
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL
/

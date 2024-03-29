DROP TABLE TELS_CWP_OPPORTUNITY CASCADE CONSTRAINTS PURGE
/

CREATE TABLE TELS_CWP_OPPORTUNITY
(
  FILENAME                       VARCHAR2(255 BYTE) NOT NULL,
  BATCHPROCESSDATE               DATE           NOT NULL,
  RECORDNUMBER                   NUMBER(15)     NOT NULL,
  IS_FILTERED                    NUMBER(1)      NOT NULL,
  B2B_KEY                        VARCHAR2(255 BYTE),
  B2B_INSERT_TIMESTAMP           DATE,
  B2B_BATCH_ID                   VARCHAR2(255 BYTE),
  SOURCE_SYSTEM                  VARCHAR2(255 BYTE),
  SOURCE_SYSTEM_CUSTOMER_KEY     VARCHAR2(255 BYTE),
  SOURCE_SYSTEM_KEY              VARCHAR2(255 BYTE),
  IS_DELETED                     NUMBER(1),
  IS_PRIVATE                     NUMBER(1),
  OPPORTUNITY_NAME               VARCHAR2(255 BYTE),
  STAGE_NAME                     VARCHAR2(255 BYTE),
  AMOUNT                         NUMBER(25,10),
  PROBABILITY                    NUMBER(25,10),
  EXPECTED_REVENUE               NUMBER(25,10),
  TOTAL_OPPORTUNITY_QUANTITY     NUMBER(25,10),
  CLOSE_DATE                     DATE,
  OPPORTUNITY_TYPE               VARCHAR2(255 BYTE),
  NEXT_STEP                      VARCHAR2(255 BYTE),
  LEAD_SOURCE                    VARCHAR2(255 BYTE),
  IS_CLOSED                      NUMBER(1),
  IS_WON                         NUMBER(1),
  CAMPAIGN_ID                    VARCHAR2(255 BYTE),
  OWNER_DNO                      VARCHAR2(255 BYTE),
  SOURCE_SYSTEM_CREATED_DATE     DATE,
  FISCAL_QUARTER                 NUMBER(15),
  FISCAL_YEAR                    NUMBER(15),
  FISCAL                         VARCHAR2(255 BYTE),
  CIDN                           VARCHAR2(255 BYTE),
  DESCRIPTION                    VARCHAR2(255 BYTE),
  END_DATE                       DATE,
  OFFER_NAME                     VARCHAR2(255 BYTE),
  OPPORTUNITY_CONTACT_PHONE_1    VARCHAR2(255 BYTE),
  OPPORTUNITY_NUMBER             VARCHAR2(255 BYTE),
  OPPORTUNITY_SOURCE             VARCHAR2(255 BYTE),
  ARCHETYPE                      VARCHAR2(255 BYTE),
  BILLING_SOLUTION               VARCHAR2(255 BYTE),
  CHANGE_TO_ABR_CALC             NUMBER(25,10),
  COMPETITOR                     VARCHAR2(255 BYTE),
  CONFIDENCE_LEVEL               VARCHAR2(255 BYTE),
  CONTRACT_TERM                  VARCHAR2(255 BYTE),
  CONTRACT_TERMS                 VARCHAR2(255 BYTE),
  CONTRACT_TYPE                  VARCHAR2(255 BYTE),
  IS_CUSTOMER_ACCEPTED           NUMBER(1),
  CUSTOMER_TIER                  VARCHAR2(255 BYTE),
  DOMAIN                         VARCHAR2(255 BYTE),
  EXPECTED_REVENUE_CALC          VARCHAR2(255 BYTE),
  EXTERNAL_OPPORTUNITY_ID        VARCHAR2(255 BYTE),
  ONGOING_OVER_CONTRACT_CALC     VARCHAR2(255 BYTE),
  OPPORTUNITY_RECORD_TYPE        VARCHAR2(255 BYTE),
  IS_OVERDUE                     NUMBER(1),
  PORTFOLIO_CODE                 VARCHAR2(255 BYTE),
  PRICE_LIST                     VARCHAR2(255 BYTE),
  PRICING_METHOD                 VARCHAR2(255 BYTE),
  PRICING_STATUS                 VARCHAR2(255 BYTE),
  PRODUCT_DOMAIN                 VARCHAR2(255 BYTE),
  PROPOSAL_TYPE                  VARCHAR2(255 BYTE),
  REVENUE_IMPACT_DATE_CALC       DATE,
  REVENUE_IMPACT_DATE            DATE,
  SOURCE_SYSTEM_OF_OPPORTUNITY   VARCHAR2(255 BYTE),
  SUCCESS_INDICATOR              VARCHAR2(255 BYTE),
  TOTAL_CONTRACT_VALUE_CALC      NUMBER(25,10),
  WON_LOST_REASON                VARCHAR2(255 BYTE),
  ACQUISITION_REVENUE_ROLLUP     NUMBER(25,10),
  AVG_ANNUALISED_REVENUE_ROLLUP  NUMBER(25,10),
  CURRENT_REVENUE_ROLLUP         NUMBER(25,10),
  INCREMENTAL_REVENUE_ROLLUP     NUMBER(25,10),
  NEW_INCOME_REVENUE_ROLLUP      NUMBER(25,10),
  ONCE_OFF_REVENUE_ROLLUP        NUMBER(25,10),
  PRODUCT_COUNT                  NUMBER(25,10),
  RENEWAL_REVENUE_ROLLUP         NUMBER(25,10),
  OVERALL_WIN_LOSS_COMMENT       VARCHAR2(255 BYTE),
  PRODUCT_TYPE                   VARCHAR2(255 BYTE),
  IS_ACTIVE_ACCOUNT              NUMBER(1),
  SOURCE_SYSTEM_PARTNER_ID       VARCHAR2(255 BYTE),
  PARTNER_ACCOUNT_NAME           VARCHAR2(255 BYTE),
  PARTNER_CODE                   VARCHAR2(255 BYTE),
  PARTNER_TYPE                   VARCHAR2(255 BYTE),
  CONTRACT                       VARCHAR2(255 BYTE),
  ALLIANCE                       VARCHAR2(255 BYTE)
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


CREATE UNIQUE INDEX TELS_OPPORTUNITY_PK ON TELS_CWP_OPPORTUNITY
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

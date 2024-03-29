DROP TABLE TELS_CWP_CUSTOMER_PRESTAGE CASCADE CONSTRAINTS PURGE
/

CREATE TABLE TELS_CWP_CUSTOMER_PRESTAGE
(
  FILENAME                        VARCHAR2(255 BYTE) NOT NULL,
  BATCHPROCESSDATE                DATE          NOT NULL,
  RECORDNUMBER                    NUMBER(15)    NOT NULL,
  IS_FILTERED                     NUMBER(1)     NOT NULL,
  B2B_KEY                         VARCHAR2(255 BYTE),
  B2B_INSERT_TIMESTAMP            VARCHAR2(255 BYTE),
  B2B_BATCH_ID                    VARCHAR2(255 BYTE),
  SOURCE_SYSTEM                   VARCHAR2(255 BYTE),
  SOURCE_SYSTEM_KEY               VARCHAR2(255 BYTE),
  IS_DELETED                      VARCHAR2(255 BYTE),
  CUSTOMER_NAME                   VARCHAR2(255 BYTE),
  CUSTOMER_TYPE                   VARCHAR2(255 BYTE),
  SOURCE_SYSTEM_PARENT_KEY        VARCHAR2(255 BYTE),
  CUSTOMER_PHONE                  VARCHAR2(255 BYTE),
  CUSTOMER_FAX                    VARCHAR2(255 BYTE),
  SOURCE_SYSTEM_CREATED_DATE      VARCHAR2(255 BYTE),
  IS_PARTNER                      VARCHAR2(255 BYTE),
  ABN                             VARCHAR2(255 BYTE),
  CIDN                            VARCHAR2(255 BYTE),
  CUSTOMER_TRADING_NAME           VARCHAR2(255 BYTE),
  LEGACY_OWNERSHIP_CODE           VARCHAR2(255 BYTE),
  LEGACY_REVEUE_ORG_UNIT          VARCHAR2(255 BYTE),
  LEGACY_SALES_ORG_UNIT           VARCHAR2(255 BYTE),
  ABN_STATUS                      VARCHAR2(255 BYTE),
  ABN_TRADING_NAME                VARCHAR2(255 BYTE),
  ACN                             VARCHAR2(255 BYTE),
  ACCOUNT_UUID                    VARCHAR2(255 BYTE),
  ACTUAL_RETIRED_DATE             VARCHAR2(255 BYTE),
  BUSINESS_UNIT                   VARCHAR2(255 BYTE),
  CUSTOMER_EFFECTIVE_ST_DATE      VARCHAR2(255 BYTE),
  CUSTOMER_STATUS                 VARCHAR2(255 BYTE),
  DATE_ST_TRAD_WITH_TELSTRA       VARCHAR2(255 BYTE),
  DATE_OF_APPLICATION             VARCHAR2(255 BYTE),
  CUSTOMER_EMAIL                  VARCHAR2(255 BYTE),
  MARKET_SEGMENT                  VARCHAR2(255 BYTE),
  IS_ONLINE_BILL_REGISTERED       VARCHAR2(255 BYTE),
  PARENT_CIDN                     VARCHAR2(255 BYTE),
  PORTFOLIO_CODE                  VARCHAR2(255 BYTE),
  IS_PREMIUM_SERVICE              VARCHAR2(255 BYTE),
  SOURCE_SYS_PRIMARY_ADDRS_KEY    VARCHAR2(255 BYTE),
  ULTIMATE_CIDN                   VARCHAR2(255 BYTE),
  YTT_YOUR_TELS_TOOLS_REGISTERED  VARCHAR2(255 BYTE),
  ACCOUNT_OWNER_NAME              VARCHAR2(255 BYTE),
  PRICE_LIST                      VARCHAR2(255 BYTE),
  ABR_LAST_VALIDATED_DATE         VARCHAR2(255 BYTE),
  CUSTOMER_EFFECTIVE_ED           VARCHAR2(255 BYTE),
  CUSTOMER_LAST_VERIFIED_DATE     VARCHAR2(255 BYTE),
  IS_CUSTOMER_VERIFIED            VARCHAR2(255 BYTE),
  RELATIONSHIP_TYPE               VARCHAR2(255 BYTE),
  IS_VIP_CUSTOMER                 VARCHAR2(255 BYTE),
  IS_WRITTEN_AUTH_REQUIRED        VARCHAR2(255 BYTE),
  RETIREMENT_REASON               VARCHAR2(255 BYTE),
  TELSTRA_CHANNEL_MANAGER         VARCHAR2(255 BYTE),
  TELSTRA_DISTR_AGREEMENT         VARCHAR2(255 BYTE),
  TELSTRA_NOM_DISTR_AGREEMENT     VARCHAR2(255 BYTE),
  TELSTRA_ONLINE_SERV_AGREEMENT   VARCHAR2(255 BYTE),
  TELSTRA_PARTNER_SERV_AGREEMENT  VARCHAR2(255 BYTE),
  PRIMARY_DISTRIBUTOR_NAME        VARCHAR2(255 BYTE)
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


CREATE UNIQUE INDEX TELS_PRESTAGE_CUST_PK ON TELS_CWP_CUSTOMER_PRESTAGE
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

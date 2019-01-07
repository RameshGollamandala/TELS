/********************************************************************
  ** TELS_CCG_PRE_PAYBATCH
  **
  ** Version: 1.0
  ** Author: Simon Marsh
  ** Created: June 2018
  ** Description:
  **
  ** Date       Modified By   Description
  ** ------------------------------------------------------------------
  ** 20180619   Simon Marsh   Initial Version
  ********************************************************************/
--DROP TABLE TELS_CCG_PRE_PAYBATCH;
CREATE TABLE TELS_CCG_PRE_PAYBATCH
(
    COMMISSION_HEADER_ID          varchar(255),
    CL_COMMISSION_HEADER_ID       varchar(255),
    CL_COMMISSION_LINE_ID         varchar(255),
    CH_PROCESSED_DATE             varchar(255),
    ORDER_NUMBER                  varchar(255),
    ORDER_LINE_ITEM               varchar(255),
    CL_CREDIT_TYPE                varchar(255),
    CL_CREATE_DURING              varchar(255),
    CL_COMMISSION_AMOUNT          varchar(255),
    CL_COMMISSION_RATE            varchar(255),
    CH_PREMISE_ID                 varchar(255),
    PAY_POINT_ID                  varchar(255),
    CL_POSTING_STATUS             varchar(255),
    CL_STATUS                     varchar(255),
    CL_ERROR_REASON               varchar(255),
    CL_ROLE_ID                    varchar(255),
    CL_REVENUE_CLASS              varchar(255),
    CL_QUOTA_ID                   varchar(255),
    CL_QUOTA_RULE_ID              varchar(255),
    PRE_PROCESSED_CODE            varchar(255),
    CH_STATUS                     varchar(255),
    CH_SOURCE_SYSTEM              varchar(255),
    CH_SYSTEM_PROCESS             varchar(255),
    CH_LIST_PRICE                 varchar(255),
    CH_SALE_STAFF_ID              varchar(255),
    CH_REVENUE_CLASS_ID           varchar(255),
    MOLI_PROVISIONED_DATE         varchar(255),
    CH_CH_ADJUST_STATUS           varchar(255),
    CUSTOMER_NAME                 varchar(255),
    CH_BILLING_ACCOUNT            varchar(255),
    CH_IMEI                       varchar(255),
    CH_COMMENT                    varchar(255),
    CH_PRODUCT_CATEGORY           varchar(255),
    CH_PRODUCT_DESCRIPTION        varchar(255),
    CH_COLI_PART_NUMBER           varchar(255),
    CH_NETWORK                    varchar(255),
    CH_PRODUCT_FAMILY_CODE        varchar(255),
    CH_PRODUCT_FAMILY_DESCRIPTION varchar(255),
    CH_PRODUCT_ATTRIBUTE_1        varchar(255),
    CH_PRODUCT_ATTRIBUTE_2        varchar(255),
    CH_PRODUCT_ATTRIBUTE_3        varchar(255),
    CH_PRODUCT_ATTRIBUTE_4        varchar(255),
    CH_PRODUCT_REVIEW_NAME        varchar(255),
    CH_SUBMISSION_COMPLETION      varchar(255),
    CH_PRODUCT_COL_REVIEW_1       varchar(255),
    CH_PRODUCT_COL_REVIEW_2       varchar(255),
    CH_PLAN_MMC                   varchar(255),
    CH_PRODUCT_CODE_PREMIUM_PLAN  varchar(255),
    CH_PREV_PLAN_MMC              varchar(255),
    CH_SUBCOMPLETION              varchar(255),
    CH_HARDWARE_SUPPLIED          varchar(255),
    CH_ACCESS_TYPE                varchar(255),
    CH_SHAPED                     varchar(255),
    CH_CAMPAIGN_NAME              varchar(255),
    CH_SUBSCRIPTION_CATEGORY      varchar(255),
    CH_CAMPAIGN_NUM               varchar(255),
    CH_SALES_TYPE                 varchar(255)
);

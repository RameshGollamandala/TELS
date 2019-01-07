/********************************************************************
  ** TELS_CCG_DEALER_TRANSLATION
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
--DROP TABLE TELS_CCG_DEALER_TRANSLATION;
CREATE TABLE TELS_CCG_DEALER_TRANSLATION
(
    PARTICIPANT_ID      varchar2(255),
    LEGACY_PARTNER_CODE varchar2(255),
    PARTICIPANT_NAME    varchar2(255),
    PARTICIPANT_SITE    varchar2(255)
);

/********************************************************************
  ** TELS_POSTED_PERIOD_HISTORY
  **
  ** Version: 1.0
  ** Author: Simon Marsh
  ** Created: June 2018
  ** Description: Used to prevent already posted and paid results from 
                  entering the payfile more than once
  **
  ** Date       Modified By   Description
  ** ------------------------------------------------------------------
  ** 20180619   Simon Marsh   Initial Version
  ********************************************************************/
--DROP TABLE TELS_POSTED_PERIOD_HISTORY;
CREATE TABLE TELS_POSTED_PERIOD_HISTORY
(
    PERIOD_NAME              varchar(50) NOT NULL ENABLE,
    POST_PIPELINERUNSEQ      varchar(50) NOT NULL ENABLE,
--    POST_PIPELINERUNSEQ      number(38,0) NOT NULL ENABLE,
    DELTA_FLAG               varchar(10),
    PAYFILE_NAME             varchar(255)
);
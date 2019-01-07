/********************************************************************
  ** TELS_OGPO_POSITION
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
--DROP TABLE TELS_OGPO_POSITION;
CREATE TABLE TELS_OGPO_POSITION
(
    FILENAME                      varchar2(50) NOT NULL,
--    RECORD_NUMBER                 number(15) NOT NULL,
    POSITIONNAME                  varchar(255),
    EFFECTIVESTARTDATE            varchar(255),
    EFFECTIVEENDDATE              varchar(255),
    PAYEEID                       varchar(255),
    PAYEETYPE                     varchar(255),
    PLANNAME                      varchar(255),
    MANAGERNAME                   varchar(255),
    TITLENAME                     varchar(255),
    POSITIONGROUPNAME             varchar(255),
    TARGETCOMPENSATION            varchar(255),
    UNITTYPEFORTARGETCOMPENSATION varchar(255),
    BUSINESSUNITNAME              varchar(255),
    DESCRIPTION                   varchar(255),
    GENERICATTRIBUTE1             varchar(255),
    GENERICATTRIBUTE2             varchar(255),
    GENERICATTRIBUTE3             varchar(255),
    GENERICATTRIBUTE4             varchar(255),
    GENERICATTRIBUTE5             varchar(255),
    GENERICATTRIBUTE6             varchar(255),
    GENERICATTRIBUTE7             varchar(255),
    GENERICATTRIBUTE8             varchar(255),
    GENERICATTRIBUTE9             varchar(255),
    GENERICATTRIBUTE10            varchar(255),
    GENERICATTRIBUTE11            varchar(255),
    GENERICATTRIBUTE12            varchar(255),
    GENERICATTRIBUTE13            varchar(255),
    GENERICATTRIBUTE14            varchar(255),
    GENERICATTRIBUTE15            varchar(255),
    GENERICATTRIBUTE16            varchar(255),
    GENERICNUMBER1                varchar(255),
    UNITTYPEFORGENERICNUMBER1     varchar(255),
    GENERICNUMBER2                varchar(255),
    UNITTYPEFORGENERICNUMBER2     varchar(255),
    GENERICNUMBER3                varchar(255),
    UNITTYPEFORGENERICNUMBER3     varchar(255),
    GENERICNUMBER4                varchar(255),
    UNITTYPEFORGENERICNUMBER4     varchar(255),
    GENERICNUMBER5                varchar(255),
    UNITTYPEFORGENERICNUMBER5     varchar(255),
    GENERICNUMBER6                varchar(255),
    UNITTYPEFORGENERICNUMBER6     varchar(255),
    GENERICDATE1                  varchar(255),
    GENERICDATE2                  varchar(255),
    GENERICDATE3                  varchar(255),
    GENERICDATE4                  varchar(255),
    GENERICDATE5                  varchar(255),
    GENERICDATE6                  varchar(255),
    GENERICBOOLEAN1               varchar(255),
    GENERICBOOLEAN2               varchar(255),
    GENERICBOOLEAN3               varchar(255),
    GENERICBOOLEAN4               varchar(255),
    GENERICBOOLEAN5               varchar(255),
    GENERICBOOLEAN6               varchar(255),
    CREDITSTARTDATE               varchar(255),
    CREDITENDDATE                 varchar(255),
    PROCESSINGSTARTDATE           varchar(255),
    PROCESSINGENDDATE             varchar(255)
);

--ALTER TABLE TELS_OGPO_POSITION ADD PRIMARY KEY (FILENAME, RECORD_NUMBER);
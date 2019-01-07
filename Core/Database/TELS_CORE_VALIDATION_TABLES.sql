CREATE TABLE TELS_CORE_FIELDVALIDATION_CUST
(
  TABLENAME        VARCHAR2(30 CHAR)            NOT NULL,
  FIELDNAME        VARCHAR2(30 CHAR)            NOT NULL,
  CONDITIONKEY     INTEGER                      NOT NULL,
  ISWARNING        NUMBER(1)                    NOT NULL,
  ISNUMBER         NUMBER(1),
  ISREQUIRED       NUMBER(1),
  ISALWAYSNULL     NUMBER(1),
  ISDATE           NUMBER(1),
  ISDATETIME       NUMBER(1),
  ISINTEGER        NUMBER(1),
  ISDECIMAL        NUMBER(1),
  MINDATALENGTH    NUMBER(6),
  MAXDATALENGTH    NUMBER(6),
  MINNUMERICVALUE  NUMBER,
  MAXNUMERICVALUE  NUMBER,
  ISONEOFVALUESET  NUMBER(1),
  ISSPACES         NUMBER(1),
  MINDATEVALUE     DATE,
  MAXDATEVALUE     DATE,
  TCDATATYPE       VARCHAR2(40 BYTE),
  DATEFORMATCHECK  VARCHAR2(50 BYTE)
);

CREATE TABLE TELS_CORE_FIELDVALIDATION_STD
(
  TABLENAME        VARCHAR2(30 CHAR)            NOT NULL,
  FIELDNAME        VARCHAR2(30 CHAR)            NOT NULL,
  CONDITIONKEY     INTEGER                      NOT NULL,
  ISWARNING        NUMBER(1)                    NOT NULL,
  ISNUMBER         NUMBER(1),
  ISREQUIRED       NUMBER(1),
  ISALWAYSNULL     NUMBER(1),
  ISDATE           NUMBER(1),
  ISDATETIME       NUMBER(1),
  ISINTEGER        NUMBER(1),
  ISDECIMAL        NUMBER(1),
  MINDATALENGTH    NUMBER(6),
  MAXDATALENGTH    NUMBER(6),
  MINNUMERICVALUE  NUMBER,
  MAXNUMERICVALUE  NUMBER,
  ISONEOFVALUESET  NUMBER(1),
  ISSPACES         NUMBER(1),
  MINDATEVALUE     DATE,
  MAXDATEVALUE     DATE,
  TCDATATYPE       VARCHAR2(40 BYTE),
  DATEFORMATCHECK  VARCHAR2(50 BYTE)
);

DROP TABLE TELS_CORE_FIELDVALUESET_CUSTOM;
CREATE TABLE TELS_CORE_FIELDVALUESET_CUST
(
  TABLENAME     VARCHAR2(30 CHAR)               NOT NULL,
  FIELDNAME     VARCHAR2(30 CHAR)               NOT NULL,
  CONDITIONKEY  INTEGER                         NOT NULL,
  ALLOWEDVALUE  VARCHAR2(140 CHAR)
);

CREATE TABLE TELS_CORE_FIELDVALUESET_STD
(
  TABLENAME     VARCHAR2(30 CHAR)               NOT NULL,
  FIELDNAME     VARCHAR2(30 CHAR)               NOT NULL,
  CONDITIONKEY  INTEGER                         NOT NULL,
  ALLOWEDVALUE  VARCHAR2(140 CHAR)
);


CREATE TABLE TELS_CORE_PRESTAGEERROR
(
  FILENAME       VARCHAR2(256 BYTE),
  RECORDNUMBER   NUMBER(22),
  FIELDNAME      VARCHAR2(30 BYTE),
  RECORDKEY      VARCHAR2(256 BYTE),
  ORIGINALVALUE  VARCHAR2(256 BYTE),
  TEMPVALUE      VARCHAR2(50 BYTE),
  ERRORMESSAGE   VARCHAR2(256 BYTE),
  FILERUNDATE    DATE,
  TABLENAME      VARCHAR2(50 BYTE),
  ISWARNINGONLY  NUMBER(1)
);

DROP TABLE TELS_CORE_RECORDKEY_CUST;
CREATE TABLE TELS_CORE_RECORDKEY_CUST
(
  TABLENAME           VARCHAR2(30 CHAR),
  FIELDNAMELIST       VARCHAR2(300 CHAR),
  ISPRIMARYRECORDKEY  NUMBER(1)                 DEFAULT 0,
  CONDITIONKEY        INTEGER
);

DROP TABLE TELS_CORE_RECORDKEY_STD;
CREATE TABLE TELS_CORE_RECORDKEY_STD
(
  TABLENAME           VARCHAR2(30 CHAR),
  FIELDNAMELIST       VARCHAR2(300 CHAR),
  ISPRIMARYRECORDKEY  NUMBER(1)                 DEFAULT 0,
  CONDITIONKEY        INTEGER
);

CREATE TABLE TELS_CORE_VALIDATIONCONDITION
(
  CONDITIONKEY   INTEGER,
  ISSTANDARD     NUMBER(1)                      DEFAULT 0                     NOT NULL,
  TABLENAME      VARCHAR2(30 CHAR)              NOT NULL,
  CONDITIONTEXT  VARCHAR2(999 CHAR)
);

ALTER TABLE TELS_CORE_FIELDVALIDATION_CUST ADD (
  CONSTRAINT CHK10_FIELDVALIDATION_CUST
  CHECK (IsSpaces IN (0,1)),
  CONSTRAINT CHK1_FIELDVALIDATION_CUST
  CHECK (IsWarning IN (0,1)),
  CONSTRAINT CHK2_FIELDVALIDATION_CUST
  CHECK (IsNumber IN (0,1)),
  CONSTRAINT CHK3_FIELDVALIDATION_CUST
  CHECK (IsRequired IN (0,1)),
  CONSTRAINT CHK4_FIELDVALIDATION_CUST
  CHECK (IsAlwaysNull IN (0,1)),
  CONSTRAINT CHK5_FIELDVALIDATION_CUST
  CHECK (IsDate IN (0,1)),
  CONSTRAINT CHK6_FIELDVALIDATION_CUST
  CHECK (IsDateTime IN (0,1)),
  CONSTRAINT CHK7_FIELDVALIDATION_CUST
  CHECK (IsInteger IN (0,1)),
  CONSTRAINT CHK8_FIELDVALIDATION_CUST
  CHECK (IsDecimal IN (0,1)),
  CONSTRAINT CHK9_FIELDVALIDATION_CUST
  CHECK (IsOneOfValueSet IN (0,1)),
  CONSTRAINT TCDATATYPE_CUS_CK
  CHECK ("TCDATATYPE"='BusinessUnit' OR "TCDATATYPE"='EventType' OR "TCDATATYPE"='ProcessingUnit' OR "TCDATATYPE"='FixedValueType' OR "TCDATATYPE"='CreditType' OR "TCDATATYPE"='EarningGroup' OR "TCDATATYPE"='EarningCode' OR "TCDATATYPE"='Calendar' OR "TCDATATYPE"='UnitType'OR "TCDATATYPE"='ReasonId'OR "TCDATATYPE"='GenericClassifierType' OR "TCDATATYPE"='PeriodType'),
  PRIMARY KEY
  (TABLENAME, FIELDNAME, CONDITIONKEY)
  USING INDEX
    TABLESPACE TALLYDATA
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                INITIAL          64K
                NEXT             1M
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                PCTINCREASE      0
               ));

ALTER TABLE TELS_CORE_FIELDVALIDATION_STD ADD (
  CONSTRAINT CHK10_FIELDVALIDATION_STD
  CHECK (IsSpaces IN (0,1)),
  CONSTRAINT CHK1_FIELDVALIDATION_STD
  CHECK (IsWarning IN (0,1)),
  CONSTRAINT CHK2_FIELDVALIDATION_STD
  CHECK (IsNumber IN (0,1)),
  CONSTRAINT CHK3_FIELDVALIDATION_STD
  CHECK (IsRequired IN (0,1)),
  CONSTRAINT CHK4_FIELDVALIDATION_STD
  CHECK (IsAlwaysNull IN (0,1)),
  CONSTRAINT CHK5_FIELDVALIDATION_STD
  CHECK (IsDate IN (0,1)),
  CONSTRAINT CHK6_FIELDVALIDATION_STD
  CHECK (IsDateTime IN (0,1)),
  CONSTRAINT CHK7_FIELDVALIDATION_STD
  CHECK (IsInteger IN (0,1)),
  CONSTRAINT CHK8_FIELDVALIDATION_STD
  CHECK (IsDecimal IN (0,1)),
  CONSTRAINT CHK9_FIELDVALIDATION_STD
  CHECK (IsOneOfValueSet IN (0,1)),
  CONSTRAINT TCDATATYPE_STD_CK
  CHECK ("TCDATATYPE"='BusinessUnit' OR "TCDATATYPE"='EventType' OR "TCDATATYPE"='ProcessingUnit' OR "TCDATATYPE"='FixedValueType' OR "TCDATATYPE"='CreditType' OR "TCDATATYPE"='EarningGroup' OR "TCDATATYPE"='EarningCode' OR "TCDATATYPE"='Calendar' OR "TCDATATYPE"='UnitType'OR "TCDATATYPE"='ReasonId'OR "TCDATATYPE"='GenericClassifierType' OR "TCDATATYPE"='PeriodType'),
  PRIMARY KEY
  (TABLENAME, FIELDNAME, CONDITIONKEY)
  USING INDEX
    TABLESPACE TALLYDATA
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                INITIAL          64K
                NEXT             1M
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                PCTINCREASE      0
               ));

ALTER TABLE TELS_CORE_FIELDVALUESET_CUST ADD (
  PRIMARY KEY
  (TABLENAME, FIELDNAME, CONDITIONKEY, ALLOWEDVALUE)
  USING INDEX
    TABLESPACE TALLYDATA
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                INITIAL          64K
                NEXT             1M
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                PCTINCREASE      0
               ));

ALTER TABLE TELS_CORE_FIELDVALUESET_STD ADD (
  PRIMARY KEY
  (TABLENAME, FIELDNAME, CONDITIONKEY, ALLOWEDVALUE)
  USING INDEX
    TABLESPACE TALLYDATA
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                INITIAL          64K
                NEXT             1M
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                PCTINCREASE      0
               ));

ALTER TABLE TELS_CORE_RECORDKEY_CUST ADD (
  PRIMARY KEY
  (TABLENAME, FIELDNAMELIST)
  USING INDEX
    TABLESPACE TALLYDATA
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                INITIAL          64K
                NEXT             1M
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                PCTINCREASE      0
               ));

ALTER TABLE TELS_CORE_RECORDKEY_STD ADD (
  PRIMARY KEY
  (TABLENAME, FIELDNAMELIST)
  USING INDEX
    TABLESPACE TALLYDATA
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                INITIAL          64K
                NEXT             1M
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                PCTINCREASE      0
               ));

ALTER TABLE TELS_CORE_VALIDATIONCONDITION ADD (
  CONSTRAINT CHK1_TELS_CORE_VALIDATIONCOND
  CHECK (ISSTANDARD IN (0,1)),
  PRIMARY KEY
  (CONDITIONKEY)
  USING INDEX
    TABLESPACE TALLYDATA
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                INITIAL          64K
                NEXT             1M
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                PCTINCREASE      0
               ));

			   

CREATE OR REPLACE FORCE VIEW TELS_CORE_FIELDVALIDATION
(
   TABLENAME,
   FIELDNAME,
   CONDITIONID,
   CONDITION,
   ISWARNINGONLY,
   ISSTANDARD,
   ISNUMBER,
   ISREQUIRED,
   ISALWAYSNULL,
   ISDATE,
   ISDATETIME,
   ISINTEGER,
   ISDECIMAL,
   ISSPACES,
   ISONEOFVALUESET,
   MINDATALENGTH,
   MAXDATALENGTH,
   MINNUMERICVALUE,
   MAXNUMERICVALUE,
   MINDATEVALUE,
   MAXDATEVALUE,
   TCDATATYPE,
   DATEFORMATCHECK
)
AS
   SELECT s.TableName,
          s.FieldName,
          s.ConditionKey,
          sc.ConditionText,
          s.IsWarning,
          1,
          s.IsNumber,
          s.IsRequired,
          s.IsAlwaysNull,
          s.IsDate,
          s.IsDateTime,
          s.IsInteger,
          s.IsDecimal,
          s.IsSpaces,
          s.IsOneOfValueSet,
          s.MinDataLength,
          s.MaxDataLength,
          s.MinNumericValue,
          s.MaxNumericValue,
          s.MinDateValue,
          s.MaxDateValue,
          tcdatatype,
          DATEFORMATCHECK
     FROM    TELS_CORE_FieldValidation_Std s
          INNER JOIN
             TELS_CORE_ValidationCondition sc
          ON sc.ConditionKey = s.ConditionKey
    WHERE s.TableName || s.FieldName || s.ConditionKey NOT IN
             (SELECT TableName || FieldName || ConditionKey
                FROM TELS_CORE_FieldValidation_Cust)
   UNION
   SELECT c.TableName,
          c.FieldName,
          c.ConditionKey,
          cc.ConditionText,
          c.IsWarning,
          0,
          c.IsNumber,
          c.IsRequired,
          c.IsAlwaysNull,
          c.IsDate,
          c.IsDateTime,
          c.IsInteger,
          c.IsDecimal,
          c.IsSpaces,
          c.IsOneOfValueSet,
          c.MinDataLength,
          c.MaxDataLength,
          c.MinNumericValue,
          c.MaxNumericValue,
          c.MinDateValue,
          c.MaxDateValue,
          tcdatatype,
          DATEFORMATCHECK
     FROM    TELS_CORE_FieldValidation_Cust c
          INNER JOIN
             TELS_CORE_ValidationCondition cc
          ON cc.ConditionKey = c.ConditionKey;

CREATE OR REPLACE FORCE VIEW TELS_CORE_FIELDVALUESET
(
   TABLENAME,
   FIELDNAME,
   CONDITIONID,
   CONDITION,
   ALLOWEDVALUE,
   ISSTANDARD
)
AS
   SELECT s.TableName,
          s.FieldName,
          s.ConditionKey,
          sc.ConditionText,
          s.AllowedValue,
          1
     FROM    TELS_CORE_FIELDVALUESET_Std s
          INNER JOIN
             TELS_CORE_ValidationCondition sc
          ON sc.ConditionKey = s.ConditionKey
    WHERE s.TableName || s.FieldName || s.ConditionKey NOT IN
             (SELECT TableName || FieldName || ConditionKey
                FROM TELS_CORE_FIELDVALUESET_Cust)
   UNION
   SELECT c.TableName,
          c.FieldName,
          c.ConditionKey,
          cc.ConditionText,
          c.AllowedValue,
          0
     FROM    TELS_CORE_FIELDVALUESET_Cust c
          INNER JOIN
             TELS_CORE_ValidationCondition cc
          ON cc.ConditionKey = c.ConditionKey;

CREATE OR REPLACE FORCE VIEW TELS_CORE_RECORDKEY
(
   TABLENAME,
   FIELDNAMELIST,
   ISPRIMARYRECORDKEY,
   CONDITIONID,
   CONDITION,
   ISSTANDARD
)
AS
   SELECT s.TableName,
          s.FieldNameList,
          s.IsPrimaryRecordKey,
          s.ConditionKey,
          sc.ConditionText,
          1
     FROM    TELS_CORE_RECORDKEY_Std s
          LEFT OUTER JOIN
             TELS_CORE_ValidationCondition sc
          ON sc.ConditionKey = s.ConditionKey
    WHERE s.TableName NOT IN (SELECT TableName FROM TELS_CORE_RECORDKEY_Cust)
   UNION
   SELECT c.TableName,
          c.FieldNameList,
          c.IsPrimaryRecordKey,
          c.ConditionKey,
          sc.ConditionText,
          0
     FROM    TELS_CORE_RECORDKEY_Cust c
          LEFT OUTER JOIN
             TELS_CORE_ValidationCondition sc
          ON sc.ConditionKey = c.ConditionKey;
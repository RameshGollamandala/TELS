--Set Period Override
--UPDATE TELS_PERIOD_OVERRIDE SET PERIOD_NAME = NULL;
--UPDATE TELS_PERIOD_OVERRIDE SET LANDING_DATE = TO_DATE('05/02/2019','DD/MM/YYYY');
--UPDATE TELS_PERIOD_OVERRIDE SET OVERRIDE_TYPE = 'LANDING_DATE';

--Remove the period override
UPDATE TELS_PERIOD_OVERRIDE SET PERIOD_NAME = NULL;
UPDATE TELS_PERIOD_OVERRIDE SET LANDING_DATE = NULL;
UPDATE TELS_PERIOD_OVERRIDE SET OVERRIDE_TYPE = NULL;

COMMIT;
SELECT * FROM TELS_PERIOD_OVERRIDE;
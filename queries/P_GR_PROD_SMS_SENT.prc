/* Formatted on 7/12/2023 7:09:44 PM (QP5 v5.326) */
CREATE OR REPLACE PROCEDURE P_GR_PROD_SMS_SENT (P_COMPANY_NO   NUMBER,
                                                P_DATE         DATE,
                                                P_FORMAT       VARCHAR2)
AS
    CURSOR C1 IS
        SELECT DISTINCT EMP.SMS_MOBILE_NO
          FROM SA_MAILOBJECTIVE    MO,
               SA_MAILUSERGROUP    MUG,
               SA_MAILUSER         MU,
               SA_MAILUSERCOMPANY  MUC,
               SA_EMP_INTERNAL     EMP
         WHERE     MO.MAILOBJECTIVE_NO = MUG.MAILOBJECTIVE_NO
               AND MUG.MAILUSERGROUP_NO = MUC.MAILUSERGROUP_NO
               AND MUG.MAILUSERGROUP_NO = MUC.MAILUSERGROUP_NO
               AND MUC.COMPANY_NO = P_COMPANY_NO
               AND MU.USER_NO = EMP.INT_EMP_NO
               AND EMP.SMS_MOBILE_NO IS NOT NULL
               AND MO.MAILOBJECTIVE_ID = 'PRODUCTION_SMS';

    V_SMS_BODY   VARCHAR2 (4000) := ' ';
    V_SMS_NO     NUMBER (30);
BEGIN
    V_SMS_BODY := F_GR_PROD_SMS_BODY (P_COMPANY_NO, P_DATE, P_FORMAT);

    FOR REC IN C1
    LOOP
        V_SMS_NO := S_GR_SMS.NEXTVAL;

        INSERT INTO GR_SMS (SMS_NO,
                            SMS_ID,
                            MOBILE_NO,
                            SMS_TEXT,
                            COMPANY_NO,
                            SS_CREATED_ON)
             VALUES (V_SMS_NO,
                     V_SMS_NO,
                     REC.SMS_MOBILE_NO,
                     V_SMS_BODY,
                     P_COMPANY_NO,
                     SYSDATE);
    END LOOP;

    COMMIT;
END;
/* Formatted on 12-Jul-23 2:29:02 PM (QP5 v5.326) */

--DROP PROCEDURE P_GR_PROD_SMS_BODY;

CREATE OR REPLACE FUNCTION F_GR_PROD_SMS_BODY (P_COMPANY_NO NUMBER, P_DATE DATE, P_FORMAT VARCHAR2)
RETURN VARCHAR2 
IS

--V_SMS_BODY VARCHAR2(4000);

    CURSOR C1 IS
        SELECT U.USER_FULL_NAME,
               U.EMP_ID,
               U.JOBTITLE,
               UF.SMS_MOBILE_NO,
               UF.INT_EMP_NO     USER_ID
          FROM SA_EMP_INTERNAL UF, GR_USER_V U
         WHERE UF.SMS_MOBILE_NO IS NOT NULL AND UF.INT_EMP_NO = U.USER_NO AND UF.PROD_SMS = 'Y';


    PROD_DATE               DATE := P_DATE;
    DAY_CUTTING             NUMBER := 0;
    MONTH_CUTTING           NUMBER := 0;
    DAY_FORCAST             NUMBER := 0;
    PROD_QTY                NUMBER := 0;
    P_PREV_MONTH            NUMBER := 0;
    P_CURR_MONTH            NUMBER := 0;
    AVG_LINE                NUMBER := 0;
    MSG                     VARCHAR2 (1024) := ' ';
    CN                      NUMBER := 0;
    P_W_HR                  NUMBER := 0;
    P_W_HR_M                NUMBER := 0;
    P_WASH_QTY              NUMBER := 0;
    CNT_PROD_DATE           NUMBER;
    AVG_PROD_SEWING         NUMBER;
    P_DAY_SUB_SEWING        NUMBER;
    P_CUR_MON_SUB_SEWING    NUMBER;
    P_PRD_MON_SUB_SEWING    NUMBER;
    P_DAY_WASH_PROD         NUMBER;
    P_DAY_WASH_PROD_DSFT    NUMBER;
    P_DAY_WASH_PROD_NSFT    NUMBER;
    P_CUR_MON_WASH_PROD     NUMBER;
    P_AV_WASH_PROD          NUMBER;
    P_NO_OF_WASH_PROD_DAY   NUMBER;
    P_PRE_MON_WASH_PROD     NUMBER;
    P_DAY_POLY              NUMBER;
    P_CUR_MON_POLY          NUMBER;
    P_PRE_MON_POLY          NUMBER;
    P_DAY_EXPORT            NUMBER;
    P_CUR_MON_EXPORT        NUMBER;
    P_PRE_MON_EXPORT        NUMBER;
    P_TODAY_EFF             NUMBER;
    P_MONTH_EFF             NUMBER;
    P_WITOUT_DEVLINE        NUMBER;
    P_WITOUT_DEVLINE_MON    NUMBER;
    P_PRE_MONTH_EFF         NUMBER;
    V_COMPANY_ALIAS         VARCHAR2 (100);
    V_WASH_COMPANY_ALIAS    VARCHAR2 (100);
    P_MON_TTL_SHORT         NUMBER;
    P_MON_TTL_EXCESS        NUMBER;
BEGIN

    BEGIN
        ---------------------------------CUTTING----------------------------------------
        BEGIN
            SELECT SUM (CD.CUT_QTY)
              INTO DAY_CUTTING
              FROM GR_CUT  C,
                   (  SELECT CUT_NO, SUM (HS.CUT_QTY) CUT_QTY
                        FROM GR_CUTDTL HS
                    GROUP BY CUT_NO) CD
             WHERE C.CUT_NO = CD.CUT_NO AND TRUNC (C.CUT_DATE) = TRUNC ( P_DATE) AND COMPANY_NO = P_COMPANY_NO;
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        BEGIN
            SELECT SUM (CD.CUT_QTY)
              INTO MONTH_CUTTING
              FROM GR_CUT  C,
                   (  SELECT CUT_NO, SUM (HS.CUT_QTY) CUT_QTY
                        FROM GR_CUTDTL HS
                    GROUP BY CUT_NO) CD
             WHERE     C.CUT_NO = CD.CUT_NO
                   AND TRUNC (C.CUT_DATE) BETWEEN TRUNC ( P_DATE, 'MM') AND TRUNC (TO_DATE ( P_DATE))
                   AND COMPANY_NO = P_COMPANY_NO;
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;


        ---------------------------------Sewing----------------------------------------
        BEGIN
            SELECT PROD_DATE,
                   FORCAST,
                   PROD_QTY,
                   CASE WHEN NVL (TOT_LINE, 0) = 0 THEN 0 ELSE ROUND (PROD_QTY / TOT_LINE) END     AVG_LINE
              INTO PROD_DATE,
                   DAY_FORCAST,
                   PROD_QTY,
                   AVG_LINE
              FROM (  SELECT S.PROD_DATE                    PROD_DATE,
                             COUNT (DISTINCT S.LINE_NO)     TOT_LINE,
                             SUM (S.TARGET)                 FORCAST,
                             SUM (P.PROD_QTY)               PROD_QTY
                        FROM GR_SEWING S,
                             (  SELECT SEWING_NO, SUM (HS.PROD_QTY) PROD_QTY
                                  FROM GR_SEWINGDTL HS
                              GROUP BY SEWING_NO) P
                       WHERE S.SEWING_NO = P.SEWING_NO AND TRUNC (PROD_DATE) = TRUNC ( P_DATE) AND COMPANY_NO = P_COMPANY_NO
                    GROUP BY S.PROD_DATE);
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;


        BEGIN
            SELECT SUM (S.PROD_QTY)
              INTO P_PREV_MONTH
              FROM GR_SEWING I, GR_SEWINGDTL S
             WHERE     I.SEWING_NO = S.SEWING_NO
                   AND TRUNC (I.PROD_DATE) BETWEEN TRUNC (TRUNC ( P_DATE, 'MONTH') - 1, 'MONTH') AND TRUNC ( P_DATE, 'MONTH') - 1
                   AND I.COMPANY_NO = P_COMPANY_NO;
        EXCEPTION
            WHEN OTHERS
            THEN
                P_PREV_MONTH := 0;
        END;

        BEGIN
            SELECT SUM (S.PROD_QTY)
              INTO P_CURR_MONTH
              FROM GR_SEWING I, GR_SEWINGDTL S
             WHERE     I.SEWING_NO = S.SEWING_NO
                   AND TRUNC (I.PROD_DATE) BETWEEN TRUNC ( P_DATE, 'MONTH') AND TRUNC ( P_DATE)
                   AND I.COMPANY_NO = P_COMPANY_NO;
        EXCEPTION
            WHEN OTHERS
            THEN
                P_CURR_MONTH := 0;
        END;


        BEGIN
            SELECT COUNT (PROD_DATE)     CNT
              INTO CNT_PROD_DATE
              FROM (  SELECT PROD_DATE, SUM (HS.PROD_QTY) PROD_QTY
                        FROM GR_SEWING I, GR_SEWINGDTL HS
                       WHERE     I.SEWING_NO = HS.SEWING_NO
                             AND TRUNC (PROD_DATE) BETWEEN TRUNC ( P_DATE, 'MONTH') AND TRUNC ( P_DATE)
                             AND I.COMPANY_NO = P_COMPANY_NO
                    GROUP BY PROD_DATE
                      HAVING SUM (HS.PROD_QTY) > 0);

            AVG_PROD_SEWING := ROUND (P_CURR_MONTH / CNT_PROD_DATE);
        EXCEPTION
            WHEN OTHERS
            THEN
                AVG_PROD_SEWING := 0;
        END;



        BEGIN
            P_W_HR := F_GR_WORK_HR ( P_COMPANY_NO, P_DATE);
        EXCEPTION
            WHEN OTHERS
            THEN
                P_W_HR := 0;
        END;


        BEGIN
            P_W_HR_M := F_GR_AVG_WORK_HR ( P_COMPANY_NO, TRUNC ( P_DATE, 'MONTH'), P_DATE);
        EXCEPTION
            WHEN OTHERS
            THEN
                P_W_HR_M := 0;
        END;


        BEGIN
            SELECT ISSUE_QTY
              INTO P_WASH_QTY
              FROM (SELECT SUM (AD.ISSUE_QTY)     ISSUE_QTY
                      FROM GR_ARTWORK A, GR_ARTWORKDTL AD
                     WHERE     A.ARTWORK_NO = AD.ARTWORK_NO
                           AND TO_DATE (A.ARTWORK_DATE) = TO_DATE ( P_DATE)
                           AND A.COMPANY_NO = P_COMPANY_NO
                           AND A.TRN_FLAG = 1);
        EXCEPTION
            WHEN OTHERS
            THEN
                P_PREV_MONTH := 0;
        END;

        ----------------------------------------Subcontract production------------------

        BEGIN
            SELECT SUM (SB.SEWING_QTY)
              INTO P_DAY_SUB_SEWING
              FROM GR_PRODSUBCONTRACT SB
             WHERE TRUNC (PROD_DATE) = TRUNC ( P_DATE) AND SB.COMPANY_NO = P_COMPANY_NO;
        EXCEPTION
            WHEN OTHERS
            THEN
                P_DAY_SUB_SEWING := 0;
        END;


        BEGIN
            SELECT SUM (SB.SEWING_QTY)
              INTO P_CUR_MON_SUB_SEWING
              FROM GR_PRODSUBCONTRACT SB
             WHERE TRUNC (PROD_DATE) BETWEEN TRUNC ( P_DATE, 'MONTH') AND TRUNC ( P_DATE) AND SB.COMPANY_NO = P_COMPANY_NO;
        EXCEPTION
            WHEN OTHERS
            THEN
                P_CUR_MON_SUB_SEWING := 0;
        END;

        BEGIN
            SELECT SUM (SB.SEWING_QTY)
              INTO P_PRD_MON_SUB_SEWING
              FROM GR_PRODSUBCONTRACT SB
             WHERE     TRUNC (PROD_DATE) BETWEEN TRUNC (TRUNC ( P_DATE, 'MONTH') - 1, 'MONTH') AND TRUNC ( P_DATE, 'MONTH') - 1
                   AND SB.COMPANY_NO = P_COMPANY_NO;
        EXCEPTION
            WHEN OTHERS
            THEN
                P_PRD_MON_SUB_SEWING := 0;
        END;


        ------------------Washing--------------------------


        BEGIN
            SELECT SUM (NVL (FB.PROD_QTY, 0) - NVL (FB.REWASH_QTY, 0))
              INTO P_DAY_WASH_PROD
              FROM GR_WASH FB, GR_WASH_FINAL_PROCESS_V FP
             WHERE     FB.WASHJOBCOLOR_NO = FP.WASHJOBCOLOR_NO
                   AND FB.WASHPROCESS_NO = FP.WASHPROCESS_NO
                   AND TRUNC (PROD_DATE) = TRUNC ( P_DATE)
                   AND FB.COMPANY_NO = P_COMPANY_NO;
        EXCEPTION
            WHEN OTHERS
            THEN
                P_DAY_WASH_PROD := 0;
        END;


        BEGIN
            SELECT SUM (NVL (WP.PROD_QTY, 0) - NVL (WP.REWASH_QTY, 0))
              INTO P_DAY_WASH_PROD_DSFT
              FROM GR_WASH WP, GR_WASH_FINAL_PROCESS_V FP
             WHERE     WP.WASHJOBCOLOR_NO = FP.WASHJOBCOLOR_NO
                   AND TRUNC (WP.PROD_DATE) = TRUNC ( P_DATE)
                   AND WP.SHIFT_NO = 11
                   AND WP.WASHPROCESS_NO = FP.WASHPROCESS_NO
                   AND WP.COMPANY_NO = P_COMPANY_NO;
        EXCEPTION
            WHEN OTHERS
            THEN
                P_DAY_WASH_PROD_DSFT := 0;
        END;


        BEGIN
            SELECT SUM (NVL (WP.PROD_QTY, 0) - NVL (REWASH_QTY, 0))
              INTO P_DAY_WASH_PROD_NSFT
              FROM GR_WASH WP, GR_WASH_FINAL_PROCESS_V FP
             WHERE     WP.WASHJOBCOLOR_NO = FP.WASHJOBCOLOR_NO
                   AND TRUNC (WP.PROD_DATE) = TRUNC ( P_DATE)
                   AND WP.SHIFT_NO = 10
                   AND WP.WASHPROCESS_NO = FP.WASHPROCESS_NO
                   AND WP.COMPANY_NO = P_COMPANY_NO;
        EXCEPTION
            WHEN OTHERS
            THEN
                P_DAY_WASH_PROD_NSFT := 0;
        END;

        BEGIN
            SELECT SUM (NVL (SB.PROD_QTY, 0) - NVL (SB.REWASH_QTY, 0))
              INTO P_CUR_MON_WASH_PROD
              FROM GR_WASH SB, GR_WASH_FINAL_PROCESS_V FP
             WHERE     SB.WASHJOBCOLOR_NO = FP.WASHJOBCOLOR_NO
                   AND SB.WASHPROCESS_NO = FP.WASHPROCESS_NO
                   AND TRUNC (PROD_DATE) BETWEEN TRUNC ( P_DATE, 'MONTH') AND TRUNC ( P_DATE)
                   AND SB.COMPANY_NO = P_COMPANY_NO;
        EXCEPTION
            WHEN OTHERS
            THEN
                P_CUR_MON_WASH_PROD := 0;
        END;


        BEGIN
            SELECT COUNT (*)
              INTO P_NO_OF_WASH_PROD_DAY
              FROM (  SELECT SB.PROD_DATE, SUM (NVL (SB.PROD_QTY, 0) - NVL (SB.REWASH_QTY, 0))
                        FROM GR_WASH SB, GR_WASH_FINAL_PROCESS_V FP
                       WHERE     SB.WASHJOBCOLOR_NO = FP.WASHJOBCOLOR_NO
                             AND SB.WASHPROCESS_NO = FP.WASHPROCESS_NO
                             AND TRUNC (PROD_DATE) BETWEEN TRUNC ( P_DATE, 'MONTH') AND TRUNC ( P_DATE)
                             AND SB.COMPANY_NO = P_COMPANY_NO
                    GROUP BY SB.PROD_DATE
                      HAVING SUM (NVL (SB.PROD_QTY, 0) - NVL (SB.REWASH_QTY, 0)) > 0);

            IF NVL (P_NO_OF_WASH_PROD_DAY, 0) > 0
            THEN
                P_AV_WASH_PROD := ROUND (P_CUR_MON_WASH_PROD / P_NO_OF_WASH_PROD_DAY);
            ELSE
                P_AV_WASH_PROD := 0;
            END IF;
        EXCEPTION
            WHEN OTHERS
            THEN
                P_AV_WASH_PROD := 0;
        END;


        BEGIN
            SELECT SUM (NVL (SB.PROD_QTY, 0) - NVL (SB.REWASH_QTY, 0))
              INTO P_PRE_MON_WASH_PROD
              FROM GR_WASH SB, GR_WASH_FINAL_PROCESS_V FP
             WHERE     SB.WASHJOBCOLOR_NO = FP.WASHJOBCOLOR_NO
                   AND SB.WASHPROCESS_NO = FP.WASHPROCESS_NO
                   AND SB.COMPANY_NO = P_COMPANY_NO
                   AND TRUNC (PROD_DATE) BETWEEN TRUNC (TRUNC ( P_DATE, 'MONTH') - 1, 'MONTH') AND TRUNC ( P_DATE, 'MONTH') - 1;
        EXCEPTION
            WHEN OTHERS
            THEN
                P_PRE_MON_WASH_PROD := 0;
        END;



        ------------------Finishing production------------------
        BEGIN
            SELECT SUM (F.OUTPUT_QTY)
              INTO P_DAY_POLY
              FROM GR_FINISHING F
             WHERE TRUNC (F.PROD_DATE) = TRUNC ( P_DATE) AND F.COMPANY_NO = P_COMPANY_NO;
        EXCEPTION
            WHEN OTHERS
            THEN
                P_DAY_POLY := 0;
        END;


        BEGIN
            SELECT SUM (F.OUTPUT_QTY)
              INTO P_CUR_MON_POLY
              FROM GR_FINISHING F
             WHERE TRUNC (PROD_DATE) BETWEEN TRUNC ( P_DATE, 'MONTH') AND TRUNC ( P_DATE) AND F.COMPANY_NO = P_COMPANY_NO;
        EXCEPTION
            WHEN OTHERS
            THEN
                P_CUR_MON_POLY := 0;
        END;



        BEGIN
            SELECT SUM (F.OUTPUT_QTY)
              INTO P_PRE_MON_POLY
              FROM GR_FINISHING F
             WHERE     TRUNC (PROD_DATE) BETWEEN TRUNC (TRUNC ( P_DATE, 'MONTH') - 1, 'MONTH') AND TRUNC ( P_DATE, 'MONTH') - 1
                   AND F.COMPANY_NO = P_COMPANY_NO;
        EXCEPTION
            WHEN OTHERS
            THEN
                P_PRE_MON_POLY := 0;
        END;

        --------------------------------Export-----------------------------------------------------------

        BEGIN
            SELECT SUM (ED.EXFACT_QTY)
              INTO P_DAY_EXPORT
              FROM GR_EXFACT E, GR_EXFACTDTL ED
             WHERE E.EXFACT_NO = ED.EXFACT_NO AND TRUNC (E.CHALLAN_DATE) = TRUNC ( P_DATE) AND E.COMPANY_NO = P_COMPANY_NO;
        EXCEPTION
            WHEN OTHERS
            THEN
                P_DAY_EXPORT := 0;
        END;


        BEGIN
            SELECT SUM (ED.EXFACT_QTY)
              INTO P_CUR_MON_EXPORT
              FROM GR_EXFACT E, GR_EXFACTDTL ED
             WHERE     E.EXFACT_NO = ED.EXFACT_NO
                   AND TRUNC (E.CHALLAN_DATE) BETWEEN TRUNC ( P_DATE, 'MONTH') AND TRUNC ( P_DATE)
                   AND E.COMPANY_NO = P_COMPANY_NO;
        EXCEPTION
            WHEN OTHERS
            THEN
                P_CUR_MON_EXPORT := 0;
        END;

        ------------------------MONTH TOTOAL EXCESS QTY----------------------------------------------------
        BEGIN
            SELECT SUM (ED.EXCESS_QTY)
              INTO P_MON_TTL_EXCESS
              FROM GR_EXFACT E, GR_EXFACTDTL ED
             WHERE     E.EXFACT_NO = ED.EXFACT_NO
                   AND TRUNC (E.CHALLAN_DATE) BETWEEN TRUNC ( P_DATE, 'MM') AND TRUNC (TO_DATE ( P_DATE))
                   AND E.COMPANY_NO = P_COMPANY_NO;
        EXCEPTION
            WHEN OTHERS
            THEN
                P_MON_TTL_EXCESS := 0;
        END;

        ------------------------MONTH TOTOAL SHORT QTY----------------------------------------------------

        BEGIN
            SELECT SUM (ED.SHORT_QTY)
              INTO P_MON_TTL_SHORT
              FROM GR_EXFACT E, GR_EXFACTDTL ED
             WHERE     E.EXFACT_NO = ED.EXFACT_NO
                   AND TRUNC (E.CHALLAN_DATE) BETWEEN TRUNC ( P_DATE, 'MM') AND TRUNC (TO_DATE ( P_DATE))
                   AND E.COMPANY_NO = P_COMPANY_NO;
        EXCEPTION
            WHEN OTHERS
            THEN
                P_MON_TTL_SHORT := 0;
        END;

        ----------------------------------------------------------

        BEGIN
            SELECT SUM (ED.EXFACT_QTY)
              INTO P_PRE_MON_EXPORT
              FROM GR_EXFACT E, GR_EXFACTDTL ED
             WHERE     E.EXFACT_NO = ED.EXFACT_NO
                   AND TRUNC (E.CHALLAN_DATE) BETWEEN TRUNC (TRUNC ( P_DATE, 'MONTH') - 1, 'MONTH') AND TRUNC ( P_DATE, 'MONTH') - 1
                   AND E.COMPANY_NO = P_COMPANY_NO;
        EXCEPTION
            WHEN OTHERS
            THEN
                P_PRE_MON_EXPORT := 0;
        END;

        BEGIN
            P_TODAY_EFF :=
                F_GR_PROD_EFFICIENCY ( P_COMPANY_NO,
                                      TRUNC ( P_DATE),
                                      TRUNC ( P_DATE),
                                      NULL);
            P_MONTH_EFF :=
                F_GR_PROD_EFFICIENCY ( P_COMPANY_NO,
                                      TRUNC ( P_DATE, 'MONTH'),
                                      TRUNC ( P_DATE),
                                      NULL);
            P_WITOUT_DEVLINE :=
                F_GR_EFFICIENCY_WITOUTDEVLINE ( P_COMPANY_NO,
                                               TRUNC ( P_DATE),
                                               TRUNC ( P_DATE),
                                               NULL);

            P_WITOUT_DEVLINE_MON :=
                F_GR_EFFI_WITOUTDEVLINE_MON ( P_COMPANY_NO,
                                             TRUNC ( P_DATE),
                                             TRUNC ( P_DATE),
                                             NULL);



            P_PRE_MONTH_EFF :=
                F_GR_PROD_EFFICIENCY ( P_COMPANY_NO,
                                      TRUNC ((TRUNC ( P_DATE, 'MONTH') - 1), 'MONTH'),
                                      (TRUNC ( P_DATE, 'MONTH') - 1),
                                      NULL);
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        ---------------------------------------------------------------------------------------------------------------

        -- MSG := 'Sewing Date:'||PROD_DATE||'; Day Forcast:'||DAY_FORCAST||'; Total Prod:'||PROD_QTY||'; AVG/Line:'||AVG_LINE||'; Month Total:'||P_CURR_MONTH||'; Last Month:'||P_PREV_MONTH||'(SMS Generated by ERP)';
        BEGIN
            SELECT COMPANY_ALIAS
              INTO V_COMPANY_ALIAS
              FROM SA_COMPANY
             WHERE COMPANY_NO = P_COMPANY_NO;
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        BEGIN
            SELECT COMPANY_ALIAS
              INTO V_WASH_COMPANY_ALIAS
              FROM SA_COMPANY
             WHERE COMPANY_NO = P_COMPANY_NO;
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

--        IF :BUTTON.TEXT_FORMATE = 1
--        THEN
--            MSG :=                                                                              ---------------Sewing---------------------------------
--                   V_COMPANY_ALIAS
--                || 'Production :'
--                || CHR (10)
--                || 'Dt:'
--                || PROD_DATE
--                || ';'
--                || CHR (10)
--                || 'Day Cutting:'
--                || DAY_CUTTING
--                || ';'
--                || CHR (10)
--                || 'Month TTL Cutting:'
--                || MONTH_CUTTING
--                || ';'
--                || CHR (10)
--                || 'Day Sewing Forcast:'
--                || DAY_FORCAST
--                || ';'
--                || CHR (10)
--                || 'Day Sewing Prod:'
--                || PROD_QTY
--                || ';'
--                || CHR (10)
--                || 'Avg/Line:'
--                || AVG_LINE
--                || ';'
--                || CHR (10)
--                || 'Avg W.Hr:'
--                || P_W_HR
--                || ';'
--                || CHR (10)
--                || 'Effi.(%):'
--                || P_WITOUT_DEVLINE
--                || ';'
--                || CHR (10)
--                || 'Avg Effi.(%):'
--                || P_WITOUT_DEVLINE_MON
--                || ';'
--                || CHR (10)
--                || 'Wash Send:'
--                || P_WASH_QTY
--                || ';'
--                || CHR (10)
--                || 'Month TTL:'
--                || P_CURR_MONTH
--                || ';'
--                || CHR (10)
--                || 'Month Avg W.Hr:'
--                || P_W_HR_M
--                || ';'
--                || CHR (10)
--                || 'Avg/Per Day:'
--                || AVG_PROD_SEWING
--                || ';'
--                || CHR (10)
--                || 'Last Month:'
--                || P_PREV_MONTH
--                || ';'
--                || CHR (10)
--                || 'Last Month Sewing Eff (%):'
--                || P_PRE_MONTH_EFF
--                || ';'
--                || CHR (10)
--                ----------------Subcontract--------------------------------
--                || 'Subcontract Prod Info:'
--                || CHR (10)
--                || 'Day Sewing Prod:'
--                || P_DAY_SUB_SEWING
--                || ';'
--                || CHR (10)
--                || 'Month TTL:'
--                || P_CUR_MON_SUB_SEWING
--                || ';';
--
--            -----------------Wash Prod-------------------------------
--            IF P_COMPANY_NO IS NOT NULL
--            THEN
--                MSG :=
--                       MSG
--                    || CHR (10)
--                    || V_WASH_COMPANY_ALIAS
--                    || ' Wash Prod Info:'
--                    || CHR (10)
--                    || 'Day Shift:'
--                    || P_DAY_WASH_PROD_DSFT
--                    || ';'
--                    || CHR (10)
--                    || 'Night Shift:'
--                    || P_DAY_WASH_PROD_NSFT
--                    || ';'
--                    || CHR (10)
--                    || 'Day TTL:'
--                    || P_DAY_WASH_PROD
--                    || ';'
--                    || CHR (10)
--                    || 'Month TTL:'
--                    || P_CUR_MON_WASH_PROD
--                    || ';'
--                    || CHR (10)
--                    || 'Avg/Per Day:'
--                    || P_AV_WASH_PROD
--                    || ';'
--                    || CHR (10)
--                    || 'Last Month:'
--                    || P_PRE_MON_WASH_PROD
--                    || ';';
--            END IF;
--
--            MSG :=
--                   MSG
--                || CHR (10)
--                -------------------Finishing Prod-----------------------------
--                || 'Finishing Prod:'
--                || CHR (10)
--                || 'Day Poly:'
--                || P_DAY_POLY
--                || ';'
--                || CHR (10)
--                || 'Month TTL:'
--                || P_CUR_MON_POLY
--                || ';'
--                || CHR (10)
--                -------------------Export Info-----------------------------
--                || 'Export Info:'
--                || CHR (10)
--                || 'Day Export:'
--                || P_DAY_EXPORT
--                || ';'
--                || CHR (10)
--                || 'Month TTL Export:'
--                || P_CUR_MON_EXPORT
--                || ';'
--                || CHR (10)
--                || 'Month TTL Excess Ship Qty :'
--                || P_MON_TTL_EXCESS
--                || ';'
--                || CHR (10)
--                || 'Month TTL Short Ship Qty :'
--                || P_MON_TTL_SHORT
--                || ';'
--                || CHR (10)
--                || '(SMS by ERP)';
--        ELSE
--END IF;
            MSG :=                                                                              ---------------Sewing---------------------------------
                   V_COMPANY_ALIAS
                || 'Production :'
                || CHR (10)
                || 'Dt:'
                || PROD_DATE
                || ';'
                || CHR (10)
                || 'Day Cutting:'
                || DAY_CUTTING
                || ';'
                || CHR (10)
                || 'Day Sewing Target:'
                || DAY_FORCAST
                || ';'
                || CHR (10)
                || 'Day Sewing Prod:'
                || PROD_QTY
                || ';'
                || CHR (10)
                || 'Avg W.Hr:'
                || P_W_HR
                || ';'
                || CHR (10)
                || 'Effi.(%):'
                || P_WITOUT_DEVLINE
                || ';'
                || CHR (10)
                || 'Wash Send:'
                || P_WASH_QTY
                || ';'
                || CHR (10)
                -------------------Finishing Prod-----------------------------
                || 'Day Poly:'
                || P_DAY_POLY
                || ';'
                || CHR (10)
                -------------------Export Info-----------------------------
                || 'Day Export:'
                || P_DAY_EXPORT
                || ';'
                || CHR (10)
                || '(SMS by ERP)';

RETURN MSG;

    EXCEPTION
        WHEN OTHERS
        THEN
            NULL;
            --P_MESSAGE (SQLERRM); EXCEPTION DECLARE
    END;

EXCEPTION
    WHEN OTHERS
    THEN
        NULL;
END;
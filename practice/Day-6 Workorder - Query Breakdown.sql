-- SUB QUERY - 1
SELECT WD.PREQDTL_NO, WD.WODTL_NO, TD.TRND_NO, WD.ORDER_QTY, TD.RCV_QTY, SUM(BD.BILL_QTY) BILL_QTY
FROM IN_WORKORDERDTL WD, IN_TRNDTL TD, IN_BILLDTL BD
    WHERE WD.WODTL_NO = TD.WODTL_NO (+)
    AND TD.TRND_NO = BD.TRND_NO (+)
    AND WD.PREQDTL_NO IS NOT NULL
GROUP BY WD.PREQDTL_NO, WD.WODTL_NO, TD.TRND_NO, WD.ORDER_QTY, TD.RCV_QTY;

-- SUB QUERY - 2
SELECT PREQDTL_NO, WODTL_NO, ORDER_QTY, SUM(RCV_QTY) RCV_QTY, SUM(BILL_QTY) BILL_QTY
FROM (
    ====== SUB QUERY - 1 =======
)
GROUP BY PREQDTL_NO, WODTL_NO, ORDER_QTY;

-- SUB QUERY -3
SELECT PREQDTL_NO, SUM(ORDER_QTY) WO_QTY, SUM(RCV_QTY) RCV_QTY, SUM(BILL_QTY) BILL_QTY
FROM (
    ====== SUB QUERY - 2 =======
)
GROUP BY PREQDTL_NO;


----------------------- FINAL QUERY ---------------------------
SELECT PREQDTL_NO, SUM(ORDER_QTY) WO_QTY, SUM(RCV_QTY) RCV_QTY, SUM(BILL_QTY) BILL_QTY
FROM (
    SELECT PREQDTL_NO, WODTL_NO, ORDER_QTY, SUM(RCV_QTY) RCV_QTY, SUM(BILL_QTY) BILL_QTY
    FROM (
        SELECT WD.PREQDTL_NO, WD.WODTL_NO, TD.TRND_NO, WD.ORDER_QTY, TD.RCV_QTY, SUM(BD.BILL_QTY) BILL_QTY
        FROM IN_WORKORDERDTL WD, IN_TRNDTL TD, IN_BILLDTL BD
            WHERE WD.WODTL_NO = TD.WODTL_NO (+)
            AND TD.TRND_NO = BD.TRND_NO (+)
            AND WD.PREQDTL_NO IS NOT NULL
        GROUP BY WD.PREQDTL_NO, WD.WODTL_NO, TD.TRND_NO, WD.ORDER_QTY, TD.RCV_QTY
    )
    GROUP BY PREQDTL_NO, WODTL_NO, ORDER_QTY
)
GROUP BY PREQDTL_NO;

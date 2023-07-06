/* Formatted on 6/25/2023 4:20:34 PM (QP5 v5.326) */
--  SELECT TRND_NO,COUNT(1)
--  FROM
--  (

  SELECT PREQDTL_NO,
         SUM (ORDER_QTY)     ORDER_QTY,
         SUM (RCV_QTY)       RCV_QTY,
         SUM (BILL_QTY)      BILL_QTY
    FROM (  SELECT PREQDTL_NO,
                   WODTL_NO,
                   ORDER_QTY,
                   SUM (RCV_QTY)      RCV_QTY,
                   SUM (BILL_QTY)     BILL_QTY
              FROM (  SELECT WD.PREQDTL_NO,
                             WD.WODTL_NO,
                             TD.TRND_NO,
                             (WD.ORDER_QTY)     ORDER_QTY,
                             (RCV_QTY)          RCV_QTY,
                             SUM (BILL_QTY)     BILL_QTY
                        FROM IN_WORKORDERDTL WD, IN_TRNDTL TD, IN_BILLDTL bd
                       WHERE     WD.WODTL_NO = TD.WODTL_NO(+)
                             AND TD.TRND_NO = bd.TRND_NO(+)
                             AND WD.PREQDTL_NO IS NOT NULL
                    GROUP BY WD.PREQDTL_NO,
                             WD.WODTL_NO,
                             TD.TRND_NO,
                             (WD.ORDER_QTY),
                             (RCV_QTY))
          GROUP BY PREQDTL_NO, WODTL_NO, ORDER_QTY)
GROUP BY PREQDTL_NO
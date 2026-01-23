USE ETB_TEST;
GO
--get all finished goods from sales history
;WITH ALLFinishedStockCode AS
( 
SELECT 
A.StockCode,
A.Customer,
B.FcstWhse,
SUM(A.QtyInvoiced) as QTYInvoiced
FROM ArTrnDetail A
INNER JOIN [ArCustomer+] B 
ON A.Customer = B.Customer
WHERE A.StockCode <>'' AND B.FcstWhse <> '' AND ProductClass IN ('REG','SRF','NEW','PRMO','PRMI','OTRF','DISC','DSP')
GROUP BY A.StockCode, A.Customer, B.FcstWhse 
)

--compare sales history item with the items in Iopwarehouse table to find missing items
SELECT 
A.Customer,
A.FcstWhse,
A.StockCode AS Invoiced_StockCode,
A.QTYInvoiced,
I.StockCode AS StockCode_IopWh
FROM ALLFinishedStockCode A
LEFT JOIN dbo.IopWarehouse I
ON A.FcstWhse = I.Warehouse AND A.StockCode = I.StockCode 
WHERE I.StockCode IS NULL
ORDER BY I.StockCode, A.FcstWhse

;


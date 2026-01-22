SELECT StockCode,B.FcstWhse,SUM(QtyInvoiced) FROM ArTrnDetail A
INNER JOIN [ArCustomer+] B 
ON A.Customer =B.Customer
WHERE A.StockCode <>'' AND B.FcstWhse <> '' AND ProductClass IN ('REG','SRF','NEW','PRMO','PRMI','OTRF','DISC','DSP')
GROUP BY A.StockCode, B.FcstWhse
ORDER BY FcstWhse

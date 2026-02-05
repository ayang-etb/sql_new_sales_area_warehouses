USE [ETB_TEST]
GO
/****** Object:  StoredProcedure [dbo].[uspLoadSalesHistory]    Script Date: 1/21/2026 9:20:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/**********************************************************************************************************
****COFFE MUG****

Customer:	ET Browne
Purpose:	Load InvMovements data into dummy forecast warehouse
Date:		15 January 2021
Version:	1.0
Author:		Simon Conradie
Date:		9 February 2021
Change:		Updated with Custom Form Fields
Version:	1.1
Date:		19 April 2021
Change:		Changed logic to clear and load history only for the month before current.
Version:	1.2
Date:		22 April 2021
Change:		Changed logic to clear and load history only for the month before current. For real this time
Version:	1.3
Author:		Sean Hare
Date:		28 July 2021
Change:		Group Movements to the 1st of the Month
Version:	1.4
Author:		Sean Hare
Date:		01 December 2021
Change:		Add Lost Sales to IopSalesAdjust, Zero out prior months draft forecast, Update Freeze Periods Current month plus 5
Version:	1.5
Author:		Sean Hare
Date:		05 April 2022
Change:		Modified the LostSales Logic
Version:	1.6
Author:		Sean Hare
This script loads sales into dummy warehouses

**********************************************************************************************************/

--	1. Setup. 
--	1a. Set start and end dates for clearing and adding history. This is set to be the month prior to current 
--	If there is a need to reload the history completely due to changes in customer mapping, then the '- 1' in the calculation 
--	of @DateStart should be changed to '- 36' to replace all the history within a 3 year window.

DECLARE @DateStart date = DATEADD(MONTH, DATEDIFF(MONTH, '19000101', GETDATE()) - 36, '19000101'),
        @DateEnd date = DATEADD(D, -1, DATEADD(MONTH, DATEDIFF(MONTH, '19000101', GETDATE()), '19000101'))

--SELECT
--  @DateStart AS 'Start Date',
--  @DateEnd AS 'End Date'

--	1b. Clear out all previous history. This is held in IopSalesAdjust with 
--	EntryNumber = 800
DELETE FROM dbo.IopSalesAdjust
WHERE EntryNumber IN (800,999)
  AND MovementDate BETWEEN @DateStart AND @DateEnd

/*
DELETE FROM dbo.IopSalesAdjust
WHERE EntryNumber NOT IN (800,999)
  AND MovementDate BETWEEN @DateStart AND @DateEnd
*/

CREATE TABLE #FcWarehouse (
  StockCode varchar(30) COLLATE DATABASE_DEFAULT,
  Warehouse varchar(10) COLLATE DATABASE_DEFAULT,
  ItemCount int,
  UnitCost decimal(15, 5),
  PRIMARY KEY
  (
  StockCode, Warehouse
  )
)

--	Load Sales at Co Level from InvMovements and load them into IopSalesAdjust
--	EntryNumber = 800 (MovementType 'S')
INSERT INTO dbo.IopSalesAdjust (
  StockCode
, Version
, Release
, Warehouse
, MovementDate
, EntryNumber
, AdjustType
, Quantity
, SalesValue
, CostValue
, Comment
)
  SELECT
    imas.StockCode,
    imas.Version,
    imas.Release,
    'zz-TotalCo' AS 'Warehouse',
	  --EntryDate,
    --@DateStart as EntryDate,
    --Alex added below line for the entry date creation and commented out the line above 
    DATEFROMPARTS(YEAR(imov.EntryDate), MONTH(imov.EntryDate), 1) AS EntryDate,
    800 AS EntryNumber,
    'A' AS AdjustType,
    SUM(TrnQty) AS Quantity,
    SUM(TrnValue) AS SalesValue,
    SUM(CostValue) AS CostValue,
    'Sales' AS Comment
  FROM dbo.InvMaster AS imas WITH (NOLOCK)
  JOIN dbo.InvMovements AS imov WITH (NOLOCK)
    ON imas.StockCode = imov.StockCode
  WHERE MovementType = 'S'
  --AND EntryDate > @DateStart
  AND EntryDate BETWEEN @DateStart AND @DateEnd
  GROUP BY imas.StockCode,
           imas.Version,
           imas.Release,
           --,
           --imov.EntryDate
           --ALEX added below line
           DATEFROMPARTS(YEAR(imov.EntryDate), MONTH(imov.EntryDate), 1)

--	Load Sales at Dummy Forecast Wh Level from InvMovements and load them into IopSalesAdjust
--	EntryNumber = 800 (MovementType 'S')
INSERT INTO dbo.IopSalesAdjust (
StockCode,
Version,
Release,
Warehouse,
MovementDate,
EntryNumber,
AdjustType,
Quantity,
SalesValue,
CostValue,
Comment
)
  SELECT
    imov.StockCode,
    imov.Version,
    imov.Release,
    acus.FcstWhse AS 'Warehouse',
    --EntryDate,
	  --@DateStart AS EntryDate,
    --Alex added below line for the entry date creation and commented out the line above 
    DATEFROMPARTS(YEAR(imov.EntryDate), MONTH(imov.EntryDate), 1) AS EntryDate,
    800 AS EntryNumber,
    'A' AS AdjustType,
    SUM(TrnQty) AS Quantity,
    SUM(TrnValue) AS SalesValue,
    SUM(CostValue) AS CostValue,
    'Sales' AS Comment
  FROM dbo.InvMovements AS imov WITH (NOLOCK)
  JOIN dbo.[ArCustomer+] AS acus WITH (NOLOCK)
    ON imov.Customer = acus.Customer
  WHERE MovementType = 'S'
  --AND EntryDate > @DateStart
  AND EntryDate BETWEEN @DateStart AND @DateEnd
  GROUP BY imov.StockCode,
           imov.Version,
           imov.Release,
           acus.FcstWhse,
           --,
           --imov.EntryDate
           --ALEX added below line
           DATEFROMPARTS(YEAR(imov.EntryDate), MONTH(imov.EntryDate), 1)

--	Load Lost Sales at Dummy Forecast Wh Level from SorLostSales and load them into IopSalesAdjust
INSERT INTO dbo.IopSalesAdjust (
  StockCode
, Version
, Release
, Warehouse
, MovementDate
, EntryNumber
, AdjustType
, Quantity
, SalesValue
, CostValue
, Comment
, LostTrnDate )
SELECT
    sor.StockCode,
    sor.Version,
    sor.Release,
    acus.FcstWhse AS 'Warehouse',
    --EntryDate,
    --sor.TrnDate as MovementDate,
    --@DateStart as MovementDate,
    --Alex added below line for the entry date creation and commented out the line above
    DATEFROMPARTS(YEAR(sor.TrnDate), MONTH(sor.TrnDate), 1) AS MovementDate,
    999 AS EntryNumber,
    'L' AS AdjustType,
	CASE 
		WHEN acus.FcstWhse like 'z0%' THEN SUM(sor.QuantityLost * 0.25)
		ELSE SUM(sor.QuantityLost) 
    END AS Quantity,
	CASE 
		WHEN acus.FcstWhse like 'z0%' THEN SUM(sor.LostSaleValue * 0.25)
		ELSE SUM(sor.LostSaleValue) 
    END AS SalesValue,
	CASE 
		WHEN acus.FcstWhse like 'z0%' THEN SUM(sor.CostValue * 0.25)
		ELSE SUM(sor.CostValue) 
    END AS CostValue,
    'NO STOCK ON HAND' AS Comment,
    --sor.TrnDate as LosTrnDate
	@DateStart AS LostTrnDate
  FROM dbo.SorLostSales sor
  JOIN dbo.[ArCustomer+] AS acus (NOLOCK)
    ON sor.Customer = acus.Customer
  WHERE acus.FcstWhse IS NOT NULL
  AND sor.TrnDate BETWEEN @DateStart AND @DateEnd
  GROUP BY sor.StockCode,
           sor.Version,
           sor.Release,
           acus.FcstWhse,
           --sor.TrnDate
           DATEFROMPARTS(YEAR(sor.TrnDate), MONTH(sor.TrnDate), 1)
          

--Add records to InvWarehouse where these do not exist
--Extract unique StockCode instances for each customer warehouse
INSERT INTO #FcWarehouse (StockCode
, Warehouse
, ItemCount)
  SELECT
    StockCode,
    Warehouse,
    COUNT(EntryNumber) AS ItemCount
  FROM dbo.IopSalesAdjust(nolock)
  WHERE Warehouse LIKE 'z%'
  GROUP BY StockCode,
           Warehouse
  --ORDER BY StockCode, Warehouse

-- Add missing records to InvWarehouse
INSERT INTO dbo.InvWarehouse (StockCode
, Warehouse)
  SELECT
    twar.StockCode,
    twar.Warehouse
  FROM #FcWarehouse AS twar (NOLOCK)
  LEFT OUTER JOIN dbo.InvWarehouse AS iwar (NOLOCK)
    ON twar.StockCode = iwar.StockCode
    AND twar.Warehouse = iwar.Warehouse
  WHERE iwar.StockCode IS NULL

-- Update UnitCost for forecasting warehouses
UPDATE #FcWarehouse
SET UnitCost = iwar.UnitCost
FROM dbo.InvWarehouse AS iwar (NOLOCK)
JOIN dbo.InvMaster AS imas (NOLOCK)
  ON iwar.StockCode = imas.StockCode
JOIN #FcWarehouse AS twar (NOLOCK)
  ON iwar.StockCode = twar.StockCode
  AND imas.WarehouseToUse = iwar.Warehouse

UPDATE InvWarehouse
SET UnitCost = twar.UnitCost
FROM #FcWarehouse AS twar (NOLOCK)
JOIN dbo.InvWarehouse AS iwar (NOLOCK)
  ON twar.StockCode = iwar.StockCode
WHERE iwar.Warehouse > 'z'
AND twar.UnitCost > 0

-- Drop temporary table
DROP TABLE #FcWarehouse


DECLARE 
	@CurMonthStart date = DATEADD(DAY,1,EOMONTH(GETDATE(),-1)),
	@FreezePeriodEnd date = EOMONTH(GETDATE(),5)

--Zero out prior months draft forecast
DELETE FROM dbo.IopNewForecast 
WHERE ForecastDate < @CurMonthStart

--Update Freeze Periods Current month plus 5
UPDATE dbo.IopNewForecast
SET Freeze = 'Y'
WHERE ForecastDate < @FreezePeriodEnd 

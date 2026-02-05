
-- connect to test db
USE ETB_TEST

--create a temporary table to hold data related to the warehouse and Area change by customer number
DECLARE @TempChangeRegion TABLE (
  Customer INT PRIMARY KEY,
  Name VARCHAR(255),
  CustomerClass VARCHAR(255),
  Description VARCHAR(255),
  OLD_AREA VARCHAR(255),
  NEW_AREA VARCHAR(255),
  OLD_Fcast_Warehouse VARCHAR(255),
  NEW_Fcast_Warehouse VARCHAR(255)                        
)

--insert the customer numbers and their new Area values into the temporary table
INSERT INTO
   @TempChangeRegion (
    Customer,
    Name,
    CustomerClass,
    Description,
    OLD_AREA,
    NEW_AREA,
    OLD_Fcast_Warehouse,
    NEW_Fcast_Warehouse
  )
VALUES
(109325,'CARIB SALES, LLC.','WHOLESALER','Change from R2 to R1','R2','R1','z02CARIBSA','z01CARIBSA'),
(105140,'STAR & BEE SALES','WHOLESALER','Change from R2 to R1','R2','R1','z02OTHER','z01OTHER'),
(124129,'GLOBAL BEAUTY CORP.','WHOLESALER','Change from R2 to R1','R2','R1','z02OTHER','z01OTHER'),
(105833,'BEN''S BEAUTY-PHILADELPHIA','WHOLESALER','Change from R2 to R1','R2','R1','z02OTHER','z01OTHER'),
(105832,'BEN''S BTY-JESSUP-RAPPA','WHOLESALER','Change from R2 to R1','R2','R1','z02OTHER','z01OTHER'),
(159626,'7 DOLLAR BEAUTY SUPPLY','WHOLESALER','Change from R2 to R1','R2','R1','z02OTHER','z01OTHER'),
(119135,'EMPRESS BEAUTY DIST','WHOLESALER','Change from R2 to R1','R2','R1','z02OTHER','z01OTHER'),
(153140,'QH WHOLESALE & DISTRIBUTION','WHOLESALER','Change from R2 to R1','R2','R1','z02OTHER','z01OTHER'),
(100827,'AMIS BEAUTY','WHOLESALER','Change from R2 to R1','R2','R1','z02OTHER','z01OTHER'),
(102333,'BEAUTY SUPPLY WHOLESALER','WHOLESALER','Change from R2 to R1','R2','R1','z02OTHER','z01OTHER'),
(135469,'KAS BEAUTY SUPPLY','BEAUTY SHOP','Change from R2 to R1','R2','R1','z02OTHER','z01OTHER'),
(105830,'BEN''S BEAUTY SUPPLY-HOUSTON','WHOLESALER','Change from R2 to R1','R2','R1','z02OTHER','z01OTHER'),
(106200,'BESCO BEAUTY SUPPLY','WHOLESALER','Change from R2 to R1','R2','R1','z02OTHER','z01OTHER'),
(124539,'SME, INC. USA','DRUG WHOLESALER','Change from R2 to R1','R2','R1','z02OTHER','z01OTHER'),
(111130,'CICELY''S HAIR & BTY.','BEAUTY SHOP','Change from R2 to R1','R2','R1','z02OTHER','z01OTHER'),
(101226,'ALBERTO CORTES COSMETICS & PER','BEAUTY SHOP','Change from R2 to R1','R2','R1','z02OTHER','z01OTHER'),
(141882,'MACRO STORE LLC.','ALT CHANNEL','Change from R2 to R1','R2','R1','z02OTHER','z01OTHER'),
(105421,'BEAUTY WORLD -DURHAM','BEAUTY SHOP','Change from R2 to R1','R2','R1','z02OTHER','z01OTHER'),
(171212,'W.B.E. HAIR DESIGN','BEAUTY SHOP','Change from R2 to R1','R2','R1','z02OTHER','z01OTHER'),
(116624,'DRUG EMPORIUM 262','DRUG','Change from R2 to R1','R2','R1','z02OTHER','z01OTHER'),
(109500,'CARIBBEAN PHARMACEUTICALS','WHOLESALER','Change from R2 to R1','R2','R1','z02OTHER','z01OTHER'),
(100115,'ATLANTA 1 TRADING','WHOLESALER','Change from R2 to R1','R2','R1','z02OTHER','z01OTHER'),
(105400,'USA BEAUTY CARE INC.','WHOLESALER','Change from R2 to R1','R2','R1','z02OTHER','z01OTHER'),
(100830,'ADONIS BEAUTY INC.','BEAUTY SHOP','Change from R2 to R1','R2','R1','z02OTHER','z01OTHER'),
(101423,'FIRST CHOICE 2015 INC.','---','Change from R2 to R1','R2','R1','z02OTHER','z01OTHER'),
(172037,'WE GROWING INC.','---','Change from R2 to R1','R2','R1','z02OTHER','z01OTHER'),
(138443,'FOUR SEASONS GENERAL MDSE','---','Change from R2 to R1','R2','R1','z02OTHER','z01OTHER'),
(145440,'MINIMUS','---','Change from R2 to R1','R2','R1','z02OTHER','z01OTHER'),
(168545,'TEN TEN TRADING','---','Change from R2 to R1','R2','R1','z02OTHER','z01OTHER'),
(110409,'U.S. TRADING','---','Change from R2 to R1','R2','R1','z02OTHER','z01OTHER'),
(100335,'ATLASSPHERE USA LLC','---','Change from R2 to R1','R2','R1','z02OTHER','z01OTHER'),
(123538,'GENESIS BEAUTY LLC DBA BEAUTY WORLD','---','Change from R2 to R1','R2','R1','z02OTHER','z01OTHER'),
(124121,'GLOBAL DISTRIBUTORS, INC.','---','Change from R4 to R1','R4','R1','z04OTHER','z01OTHER'),
(142850,'MAMADO INTERNATIONAL LLC','---','Change from R4 to R1','R4','R1','z04OTHER','z01OTHER'),

(137650,'PEYTON''S INC.','FOOD','Change from R6 to R2','R6','R2','z06PEYTON','z02PEYTON'),
(143526,'MEIJER INC.','FOOD','Change from R6 to R2','R6','R2','z06MEIJER','z02MEIJER'),
(135525,'KEEFE SUPPLY COMPANY','WHOLESALER','Change from R6 to R2','R6','R2','z06OTHER','z02OTHER'),
(106268,'BIG LOTS STORES, INC.','VALUE','Change from R6 to R2','R6','R2','z06BIGLOTS','z02BIGLOTS'),
(102725,'ASSOCIATED FOOD STORES','','','R1','R2','z01OTHER','z02OTHER'),

(137748,'L&R DISTRIBUTORS, INC.','FOOD','Change from R1 to R6','R1','R6','z01OTHER','z06OTHER'),
(116657,'AMERISOURCE','DRUG WHOLESALER','Change from R1 to R6','R1','R6','z01OTHER','z06OTHER'),
(141510,'MCKESSON','DRUG WHOLESALER','Change from R2 to R6','R2','R6','z02OTHER','z06OTHER'),
(143455,'MEDLINE INDUSTRIES','','Change from R4 to R6','R4','R6','z04OTHER','z06OTHER'),
(146255,'MORRIS & DICKSON','DRUG WHOLESALER','Change from R2 to R6','R2','R6','z02OTHER','z06OTHER'),
(147957,'NAVAJO MANUFACTURING CO.','FOOD','Change from R2 to R6','R2','R6','z02OTHER','z06OTHER'),
(148725,'NC MUTUAL WHLSE DRUG CO','DRUG WHOLESALER','Change from R2 to R6','R2','R6','z02OTHER','z06OTHER'),
(161125,'SMITH WHOLESALE DRUG','DRUG WHOLESALER','Change from R2 to R6','R2','R6','z02OTHER','z06OTHER'),
(119142,'ENDURANCE REHABILITATION','---','Change from R4 to R6','R4','R6','z04OTHER','z06OTHER'),

-- do not update the following customers' area, they already exist in the ArCustomer table with the correct region 
(880925,'DELTA GLOBAL GENERAL TRADING L.L.C','','MIDDLE EAST','95','95','','z95OTHER'),
(140935,'LOTUS LIGHT ENTERPRISES, INC.','','REGION 2 - KERRY TOTTEN','R2','R2','','z02OTHER'),
(812925,'BULANDI DISTRBUTORS FZCO','','MIDDLE EAST','95','95','','z95OTHER'),
(113334,'DJ''S BEAUTY SUPPLY','','REGION 1 - JOE VENEZIA','R1','R1','','z01OTHER'),
(123232,'HABIBI BEAUTY SUPPLY','','REGION 1 - JOE VENEZIA','R1','R1','','z01OTHER'),
(113333,'DJ''S AND FRIENDS INC.','','REGION 1 - JOE VENEZIA','R1','R1','','z01OTHER'),
(113335,'3D BEAUTY SUPPLY INC.','','REGION 1 - JOE VENEZIA','R1','R1','','z01OTHER')


--update the "ArCustomer+" table "FcstWhse" field

UPDATE c
SET c.FcstWhse = t.NEW_Fcast_Warehouse
FROM dbo.[ArCustomer+] c
JOIN @TempChangeRegion t
  ON c.Customer = t.Customer


--update the "ArCustomer" table  "Area" field

--UPDATE c
--SET c.Area = t.NEW_AREA
--FROM dbo.ArCustomer c
--JOIN TempChangeRegion t
--  ON c.Customer = t.Customer

-- ADVENTUREWORKS DATA ANALYSIS PORTFOLIO
-- SQL Porfolio Project
-- Database: Adventureworks
-- Tool: MySQL


SHOW DATABASES;

USE adventureworks;
SHOW TABLES;


SECTION A: Sales & Customer Analytics

Question 1
-- High-Value Customer Orders

USE adventureworks;

SELECT DISTINCT 
    p.FirstName, 
    p.LastName, 
    e.EmailAddress, 
    s.TotalDue
FROM sales_customer c
JOIN person_person p ON c.PersonID = p.BusinessEntityID
JOIN person_emailaddress e ON p.BusinessEntityID = e.BusinessEntityID
JOIN sales_salesorderheader s ON c.CustomerID = s.CustomerID
WHERE s.TotalDue > 5000
ORDER BY s.TotalDue DESC;


Question 2
-- Orders Exceeding Company Average

SELECT 
    SalesOrderID, 
    OrderDate, 
    TotalDue
FROM sales_salesorderheader
WHERE TotalDue > (
    SELECT AVG(TotalDue) 
    FROM sales_salesorderheader
)
ORDER BY TotalDue DESC;


Question 3
-- Top Revenue-Generating Store Account

SELECT 
    st.Name AS StoreName, 
    st.BusinessEntityID, 
    SUM(s.TotalDue) AS TotalRevenue
FROM sales_store st
JOIN sales_customer c ON st.BusinessEntityID = c.StoreID
JOIN sales_salesorderheader s ON c.CustomerID = s.CustomerID
GROUP BY st.Name, st.BusinessEntityID
ORDER BY TotalRevenue DESC
LIMIT 5;


Question 4
-- Unordered Catalog Products

SELECT 
    p.ProductID, 
    p.Name AS ProductName
FROM production_product p
WHERE p.ProductID NOT IN (
    SELECT DISTINCT ProductID 
    FROM sales_salesorderdetail
)
ORDER BY p.Name;



SECTION B: Product & Inventory Management 

Question 5
-- Premium Subcategory Pricing Analysis

SELECT 
    p.ProductID, 
    p.Name AS ProductName, 
    p.ListPrice, 
    p.ProductSubcategoryID
FROM production_product p
WHERE p.ListPrice > (
    SELECT AVG(p2.ListPrice)
    FROM production_product p2
    WHERE p2.ProductSubcategoryID = p.ProductSubcategoryID
)
ORDER BY p.ProductSubcategoryID, p.ListPrice DESC;



Question 6
-- High-End Bicycle Catalog Filtering
 
 SELECT 
    p.Name AS ProductName, 
    p.ProductModelID, 
    p.ListPrice, 
    pc.Name AS CategoryName
FROM production_product p
JOIN production_productsubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN production_productcategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
WHERE pc.Name = 'Bikes' AND p.ListPrice > 1000
ORDER BY p.ListPrice DESC;



Question 7
-- Low-Stock Inventory Alerts

SELECT 
    p.Name AS ProductName, 
    l.Name AS LocationName, 
    inv.Quantity
FROM production_productinventory inv
JOIN production_product p ON inv.ProductID = p.ProductID
JOIN production_location l ON inv.LocationID = l.LocationID
WHERE inv.Quantity < 10
ORDER BY inv.Quantity ASC;


SECTION C: Human Resources & Employee Metrics

Question 8
-- Above-Average Earning Employees

SELECT 
    e.BusinessEntityID, 
    p.FirstName, 
    p.LastName, 
    e.JobTitle, 
    ph.Rate
FROM humanresources_employee e
JOIN person_person p ON e.BusinessEntityID = p.BusinessEntityID
JOIN humanresources_employeepayhistory ph ON e.BusinessEntityID = ph.BusinessEntityID
WHERE ph.Rate > (
    SELECT AVG(Rate) 
    FROM humanresources_employeepayhistory
)
ORDER BY ph.Rate DESC;



Question 9
-- Manufacturing Department Staff Roster

SELECT 
    p.FirstName, 
    p.LastName, 
    e.JobTitle, 
    d.Name AS DepartmentName, 
    d.GroupName
FROM humanresources_employee e
JOIN person_person p ON e.BusinessEntityID = p.BusinessEntityID
JOIN humanresources_employeedepartmenthistory edh ON e.BusinessEntityID = edh.BusinessEntityID
JOIN humanresources_department d ON edh.DepartmentID = d.DepartmentID
WHERE d.GroupName = 'Manufacturing' AND edh.EndDate IS NULL
ORDER BY d.Name, p.LastName;


SECTION D: Purchasing & Vendor Mangement

Question 10
-- High-Cost Component Vendors

SELECT DISTINCT 
    v.Name AS VendorName, 
    v.AccountNumber
FROM purchasing_vendor v
JOIN purchasing_productvendor pv ON v.BusinessEntityID = pv.BusinessEntityID
WHERE pv.StandardPrice > 500
ORDER BY v.Name;



Question 11
-- Purchase Orders Exceeding Vendor Average

SELECT 
    poh.PurchaseOrderID, 
    poh.VendorID, 
    poh.SubTotal
FROM purchasing_purchaseorderheader poh
WHERE poh.SubTotal > (
    SELECT AVG(poh2.SubTotal)
    FROM purchasing_purchaseorderheader poh2
    WHERE poh2.VendorID = poh.VendorID
)
ORDER BY poh.VendorID, poh.SubTotal DESC;


Question 12
-- Multi-Credit Card Profiles

SELECT 
    p.FirstName, 
    p.LastName, 
    COUNT(cc.CreditCardID) AS CardCount
FROM person_person p
JOIN sales_personcreditcard cc ON p.BusinessEntityID = cc.BusinessEntityID
GROUP BY p.BusinessEntityID, p.FirstName, p.LastName
HAVING COUNT(cc.CreditCardID) > 1
ORDER BY CardCount DESC;



Question 13
-- Top-Performing Sales Representatived per Territory

SELECT 
    sp.BusinessEntityID, 
    p.FirstName, 
    p.LastName, 
    sp.TerritoryID, 
    sp.SalesYTD
FROM sales_salesperson sp
JOIN person_person p ON sp.BusinessEntityID = p.BusinessEntityID
WHERE sp.SalesYTD > (
    SELECT AVG(sp2.SalesYTD)
    FROM sales_salesperson sp2
    WHERE sp2.TerritoryID = sp.TerritoryID
)
ORDER BY sp.TerritoryID, sp.SalesYTD DESC;



Question 14
-- Shipping Cost Outlier Analysis

SELECT 
    soh.SalesOrderID, 
    soh.ShipMethodID, 
    soh.Freight
FROM sales_salesorderheader soh
JOIN (
    SELECT ShipMethodID, AVG(Freight) AS AvgFreight
    FROM sales_salesorderheader
    GROUP BY ShipMethodID
) avg_table ON soh.ShipMethodID = avg_table.ShipMethodID
WHERE soh.Freight > avg_table.AvgFreight
ORDER BY soh.ShipMethodID, soh.Freight DESC;



Question 15
-- High-Discount Bulk Special Offers

SELECT DISTINCT 
    p.ProductID, 
    p.Name AS ProductName, 
    so.Description AS OfferDescription, 
    so.DiscountPct, 
    so.MinQty
FROM production_product p
JOIN sales_specialofferproduct sop ON p.ProductID = sop.ProductID
JOIN sales_specialoffer so ON sop.SpecialOfferID = so.SpecialOfferID
WHERE so.DiscountPct > 0.10 
  AND so.MinQty > 1
ORDER BY so.DiscountPct DESC, so.MinQty ASC;
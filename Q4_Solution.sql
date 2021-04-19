USE [WideWorldImporters]
GO
SELECT s.CustomerCategoryName AS CustomerCategoryName,
	   s.Loss AS MaxLoss,
	   s.CustomerName,
	   s.CustomerID
FROM 
	(
		SELECT cat.CustomerCategoryName AS CustomerCategoryName,
			   SUM(ol.Quantity * ol.UnitPrice) AS Loss,
			   cu.CustomerName AS CustomerName,
			   cu.CustomerID AS CustomerID,
			   ROW_NUMBER() OVER (PARTITION BY cat.CustomerCategoryName ORDER BY SUM(ol.Quantity * ol.UnitPrice) DESC) rn 
		FROM Sales.CustomerCategories AS cat
		JOIN Sales.Customers AS cu
			ON cu.CustomerCategoryID = cat.CustomerCategoryID
			JOIN Sales.Orders AS o
				ON o.CustomerID = cu.CustomerID
				JOIN Sales.OrderLines AS ol
					ON ol.OrderID = o.OrderID
				WHERE NOT EXISTS
					(
						SELECT *
						FROM Sales.Invoices as Iv
						WHERE Iv.OrderId = o.OrderID
					)
				GROUP BY cat.CustomerCategoryName, cu.CustomerName, cu.CustomerID
	 ) s
WHERE rn = 1
ORDER BY MaxLoss DESC
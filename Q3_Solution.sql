/*Need to check if entered year but not choice?*/
USE [WideWorldImporters]

IF EXISTS (SELECT 1 FROM sys.procedures WHERE [name] = 'ReportCustomerTurnover')
BEGIN
DROP PROCEDURE dbo.ReportCustomerTurnover
END

GO
CREATE PROCEDURE dbo.ReportCustomerTurnover
	@Choice int = 1,
	@Year int = 2013
AS
BEGIN
	IF @Choice = 1  -- Pivot month
	BEGIN
		SELECT CustomerName, 
			   ISNULL([1],0) AS [Jan], 
			   ISNULL([2],0) AS [Feb], 
			   ISNULL([3],0) AS [Mar], 
			   ISNULL([4],0) AS [Apr], 
			   ISNULL([5],0) AS [May], 
			   ISNULL([6],0) AS [Jun], 
			   ISNULL([7],0) AS [Jul], 
			   ISNULL([8],0) AS [Aug], 
			   ISNULL([9],0) AS [Sep], 
			   ISNULL([10],0) AS [Oct], 
			   ISNULL([11],0) AS [Nov], 
			   ISNULL([12],0) AS [Dec]
		FROM 
			(
				SELECT SUM(Il.Quantity * Il.UnitPrice) AS Montant,
					   DATEPART(MONTH, Iv.InvoiceDate) AS Month,
					  cu.CustomerName AS CustomerName
				FROM Sales.Customers AS cu
				JOIN Sales.Invoices AS Iv
					ON Iv.CustomerID = cu.CustomerID
				    JOIN Sales.InvoiceLines AS Il
					ON Il.InvoiceID = Iv.InvoiceID
				WHERE DATEPART(YEAR, Iv.InvoiceDate) = @Year
				GROUP BY DATEPART(MONTH, Iv.InvoiceDate), cu.CustomerName

				UNION
		
				SELECT NULL, NULL, cu.CustomerName 
				FROM Sales.Customers AS cu
				WHERE cu.CustomerName NOT IN
					(
						SELECT cu.CustomerName
						FROM Sales.Customers AS cu
						JOIN Sales.Invoices AS Iv
							ON Iv.CustomerID = cu.CustomerID
	 						JOIN Sales.InvoiceLines AS Il
								ON Il.InvoiceID = Iv.InvoiceID
						WHERE DATEPART(YEAR, Iv.InvoiceDate) = @Year
						GROUP BY DATEPART(MONTH, Iv.InvoiceDate), cu.CustomerName
					)

			) AS SourceTable
		PIVOT
			(
				MAX(Montant)
				FOR Month IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])
			) AS PivotTable
		ORDER BY CustomerName
	END

	IF 	@Choice = 2 -- Pivot quarters
	BEGIN
		SELECT CustomerName, 
			   ISNULL([1],0) AS [Q1], 
			   ISNULL([2],0) AS [Q2], 
	              ISNULL([3],0) AS [Q3], 
			   ISNULL([4],0) AS [Q4]
		FROM 
			(
				SELECT SUM(Il.Quantity * Il.UnitPrice) AS Montant,
					   DATEPART(QUARTER, Iv.InvoiceDate) AS Quart,
					   cu.CustomerName AS CustomerName
				FROM Sales.Customers AS cu
				JOIN Sales.Invoices AS Iv
				  ON Iv.CustomerID = cu.CustomerID
				  JOIN Sales.InvoiceLines AS Il
					ON Il.InvoiceID = Iv.InvoiceID
				WHERE DATEPART(YEAR, Iv.InvoiceDate) = @Year
				GROUP BY  DATEPART(QUARTER, Iv.InvoiceDate), cu.CustomerName
				
				UNION
		
				SELECT NULL, NULL, cu.CustomerName 
				FROM Sales.Customers AS cu
				WHERE cu.CustomerName NOT IN
					(
						SELECT cu.CustomerName
						FROM Sales.Customers AS cu
						JOIN Sales.Invoices AS Iv
							ON Iv.CustomerID = cu.CustomerID
	 						JOIN Sales.InvoiceLines AS Il
								ON Il.InvoiceID = Iv.InvoiceID
						WHERE DATEPART(YEAR, Iv.InvoiceDate) = @Year
						GROUP BY DATEPART(QUARTER, Iv.InvoiceDate), cu.CustomerName
					)

			) AS SourceTable
		PIVOT
			(
				MAX(Montant)
				FOR Quart IN ([1], [2], [3], [4])
			) AS PivotTable
		ORDER BY CustomerName
	END

	IF 	@Choice = 3  -- Pivot years
	BEGIN
		SELECT CustomerName, 
			   ISNULL([2013],0) AS [2013], 
			   ISNULL([2014],0) AS [2014], 
			   ISNULL([2015],0) AS [2015], 
			   ISNULL([2016],0) AS [2016]
		FROM 
			(
				SELECT SUM(Il.Quantity * Il.UnitPrice) AS Montant,
					   DATEPART(YEAR, Iv.InvoiceDate) AS Year,
					   cu.CustomerName AS CustomerName
				FROM Sales.Customers AS cu
				JOIN Sales.Invoices AS Iv
					ON Iv.CustomerID = cu.CustomerID
					JOIN Sales.InvoiceLines AS Il
						ON Il.InvoiceID = Iv.InvoiceID
				GROUP BY DATEPART(YEAR, Iv.InvoiceDate), cu.CustomerName

				UNION
		
				SELECT NULL, NULL, cu.CustomerName 
				FROM Sales.Customers AS cu
				WHERE cu.CustomerName NOT IN
					(
						SELECT cu.CustomerName
						FROM Sales.Customers AS cu
						JOIN Sales.Invoices AS Iv
							ON Iv.CustomerID = cu.CustomerID
								JOIN Sales.InvoiceLines AS Il
								ON Il.InvoiceID = Iv.InvoiceID
						GROUP BY DATEPART(YEAR, Iv.InvoiceDate), cu.CustomerName
					)

		 ) AS SourceTable
		PIVOT
		 (
			MAX(Montant)
			FOR YEAR IN ([2013], [2014], [2015], [2016])
		 ) AS PivotTable
		ORDER BY CustomerName
	END

	IF @Choice NOT IN (1,3)
		PRINT('@Choice value incorrect') -- Or need to check which value is entered?
END
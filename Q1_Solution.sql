USE [WideWorldImporters]
GO
SELECT cu.CustomerID,
	   cu.CustomerName,
		(
			SELECT COUNT(*)
			FROM Sales.Orders AS o
			WHERE o.CustomerID = Cu.CustomerID
				AND EXISTS
					(
					SELECT *
					FROM Sales.Invoices I
					WHERE o.OrderID = I.OrderID
					)
		) AS TotalNBOrders,
		(
			SELECT COUNT(*)
			FROM Sales.Invoices AS I
			WHERE I.CustomerID = cu.CustomerID
		) AS TotalNBInvoices,
		(
			SELECT SUM(Ol.PickedQuantity*Ol.UnitPrice) 
			FROM Sales.OrderLines AS Ol
			JOIN Sales.Orders O
				ON O.OrderID = Ol.OrderID
			WHERE O.CustomerID = cu.CustomerID
			GROUP BY O.CustomerID
		) AS OrdersTotalValue,
		(
			SELECT SUM(Il.UnitPrice*Il.Quantity) 
			FROM Sales.InvoiceLines Il
			JOIN Sales.Invoices I
				ON I.InvoiceID = Il.InvoiceID
			WHERE I.CustomerID = cu.CustomerID
			GROUP BY I.CustomerID
		) AS InvoicesTotalValue,
		ABS(	
			(SELECT SUM(Ol.PickedQuantity*Ol.UnitPrice)
			FROM Sales.OrderLines AS Ol
			JOIN Sales.Orders O
				ON O.OrderID = Ol.OrderID
			WHERE O.CustomerID = cu.CustomerID
			GROUP BY O.CustomerID)
			-
			(SELECT SUM(Il.UnitPrice*Il.Quantity)
			FROM Sales.InvoiceLines Il
			JOIN Sales.Invoices I
				ON I.InvoiceID = Il.InvoiceID
			WHERE I.CustomerID = cu.CustomerID
			GROUP BY I.CustomerID)
		) AS AbsoluteValueDifference
FROM Sales.Customers AS cu
ORDER BY AbsoluteValueDifference DESC, TotalNBOrders ASC, cu.CustomerName ASC
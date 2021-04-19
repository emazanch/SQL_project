USE [WideWorldImporters]
GO
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRY
 BEGIN TRANSACTION
 	UPDATE Sales.InvoiceLines
	SET UnitPrice = UnitPrice + 20
	WHERE InvoiceLineID = 
		(SELECT MIN(Il.InvoiceLineID)
		 FROM Sales.InvoiceLines Il
		 JOIN Sales.Invoices I
			 ON I.InvoiceID = Il.InvoiceID
		 WHERE I.CustomerID = 1060
		 )
	SELECT I.InvoiceID, InvoiceLineID, Quantity, UnitPrice, TaxRate, TaxAmount, ExtendedPrice
	FROM Sales.InvoiceLines Il
	JOIN Sales.Invoices I
		ON I.InvoiceID = Il.InvoiceID
	WHERE I.CustomerID = 1060
	ORDER BY I.InvoiceID
 COMMIT TRANSACTION
END TRY

BEGIN CATCH
	-- If Try ends by error
	ROLLBACK TRANSACTION
END CATCH
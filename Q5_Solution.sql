USE [SQLPlayground]
GO
SELECT cu.CustomerID,
		cu.CustomerName/*,
		COUNT(p.ProductId) AS NbOfProducts,
		SUM(p.Qty) AS TotalSum*/
FROM Customer AS cu
JOIN  Purchase AS p
	ON p.CustomerId = cu.CustomerId
WHERE EXISTS
		(
			SELECT SUM(p.Qty)
			FROM Purchase AS p
			WHERE cu.CustomerId = p.CustomerId
			HAVING SUM(p.Qty) >= 50
		)
GROUP BY cu.CustomerId, cu.CustomerName
HAVING COUNT(p.ProductId) >= COUNT(DISTINCT p.ProductId)
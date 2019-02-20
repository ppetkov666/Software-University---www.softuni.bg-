ALTER TABLE Payments
DROP CONSTRAINT [CK_TaxAmount]
UPDATE Payments
SET TaxRate *= 0.97

SELECT TaxRate FROM Payments
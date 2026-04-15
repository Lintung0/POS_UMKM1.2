-- Fix image column to support base64 images
-- VARCHAR(255) is too small for base64 encoded images
-- Change to LONGTEXT to support images up to 4GB

USE pos_umkm;

ALTER TABLE products MODIFY COLUMN image LONGTEXT;

-- Verify the change
DESCRIBE products;

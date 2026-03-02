#!/bin/bash

echo "🔧 Cleaning Database for Foreign Key Migration"
echo "============================================="

# Connect to MySQL and clean invalid data
mysql -u root -p pos_umkm << 'EOF'

-- Check existing recipes with invalid references
SELECT 'Checking invalid recipes...' as status;
SELECT COUNT(*) as invalid_recipes FROM recipes r 
LEFT JOIN products p ON r.product_id = p.id 
LEFT JOIN raw_materials rm ON r.material_id = rm.id 
WHERE p.id IS NULL OR rm.id IS NULL;

-- Delete invalid recipes
DELETE r FROM recipes r 
LEFT JOIN products p ON r.product_id = p.id 
WHERE p.id IS NULL;

DELETE r FROM recipes r 
LEFT JOIN raw_materials rm ON r.material_id = rm.id 
WHERE rm.id IS NULL;

-- Check existing transaction_details with invalid references
SELECT 'Checking invalid transaction details...' as status;
SELECT COUNT(*) as invalid_details FROM transaction_details td 
LEFT JOIN transactions t ON td.transaction_id = t.id 
LEFT JOIN products p ON td.product_id = p.id 
WHERE t.id IS NULL OR p.id IS NULL;

-- Delete invalid transaction details
DELETE td FROM transaction_details td 
LEFT JOIN transactions t ON td.transaction_id = t.id 
WHERE t.id IS NULL;

DELETE td FROM transaction_details td 
LEFT JOIN products p ON td.product_id = p.id 
WHERE p.id IS NULL;

SELECT 'Database cleaned successfully!' as status;

EOF

echo "✅ Database cleanup completed!"
echo "Now you can run: go run main.go"

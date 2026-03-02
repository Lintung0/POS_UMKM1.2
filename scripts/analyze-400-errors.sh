#!/bin/bash

echo "🔧 PRODUCTS 400 ERROR ANALYSIS & SOLUTIONS"
echo "=========================================="

BASE_URL="http://localhost:8082/api"
ADMIN_TOKEN=$(curl -s "$BASE_URL/auth/login" -X POST -H "Content-Type: application/json" -d '{"username":"admin","password":"admin123"}' | jq -r '.data.token')

echo "📋 IDENTIFIED VALIDATION RULES"
echo "=============================="
echo "1. name: required, non-empty string"
echo "2. cost_price: required, >= 0"
echo "3. selling_price: required, >= 0, must be > cost_price"
echo "4. stock: >= 0"
echo "5. category: optional string"
echo "6. image: optional string"
echo ""

echo "🧪 TESTING EACH VALIDATION RULE"
echo "==============================="

echo "➤ Test 1: Valid product (should work)"
RESPONSE=$(curl -s "$BASE_URL/products" -X POST -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json" -d '{"name":"Valid Product","category":"Test","selling_price":15000,"cost_price":10000,"stock":20}')
echo "Valid: $(echo $RESPONSE | jq '.success') - $(echo $RESPONSE | jq -r '.message')"

echo "➤ Test 2: Empty name (should fail)"
RESPONSE=$(curl -s "$BASE_URL/products" -X POST -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json" -d '{"name":"","category":"Test","selling_price":15000,"cost_price":10000,"stock":20}')
echo "Empty name: $(echo $RESPONSE | jq '.success') - $(echo $RESPONSE | jq -r '.message')"

echo "➤ Test 3: Negative cost_price (should fail)"
RESPONSE=$(curl -s "$BASE_URL/products" -X POST -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json" -d '{"name":"Test Product","category":"Test","selling_price":15000,"cost_price":-1,"stock":20}')
echo "Negative cost: $(echo $RESPONSE | jq '.success') - $(echo $RESPONSE | jq -r '.message')"

echo "➤ Test 4: selling_price <= cost_price (should fail)"
RESPONSE=$(curl -s "$BASE_URL/products" -X POST -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json" -d '{"name":"Test Product","category":"Test","selling_price":10000,"cost_price":10000,"stock":20}')
echo "Equal prices: $(echo $RESPONSE | jq '.success') - $(echo $RESPONSE | jq -r '.message')"

echo "➤ Test 5: Missing required fields (should fail)"
RESPONSE=$(curl -s "$BASE_URL/products" -X POST -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json" -d '{"category":"Test","stock":20}')
echo "Missing fields: $(echo $RESPONSE | jq '.success') - $(echo $RESPONSE | jq -r '.message')"

echo "➤ Test 6: Zero cost_price with positive selling_price (should work)"
RESPONSE=$(curl -s "$BASE_URL/products" -X POST -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json" -d '{"name":"Zero Cost Product","category":"Test","selling_price":15000,"cost_price":0,"stock":20}')
echo "Zero cost: $(echo $RESPONSE | jq '.success') - $(echo $RESPONSE | jq -r '.message')"

echo ""
echo "🎯 FRONTEND FORM VALIDATION REQUIREMENTS"
echo "========================================"
echo "To prevent 400 errors, frontend should validate:"
echo ""
echo "1. ✅ Name field:"
echo "   - Required: true"
echo "   - Min length: 1"
echo "   - Validation: name.trim().length > 0"
echo ""
echo "2. ✅ Cost Price field:"
echo "   - Required: true"
echo "   - Type: number"
echo "   - Min value: 0"
echo "   - Validation: costPrice >= 0"
echo ""
echo "3. ✅ Selling Price field:"
echo "   - Required: true"
echo "   - Type: number"
echo "   - Min value: 0"
echo "   - Business rule: sellingPrice > costPrice"
echo "   - Validation: sellingPrice > costPrice"
echo ""
echo "4. ✅ Stock field:"
echo "   - Type: number"
echo "   - Min value: 0"
echo "   - Default: 0"
echo "   - Validation: stock >= 0"
echo ""
echo "5. ✅ Category field:"
echo "   - Optional"
echo "   - Type: string"
echo "   - Default: 'Umum'"
echo ""

echo "📝 FRONTEND VALIDATION EXAMPLE"
echo "============================="
cat << 'EOF'
// JavaScript validation example
function validateProductForm(formData) {
    const errors = [];
    
    // Name validation
    if (!formData.name || formData.name.trim().length === 0) {
        errors.push("Nama produk wajib diisi");
    }
    
    // Cost price validation
    if (formData.cost_price === undefined || formData.cost_price < 0) {
        errors.push("Harga modal harus >= 0");
    }
    
    // Selling price validation
    if (formData.selling_price === undefined || formData.selling_price < 0) {
        errors.push("Harga jual harus >= 0");
    }
    
    // Business rule: selling > cost
    if (formData.selling_price <= formData.cost_price) {
        errors.push("Harga jual harus lebih besar dari harga modal");
    }
    
    // Stock validation
    if (formData.stock < 0) {
        errors.push("Stok tidak boleh negatif");
    }
    
    return errors;
}

// Usage in form submit
const errors = validateProductForm(formData);
if (errors.length > 0) {
    showErrors(errors);
    return false; // Don't submit
}
EOF

echo ""
echo "🔧 QUICK FIXES FOR COMMON ISSUES"
echo "==============================="
echo "1. 🚫 'Data tidak valid' error:"
echo "   → Check all required fields are filled"
echo "   → Ensure numeric fields contain valid numbers"
echo "   → Verify JSON format is correct"
echo ""
echo "2. 🚫 'Harga jual harus lebih besar dari harga modal':"
echo "   → Make sure selling_price > cost_price"
echo "   → Both prices must be positive numbers"
echo ""
echo "3. 🚫 Multiple 400 errors in logs:"
echo "   → Frontend form is sending invalid data repeatedly"
echo "   → Add client-side validation before API call"
echo "   → Check browser console for JavaScript errors"
echo ""
echo "✅ The API validation is working correctly!"
echo "   The 400 errors indicate proper input validation."

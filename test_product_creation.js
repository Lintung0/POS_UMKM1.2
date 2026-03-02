#!/usr/bin/env node

const axios = require('axios');

const API_BASE = 'http://localhost:8082/api';

async function testProductCreation() {
    console.log('🧪 Testing Product Creation Flow...\n');
    
    try {
        // Step 1: Login
        console.log('1️⃣ Testing Login...');
        const loginResponse = await axios.post(`${API_BASE}/auth/login`, {
            username: 'admin',
            password: 'admin123'
        });
        
        if (loginResponse.data.success) {
            console.log('✅ Login successful');
            console.log(`   User: ${loginResponse.data.data.username} (${loginResponse.data.data.role})`);
        } else {
            throw new Error('Login failed');
        }
        
        const token = loginResponse.data.data.token;
        
        // Step 2: Test Get Products
        console.log('\n2️⃣ Testing Get Products...');
        const productsResponse = await axios.get(`${API_BASE}/products`, {
            headers: { Authorization: `Bearer ${token}` }
        });
        
        console.log(`✅ Found ${productsResponse.data.data.products.length} products`);
        
        // Step 3: Test Create Product (the problematic operation)
        console.log('\n3️⃣ Testing Create Product...');
        const newProduct = {
            name: `Test Product ${Date.now()}`,
            category: 'Test Category',
            cost_price: 5000,
            selling_price: 8000,
            stock: 10,
            image: ''
        };
        
        const createResponse = await axios.post(`${API_BASE}/products`, newProduct, {
            headers: { 
                Authorization: `Bearer ${token}`,
                'Content-Type': 'application/json'
            }
        });
        
        if (createResponse.data.success) {
            console.log('✅ Product created successfully');
            console.log(`   Product ID: ${createResponse.data.data.id}`);
            console.log(`   Product Name: ${createResponse.data.data.name}`);
        }
        
        // Step 4: Test Token Validation
        console.log('\n4️⃣ Testing Token Validation...');
        const validateResponse = await axios.get(`${API_BASE}/products`, {
            headers: { Authorization: `Bearer ${token}` }
        });
        
        if (validateResponse.status === 200) {
            console.log('✅ Token still valid after product creation');
        }
        
        // Step 5: Test Recipe Creation (the 403 error from logs)
        console.log('\n5️⃣ Testing Recipe Creation...');
        try {
            const recipeData = {
                product_id: createResponse.data.data.id,
                recipes: [
                    {
                        material_id: 1,
                        quantity: 2
                    }
                ]
            };
            
            const recipeResponse = await axios.post(`${API_BASE}/recipes`, recipeData, {
                headers: { 
                    Authorization: `Bearer ${token}`,
                    'Content-Type': 'application/json'
                }
            });
            
            console.log('✅ Recipe created successfully');
        } catch (recipeError) {
            console.log('❌ Recipe creation failed:');
            console.log(`   Status: ${recipeError.response?.status}`);
            console.log(`   Message: ${recipeError.response?.data?.message}`);
        }
        
        console.log('\n🎉 All tests completed!');
        
    } catch (error) {
        console.error('❌ Test failed:');
        console.error(`   Status: ${error.response?.status}`);
        console.error(`   Message: ${error.response?.data?.message || error.message}`);
        
        if (error.response?.status === 401) {
            console.error('   🔍 This indicates an authentication problem');
        } else if (error.response?.status === 403) {
            console.error('   🔍 This indicates an authorization problem (user role)');
        }
    }
}

testProductCreation();

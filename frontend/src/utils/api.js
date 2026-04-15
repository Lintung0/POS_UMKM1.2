import axios from 'axios';

const API_BASE_URL = 'http://localhost:8080/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add token to requests
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Handle auth errors
api.interceptors.response.use(
  (response) => response,
  (error) => {
    // Only redirect to login if token is actually invalid/expired
    // Don't redirect for authorization errors (403) or other 401 errors
    if (error.response?.status === 401) {
      const errorMsg = error.response?.data?.message?.toLowerCase() || '';
      const errorData = error.response?.data?.error?.toLowerCase() || '';
      
      // Check if it's a token-related error
      const isTokenError = 
        errorMsg.includes('token') || 
        errorMsg.includes('jwt') ||
        errorMsg.includes('expired') ||
        errorMsg.includes('invalid token') ||
        errorMsg.includes('authentication failed') ||
        errorData.includes('token') ||
        errorData.includes('jwt');
      
      if (isTokenError) {
        localStorage.removeItem('token');
        localStorage.removeItem('user');
        window.location.href = '/login';
      }
      // Otherwise, let the component handle the error
    }
    return Promise.reject(error);
  }
);

// Auth API (uses different base URL - no /api prefix)
export const authAPI = {
  login: (credentials) => axios.post('http://localhost:8080/login', credentials),
};

// Products API
export const productsAPI = {
  getAll: (params = {}) => api.get('/products', { params: { ...params, _t: Date.now() } }),
  getById: (id) => api.get(`/products/${id}`, { params: { _t: Date.now() } }),
  create: (data) => api.post('/products', data),
  update: (id, data) => api.put(`/products/${id}`, data),
  delete: (id) => api.delete(`/products/${id}`),
  getRecipes: (id) => api.get(`/products/${id}/recipes`, { params: { _t: Date.now() } }),
};

// Materials API
export const materialsAPI = {
  getAll: (params = {}) => api.get('/materials', { params: { ...params, _t: Date.now() } }),
  getAllNoPagination: () => api.get('/materials', { params: { page: 1, limit: 9999, _t: Date.now() } }),
  getLowStock: () => api.get('/materials/low-stock', { params: { _t: Date.now() } }),
  create: (data) => api.post('/materials', data),
  update: (id, data) => api.put(`/materials/${id}`, data),
  delete: (id) => api.delete(`/materials/${id}`),
  restock: (id, data) => api.post(`/materials/${id}/restock`, data),
};

// Recipes API
export const recipesAPI = {
  getByProduct: (productId) => api.get(`/recipes/product/${productId}`),
  save: (data) => api.post('/recipes', data),
  delete: (id) => api.delete(`/recipes/${id}`),
};

// Transactions API
export const transactionsAPI = {
  getAll: (params = {}) => api.get('/transactions', { params }),
  getById: (id) => api.get(`/transactions/${id}`),
  create: (data) => api.post('/transactions', data),
  getReceipt: (id) => api.get(`/transactions/${id}/receipt`),
  getDailyReport: (date) => api.get('/transactions/report/daily', { params: { date } }),
  getMonthlyReport: (month) => api.get('/transactions/report/monthly', { params: { month } }),
};

// Dashboard API
export const dashboardAPI = {
  getSummary: () => api.get('/dashboard/summary', { params: { _t: Date.now() } }),
  getTopProducts: (limit = 5) => api.get('/dashboard/top-products', { params: { limit, _t: Date.now() } }),
  getSalesTrend: (days = 30) => api.get('/dashboard/sales-trend', { params: { days, _t: Date.now() } }),
};

// Expenses API
export const expensesAPI = {
  getAll: (params = {}) => api.get('/expenses', { params: { ...params, _t: Date.now() } }),
  getSummary: (params = {}) => api.get('/expenses/summary', { params: { ...params, _t: Date.now() } }),
  create: (data) => api.post('/expenses', data),
  update: (id, data) => api.put(`/expenses/${id}`, data),
  delete: (id) => api.delete(`/expenses/${id}`),
};

// Reports API (placeholder)
export const reportsAPI = {
  getDailyReport: (date) => api.get('/transactions/report/daily', { params: { date, _t: Date.now() } }),
  getMonthlyReport: (month) => api.get('/transactions/report/monthly', { params: { month, _t: Date.now() } }),
};

// Profit API
export const profitAPI = {
  getSummary: (params) => api.get('/profit/summary', { params: { ...params, _t: Date.now() } }),
  getProducts: (params) => api.get('/profit/products', { params: { ...params, _t: Date.now() } }),
  getTrend: () => api.get('/profit/trend', { params: { _t: Date.now() } }),
};

// Settings API
export const settingsAPI = {
  get: () => api.get('/settings'),
  update: (data) => api.put('/settings', data),
};

export default api;

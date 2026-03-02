import React, { useState, useEffect } from 'react';
import { useAuth } from '../context/AuthContext';
import { CartProvider } from '../context/CartContext';
import Sidebar from '../components/Sidebar';
import DashboardPage from '../pages/DashboardPage';
import CashierPage from '../pages/CashierPage';
import ProductsPage from '../pages/ProductsPage';
import MaterialsPage from '../pages/MaterialsPage';
import ExpensesPage from '../pages/ExpensesPage';
import ReportsPage from '../pages/ReportsPage';
import SettingsPage from '../pages/SettingsPage';
import ProfitAnalysis from '../pages/ProfitAnalysis';
import { Menu, Bell, X, AlertTriangle } from 'lucide-react';
import { materialsAPI, productsAPI } from '../utils/api';

const MainLayout = () => {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [activeTab, setActiveTab] = useState('dashboard');
  const [showNotifications, setShowNotifications] = useState(false);
  const [notifications, setNotifications] = useState([]);
  const { user } = useAuth();

  useEffect(() => {
    // Force fetch on mount
    fetchNotifications();
    // Refresh every minute
    const interval = setInterval(fetchNotifications, 60000);
    return () => clearInterval(interval);
  }, []);

  useEffect(() => {
    const handleClickOutside = (event) => {
      if (showNotifications && !event.target.closest('.notification-container')) {
        setShowNotifications(false);
      }
    };

    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, [showNotifications]);

  const fetchNotifications = async () => {
    try {
      const [lowStockMaterials, allProducts] = await Promise.all([
        materialsAPI.getLowStock(),
        productsAPI.getAll()
      ]);

      const notifs = [];

      // Low stock materials
      if (lowStockMaterials.data.data && Array.isArray(lowStockMaterials.data.data)) {
        console.log('Low stock materials:', lowStockMaterials.data.data.length);
        lowStockMaterials.data.data.forEach(material => {
          notifs.push({
            id: `material-${material.id}`,
            type: 'material',
            title: 'Stok Bahan Rendah',
            message: `${material.name} tersisa ${material.stock} ${material.unit}`,
            severity: 'warning'
          });
        });
      }

      // Low stock products
      if (allProducts.data.data.products) {
        allProducts.data.data.products.forEach(product => {
          if (product.stock <= 5 && product.stock > 0) {
            notifs.push({
              id: `product-${product.id}`,
              type: 'product',
              title: 'Stok Produk Rendah',
              message: `${product.name} tersisa ${product.stock} unit`,
              severity: 'warning'
            });
          } else if (product.stock === 0) {
            notifs.push({
              id: `product-${product.id}`,
              type: 'product',
              title: 'Stok Produk Habis',
              message: `${product.name} habis`,
              severity: 'danger'
            });
          }
        });
      }

      console.log('Total notifications:', notifs.length);
      setNotifications(notifs);
    } catch (error) {
      console.error('Failed to fetch notifications:', error);
    }
  };

  const renderContent = () => {
    switch (activeTab) {
      case 'dashboard':
        return <DashboardPage onNavigate={setActiveTab} />;
      case 'cashier':
        return <CashierPage />;
      case 'products':
        return <ProductsPage />;
      case 'materials':
        return <MaterialsPage />;
      case 'expenses':
        return <ExpensesPage />;
      case 'reports':
        return <ReportsPage />;
      case 'profit':
        return <ProfitAnalysis />;
      case 'settings':
        return <SettingsPage />;
      default:
        return <DashboardPage onNavigate={setActiveTab} />;
    }
  };

  return (
    <CartProvider>
      <div className="flex h-screen bg-gray-50 dark:bg-gray-900 transition-colors duration-200">
        <Sidebar 
          isOpen={sidebarOpen}
          onToggle={() => setSidebarOpen(!sidebarOpen)}
          activeTab={activeTab}
          onTabChange={setActiveTab}
        />
        
        <div className="flex-1 flex flex-col overflow-hidden">
          {/* Top Bar */}
          <header className="bg-white dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700 px-6 py-4 transition-colors duration-200">
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-4">
                <button
                  onClick={() => setSidebarOpen(!sidebarOpen)}
                  className="lg:hidden p-2 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg transition-colors"
                >
                  <Menu className="w-5 h-5 text-gray-600 dark:text-gray-300" />
                </button>
              </div>
              
              <div className="flex items-center space-x-4">
                <div className="relative notification-container">
                  <button 
                    onClick={() => setShowNotifications(!showNotifications)}
                    className="p-2 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg relative transition-colors"
                  >
                    <Bell className="w-5 h-5 text-gray-600 dark:text-gray-300" />
                    {notifications.length > 0 && (
                      <span className="absolute -top-1 -right-1 w-5 h-5 bg-red-500 rounded-full flex items-center justify-center text-white text-xs font-bold">
                        {notifications.length}
                      </span>
                    )}
                  </button>

                  {/* Notification Dropdown */}
                  {showNotifications && (
                    <div className="absolute right-0 mt-2 w-80 bg-white dark:bg-gray-800 rounded-lg shadow-lg border border-gray-200 dark:border-gray-700 z-50 transition-colors duration-200">
                      <div className="p-4 border-b border-gray-200 dark:border-gray-700 flex items-center justify-between">
                        <h3 className="font-semibold text-gray-900 dark:text-gray-100">Notifikasi</h3>
                        <div className="flex items-center space-x-2">
                          <button 
                            onClick={() => {
                              fetchNotifications();
                              console.log('Refreshing notifications...');
                            }}
                            className="p-1 hover:bg-gray-100 dark:hover:bg-gray-700 rounded transition-colors"
                            title="Refresh"
                          >
                            <svg className="w-4 h-4 text-gray-600 dark:text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                            </svg>
                          </button>
                          <button 
                            onClick={() => setShowNotifications(false)}
                            className="p-1 hover:bg-gray-100 dark:hover:bg-gray-700 rounded transition-colors"
                          >
                            <X className="w-4 h-4 text-gray-600 dark:text-gray-300" />
                          </button>
                        </div>
                      </div>
                      
                      <div className="max-h-96 overflow-y-auto">
                        {notifications.length === 0 ? (
                          <div className="p-8 text-center text-gray-500 dark:text-gray-400">
                            <Bell className="w-12 h-12 mx-auto mb-2 text-gray-300 dark:text-gray-600" />
                            <p>Tidak ada notifikasi</p>
                          </div>
                        ) : (
                          <div className="divide-y divide-gray-100 dark:divide-gray-700">
                            {notifications.map((notif) => (
                              <div 
                                key={notif.id}
                                className="p-4 hover:bg-gray-50 dark:hover:bg-gray-700 cursor-pointer transition-colors"
                                onClick={() => {
                                  setActiveTab(notif.type === 'material' ? 'materials' : 'products');
                                  setShowNotifications(false);
                                }}
                              >
                                <div className="flex items-start space-x-3">
                                  <div className={`p-2 rounded-lg ${
                                    notif.severity === 'danger' 
                                      ? 'bg-red-100 dark:bg-red-900/30' 
                                      : 'bg-orange-100 dark:bg-orange-900/30'
                                  }`}>
                                    <AlertTriangle className={`w-4 h-4 ${
                                      notif.severity === 'danger'
                                        ? 'text-red-600 dark:text-red-400'
                                        : 'text-orange-600 dark:text-orange-400'
                                    }`} />
                                  </div>
                                  <div className="flex-1">
                                    <p className="text-sm font-medium text-gray-900 dark:text-gray-100">
                                      {notif.title}
                                    </p>
                                    <p className="text-sm text-gray-600 dark:text-gray-400 mt-1">
                                      {notif.message}
                                    </p>
                                  </div>
                                </div>
                              </div>
                            ))}
                          </div>
                        )}
                      </div>
                    </div>
                  )}
                </div>

                <div className="flex items-center space-x-2">
                  <div className="w-8 h-8 bg-primary rounded-full flex items-center justify-center">
                    <span className="text-white text-sm font-medium">
                      {user?.name?.charAt(0) || 'U'}
                    </span>
                  </div>
                  <span className="hidden md:block text-sm font-medium text-gray-900 dark:text-gray-100">
                    {user?.name}
                  </span>
                </div>
              </div>
            </div>
          </header>

          {/* Main Content */}
          <main className="flex-1 overflow-auto">
            {activeTab === 'cashier' ? (
              renderContent()
            ) : (
              <div className="p-6">
                {renderContent()}
              </div>
            )}
          </main>
        </div>
      </div>
    </CartProvider>
  );
};

export default MainLayout;

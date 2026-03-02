import React, { useState, useEffect } from 'react';
import { dashboardAPI } from '../utils/api';
import { formatCurrency } from '../utils/helpers';
import LowStockAlert from '../components/LowStockAlert';
import { 
  TrendingUp, 
  DollarSign, 
  Package, 
  AlertTriangle,
  ShoppingCart,
  Users,
  BarChart3,
  Calendar
} from 'lucide-react';

const DashboardPage = ({ onNavigate }) => {
  const [summary, setSummary] = useState(null);
  const [topProducts, setTopProducts] = useState([]);
  const [salesTrend, setSalesTrend] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchDashboardData();
  }, []);

  const fetchDashboardData = async () => {
    try {
      const [summaryRes, topProductsRes, salesTrendRes] = await Promise.all([
        dashboardAPI.getSummary(),
        dashboardAPI.getTopProducts(5),
        dashboardAPI.getSalesTrend(7)
      ]);

      setSummary(summaryRes.data.data);
      setTopProducts(topProductsRes.data.data || []);
      setSalesTrend(salesTrendRes.data.data || []);
    } catch (error) {
      console.error('Error fetching dashboard data:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
      </div>
    );
  }

  const stats = [
    {
      title: 'Total Penjualan Hari Ini',
      value: formatCurrency(summary?.today_sales || 0),
      icon: DollarSign,
      color: 'bg-green-500',
      change: '+12%'
    },
    {
      title: 'Keuntungan Hari Ini',
      value: formatCurrency(summary?.today_profit || 0),
      icon: TrendingUp,
      color: 'bg-blue-500',
      change: '+8%'
    },
    {
      title: 'Total Produk',
      value: summary?.total_products || 0,
      icon: Package,
      color: 'bg-purple-500',
      change: '+2'
    },
    {
      title: 'Stok Rendah',
      value: summary?.low_stock_count || 0,
      icon: AlertTriangle,
      color: 'bg-orange-500',
      change: '-1'
    }
  ];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
        <div className="flex items-center space-x-2 text-sm text-gray-600">
          <Calendar className="w-4 h-4" />
          <span>{new Date().toLocaleDateString('id-ID', { 
            weekday: 'long', 
            year: 'numeric', 
            month: 'long', 
            day: 'numeric' 
          })}</span>
        </div>
      </div>

      {/* Low Stock Alert */}
      <LowStockAlert />

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {stats.map((stat, index) => (
          <div key={index} className="card">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-600">{stat.title}</p>
                <p className="text-2xl font-bold text-gray-900 mt-1">{stat.value}</p>
                <p className="text-sm text-green-600 mt-1">{stat.change} dari kemarin</p>
              </div>
              <div className={`${stat.color} p-3 rounded-lg`}>
                <stat.icon className="w-6 h-6 text-white" />
              </div>
            </div>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Top Products */}
        <div className="card">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold text-gray-900">Produk Terlaris</h2>
            <BarChart3 className="w-5 h-5 text-gray-400" />
          </div>
          <div className="space-y-3">
            {topProducts && topProducts.length > 0 ? (
              topProducts.map((product, index) => (
              <div key={index} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                <div className="flex items-center space-x-3">
                  <div className="w-8 h-8 bg-primary rounded-full flex items-center justify-center text-white text-sm font-medium">
                    {index + 1}
                  </div>
                  <div>
                    <p className="font-medium text-gray-900">{product.product_name}</p>
                    <p className="text-sm text-gray-600">{product.total_sold} terjual</p>
                  </div>
                </div>
                <div className="text-right">
                  <p className="font-medium text-gray-900">{formatCurrency(product.total_amount)}</p>
                  <p className="text-sm text-green-600">{formatCurrency(product.total_profit)}</p>
                </div>
              </div>
              ))
            ) : (
              <div className="text-center py-8 text-gray-500">
                <Package className="w-12 h-12 mx-auto mb-2 text-gray-300" />
                <p>Belum ada data produk terlaris</p>
              </div>
            )}
          </div>
        </div>

        {/* Sales Trend */}
        <div className="card">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold text-gray-900">Tren Penjualan (7 Hari)</h2>
            <TrendingUp className="w-5 h-5 text-gray-400" />
          </div>
          <div className="space-y-3">
            {salesTrend && salesTrend.length > 0 ? (
              salesTrend.map((trend, index) => (
              <div key={index} className="flex items-center justify-between p-3 border-l-4 border-primary bg-blue-50 rounded-r-lg">
                <div>
                  <p className="font-medium text-gray-900">
                    {new Date(trend.date).toLocaleDateString('id-ID', { 
                      weekday: 'short', 
                      month: 'short', 
                      day: 'numeric' 
                    })}
                  </p>
                  <p className="text-sm text-gray-600">{trend.transaction_count} transaksi</p>
                </div>
                <div className="text-right">
                  <p className="font-medium text-gray-900">{formatCurrency(trend.total_sales)}</p>
                  <p className="text-sm text-green-600">{formatCurrency(trend.total_profit)}</p>
                </div>
              </div>
              ))
            ) : (
              <div className="text-center py-8 text-gray-500">
                <BarChart3 className="w-12 h-12 mx-auto mb-2 text-gray-300" />
                <p>Belum ada data trend penjualan</p>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="card">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">Aksi Cepat</h2>
        <div className="grid grid-cols-2 md:grid-cols-5 gap-4">
          <button 
            onClick={() => onNavigate && onNavigate('cashier')}
            className="btn btn-primary flex items-center justify-center space-x-2 py-3"
          >
            <ShoppingCart className="w-5 h-5" />
            <span>Transaksi Baru</span>
          </button>
          <button 
            onClick={() => onNavigate && onNavigate('products')}
            className="btn bg-green-100 text-green-700 hover:bg-green-200 flex items-center justify-center space-x-2 py-3"
          >
            <Package className="w-5 h-5" />
            <span>Tambah Produk</span>
          </button>
          <button 
            onClick={() => onNavigate && onNavigate('materials')}
            className="btn bg-purple-100 text-purple-700 hover:bg-purple-200 flex items-center justify-center space-x-2 py-3"
          >
            <Users className="w-5 h-5" />
            <span>Kelola Stok</span>
          </button>
          <button 
            onClick={() => onNavigate && onNavigate('profit')}
            className="btn bg-blue-100 text-blue-700 hover:bg-blue-200 flex items-center justify-center space-x-2 py-3"
          >
            <TrendingUp className="w-5 h-5" />
            <span>Analisis Profit</span>
          </button>
          <button 
            onClick={() => onNavigate && onNavigate('reports')}
            className="btn bg-orange-100 text-orange-700 hover:bg-orange-200 flex items-center justify-center space-x-2 py-3"
          >
            <BarChart3 className="w-5 h-5" />
            <span>Laporan</span>
          </button>
        </div>
      </div>
    </div>
  );
};

export default DashboardPage;

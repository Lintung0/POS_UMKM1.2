import React, { useState, useEffect } from 'react';
import { transactionsAPI, dashboardAPI } from '../utils/api';
import { formatCurrency } from '../utils/helpers';
import { 
  FileText, 
  Calendar, 
  TrendingUp, 
  Search,
  Eye,
  ShoppingBag,
  CreditCard
} from 'lucide-react';
import toast from 'react-hot-toast';
import TransactionDetailModal from '../components/TransactionDetailModal';
import { LineChart, Line, BarChart, Bar, PieChart, Pie, Cell, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';

const COLORS = ['#3b82f6', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6', '#ec4899'];

const ReportsPage = () => {
  const [transactions, setTransactions] = useState([]);
  const [dailyReport, setDailyReport] = useState(null);
  const [monthlyReport, setMonthlyReport] = useState(null);
  const [salesTrend, setSalesTrend] = useState([]);
  const [topProducts, setTopProducts] = useState([]);
  const [paymentMethods, setPaymentMethods] = useState([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState('transactions');
  const [dateFilter, setDateFilter] = useState('');
  const [startDate, setStartDate] = useState('');
  const [endDate, setEndDate] = useState('');
  const [searchTerm, setSearchTerm] = useState('');
  const [cashierFilter, setCashierFilter] = useState('');
  const [paymentFilter, setPaymentFilter] = useState('');
  const [selectedTransactionId, setSelectedTransactionId] = useState(null);
  const [cashiers, setCashiers] = useState([]);

  useEffect(() => {
    fetchData();
    
    // Auto refresh every 30 seconds for today's data
    const interval = setInterval(() => {
      const today = new Date().toISOString().split('T')[0];
      fetchDailyReport(today);
    }, 30000);
    
    return () => clearInterval(interval);
  }, []);

  const fetchData = async () => {
    try {
      const today = new Date();
      const dateStr = today.toISOString().split('T')[0];
      const month = today.getMonth() + 1;
      const year = today.getFullYear();

      const [transactionsRes, dailyRes, monthlyRes, trendRes, topProductsRes] = await Promise.all([
        transactionsAPI.getAll(),
        transactionsAPI.getDailyReport(dateStr),
        transactionsAPI.getMonthlyReport(`${year}-${month.toString().padStart(2, '0')}`),
        dashboardAPI.getSalesTrend(30),
        dashboardAPI.getTopProducts(5)
      ]);

      const txData = transactionsRes.data.data.transactions || [];
      setTransactions(txData);
      setDailyReport(dailyRes.data.data);
      setMonthlyReport(monthlyRes.data.data.report);
      
      // Extract unique cashiers
      const uniqueCashiers = [...new Set(txData.map(tx => tx.cashier_name).filter(Boolean))];
      setCashiers(uniqueCashiers);
      
      // Process sales trend
      const trend = trendRes.data.data || [];
      setSalesTrend(trend.map(item => ({
        date: new Date(item.date).toLocaleDateString('id-ID', { day: '2-digit', month: 'short' }),
        penjualan: item.total_sales,
        profit: item.total_profit
      })));

      // Process top products
      const products = topProductsRes.data.data || [];
      setTopProducts(products.map(item => ({
        name: item.product_name,
        qty: item.total_qty,
        revenue: item.total_revenue
      })));

      // Process payment methods
      const paymentStats = {};
      txData.forEach(tx => {
        const method = tx.payment_method || 'Cash';
        paymentStats[method] = (paymentStats[method] || 0) + 1;
      });
      setPaymentMethods(Object.entries(paymentStats).map(([name, value]) => ({ name, value })));

    } catch (error) {
      console.error('Error fetching reports:', error);
      toast.error('Gagal memuat data laporan');
    } finally {
      setLoading(false);
    }
  };

  const fetchDailyReport = async (date) => {
    try {
      const response = await transactionsAPI.getDailyReport(date);
      setDailyReport(response.data.data);
    } catch (error) {
      toast.error('Gagal memuat laporan harian');
    }
  };

  const fetchMonthlyReport = async (month) => {
    try {
      const response = await transactionsAPI.getMonthlyReport(month);
      setMonthlyReport(response.data.data.report);
    } catch (error) {
      toast.error('Gagal memuat laporan bulanan');
    }
  };

  const setQuickFilter = (days) => {
    const end = new Date();
    const start = new Date();
    start.setDate(start.getDate() - days);
    setStartDate(start.toISOString().split('T')[0]);
    setEndDate(end.toISOString().split('T')[0]);
  };

  const filteredTransactions = transactions.filter(transaction => {
    const matchesSearch = transaction.id.toString().includes(searchTerm) ||
                         transaction.cashier_name?.toLowerCase().includes(searchTerm.toLowerCase());
    const txDate = new Date(transaction.created_at).toISOString().split('T')[0];
    const matchesDateRange = (!startDate || txDate >= startDate) && (!endDate || txDate <= endDate);
    const matchesDateFilter = !dateFilter || transaction.created_at.startsWith(dateFilter);
    const matchesCashier = !cashierFilter || transaction.cashier_name === cashierFilter;
    const matchesPayment = !paymentFilter || transaction.payment_method === paymentFilter;
    return matchesSearch && (matchesDateRange || matchesDateFilter) && matchesCashier && matchesPayment;
  });

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">Laporan</h1>
      </div>

      {/* Tabs */}
      <div className="border-b border-gray-200 dark:border-gray-700">
        <nav className="-mb-px flex space-x-8">
          {[
            { id: 'overview', name: 'Overview', icon: TrendingUp },
            { id: 'transactions', name: 'Transaksi', icon: FileText },
            { id: 'daily', name: 'Laporan Harian', icon: Calendar },
            { id: 'monthly', name: 'Laporan Bulanan', icon: TrendingUp }
          ].map((tab) => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={`flex items-center space-x-2 py-2 px-1 border-b-2 font-medium text-sm ${
                activeTab === tab.id
                  ? 'border-primary text-primary'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 dark:text-gray-400 dark:hover:text-gray-300'
              }`}
            >
              <tab.icon className="w-4 h-4" />
              <span>{tab.name}</span>
            </button>
          ))}
        </nav>
      </div>

      {/* Overview Tab */}
      {activeTab === 'overview' && (
        <div className="space-y-6">
          {/* Trend Penjualan */}
          <div className="card">
            <h3 className="text-lg font-semibold mb-4 text-gray-900 dark:text-gray-100">Trend Penjualan 30 Hari Terakhir</h3>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={salesTrend}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="date" />
                <YAxis />
                <Tooltip formatter={(value) => formatCurrency(value)} />
                <Legend />
                <Line type="monotone" dataKey="penjualan" stroke="#3b82f6" strokeWidth={2} name="Penjualan" />
                <Line type="monotone" dataKey="profit" stroke="#10b981" strokeWidth={2} name="Profit" />
              </LineChart>
            </ResponsiveContainer>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            {/* Top Products */}
            <div className="card">
              <h3 className="text-lg font-semibold mb-4 text-gray-900 dark:text-gray-100 flex items-center">
                <ShoppingBag className="w-5 h-5 mr-2" />
                Top 5 Produk Terlaris
              </h3>
              <ResponsiveContainer width="100%" height={300}>
                <BarChart data={topProducts}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="name" />
                  <YAxis />
                  <Tooltip formatter={(value, name) => name === 'revenue' ? formatCurrency(value) : value} />
                  <Legend />
                  <Bar dataKey="qty" fill="#3b82f6" name="Qty Terjual" />
                  <Bar dataKey="revenue" fill="#10b981" name="Revenue" />
                </BarChart>
              </ResponsiveContainer>
            </div>

            {/* Payment Methods */}
            <div className="card">
              <h3 className="text-lg font-semibold mb-4 text-gray-900 dark:text-gray-100 flex items-center">
                <CreditCard className="w-5 h-5 mr-2" />
                Metode Pembayaran
              </h3>
              <ResponsiveContainer width="100%" height={300}>
                <PieChart>
                  <Pie
                    data={paymentMethods}
                    cx="50%"
                    cy="50%"
                    labelLine={false}
                    label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                    outerRadius={80}
                    fill="#8884d8"
                    dataKey="value"
                  >
                    {paymentMethods.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip />
                </PieChart>
              </ResponsiveContainer>
            </div>
          </div>
        </div>
      )}

      {/* Transactions Tab */}
      {activeTab === 'transactions' && (
        <div className="card">
          {/* Quick Filters */}
          <div className="flex flex-wrap gap-2 mb-4">
            <button onClick={() => setQuickFilter(0)} className="btn btn-sm bg-gray-100 hover:bg-gray-200 text-gray-700 dark:bg-gray-700 dark:text-gray-300">
              Hari Ini
            </button>
            <button onClick={() => setQuickFilter(1)} className="btn btn-sm bg-gray-100 hover:bg-gray-200 text-gray-700 dark:bg-gray-700 dark:text-gray-300">
              Kemarin
            </button>
            <button onClick={() => setQuickFilter(7)} className="btn btn-sm bg-gray-100 hover:bg-gray-200 text-gray-700 dark:bg-gray-700 dark:text-gray-300">
              7 Hari Terakhir
            </button>
            <button onClick={() => setQuickFilter(30)} className="btn btn-sm bg-gray-100 hover:bg-gray-200 text-gray-700 dark:bg-gray-700 dark:text-gray-300">
              30 Hari Terakhir
            </button>
            <button onClick={() => { setStartDate(''); setEndDate(''); setDateFilter(''); }} className="btn btn-sm bg-gray-100 hover:bg-gray-200 text-gray-700 dark:bg-gray-700 dark:text-gray-300">
              Reset
            </button>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-4 mb-6">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
              <input
                type="text"
                placeholder="Cari transaksi..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="input pl-10"
              />
            </div>
            <input
              type="date"
              placeholder="Dari Tanggal"
              value={startDate}
              onChange={(e) => setStartDate(e.target.value)}
              className="input"
            />
            <input
              type="date"
              placeholder="Sampai Tanggal"
              value={endDate}
              onChange={(e) => setEndDate(e.target.value)}
              className="input"
            />
            <select
              value={cashierFilter}
              onChange={(e) => setCashierFilter(e.target.value)}
              className="input"
            >
              <option value="">Semua Kasir</option>
              {cashiers.map(cashier => (
                <option key={cashier} value={cashier}>{cashier}</option>
              ))}
            </select>
            <select
              value={paymentFilter}
              onChange={(e) => setPaymentFilter(e.target.value)}
              className="input"
            >
              <option value="">Semua Pembayaran</option>
              <option value="Cash">Cash</option>
              <option value="Debit">Debit</option>
              <option value="Credit">Credit</option>
              <option value="E-Wallet">E-Wallet</option>
            </select>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-gray-200 dark:border-gray-700">
                  <th className="text-left py-3 px-4 font-medium text-gray-900 dark:text-gray-100">ID</th>
                  <th className="text-left py-3 px-4 font-medium text-gray-900 dark:text-gray-100">Tanggal</th>
                  <th className="text-left py-3 px-4 font-medium text-gray-900 dark:text-gray-100">Kasir</th>
                  <th className="text-left py-3 px-4 font-medium text-gray-900 dark:text-gray-100">Total</th>
                  <th className="text-left py-3 px-4 font-medium text-gray-900 dark:text-gray-100">Pembayaran</th>
                  <th className="text-left py-3 px-4 font-medium text-gray-900 dark:text-gray-100">Aksi</th>
                </tr>
              </thead>
              <tbody>
                {filteredTransactions.map((transaction) => (
                  <tr key={transaction.id} className="border-b border-gray-100 dark:border-gray-800 hover:bg-gray-50 dark:hover:bg-gray-800">
                    <td className="py-3 px-4 font-mono text-sm">#{transaction.id}</td>
                    <td className="py-3 px-4 text-gray-900 dark:text-gray-100">
                      {new Date(transaction.created_at).toLocaleDateString('id-ID')}
                    </td>
                    <td className="py-3 px-4 text-gray-900 dark:text-gray-100">
                      {transaction.cashier_name || 'System'}
                    </td>
                    <td className="py-3 px-4 text-gray-900 dark:text-gray-100 font-medium">
                      {formatCurrency(transaction.total_amount)}
                    </td>
                    <td className="py-3 px-4">
                      <span className="px-2 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200">
                        {transaction.payment_method}
                      </span>
                    </td>
                    <td className="py-3 px-4">
                      <button 
                        onClick={() => setSelectedTransactionId(transaction.id)}
                        className="p-1 hover:bg-gray-100 dark:hover:bg-gray-700 rounded"
                      >
                        <Eye className="w-4 h-4 text-gray-600 dark:text-gray-400" />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Daily Report Tab */}
      {activeTab === 'daily' && (
        <div className="space-y-6">
          <div className="flex items-center space-x-4">
            <input
              type="date"
              value={dateFilter || new Date().toISOString().split('T')[0]}
              onChange={(e) => {
                setDateFilter(e.target.value);
                fetchDailyReport(e.target.value);
              }}
              className="input"
            />
          </div>

          {dailyReport && (
            <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
              <div className="card">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm font-medium text-gray-600 dark:text-gray-400">Total Transaksi</p>
                    <p className="text-2xl font-bold text-gray-900 dark:text-gray-100">{dailyReport.transaction_count || 0}</p>
                  </div>
                  <FileText className="w-8 h-8 text-primary" />
                </div>
              </div>

              <div className="card">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm font-medium text-gray-600 dark:text-gray-400">Total Penjualan</p>
                    <p className="text-2xl font-bold text-gray-900 dark:text-gray-100">
                      {formatCurrency(dailyReport.total_sales || 0)}
                    </p>
                  </div>
                  <TrendingUp className="w-8 h-8 text-green-500" />
                </div>
              </div>

              <div className="card">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm font-medium text-gray-600 dark:text-gray-400">Rata-rata per Transaksi</p>
                    <p className="text-2xl font-bold text-gray-900 dark:text-gray-100">
                      {formatCurrency((dailyReport.total_sales || 0) / (dailyReport.transaction_count || 1))}
                    </p>
                  </div>
                  <Calendar className="w-8 h-8 text-blue-500" />
                </div>
              </div>

              <div className="card">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm font-medium text-gray-600 dark:text-gray-400">Total Profit</p>
                    <p className="text-2xl font-bold text-gray-900 dark:text-gray-100">{formatCurrency(dailyReport.total_profit || 0)}</p>
                  </div>
                  <FileText className="w-8 h-8 text-orange-500" />
                </div>
              </div>
            </div>
          )}
        </div>
      )}

      {/* Monthly Report Tab */}
      {activeTab === 'monthly' && (
        <div className="space-y-6">
          <div className="flex items-center space-x-4">
            <input
              type="month"
              value={dateFilter || new Date().toISOString().slice(0, 7)}
              onChange={(e) => {
                setDateFilter(e.target.value);
                fetchMonthlyReport(e.target.value);
              }}
              className="input"
            />
          </div>

          {monthlyReport && (
            <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
              <div className="card">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm font-medium text-gray-600 dark:text-gray-400">Total Transaksi</p>
                    <p className="text-2xl font-bold text-gray-900 dark:text-gray-100">{monthlyReport.transaction_count || 0}</p>
                  </div>
                  <FileText className="w-8 h-8 text-primary" />
                </div>
              </div>

              <div className="card">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm font-medium text-gray-600 dark:text-gray-400">Total Penjualan</p>
                    <p className="text-2xl font-bold text-gray-900 dark:text-gray-100">
                      {formatCurrency(monthlyReport.total_sales || 0)}
                    </p>
                  </div>
                  <TrendingUp className="w-8 h-8 text-green-500" />
                </div>
              </div>

              <div className="card">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm font-medium text-gray-600 dark:text-gray-400">Rata-rata Transaksi</p>
                    <p className="text-2xl font-bold text-gray-900 dark:text-gray-100">
                      {formatCurrency(monthlyReport.avg_transaction || 0)}
                    </p>
                  </div>
                  <Calendar className="w-8 h-8 text-blue-500" />
                </div>
              </div>

              <div className="card">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm font-medium text-gray-600 dark:text-gray-400">Total Profit</p>
                    <p className="text-2xl font-bold text-gray-900 dark:text-gray-100">
                      {formatCurrency(monthlyReport.total_profit || 0)}
                    </p>
                  </div>
                  <TrendingUp className="w-8 h-8 text-green-500" />
                </div>
              </div>
            </div>
          )}
        </div>
      )}
      
      {/* Transaction Detail Modal */}
      {selectedTransactionId && (
        <TransactionDetailModal
          transactionId={selectedTransactionId}
          onClose={() => setSelectedTransactionId(null)}
        />
      )}
    </div>
  );
};

export default ReportsPage;

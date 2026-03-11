import React, { useState, useEffect } from 'react';
import { TrendingUp, TrendingDown, DollarSign, BarChart3, Calendar } from 'lucide-react';
import { profitAPI } from '../utils/api';
import toast from 'react-hot-toast';

const ProfitAnalysis = () => {
  const [profitSummary, setProfitSummary] = useState(null);
  const [productProfits, setProductProfits] = useState([]);
  const [dailyTrend, setDailyTrend] = useState([]);
  const [dateRange, setDateRange] = useState({
    start_date: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
    end_date: new Date().toISOString().split('T')[0]
  });
  const [loading, setLoading] = useState(true);

  const fetchProfitData = async () => {
    try {
      setLoading(true);
      
      const [summaryRes, productsRes, trendRes] = await Promise.all([
        profitAPI.getSummary(dateRange),
        profitAPI.getProducts(dateRange),
        profitAPI.getTrend()
      ]);

      setProfitSummary(summaryRes.data);
      setProductProfits(productsRes.data || []);
      setDailyTrend(trendRes.data || []);
    } catch (error) {
      toast.error('Gagal memuat data profit');
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchProfitData();
  }, [dateRange]);

  const formatCurrency = (amount) => {
    return new Intl.NumberFormat('id-ID', {
      style: 'currency',
      currency: 'IDR',
      minimumFractionDigits: 0
    }).format(amount);
  };

  const formatPercent = (percent) => {
    return `${percent.toFixed(1)}%`;
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Analisis Keuntungan</h1>
      </div>

      {/* Date Range Filter */}
      <div className="card">
        <div className="flex flex-col md:flex-row gap-4">
          <div className="flex-1">
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Tanggal Mulai</label>
            <input
              type="date"
              value={dateRange.start_date}
              onChange={(e) => setDateRange({ ...dateRange, start_date: e.target.value })}
              className="input"
            />
          </div>
          <div className="flex-1">
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Tanggal Akhir</label>
            <input
              type="date"
              value={dateRange.end_date}
              onChange={(e) => setDateRange({ ...dateRange, end_date: e.target.value })}
              className="input"
            />
          </div>
        </div>
        <div className="flex gap-2 mt-4">
          <button
            onClick={() => setDateRange({
              start_date: new Date().toISOString().split('T')[0],
              end_date: new Date().toISOString().split('T')[0]
            })}
            className="px-3 py-1 text-sm bg-gray-100 hover:bg-gray-200 dark:bg-gray-700 dark:hover:bg-gray-600 rounded-lg"
          >
            Hari Ini
          </button>
          <button
            onClick={() => setDateRange({
              start_date: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
              end_date: new Date().toISOString().split('T')[0]
            })}
            className="px-3 py-1 text-sm bg-gray-100 hover:bg-gray-200 dark:bg-gray-700 dark:hover:bg-gray-600 rounded-lg"
          >
            7 Hari
          </button>
          <button
            onClick={() => setDateRange({
              start_date: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
              end_date: new Date().toISOString().split('T')[0]
            })}
            className="px-3 py-1 text-sm bg-gray-100 hover:bg-gray-200 dark:bg-gray-700 dark:hover:bg-gray-600 rounded-lg"
          >
            30 Hari
          </button>
          <button
            onClick={() => {
              const now = new Date();
              const firstDay = new Date(now.getFullYear(), now.getMonth(), 1);
              setDateRange({
                start_date: firstDay.toISOString().split('T')[0],
                end_date: new Date().toISOString().split('T')[0]
              });
            }}
            className="px-3 py-1 text-sm bg-gray-100 hover:bg-gray-200 dark:bg-gray-700 dark:hover:bg-gray-600 rounded-lg"
          >
            Bulan Ini
          </button>
          <button
            onClick={() => {
              const now = new Date();
              const firstDay = new Date(now.getFullYear(), 0, 1);
              setDateRange({
                start_date: firstDay.toISOString().split('T')[0],
                end_date: new Date().toISOString().split('T')[0]
              });
            }}
            className="px-3 py-1 text-sm bg-gray-100 hover:bg-gray-200 dark:bg-gray-700 dark:hover:bg-gray-600 rounded-lg"
          >
            Tahun Ini
          </button>
        </div>
      </div>

      {/* Summary Cards */}
      {profitSummary && (
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
          <div className="bg-white p-6 rounded-lg shadow-md">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-600 dark:text-gray-400">Total Pendapatan</p>
                <p className="text-2xl font-bold text-green-600">
                  {formatCurrency(profitSummary.total_revenue)}
                </p>
              </div>
              <DollarSign className="h-8 w-8 text-green-600" />
            </div>
          </div>

          <div className="bg-white p-6 rounded-lg shadow-md">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-600 dark:text-gray-400">Total Biaya</p>
                <p className="text-2xl font-bold text-red-600">
                  {formatCurrency(profitSummary.total_cost)}
                </p>
              </div>
              <TrendingDown className="h-8 w-8 text-red-600" />
            </div>
          </div>

          <div className="bg-white p-6 rounded-lg shadow-md">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-600 dark:text-gray-400">Keuntungan Bersih</p>
                <p className={`text-2xl font-bold ${profitSummary.total_profit >= 0 ? 'text-green-600' : 'text-red-600'}`}>
                  {formatCurrency(profitSummary.total_profit)}
                </p>
              </div>
              <TrendingUp className={`h-8 w-8 ${profitSummary.total_profit >= 0 ? 'text-green-600' : 'text-red-600'}`} />
            </div>
          </div>

          <div className="bg-white p-6 rounded-lg shadow-md">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-600 dark:text-gray-400">Margin Keuntungan</p>
                <p className={`text-2xl font-bold ${profitSummary.profit_margin >= 0 ? 'text-green-600' : 'text-red-600'}`}>
                  {formatPercent(profitSummary.profit_margin)}
                </p>
              </div>
              <BarChart3 className={`h-8 w-8 ${profitSummary.profit_margin >= 0 ? 'text-green-600' : 'text-red-600'}`} />
            </div>
          </div>
        </div>
      )}

      {/* Daily Trend Chart */}
      <div className="bg-white p-6 rounded-lg shadow-md">
        <h2 className="text-lg font-semibold mb-4 text-gray-900 dark:text-white">Tren Keuntungan 7 Hari Terakhir</h2>
        <div className="space-y-2">
          {dailyTrend.map((day, index) => (
            <div key={index} className="flex items-center justify-between p-3 bg-gray-50 rounded">
              <span className="font-medium text-gray-900">{new Date(day.date).toLocaleDateString('id-ID')}</span>
              <div className="flex gap-4 text-sm">
                <span className="text-green-700 font-medium">Pendapatan: {formatCurrency(day.revenue)}</span>
                <span className="text-red-700 font-medium">Biaya: {formatCurrency(day.cost)}</span>
                <span className={`font-bold ${day.profit >= 0 ? 'text-green-700' : 'text-red-700'}`}>
                  Profit: {formatCurrency(day.profit)}
                </span>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Product Profit Analysis */}
      <div className="bg-white p-6 rounded-lg shadow-md">
        <h2 className="text-lg font-semibold mb-4 text-gray-900 dark:text-white">Analisis Keuntungan per Produk</h2>
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">
                  Produk
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">
                  Terjual
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">
                  Pendapatan
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">
                  Biaya
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">
                  Keuntungan
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">
                  Margin
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {productProfits.map((product, index) => (
                <tr key={index}>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    {product.product_name}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {product.total_sold}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-green-700">
                    {formatCurrency(product.revenue)}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-red-700">
                    {formatCurrency(product.cost)}
                  </td>
                  <td className={`px-6 py-4 whitespace-nowrap text-sm font-medium ${product.profit >= 0 ? 'text-green-700' : 'text-red-700'}`}>
                    {formatCurrency(product.profit)}
                  </td>
                  <td className={`px-6 py-4 whitespace-nowrap text-sm font-medium ${product.profit_margin >= 0 ? 'text-green-700' : 'text-red-700'}`}>
                    {formatPercent(product.profit_margin)}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default ProfitAnalysis;

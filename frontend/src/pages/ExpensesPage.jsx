import React, { useState, useEffect } from 'react';
import { expensesAPI } from '../utils/api';
import { formatCurrency } from '../utils/helpers';
import { Plus, Edit, Trash2, DollarSign, Search, Calendar } from 'lucide-react';
import toast from 'react-hot-toast';

const ExpensesPage = () => {
  const [expenses, setExpenses] = useState([]);
  const [summary, setSummary] = useState({ total_amount: 0, by_category: {}, count: 0 });
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [editingExpense, setEditingExpense] = useState(null);
  const [period, setPeriod] = useState('month');
  const [searchTerm, setSearchTerm] = useState('');
  const [formData, setFormData] = useState({
    date: new Date().toISOString().split('T')[0],
    category: '',
    description: '',
    amount: ''
  });

  const categories = [
    'Gaji Karyawan',
    'Listrik & Air',
    'Sewa Tempat',
    'Transportasi',
    'Peralatan',
    'Bahan Baku',
    'Lain-lain'
  ];

  useEffect(() => {
    fetchExpenses();
    fetchSummary();
  }, [period, searchTerm]);

  const fetchExpenses = async () => {
    try {
      const response = await expensesAPI.getAll({ period, search: searchTerm });
      setExpenses(response.data.data || []);
    } catch (error) {
      toast.error('Gagal memuat data pengeluaran');
    } finally {
      setLoading(false);
    }
  };

  const fetchSummary = async () => {
    try {
      const response = await expensesAPI.getSummary({ period });
      setSummary(response.data.data);
    } catch (error) {
      console.error('Failed to fetch summary:', error);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const data = {
        date: formData.date,
        category: formData.category,
        description: formData.description,
        amount: parseFloat(formData.amount)
      };

      if (editingExpense) {
        await expensesAPI.update(editingExpense.id, data);
        toast.success('Pengeluaran berhasil diperbarui');
      } else {
        await expensesAPI.create(data);
        toast.success('Pengeluaran berhasil ditambahkan');
      }

      setShowModal(false);
      setEditingExpense(null);
      setFormData({ date: new Date().toISOString().split('T')[0], category: '', description: '', amount: '' });
      fetchExpenses();
      fetchSummary();
    } catch (error) {
      toast.error(error.response?.data?.message || 'Gagal menyimpan pengeluaran');
    }
  };

  const handleEdit = (expense) => {
    setEditingExpense(expense);
    setFormData({
      date: new Date(expense.date).toISOString().split('T')[0],
      category: expense.category,
      description: expense.description,
      amount: expense.amount.toString()
    });
    setShowModal(true);
  };

  const handleDelete = async (id) => {
    if (window.confirm('Yakin ingin menghapus pengeluaran ini?')) {
      try {
        await expensesAPI.delete(id);
        toast.success('Pengeluaran berhasil dihapus');
        fetchExpenses();
        fetchSummary();
      } catch (error) {
        toast.error('Gagal menghapus pengeluaran');
      }
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold text-gray-900">Pengeluaran</h1>
        <button
          onClick={() => {
            setEditingExpense(null);
            setFormData({ date: new Date().toISOString().split('T')[0], category: '', description: '', amount: '' });
            setShowModal(true);
          }}
          className="btn btn-primary flex items-center space-x-2"
        >
          <Plus className="w-4 h-4" />
          <span>Tambah Pengeluaran</span>
        </button>
      </div>

      {/* Summary Card */}
      <div className="card bg-gradient-to-r from-red-500 to-red-600 text-white">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-red-100 text-sm mb-1">Total Pengeluaran</p>
            <h2 className="text-3xl font-bold">{formatCurrency(summary.total_amount)}</h2>
            <p className="text-red-100 text-sm mt-1">{summary.count} transaksi</p>
          </div>
          <DollarSign className="w-16 h-16 text-red-200 opacity-50" />
        </div>
      </div>

      {/* Filters */}
      <div className="card">
        <div className="flex flex-col md:flex-row gap-4">
          <div className="flex-1">
            <label className="block text-sm font-medium text-gray-700 mb-2">Periode</label>
            <select
              value={period}
              onChange={(e) => setPeriod(e.target.value)}
              className="input"
            >
              <option value="today">Hari Ini</option>
              <option value="week">Minggu Ini</option>
              <option value="month">Bulan Ini</option>
              <option value="year">Tahun Ini</option>
            </select>
          </div>
          <div className="flex-1">
            <label className="block text-sm font-medium text-gray-700 mb-2">Cari</label>
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
              <input
                type="text"
                placeholder="Cari keterangan atau kategori..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="input pl-10"
              />
            </div>
          </div>
        </div>
      </div>

      {/* Category Breakdown */}
      {Object.keys(summary.by_category).length > 0 && (
        <div className="card">
          <h3 className="font-semibold text-gray-900 mb-4">Breakdown per Kategori</h3>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            {Object.entries(summary.by_category).map(([category, amount]) => (
              <div key={category} className="bg-gray-50 p-4 rounded-lg">
                <p className="text-sm text-gray-600 mb-1">{category}</p>
                <p className="text-lg font-bold text-gray-900">{formatCurrency(amount)}</p>
                <p className="text-xs text-gray-500">
                  {((amount / summary.total_amount) * 100).toFixed(1)}%
                </p>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Expenses Table */}
      <div className="card">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b border-gray-200">
                <th className="text-left py-3 px-4 font-medium text-gray-900">Tanggal</th>
                <th className="text-left py-3 px-4 font-medium text-gray-900">Kategori</th>
                <th className="text-left py-3 px-4 font-medium text-gray-900">Keterangan</th>
                <th className="text-right py-3 px-4 font-medium text-gray-900">Jumlah</th>
                <th className="text-center py-3 px-4 font-medium text-gray-900">Aksi</th>
              </tr>
            </thead>
            <tbody>
              {expenses.length === 0 ? (
                <tr>
                  <td colSpan="5" className="text-center py-8 text-gray-500">
                    Belum ada data pengeluaran
                  </td>
                </tr>
              ) : (
                expenses.map((expense) => (
                  <tr key={expense.id} className="border-b border-gray-100 hover:bg-gray-50">
                    <td className="py-3 px-4 text-gray-900">
                      {new Date(expense.date).toLocaleDateString('id-ID')}
                    </td>
                    <td className="py-3 px-4">
                      <span className="px-2 py-1 bg-blue-100 text-blue-800 text-xs rounded-full">
                        {expense.category}
                      </span>
                    </td>
                    <td className="py-3 px-4 text-gray-900">{expense.description}</td>
                    <td className="py-3 px-4 text-right font-semibold text-red-600">
                      {formatCurrency(expense.amount)}
                    </td>
                    <td className="py-3 px-4">
                      <div className="flex items-center justify-center space-x-2">
                        <button
                          onClick={() => handleEdit(expense)}
                          className="p-1 hover:bg-gray-100 rounded"
                        >
                          <Edit className="w-4 h-4 text-gray-600" />
                        </button>
                        <button
                          onClick={() => handleDelete(expense.id)}
                          className="p-1 hover:bg-gray-100 rounded"
                        >
                          <Trash2 className="w-4 h-4 text-red-600" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-md">
            <h2 className="text-lg font-semibold mb-4">
              {editingExpense ? 'Edit Pengeluaran' : 'Tambah Pengeluaran'}
            </h2>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Tanggal</label>
                <input
                  type="date"
                  value={formData.date}
                  onChange={(e) => setFormData({ ...formData, date: e.target.value })}
                  className="input"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Kategori</label>
                <select
                  value={formData.category}
                  onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                  className="input"
                  required
                >
                  <option value="">Pilih kategori</option>
                  {categories.map((cat) => (
                    <option key={cat} value={cat}>{cat}</option>
                  ))}
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Keterangan</label>
                <textarea
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  className="input"
                  rows="3"
                  placeholder="Deskripsi pengeluaran..."
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Jumlah (Rp)</label>
                <input
                  type="number"
                  step="0.01"
                  value={formData.amount}
                  onChange={(e) => setFormData({ ...formData, amount: e.target.value })}
                  className="input"
                  placeholder="0"
                  required
                  min="0.01"
                />
              </div>
              <div className="flex justify-end space-x-3">
                <button
                  type="button"
                  onClick={() => {
                    setShowModal(false);
                    setEditingExpense(null);
                    setFormData({ date: new Date().toISOString().split('T')[0], category: '', description: '', amount: '' });
                  }}
                  className="px-4 py-2 text-gray-600 hover:bg-gray-100 rounded-lg"
                >
                  Batal
                </button>
                <button type="submit" className="btn btn-primary">
                  {editingExpense ? 'Perbarui' : 'Simpan'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default ExpensesPage;

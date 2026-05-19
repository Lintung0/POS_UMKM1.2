import React, { useState, useEffect } from 'react';
import { expensesAPI } from '../utils/api';
import { formatCurrency } from '../utils/helpers';
import { Plus, Edit, Trash2, DollarSign, Search } from 'lucide-react';
import toast from 'react-hot-toast';
import Pagination from '../components/Pagination';
import DateRangeFilter from '../components/DateRangeFilter';
import ConfirmDialog from '../components/ConfirmDialog';

const ExpensesPage = () => {
  const [expenses, setExpenses] = useState([]);
  const [summary, setSummary] = useState({ total_amount: 0, by_category: {}, count: 0 });
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [editingExpense, setEditingExpense] = useState(null);
  const [deleteConfirm, setDeleteConfirm] = useState({ isOpen: false, id: null });
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const itemsPerPage = 15;
  const [dateRange, setDateRange] = useState({
    start_date: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
    end_date: new Date().toISOString().split('T')[0]
  });
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
  }, [dateRange, searchTerm, currentPage]);

  const fetchExpenses = async () => {
    try {
      const response = await expensesAPI.getAll({ 
        start_date: dateRange.start_date, 
        end_date: dateRange.end_date, 
        search: searchTerm 
      });
      const allExpenses = response.data.data || [];
      
      // Client-side pagination
      const startIndex = (currentPage - 1) * itemsPerPage;
      const endIndex = startIndex + itemsPerPage;
      setExpenses(allExpenses.slice(startIndex, endIndex));
      setTotalPages(Math.ceil(allExpenses.length / itemsPerPage));
    } catch (error) {
      toast.error('Gagal memuat data pengeluaran');
    } finally {
      setLoading(false);
    }
  };

  const fetchSummary = async () => {
    try {
      const response = await expensesAPI.getSummary({ 
        start_date: dateRange.start_date, 
        end_date: dateRange.end_date 
      });
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
    setDeleteConfirm({ isOpen: true, id });
  };

  const confirmDelete = async () => {
    try {
      await expensesAPI.delete(deleteConfirm.id);
      toast.success('Pengeluaran berhasil dihapus');
      fetchExpenses();
      fetchSummary();
    } catch (error) {
      toast.error('Gagal menghapus pengeluaran');
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
        <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Pengeluaran</h1>
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
      <div className="space-y-4">
        <DateRangeFilter value={dateRange} onChange={setDateRange} />
        <div className="card">
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

      {/* Category Breakdown */}
      {Object.keys(summary.by_category).length > 0 && (
        <div className="card">
          <h3 className="font-semibold text-gray-900 mb-4">Breakdown per Kategori</h3>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            {Object.entries(summary.by_category).map(([category, amount]) => (
              <div key={category} className="bg-gray-50 dark:bg-gray-700 p-4 rounded-lg">
                <p className="text-sm text-gray-600 dark:text-gray-400 mb-1">{category}</p>
                <p className="text-lg font-bold text-gray-900 dark:text-white">{formatCurrency(amount)}</p>
                <p className="text-xs text-gray-500 dark:text-gray-400">
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
                <th className="text-left py-3 px-4 font-medium text-gray-900 dark:text-white">Tanggal</th>
                <th className="text-left py-3 px-4 font-medium text-gray-900 dark:text-white">Kategori</th>
                <th className="text-left py-3 px-4 font-medium text-gray-900 dark:text-white">Keterangan</th>
                <th className="text-right py-3 px-4 font-medium text-gray-900 dark:text-white">Jumlah</th>
                <th className="text-center py-3 px-4 font-medium text-gray-900 dark:text-white">Aksi</th>
              </tr>
            </thead>
            <tbody>
              {expenses.length === 0 ? (
                <tr>
                  <td colSpan="5" className="text-center py-8 text-gray-500 dark:text-gray-400">
                    Belum ada data pengeluaran
                  </td>
                </tr>
              ) : (
                expenses.map((expense) => (
                  <tr key={expense.id} className="border-b border-gray-100 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-700">
                    <td className="py-3 px-4 text-gray-900 dark:text-white">
                      {new Date(expense.date).toLocaleDateString('id-ID')}
                    </td>
                    <td className="py-3 px-4">
                      <span className="px-2 py-1 bg-blue-100 text-blue-800 text-xs rounded-full">
                        {expense.category}
                      </span>
                    </td>
                    <td className="py-3 px-4 text-gray-900 dark:text-white">{expense.description}</td>
                    <td className="py-3 px-4 text-right font-semibold text-red-600">
                      {formatCurrency(expense.amount)}
                    </td>
                    <td className="py-3 px-4">
                      <div className="flex items-center justify-center space-x-2">
                        <button
                          onClick={() => handleEdit(expense)}
                          className="p-1 hover:bg-gray-100 dark:hover:bg-gray-600 rounded"
                        >
                          <Edit className="w-4 h-4 text-gray-600 dark:text-gray-400" />
                        </button>
                        <button
                          onClick={() => handleDelete(expense.id)}
                          className="p-1 hover:bg-gray-100 dark:hover:bg-gray-600 rounded"
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
        <Pagination 
          currentPage={currentPage}
          totalPages={totalPages}
          onPageChange={setCurrentPage}
        />
      </div>

      {/* Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white dark:bg-gray-800 rounded-lg p-6 w-full max-w-md">
            <h2 className="text-lg font-semibold mb-4 text-gray-900 dark:text-white">
              {editingExpense ? 'Edit Pengeluaran' : 'Tambah Pengeluaran'}
            </h2>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Tanggal</label>
                <input
                  type="date"
                  value={formData.date}
                  onChange={(e) => setFormData({ ...formData, date: e.target.value })}
                  className="input"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Kategori</label>
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
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Keterangan</label>
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
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Jumlah (Rp)</label>
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
                  className="px-4 py-2 text-gray-600 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg"
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
      <ConfirmDialog
        isOpen={deleteConfirm.isOpen}
        onClose={() => setDeleteConfirm({ isOpen: false, id: null })}
        onConfirm={confirmDelete}
        title="Hapus Pengeluaran"
        message="Yakin ingin menghapus pengeluaran ini?"
        type="danger"
      />
    </div>
  );
};

export default ExpensesPage;

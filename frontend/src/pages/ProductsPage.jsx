import React, { useState, useEffect } from 'react';
import { productsAPI } from '../utils/api';
import { formatCurrency } from '../utils/helpers';
import { Plus, Edit, Trash2, Package, Search, ChefHat } from 'lucide-react';
import toast from 'react-hot-toast';
import RecipesPage from './RecipesPage';
import { useAuth } from '../context/AuthContext';
import ConfirmDialog from '../components/ConfirmDialog';
import { usePageRefresh } from '../utils/hooks';
import Pagination from '../components/Pagination';

const ProductsPage = () => {
  const { user, isAuthenticated } = useAuth();
  const [products, setProducts] = useState([]);
  const [allProducts, setAllProducts] = useState([]);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const itemsPerPage = 15;
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [editingProduct, setEditingProduct] = useState(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [showRecipes, setShowRecipes] = useState(false);
  const [selectedProductId, setSelectedProductId] = useState(null);
  const [deleteConfirm, setDeleteConfirm] = useState({ isOpen: false, productId: null });
  const [formData, setFormData] = useState({
    name: '',
    category: '',
    price: '',
    cost: '',
    stock: '',
    description: '',
    image: ''
  });
  const [imagePreview, setImagePreview] = useState(null);
  const [categories, setCategories] = useState([
    'Makanan',
    'Minuman',
    'Snack',
    'Kue',
    'Roti',
    'Lainnya'
  ]);
  const [showNewCategory, setShowNewCategory] = useState(false);
  const [newCategory, setNewCategory] = useState('');

  const fetchProducts = async () => {
    try {
      const response = await productsAPI.getAll();
      setAllProducts(response.data.data.products || []);
    } catch (error) {
      toast.error('Gagal memuat produk');
    } finally {
      setLoading(false);
    }
  };

  usePageRefresh(fetchProducts);

  // Check authentication before any operation
  const checkAuth = () => {
    const token = localStorage.getItem('token');
    const userData = localStorage.getItem('user');
    if (!isAuthenticated || !token || !userData) {
      toast.error('Sesi login telah berakhir. Silakan login kembali.');
      window.location.href = '/login';
      return false;
    }
    if (user?.role !== 'admin') {
      toast.error('Akses ditolak. Hanya admin yang dapat mengelola produk.');
      return false;
    }
    return true;
  };

  // Filter and paginate products
  useEffect(() => {
    const filtered = allProducts.filter(product =>
      product.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      product.category.toLowerCase().includes(searchTerm.toLowerCase())
    );
    
    const startIndex = (currentPage - 1) * itemsPerPage;
    const endIndex = startIndex + itemsPerPage;
    setProducts(filtered.slice(startIndex, endIndex));
    setTotalPages(Math.ceil(filtered.length / itemsPerPage));
  }, [allProducts, searchTerm, currentPage]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    // Check authentication before proceeding
    if (!checkAuth()) {
      return;
    }
    
    try {
      const data = {
        name: formData.name,
        category: formData.category,
        cost_price: parseFloat(formData.cost),
        selling_price: parseFloat(formData.price),
        stock: parseInt(formData.stock),
        image: formData.image
      };

      if (editingProduct) {
        await productsAPI.update(editingProduct.id, data);
        toast.success('Produk berhasil diperbarui');
      } else {
        await productsAPI.create(data);
        toast.success('Produk berhasil ditambahkan');
      }
      
      setShowModal(false);
      setEditingProduct(null);
      setFormData({ name: '', category: '', price: '', cost: '', stock: '', description: '', image: '' });
      setImagePreview(null);
      fetchProducts();
    } catch (error) {
      if (error.response?.status === 401) {
        toast.error('Sesi login telah berakhir. Silakan login kembali.');
      } else if (error.response?.status === 403) {
        toast.error('Akses ditolak. Hanya admin yang dapat mengelola produk.');
      } else {
        toast.error(error.response?.data?.message || 'Gagal menyimpan produk');
      }
    }
  };

  const handleImageChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      if (file.size > 2 * 1024 * 1024) { // 2MB limit
        toast.error('Ukuran gambar maksimal 2MB');
        return;
      }
      const reader = new FileReader();
      reader.onloadend = () => {
        setFormData({ ...formData, image: reader.result });
        setImagePreview(reader.result);
      };
      reader.readAsDataURL(file);
    }
  };

  const handleEdit = (product) => {
    setEditingProduct(product);
    const displayStock = product.has_recipe ? product.available_stock : product.stock;
    setFormData({
      name: product.name,
      category: product.category,
      price: product.selling_price?.toString() || product.price?.toString() || '',
      cost: product.cost_price?.toString() || product.cost?.toString() || '',
      stock: displayStock.toString(),
      description: product.description || '',
      image: product.image || ''
    });
    setImagePreview(product.image || null);
    setShowModal(true);
  };

  const handleDelete = async (id) => {
    if (!checkAuth()) {
      return;
    }
    
    setDeleteConfirm({ isOpen: true, productId: id });
  };

  const confirmDelete = async () => {
    try {
      await productsAPI.delete(deleteConfirm.productId);
      toast.success('Produk berhasil dihapus');
      fetchProducts();
    } catch (error) {
      console.error('Delete product error:', error);
      if (error.response?.status === 401) {
        toast.error('Sesi login telah berakhir. Silakan login kembali.');
      } else if (error.response?.status === 403) {
        toast.error('Akses ditolak. Hanya admin yang dapat menghapus produk.');
      } else {
        toast.error(error.response?.data?.message || 'Gagal menghapus produk');
      }
    }
  };

  if (showRecipes) {
    return <RecipesPage productId={selectedProductId} onBack={() => setShowRecipes(false)} />;
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="spinner h-12 w-12"></div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">Manajemen Produk</h1>
        <div className="flex items-center space-x-3">
          <button
            onClick={fetchProducts}
            disabled={loading}
            className="btn btn-sm bg-blue-100 text-blue-700 hover:bg-blue-200 flex items-center space-x-2"
            title="Refresh data produk"
          >
            <Package className="w-4 h-4" />
            <span>Refresh</span>
          </button>
          <button
            onClick={() => setShowModal(true)}
            className="btn btn-primary flex items-center space-x-2"
          >
            <Plus className="w-4 h-4" />
            <span>Tambah Produk</span>
          </button>
        </div>
      </div>

      <div className="card">
        <div className="flex items-center space-x-4 mb-6">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
            <input
              type="text"
              placeholder="Cari produk..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="input pl-10"
            />
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr>
                <th className="table-header">Produk</th>
                <th className="table-header">Kategori</th>
                <th className="table-header">Harga</th>
                <th className="table-header">Modal</th>
                <th className="table-header">Stok</th>
                <th className="table-header">Aksi</th>
              </tr>
            </thead>
            <tbody>
              {products.map((product) => (
                <tr key={product.id} className="table-row">
                  <td className="table-cell">
                    <div className="flex items-center space-x-3">
                      <div className="w-10 h-10 bg-gray-200 dark:bg-gray-600 rounded-lg flex items-center justify-center overflow-hidden">
                        {product.image ? (
                          <img src={product.image} alt={product.name} className="w-full h-full object-cover" />
                        ) : (
                          <Package className="w-5 h-5 text-gray-600 dark:text-gray-300" />
                        )}
                      </div>
                      <div>
                        <div className="font-medium text-gray-900 dark:text-gray-100">{product.name}</div>
                        <div className="text-sm text-gray-500 dark:text-gray-400">{product.description}</div>
                      </div>
                    </div>
                  </td>
                  <td className="table-cell">{product.category}</td>
                  <td className="table-cell">{formatCurrency(product.selling_price || product.price)}</td>
                  <td className="table-cell">{formatCurrency(product.cost_price || product.cost)}</td>
                  <td className="table-cell">
                    {(() => {
                      const displayStock = product.has_recipe ? product.available_stock : product.stock;
                      return (
                        <span className={`badge ${
                          displayStock > 10 ? 'badge-success' :
                          displayStock > 0 ? 'badge-warning' :
                          'badge-danger'
                        }`}>
                          {displayStock}
                        </span>
                      );
                    })()}
                  </td>
                  <td className="table-cell">
                    <div className="flex items-center space-x-2">
                      <button
                        onClick={() => {
                          setSelectedProductId(product.id);
                          setShowRecipes(true);
                        }}
                        className="icon-btn-sm"
                        title="Kelola Resep"
                      >
                        <ChefHat className="w-4 h-4 text-blue-600" />
                      </button>
                      <button
                        onClick={() => handleEdit(product)}
                        className="icon-btn-sm"
                        title="Edit Produk"
                      >
                        <Edit className="w-4 h-4 text-gray-600 dark:text-gray-400" />
                      </button>
                      <button
                        onClick={() => handleDelete(product.id)}
                        className="icon-btn-sm"
                        title="Hapus Produk"
                      >
                        <Trash2 className="w-4 h-4 text-red-600" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
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
        <div className="modal">
          <div className="modal-content">
            <h2 className="modal-title">
              {editingProduct ? 'Edit Produk' : 'Tambah Produk'}
            </h2>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="form-group">
                <label className="form-label">Nama Produk</label>
                <input
                  type="text"
                  value={formData.name}
                  onChange={(e) => setFormData({...formData, name: e.target.value})}
                  className="input"
                  required
                />
              </div>
              <div className="form-group">
                <label className="form-label">Kategori</label>
                <select
                  value={formData.category}
                  onChange={(e) => {
                    const value = e.target.value;
                    if (value === '__new__') {
                      setShowNewCategory(true);
                      setFormData({...formData, category: ''});
                    } else {
                      setShowNewCategory(false);
                      setFormData({...formData, category: value});
                    }
                  }}
                  className="input"
                  required={!showNewCategory}
                >
                  <option value="">Pilih Kategori</option>
                  {categories.map((cat) => (
                    <option key={cat} value={cat}>{cat}</option>
                  ))}
                  <option value="__new__">+ Tambah Kategori Baru</option>
                </select>
                
                {showNewCategory && (
                  <div className="mt-2 flex gap-2">
                    <input
                      type="text"
                      value={newCategory}
                      onChange={(e) => setNewCategory(e.target.value)}
                      className="input flex-1"
                      placeholder="Nama kategori baru..."
                      required
                    />
                    <button
                      type="button"
                      onClick={() => {
                        if (newCategory.trim()) {
                          if (!categories.includes(newCategory.trim())) {
                            setCategories([...categories, newCategory.trim()]);
                          }
                          setFormData({...formData, category: newCategory.trim()});
                          setShowNewCategory(false);
                          setNewCategory('');
                          toast.success('Kategori baru ditambahkan');
                        }
                      }}
                      className="px-3 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700"
                    >
                      Simpan
                    </button>
                    <button
                      type="button"
                      onClick={() => {
                        setShowNewCategory(false);
                        setNewCategory('');
                      }}
                      className="px-3 py-2 bg-gray-300 text-gray-700 rounded-lg hover:bg-gray-400"
                    >
                      Batal
                    </button>
                  </div>
                )}
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div className="form-group">
                  <label className="form-label">Harga Jual</label>
                  <input
                    type="number"
                    value={formData.price}
                    onChange={(e) => setFormData({...formData, price: e.target.value})}
                    className="input"
                    required
                  />
                </div>
                <div className="form-group">
                  <label className="form-label">Harga Modal</label>
                  <input
                    type="number"
                    value={formData.cost}
                    onChange={(e) => setFormData({...formData, cost: e.target.value})}
                    className="input"
                    required
                  />
                </div>
              </div>
              <div className="form-group">
                <label className="form-label">Stok</label>
                <input
                  type="number"
                  value={formData.stock}
                  onChange={(e) => setFormData({...formData, stock: e.target.value})}
                  className="input"
                  required
                />
              </div>
              <div className="form-group">
                <label className="form-label">Gambar Produk (Opsional)</label>
                <input
                  type="file"
                  accept="image/*"
                  onChange={handleImageChange}
                  className="input"
                />
                {imagePreview && (
                  <div className="mt-2">
                    <img src={imagePreview} alt="Preview" className="w-32 h-32 object-cover rounded-lg border border-gray-200 dark:border-gray-600" />
                  </div>
                )}
              </div>
              <div className="form-group">
                <label className="form-label">Deskripsi</label>
                <textarea
                  value={formData.description}
                  onChange={(e) => setFormData({...formData, description: e.target.value})}
                  className="input"
                  rows="3"
                />
              </div>
              <div className="flex justify-end space-x-3">
                <button
                  type="button"
                  onClick={() => {
                    setShowModal(false);
                    setEditingProduct(null);
                    setFormData({ name: '', category: '', price: '', cost: '', stock: '', description: '', image: '' });
                    setImagePreview(null);
                  }}
                  className="btn btn-secondary"
                >
                  Batal
                </button>
                <button type="submit" className="btn btn-primary">
                  {editingProduct ? 'Perbarui' : 'Simpan'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      <ConfirmDialog
        isOpen={deleteConfirm.isOpen}
        onClose={() => setDeleteConfirm({ isOpen: false, productId: null })}
        onConfirm={confirmDelete}
        title="Hapus Produk"
        message="Apakah Anda yakin ingin menghapus produk ini? Tindakan ini tidak dapat dibatalkan."
        type="danger"
      />
    </div>
  );
};

export default ProductsPage;

import React, { useState, useEffect } from 'react';
import { materialsAPI } from '../utils/api';
import { formatCurrency } from '../utils/helpers';
import { Plus, Edit, AlertTriangle, Package2, Search, Trash2 } from 'lucide-react';
import toast from 'react-hot-toast';

const MaterialsPage = () => {
  const [materials, setMaterials] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [editingMaterial, setEditingMaterial] = useState(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [showLowStock, setShowLowStock] = useState(false);
  const [formData, setFormData] = useState({
    name: '',
    unit: '',
    stock: '',
    min_stock: '',
    price_per_unit: ''
  });

  useEffect(() => {
    fetchMaterials();
  }, []);

  const fetchMaterials = async () => {
    try {
      const response = await materialsAPI.getAll();
      setMaterials(response.data.data.materials || []);
    } catch (error) {
      toast.error('Gagal memuat bahan baku');
    } finally {
      setLoading(false);
    }
  };

  const fetchLowStockMaterials = async () => {
    try {
      const response = await materialsAPI.getLowStock();
      setMaterials(response.data.data || []);
      setShowLowStock(true);
    } catch (error) {
      toast.error('Gagal memuat bahan baku stok rendah');
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const data = {
        name: formData.name,
        unit: formData.unit,
        stock: parseFloat(formData.stock),
        min_stock: parseFloat(formData.min_stock),
        cost_per_unit: parseFloat(formData.price_per_unit)
      };

      if (editingMaterial) {
        await materialsAPI.update(editingMaterial.id, data);
        toast.success('Bahan baku berhasil diperbarui');
      } else {
        await materialsAPI.create(data);
        toast.success('Bahan baku berhasil ditambahkan');
      }
      
      setShowModal(false);
      setEditingMaterial(null);
      setFormData({ name: '', unit: '', stock: '', min_stock: '', price_per_unit: '' });
      fetchMaterials();
    } catch (error) {
      toast.error('Gagal menyimpan bahan baku');
    }
  };

  const handleEdit = (material) => {
    setEditingMaterial(material);
    setFormData({
      name: material.name,
      unit: material.unit,
      stock: material.stock.toString(),
      min_stock: material.min_stock.toString(),
      price_per_unit: (material.price_per_unit || material.cost_per_unit || 0).toString()
    });
    setShowModal(true);
  };

  const handleDelete = async (id) => {
    if (window.confirm('Yakin ingin menghapus bahan baku ini?')) {
      try {
        await materialsAPI.delete(id);
        toast.success('Bahan baku berhasil dihapus');
        fetchMaterials();
      } catch (error) {
        toast.error(error.response?.data?.message || 'Gagal menghapus bahan baku');
      }
    }
  };

  const filteredMaterials = materials.filter(material =>
    material.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    material.unit.toLowerCase().includes(searchTerm.toLowerCase())
  );

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
        <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">Manajemen Bahan Baku</h1>
        <div className="flex space-x-3">
          <button
            onClick={() => {
              if (showLowStock) {
                setShowLowStock(false);
                fetchMaterials();
              } else {
                fetchLowStockMaterials();
              }
            }}
            className={`btn flex items-center space-x-2 ${
              showLowStock 
                ? 'bg-gray-500 dark:bg-gray-600 text-white hover:bg-gray-600 dark:hover:bg-gray-700' 
                : 'bg-orange-500 text-white hover:bg-orange-600'
            }`}
          >
            <AlertTriangle className="w-4 h-4" />
            <span>{showLowStock ? 'Semua Bahan' : 'Stok Rendah'}</span>
          </button>
          <button
            onClick={() => setShowModal(true)}
            className="btn btn-primary flex items-center space-x-2"
          >
            <Plus className="w-4 h-4" />
            <span>Tambah Bahan</span>
          </button>
        </div>
      </div>

      <div className="card">
        <div className="flex items-center space-x-4 mb-6">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
            <input
              type="text"
              placeholder="Cari bahan baku..."
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
                <th className="table-header">Bahan Baku</th>
                <th className="table-header">Satuan</th>
                <th className="table-header">Stok</th>
                <th className="table-header">Min. Stok</th>
                <th className="table-header">Harga/Unit</th>
                <th className="table-header">Status</th>
                <th className="table-header">Aksi</th>
              </tr>
            </thead>
            <tbody>
              {filteredMaterials.map((material) => (
                <tr key={material.id} className="table-row">
                  <td className="table-cell">
                    <div className="flex items-center space-x-3">
                      <div className="w-10 h-10 bg-gray-200 dark:bg-gray-600 rounded-lg flex items-center justify-center">
                        <Package2 className="w-5 h-5 text-gray-600 dark:text-gray-300" />
                      </div>
                      <div className="font-medium text-gray-900 dark:text-gray-100">{material.name}</div>
                    </div>
                  </td>
                  <td className="table-cell">{material.unit}</td>
                  <td className="table-cell">{material.stock}</td>
                  <td className="table-cell">{material.min_stock}</td>
                  <td className="table-cell">{formatCurrency(material.price_per_unit || material.cost_per_unit || 0)}</td>
                  <td className="table-cell">
                    <span className={`badge ${
                      material.stock > material.min_stock ? 'badge-success' :
                      material.stock > 0 ? 'badge-warning' :
                      'badge-danger'
                    }`}>
                      {material.stock > material.min_stock ? 'Aman' :
                       material.stock > 0 ? 'Rendah' : 'Habis'}
                    </span>
                  </td>
                  <td className="table-cell">
                    <div className="flex items-center space-x-2">
                      <button
                        onClick={() => handleEdit(material)}
                        className="icon-btn-sm"
                        title="Edit Bahan"
                      >
                        <Edit className="w-4 h-4 text-gray-600 dark:text-gray-400" />
                      </button>
                      <button
                        onClick={() => handleDelete(material.id)}
                        className="icon-btn-sm"
                        title="Hapus Bahan"
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
      </div>

      {/* Modal */}
      {showModal && (
        <div className="modal">
          <div className="modal-content">
            <h2 className="modal-title">
              {editingMaterial ? 'Edit Bahan Baku' : 'Tambah Bahan Baku'}
            </h2>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="form-group">
                <label className="form-label">Nama Bahan</label>
                <input
                  type="text"
                  value={formData.name}
                  onChange={(e) => setFormData({...formData, name: e.target.value})}
                  className="input"
                  required
                />
              </div>
              <div className="form-group">
                <label className="form-label">Satuan</label>
                <input
                  type="text"
                  value={formData.unit}
                  onChange={(e) => setFormData({...formData, unit: e.target.value})}
                  className="input"
                  placeholder="kg, liter, pcs, dll"
                  required
                />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div className="form-group">
                  <label className="form-label">Stok</label>
                  <input
                    type="number"
                    step="0.01"
                    value={formData.stock}
                    onChange={(e) => setFormData({...formData, stock: e.target.value})}
                    className="input"
                    required
                  />
                </div>
                <div className="form-group">
                  <label className="form-label">Min. Stok</label>
                  <input
                    type="number"
                    step="0.01"
                    value={formData.min_stock}
                    onChange={(e) => setFormData({...formData, min_stock: e.target.value})}
                    className="input"
                    required
                  />
                </div>
              </div>
              <div className="form-group">
                <label className="form-label">Harga per Unit</label>
                <input
                  type="number"
                  step="0.01"
                  value={formData.price_per_unit}
                  onChange={(e) => setFormData({...formData, price_per_unit: e.target.value})}
                  className="input"
                  required
                />
              </div>
              <div className="flex justify-end space-x-3">
                <button
                  type="button"
                  onClick={() => {
                    setShowModal(false);
                    setEditingMaterial(null);
                    setFormData({ name: '', unit: '', stock: '', min_stock: '', price_per_unit: '' });
                  }}
                  className="btn btn-secondary"
                >
                  Batal
                </button>
                <button type="submit" className="btn btn-primary">
                  {editingMaterial ? 'Perbarui' : 'Simpan'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default MaterialsPage;

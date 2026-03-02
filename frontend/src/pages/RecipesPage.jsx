import React, { useState, useEffect } from 'react';
import { recipesAPI, productsAPI, materialsAPI } from '../utils/api';
import { Plus, Trash2, ChefHat, Package, ArrowLeft, Edit3, Save, X } from 'lucide-react';
import toast from 'react-hot-toast';

const RecipesPage = ({ productId, onBack }) => {
  const [product, setProduct] = useState(null);
  const [recipes, setRecipes] = useState([]);
  const [materials, setMaterials] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [editingId, setEditingId] = useState(null);
  const [newRecipe, setNewRecipe] = useState({
    material_id: '',
    quantity: ''
  });

  useEffect(() => {
    fetchData();
  }, [productId]);

  const fetchData = async () => {
    try {
      const [productRes, recipesRes, materialsRes] = await Promise.all([
        productsAPI.getById(productId),
        recipesAPI.getByProduct(productId),
        materialsAPI.getAll()
      ]);

      setProduct(productRes.data.data);
      setRecipes(recipesRes.data.data || []);
      setMaterials(materialsRes.data.data.materials || []);
    } catch (error) {
      toast.error('Gagal memuat data resep');
    } finally {
      setLoading(false);
    }
  };

  const handleAddRecipe = async (e) => {
    e.preventDefault();
    
    // Check if material already exists
    const existingRecipe = recipes.find(r => r.material_id === parseInt(newRecipe.material_id));
    if (existingRecipe) {
      toast.error('Bahan baku ini sudah ada dalam resep');
      return;
    }
    
    try {
      // Send all existing recipes + new one
      const allRecipes = [
        ...recipes.map(r => ({
          material_id: r.material_id,
          quantity_used: r.quantity_used
        })),
        {
          material_id: parseInt(newRecipe.material_id),
          quantity_used: parseFloat(newRecipe.quantity)
        }
      ];
      
      const data = {
        product_id: parseInt(productId),
        recipes: allRecipes
      };

      await recipesAPI.save(data);
      toast.success('Resep berhasil ditambahkan');
      setShowModal(false);
      setNewRecipe({ material_id: '', quantity: '' });
      fetchData();
    } catch (error) {
      toast.error(error.response?.data?.message || 'Gagal menambahkan resep');
    }
  };

  const handleUpdateRecipe = async (id, quantity) => {
    try {
      // Send all recipes with updated quantity for the specific one
      const allRecipes = recipes.map(r => ({
        material_id: r.material_id,
        quantity_used: r.id === id ? parseFloat(quantity) : r.quantity_used
      }));
      
      const data = {
        product_id: parseInt(productId),
        recipes: allRecipes
      };

      await recipesAPI.save(data);
      toast.success('Resep berhasil diperbarui');
      setEditingId(null);
      fetchData();
    } catch (error) {
      toast.error('Gagal memperbarui resep');
    }
  };

  const handleDeleteRecipe = async (id) => {
    if (window.confirm('Yakin ingin menghapus resep ini?')) {
      try {
        await recipesAPI.delete(id);
        toast.success('Resep berhasil dihapus');
        fetchData();
      } catch (error) {
        toast.error('Gagal menghapus resep');
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
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-4">
          <button
            onClick={onBack}
            className="p-2 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg transition-colors"
          >
            <ArrowLeft className="w-5 h-5 text-gray-600 dark:text-gray-400" />
          </button>
          <div>
            <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">Resep Produk</h1>
            <p className="text-gray-600 dark:text-gray-400">{product?.name}</p>
          </div>
        </div>
        <button
          onClick={() => setShowModal(true)}
          className="btn btn-primary flex items-center space-x-2"
        >
          <Plus className="w-4 h-4" />
          <span>Tambah Bahan</span>
        </button>
      </div>

      <div className="card">
        <div className="flex items-center space-x-3 mb-6">
          <ChefHat className="w-6 h-6 text-primary" />
          <h2 className="text-lg font-semibold text-gray-900 dark:text-gray-100">Komposisi Bahan</h2>
        </div>

        {recipes.length === 0 ? (
          <div className="text-center py-12">
            <Package className="w-12 h-12 text-gray-400 mx-auto mb-4" />
            <p className="text-gray-500 dark:text-gray-400">Belum ada resep untuk produk ini</p>
            <button
              onClick={() => setShowModal(true)}
              className="btn btn-primary mt-4"
            >
              Tambah Resep Pertama
            </button>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-gray-200 dark:border-gray-600">
                  <th className="text-left py-3 px-4 font-medium text-gray-900 dark:text-gray-100">Bahan Baku</th>
                  <th className="text-left py-3 px-4 font-medium text-gray-900 dark:text-gray-100">Satuan</th>
                  <th className="text-left py-3 px-4 font-medium text-gray-900 dark:text-gray-100">Jumlah</th>
                  <th className="text-left py-3 px-4 font-medium text-gray-900 dark:text-gray-100">Stok Tersedia</th>
                  <th className="text-left py-3 px-4 font-medium text-gray-900 dark:text-gray-100">Aksi</th>
                </tr>
              </thead>
              <tbody>
                {recipes.map((recipe) => {
                  const material = materials.find(m => m.id === recipe.material_id);
                  const isEditing = editingId === recipe.id;
                  
                  return (
                    <tr key={recipe.id} className="border-b border-gray-100 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors">
                      <td className="py-3 px-4">
                        <div className="flex items-center space-x-3">
                          <div className="w-10 h-10 bg-gray-200 dark:bg-gray-600 rounded-lg flex items-center justify-center">
                            <Package className="w-5 h-5 text-gray-600 dark:text-gray-300" />
                          </div>
                          <div className="font-medium text-gray-900 dark:text-gray-100">
                            {material?.name || 'Bahan tidak ditemukan'}
                          </div>
                        </div>
                      </td>
                      <td className="py-3 px-4 text-gray-900 dark:text-gray-100">{material?.unit}</td>
                      <td className="py-3 px-4">
                        {isEditing ? (
                          <input
                            type="number"
                            step="0.01"
                            defaultValue={recipe.quantity_used || recipe.quantity}
                            className="w-20 px-2 py-1 text-sm border border-gray-300 dark:border-gray-600 rounded bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100"
                            onKeyDown={(e) => {
                              if (e.key === 'Enter') {
                                handleUpdateRecipe(recipe.id, e.target.value);
                              } else if (e.key === 'Escape') {
                                setEditingId(null);
                              }
                            }}
                            autoFocus
                          />
                        ) : (
                          <span className="text-gray-900 dark:text-gray-100">
                            {recipe.quantity_used || recipe.quantity}
                          </span>
                        )}
                      </td>
                      <td className="py-3 px-4">
                        <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                          material && material.stock >= (recipe.quantity_used || recipe.quantity) ? 
                          'bg-green-100 dark:bg-green-900 text-green-800 dark:text-green-200' : 
                          'bg-red-100 dark:bg-red-900 text-red-800 dark:text-red-200'
                        }`}>
                          {material?.stock || 0}
                        </span>
                      </td>
                      <td className="py-3 px-4">
                        <div className="flex items-center space-x-2">
                          {isEditing ? (
                            <>
                              <button
                                onClick={() => {
                                  const input = document.querySelector(`tr:nth-child(${recipes.indexOf(recipe) + 1}) input`);
                                  handleUpdateRecipe(recipe.id, input.value);
                                }}
                                className="p-1 hover:bg-gray-100 dark:hover:bg-gray-600 rounded transition-colors"
                              >
                                <Save className="w-4 h-4 text-green-600" />
                              </button>
                              <button
                                onClick={() => setEditingId(null)}
                                className="p-1 hover:bg-gray-100 dark:hover:bg-gray-600 rounded transition-colors"
                              >
                                <X className="w-4 h-4 text-gray-600 dark:text-gray-400" />
                              </button>
                            </>
                          ) : (
                            <>
                              <button
                                onClick={() => setEditingId(recipe.id)}
                                className="p-1 hover:bg-gray-100 dark:hover:bg-gray-600 rounded transition-colors"
                              >
                                <Edit3 className="w-4 h-4 text-blue-600" />
                              </button>
                              <button
                                onClick={() => handleDeleteRecipe(recipe.id)}
                                className="p-1 hover:bg-gray-100 dark:hover:bg-gray-600 rounded transition-colors"
                              >
                                <Trash2 className="w-4 h-4 text-red-600" />
                              </button>
                            </>
                          )}
                        </div>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white dark:bg-gray-800 rounded-lg p-6 w-full max-w-md">
            <h2 className="text-lg font-semibold mb-4 text-gray-900 dark:text-gray-100">Tambah Bahan ke Resep</h2>
            <form onSubmit={handleAddRecipe} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Bahan Baku</label>
                <select
                  value={newRecipe.material_id}
                  onChange={(e) => setNewRecipe({...newRecipe, material_id: e.target.value})}
                  className="input"
                  required
                >
                  <option value="">Pilih bahan baku</option>
                  {materials.map((material) => (
                    <option key={material.id} value={material.id}>
                      {material.name} ({material.unit})
                    </option>
                  ))}
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Jumlah</label>
                <input
                  type="number"
                  step="0.01"
                  value={newRecipe.quantity}
                  onChange={(e) => setNewRecipe({...newRecipe, quantity: e.target.value})}
                  className="input"
                  placeholder="Masukkan jumlah"
                  required
                />
              </div>
              <div className="flex justify-end space-x-3">
                <button
                  type="button"
                  onClick={() => {
                    setShowModal(false);
                    setNewRecipe({ material_id: '', quantity: '' });
                  }}
                  className="px-4 py-2 text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg transition-colors"
                >
                  Batal
                </button>
                <button type="submit" className="btn btn-primary">
                  Tambah
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default RecipesPage;

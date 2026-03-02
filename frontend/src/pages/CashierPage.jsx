import React, { useState, useEffect } from 'react';
import { productsAPI } from '../utils/api';
import { useCart } from '../context/CartContext';
import { formatCurrency } from '../utils/helpers';
import { 
  ShoppingCart, 
  Plus, 
  Minus, 
  CreditCard, 
  Receipt,
  Search,
  Filter,
  Package
} from 'lucide-react';
import toast from 'react-hot-toast';
import PaymentModal from '../components/PaymentModal';

const CashierPage = () => {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('');
  const [showPaymentModal, setShowPaymentModal] = useState(false);
  
  const { items, addItem, updateQuantity, removeItem, getTotalAmount, getTotalItems, clearCart } = useCart();

  useEffect(() => {
    fetchProducts();
  }, []);

  const fetchProducts = async () => {
    try {
      const response = await productsAPI.getAll();
      setProducts(response.data.data.products || []);
    } catch (error) {
      toast.error('Gagal memuat produk');
    } finally {
      setLoading(false);
    }
  };

  const filteredProducts = products.filter(product => {
    const matchesSearch = product.name.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesCategory = !selectedCategory || product.category === selectedCategory;
    return matchesSearch && matchesCategory;
  });

  const categories = [...new Set(products.map(p => p.category))];

  const handleAddToCart = (product) => {
    const displayStock = product.has_recipe ? product.available_stock : product.stock;
    
    if (displayStock <= 0) {
      toast.error('Stok produk habis');
      return;
    }
    
    // Warning jika stok menipis (gunakan toast biasa dengan emoji)
    if (displayStock <= 10) {
      toast(
        `⚠️ Stok ${product.name} tinggal ${displayStock} unit!`,
        { 
          duration: 3000,
          icon: '⚠️',
          style: {
            background: '#FEF3C7',
            color: '#92400E',
          }
        }
      );
    }
    
    addItem(product);
    toast.success(`${product.name} ditambahkan ke keranjang`);
  };

  const handleCheckout = () => {
    if (items.length === 0) {
      toast.error('Keranjang masih kosong');
      return;
    }
    setShowPaymentModal(true);
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
      </div>
    );
  }

  return (
    <div className="flex h-screen bg-gray-50 dark:bg-gray-900">
      {/* Products Section */}
      <div className="flex-1 p-6">
        <div className="mb-6">
          <h1 className="text-3xl font-bold text-gray-900 mb-4">Kasir</h1>
          
          {/* Search and Filter */}
          <div className="flex space-x-4 mb-6">
            <div className="flex-1 relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
              <input
                type="text"
                placeholder="Cari produk..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="input pl-10"
              />
            </div>
            <select
              value={selectedCategory}
              onChange={(e) => setSelectedCategory(e.target.value)}
              className="input w-48"
            >
              <option value="">Semua Kategori</option>
              {categories.map(category => (
                <option key={category} value={category}>{category}</option>
              ))}
            </select>
          </div>
        </div>

        {/* Products Grid */}
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4 max-h-[calc(100vh-200px)] overflow-y-auto">
          {filteredProducts.map(product => {
            const displayStock = product.has_recipe ? product.available_stock : product.stock;
            const isLowStock = displayStock > 0 && displayStock <= 10;
            
            return (
              <div key={product.id} className="card hover:shadow-lg transition-shadow cursor-pointer">
                <div className="aspect-square bg-gray-100 rounded-lg mb-3 flex items-center justify-center">
                  <Package className="w-12 h-12 text-gray-400" />
                </div>
                <h3 className="font-semibold text-gray-900 mb-1">{product.name}</h3>
                <p className="text-sm text-gray-600 mb-2">{product.category}</p>
                <div className="flex items-center justify-between mb-3">
                  <span className="text-lg font-bold text-primary">
                    {formatCurrency(product.selling_price)}
                  </span>
                  <div className="text-right">
                    <span className={`text-sm font-medium ${
                      displayStock <= 0 ? 'text-red-600' : 
                      isLowStock ? 'text-yellow-600' : 
                      'text-gray-600'
                    }`}>
                      Stok: {displayStock}
                    </span>
                    {product.has_recipe && (
                      <p className="text-xs text-blue-600">dari bahan baku</p>
                    )}
                  </div>
                </div>
                <button
                  onClick={() => handleAddToCart(product)}
                  disabled={displayStock <= 0}
                  className={`btn w-full ${
                    displayStock <= 0 
                      ? 'bg-gray-300 text-gray-500 cursor-not-allowed' 
                      : 'btn-primary'
                  }`}
                >
                  <Plus className="w-4 h-4 mr-2" />
                  {displayStock <= 0 ? 'Stok Habis' : 'Tambah'}
                </button>
              </div>
            );
          })}
        </div>
      </div>

      {/* Cart Section */}
      <div className="w-96 bg-white dark:bg-gray-800 border-l border-gray-200 dark:border-gray-700 p-6">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-semibold text-gray-900 dark:text-gray-100">Keranjang</h2>
          <div className="bg-primary text-white rounded-full w-6 h-6 flex items-center justify-center text-sm">
            {getTotalItems()}
          </div>
        </div>

        {/* Cart Items */}
        <div className="space-y-4 max-h-96 overflow-y-auto mb-6">
          {items.length === 0 ? (
            <div className="text-center py-8 text-gray-500">
              <ShoppingCart className="w-12 h-12 mx-auto mb-2 text-gray-300" />
              <p>Keranjang kosong</p>
            </div>
          ) : (
            items.map(item => (
              <div key={item.id} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                <div className="flex-1">
                  <h4 className="font-medium text-gray-900">{item.name}</h4>
                  <p className="text-sm text-gray-600">{formatCurrency(item.selling_price)}</p>
                </div>
                <div className="flex items-center space-x-2">
                  <button
                    onClick={() => updateQuantity(item.id, item.quantity - 1)}
                    className="w-8 h-8 rounded-full bg-gray-200 flex items-center justify-center hover:bg-gray-300"
                  >
                    <Minus className="w-4 h-4" />
                  </button>
                  <span className="w-8 text-center font-medium">{item.quantity}</span>
                  <button
                    onClick={() => updateQuantity(item.id, item.quantity + 1)}
                    className="w-8 h-8 rounded-full bg-primary text-white flex items-center justify-center hover:bg-blue-700"
                  >
                    <Plus className="w-4 h-4" />
                  </button>
                </div>
              </div>
            ))
          )}
        </div>

        {/* Cart Summary */}
        {items.length > 0 && (
          <div className="border-t border-gray-200 pt-4">
            <div className="flex justify-between items-center mb-4">
              <span className="text-lg font-semibold text-gray-900">Total:</span>
              <span className="text-2xl font-bold text-primary">
                {formatCurrency(getTotalAmount())}
              </span>
            </div>
            
            <div className="space-y-2">
              <button
                onClick={handleCheckout}
                className="btn btn-primary w-full py-3 text-lg"
              >
                <CreditCard className="w-5 h-5 mr-2" />
                Bayar
              </button>
              <button
                onClick={clearCart}
                className="btn bg-gray-100 text-gray-700 hover:bg-gray-200 w-full"
              >
                Kosongkan Keranjang
              </button>
            </div>
          </div>
        )}
      </div>

      {/* Payment Modal */}
      {showPaymentModal && (
        <PaymentModal
          isOpen={showPaymentModal}
          onClose={() => setShowPaymentModal(false)}
          cartItems={items}
          totalAmount={getTotalAmount()}
          onSuccess={() => {
            clearCart();
            setShowPaymentModal(false);
            fetchProducts(); // Refresh products to update stock
            toast.success('Transaksi berhasil!');
          }}
        />
      )}
    </div>
  );
};

export default CashierPage;

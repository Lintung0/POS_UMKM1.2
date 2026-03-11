import React, { useState, useEffect } from 'react';
import { settingsAPI } from '../utils/api';
import { Settings as SettingsIcon, Store, Bell, Moon, Sun, Save } from 'lucide-react';
import toast from 'react-hot-toast';

const SettingsPage = () => {
  const [activeTab, setActiveTab] = useState('store');
  const [loading, setLoading] = useState(true);
  const [darkMode, setDarkMode] = useState(false);
  const [settings, setSettings] = useState({
    store_name: 'UMKM Store',
    store_address: 'Jl. Contoh No. 123',
    store_phone: '081234567890',
    store_email: '',
    stock_alert_enabled: true,
    stock_alert_threshold: 50,
  });

  useEffect(() => {
    fetchSettings();
    // Check if dark mode is enabled
    const isDark = document.documentElement.classList.contains('dark');
    setDarkMode(isDark);
  }, []);

  const fetchSettings = async () => {
    try {
      const response = await settingsAPI.get();
      if (response.data.success && response.data.data) {
        setSettings({
          store_name: response.data.data.store_name || 'UMKM Store',
          store_address: response.data.data.store_address || 'Jl. Contoh No. 123',
          store_phone: response.data.data.store_phone || '081234567890',
          store_email: response.data.data.store_email || '',
          stock_alert_enabled: response.data.data.stock_alert_enabled !== undefined ? response.data.data.stock_alert_enabled : true,
          stock_alert_threshold: response.data.data.stock_alert_threshold || 50,
        });
      }
    } catch (error) {
      console.error('Failed to fetch settings:', error);
      toast.error('Gagal memuat pengaturan');
    } finally {
      setLoading(false);
    }
  };

  const handleSave = async (section) => {
    try {
      const response = await settingsAPI.update(settings);
      if (response.data.success) {
        toast.success(`Pengaturan ${section} berhasil disimpan`);
      }
    } catch (error) {
      console.error('Failed to save settings:', error);
      const errorMsg = error.response?.data?.message || error.response?.data?.error || 'Gagal menyimpan pengaturan';
      toast.error(errorMsg);
    }
  };

  const toggleDarkMode = () => {
    const newDarkMode = !darkMode;
    setDarkMode(newDarkMode);
    
    if (newDarkMode) {
      document.documentElement.classList.add('dark');
      localStorage.setItem('theme', 'dark');
      toast.success('Mode gelap diaktifkan');
    } else {
      document.documentElement.classList.remove('dark');
      localStorage.setItem('theme', 'light');
      toast.success('Mode terang diaktifkan');
    }
  };

  const tabs = [
    { id: 'store', name: 'Toko', icon: Store },
    { id: 'theme', name: 'Tema', icon: darkMode ? Moon : Sun },
    { id: 'alerts', name: 'Peringatan', icon: Bell },
  ];

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center space-x-3">
        <SettingsIcon className="w-8 h-8 text-primary" />
        <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Pengaturan</h1>
      </div>

      <div className="flex flex-col lg:flex-row gap-6">
        {/* Sidebar */}
        <div className="lg:w-64">
          <div className="card p-0">
            <nav className="space-y-1">
              {tabs.map((tab) => (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`w-full flex items-center space-x-3 px-4 py-3 text-left rounded-lg transition-colors ${
                    activeTab === tab.id
                      ? 'bg-primary text-white'
                      : 'text-gray-700 dark:text-white hover:bg-gray-100 dark:hover:bg-gray-700'
                  }`}
                >
                  <tab.icon className="w-5 h-5" />
                  <span>{tab.name}</span>
                </button>
              ))}
            </nav>
          </div>
        </div>

        {/* Content */}
        <div className="flex-1">
          {/* Store Settings */}
          {activeTab === 'store' && (
            <div className="card">
              <h2 className="text-lg font-semibold mb-6 text-gray-900 dark:text-white">Pengaturan Toko</h2>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-white mb-1">Nama Toko</label>
                  <input
                    type="text"
                    value={settings.store_name}
                    onChange={(e) => setSettings({...settings, store_name: e.target.value})}
                    className="input"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-white mb-1">Alamat Toko</label>
                  <textarea
                    value={settings.store_address}
                    onChange={(e) => setSettings({...settings, store_address: e.target.value})}
                    className="input"
                    rows="3"
                  />
                </div>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 dark:text-white mb-1">Telepon Toko</label>
                    <input
                      type="tel"
                      value={settings.store_phone}
                      onChange={(e) => setSettings({...settings, store_phone: e.target.value})}
                      className="input"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 dark:text-white mb-1">Email Toko</label>
                    <input
                      type="email"
                      value={settings.store_email}
                      onChange={(e) => setSettings({...settings, store_email: e.target.value})}
                      className="input"
                    />
                  </div>
                </div>
                <div className="flex justify-end">
                  <button 
                    onClick={() => handleSave('toko')}
                    className="btn btn-primary flex items-center space-x-2"
                  >
                    <Save className="w-4 h-4" />
                    <span>Simpan</span>
                  </button>
                </div>
              </div>
            </div>
          )}

          {/* Receipt Settings */}
          {activeTab === 'theme' && (
            <div className="card">
              <h2 className="text-lg font-semibold mb-6 text-gray-900 dark:text-gray-100">Pengaturan Tema</h2>
              
              <div className="flex flex-col items-center justify-center py-8">
                <p className="text-gray-600 dark:text-gray-400 mb-8 text-center">
                  Pilih tema tampilan aplikasi sesuai preferensi Anda
                </p>
                
                {/* 3D Toggle Switch */}
                <div className="relative">
                  <button
                    onClick={toggleDarkMode}
                    className="relative w-32 h-16 rounded-full transition-all duration-500 ease-in-out transform hover:scale-105 focus:outline-none focus:ring-4 focus:ring-primary/30"
                    style={{
                      background: darkMode 
                        ? 'linear-gradient(145deg, #1e293b, #0f172a)' 
                        : 'linear-gradient(145deg, #fbbf24, #f59e0b)',
                      boxShadow: darkMode
                        ? '8px 8px 16px #0a0e1a, -8px -8px 16px #2a3650'
                        : '8px 8px 16px #d4a00a, -8px -8px 16px #ffde3a'
                    }}
                  >
                    {/* Toggle Ball */}
                    <div
                      className={`absolute top-2 w-12 h-12 rounded-full transition-all duration-500 ease-in-out flex items-center justify-center ${
                        darkMode ? 'left-16' : 'left-2'
                      }`}
                      style={{
                        background: darkMode
                          ? 'linear-gradient(145deg, #475569, #334155)'
                          : 'linear-gradient(145deg, #ffffff, #f1f5f9)',
                        boxShadow: darkMode
                          ? '4px 4px 8px #1e293b, -4px -4px 8px #64748b'
                          : '4px 4px 8px #cbd5e1, -4px -4px 8px #ffffff'
                      }}
                    >
                      {darkMode ? (
                        <Moon className="w-6 h-6 text-blue-300 animate-pulse" />
                      ) : (
                        <Sun className="w-6 h-6 text-yellow-500 animate-spin-slow" />
                      )}
                    </div>
                  </button>
                </div>

                <div className="mt-8 text-center">
                  <p className="text-lg font-semibold text-gray-900 dark:text-gray-100">
                    {darkMode ? 'Mode Gelap' : 'Mode Terang'}
                  </p>
                  <p className="text-sm text-gray-500 dark:text-gray-400 mt-2">
                    {darkMode 
                      ? 'Nyaman untuk mata di malam hari' 
                      : 'Cerah dan jelas untuk siang hari'}
                  </p>
                </div>
              </div>
            </div>
          )}

          {/* Alerts Settings */}
          {activeTab === 'alerts' && (
            <div className="card">
              <h2 className="text-lg font-semibold mb-6 text-gray-900 dark:text-gray-100">Pengaturan Peringatan Stok</h2>
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <div>
                    <h3 className="font-medium text-gray-900 dark:text-gray-100">Aktifkan Peringatan Stok</h3>
                    <p className="text-sm text-gray-500 dark:text-gray-400">Tampilkan alert saat stok bahan baku menipis</p>
                  </div>
                  <label className="relative inline-flex items-center cursor-pointer">
                    <input
                      type="checkbox"
                      checked={settings.stock_alert_enabled}
                      onChange={(e) => setSettings({...settings, stock_alert_enabled: e.target.checked})}
                      className="sr-only peer"
                    />
                    <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-primary/20 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary"></div>
                  </label>
                </div>

                {settings.stock_alert_enabled && (
                  <div>
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                      Threshold Peringatan (%)
                    </label>
                    <input
                      type="number"
                      value={settings.stock_alert_threshold}
                      onChange={(e) => setSettings({...settings, stock_alert_threshold: parseInt(e.target.value)})}
                      className="input"
                      min="0"
                      max="100"
                    />
                    <p className="text-sm text-gray-500 mt-1">
                      Alert muncul jika stok di bawah {settings.stock_alert_threshold}% dari minimum stock
                    </p>
                  </div>
                )}

                <div className="flex justify-end">
                  <button 
                    onClick={() => handleSave('peringatan')}
                    className="btn btn-primary flex items-center space-x-2"
                  >
                    <Save className="w-4 h-4" />
                    <span>Simpan</span>
                  </button>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default SettingsPage;

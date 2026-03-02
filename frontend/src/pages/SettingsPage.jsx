import React, { useState, useEffect } from 'react';
import { settingsAPI } from '../utils/api';
import { Settings as SettingsIcon, Store, Bell, Receipt, Save } from 'lucide-react';
import toast from 'react-hot-toast';

const SettingsPage = () => {
  const [activeTab, setActiveTab] = useState('store');
  const [loading, setLoading] = useState(true);
  const [settings, setSettings] = useState({
    store_name: 'UMKM Store',
    store_address: 'Jl. Contoh No. 123',
    store_phone: '081234567890',
    store_email: '',
    stock_alert_enabled: true,
    stock_alert_threshold: 50,
    receipt_footer_text: 'Terima kasih!',
    receipt_show_cashier: true,
    tax_enabled: false,
    tax_percentage: 10,
  });

  useEffect(() => {
    fetchSettings();
  }, []);

  const fetchSettings = async () => {
    try {
      const response = await settingsAPI.get();
      setSettings(response.data.data);
    } catch (error) {
      console.error('Failed to fetch settings:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSave = async (section) => {
    try {
      await settingsAPI.update(settings);
      toast.success(`Pengaturan ${section} berhasil disimpan`);
    } catch (error) {
      console.error('Failed to save settings:', error);
      toast.error('Gagal menyimpan settings');
    }
  };

  const tabs = [
    { id: 'store', name: 'Toko', icon: Store },
    { id: 'receipt', name: 'Struk', icon: Receipt },
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
        <h1 className="text-2xl font-bold text-gray-900">Pengaturan</h1>
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
                      : 'text-gray-700 hover:bg-gray-100'
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
              <h2 className="text-lg font-semibold mb-6 text-gray-900">Pengaturan Toko</h2>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Nama Toko</label>
                  <input
                    type="text"
                    value={settings.store_name}
                    onChange={(e) => setSettings({...settings, store_name: e.target.value})}
                    className="input"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Alamat Toko</label>
                  <textarea
                    value={settings.store_address}
                    onChange={(e) => setSettings({...settings, store_address: e.target.value})}
                    className="input"
                    rows="3"
                  />
                </div>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Telepon Toko</label>
                    <input
                      type="tel"
                      value={settings.store_phone}
                      onChange={(e) => setSettings({...settings, store_phone: e.target.value})}
                      className="input"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Email Toko</label>
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
          {activeTab === 'receipt' && (
            <div className="card">
              <h2 className="text-lg font-semibold mb-6 text-gray-900">Pengaturan Struk</h2>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Footer Text Struk</label>
                  <textarea
                    value={settings.receipt_footer_text}
                    onChange={(e) => setSettings({...settings, receipt_footer_text: e.target.value})}
                    className="input"
                    rows="2"
                  />
                </div>
                
                <div className="border-t pt-4">
                  <h3 className="font-medium text-gray-900 mb-4">Pajak</h3>
                  
                  <div className="flex items-center justify-between mb-4">
                    <div>
                      <h4 className="font-medium text-gray-900">Aktifkan Pajak</h4>
                      <p className="text-sm text-gray-500">Tambahkan pajak ke total transaksi</p>
                    </div>
                    <label className="relative inline-flex items-center cursor-pointer">
                      <input
                        type="checkbox"
                        checked={settings.tax_enabled}
                        onChange={(e) => setSettings({...settings, tax_enabled: e.target.checked})}
                        className="sr-only peer"
                      />
                      <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-primary/20 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary"></div>
                    </label>
                  </div>

                  {settings.tax_enabled && (
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">Persentase Pajak (%)</label>
                      <input
                        type="number"
                        value={settings.tax_percentage}
                        onChange={(e) => setSettings({...settings, tax_percentage: parseFloat(e.target.value)})}
                        className="input"
                        min="0"
                        max="100"
                      />
                    </div>
                  )}
                </div>

                <div className="flex justify-end">
                  <button 
                    onClick={() => handleSave('struk')}
                    className="btn btn-primary flex items-center space-x-2"
                  >
                    <Save className="w-4 h-4" />
                    <span>Simpan</span>
                  </button>
                </div>
              </div>
            </div>
          )}

          {/* Alert Settings */}
          {activeTab === 'alerts' && (
            <div className="card">
              <h2 className="text-lg font-semibold mb-6 text-gray-900">Pengaturan Peringatan Stok</h2>
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <div>
                    <h3 className="font-medium text-gray-900">Aktifkan Peringatan Stok</h3>
                    <p className="text-sm text-gray-500">Tampilkan alert saat stok bahan baku menipis</p>
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
                    <label className="block text-sm font-medium text-gray-700 mb-1">
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

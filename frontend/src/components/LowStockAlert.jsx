import React, { useState, useEffect } from 'react';
import { AlertTriangle, X } from 'lucide-react';
import { materialsAPI } from '../utils/api';

const LowStockAlert = () => {
  const [lowStockMaterials, setLowStockMaterials] = useState([]);
  const [loading, setLoading] = useState(true);
  const [dismissed, setDismissed] = useState(false);
  
  useEffect(() => {
    fetchLowStock();
  }, []);
  
  const fetchLowStock = async () => {
    try {
      const response = await materialsAPI.getLowStock();
      setLowStockMaterials(response.data.data || []);
    } catch (error) {
      console.error('Failed to fetch low stock materials:', error);
    } finally {
      setLoading(false);
    }
  };
  
  if (loading || dismissed || lowStockMaterials.length === 0) {
    return null;
  }
  
  return (
    <div className="bg-red-50 border-l-4 border-red-500 p-4 mb-6 rounded-r-lg relative">
      <button
        onClick={() => setDismissed(true)}
        className="absolute top-2 right-2 text-red-500 hover:text-red-700"
      >
        <X className="w-5 h-5" />
      </button>
      
      <div className="flex items-start">
        <AlertTriangle className="w-6 h-6 text-red-500 mr-3 flex-shrink-0 mt-0.5" />
        <div className="flex-1">
          <h3 className="font-semibold text-red-800 mb-2">
            ⚠️ Peringatan Stok Rendah!
          </h3>
          <p className="text-sm text-red-700 mb-3">
            {lowStockMaterials.length} bahan baku perlu direstock segera
          </p>
          <ul className="space-y-2">
            {lowStockMaterials.map(material => {
              const percentage = (material.stock / material.min_stock) * 100;
              const isDanger = percentage < 50;
              
              return (
                <li 
                  key={material.id} 
                  className={`text-sm p-2 rounded ${
                    isDanger ? 'bg-red-100' : 'bg-yellow-50'
                  }`}
                >
                  <div className="flex justify-between items-center">
                    <span className="font-medium">{material.name}</span>
                    <span className={`text-xs px-2 py-1 rounded ${
                      isDanger ? 'bg-red-200 text-red-800' : 'bg-yellow-200 text-yellow-800'
                    }`}>
                      {percentage.toFixed(0)}%
                    </span>
                  </div>
                  <div className="text-xs text-gray-600 mt-1">
                    Stok: {material.stock} {material.unit} (min: {material.min_stock} {material.unit})
                  </div>
                </li>
              );
            })}
          </ul>
        </div>
      </div>
    </div>
  );
};

export default LowStockAlert;

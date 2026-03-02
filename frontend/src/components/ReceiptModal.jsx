import React, { useState } from 'react';
import { X, Printer } from 'lucide-react';
import { formatCurrency } from '../utils/helpers';

const ReceiptModal = ({ isOpen, onClose, transaction }) => {
  const [settings] = useState({
    store_name: 'UMKM Store',
    store_address: 'Jl. Contoh No. 123',
    store_phone: '081234567890',
    receipt_footer_text: 'Terima kasih!',
    receipt_show_cashier: true,
    tax_enabled: false,
    tax_percentage: 10,
  });

  const handlePrint = () => {
    window.print();
  };

  if (!isOpen || !transaction) return null;

  // Calculate totals
  const subtotal = transaction.total_amount;
  const taxAmount = settings.tax_enabled ? (subtotal * settings.tax_percentage / 100) : 0;
  const total = subtotal + taxAmount;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 dark:bg-opacity-70 flex items-center justify-center z-50 p-4">
      <div className="bg-white dark:bg-gray-800 rounded-lg max-w-md w-full max-h-[90vh] overflow-y-auto">
        {/* Header - Hide on print */}
        <div className="flex justify-between items-center p-4 border-b border-gray-200 dark:border-gray-700 no-print">
          <h2 className="text-xl font-bold text-gray-900 dark:text-gray-100">Struk Pembayaran</h2>
          <button onClick={onClose} className="text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-300">
            <X className="w-6 h-6" />
          </button>
        </div>

        {/* Receipt Content - Printable */}
        <div className="receipt-content p-6">
          {/* Store Info */}
          <div className="text-center mb-4 pb-4 border-b-2 border-dashed border-gray-300">
            <h3 className="text-xl font-bold mb-1">{settings.store_name}</h3>
            <p className="text-sm text-gray-600">{settings.store_address}</p>
            <p className="text-sm text-gray-600">{settings.store_phone}</p>
          </div>

          {/* Transaction Info */}
          <div className="text-sm mb-4 pb-4 border-b border-dashed border-gray-300">
            <div className="flex justify-between mb-1">
              <span className="text-gray-600">No. Transaksi:</span>
              <span className="font-medium">#{transaction.id}</span>
            </div>
            <div className="flex justify-between mb-1">
              <span className="text-gray-600">Tanggal:</span>
              <span className="font-medium">
                {new Date(transaction.created_at).toLocaleString('id-ID', {
                  day: '2-digit',
                  month: '2-digit',
                  year: 'numeric',
                  hour: '2-digit',
                  minute: '2-digit'
                })}
              </span>
            </div>
            {settings.receipt_show_cashier && (
              <div className="flex justify-between">
                <span className="text-gray-600">Kasir:</span>
                <span className="font-medium">{transaction.cashier_name}</span>
              </div>
            )}
          </div>

          {/* Items */}
          <div className="mb-4 pb-4 border-b border-dashed border-gray-300">
            {transaction.details && transaction.details.map((item, index) => (
              <div key={index} className="flex justify-between mb-2">
                <div className="flex-1">
                  <div className="font-medium">{item.product_name}</div>
                  <div className="text-sm text-gray-600">
                    {item.qty} x {formatCurrency(item.price_per_unit)}
                  </div>
                </div>
                <div className="font-medium">
                  {formatCurrency(item.total_price)}
                </div>
              </div>
            ))}
          </div>

          {/* Totals */}
          <div className="space-y-2 mb-4">
            <div className="flex justify-between text-sm">
              <span>Subtotal:</span>
              <span>{formatCurrency(subtotal)}</span>
            </div>
            
            {settings.tax_enabled && (
              <div className="flex justify-between text-sm">
                <span>Pajak ({settings.tax_percentage}%):</span>
                <span>{formatCurrency(taxAmount)}</span>
              </div>
            )}

            <div className="flex justify-between text-lg font-bold pt-2 border-t-2 border-gray-300">
              <span>TOTAL:</span>
              <span>{formatCurrency(total)}</span>
            </div>

            <div className="flex justify-between text-sm pt-2">
              <span>Bayar:</span>
              <span>{formatCurrency(transaction.cash_received)}</span>
            </div>

            <div className="flex justify-between text-sm font-medium">
              <span>Kembali:</span>
              <span>{formatCurrency(transaction.change_amount)}</span>
            </div>
          </div>

          {/* Footer */}
          <div className="text-center pt-4 border-t-2 border-dashed border-gray-300">
            <p className="text-sm text-gray-600">{settings.receipt_footer_text}</p>
          </div>
        </div>

        {/* Actions - Hide on print */}
        <div className="flex gap-3 p-4 border-t no-print">
          <button
            onClick={handlePrint}
            className="btn btn-primary flex-1 flex items-center justify-center gap-2"
          >
            <Printer className="w-4 h-4" />
            Print / Save PDF
          </button>
          <button
            onClick={onClose}
            className="btn bg-gray-200 hover:bg-gray-300 flex-1"
          >
            Tutup
          </button>
        </div>
      </div>
    </div>
  );
};

export default ReceiptModal;

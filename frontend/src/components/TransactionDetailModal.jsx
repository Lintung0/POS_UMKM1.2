import React, { useState, useEffect } from 'react';
import { transactionsAPI } from '../utils/api';
import { formatCurrency } from '../utils/helpers';
import { X, Receipt, Calendar, User, CreditCard } from 'lucide-react';
import toast from 'react-hot-toast';

const TransactionDetailModal = ({ transactionId, onClose }) => {
  const [transaction, setTransaction] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchTransactionDetail();
  }, [transactionId]);

  const fetchTransactionDetail = async () => {
    try {
      const response = await transactionsAPI.getById(transactionId);
      setTransaction(response.data.data);
    } catch (error) {
      toast.error('Gagal memuat detail transaksi');
    } finally {
      setLoading(false);
    }
  };

  const handlePrintReceipt = async () => {
    try {
      const response = await transactionsAPI.getReceipt(transactionId);
      // In a real app, this would trigger a print dialog or PDF generation
      toast.success('Struk siap dicetak');
    } catch (error) {
      toast.error('Gagal mencetak struk');
    }
  };

  if (loading) {
    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div className="bg-white rounded-lg p-6 w-full max-w-2xl">
          <div className="flex items-center justify-center h-64">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
          </div>
        </div>
      </div>
    );
  }

  if (!transaction) {
    return null;
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <div className="flex justify-between items-center mb-6">
          <h2 className="text-xl font-semibold">Detail Transaksi #{transaction.id}</h2>
          <button
            onClick={onClose}
            className="p-2 hover:bg-gray-100 rounded-lg"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="space-y-6">
          {/* Transaction Info */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="flex items-center space-x-3">
              <Calendar className="w-5 h-5 text-gray-400" />
              <div>
                <p className="text-sm text-gray-500">Tanggal</p>
                <p className="font-medium">
                  {new Date(transaction.created_at).toLocaleString('id-ID')}
                </p>
              </div>
            </div>
            <div className="flex items-center space-x-3">
              <User className="w-5 h-5 text-gray-400" />
              <div>
                <p className="text-sm text-gray-500">Pelanggan</p>
                <p className="font-medium">{transaction.customer_name || 'Umum'}</p>
              </div>
            </div>
            <div className="flex items-center space-x-3">
              <CreditCard className="w-5 h-5 text-gray-400" />
              <div>
                <p className="text-sm text-gray-500">Metode Pembayaran</p>
                <p className="font-medium">{transaction.payment_method}</p>
              </div>
            </div>
            <div className="flex items-center space-x-3">
              <Receipt className="w-5 h-5 text-gray-400" />
              <div>
                <p className="text-sm text-gray-500">Total</p>
                <p className="font-medium text-lg text-primary">
                  {formatCurrency(transaction.total_amount)}
                </p>
              </div>
            </div>
          </div>

          {/* Transaction Items */}
          <div>
            <h3 className="text-lg font-medium mb-4">Item Pembelian</h3>
            <div className="border rounded-lg overflow-hidden">
              <table className="w-full">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="text-left py-3 px-4 font-medium text-gray-900">Produk</th>
                    <th className="text-left py-3 px-4 font-medium text-gray-900">Harga</th>
                    <th className="text-left py-3 px-4 font-medium text-gray-900">Qty</th>
                    <th className="text-left py-3 px-4 font-medium text-gray-900">Subtotal</th>
                  </tr>
                </thead>
                <tbody>
                  {transaction.details?.map((detail, index) => (
                    <tr key={index} className="border-t border-gray-100">
                      <td className="py-3 px-4">{detail.product_name || detail.product?.name || 'N/A'}</td>
                      <td className="py-3 px-4">{formatCurrency(detail.price_per_unit || detail.price || 0)}</td>
                      <td className="py-3 px-4">{detail.qty || detail.quantity || 0}</td>
                      <td className="py-3 px-4 font-medium">
                        {formatCurrency(detail.total_price || detail.subtotal || 0)}
                      </td>
                    </tr>
                  ))}
                </tbody>
                <tfoot className="bg-gray-50 border-t-2 border-gray-200">
                  <tr>
                    <td colSpan="3" className="py-3 px-4 font-medium text-right">Total:</td>
                    <td className="py-3 px-4 font-bold text-lg text-primary">
                      {formatCurrency(transaction.total_amount)}
                    </td>
                  </tr>
                </tfoot>
              </table>
            </div>
          </div>

          {/* Payment Info */}
          <div className="bg-gray-50 rounded-lg p-4">
            <h3 className="font-medium mb-2">Informasi Pembayaran</h3>
            <div className="grid grid-cols-2 gap-4 text-sm">
              <div>
                <span className="text-gray-500">Jumlah Bayar:</span>
                <span className="ml-2 font-medium">
                  {formatCurrency(transaction.cash_received || transaction.paid_amount || transaction.total_amount)}
                </span>
              </div>
              <div>
                <span className="text-gray-500">Kembalian:</span>
                <span className="ml-2 font-medium">
                  {formatCurrency(transaction.change_amount || 0)}
                </span>
              </div>
            </div>
          </div>

          {/* Actions */}
          <div className="flex justify-end space-x-3">
            <button
              onClick={handlePrintReceipt}
              className="btn btn-primary flex items-center space-x-2"
            >
              <Receipt className="w-4 h-4" />
              <span>Cetak Struk</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default TransactionDetailModal;

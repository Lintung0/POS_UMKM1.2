import React, { useState } from 'react';
import { transactionsAPI } from '../utils/api';
import { formatCurrency } from '../utils/helpers';
import { X, CreditCard, Banknote, Calculator } from 'lucide-react';
import toast from 'react-hot-toast';
import ReceiptModal from './ReceiptModal';

const PaymentModal = ({ isOpen, onClose, cartItems, totalAmount, onSuccess }) => {
  const [paymentMethod, setPaymentMethod] = useState('CASH');
  const [cashReceived, setCashReceived] = useState('');
  const [cashierName, setCashierName] = useState('Kasir UMKM');
  const [notes, setNotes] = useState('');
  const [loading, setLoading] = useState(false);
  const [showReceipt, setShowReceipt] = useState(false);
  const [transactionData, setTransactionData] = useState(null);

  if (!isOpen) return null;

  const cashAmount = parseFloat(cashReceived) || 0;
  const changeAmount = cashAmount - totalAmount;

  const handlePayment = async () => {
    if (paymentMethod === 'CASH' && cashAmount < totalAmount) {
      toast.error('Uang yang diterima kurang');
      return;
    }

    setLoading(true);
    try {
      const requestData = {
        cash_received: paymentMethod === 'CASH' ? cashAmount : totalAmount,
        payment_method: paymentMethod,
        cashier_name: cashierName,
        notes: notes,
        items: cartItems.map(item => ({
          product_id: item.id,
          quantity: item.quantity
        }))
      };

      const response = await transactionsAPI.create(requestData);
      
      // Set transaction data and show receipt
      setTransactionData(response.data.data.transaction);
      setShowReceipt(true);
      
      toast.success('Transaksi berhasil!');
      onSuccess();
      onClose();
    } catch (error) {
      toast.error(error.response?.data?.message || 'Transaksi gagal');
    } finally {
      setLoading(false);
    }
  };

  const quickCashAmounts = [
    totalAmount,
    Math.ceil(totalAmount / 10000) * 10000,
    Math.ceil(totalAmount / 20000) * 20000,
    Math.ceil(totalAmount / 50000) * 50000,
    Math.ceil(totalAmount / 100000) * 100000
  ].filter((amount, index, arr) => arr.indexOf(amount) === index);

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 dark:bg-opacity-70 flex items-center justify-center z-50 p-4">
      <div className="bg-white dark:bg-gray-800 rounded-2xl max-w-md w-full max-h-[90vh] overflow-y-auto">
        <div className="p-6">
          {/* Header */}
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-2xl font-bold text-gray-900 dark:text-gray-100">Pembayaran</h2>
            <button
              onClick={onClose}
              className="p-2 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-full"
            >
              <X className="w-6 h-6 text-gray-600 dark:text-gray-300" />
            </button>
          </div>

          {/* Order Summary */}
          <div className="mb-6">
            <h3 className="font-semibold text-gray-900 dark:text-gray-100 mb-3">Ringkasan Pesanan</h3>
            <div className="space-y-2 max-h-32 overflow-y-auto">
              {cartItems.map(item => (
                <div key={item.id} className="flex justify-between text-sm text-gray-700 dark:text-gray-300">
                  <span>{item.name} x{item.quantity}</span>
                  <span>{formatCurrency(item.selling_price * item.quantity)}</span>
                </div>
              ))}
            </div>
            <div className="border-t border-gray-200 dark:border-gray-600 mt-3 pt-3">
              <div className="flex justify-between font-bold text-lg text-gray-900 dark:text-gray-100">
                <span>Total:</span>
                <span className="text-primary">{formatCurrency(totalAmount)}</span>
              </div>
            </div>
          </div>

          {/* Payment Method */}
          <div className="mb-6">
            <h3 className="font-semibold text-gray-900 mb-3">Metode Pembayaran</h3>
            <div className="grid grid-cols-2 gap-3">
              <button
                onClick={() => setPaymentMethod('CASH')}
                className={`p-3 rounded-lg border-2 flex items-center justify-center space-x-2 ${
                  paymentMethod === 'CASH' 
                    ? 'border-primary bg-primary/10 text-primary' 
                    : 'border-gray-200 hover:border-gray-300'
                }`}
              >
                <Banknote className="w-5 h-5" />
                <span>Tunai</span>
              </button>
              <button
                onClick={() => setPaymentMethod('CARD')}
                className={`p-3 rounded-lg border-2 flex items-center justify-center space-x-2 ${
                  paymentMethod === 'CARD' 
                    ? 'border-primary bg-primary/10 text-primary' 
                    : 'border-gray-200 hover:border-gray-300'
                }`}
              >
                <CreditCard className="w-5 h-5" />
                <span>Kartu</span>
              </button>
            </div>
          </div>

          {/* Cash Payment */}
          {paymentMethod === 'CASH' && (
            <div className="mb-6">
              <h3 className="font-semibold text-gray-900 mb-3">Uang Diterima</h3>
              <div className="relative mb-3">
                <span className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-500">Rp</span>
                <input
                  type="number"
                  value={cashReceived}
                  onChange={(e) => setCashReceived(e.target.value)}
                  className="input pl-10 text-lg font-medium"
                  placeholder="0"
                />
              </div>
              
              {/* Quick Cash Buttons */}
              <div className="grid grid-cols-3 gap-2 mb-4">
                {quickCashAmounts.slice(0, 6).map(amount => (
                  <button
                    key={amount}
                    onClick={() => setCashReceived(amount.toString())}
                    className="btn bg-gray-100 text-gray-700 hover:bg-gray-200 text-sm py-2"
                  >
                    {formatCurrency(amount)}
                  </button>
                ))}
              </div>

              {/* Change Amount */}
              {cashAmount > 0 && (
                <div className={`p-3 rounded-lg ${
                  changeAmount >= 0 ? 'bg-green-50 border border-green-200' : 'bg-red-50 border border-red-200'
                }`}>
                  <div className="flex items-center justify-between">
                    <span className="font-medium">Kembalian:</span>
                    <span className={`text-lg font-bold ${
                      changeAmount >= 0 ? 'text-green-600' : 'text-red-600'
                    }`}>
                      {formatCurrency(Math.abs(changeAmount))}
                    </span>
                  </div>
                  {changeAmount < 0 && (
                    <p className="text-sm text-red-600 mt-1">
                      Kurang {formatCurrency(Math.abs(changeAmount))}
                    </p>
                  )}
                </div>
              )}
            </div>
          )}

          {/* Additional Info */}
          <div className="mb-6 space-y-3">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Nama Kasir
              </label>
              <input
                type="text"
                value={cashierName}
                onChange={(e) => setCashierName(e.target.value)}
                className="input"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Catatan (Opsional)
              </label>
              <textarea
                value={notes}
                onChange={(e) => setNotes(e.target.value)}
                className="input resize-none"
                rows="2"
                placeholder="Catatan tambahan..."
              />
            </div>
          </div>

          {/* Action Buttons */}
          <div className="flex space-x-3">
            <button
              onClick={onClose}
              className="btn bg-gray-100 text-gray-700 hover:bg-gray-200 flex-1"
            >
              Batal
            </button>
            <button
              onClick={handlePayment}
              disabled={loading || (paymentMethod === 'CASH' && changeAmount < 0)}
              className="btn btn-primary flex-1 flex items-center justify-center space-x-2"
            >
              {loading ? (
                <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white"></div>
              ) : (
                <>
                  <CreditCard className="w-5 h-5" />
                  <span>Proses Pembayaran</span>
                </>
              )}
            </button>
          </div>
        </div>
      </div>

      {/* Receipt Modal */}
      <ReceiptModal
        isOpen={showReceipt}
        onClose={() => setShowReceipt(false)}
        transaction={transactionData}
      />
    </div>
  );
};

export default PaymentModal;

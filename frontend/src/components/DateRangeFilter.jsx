import React from 'react';

const today = () => new Date().toISOString().split('T')[0];
const daysAgo = (n) => new Date(Date.now() - n * 86400000).toISOString().split('T')[0];
const firstOfMonth = () => new Date(new Date().getFullYear(), new Date().getMonth(), 1).toISOString().split('T')[0];
const firstOfYear = () => new Date(new Date().getFullYear(), 0, 1).toISOString().split('T')[0];

const DateRangeFilter = ({ value, onChange, showYear = false }) => {
  const presets = [
    { label: 'Hari Ini', fn: () => onChange({ start_date: today(), end_date: today() }) },
    { label: '7 Hari', fn: () => onChange({ start_date: daysAgo(6), end_date: today() }) },
    { label: '30 Hari', fn: () => onChange({ start_date: daysAgo(29), end_date: today() }) },
    { label: 'Bulan Ini', fn: () => onChange({ start_date: firstOfMonth(), end_date: today() }) },
    ...(showYear ? [{ label: 'Tahun Ini', fn: () => onChange({ start_date: firstOfYear(), end_date: today() }) }] : []),
  ];

  return (
    <div className="card">
      <div className="flex flex-col md:flex-row gap-4">
        <div className="flex-1">
          <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Dari Tanggal</label>
          <input
            type="date"
            value={value.start_date}
            onChange={(e) => onChange({ ...value, start_date: e.target.value })}
            className="input"
          />
        </div>
        <div className="flex-1">
          <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Sampai Tanggal</label>
          <input
            type="date"
            value={value.end_date}
            onChange={(e) => onChange({ ...value, end_date: e.target.value })}
            className="input"
          />
        </div>
      </div>
      <div className="flex flex-wrap gap-2 mt-4">
        {presets.map(({ label, fn }) => (
          <button key={label} onClick={fn} className="px-3 py-1 text-sm bg-gray-100 hover:bg-gray-200 dark:bg-gray-700 dark:hover:bg-gray-600 dark:text-gray-300 rounded-lg">
            {label}
          </button>
        ))}
      </div>
    </div>
  );
};

export default DateRangeFilter;

// Theme utility functions and constants

export const themeClasses = {
  // Background colors
  bg: {
    primary: 'bg-gray-50 dark:bg-gray-900',
    secondary: 'bg-white dark:bg-gray-800',
    tertiary: 'bg-gray-100 dark:bg-gray-700',
    hover: 'hover:bg-gray-50 dark:hover:bg-gray-700',
    active: 'bg-gray-100 dark:bg-gray-700'
  },
  
  // Text colors
  text: {
    primary: 'text-gray-900 dark:text-gray-100',
    secondary: 'text-gray-600 dark:text-gray-400',
    tertiary: 'text-gray-500 dark:text-gray-500',
    muted: 'text-gray-400 dark:text-gray-500'
  },
  
  // Border colors
  border: {
    primary: 'border-gray-200 dark:border-gray-700',
    secondary: 'border-gray-300 dark:border-gray-600',
    light: 'border-gray-100 dark:border-gray-800'
  },
  
  // Input styles
  input: {
    base: 'bg-white dark:bg-gray-700 border-gray-300 dark:border-gray-600 text-gray-900 dark:text-gray-100 placeholder-gray-500 dark:placeholder-gray-400',
    focus: 'focus:ring-primary focus:border-transparent'
  },
  
  // Button styles
  button: {
    secondary: 'bg-gray-200 dark:bg-gray-700 text-gray-900 dark:text-gray-100 hover:bg-gray-300 dark:hover:bg-gray-600',
    ghost: 'hover:bg-gray-100 dark:hover:bg-gray-700 text-gray-600 dark:text-gray-400'
  },
  
  // Card styles
  card: {
    base: 'bg-white dark:bg-gray-800 border-gray-200 dark:border-gray-700',
    shadow: 'shadow-sm dark:shadow-gray-900/10'
  },
  
  // Table styles
  table: {
    header: 'border-gray-200 dark:border-gray-600 text-gray-900 dark:text-gray-100',
    row: 'border-gray-100 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-700',
    cell: 'text-gray-900 dark:text-gray-100'
  },
  
  // Modal styles
  modal: {
    backdrop: 'bg-black bg-opacity-50 dark:bg-black dark:bg-opacity-70',
    content: 'bg-white dark:bg-gray-800 border-gray-200 dark:border-gray-700'
  },
  
  // Status badges
  badge: {
    success: 'bg-green-100 dark:bg-green-900 text-green-800 dark:text-green-200',
    warning: 'bg-yellow-100 dark:bg-yellow-900 text-yellow-800 dark:text-yellow-200',
    danger: 'bg-red-100 dark:bg-red-900 text-red-800 dark:text-red-200',
    info: 'bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200'
  }
};

// Helper function to combine theme classes
export const cn = (...classes) => {
  return classes.filter(Boolean).join(' ');
};

// Common component class combinations
export const commonClasses = {
  pageTitle: cn(themeClasses.text.primary, 'text-2xl font-bold'),
  sectionTitle: cn(themeClasses.text.primary, 'text-lg font-semibold'),
  card: cn(themeClasses.card.base, themeClasses.card.shadow, 'rounded-xl p-6 transition-colors duration-200'),
  input: cn('w-full px-3 py-2 rounded-lg focus:outline-none focus:ring-2 transition-colors duration-200', themeClasses.input.base, themeClasses.input.focus),
  button: {
    primary: 'btn btn-primary',
    secondary: cn('btn', themeClasses.button.secondary),
    ghost: cn('p-2 rounded-lg transition-colors', themeClasses.button.ghost)
  },
  table: {
    header: cn('text-left py-3 px-4 font-medium', themeClasses.table.header),
    row: cn('transition-colors duration-150', themeClasses.table.row),
    cell: cn('py-3 px-4', themeClasses.table.cell)
  },
  modal: {
    backdrop: cn('fixed inset-0 flex items-center justify-center z-50', themeClasses.modal.backdrop),
    content: cn('rounded-lg p-6 w-full max-w-md shadow-xl transition-colors duration-200', themeClasses.modal.content)
  },
  badge: {
    success: cn('px-2 py-1 rounded-full text-xs font-medium', themeClasses.badge.success),
    warning: cn('px-2 py-1 rounded-full text-xs font-medium', themeClasses.badge.warning),
    danger: cn('px-2 py-1 rounded-full text-xs font-medium', themeClasses.badge.danger),
    info: cn('px-2 py-1 rounded-full text-xs font-medium', themeClasses.badge.info)
  }
};

export default { themeClasses, cn, commonClasses };

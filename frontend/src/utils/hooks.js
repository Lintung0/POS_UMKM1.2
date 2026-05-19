import { useEffect } from 'react';

export const usePageRefresh = (callback) => {
  useEffect(() => {
    callback();
    const handler = () => { if (!document.hidden) callback(); };
    document.addEventListener('visibilitychange', handler);
    return () => document.removeEventListener('visibilitychange', handler);
  }, []);
};

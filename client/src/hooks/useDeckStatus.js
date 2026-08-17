import { useState, useEffect, useCallback } from 'react';
import { useAuth } from '../context/AuthContext';

export const DECK_STATUS = {
  NOT_STARTED: 'not_started', // Chưa học
  LEARNING: 'learning',       // Đang học
  COMPLETED: 'completed'      // Đã học
};

export const useDeckStatus = (decks = []) => {
  const { user } = useAuth();
  const storageKey = `mochi_deck_status_${user?.id || 'guest'}`;

  const [statuses, setStatuses] = useState(() => {
    try {
      const saved = localStorage.getItem(storageKey);
      return saved ? JSON.parse(saved) : {};
    } catch {
      return {};
    }
  });

  // Khởi tạo mặc định nếu chưa có status nào được lưu
  useEffect(() => {
    if (!decks || decks.length === 0) return;

    try {
      const saved = localStorage.getItem(storageKey);
      let parsed = saved ? JSON.parse(saved) : {};

      // Nếu chưa có bất kỳ trạng thái nào, đặt 3 bài học đầu tiên (hoặc theo chuyên ngành) thành 'learning'
      if (Object.keys(parsed).length === 0) {
        const initialMap = {};
        decks.forEach((deck, idx) => {
          const deckId = deck.id || deck._id;
          if (idx < 3) {
            initialMap[deckId] = DECK_STATUS.LEARNING;
          } else {
            initialMap[deckId] = DECK_STATUS.NOT_STARTED;
          }
        });
        localStorage.setItem(storageKey, JSON.stringify(initialMap));
        setStatuses(initialMap);
      }
    } catch (e) {
      console.warn('Error initializing deck statuses:', e);
    }
  }, [decks, storageKey]);

  const setStatus = useCallback((deckId, newStatus) => {
    setStatuses(prev => {
      const next = { ...prev, [deckId]: newStatus };
      try {
        localStorage.setItem(storageKey, JSON.stringify(next));
      } catch (e) {
        console.error('Error saving deck status:', e);
      }
      return next;
    });
  }, [storageKey]);

  const getStatus = useCallback((deckId) => {
    return statuses[deckId] || DECK_STATUS.NOT_STARTED;
  }, [statuses]);

  // Phân loại danh sách bộ thẻ
  const learningDecks = decks.filter(d => getStatus(d.id || d._id) === DECK_STATUS.LEARNING);
  const notStartedDecks = decks.filter(d => getStatus(d.id || d._id) === DECK_STATUS.NOT_STARTED);
  const completedDecks = decks.filter(d => getStatus(d.id || d._id) === DECK_STATUS.COMPLETED);

  return {
    statuses,
    getStatus,
    setStatus,
    learningDecks,
    notStartedDecks,
    completedDecks,
    DECK_STATUS
  };
};

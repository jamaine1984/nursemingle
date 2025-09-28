import { create } from 'zustand';
import { subscribeWithSelector } from 'zustand/middleware';

// Types
export interface User {
  id: string;
  name: string;
  email: string;
  age: number;
  specialty: string;
  location: string;
  about: string;
  interests: string[];
  avatar: string;
  isOnline?: boolean;
  lastSeen?: number;
  giftPoints?: number;
  superLikes?: number;
  videoMinutes?: number;
  isPremium?: boolean;
  language?: string;
  country?: string;
  timezone?: string;
}

export interface Message {
  id: string;
  text: string;
  senderId: string;
  receiverId: string;
  timestamp: number;
  type: 'text' | 'gift' | 'image';
  status: 'sent' | 'delivered' | 'read';
  giftData?: any;
}

export interface Match {
  id: string;
  users: string[];
  timestamp: number;
  isActive: boolean;
  lastMessage?: Message;
}

export interface AppState {
  // User state
  currentUser: User | null;
  isAuthenticated: boolean;
  users: User[];

  // App state
  currentPage: string;
  isLoading: boolean;
  error: string | null;
  language: string;
  theme: 'light' | 'dark';

  // Dating state
  matches: Match[];
  messages: Record<string, Message[]>;
  likes: string[];
  passes: string[];

  // Notifications
  notifications: Array<{
    id: string;
    type: 'match' | 'message' | 'like' | 'gift';
    title: string;
    message: string;
    timestamp: number;
    read: boolean;
  }>;

  // Actions
  setCurrentUser: (user: User | null) => void;
  setAuthenticated: (value: boolean) => void;
  setUsers: (users: User[]) => void;
  addUser: (user: User) => void;
  updateUser: (id: string, updates: Partial<User>) => void;

  setCurrentPage: (page: string) => void;
  setLoading: (loading: boolean) => void;
  setError: (error: string | null) => void;
  setLanguage: (language: string) => void;
  setTheme: (theme: 'light' | 'dark') => void;

  addMatch: (match: Match) => void;
  addMessage: (message: Message) => void;
  markMessageAsRead: (messageId: string) => void;

  addLike: (userId: string) => void;
  addPass: (userId: string) => void;

  addNotification: (notification: Omit<AppState['notifications'][0], 'id'>) => void;
  markNotificationAsRead: (id: string) => void;
  clearNotifications: () => void;

  // Computed getters
  getUnreadMessagesCount: () => number;
  getUnreadNotificationsCount: () => number;
  getAvailableUsers: () => User[];
}

export const useAppStore = create<AppState>()(
  subscribeWithSelector((set, get) => ({
    // Initial state
    currentUser: null,
    isAuthenticated: false,
    users: [],

    currentPage: 'welcome',
    isLoading: false,
    error: null,
    language: 'en',
    theme: 'light',

    matches: [],
    messages: {},
    likes: [],
    passes: [],

    notifications: [],

    // Actions
    setCurrentUser: (user) => set({ currentUser: user }),
    setAuthenticated: (value) => set({ isAuthenticated: value }),
    setUsers: (users) => set({ users }),
    addUser: (user) => set((state) => ({ users: [...state.users, user] })),
    updateUser: (id, updates) => set((state) => ({
      users: state.users.map(user => user.id === id ? { ...user, ...updates } : user),
      currentUser: state.currentUser?.id === id ? { ...state.currentUser, ...updates } : state.currentUser
    })),

    setCurrentPage: (page) => set({ currentPage: page }),
    setLoading: (loading) => set({ isLoading: loading }),
    setError: (error) => set({ error }),
    setLanguage: (language) => set({ language }),
    setTheme: (theme) => set({ theme }),

    addMatch: (match) => set((state) => ({ matches: [...state.matches, match] })),
    addMessage: (message) => set((state) => {
      const chatId = [message.senderId, message.receiverId].sort().join('_');
      return {
        messages: {
          ...state.messages,
          [chatId]: [...(state.messages[chatId] || []), message]
        }
      };
    }),
    markMessageAsRead: (messageId) => set((state) => {
      const newMessages = { ...state.messages };
      Object.keys(newMessages).forEach(chatId => {
        newMessages[chatId] = newMessages[chatId].map(msg =>
          msg.id === messageId ? { ...msg, status: 'read' } : msg
        );
      });
      return { messages: newMessages };
    }),

    addLike: (userId) => set((state) => ({ likes: [...state.likes, userId] })),
    addPass: (userId) => set((state) => ({ passes: [...state.passes, userId] })),

    addNotification: (notification) => set((state) => ({
      notifications: [
        {
          ...notification,
          id: Date.now().toString() + Math.random().toString(36).substr(2, 9),
          read: false
        },
        ...state.notifications
      ]
    })),
    markNotificationAsRead: (id) => set((state) => ({
      notifications: state.notifications.map(n => n.id === id ? { ...n, read: true } : n)
    })),
    clearNotifications: () => set({ notifications: [] }),

    // Computed getters
    getUnreadMessagesCount: () => {
      const state = get();
      let count = 0;
      Object.values(state.messages).forEach(chatMessages => {
        count += chatMessages.filter(msg =>
          msg.receiverId === state.currentUser?.id && msg.status !== 'read'
        ).length;
      });
      return count;
    },

    getUnreadNotificationsCount: () => {
      return get().notifications.filter(n => !n.read).length;
    },

    getAvailableUsers: () => {
      const state = get();
      return state.users.filter(user =>
        user.id !== state.currentUser?.id &&
        !state.likes.includes(user.id) &&
        !state.passes.includes(user.id)
      );
    }
  }))
);

// Persistence middleware
useAppStore.subscribe(
  (state) => ({
    language: state.language,
    theme: state.theme,
    currentUser: state.currentUser
  }),
  (newState) => {
    localStorage.setItem('nurse-mingle-state', JSON.stringify(newState));
  }
);

// Load persisted state
const persistedState = localStorage.getItem('nurse-mingle-state');
if (persistedState) {
  try {
    const parsed = JSON.parse(persistedState);
    useAppStore.setState(parsed);
  } catch (error) {
    console.error('Failed to load persisted state:', error);
  }
}
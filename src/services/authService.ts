import {
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
  signOut,
  onAuthStateChanged,
  User as FirebaseUser,
  updateProfile
} from 'firebase/auth';
import {
  doc,
  getDoc,
  setDoc,
  updateDoc,
  collection,
  addDoc,
  getDocs,
  query,
  where,
  orderBy,
  limit,
  onSnapshot,
  Timestamp
} from 'firebase/firestore';
import { ref, uploadBytes, getDownloadURL } from 'firebase/storage';
import { httpsCallable } from 'firebase/functions';

import { auth, db, storage, functions } from '../lib/firebase';
import { User, Message, Match } from '../types';
import { useAppStore } from '../store';

// Error handling wrapper
const withErrorHandling = async <T>(operation: () => Promise<T>): Promise<T> => {
  try {
    return await operation();
  } catch (error: any) {
    console.error('Firebase operation error:', error);

    // User-friendly error messages
    let userMessage = 'An unexpected error occurred. Please try again.';

    if (error.code === 'permission-denied') {
      userMessage = 'Permission denied. Please check your access rights.';
    } else if (error.code === 'unavailable') {
      userMessage = 'Service temporarily unavailable. Please try again later.';
    } else if (error.code === 'network-request-failed') {
      userMessage = 'Network error. Please check your internet connection.';
    } else if (error.code === 'auth/user-not-found') {
      userMessage = 'User not found. Please check your credentials.';
    } else if (error.code === 'auth/wrong-password') {
      userMessage = 'Invalid password. Please try again.';
    } else if (error.code === 'auth/email-already-in-use') {
      userMessage = 'Email already in use. Please use a different email.';
    } else if (error.code === 'auth/weak-password') {
      userMessage = 'Password is too weak. Please choose a stronger password.';
    }

    useAppStore.getState().setError(userMessage);
    throw new Error(userMessage);
  }
};

// Authentication services
export const authService = {
  async signUp(email: string, password: string): Promise<FirebaseUser> {
    return withErrorHandling(async () => {
      const result = await createUserWithEmailAndPassword(auth, email, password);
      return result.user;
    });
  },

  async signIn(email: string, password: string): Promise<FirebaseUser> {
    return withErrorHandling(async () => {
      const result = await signInWithEmailAndPassword(auth, email, password);
      return result.user;
    });
  },

  async signOut(): Promise<void> {
    return withErrorHandling(async () => {
      await signOut(auth);
      useAppStore.getState().setCurrentUser(null);
      useAppStore.getState().setAuthenticated(false);
    });
  },

  onAuthStateChanged(callback: (user: FirebaseUser | null) => void) {
    return onAuthStateChanged(auth, callback);
  },

  getCurrentUser(): FirebaseUser | null {
    return auth.currentUser;
  }
};

// User services
export const userService = {
  async createProfile(userData: Omit<User, 'id'>): Promise<void> {
    return withErrorHandling(async () => {
      if (!auth.currentUser) throw new Error('No authenticated user');

      const userDoc = doc(db, 'users', auth.currentUser.uid);
      await setDoc(userDoc, {
        ...userData,
        id: auth.currentUser.uid,
        createdAt: Timestamp.now(),
        lastActive: Timestamp.now(),
        isOnline: true
      });

      // Update Firebase Auth profile
      await updateProfile(auth.currentUser, {
        displayName: userData.name,
        photoURL: userData.avatar
      });
    });
  },

  async updateProfile(updates: Partial<User>): Promise<void> {
    return withErrorHandling(async () => {
      if (!auth.currentUser) throw new Error('No authenticated user');

      const userDoc = doc(db, 'users', auth.currentUser.uid);
      await updateDoc(userDoc, {
        ...updates,
        lastActive: Timestamp.now()
      });

      // Update Firebase Auth profile if name or avatar changed
      if (updates.name || updates.avatar) {
        await updateProfile(auth.currentUser, {
          displayName: updates.name || auth.currentUser.displayName,
          photoURL: updates.avatar || auth.currentUser.photoURL
        });
      }
    });
  },

  async getProfile(userId: string): Promise<User | null> {
    return withErrorHandling(async () => {
      const userDoc = doc(db, 'users', userId);
      const userSnap = await getDoc(userDoc);

      if (userSnap.exists()) {
        return { id: userSnap.id, ...userSnap.data() } as User;
      }
      return null;
    });
  },

  async getUsers(excludeIds: string[] = []): Promise<User[]> {
    return withErrorHandling(async () => {
      const usersQuery = query(
        collection(db, 'users'),
        orderBy('lastActive', 'desc'),
        limit(50)
      );

      const snapshot = await getDocs(usersQuery);
      return snapshot.docs
        .map(doc => ({ id: doc.id, ...doc.data() } as User))
        .filter(user => !excludeIds.includes(user.id));
    });
  },

  async uploadAvatar(file: File): Promise<string> {
    return withErrorHandling(async () => {
      if (!auth.currentUser) throw new Error('No authenticated user');

      const avatarRef = ref(storage, `avatars/${auth.currentUser.uid}`);
      await uploadBytes(avatarRef, file);
      return await getDownloadURL(avatarRef);
    });
  }
};

// Matching services
export const matchingService = {
  async likeUser(likedUserId: string): Promise<boolean> {
    return withErrorHandling(async () => {
      if (!auth.currentUser) throw new Error('No authenticated user');

      // Save the like
      await addDoc(collection(db, 'likes'), {
        likerId: auth.currentUser.uid,
        likedUserId,
        timestamp: Timestamp.now(),
        type: 'like'
      });

      // Check for mutual like
      const mutualLikeQuery = query(
        collection(db, 'likes'),
        where('likerId', '==', likedUserId),
        where('likedUserId', '==', auth.currentUser.uid)
      );

      const mutualLikeSnap = await getDocs(mutualLikeQuery);

      if (!mutualLikeSnap.empty) {
        // Create match - using 'users' field to match security rules
        await addDoc(collection(db, 'matches'), {
          users: [auth.currentUser.uid, likedUserId],
          timestamp: Timestamp.now(),
          isActive: true
        });
        return true; // It's a match!
      }

      return false; // Just a like
    });
  },

  async superLikeUser(likedUserId: string): Promise<boolean> {
    return withErrorHandling(async () => {
      if (!auth.currentUser) throw new Error('No authenticated user');

      await addDoc(collection(db, 'likes'), {
        likerId: auth.currentUser.uid,
        likedUserId,
        timestamp: Timestamp.now(),
        type: 'superlike'
      });

      // Super likes create immediate notifications
      await addDoc(collection(db, 'notifications'), {
        userId: likedUserId,
        type: 'superlike',
        fromUserId: auth.currentUser.uid,
        timestamp: Timestamp.now(),
        read: false
      });

      return false; // Super likes don't auto-match
    });
  },

  async passUser(passedUserId: string): Promise<void> {
    return withErrorHandling(async () => {
      if (!auth.currentUser) throw new Error('No authenticated user');

      await addDoc(collection(db, 'swipes'), {
        swiperId: auth.currentUser.uid,
        swipedUserId: passedUserId,
        timestamp: Timestamp.now(),
        action: 'pass'
      });
    });
  },

  async getMatches(): Promise<Match[]> {
    return withErrorHandling(async () => {
      if (!auth.currentUser) throw new Error('No authenticated user');

      const matchesQuery = query(
        collection(db, 'matches'),
        where('users', 'array-contains', auth.currentUser.uid),
        where('isActive', '==', true),
        orderBy('timestamp', 'desc')
      );

      const snapshot = await getDocs(matchesQuery);
      return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() } as Match));
    });
  }
};

// Messaging services
export const messagingService = {
  async sendMessage(receiverId: string, text: string, type: 'text' | 'gift' = 'text'): Promise<void> {
    return withErrorHandling(async () => {
      if (!auth.currentUser) throw new Error('No authenticated user');

      const chatId = [auth.currentUser.uid, receiverId].sort().join('_');

      await addDoc(collection(db, 'chats', chatId, 'messages'), {
        senderId: auth.currentUser.uid,
        receiverId,
        text,
        type,
        timestamp: Timestamp.now(),
        status: 'sent'
      });
    });
  },

  subscribeToMessages(chatId: string, callback: (messages: Message[]) => void) {
    const messagesQuery = query(
      collection(db, 'chats', chatId, 'messages'),
      orderBy('timestamp', 'asc')
    );

    return onSnapshot(messagesQuery, (snapshot) => {
      const messages = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        timestamp: doc.data().timestamp?.toMillis() || Date.now()
      } as Message));

      callback(messages);
    });
  },

  async markAsRead(chatId: string, messageId: string): Promise<void> {
    return withErrorHandling(async () => {
      const messageRef = doc(db, 'chats', chatId, 'messages', messageId);
      await updateDoc(messageRef, { status: 'read' });
    });
  }
};

// LiveKit token service
export const liveKitService = {
  async generateToken(roomName: string): Promise<string> {
    return withErrorHandling(async () => {
      const generateToken = httpsCallable(functions, 'generateLiveKitToken');
      const result = await generateToken({ roomName });
      return (result.data as any).token;
    });
  }
};

// Analytics service
export const analyticsService = {
  async trackEvent(eventName: string, parameters: Record<string, any> = {}): Promise<void> {
    try {
      if (auth.currentUser) {
        await addDoc(collection(db, 'analytics'), {
          userId: auth.currentUser.uid,
          event: eventName,
          parameters,
          timestamp: Timestamp.now(),
          userAgent: navigator.userAgent,
          language: navigator.language
        });
      }
    } catch (error) {
      console.warn('Analytics tracking failed:', error);
      // Don't throw - analytics failures shouldn't break the app
    }
  },

  async trackPageView(page: string): Promise<void> {
    return this.trackEvent('page_view', { page });
  },

  async trackUserAction(action: string, details?: Record<string, any>): Promise<void> {
    return this.trackEvent('user_action', { action, ...details });
  }
};

// Initialize app state listeners
export const initializeFirebaseListeners = () => {
  // Auth state listener
  authService.onAuthStateChanged(async (user) => {
    const store = useAppStore.getState();

    store.setLoading(true);

    try {
      if (user) {
        store.setAuthenticated(true);

        // Load user profile
        const profile = await userService.getProfile(user.uid);
        if (profile) {
          store.setCurrentUser(profile);
          store.setCurrentPage('home');
        } else {
          store.setCurrentPage('profile-setup');
        }

        // Track login
        await analyticsService.trackEvent('user_login');

      } else {
        store.setAuthenticated(false);
        store.setCurrentUser(null);
        store.setCurrentPage('welcome');
      }
    } catch (error) {
      console.error('Auth state change error:', error);
      store.setError('Failed to load user profile');
    } finally {
      store.setLoading(false);
    }
  });
};

// Export all services
export default {
  auth: authService,
  user: userService,
  matching: matchingService,
  messaging: messagingService,
  liveKit: liveKitService,
  analytics: analyticsService,
  initialize: initializeFirebaseListeners
};
// Critical authentication and profile loading fixes

import { getAuth, onAuthStateChanged } from 'firebase/auth';
import { getFirestore, doc, getDoc } from 'firebase/firestore';

// Fix 1: Proper user profile loading with unique user data
export const loadUserProfile = async (userId: string) => {
  const db = getFirestore();

  try {
    console.log('Loading profile for user ID:', userId);
    const userDoc = doc(db, 'users', userId);
    const userSnap = await getDoc(userDoc);

    if (userSnap.exists()) {
      const userData = userSnap.data();
      console.log('User data loaded:', userData);

      // Ensure we're getting the correct user's data
      if (userData.uid === userId) {
        return userData;
      } else {
        console.error('User ID mismatch! Expected:', userId, 'Got:', userData.uid);
        return null;
      }
    } else {
      console.log('No user document found for ID:', userId);
      return null;
    }
  } catch (error) {
    console.error('Error loading user profile:', error);
    return null;
  }
};

// Fix 2: Clear user profile state when switching users
export const clearUserProfile = () => {
  return {
    avatar: 'https://placehold.co/120x120/E1E1E1/BDBDBD?text=You',
    additionalPhotos: [] as string[],
    name: 'Loading...',
    about: '',
    prompts: { prompt1: '', prompt2: '' },
    age: 25,
    specialty: 'Loading...',
    location: 'Loading...',
    interests: [] as string[],
    giftPoints: 100,
    superLikes: 5,
    videoMinutes: 10,
    profileViews: 0,
    isPremium: false,
    subscriptionTier: 'free',
    darkMode: false,
    loginStreak: 1,
    lastLogin: Date.now(),
    earnedBadges: [] as string[],
    messagesSent: 0,
    adsWatchedPerTier: {},
    additionalPhotos: [] as string[],
    verificationStatus: 'unverified',
    verificationIdUrl: ''
  };
};

// Fix 3: Enhanced authentication state handler
export const setupAuthStateListener = (currentUserProfile: any, renderProfilePage: () => void, initializeFirebaseData: () => Promise<void>) => {
  const auth = getAuth();

  return onAuthStateChanged(auth, async (user) => {
    console.log('🔐 Auth state changed:', user?.uid || 'null');

    if (user) {
      console.log('✅ User authenticated:', user.email);

      // CRITICAL: Clear previous user data first
      Object.assign(currentUserProfile, clearUserProfile());

      // Load the specific user's data
      const userData = await loadUserProfile(user.uid);

      if (userData) {
        // Update with the correct user's data
        Object.assign(currentUserProfile, userData);
        console.log('✅ Profile loaded for user:', currentUserProfile.name);

        // Render the profile with the correct data
        renderProfilePage();

        // Initialize Firebase data
        await initializeFirebaseData();
      } else {
        console.log('❌ No profile found, redirecting to setup');
        // Redirect to profile setup
      }
    } else {
      console.log('❌ User signed out, clearing profile');
      Object.assign(currentUserProfile, clearUserProfile());
    }
  });
};

// Fix 4: Speed dating room participant tracking
export const updateSpeedDatingParticipants = async (roomId: string, action: 'join' | 'leave') => {
  const db = getFirestore();
  const auth = getAuth();

  if (!auth.currentUser) return;

  try {
    const roomRef = doc(db, 'speedDatingRooms', roomId);
    const roomSnap = await getDoc(roomRef);

    if (roomSnap.exists()) {
      const roomData = roomSnap.data();
      let participants = roomData.participants || [];

      if (action === 'join') {
        if (!participants.includes(auth.currentUser.uid)) {
          participants.push(auth.currentUser.uid);
        }
      } else if (action === 'leave') {
        participants = participants.filter((id: string) => id !== auth.currentUser.uid);
      }

      // Update the room with new participant count
      await import('firebase/firestore').then(({ updateDoc }) =>
        updateDoc(roomRef, {
          participants,
          participantCount: participants.length,
          lastUpdated: new Date()
        })
      );

      console.log(`Speed dating room ${roomId} updated: ${participants.length}/2 participants`);
      return participants.length;
    }
  } catch (error) {
    console.error('Error updating speed dating participants:', error);
  }

  return 0;
};

export default {
  loadUserProfile,
  clearUserProfile,
  setupAuthStateListener,
  updateSpeedDatingParticipants
};
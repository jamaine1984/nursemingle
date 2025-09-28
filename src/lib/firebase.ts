import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';
import { getStorage } from 'firebase/storage';
import { getFunctions } from 'firebase/functions';

// Firebase configuration - using environment variables with fallback
const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY || "AIzaSyCxY_A5M-LmYuy_rzSs2HsEqcGdaj05wOw",
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN || "nurse-mingle-2.firebaseapp.com",
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID || "nurse-mingle-2",
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET || "nurse-mingle-2.firebasestorage.app",
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID || "859917280016",
  appId: import.meta.env.VITE_FIREBASE_APP_ID || "1:859917280016:web:cc944e816d31d249bd3b95",
  measurementId: import.meta.env.VITE_FIREBASE_MEASUREMENT_ID || "G-9CMN4W0C47"
};

// Initialize Firebase app
const app = initializeApp(firebaseConfig);

// Initialize Firebase services
export const auth = getAuth(app);
export const db = getFirestore(app);
export const storage = getStorage(app);
export const functions = getFunctions(app);

// Export the app instance for testing
export default app;

console.log('Firebase initialized successfully with project:', firebaseConfig.projectId);
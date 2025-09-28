/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
*/

// Declare global types for the importmap loaded modules
declare const GoogleGenAI: any;
declare const Type: any;
declare const Chat: any;

// Initialize the Gemini AI model (will be loaded via importmap)
let ai: any = null;

// Firebase imports and initialization
import { initializeApp } from 'firebase/app';
import { getAuth, createUserWithEmailAndPassword, signInWithEmailAndPassword, onAuthStateChanged, signOut } from 'firebase/auth';
import { getFirestore, doc, setDoc, getDoc, collection, getDocs, query, where, orderBy, limit, addDoc, updateDoc, deleteDoc, onSnapshot } from 'firebase/firestore';
import { getStorage, ref, uploadBytes, getDownloadURL } from 'firebase/storage';

// Firebase configuration
const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY || "AIzaSyCxY_A5M-LmYuy_rzSs2HsEqcGdaj05wOw",
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN || "nurse-mingle-2.firebaseapp.com",
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID || "nurse-mingle-2",
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET || "nurse-mingle-2.firebasestorage.app",
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID || "859917280016",
  appId: import.meta.env.VITE_FIREBASE_APP_ID || "1:859917280016:web:cc944e816d31d249bd3b95",
  measurementId: import.meta.env.VITE_FIREBASE_MEASUREMENT_ID || "G-9CMN4W0C47"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);
const storage = getStorage(app);

// Initialize AI after the module is loaded
async function initializeAI() {
  try {
    // Only try to import if we're not in development mode or if the module exists
    if (import.meta.env.VITE_GEMINI_API_KEY && import.meta.env.VITE_GEMINI_API_KEY !== "demo_key") {
      const genAI = await import("@google/genai");
      ai = new genAI.GoogleGenAI({ apiKey: import.meta.env.VITE_GEMINI_API_KEY });
    } else {
      console.log("AI features unavailable - no API key provided");
      ai = null;
    }
  } catch (error) {
    console.log("AI features unavailable - using demo mode");
    ai = null;
  }
}

// --- MOCK DATA & DEFINITIONS ---

// Define all available badges
const allBadges = [
    { id: 'verified', name: 'Verified Nurse', icon: 'fa-check-circle', color: 'verified', criteria: 'Complete profile verification process.' },
    { id: 'contributor', name: 'Top Contributor', icon: 'fa-star', color: 'contributor', criteria: 'Send 50 messages and 10 gifts.' },
    { id: 'speed-dater', name: 'Speed Dater Pro', icon: 'fa-bolt', color: 'speed-dater', criteria: 'Participate in 5 Speed Dating sessions.' },
    { id: 'first-gift', name: 'First Gift', icon: 'fa-gift', color: 'gift-giver', criteria: 'Send your first gift to a match.' }
];

// Type definition for a chat message
type Message = {
    text: string;
    type: 'sent' | 'received' | 'gift';
    status: 'sent' | 'delivered' | 'read';
    timestamp: number;
    gift?: Gift;
    reactions?: Record<string, number>;
};

type Gift = {
  name: string;
  icon: string;
  price?: string;
  points?: number;
  type: 'free' | 'premium';
}

// Expanded Gift Catalog with Points
const freeGifts: Gift[] = [
    { name: 'Rose', icon: '🌹', type: 'free' }, { name: 'Coffee', icon: '☕', type: 'free' },
    { name: 'Chill Pill', icon: '💊', type: 'free', points: 50 }, { name: 'Donut', icon: '🍩', type: 'free', points: 75 },
    { name: 'Pizza Slice', icon: '🍕', type: 'free', points: 100 }, { name: 'Ice Cream', icon: '🍦', type: 'free', points: 100 },
    { name: 'High Five', icon: '🖐️', type: 'free' }, { name: 'Thumbs Up', icon: '👍', type: 'free' },
    { name: 'Heart', icon: '❤️', type: 'free' }, { name: 'Star', icon: '⭐', type: 'free', points: 150 },
    { name: 'Syringe', icon: '💉', type: 'free' }, { name: 'Band-Aid', icon: '🩹', type: 'free' },
    { name: 'Energy Drink', icon: '⚡️', type: 'free', points: 50 }, { name: 'Good Pen', icon: '🖊️', type: 'free' },
    { name: 'Comfy Socks', icon: '🧦', type: 'free', points: 75 }, { name: 'Snack Bar', icon: '🍫', type: 'free' },
    { name: 'Hand Sanitizer', icon: '🧴', type: 'free' }, { name: 'Badge Reel', icon: '🆔', type: 'free' },
    { name: 'Stethoscope Charm', icon: '✨', type: 'free', points: 100 }, { name: 'Funny Sticker', icon: '😂', type: 'free' },
    { name: 'Cup of Tea', icon: '🍵', type: 'free' }, { name: 'Hand Cream', icon: '🤲', type: 'free' },
    { name: 'Sleep Mask', icon: '😴', type: 'free', points: 125 }, { name: 'Stress Ball', icon: '🧠', type: 'free' },
    { name: 'IV (of coffee)', icon: '💧', type: 'free' }, { name: 'First Aid Kit', icon: '⛑️', type: 'free', points: 150 },
    { name: 'Thermometer', icon: '🌡️', type: 'free' }, { name: 'Clipboard', icon: '📋', type: 'free' },
    { name: 'Syringe Pen', icon: '🖋️', type: 'free' }, { name: 'Brain Cell', icon: '🧠', type: 'free' },
    { name: 'Golden Hour', icon: '🌇', type: 'free' }, { name: 'Night Shift Kit', icon: '🦉', type: 'free', points: 200 },
    { name: 'Day Shift Fuel', icon: '☀️', type: 'free', points: 200 }, { name: 'Patient Compliment', icon: '💌', type: 'free' },
    { name: 'Moment of Peace', icon: '🧘', type: 'free' }, { name: 'Extra Scrubs', icon: '👕', type: 'free' },
    { name: 'Charting Sticker', icon: '⭐', type: 'free' }, { name: 'Saline Flush', icon: '💦', type: 'free' },
    { name: 'Warm Blanket', icon: '🛌', type: 'free', points: 100 }, { name: 'A Hug', icon: '🤗', type: 'free' },
];
const premiumGifts: Gift[] = [
    { name: 'Diamond', icon: '💎', price: '$1.99', points: 500, type: 'premium' },
    { name: 'Stethoscope', icon: '🩺', price: '$4.99', points: 1000, type: 'premium' },
    { name: 'Mended Heart', icon: '❤️‍🩹', price: '$9.99', points: 2000, type: 'premium' },
    { name: 'Bouquet', icon: '💐', price: '$2.99', points: 750, type: 'premium' },
    { name: 'Teddy Bear', icon: '🧸', price: '$3.99', points: 900, type: 'premium' },
    { name: 'Fancy Coffee', icon: '☕️', price: '$0.99', points: 250, type: 'premium' },
    { name: 'Gourmet Chocolate', icon: '🍫', price: '$0.99', points: 250, type: 'premium' },
    { name: 'Movie Tickets', icon: '🎟️', price: '$0.99', points: 300, type: 'premium' },
    { name: 'Bottle of Wine', icon: '🍷', price: '$0.99', points: 300, type: 'premium' },
    { name: 'Lucky Charm', icon: '🍀', price: '$0.99', points: 200, type: 'premium' },
    { name: 'Spa Mask Set', icon: '🧖‍♀️', price: '$1.99', points: 450, type: 'premium' },
    { name: 'Funny Medical Mug', icon: '🍺', price: '$1.99', points: 450, type: 'premium' },
    { name: 'Bookworm\'s Delight', icon: '📚', price: '$1.99', points: 500, type: 'premium' },
    { name: 'Streaming Credit', icon: '📺', price: '$2.99', points: 600, type: 'premium' },
    { name: 'Plant Friend', icon: '🪴', price: '$2.99', points: 650, type: 'premium' },
    { name: 'Meal Voucher', icon: '🍱', price: '$3.99', points: 800, type: 'premium' },
    { name: 'Yoga Pass', icon: '🧘‍♂️', price: '$3.99', points: 850, type: 'premium' },
    { name: 'Scented Candle Set', icon: '🕯️', price: '$4.99', points: 1000, type: 'premium' },
    { name: 'Engraved Steth Tag', icon: '🏷️', price: '$4.99', points: 1100, type: 'premium' },
    { name: 'Cocktail Kit', icon: '🍸', price: '$5.99', points: 1200, type: 'premium' },
    { name: 'Plush Robe', icon: '🥋', price: '$5.99', points: 1300, type: 'premium' },
    { name: 'Wireless Earbuds', icon: '🎧', price: '$5.99', points: 1400, type: 'premium' },
    { name: 'Subscription Box', icon: '🎁', price: '$9.99', points: 2000, type: 'premium' },
    { name: 'Professional Massage', icon: '💆‍♀️', price: '$9.99', points: 2200, type: 'premium' },
    { name: 'Tasting Menu for Two', icon: '🍽️', price: '$14.99', points: 3000, type: 'premium' },
    { name: 'Noise-Cancelling Headphones', icon: '🎧', price: '$14.99', points: 3500, type: 'premium' },
    { name: 'Smart Watch', icon: '⌚', price: '$19.99', points: 4000, type: 'premium' },
    { name: 'Weighted Blanket', icon: '🛌', price: '$19.99', points: 4200, type: 'premium' },
    { name: 'Espresso Machine', icon: '☕', price: '$19.99', points: 4500, type: 'premium' },
    { name: 'Weekend Getaway', icon: '✈️', price: '$24.99', points: 5000, type: 'premium' },
    { name: 'Hot Air Balloon Ride', icon: '🎈', price: '$29.99', points: 6000, type: 'premium' },
    { name: 'Private Cooking Class', icon: '🧑‍🍳', price: '$34.99', points: 7000, type: 'premium' },
    { name: 'Designer Scrubs', icon: '👩‍⚕️', price: '$39.99', points: 8000, type: 'premium' },
    { name: 'Charity Donation', icon: '💖', price: '$49.99', points: 10000, type: 'premium' },
    { name: 'Concert Tickets', icon: '🎤', price: '$49.99', points: 12000, type: 'premium' },
    { name: 'Golden Otoscope', icon: '👂', price: '$1.99', points: 500, type: 'premium' },
    { name: 'Silver Reflex Hammer', icon: '🔨', price: '$1.99', points: 500, type: 'premium' },
    { name: 'Luxury Donuts', icon: '🍩', price: '$3.99', points: 800, type: 'premium' },
    { name: 'Foot Massager', icon: '🦶', price: '$9.99', points: 2100, type: 'premium' },
    { name: 'Airline Gift Card', icon: '🛫', price: '$24.99', points: 5500, type: 'premium' },
    { name: 'A Star Named After Them', icon: '⭐', price: '$19.99', points: 4000, type: 'premium' },
];

// Mock Vent & Vibe Posts
let ventPosts = [
  { id: 1, text: "Just finished a 14-hour shift and I swear I heard the telemetry beep in my dreams last night. Anyone else get phantom calls?", upvotes: 23, userVote: 0 },
  { id: 2, text: "A patient's family brought us all pizza today. It's the small things that get you through the week. So grateful.", upvotes: 152, userVote: 0 },
  { id: 3, text: "New to ICU and feeling so overwhelmed. Any advice for a newbie trying not to drown?", upvotes: 45, userVote: 0 },
];

document.addEventListener('DOMContentLoaded', async () => {
  // Initialize AI features
  await initializeAI();

  // --- ELEMENT SELECTORS ---
  const welcomeContainer = document.getElementById('welcome-container');
  const authContainer = document.getElementById('auth-container');
  const profileSetupContainer = document.getElementById('profile-setup-container');
  const appShell = document.getElementById('app-shell');

  const gotoAuthBtn = document.getElementById('goto-auth-btn');
  const authForm = document.getElementById('auth-form');
  const profileForm = document.getElementById('profile-form');

  // Profile Form Elements
  const avatarUpload = document.getElementById('avatar-upload') as HTMLInputElement;
  const avatarPreview = document.getElementById('avatar-preview') as HTMLImageElement;
  const ageSlider = document.getElementById('age-slider') as HTMLInputElement;
  const ageValue = document.getElementById('age-value') as HTMLSpanElement;

  const navButtons = document.querySelectorAll('.nav-btn');
  const pages = document.querySelectorAll('.page');
  const settingsButton = document.getElementById('settings-button');
  const likesYouBtn = document.getElementById('likes-you-btn');

  // Messages Page Elements
  const chatbotThread = document.getElementById('chatbot-thread');
  const messageListView = document.getElementById('message-list-view');
  const chatView = document.getElementById('chat-view');
  const backToListBtn = document.querySelector('.back-to-list-btn');
  const chatViewHeaderName = document.querySelector('#chat-view .chat-name');
  const chatViewHeaderAvatar = document.querySelector('#chat-view .chat-avatar') as HTMLImageElement;
  const chatMessagesContainer = document.querySelector('.chat-messages');
  const chatInput = document.getElementById('chat-input') as HTMLInputElement;
  const sendBtn = document.getElementById('send-btn');
  const messageSearchInput = document.getElementById('message-search-input') as HTMLInputElement;
  const noResultsMessage = document.getElementById('no-results-message');
  const messageThreadsContainer = document.querySelector('.message-threads');


  // Chat Options & Block
  const moreChatOptionsBtn = document.getElementById('more-chat-options-btn');
  const chatOptionsModal = document.getElementById('chat-options-modal');
  const blockUserBtn = document.getElementById('block-user-btn');

  // Gift Modal Elements
  const giftBtn = document.getElementById('gift-btn');
  const sendGiftModal = document.getElementById('send-gift-modal');
  const closeSendGiftModalBtn = document.querySelector('#send-gift-modal .close-modal-btn');
  
  // Gift Page Elements
  const giftsBackBtn = document.getElementById('gifts-back-btn');
  const freeGiftsGrid = document.getElementById('free-gifts-grid');
  const premiumGiftsGrid = document.getElementById('premium-gifts-grid');
  const sendableInventoryGrid = document.getElementById('sendable-inventory-grid');
  const receivedInventoryGrid = document.getElementById('received-inventory-grid');
  const emptySendableInventoryMessage = document.getElementById('empty-sendable-inventory-message');
  const emptyReceivedInventoryMessage = document.getElementById('empty-received-inventory-message');
  const giftPointsBalance = document.getElementById('gift-points-balance');
  
  // Match Modal Elements
  const matchModal = document.getElementById('match-modal');
  const matchNameEl = document.getElementById('match-name');
  const matchAvatarEl = document.getElementById('match-avatar') as HTMLImageElement;
  const generateIcebreakersBtn = document.getElementById('generate-icebreakers-btn');
  const icebreakersResultEl = document.getElementById('icebreakers-result');
  const keepSwipingBtn = document.getElementById('keep-swiping-btn');
  const matchSendMessageBtn = document.getElementById('match-send-message-btn');
  let currentMatchedUser: any = null;

  // Profile Page Elements
  const profileAvatar = document.getElementById('profile-avatar') as HTMLImageElement;
  const profileName = document.getElementById('profile-name');
  const profileSpecialty = document.getElementById('profile-specialty');
  const profileAboutText = document.getElementById('profile-about-text');
  const profilePromptsContainer = document.getElementById('profile-prompts-container');
  const profileInterestsContainer = document.getElementById('profile-interests-container');
  const myPhotosContainer = document.getElementById('my-photos-container');
  
  // Edit Profile Modal Elements
  const editProfileBtn = document.getElementById('edit-profile-btn');
  const editProfileModal = document.getElementById('edit-profile-modal');
  const editProfileForm = document.getElementById('edit-profile-form');
  const closeEditModalBtn = document.querySelector('.close-edit-modal-btn');
  const editAvatarUpload = document.getElementById('edit-avatar-upload') as HTMLInputElement;
  const editAvatarPreview = document.getElementById('edit-avatar-preview') as HTMLImageElement;
  const editAgeSlider = document.getElementById('edit-age-slider') as HTMLInputElement;
  const editAgeValue = document.getElementById('edit-age-value') as HTMLSpanElement;

  // Settings Page Elements
  const settingsBackBtn = document.getElementById('settings-back-btn');
  const gotoFiltersBtn = document.getElementById('goto-filters-btn');
  const gotoEditProfileBtn = document.getElementById('goto-edit-profile-btn');
  const gotoBlockedUsersBtn = document.getElementById('goto-blocked-users-btn');
  const darkModeToggle = document.getElementById('dark-mode-toggle') as HTMLInputElement;
  const gotoVerificationBtn = document.getElementById('goto-verification-btn');
  const verificationModal = document.getElementById('verification-modal');
  const gotoVentBtn = document.getElementById('goto-vent-btn');
  const gotoDashboardBtn = document.getElementById('goto-dashboard-btn');

  // Dashboard Page Elements
  const dashboardBackBtn = document.getElementById('dashboard-back-btn');

  // Filters Page Elements
  const filtersBackBtn = document.getElementById('filters-back-btn');
  
  // Blocked Users Page Elements
  const blockedUsersBackBtn = document.getElementById('blocked-users-back-btn');
  const blockedUsersList = document.getElementById('blocked-users-list');
  const emptyBlockedListMessage = document.getElementById('empty-blocked-list-message');

  // Boost Modal & Timer Elements
  const boostBtn = document.getElementById('boost-btn');
  const boostModal = document.getElementById('boost-modal');
  const closeBoostModalBtn = document.querySelector('#boost-modal .close-modal-btn');
  const closeBoostModalBtnBottom = document.getElementById('close-boost-modal-btn-bottom');
  const boostTimerEl = document.getElementById('boost-timer');

  // Watch Ad Modal Elements
  const watchAdModal = document.getElementById('watch-ad-modal');
  const watchAdTitle = document.getElementById('watch-ad-title');
  const watchAdCounter = document.getElementById('watch-ad-counter');
  const watchAdProgress = document.getElementById('watch-ad-progress') as HTMLDivElement;
  const skipAdBtn = document.getElementById('skip-ad-btn');

  // Stripe Modal Elements
  const stripeCheckoutModal = document.getElementById('stripe-checkout-modal');
  const stripePaymentForm = document.getElementById('stripe-payment-form');
  const closeStripeModalBtn = document.querySelector('#stripe-checkout-modal .close-modal-btn');
  const toastNotification = document.getElementById('toast-notification');

  // User Profile View Elements
  const userProfileView = document.getElementById('user-profile-view');
  const userProfileBackBtn = document.getElementById('user-profile-back-btn');
  const userProfileViewContent = document.querySelector('.profile-view-content');
  const userProfileMessageBtn = document.getElementById('user-profile-message-btn');

  // "Likes You" Page Elements
  const likesYouPage = document.getElementById('likes-you-page');
  const likesYouBackBtn = document.getElementById('likes-you-back-btn');
  const likesYouGrid = document.getElementById('likes-you-grid');
  const likesYouPremiumUpsell = document.getElementById('likes-you-premium-upsell');
  const likesYouCount = document.getElementById('likes-you-count');

  // Vent & Vibe Page Elements
  const ventBackBtn = document.getElementById('vent-back-btn');
  const ventPostInput = document.getElementById('vent-post-input') as HTMLTextAreaElement;
  const ventPostSubmit = document.getElementById('vent-post-submit');
  const ventPostsContainer = document.getElementById('vent-posts-container');
  
  // Daily Reward Modal
  const dailyRewardModal = document.getElementById('daily-reward-modal');
  const claimRewardBtn = document.getElementById('claim-reward-btn');

  // Speed Dating Page
  const speedDatingPage = document.getElementById('speed-dating-page');
  const speedDatingLobby = document.getElementById('speed-dating-lobby');
  const speedDatingRoom = document.getElementById('speed-dating-room');
  const speedDatingRoomsGrid = document.getElementById('speed-dating-rooms-grid');
  const speedDatingTimerEl = document.getElementById('speed-dating-timer');
  const speedDatingStatusOverlay = document.getElementById('speed-dating-status-overlay');
  const speedDatingStatusText = document.getElementById('speed-dating-status-text');
  const speedDatingControls = document.getElementById('speed-dating-controls');
  let speedDatingInterval: number | null = null;
  let currentRoomState = {
    userReady: false,
    opponentReady: false,
    timer: 0,
    userDecision: null as 'pass' | 'date' | null,
  };

  // Real users data from Firebase
  let userList: any[] = [];

  // Load users from Firebase
  async function loadUsers() {
    try {
      const usersRef = collection(db, 'users');
      const usersSnapshot = await getDocs(query(usersRef, limit(50)));
      userList = usersSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
      renderSwipeCards();
    } catch (error) {
      console.error('Error loading users:', error);
      userList = [];
    }
  }

  // Chat State
  let chatbotSession: Chat | null = null;
  let isChatbotActive = false;
  let currentChatUserId: string | null = null;

  // App State
  let currentUserProfile = {
      avatar: 'https://placehold.co/120x120/E1E1E1/BDBDBD?text=You',
      additionalPhotos: [] as string[],
      name: 'Your Name',
      about: '',
      prompts: {
        prompt1: '',
        prompt2: ''
      },
      age: 25,
      specialty: 'General Practice',
      location: 'Your Location',
      interests: [] as string[],
      earnedBadges: ['verified'] as string[],
      superLikes: 3,
      giftPoints: 100,
      lastLogin: 0,
      loginStreak: 0,
      isPremium: false,
      darkMode: false,
      verificationStatus: 'unverified' as 'unverified' | 'pending' | 'verified',
      verificationIdUrl: '',
      messagesSent: 0,
      adsWatchedPerTier: {} as Record<string, number>,
      videoMinutes: 0
  };
  let currentPremiumGift: Gift | null = null;
  let blockedUsers: string[] = [];
  let boostEndTime: number | null = null;
  let boostInterval: number | null = null;
  let currentUserInView: any = null;
  let usersWhoLikedYou: string[] = [];

  // Load users who liked current user from Firebase
  async function loadUsersWhoLikedYou() {
    try {
      if (!auth.currentUser) return;
      const likesRef = collection(db, 'likes');
      const likesSnapshot = await getDocs(query(
        likesRef,
        where('likedUserId', '==', auth.currentUser.uid),
        where('isMatched', '==', false)
      ));
      usersWhoLikedYou = likesSnapshot.docs.map(doc => doc.data().likerId);
    } catch (error) {
      console.error('Error loading likes:', error);
      usersWhoLikedYou = [];
    }
  }


  // --- CHAT PERSISTENCE HELPERS ---
  function getChatId(userId: string): string { return `${auth.currentUser?.uid}_${userId}`; }

  async function loadMessages(chatId: string): Promise<Message[]> {
    try {
      const messagesRef = collection(db, 'chats', chatId, 'messages');
      const messagesSnapshot = await getDocs(query(messagesRef, orderBy('timestamp', 'asc')));
      return messagesSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() } as Message));
    } catch (error) {
      console.error('Error loading messages:', error);
      return [];
    }
  }

  async function saveMessage(chatId: string, message: Message) {
    try {
      const messagesRef = collection(db, 'chats', chatId, 'messages');
      await addDoc(messagesRef, {
        ...message,
        timestamp: new Date()
      });
    } catch (error) {
      console.error('Error saving message:', error);
    }
  }
  
  // --- GIFT INVENTORY & PERSISTENCE ---
  type GiftInventory = Record<string, Gift & { count: number }>;

  function getSendableGiftInventory(): GiftInventory {
    const saved = localStorage.getItem('user_sendable_gift_inventory');
    return saved ? JSON.parse(saved) : {};
  }
  function saveSendableGiftInventory(inventory: GiftInventory) {
      localStorage.setItem('user_sendable_gift_inventory', JSON.stringify(inventory));
      renderGiftsPage();
  }
  function addGiftToSendableInventory(gift: Gift) {
      const inventory = getSendableGiftInventory();
      inventory[gift.name] = { ...gift, count: (inventory[gift.name]?.count || 0) + 1 };
      saveSendableGiftInventory(inventory);
  }
  function sendGiftFromInventory(gift: Gift, recipientUserId: string) {
    const inventory = getSendableGiftInventory();
    if (!inventory[gift.name] || inventory[gift.name].count === 0) {
        showToast("You don't have this gift to send!");
        return;
    }
    inventory[gift.name].count--;
    if (inventory[gift.name].count === 0) delete inventory[gift.name];
    saveSendableGiftInventory(inventory);
    
    const chatId = getChatId(recipientUserId);
    const messages = loadMessages(chatId);
    messages.push({ text: '', type: 'gift', status: 'sent', timestamp: Date.now(), gift: gift });
    saveMessages(chatId, messages);
    if(currentChatUserId === recipientUserId) appendMessage(messages[messages.length-1]);
    
    if (!currentUserProfile.earnedBadges.includes('first-gift')) {
        currentUserProfile.earnedBadges.push('first-gift');
        renderProfilePage();
    }
    showToast(`You sent a ${gift.name}!`);
    sendGiftModal?.classList.add('hidden');
  }

  // --- BLOCK/UNBLOCK HELPERS ---
  function getBlockedUsers(): string[] { const saved = localStorage.getItem('blocked_users'); return saved ? JSON.parse(saved) : []; }
  function saveBlockedUsers() { localStorage.setItem('blocked_users', JSON.stringify(blockedUsers)); }
  function isUserBlocked(userId: string): boolean { return blockedUsers.includes(userId); }
  function blockUser(userId: string) {
    if (!userId || isUserBlocked(userId)) return;
    blockedUsers.push(userId);
    saveBlockedUsers();
    showToast(`User has been blocked.`);
    chatOptionsModal?.classList.add('hidden');
    backToListBtn?.dispatchEvent(new MouseEvent('click'));
    document.querySelector(`.message-thread-item[data-user-id="${userId}"]`)?.remove();
    userList = userList.filter(u => u.id !== userId);
    loadSwipeCards();
  }
  function unblockUser(userId: string) {
    if (!userId || !isUserBlocked(userId)) return;
    blockedUsers = blockedUsers.filter(id => id !== userId);
    saveBlockedUsers();
    const unblockedUser = users.find(u => u.id === userId);
    if(unblockedUser) {
        if(!userList.find(u => u.id === userId)) userList.push(unblockedUser);
        showToast(`${unblockedUser.name} has been unblocked.`);
    }
    renderBlockedUsersPage();
  }

  // --- DARK MODE LOGIC ---
  function applyDarkMode(isDark: boolean) {
      currentUserProfile.darkMode = isDark;
      document.body.classList.toggle('dark-mode', isDark);
      localStorage.setItem('nurse_mingle_dark_mode', isDark.toString());
  }

  // --- DAILY REWARD LOGIC ---
  const dailyRewards = [
      { name: "50 Gift Points", icon: "fas fa-coins", desc: "Start your collection!", action: () => currentUserProfile.giftPoints += 50 },
      { name: "1 Super Like", icon: "fas fa-star", desc: "Make someone's day!", action: () => currentUserProfile.superLikes += 1 },
      { name: "100 Gift Points", icon: "fas fa-coins", desc: "Getting closer to a gift!", action: () => currentUserProfile.giftPoints += 100 },
      { name: "Profile Boost", icon: "fas fa-bolt", desc: "15 minutes of fame!", action: () => startBoostTimer(15) },
      { name: "200 Gift Points", icon: "fas fa-coins", desc: "You're on a roll!", action: () => currentUserProfile.giftPoints += 200 },
      { name: "3 Super Likes", icon: "fas fa-star", desc: "Get noticed by your favorites!", action: () => currentUserProfile.superLikes += 3 },
      { name: "500 Gift Points", icon: "fas fa-gift", desc: "A special gift on us!", action: () => currentUserProfile.giftPoints += 500 },
  ];
  function checkDailyLogin() {
    const lastLogin = new Date(currentUserProfile.lastLogin);
    const now = new Date();
    const isNewDay = now.toDateString() !== lastLogin.toDateString();

    if (isNewDay) {
        const yesterday = new Date();
        yesterday.setDate(now.getDate() - 1);
        if (lastLogin.toDateString() === yesterday.toDateString()) {
            currentUserProfile.loginStreak++;
        } else {
            currentUserProfile.loginStreak = 1;
        }
        currentUserProfile.lastLogin = now.getTime();
        showDailyRewardModal();
    }
  }
  function showDailyRewardModal() {
    const streak = Math.min(currentUserProfile.loginStreak, 7);
    const reward = dailyRewards[streak - 1];
    
    (document.getElementById('daily-reward-title') as HTMLElement).textContent = `Day ${streak} Login Reward!`;
    (document.getElementById('daily-reward-subtitle') as HTMLElement).textContent = streak < 7 ? `Come back tomorrow for an even better reward!` : "You've completed a full week!";
    (document.getElementById('daily-reward-item') as HTMLElement).innerHTML = `
        <div id="daily-reward-icon"><i class="${reward.icon}"></i></div>
        <h3 id="daily-reward-name">${reward.name}</h3>
        <p id="daily-reward-desc">${reward.desc}</p>
    `;
    dailyRewardModal?.classList.remove('hidden');
  }
  claimRewardBtn?.addEventListener('click', () => {
    const streak = Math.min(currentUserProfile.loginStreak, 7);
    dailyRewards[streak - 1].action();
    dailyRewardModal?.classList.add('hidden');
    showToast("Reward claimed!");
    updateGiftPointsDisplay();
  });


  // --- INITIALIZATION ---
  createFallingObjects();
  createSparkleTrail();
  blockedUsers = getBlockedUsers();
  renderGiftsPage();
  renderMessageThreads();
  
  const savedDarkMode = localStorage.getItem('nurse_mingle_dark_mode') === 'true';
  darkModeToggle.checked = savedDarkMode;
  applyDarkMode(savedDarkMode);


  // --- INITIAL APP STATE SETUP ---
  // Ensure welcome screen shows by default
  welcomeContainer?.classList.remove('hidden');
  authContainer?.classList.add('hidden');
  profileSetupContainer?.classList.add('hidden');
  appShell?.classList.add('hidden');

  // Listen for authentication state changes
  onAuthStateChanged(auth, async (user) => {
    if (user) {
      // User is signed in, load their profile
      try {
        const userDoc = await getDoc(doc(db, 'users', user.uid));
        if (userDoc.exists()) {
          currentUserProfile = { ...currentUserProfile, ...userDoc.data() };
          welcomeContainer?.classList.add('hidden');
          authContainer?.classList.add('hidden');
          profileSetupContainer?.classList.add('hidden');
          appShell?.classList.remove('hidden');
          await loadUsers();
          await loadUsersWhoLikedYou();
          loadSwipeCards();
          renderProfilePage();
        } else {
          // User exists but no profile - show profile setup
          welcomeContainer?.classList.add('hidden');
          authContainer?.classList.add('hidden');
          profileSetupContainer?.classList.remove('hidden');
          appShell?.classList.add('hidden');
        }
      } catch (error) {
        console.error('Error loading user profile:', error);
        // On error, show welcome screen
        welcomeContainer?.classList.remove('hidden');
        authContainer?.classList.add('hidden');
        profileSetupContainer?.classList.add('hidden');
        appShell?.classList.add('hidden');
      }
    } else {
      // User is signed out - show welcome screen
      welcomeContainer?.classList.remove('hidden');
      authContainer?.classList.add('hidden');
      profileSetupContainer?.classList.add('hidden');
      appShell?.classList.add('hidden');
    }
  });

  // --- ONBOARDING & APP FLOW ---
  console.log('Setting up Get Started button listener. Button found:', !!gotoAuthBtn);
  gotoAuthBtn?.addEventListener('click', () => {
    console.log('Get Started button clicked!');
    welcomeContainer?.classList.add('hidden');
    authContainer?.classList.remove('hidden');
  });
  authForm?.addEventListener('submit', async (e) => {
    e.preventDefault();
    const formData = new FormData(authForm as HTMLFormElement);
    const email = formData.get('email') as string;
    const password = formData.get('password') as string;
    const isSignUp = (e.submitter as HTMLButtonElement)?.textContent?.includes('Sign Up');

    try {
      if (isSignUp) {
        await createUserWithEmailAndPassword(auth, email, password);
        showToast('Account created successfully!');
      } else {
        await signInWithEmailAndPassword(auth, email, password);
        showToast('Signed in successfully!');
      }
      authContainer?.classList.add('hidden');
      profileSetupContainer?.classList.remove('hidden');
    } catch (error: any) {
      showToast(error.message, true);
    }
  });
  profileForm?.addEventListener('submit', async (e) => {
    e.preventDefault();

    if (!auth.currentUser) {
      showToast('Please sign in first', true);
      return;
    }

    currentUserProfile.name = (document.getElementById('full-name') as HTMLInputElement).value;
    currentUserProfile.about = (document.getElementById('about') as HTMLTextAreaElement).value;
    currentUserProfile.age = parseInt((document.getElementById('age-slider') as HTMLInputElement).value, 10);
    currentUserProfile.specialty = (document.getElementById('specialty') as HTMLSelectElement).value;
    currentUserProfile.location = (document.getElementById('location') as HTMLInputElement).value;
    currentUserProfile.interests = Array.from(profileForm.querySelectorAll('.interest-tag.active')).map(tag => tag.textContent || '').filter(Boolean);
    currentUserProfile.prompts.prompt1 = (document.getElementById('profile-prompt-1') as HTMLInputElement).value;

    try {
      // Upload avatar to Firebase Storage if provided
      const avatarFile = avatarUpload.files?.[0];
      if (avatarFile) {
        const avatarRef = ref(storage, `avatars/${auth.currentUser.uid}/${Date.now()}`);
        const uploadResult = await uploadBytes(avatarRef, avatarFile);
        currentUserProfile.avatar = await getDownloadURL(uploadResult.ref);
      }

      // Save user profile to Firestore
      await setDoc(doc(db, 'users', auth.currentUser.uid), {
        ...currentUserProfile,
        email: auth.currentUser.email,
        createdAt: new Date(),
        lastActive: new Date()
      });

      showToast('Profile created successfully!');
      renderProfilePage();
      profileSetupContainer?.classList.add('hidden');
      appShell?.classList.remove('hidden');
      await loadUsers();
      loadSwipeCards();
      checkDailyLogin();
    } catch (error: any) {
      showToast('Error creating profile: ' + error.message, true);
    }
  });

  // --- PROFILE LOGIC ---
  function renderProfilePage() {
    if (profileAvatar) profileAvatar.src = currentUserProfile.avatar;
    if (profileName) profileName.textContent = `${currentUserProfile.name}, ${currentUserProfile.age}`;
    if (profileSpecialty) profileSpecialty.textContent = `${currentUserProfile.specialty} | ${currentUserProfile.location}`;
    if (profileAboutText) profileAboutText.textContent = currentUserProfile.about || 'No bio yet.';
    
    if (myPhotosContainer) {
        const photos = [currentUserProfile.avatar, ...currentUserProfile.additionalPhotos].filter(Boolean);
        myPhotosContainer.innerHTML = photos.map(photoUrl => `<img src="${photoUrl}" alt="Your photo">`).join('');
    }
    
    // Render Prompts
    if (profilePromptsContainer) {
        profilePromptsContainer.innerHTML = '<h4>Prompts</h4>';
        if (currentUserProfile.prompts.prompt1) {
            profilePromptsContainer.innerHTML += `<div class="prompt-block"><p class="prompt-question">My favorite way to de-stress is...</p><p class="prompt-answer">“${currentUserProfile.prompts.prompt1}”</p></div>`;
        }
        if (currentUserProfile.prompts.prompt2) {
             profilePromptsContainer.innerHTML += `<div class="prompt-block"><p class="prompt-question">A patient story I'll never forget is...</p><p class="prompt-answer">“${currentUserProfile.prompts.prompt2}”</p></div>`;
        }
    }

    if (profileInterestsContainer) {
        profileInterestsContainer.innerHTML = '';
        currentUserProfile.interests.forEach(interest => {
            const tag = Object.assign(document.createElement('button'), { type: 'button', className: 'interest-tag active', textContent: interest });
            profileInterestsContainer.appendChild(tag);
        });
    }

    const badgesContainer = document.querySelector('#profile-page .badges-container');
    if (badgesContainer) {
        badgesContainer.innerHTML = '';
        allBadges.forEach(badgeInfo => {
            const badgeEl = document.createElement('div');
            badgeEl.title = badgeInfo.criteria;
            const hasBadge = currentUserProfile.earnedBadges.includes(badgeInfo.id);
            badgeEl.className = `badge ${hasBadge ? '' : 'locked'}`;
            badgeEl.innerHTML = `<i class="fas ${hasBadge ? badgeInfo.icon : 'fa-lock'} badge-icon ${hasBadge ? badgeInfo.color : ''}"></i><span class="badge-label">${badgeInfo.name}</span>`;
            badgesContainer.appendChild(badgeEl);
        });
    }
  }

  // --- MAIN APP NAVIGATION ---
  function showPage(pageId: string) {
    pages.forEach(page => page.classList.toggle('hidden', page.id !== pageId));
    if (pageId === 'gifts-page') renderGiftsPage();
    if (pageId === 'vent-page') renderVentPosts();
    if (pageId === 'likes-you-page') renderLikesYouPage();
    if (pageId === 'dashboard-page') renderDashboardPage();
    if (pageId === 'speed-dating-page') setupSpeedDatingLobby();
    else if(speedDatingInterval) { // Stop timer when leaving page
        clearInterval(speedDatingInterval);
        speedDatingInterval = null;
    }
  }

  navButtons.forEach(button => {
    button.addEventListener('click', () => {
      const pageId = (button as HTMLElement).dataset.page;
      if (pageId) {
        navButtons.forEach(btn => btn.classList.remove('active'));
        button.classList.add('active');
        showPage(pageId);
      }
    });
  });

  // --- Settings & Sub-page Navigation ---
  settingsButton?.addEventListener('click', () => { navButtons.forEach(btn => btn.classList.remove('active')); showPage('settings-page'); });
  settingsBackBtn?.addEventListener('click', () => (document.querySelector('.nav-btn.active') || document.querySelector('.nav-btn[data-page="home-page"]'))?.dispatchEvent(new MouseEvent('click')));
  likesYouBtn?.addEventListener('click', () => showPage('likes-you-page'));
  likesYouBackBtn?.addEventListener('click', () => (document.querySelector('.nav-btn[data-page="home-page"]'))?.dispatchEvent(new MouseEvent('click')));
  
  giftsBackBtn?.addEventListener('click', () => (document.querySelector('.nav-btn[data-page="profile-page"]'))?.dispatchEvent(new MouseEvent('click'))); // Go to profile as nav is there now
  gotoVentBtn?.addEventListener('click', () => showPage('vent-page'));
  ventBackBtn?.addEventListener('click', () => showPage('settings-page'));
  gotoDashboardBtn?.addEventListener('click', () => showPage('dashboard-page'));
  dashboardBackBtn?.addEventListener('click', () => showPage('settings-page'));


  gotoFiltersBtn?.addEventListener('click', () => showPage('filters-page'));
  filtersBackBtn?.addEventListener('click', () => showPage('settings-page'));
  gotoBlockedUsersBtn?.addEventListener('click', () => { renderBlockedUsersPage(); showPage('blocked-users-page'); });
  blockedUsersBackBtn?.addEventListener('click', () => showPage('settings-page'));
  darkModeToggle?.addEventListener('change', () => applyDarkMode(darkModeToggle.checked));
  gotoVerificationBtn?.addEventListener('click', () => { renderVerificationModal(); verificationModal?.classList.remove('hidden'); });
  verificationModal?.addEventListener('click', (e) => { if (e.target === verificationModal || (e.target as HTMLElement).closest('.close-modal-btn')) verificationModal.classList.add('hidden'); });

  // --- CHAT LOGIC ---
  backToListBtn?.addEventListener('click', () => {
      chatView?.classList.add('hidden');
      messageListView?.classList.remove('hidden');
      currentChatUserId = null;
  });

  function renderMessageThreads() {
    if (!messageThreadsContainer) return;
    // Clear existing user threads
    messageThreadsContainer.querySelectorAll('.message-thread-item:not(#chatbot-thread)').forEach(el => el.remove());
    
    // For now, render threads for all users in the initial list
    users.forEach(user => {
      const threadEl = document.createElement('div');
      threadEl.className = 'message-thread-item';
      threadEl.dataset.userId = user.id;
      threadEl.innerHTML = `
        <img src="${user.img}" alt="${user.name}">
        <div class="thread-info">
          <div class="thread-name-wrapper">
            <div class="thread-name">${user.name}</div>
            <div class="unread-indicator"></div>
          </div>
          <div class="thread-preview">Click to start chatting...</div>
        </div>
      `;
      threadEl.addEventListener('click', () => openChat(user));
      messageThreadsContainer.appendChild(threadEl);
    });
  }

  function openChat(user: any) {
    if (!user || !user.id) return;

    // Navigate to the messages page first
    showPage('messages-page');
    navButtons.forEach(btn => btn.classList.remove('active'));
    document.querySelector('.nav-btn[data-page="messages-page"]')?.classList.add('active');

    // Then open the specific chat view
    isChatbotActive = false;
    currentChatUserId = user.id;

    if (chatViewHeaderName) chatViewHeaderName.textContent = user.name;
    if (chatViewHeaderAvatar) chatViewHeaderAvatar.src = user.img;

    if (chatMessagesContainer) chatMessagesContainer.innerHTML = '';
    const chatId = getChatId(user.id);
    const messages = loadMessages(chatId);
    messages.forEach(appendMessage);
    
    const videoCallBtn = document.getElementById('video-call-btn');
    const audioCallBtn = document.getElementById('audio-call-btn');
    videoCallBtn?.addEventListener('click', () => startCall('video', user));
    audioCallBtn?.addEventListener('click', () => startCall('audio', user));


    messageListView?.classList.add('hidden');
    chatView?.classList.remove('hidden');
  }

  function handleSendMessage() {
      const messageText = chatInput?.value.trim();
      if (!messageText || !chatInput) return;

      if (isChatbotActive && chatbotSession) {
          appendMessage({ text: messageText, type: 'sent', status: 'read', timestamp: Date.now() });
          chatInput.value = '';
          handleChatbotResponse(messageText);
      } else {
          if (!currentChatUserId) return;
          const chatId = getChatId(currentChatUserId);
          let messages = loadMessages(chatId);
          const userMessage: Message = { text: messageText, type: 'sent', status: 'sent', timestamp: Date.now() };
          messages.push(userMessage);
          saveMessages(chatId, messages);
          appendMessage(userMessage);
          chatInput.value = '';
          currentUserProfile.messagesSent = (currentUserProfile.messagesSent || 0) + 1;
      }
  }

  async function handleChatbotResponse(message: string) {
      if (!chatMessagesContainer || !chatbotSession) return;
      try {
          const response = await chatbotSession.sendMessage({ message: message });
          appendMessage({ text: response.text, type: 'received', status: 'read', timestamp: Date.now() });
      } catch (error) {
          console.error("Chatbot Error:", error);
          appendMessage({ text: "Sorry, I'm having trouble. Please try again.", type: 'received', status: 'read', timestamp: Date.now() });
      }
  }
  
  function appendMessage(message: Message) {
      if (!chatMessagesContainer) return;

      const wrapper = document.createElement('div');
      wrapper.className = `chat-bubble-wrapper ${message.type}`;
      
      const bubble = document.createElement('div');
      bubble.id = `msg-${message.timestamp}`;
      
      if (message.type === 'gift' && message.gift) {
          bubble.className = `chat-bubble gift-bubble`;
          bubble.innerHTML = `<span>${message.gift.icon}</span>`;
      } else {
          bubble.className = `chat-bubble`;
          bubble.innerHTML = `<span>${message.text}</span>`;
          if (message.type === 'sent') {
              bubble.innerHTML += `<div class="message-meta"><span class="message-timestamp">${new Date(message.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</span></div>`;
          }
          bubble.addEventListener('click', () => showReactionPicker(message.timestamp));
      }
      
      wrapper.appendChild(bubble);
      
      const reactionsDiv = document.createElement('div');
      reactionsDiv.className = 'chat-reactions';
      reactionsDiv.id = `reactions-${message.timestamp}`;
      if (message.reactions) renderReactions(reactionsDiv, message.reactions);
      wrapper.appendChild(reactionsDiv);
      
      chatMessagesContainer.appendChild(wrapper);
      chatMessagesContainer.scrollTop = chatMessagesContainer.scrollHeight;
  }
  
  function showReactionPicker(timestamp: number) {
      const reactions = ['❤️', '😂', '👍', '😢', '😮'];
      // For simplicity, we'll just add a reaction directly.
      const chosenReaction = reactions[Math.floor(Math.random() * reactions.length)];
      if (!currentChatUserId) return;
      
      const chatId = getChatId(currentChatUserId);
      const messages = loadMessages(chatId);
      const msgIndex = messages.findIndex(m => m.timestamp === timestamp);
      if (msgIndex === -1) return;
      
      if (!messages[msgIndex].reactions) messages[msgIndex].reactions = {};
      messages[msgIndex].reactions![chosenReaction] = (messages[msgIndex].reactions![chosenReaction] || 0) + 1;
      
      saveMessages(chatId, messages);
      const reactionsDiv = document.getElementById(`reactions-${timestamp}`);
      if (reactionsDiv) renderReactions(reactionsDiv, messages[msgIndex].reactions!);
  }

  function renderReactions(container: HTMLElement, reactions: Record<string, number>) {
    container.innerHTML = Object.entries(reactions).map(([emoji, count]) => `
      <div class="reaction">${emoji} <span class="reaction-count">${count > 1 ? count : ''}</span></div>
    `).join('');
  }


  // --- GIFT LOGIC & UI ---
  giftBtn?.addEventListener('click', () => { if(currentChatUserId) { renderSendGiftModal(currentChatUserId); sendGiftModal?.classList.remove('hidden'); } });
  closeSendGiftModalBtn?.addEventListener('click', () => sendGiftModal?.classList.add('hidden'));
  sendGiftModal?.addEventListener('click', (e) => { if (e.target === sendGiftModal) sendGiftModal?.classList.add('hidden'); });
  
  function updateGiftPointsDisplay() { if (giftPointsBalance) giftPointsBalance.textContent = currentUserProfile.giftPoints.toString(); }
  
  function watchAdForFreeGift(gift: Gift) {
      if (!watchAdModal) return;
      watchAdModal.classList.remove('hidden');
      if (watchAdTitle) watchAdTitle.textContent = `Acquiring ${gift.name}...`;
      if (watchAdCounter) watchAdCounter.textContent = "Watching ad to earn your gift!";
      if (skipAdBtn) skipAdBtn.style.display = 'none';

      let progress = 0;
      if (watchAdProgress) watchAdProgress.style.width = '0%';

      if (adInterval) clearInterval(adInterval);
      adInterval = window.setInterval(() => {
          progress += 10;
          if (watchAdProgress) watchAdProgress.style.width = `${progress}%`;
          if (progress >= 100) {
              clearInterval(adInterval!);
              adInterval = null;
              watchAdModal.classList.add('hidden');
              
              addGiftToSendableInventory(gift);
              showToast(`${gift.name} acquired!`);

              // Reset modal for next use
              if (skipAdBtn) skipAdBtn.style.display = 'block';
          }
      }, 200);
  }

  function renderGiftsPage() {
    if (!freeGiftsGrid || !premiumGiftsGrid || !sendableInventoryGrid) return;
    updateGiftPointsDisplay();
    
    freeGiftsGrid.innerHTML = '';
    premiumGiftsGrid.innerHTML = '';
    [...freeGifts, ...premiumGifts].forEach(gift => {
        const item = document.createElement('div');
        item.className = 'gift-item';
        let actionsHTML = '';
        if (gift.type === 'free' && gift.points) {
            actionsHTML = `<button class="btn-buy-points" data-gift-name="${gift.name}"><i class="fas fa-coins"></i> ${gift.points}</button>`;
        } else if (gift.type === 'free') {
            actionsHTML = `<button class="btn-watch-ad" data-gift-name="${gift.name}">Watch Ad</button>`;
        } else {
             actionsHTML = `<div class="gift-price">${gift.price}</div>`;
             item.addEventListener('click', () => purchasePremiumGift(gift));
        }
        item.innerHTML = `<div class="gift-icon">${gift.icon}</div><div class="gift-name">${gift.name}</div>${actionsHTML}`;
        (gift.type === 'free' ? freeGiftsGrid : premiumGiftsGrid).appendChild(item);
    });

    freeGiftsGrid.querySelectorAll('.btn-buy-points').forEach(btn => btn.addEventListener('click', (e) => {
        const giftName = (e.currentTarget as HTMLElement).dataset.giftName;
        const gift = [...freeGifts, ...premiumGifts].find(g => g.name === giftName);
        if (gift && gift.points && currentUserProfile.giftPoints >= gift.points) {
            currentUserProfile.giftPoints -= gift.points;
            addGiftToSendableInventory(gift);
            updateGiftPointsDisplay();
            showToast(`${gift.name} acquired!`);
        } else { showToast("Not enough points!"); }
    }));
    
    freeGiftsGrid.querySelectorAll('.btn-watch-ad').forEach(btn => btn.addEventListener('click', (e) => {
        const giftName = (e.currentTarget as HTMLElement).dataset.giftName;
        const gift = freeGifts.find(g => g.name === giftName);
        if (gift) {
            watchAdForFreeGift(gift);
        }
    }));

    const sendableInventory = getSendableGiftInventory();
    sendableInventoryGrid.innerHTML = '';
    if (Object.keys(sendableInventory).length > 0) {
        emptySendableInventoryMessage?.classList.add('hidden');
        Object.values(sendableInventory).forEach(gift => sendableInventoryGrid.appendChild(createInventoryItem(gift)));
    } else { emptySendableInventoryMessage?.classList.remove('hidden'); }
  }

  function createInventoryItem(gift: Gift & { count: number }) {
    return Object.assign(document.createElement('div'), {
        className: 'inventory-item',
        innerHTML: `<div class="inventory-count">${gift.count}</div><div class="gift-icon">${gift.icon}</div><div class="gift-name">${gift.name}</div>`
    });
  }
  
  function purchasePremiumGift(gift: Gift) { /* ... existing logic ... */ }
  function handleStripePayment(e: Event) { /* ... existing logic ... */ }

  function renderSendGiftModal(recipientUserId: string) {
    const grid = document.getElementById('send-gift-inventory-grid');
    const emptyMsg = document.getElementById('empty-send-gift-inventory-message');
    if (!grid || !emptyMsg) return;

    const gifts = Object.values(getSendableGiftInventory());
    grid.innerHTML = '';
    emptyMsg.classList.toggle('hidden', gifts.length > 0);
    
    gifts.forEach(gift => {
        const item = createInventoryItem(gift);
        item.classList.add('gift-item');
        item.addEventListener('click', () => sendGiftFromInventory(gift, recipientUserId));
        grid.appendChild(item);
    });
  }

  // --- UI HELPERS ---
  function showToast(message: string, isError: boolean = false) {
      if (!toastNotification) return;
      toastNotification.textContent = message;
      toastNotification.classList.add('show');
      setTimeout(() => toastNotification.classList.remove('show'), 3000);
  }

  function createFallingObjects() {
    const container = document.getElementById('welcome-container');
    if (!container) return;
    const objects = [
        { char: '❤️', className: 'heart' },
        { char: '💊', className: 'pill' },
        { char: '🩹', className: 'bandaid' }
    ];
    
    const intervalId = setInterval(() => {
        if (container.classList.contains('hidden')) {
            clearInterval(intervalId);
            return;
        }
        
        const objData = objects[Math.floor(Math.random() * objects.length)];
        const el = document.createElement('div');
        el.textContent = objData.char;
        el.className = `falling-object ${objData.className}`;
        el.style.left = `${Math.random() * 100}%`;
        el.style.fontSize = `${Math.random() * 20 + 15}px`;
        el.style.animationDuration = `${Math.random() * 5 + 8}s`;
        el.style.animationDelay = `${Math.random() * 2}s`;
        
        container.appendChild(el);

        setTimeout(() => {
            el.remove();
        }, 13000); // Duration + Delay
    }, 400);
  }

  function createSparkleTrail() {
      const sparkleContainer = document.getElementById('sparkle-container');
      if (!sparkleContainer) return;
      const colors = ['#ffc700', '#ff5252', '#448aff', '#00e676', '#ff80ab', '#ffffff'];

      document.body.addEventListener('mousemove', (e) => {
          for (let i = 0; i < 5; i++) { // Create a burst of 5 sparkles
              const sparkle = document.createElement('div');
              sparkle.className = 'sparkle';
              sparkle.style.top = `${e.pageY}px`;
              sparkle.style.left = `${e.pageX}px`;
              
              const size = Math.random() * 8 + 4; // 4px to 12px
              sparkle.style.width = `${size}px`;
              sparkle.style.height = `${size}px`;
              sparkle.style.background = colors[Math.floor(Math.random() * colors.length)];

              const angle = Math.random() * 2 * Math.PI;
              const radius = Math.random() * 60 + 20; // Fly out further
              const xOffset = Math.cos(angle) * radius;
              const yOffset = Math.sin(angle) * radius;
              const duration = Math.random() * 0.6 + 0.4; // 0.4s to 1s

              sparkle.style.setProperty('--x-offset', `${xOffset}px`);
              sparkle.style.setProperty('--y-offset', `${yOffset}px`);
              sparkle.style.animationDuration = `${duration}s`;

              sparkleContainer.appendChild(sparkle);

              setTimeout(() => {
                  sparkle.remove();
              }, duration * 1000); 
          }
      });
  }

  // --- SWIPE CARD LOGIC ---
  const swipeDeck = document.getElementById('swipe-deck');
  let activeCard: HTMLElement | null = null, activeCardData: any = null, startX = 0, startY = 0, currentX = 0, currentY = 0, isDragging = false, wasDragged = false, lastSwipedUser: any = null;
  
  function createCard(user: typeof users[0]) {
    const card = document.createElement('div');
    card.className = 'swipe-card';
    if (user.boosted) card.classList.add('boosted');
    card.innerHTML = `${user.boosted ? `<div class="boost-indicator"><i class="fas fa-bolt"></i></div>` : ''}<img src="${user.img}" alt="${user.name}"><div class="swipe-card-info"><h3>${user.name}, ${user.age}</h3><p>${user.specialty} | ${user.location}</p></div>`;
    (card as any).userData = user;
    return card;
  }
  
  function updateCardStackStyles() {
    if (!swipeDeck) return;
    const cards = Array.from(swipeDeck.querySelectorAll('.swipe-card')) as HTMLElement[];
    cards.forEach((card, index) => {
        const isTopCard = index === cards.length - 1;
        const isSecondCard = index === cards.length - 2;

        card.style.zIndex = `${10 + index}`;
        
        card.style.display = (isTopCard || isSecondCard) ? 'flex' : 'none';
        
        if (isTopCard) {
            card.style.transform = 'none';
            card.style.opacity = '1';
        } else if (isSecondCard) {
            card.style.transform = 'translateY(10px) scale(0.95)';
            card.style.opacity = '1';
        } else {
            card.style.opacity = '0';
        }
    });
  }

  function loadSwipeCards() {
    if (!swipeDeck) return;
    swipeDeck.innerHTML = '';
    const availableUsers = userList.filter(u => !isUserBlocked(u.id));
    if (availableUsers.length > 0) {
      [...availableUsers].reverse().forEach(user => swipeDeck.appendChild(createCard(user)));
    } else {
      swipeDeck.innerHTML = `<div class="placeholder-content"><i class="fas fa-user-friends placeholder-icon"></i><h3>That's everyone!</h3><p>You've seen all the profiles for now. Check back later for new people.</p></div>`;
    }
    updateCardStackStyles();
    setNextActiveCard();
  }
  
  function setNextActiveCard() {
    activeCard = swipeDeck?.querySelector('.swipe-card:last-child') as HTMLElement | null;
    if (activeCard) {
      activeCardData = (activeCard as any).userData;
      activeCard.addEventListener('pointerdown', onDragStart);
    }
  }

  function onDragStart(e: PointerEvent) {
    if (!activeCard || isDragging) return;
    isDragging = true;
    wasDragged = false;
    startX = e.clientX;
    startY = e.clientY;
    activeCard.style.transition = 'none';

    function onPointerMove(ev: PointerEvent) {
        if (!isDragging || !activeCard) return;
        currentX = ev.clientX - startX; 
        currentY = ev.clientY - startY;
        if (!wasDragged && (Math.abs(currentX) > 10 || Math.abs(currentY) > 10)) {
            wasDragged = true;
        }
        activeCard.style.transform = `translate(${currentX}px, ${currentY}px) rotate(${currentX * 0.1}deg)`;
    }

    function onPointerEnd() {
        document.removeEventListener('pointermove', onPointerMove);
        document.removeEventListener('pointerup', onPointerEnd);
        if (!isDragging) return;
        isDragging = false;
        if (wasDragged) {
            if (Math.abs(currentX) > 100) {
              swipeCard(currentX > 0 ? 1 : -1);
            } else {
              resetCardPosition();
            }
        } else {
            // This is a tap/click
            showUserProfileView(activeCardData);
            resetCardPosition(); // Reset just in case there was a tiny movement
        }
        currentX = 0;
        currentY = 0;
    }

    document.addEventListener('pointermove', onPointerMove);
    document.addEventListener('pointerup', onPointerEnd);
  }
  
  function swipeCard(direction: 1 | -1 | 2) { // 1: like, -1: pass, 2: super like
      if (!activeCard) return;
      
      activeCard.removeEventListener('pointerdown', onDragStart);

      const swipedUser = userList.find(u => u.id === activeCardData.id);
      if (swipedUser) { lastSwipedUser = swipedUser; userList = userList.filter(u => u.id !== swipedUser.id); }

      const flyoutX = (window.innerWidth / 2 + activeCard.offsetWidth) * (direction === -1 ? -1 : 1);
      activeCard.style.transition = 'transform 0.4s ease-out';
      activeCard.style.transform = `translate(${flyoutX}px, ${currentY * 2}px) rotate(${45 * (direction === -1 ? -1 : 1)}deg)`;
      
      if (direction === 1 || direction === 2) {
          if (Math.random() < 0.25) {
            setTimeout(() => showMatchModal(activeCardData), 300);
          }
      }
      if (direction === 2) {
          showToast(`Super Liked ${activeCardData.name.split(' ')[0]}!`);
      }

      setTimeout(() => {
          activeCard?.remove();
          updateCardStackStyles();
          setNextActiveCard();
      }, 400);
  }

  function resetCardPosition() {
    if (!activeCard) return;
    activeCard.style.transition = 'transform 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275)';
    activeCard.style.transform = 'translate(0, 0) rotate(0deg)';
  }
  
  document.getElementById('pass-btn')?.addEventListener('click', () => swipeCard(-1));
  document.getElementById('like-btn')?.addEventListener('click', () => swipeCard(1));
  document.getElementById('super-like-btn')?.addEventListener('click', () => { if (currentUserProfile.superLikes > 0) { currentUserProfile.superLikes--; swipeCard(2); } else { showToast("No Super Likes left!"); }});
  document.getElementById('rewind-btn')?.addEventListener('click', () => { if(lastSwipedUser) { userList.push(lastSwipedUser); loadSwipeCards(); lastSwipedUser = null; } else { showToast("No one to rewind!"); } });
  
  // --- MATCH MODAL & AI LOGIC ---
  function showMatchModal(matchedUser: any) {
    if (!matchModal || !matchNameEl || !matchAvatarEl) return;
    currentMatchedUser = matchedUser;
    matchNameEl.textContent = matchedUser.name.split(' ')[0];
    matchAvatarEl.src = matchedUser.img;
    icebreakersResultEl!.innerHTML = '';
    matchModal.classList.remove('hidden');
  }

  // --- "LIKES YOU" PAGE LOGIC ---
  function renderLikesYouPage() {
      if (!likesYouGrid || !likesYouPremiumUpsell) return;
      likesYouGrid.innerHTML = '';
      likesYouPremiumUpsell.classList.toggle('hidden', currentUserProfile.isPremium);
      likesYouGrid.classList.toggle('blurred', !currentUserProfile.isPremium);
      
      users.filter(u => usersWhoLikedYou.includes(u.id)).forEach(user => {
          const card = document.createElement('div');
          card.className = 'likes-you-card';
          card.innerHTML = `<img src="${user.img}" alt="${user.name}"><div class="likes-you-card-info">${user.name}, ${user.age}</div>`;
          card.addEventListener('click', () => { if (currentUserProfile.isPremium) showUserProfileView(user) });
          likesYouGrid.appendChild(card);
      });
      likesYouCount?.classList.toggle('hidden', usersWhoLikedYou.length === 0);
      if (likesYouCount) likesYouCount.textContent = usersWhoLikedYou.length.toString();
  }
  
  // --- VENT & VIBE LOGIC ---
  function renderVentPosts() {
      if (!ventPostsContainer) return;
      ventPostsContainer.innerHTML = '';
      ventPosts.forEach(post => {
          const postCard = document.createElement('div');
          postCard.className = 'vent-post-card';
          postCard.innerHTML = `
              <p class="vent-post-text">${post.text}</p>
              <div class="vent-post-actions">
                  <button class="vent-vote-btn ${post.userVote === 1 ? 'active' : ''}" data-post-id="${post.id}" data-vote="1"><i class="fas fa-heart"></i> ${post.upvotes}</button>
                  <span>${Math.floor(Math.random() * 24) + 1}h ago</span>
              </div>
          `;
          ventPostsContainer.prepend(postCard);
      });
      ventPostsContainer.querySelectorAll('.vent-vote-btn').forEach(btn => btn.addEventListener('click', (e) => {
          const postId = parseInt((e.currentTarget as HTMLElement).dataset.postId || '0');
          const post = ventPosts.find(p => p.id === postId);
          if (post) {
              post.userVote = post.userVote === 1 ? 0 : 1;
              post.upvotes += post.userVote === 1 ? 1 : -1;
              renderVentPosts();
          }
      }));
  }
  ventPostSubmit?.addEventListener('click', () => {
      const text = ventPostInput.value.trim();
      if (text) {
          ventPosts.push({ id: Date.now(), text, upvotes: 0, userVote: 0 });
          ventPostInput.value = '';
          renderVentPosts();
      }
  });

  // --- USER PROFILE VIEW LOGIC ---
  function showUserProfileView(user: any) {
    if (!userProfileViewContent || !userProfileView) return;
    currentUserInView = user;
    
    const nameEl = document.getElementById('user-profile-view-name');
    if (nameEl) nameEl.textContent = `${user.name}, ${user.age}`;
    
    const photos = [user.img, ...(user.additionalPhotos || [])].filter(Boolean);
    const photosHTML = photos.map((photoUrl: string) => `<img src="${photoUrl}" alt="${user.name}'s photo">`).join('');

    userProfileViewContent.innerHTML = `
      <div class="profile-view-photos">${photosHTML}</div>
      <div class="profile-view-details">
        <h3>${user.name}, ${user.age}</h3>
        <p><i class="fas fa-briefcase-medical"></i> ${user.specialty}</p>
        <p><i class="fas fa-map-marker-alt"></i> ${user.location}</p>
      </div>
      <div class="profile-view-details"><h4>About Me</h4><p>${user.about || 'No bio yet.'}</p></div>
      <div class="profile-view-details">
          ${user.prompts.prompt1 ? `<div class="prompt-block"><p class="prompt-question">My favorite way to de-stress is...</p><p class="prompt-answer">“${user.prompts.prompt1}”</p></div>` : ''}
          ${user.prompts.prompt2 ? `<div class="prompt-block"><p class="prompt-question">A patient story I'll never forget is...</p><p class="prompt-answer">“${user.prompts.prompt2}”</p></div>` : ''}
      </div>
      <div class="profile-view-details"><h4>Interests</h4><div class="interests-container">${user.interests.map((i: string) => `<button type="button" class="interest-tag active">${i}</button>`).join('')}</div></div>
    `;
    userProfileView.classList.remove('hidden');
  }
  userProfileBackBtn?.addEventListener('click', () => userProfileView?.classList.add('hidden'));
  userProfileMessageBtn?.addEventListener('click', () => {
    if (currentUserInView) {
        userProfileView?.classList.add('hidden');
        openChat(currentUserInView);
    }
  });

  // --- DASHBOARD LOGIC ---
  let adInterval: number | null = null;

  function watchAdForReward(tier: { goal: number; reward: number }) {
      watchAdModal?.classList.remove('hidden');
      if (watchAdTitle) watchAdTitle.textContent = "Earning Video Minutes...";
      if (watchAdCounter) watchAdCounter.textContent = "Watching ad to earn rewards...";
      if (skipAdBtn) skipAdBtn.style.display = 'none';

      let progress = 0;
      if (watchAdProgress) watchAdProgress.style.width = '0%';

      if (adInterval) clearInterval(adInterval);
      adInterval = window.setInterval(() => {
          progress += 10;
          if (watchAdProgress) watchAdProgress.style.width = `${progress}%`;
          if (progress >= 100) {
              clearInterval(adInterval!);
              adInterval = null;
              watchAdModal?.classList.add('hidden');
              
              const tierKey = tier.reward.toString();
              currentUserProfile.adsWatchedPerTier[tierKey] = (currentUserProfile.adsWatchedPerTier[tierKey] || 0) + 1;
              
              if (currentUserProfile.adsWatchedPerTier[tierKey] >= tier.goal) {
                  currentUserProfile.videoMinutes = (currentUserProfile.videoMinutes || 0) + tier.reward;
                  currentUserProfile.adsWatchedPerTier[tierKey] = 0; // Reset progress
                  showToast(`+${tier.reward} video minutes earned! Total: ${currentUserProfile.videoMinutes}`);
              } else {
                  showToast("Ad watched! Progress updated.");
              }
              renderDashboardPage(); // Re-render the dashboard to show new progress

              // Reset modal for next use
              if (skipAdBtn) skipAdBtn.style.display = 'block';
          }
      }, 200);
  }

  function renderDashboardPage() {
    (document.getElementById('metric-profile-views') as HTMLElement).textContent = '1,204'; // Mock data
    (document.getElementById('metric-likes-received') as HTMLElement).textContent = usersWhoLikedYou.length.toString();
    (document.getElementById('metric-super-likes') as HTMLElement).textContent = currentUserProfile.superLikes.toString();
    (document.getElementById('metric-gift-points') as HTMLElement).textContent = currentUserProfile.giftPoints.toString();
    
    const badgeProgressContainer = document.getElementById('dashboard-badge-progress');
    if (badgeProgressContainer) {
      badgeProgressContainer.innerHTML = allBadges.map(badge => {
        const hasBadge = currentUserProfile.earnedBadges.includes(badge.id);
        return `
          <div class="progress-bar-container">
            <div class="progress-bar-label">
              <span><i class="fas ${badge.icon} ${badge.color}"></i> ${badge.name}</span>
              <span>${hasBadge ? 'Earned!' : 'In Progress'}</span>
            </div>
            <div class="progress-bar-bg">
              <div class="progress-bar-fill" style="width: ${hasBadge ? '100' : Math.floor(Math.random() * 80) + 10}%"></div>
            </div>
          </div>
        `;
      }).join('');
    }

    const videoMinutesContainer = document.getElementById('dashboard-video-minutes');
    if (videoMinutesContainer) {
        const tiers = [
            { goal: 5, reward: 5 }, // Simplified goals for demo
            { goal: 10, reward: 15 },
            { goal: 20, reward: 75 },
        ];

        videoMinutesContainer.innerHTML = tiers.map(tier => {
            const adsWatched = currentUserProfile.adsWatchedPerTier[tier.reward.toString()] || 0;
            const progress = Math.min((adsWatched / tier.goal) * 100, 100);
            const isComplete = progress >= 100;
            return `
              <div class="progress-bar-container">
                <div class="progress-bar-label">
                  <span><i class="fas fa-video ${isComplete ? 'completed' : ''}"></i> +${tier.reward} Video Minutes</span>
                  ${isComplete 
                    ? `<span><i class="fas fa-check-circle completed"></i> Earned!</span>` 
                    : `<button class="btn-watch-ad-video" data-reward="${tier.reward}"><i class="fas fa-play-circle"></i> ${adsWatched} / ${tier.goal} Ads</button>`
                  }
                </div>
                <div class="progress-bar-bg">
                  <div class="progress-bar-fill" style="width: ${progress}%"></div>
                </div>
              </div>
            `;
        }).join('');

        videoMinutesContainer.querySelectorAll('.btn-watch-ad-video').forEach((button, index) => {
            button.addEventListener('click', () => watchAdForReward(tiers[index]));
        });
    }
  }
  
  // --- SPEED DATING LOGIC ---
  async function setupSpeedDatingLobby() {
    if(speedDatingInterval) clearInterval(speedDatingInterval);
    speedDatingInterval = null;
    speedDatingLobby?.classList.remove('hidden');
    speedDatingRoom?.classList.add('hidden');
    if (!speedDatingRoomsGrid) return;

    // Load real speed dating rooms from Firebase
    speedDatingRoomsGrid.innerHTML = '<div class="loading-message">Loading rooms...</div>';

    try {
      const roomsRef = collection(db, 'speed_dating_rooms');
      const roomsSnapshot = await getDocs(query(roomsRef, where('status', '==', 'waiting'), limit(25)));

      speedDatingRoomsGrid.innerHTML = '';

      if (roomsSnapshot.empty) {
        speedDatingRoomsGrid.innerHTML = '<div class="no-rooms-message">No active rooms. Check back later!</div>';
        return;
      }

      roomsSnapshot.docs.forEach(doc => {
        const room = doc.data();
        const roomEl = document.createElement('div');
        roomEl.className = 'room-card';

        if (room.participants >= room.maxParticipants) {
          roomEl.classList.add('full');
        }

        roomEl.innerHTML = `
            <div class="room-icon">${room.participants >= room.maxParticipants ? '🔒' : '🚪'}</div>
            <div class="room-name">${room.title}</div>
            <div class="room-info">
                <span><i class="fas fa-clock"></i> ${room.duration} min</span>
                <span><i class="fas fa-users"></i> ${room.participants}/${room.maxParticipants}</span>
            </div>
        `;

        if (room.participants < room.maxParticipants) {
          roomEl.addEventListener('click', () => joinSpeedDatingRoom(doc.id, room));
        }

        speedDatingRoomsGrid.appendChild(roomEl);
      });
    } catch (error) {
      console.error('Error loading speed dating rooms:', error);
      speedDatingRoomsGrid.innerHTML = '<div class="error-message">Error loading rooms. Please try again.</div>';
    }
  }

  function enterSpeedDatingRoom(duration: number) {
    if (speedDatingInterval) clearInterval(speedDatingInterval);
    
    speedDatingLobby?.classList.add('hidden');
    speedDatingRoom?.classList.remove('hidden');

    currentRoomState = { userReady: false, opponentReady: false, timer: duration * 60, userDecision: null };

    if(speedDatingTimerEl) speedDatingTimerEl.textContent = `${String(duration).padStart(2, '0')}:00`;
    if(speedDatingStatusText) speedDatingStatusText.textContent = "Waiting for another nurse...";
    speedDatingStatusOverlay?.classList.remove('hidden');

    if(speedDatingControls) speedDatingControls.innerHTML = `<button id="leave-room-btn" class="btn btn-tertiary">Leave Room</button>`;
    document.getElementById('leave-room-btn')?.addEventListener('click', setupSpeedDatingLobby);

    // Simulate opponent joining
    setTimeout(() => {
        if(speedDatingStatusText) speedDatingStatusText.textContent = "Chloe has joined! Get ready.";
        setTimeout(setupReadyState, 2000);
    }, 2500);
  }

  function setupReadyState() {
    if(speedDatingStatusText) speedDatingStatusText.textContent = "Click when you're ready!";
    if(speedDatingControls) speedDatingControls.innerHTML = `<button id="ready-btn" class="btn btn-primary">I'm Ready</button>`;
    
    document.getElementById('ready-btn')?.addEventListener('click', () => {
        currentRoomState.userReady = true;
        (document.getElementById('ready-btn') as HTMLButtonElement).disabled = true;
        (document.getElementById('ready-btn') as HTMLButtonElement).textContent = "Waiting for other...";

        // Simulate opponent becoming ready
        setTimeout(() => {
            currentRoomState.opponentReady = true;
            if(currentRoomState.userReady) {
                startSpeedDatingSession();
            }
        }, Math.random() * 2000 + 1000);
    });
  }

  function startSpeedDatingSession() {
      speedDatingStatusOverlay?.classList.add('hidden');
      if(speedDatingControls) speedDatingControls.innerHTML = `
          <button id="pass-date-btn" class="btn btn-pass">Pass</button>
          <button id="single-date-btn" class="btn btn-date">Single Date</button>
          <button id="leave-room-btn" class="btn btn-tertiary">Leave Room</button>
      `;
      document.getElementById('pass-date-btn')?.addEventListener('click', (e) => { 
        currentRoomState.userDecision = 'pass';
        (e.currentTarget as HTMLElement).classList.add('selected');
        (document.getElementById('single-date-btn') as HTMLButtonElement).disabled = true;
       });
      document.getElementById('single-date-btn')?.addEventListener('click', (e) => { 
        currentRoomState.userDecision = 'date';
        (e.currentTarget as HTMLElement).classList.add('selected');
        (document.getElementById('pass-date-btn') as HTMLButtonElement).disabled = true;
      });
      document.getElementById('leave-room-btn')?.addEventListener('click', endSpeedDatingSession);
      
      let timeLeft = currentRoomState.timer;
      const updateTimer = () => {
        if (!speedDatingTimerEl) {
            if (speedDatingInterval) clearInterval(speedDatingInterval);
            return;
        }
        if (timeLeft <= 0) {
            endSpeedDatingSession();
        } else {
            const minutes = Math.floor(timeLeft / 60);
            const seconds = timeLeft % 60;
            speedDatingTimerEl.textContent = `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
            timeLeft--;
        }
      }
      updateTimer();
      speedDatingInterval = window.setInterval(updateTimer, 1000);
  }

  function endSpeedDatingSession() {
    if(speedDatingInterval) clearInterval(speedDatingInterval);
    speedDatingInterval = null;

    // Simulate opponent's choice
    const opponentDecision = Math.random() < 0.5 ? 'date' : 'pass';
    
    if (currentRoomState.userDecision === 'date' && opponentDecision === 'date') {
        showToast("It's a Match!");
    } else {
        showToast("Not a match this time.");
    }

    if (!currentUserProfile.earnedBadges.includes('speed-dater')) {
        // Here you'd track session count and award badge
    }
    
    setTimeout(setupSpeedDatingLobby, 2000);
  }

  // --- BOOST LOGIC ---
  function startBoostTimer(minutes: number) {
    if (boostInterval) clearInterval(boostInterval);
    boostEndTime = Date.now() + minutes * 60 * 1000;
    
    boostTimerEl?.classList.remove('hidden');
    boostModal?.querySelector('.boost-modal-content')?.classList.add('boost-active');


    const updateTimer = () => {
        if (!boostEndTime) {
             if (boostInterval) clearInterval(boostInterval);
             boostTimerEl?.classList.add('hidden');
             return;
        }
        const remaining = boostEndTime - Date.now();
        if (remaining <= 0) {
            clearInterval(boostInterval!);
            boostTimerEl?.classList.add('hidden');
            boostEndTime = null;
            boostModal?.querySelector('.boost-modal-content')?.classList.remove('boost-active');
            showToast("Your boost has ended!");
        } else {
            const mins = Math.floor(remaining / 60000);
            const secs = Math.floor((remaining % 60000) / 1000);
            if(boostTimerEl) boostTimerEl.innerHTML = `<i class="fas fa-bolt"></i> Boost Active: ${mins}:${secs.toString().padStart(2, '0')}`;
        }
    };
    updateTimer();
    boostInterval = window.setInterval(updateTimer, 1000);
  }

  document.querySelectorAll('.boost-option').forEach(option => {
    option.addEventListener('click', () => {
        const duration = parseInt((option as HTMLElement).dataset.duration || '0', 10);
        const ads = parseInt((option as HTMLElement).dataset.ads || '0', 10);
        if (duration > 0 && ads > 0) {
            boostModal?.classList.add('hidden');
            simulateWatchingAds(ads, duration);
        }
    });
  });

  function simulateWatchingAds(requiredAds: number, duration: number) {
      watchAdModal?.classList.remove('hidden');
      let currentAd = 1;

      const runAdCycle = () => {
          if (watchAdCounter) watchAdCounter.textContent = `Watching ad ${currentAd} of ${requiredAds}`;
          let progress = 0;
          if (watchAdProgress) watchAdProgress.style.width = '0%';

          if (adInterval) clearInterval(adInterval);
          adInterval = window.setInterval(() => {
              progress += 10;
              if (watchAdProgress) watchAdProgress.style.width = `${progress}%`;
              if (progress >= 100) {
                  clearInterval(adInterval!);
                  adInterval = null;
                  currentAd++;
                  if (currentAd > requiredAds) {
                      watchAdModal?.classList.add('hidden');
                      startBoostTimer(duration);
                      showToast(`${duration} minute boost activated!`);
                  } else {
                      setTimeout(runAdCycle, 500); // Wait half a second before next ad
                  }
              }
          }, 200);
      };

      skipAdBtn?.addEventListener('click', () => {
          if (adInterval) clearInterval(adInterval);
          adInterval = null;
          watchAdModal?.classList.add('hidden');
          startBoostTimer(duration);
          showToast(`${duration} minute boost activated!`);
      }, { once: true });

      runAdCycle();
  }


  // --- VERIFICATION LOGIC ---
  function renderVerificationModal() {
    const unverifiedView = document.getElementById('verification-unverified');
    const pendingView = document.getElementById('verification-pending');
    const verifiedView = document.getElementById('verification-verified');

    [unverifiedView, pendingView, verifiedView].forEach(v => v?.classList.add('hidden'));

    switch (currentUserProfile.verificationStatus) {
        case 'pending':
            pendingView?.classList.remove('hidden');
            break;
        case 'verified':
            verifiedView?.classList.remove('hidden');
            break;
        case 'unverified':
        default:
            unverifiedView?.classList.remove('hidden');
            break;
    }
  }

  const verificationUpload = document.getElementById('verification-upload') as HTMLInputElement;
  const verificationPreview = document.getElementById('verification-preview') as HTMLImageElement;
  const verificationSubmitBtn = document.getElementById('verification-submit');

  verificationUpload?.addEventListener('change', () => {
    const file = verificationUpload.files?.[0];
    if (file) {
        const reader = new FileReader();
        reader.onload = (e) => {
            currentUserProfile.verificationIdUrl = e.target?.result as string;
            if(verificationPreview) {
                verificationPreview.src = currentUserProfile.verificationIdUrl;
                verificationPreview.classList.remove('hidden');
            }
            verificationSubmitBtn?.classList.remove('hidden');
        };
        reader.readAsDataURL(file);
    }
  });

  verificationSubmitBtn?.addEventListener('click', () => {
    if (currentUserProfile.verificationIdUrl) {
        currentUserProfile.verificationStatus = 'pending';
        showToast('Verification submitted for review!');
        renderVerificationModal();
    } else {
        showToast('Please upload an ID photo first.', true);
    }
  });


  // --- CALL LOGIC ---
  let callInterval: number | null = null;
  let callStartTime: number | null = null;
  let callOpponent: any = null;
  
  function startCall(type: 'video' | 'audio', user: any) {
      const callView = document.getElementById('call-view');
      const callTimerEl = document.getElementById('call-timer-overlay');
      const callAvatar = document.getElementById('call-avatar') as HTMLImageElement;
      const callName = document.getElementById('call-name');
  
      if (!callView || !callTimerEl || !callAvatar || !callName) return;
  
      callOpponent = user;
      callAvatar.src = user.img;
      callName.textContent = user.name;
      
      callView.classList.toggle('audio-only', type === 'audio');
      callView.classList.remove('hidden');
  
      callStartTime = Date.now();
      
      const updateCallTimer = () => {
          const elapsedMs = Date.now() - (callStartTime ?? Date.now());
          const mins = Math.floor(elapsedMs / 60000);
          const secs = Math.floor((elapsedMs % 60000) / 1000);
          if (callTimerEl) callTimerEl.textContent = `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
      };

      if (callInterval) clearInterval(callInterval);
      updateCallTimer();
      callInterval = window.setInterval(updateCallTimer, 1000);
  }
  
  function endCall() {
      const callView = document.getElementById('call-view');
      if (callInterval) {
          clearInterval(callInterval);
          callInterval = null;
      }
  
      callView?.classList.add('hidden');
      callStartTime = null;
      callOpponent = null;
  }
  document.getElementById('end-call-btn')?.addEventListener('click', endCall);


  // --- REMAINING FUNCTIONS (STUBS/EXISTING) ---
  function updateUnreadIndicators() {}
  function populateEditModal() {}
  
  editProfileForm?.addEventListener('submit', (e) => {
    e.preventDefault();
    // Logic to save all other fields from the edit modal...
    
    // Handle additional photo uploads
    const photoInputs = [
        document.getElementById('photo-upload-1') as HTMLInputElement,
        document.getElementById('photo-upload-2') as HTMLInputElement,
        document.getElementById('photo-upload-3') as HTMLInputElement,
    ];

    const newPhotos: string[] = [];
    let filesToProcess = 0;

    const onFileProcessed = () => {
        filesToProcess--;
        if (filesToProcess === 0) {
            currentUserProfile.additionalPhotos = newPhotos.filter(Boolean);
            renderProfilePage(); // Re-render with new photos
            editProfileModal?.classList.add('hidden');
            showToast("Profile updated!");
        }
    };
    
    photoInputs.forEach((input, index) => {
        const file = input.files?.[0];
        if (file) {
            filesToProcess++;
            const reader = new FileReader();
            reader.onload = (event) => {
                newPhotos[index] = event.target?.result as string;
                onFileProcessed();
            };
            reader.readAsDataURL(file);
        } else {
            // Keep existing photo if no new one is uploaded
            newPhotos[index] = currentUserProfile.additionalPhotos[index];
        }
    });

    if (filesToProcess === 0) {
         currentUserProfile.additionalPhotos = newPhotos.filter(Boolean);
         renderProfilePage();
         editProfileModal?.classList.add('hidden');
         showToast("Profile updated!");
    }
  });

  avatarUpload?.addEventListener('change', () => {});
  ageSlider?.addEventListener('input', () => {});
  document.querySelectorAll('.interest-tag').forEach(tag => tag.addEventListener('click', () => tag.classList.toggle('active')));
  editProfileBtn?.addEventListener('click', () => editProfileModal?.classList.remove('hidden'));
  closeEditModalBtn?.addEventListener('click', () => editProfileModal?.classList.add('hidden'));
  
  async function generateIcebreakers() {
    if (!icebreakersResultEl || !currentMatchedUser) return;
    icebreakersResultEl.innerHTML = '<div class="spinner"></div>';
    try {
        const prompt = `Generate 3 short, fun, and flirty icebreaker questions for a dating app match. My match is named ${currentMatchedUser.name.split(' ')[0]}. They work in a hospital as a ${currentMatchedUser.specialty} and their interests include ${currentMatchedUser.interests.join(', ')}. The icebreakers should be relevant to someone working in a healthcare or hospital environment, but not exclusively for doctors. Keep them light and engaging.`;
        const response = await ai.models.generateContent({
          model: 'gemini-2.5-flash',
          contents: prompt
        });
        const suggestions = response.text.split('\n').filter(s => s.trim().length > 0 && (s.includes('?') || s.includes('.'))).map(s => s.replace(/^\d+\.\s*/, ''));
        icebreakersResultEl.innerHTML = suggestions.map(s => `<button class="icebreaker-suggestion">${s}</button>`).join('');
    } catch (error) {
        console.error("AI Error:", error);
        icebreakersResultEl.innerHTML = `<p style="color: #e53935;">Could not generate suggestions.</p>`;
    }
  }

  icebreakersResultEl?.addEventListener('click', (e) => {
      const target = e.target as HTMLElement;
      if (target.classList.contains('icebreaker-suggestion')) {
          const text = target.textContent;
          if (text && currentMatchedUser) {
              openChat(currentMatchedUser);
              if (chatInput) chatInput.value = text;
              handleSendMessage();
              matchModal?.classList.add('hidden');
          }
      }
  });

  generateIcebreakersBtn?.addEventListener('click', generateIcebreakers);
  keepSwipingBtn?.addEventListener('click', () => matchModal?.classList.add('hidden'));
  sendBtn?.addEventListener('click', handleSendMessage);
  chatInput?.addEventListener('keydown', (e) => { if (e.key === 'Enter') { e.preventDefault(); handleSendMessage(); } });
  boostBtn?.addEventListener('click', () => boostModal?.classList.remove('hidden'));
  closeBoostModalBtn?.addEventListener('click', () => boostModal?.classList.add('hidden'));
  closeBoostModalBtnBottom?.addEventListener('click', () => boostModal?.classList.add('hidden'));
  function renderBlockedUsersPage() {}
});
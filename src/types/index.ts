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
  createdAt?: any;
  lastActive?: any;
}

export interface Like {
  id: string;
  likerId: string;
  likedUserId: string;
  type: 'like' | 'pass';
  createdAt: any;
  isMatched: boolean;
}

export interface Match {
  id: string;
  users: string[];
  timestamp: number;
  isActive: boolean;
  lastMessage?: Message;
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

export interface Gift {
  id: string;
  senderId: string;
  receiverId: string;
  giftName: string;
  giftUrl: string;
  points: number;
  createdAt: any;
}

export interface SpeedDatingRoom {
  id: string;
  creatorId: string;
  title: string;
  duration: number;
  participants: string[];
  status: 'waiting' | 'active' | 'completed';
  startedAt: any;
  scheduledTime: any;
}

export interface SpeedDatingSession {
  id: string;
  roomId: string;
  participants: [string, string];
  startedAt: any;
  endedAt?: any;
  feedback?: { rating: number; comment: string };
}
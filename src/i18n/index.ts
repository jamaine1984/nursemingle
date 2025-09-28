import i18n from 'i18next';
import Backend from 'i18next-http-backend';
import LanguageDetector from 'i18next-browser-languagedetector';

// Import translations
import en from './en.json';
import es from './es.json';
import fr from './fr.json';

// Available languages with their display names and flags
export const SUPPORTED_LANGUAGES = {
  en: { name: 'English', flag: '🇺🇸', nativeName: 'English' },
  es: { name: 'Spanish', flag: '🇪🇸', nativeName: 'Español' },
  fr: { name: 'French', flag: '🇫🇷', nativeName: 'Français' },
  de: { name: 'German', flag: '🇩🇪', nativeName: 'Deutsch' },
  it: { name: 'Italian', flag: '🇮🇹', nativeName: 'Italiano' },
  pt: { name: 'Portuguese', flag: '🇵🇹', nativeName: 'Português' },
  ru: { name: 'Russian', flag: '🇷🇺', nativeName: 'Русский' },
  zh: { name: 'Chinese', flag: '🇨🇳', nativeName: '中文' },
  ja: { name: 'Japanese', flag: '🇯🇵', nativeName: '日本語' },
  ko: { name: 'Korean', flag: '🇰🇷', nativeName: '한국어' },
  ar: { name: 'Arabic', flag: '🇸🇦', nativeName: 'العربية' },
  hi: { name: 'Hindi', flag: '🇮🇳', nativeName: 'हिन्दी' }
};

// Initialize i18next
i18n
  .use(Backend)
  .use(LanguageDetector)
  .init({
    fallbackLng: 'en',
    debug: process.env.NODE_ENV === 'development',

    // Resources for immediate loading
    resources: {
      en: { translation: en },
      es: { translation: es },
      fr: { translation: fr }
    },

    interpolation: {
      escapeValue: false, // not needed for react as it escapes by default
    },

    // Language detection options
    detection: {
      order: ['localStorage', 'navigator', 'htmlTag'],
      caches: ['localStorage'],
      lookupLocalStorage: 'nurse-mingle-language'
    },

    // Backend options for loading additional languages
    backend: {
      loadPath: '/src/i18n/{{lng}}.json',
    }
  });

// Helper function to get user's language preference
export const getUserLanguage = (): string => {
  return localStorage.getItem('nurse-mingle-language') ||
         navigator.language.split('-')[0] ||
         'en';
};

// Helper function to set user's language preference
export const setUserLanguage = (lang: string): void => {
  localStorage.setItem('nurse-mingle-language', lang);
  i18n.changeLanguage(lang);

  // Update HTML lang attribute for accessibility
  document.documentElement.lang = lang;

  // Update direction for RTL languages
  const rtlLanguages = ['ar', 'he', 'fa'];
  document.documentElement.dir = rtlLanguages.includes(lang) ? 'rtl' : 'ltr';
};

// Helper function to translate text
export const t = (key: string, options?: any): string => {
  return i18n.t(key, options);
};

// Helper function to get current language
export const getCurrentLanguage = (): string => {
  return i18n.language || 'en';
};

// Helper function to check if language is RTL
export const isRTL = (lang?: string): boolean => {
  const rtlLanguages = ['ar', 'he', 'fa'];
  return rtlLanguages.includes(lang || getCurrentLanguage());
};

export default i18n;
/* eslint-disable react-refresh/only-export-components */
import { createContext, useContext, useState, useEffect } from 'react';
import { supabase } from '../services/supabase';

const AuthContext = createContext(null);

export const useAuth = () => useContext(AuthContext);

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  const fetchUserProfile = async (supabaseUser) => {
    if (!supabaseUser) return null;
    const metadata = supabaseUser.user_metadata || {};
    let role = metadata.role || 'user';
    let profileData = {};

    try {
      const { data } = await supabase
        .from('profiles')
        .select('*')
        .or(`id.eq.${supabaseUser.id},email.eq.${supabaseUser.email}`)
        .maybeSingle();

      if (data) {
        profileData = data;
        role = data.role || role;
      }
    } catch (e) {
      console.warn('Could not fetch profile role:', e);
    }

    return {
      id: supabaseUser.id,
      email: supabaseUser.email,
      username: profileData.username || metadata.full_name || metadata.name || supabaseUser.email?.split('@')[0] || 'User',
      full_name: profileData.full_name || metadata.full_name || metadata.name || '',
      avatar_url: profileData.avatar_url || metadata.avatar_url || metadata.picture || null,
      role: role || 'user',
      isAdmin: role === 'admin',
      major: profileData.major || metadata.major || 'it',
      academic_level: profileData.academic_level || metadata.academicLevel || 'K67',
      streak: profileData.streak || 0,
      exp: profileData.exp || 0,
      level: profileData.level || 1,
      is_pro: profileData.is_pro || false,
      raw: supabaseUser
    };
  };

  useEffect(() => {
    // 1. Get initial session
    supabase.auth.getSession().then(async ({ data: { session } }) => {
      const formatted = await fetchUserProfile(session?.user);
      setUser(formatted);
      setLoading(false);
    }).catch(() => {
      setLoading(false);
    });

    // 2. Listen for auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(async (_event, session) => {
      const formatted = await fetchUserProfile(session?.user);
      setUser(formatted);
      setLoading(false);
    });

    return () => {
      subscription?.unsubscribe();
    };
  }, []);

  const loginWithGoogle = async () => {
    const { data, error } = await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: {
        redirectTo: `${window.location.origin}/dashboard`
      }
    });
    if (error) throw error;
    return data;
  };

  const logout = async () => {
    await supabase.auth.signOut();
    setUser(null);
  };

  const updateUser = (data) => {
    setUser(prev => ({ ...prev, ...data }));
  };

  return (
    <AuthContext.Provider value={{ user, loading, loginWithGoogle, logout, updateUser }}>
      {children}
    </AuthContext.Provider>
  );
};

import { createClient } from '@supabase/supabase-js';

const supabaseUrl =
  import.meta.env.VITE_SUPABASE_URL ||
  'https://jhlzfowhrckzzhrbxbuj.supabase.co';
const supabaseAnonKey =
  import.meta.env.VITE_SUPABASE_ANON_KEY ||
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpobHpmb3docmNrenpocmJ4YnVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY2OTEzNzcsImV4cCI6MjEwMjI2NzM3N30.PJWznrFYoS6UzTsIAjzhtIbcnJf9tSIqq2BfedjW_Hw';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

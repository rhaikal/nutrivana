import { createContext, useEffect, useState } from 'react';
import UserModule from '../modules/UserModule';

const UserContext = createContext();

export function UserProvider({ children }) {
  const [user, setUser] = useState(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchUserData = async () => {
      try {
        const nutritionStatus = await UserModule.getCurrentNutritionStatus();
        setUser({ nutritionStatus });
      } catch (error) {
        console.log(error)
        if (error.status === 401) {
          localStorage.removeItem('access_token');
          window.location.reload();
        }
        console.error('Error fetching user data:', error);
      } finally {
        setIsLoading(false);
      }
    };

    fetchUserData();
  }, []);

  return (
    <UserContext.Provider value={{ user, setUser, isLoading }}>
      {children}
    </UserContext.Provider>
  );
}

export default UserContext;
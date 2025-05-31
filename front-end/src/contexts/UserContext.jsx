import { createContext, useEffect, useState } from 'react';
import UserModule from '../modules/UserModule';

const UserContext = createContext();

export function UserProvider({ children }) {
  const [user, setUser] = useState(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const accessToken = localStorage.getItem('access_token');

    if (accessToken) {
      const fetchUserData = async () => {
        try {
          const nutritionStatus = await UserModule.getCurrentNutritionStatus();
          const minimumNutritions = await UserModule.getCurrentMinimumNutritions();
          const intakeNutritions = await UserModule.getCurrentIntakeNutritions();
          
          setUser({
            nutritionStatus,
            minimumNutritions: minimumNutritions,
            intakeNutritions
          });
        } catch (error) {
          console.error('Error fetching user data:', error);
          if (error.status === 401) {
            localStorage.removeItem('access_token');
            window.location.reload();
          }
        } finally {
          setIsLoading(false);
        }
      };
  
      fetchUserData();
    } else {
      setIsLoading(false);
    }
  }, []);

  return (
    <UserContext.Provider value={{ user, setUser, isLoading }}>
      {children}
    </UserContext.Provider>
  );
}

export default UserContext;
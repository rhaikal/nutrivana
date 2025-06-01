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
          const minimumNutritions = await UserModule.getCurrentMinimumNutritions();
          const intakeNutritions = await UserModule.getCurrentIntakeNutritions();
          const growthRecords = await UserModule.getGrowthRecords();

          setUser({
            nutritionStatus: growthRecords[growthRecords?.length - 1].nutrition_status,
            minimumNutritions,
            intakeNutritions,
            growthRecords: {
              height: growthRecords.map((record) => record.height),
              weight: growthRecords.map((record) => record.weight)
            }
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

  const updateIntakeNutritions = async () => {
    setIsLoading(true);
    const intakeNutritions = await UserModule.getCurrentIntakeNutritions();
    setUser((prevUser) => ({
      ...prevUser,
      intakeNutritions
    }));
    setIsLoading(false);
  };

  const updateGrowthRecords = async () => {
    setIsLoading(true);
    const minimumNutritions = await UserModule.getCurrentMinimumNutritions();
    const growthRecords = await UserModule.getGrowthRecords();
    setUser((prevUser) => ({
      ...prevUser,
      nutritionStatus: growthRecords[growthRecords?.length - 1].nutrition_status,
      minimumNutritions,
      growthRecords: {
        height: growthRecords.map((record) => record.height),
        weight: growthRecords.map((record) => record.weight)
      }
    }));
    setIsLoading(false);
  };
  
  return (
    <UserContext.Provider value={{ user, setUser, updateIntakeNutritions, updateGrowthRecords, isLoading }}>
      {children}
    </UserContext.Provider>
  );
}

export default UserContext;
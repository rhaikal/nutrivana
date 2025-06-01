import { createContext, useEffect, useState } from 'react';
import UserModule from '../modules/UserModule';
import { transformGrowthRecordToMonthlyArrays } from '../utils/user';

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
          const { height, weight } = transformGrowthRecordToMonthlyArrays(growthRecords); 

          setUser({
            nutritionStatus: growthRecords[growthRecords?.length - 1].nutrition_status,
            minimumNutritions,
            intakeNutritions,
            growthRecords: {
              height,
              weight
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
    const { height, weight } = transformGrowthRecordToMonthlyArrays(growthRecords); 

    setUser((prevUser) => ({
      ...prevUser,
      nutritionStatus: growthRecords[growthRecords?.length - 1].nutrition_status,
      minimumNutritions,
      growthRecords: {
        height,
        weight
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
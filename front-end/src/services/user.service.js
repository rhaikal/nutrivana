import { axiosInstance, getAuthHeader } from '../utils/api';

const getCurrentNutritionStatus = () => {
    return axiosInstance.get('get_status_nutritions', { headers: getAuthHeader() });
};

const getCurrentMinimumNutritions = () => {
    return axiosInstance.get('get_minimum_nutrition', { headers: getAuthHeader() });
};

const getCurrentIntakeNutritions = () => {
    return axiosInstance.get('get_nutrient_current', { headers: getAuthHeader() });
}

export default {
    getCurrentNutritionStatus,
    getCurrentMinimumNutritions,
    getCurrentIntakeNutritions
};
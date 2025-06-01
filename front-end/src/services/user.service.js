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

const getGrowthRecords = () => {
    return axiosInstance.get('track_record', { headers: getAuthHeader() });
}

const updateGrowthRecords = (payload) => {
    return axiosInstance.put('update_user_nutritions', payload, { headers: getAuthHeader() });
}

export default {
    getCurrentNutritionStatus,
    getCurrentMinimumNutritions,
    getCurrentIntakeNutritions,
    getGrowthRecords,
    updateGrowthRecords,
};
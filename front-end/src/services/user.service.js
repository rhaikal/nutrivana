import { axiosInstance, getAuthHeader } from '../utils/api';

const getCurrentNutritionStatus = () => {
    return axiosInstance.get('get_status_nutritions', { headers: getAuthHeader() });
};

export default {
    getCurrentNutritionStatus
};
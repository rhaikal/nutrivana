import { authorizedHeader, axiosInstance } from '../utils/api';

const getCurrentNutritionStatus = async () => {
    return axiosInstance.get(
        'get_status_nutritions',
        { headers: authorizedHeader() }
    );
}

export default {
    getCurrentNutritionStatus
}
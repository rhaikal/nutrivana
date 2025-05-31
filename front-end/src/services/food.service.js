import { axiosInstance, getAuthHeader } from "../utils/api";

const list = () => {
    return axiosInstance.get('foods', { headers: getAuthHeader() });
};

const getEatenList = () => {
    return axiosInstance.get('get_food_histories', { headers: getAuthHeader() });
}

const getRecommendationFoods = () => {
    return axiosInstance.get('food_recommendations', { headers: getAuthHeader() });
}

const saveEatenList = (payload) => {
    return axiosInstance.post('post_food_histories', payload, { headers: getAuthHeader() });
}

export default {
    list,
    getEatenList,
    getRecommendationFoods,
    saveEatenList,
};
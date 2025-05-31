import { axiosInstance, getAuthHeader } from "../utils/api";

const list = () => {
    return axiosInstance.get('foods', { headers: getAuthHeader() });
};

const getEatenList = () => {
    return axiosInstance.get('get_food_histories', { headers: getAuthHeader() });
}

const getRecommendationList = () => {
    return axiosInstance.get('food_recommendations', { headers: getAuthHeader() });
}

export default {
    list,
    getEatenList,
    getRecommendationList
};
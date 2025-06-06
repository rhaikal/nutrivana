import FoodService from "../services/food.service";
import { handleResponse, handleError } from "../utils/api";

const getFoods = () => {
    return FoodService.list()
        .then(handleResponse)
        .catch(handleError);
};

const getEatenFoods = () => {
    return FoodService.getEatenList()
        .then(handleResponse)
        .catch(handleError);
};

const getRecommendationFoods = () => {
    return FoodService.getRecommendationFoods()
        .then(handleResponse)
        .catch(handleError);
};

const saveEatenFoods = (payload) => {
    return FoodService.saveEatenList(payload)
        .then(handleResponse)
        .catch(handleError);
};

export default {
    getFoods,
    getEatenFoods,
    getRecommendationFoods,
    saveEatenFoods
};
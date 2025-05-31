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

const getRecommendationList = () => {
    return FoodService.getRecommendationList()
        .then(handleResponse)
        .catch(handleError);
};

export default {
    getFoods,
    getEatenFoods,
    getRecommendationList
};
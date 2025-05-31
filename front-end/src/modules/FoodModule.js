import FoodService from "../services/food.service";
import { handleResponse, handleError } from "../utils/api";

const getFoods = () => {
    return FoodService.list()
        .then(handleResponse)
        .catch(handleError);
};

export default {
    getFoods
};
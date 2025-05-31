import UserService from "../services/user.service";
import { handleResponse, handleError } from "../utils/api";

const getCurrentNutritionStatus = () => {
    return UserService.getCurrentNutritionStatus()
        .then(handleResponse)
        .catch(handleError);
};

const getCurrentMinimumNutritions = () => {
    return UserService.getCurrentMinimumNutritions()
        .then(handleResponse)
        .catch(handleError);
};

const getCurrentIntakeNutritions = () => {
    return UserService.getCurrentIntakeNutritions()
        .then(handleResponse)
        .catch(handleError);
}

export default {
    getCurrentNutritionStatus,
    getCurrentMinimumNutritions,
    getCurrentIntakeNutritions
};
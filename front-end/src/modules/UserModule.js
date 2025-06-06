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

const getGrowthRecords = () => {
    return UserService.getGrowthRecords()
        .then(handleResponse)
        .catch(handleError);
}

const updateGrowthRecords = (payload) => {
    return UserService.updateGrowthRecords(payload)
        .then(handleResponse)
        .catch(handleError);
}

export default {
    getCurrentNutritionStatus,
    getCurrentMinimumNutritions,
    getCurrentIntakeNutritions,
    getGrowthRecords,
    updateGrowthRecords
};
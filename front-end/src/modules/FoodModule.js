import FoodService from "../services/food.service"

const getFoods = async () => {
    return FoodService.list().then(
        (response) => {
            return Promise.resolve(response.data, response.data.message);
        },
        (error) => {
            const message =
                (error.response && error.response.data && error.response.data.message) ||
                error.message ||
                error.toString();
            return Promise.reject({status: error.response.status, message});
        },
    );
}

export default {
    getFoods
}
import { axiosInstance, getAuthHeader } from "../utils/api";

const list = () => {
    return axiosInstance.get('foods', { headers: getAuthHeader() });
};

export default {
    list
};
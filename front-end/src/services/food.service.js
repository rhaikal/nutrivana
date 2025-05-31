import { axiosInstance, authorizedHeader } from "../utils/api";

const list = async () => {
    return axiosInstance.get(
        'foods',
        { headers: authorizedHeader() }
    );
}

export default {
    list
}
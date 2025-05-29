import axios from 'axios';
import { axiosInstance, API_URL } from '../utils/api';

const login = async (payload) => {
    const formData = new URLSearchParams();
    formData.append('username', payload.username);
    formData.append('password', payload.password);
    
    return axios.post(
        `${API_URL}login`,
        formData
    ) 
}

const register = async (payload) => {
    return axiosInstance.post(
        `register`,
        payload
    );
};

export default {
    login,
    register
}
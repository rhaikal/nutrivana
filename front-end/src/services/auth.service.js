import axios from 'axios';
import { axiosInstance, API_URL } from '../utils/api';

const login = (credentials) => {
    const formData = new FormData();
    formData.append('username', credentials.username);
    formData.append('password', credentials.password);
    
    return axios.post(`${API_URL}/login`, formData);
};

const register = (userData) => {
    return axiosInstance.post('register', userData);
};

export default {
    login,
    register
};
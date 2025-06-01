import axios from 'axios';

const API_URL = import.meta.env.VITE_BACKEND_URL;

const axiosInstance = axios.create({
    baseURL: API_URL,
    withCredentials: true,
    headers: {
        'Content-Type': 'application/json',
    }
});

const getAuthHeader = () => {
    const token = localStorage.getItem('access_token');
    return token ? { Authorization: `Bearer ${token}` } : {};
};

const handleResponse = (response) => {
    return Promise.resolve(response.data);
};

const handleError = (error) => {
    const message =
        error.response?.data?.detail || 
        (error.response?.data?.message) ||
        error.message ||
        error.toString();
    return Promise.reject({ status: error.response?.status, message });
};

export { axiosInstance, getAuthHeader, API_URL, handleResponse, handleError };
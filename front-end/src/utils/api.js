import axios from 'axios';

const API_URL = import.meta.env.VITE_BACKEND_URL;

const axiosInstance = axios.create({
    baseURL: API_URL,
    withCredentials: true,
    headers: {
        'Content-Type': 'application/json',
    }
});

const authorizedHeader = () => {
    const token = localStorage.getItem('access_token');
    if (token) {
        return {
            Authorization: `Bearer ${token}`,
        };
    }
    return {};
};

export { axiosInstance, authorizedHeader, API_URL };
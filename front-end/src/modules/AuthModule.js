import AuthService from '../services/auth.service';
import { handleResponse, handleError } from '../utils/api';

const login = (payload) => {
    return AuthService.login(payload)
        .then(handleResponse)
        .catch(handleError);
};

const register = (payload) => {
    return AuthService.register(payload)
        .then(handleResponse)
        .catch(handleError);
};

export default {
    login,
    register
};
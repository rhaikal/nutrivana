import AuthService from '../services/auth.service';

const login = (payload) => {
	return AuthService.login(payload).then(
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
};

const register = (payload) => {
	return AuthService.register(payload).then(
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
};

export default {
    login,
    register
}
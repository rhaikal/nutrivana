export const handleResponse = (response) => {
    return Promise.resolve(response.data);
};

export const handleError = (error) => {
    const message =
        (error.response?.data?.message) ||
        error.message ||
        error.toString();
    return Promise.reject({ status: error.response?.status, message });
};
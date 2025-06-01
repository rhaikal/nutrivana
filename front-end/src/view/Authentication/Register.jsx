import { useState, useRef, useEffect } from 'react';
import { useFormik } from 'formik';
import * as Yup from 'yup';
import { Link } from 'react-router-dom';
import { UserIcon, KeyIcon } from '@heroicons/react/24/solid';
import Swal from '../../utils/Swal';
import Wrapper from './components/Wrapper';
import AuthModule from '../../modules/AuthModule';
import FormField from '../../components/FormField';
import SelectField from '../../components/SelectField';

const Register = () => {
    const [step, setStep] = useState(0);
    const [contentHeight, setContentHeight] = useState('auto');
    const step1Ref = useRef(null);
    const step2Ref = useRef(null);

    const step1ValidationSchema = Yup.object({
        username: Yup.string()
            .min(3, 'Username must be at least 3 characters')
            .required('Username is required'),
        password: Yup.string()
            .min(6, 'Password must be at least 6 characters')
            .required('Password is required'),
        confirm_password: Yup.string()
            .oneOf([Yup.ref('password')], 'Passwords must match')
            .required('Confirm Password is required')
    });

    const validationSchema = step1ValidationSchema.concat(
        Yup.object({
            weight: Yup.number()
                .positive('Weight must be positive')
                .required('Weight is required'),
            height: Yup.number()
                .positive('Height must be positive')
                .required('Height is required'),
            date_of_birth: Yup.date()
                .max(new Date(), "Date of birth cannot be in the future")
                .min(new Date(new Date().setFullYear(new Date().getFullYear() - 5)), "Date of birth must be within the last 5 years")
                .required('Date of birth is required'),
            gender: Yup.string()
                .required('Gender is required')
        }
    ));

    const formik = useFormik({
        initialValues: {
            username: '',
            password: '',
            confirm_password: '',
            weight: '',
            height: '',
            date_of_birth: '',
            gender: ''
        },
        validationSchema: validationSchema,
        onSubmit: handleSubmit
    });

    useEffect(() => {
        if (step === 0 && step1Ref.current) {
            setContentHeight(`${step1Ref.current.offsetHeight}px`);
        } else if (step === 1 && step2Ref.current) {
            setContentHeight(`${step2Ref.current.offsetHeight}px`);
        }
    }, [step, formik.errors, formik.touched]);

    function handleNext(e) {
        e.preventDefault();
        const errors = {};
        try {
            step1ValidationSchema.validateSync(
                { 
                    username: formik.values.username, 
                    password: formik.values.password, 
                    confirm_password: formik.values.confirm_password 
                },
                { abortEarly: false }
            );
            setStep(1);
        } catch (validationErrors) {
            validationErrors.inner.forEach(error => {
                errors[error.path] = error.message;
            });
            formik.setErrors({ ...formik.errors, ...errors });
        }
    }

    function handleBack(e) {
        e.preventDefault();
        setStep(0);
    }

    function handleSubmit(data) {
        Swal.fire({
            title: 'Confirm Registration',
            text: 'Please confirm that all your information is correct before proceeding',
            icon: 'warning',            
            showCancelButton: true,
            confirmButtonText: 'Yes',
        }).then((result) => {
            if (result.isConfirmed) {
                AuthModule.register(data).then((response) => {
                    localStorage.setItem('access_token', response.access_token);
                    window.location.reload();
                }).catch((error) => {
                    Swal.fire({
                        title: 'Registration Failed',
                        text: error.message === 'Username sudah digunakan' ? 'Username already exists' : 'Unable to complete registration. Please try again.',
                        icon: 'error',
                    });
                });
            }
        });
    }

    const genderOptions = [
        { value: 'l', label: 'Male' },
        { value: 'p', label: 'Female' }
    ];

    return (
        <Wrapper>
            <div>
                <h3 className="text-xl font-semibold text-center mb-6">Register new account</h3>

                <form noValidate className="flex flex-col justify-around gap-4" onSubmit={formik.handleSubmit}>
                    <div 
                        className="relative overflow-hidden transition-all duration-500 ease-in-out pe-2"
                        style={{ height: contentHeight }}
                    >
                        <div 
                            ref={step1Ref}
                            className={`transition-all duration-500 ease-in-out ${
                                step === 0 ? 'translate-x-1 opacity-100' : '-translate-x-full opacity-0 absolute invisible'
                            }`}
                        >
                            <FormField
                                label="Username"
                                name="username"
                                value={formik.values.username}
                                onChange={formik.handleChange}
                                onBlur={formik.handleBlur}
                                error={formik.errors.username}
                                touched={formik.touched.username}
                                icon={UserIcon}
                            />

                            <FormField
                                label="Password"
                                name="password"
                                type="password"
                                value={formik.values.password}
                                onChange={formik.handleChange}
                                onBlur={formik.handleBlur}
                                error={formik.errors.password}
                                touched={formik.touched.password}
                                icon={KeyIcon}
                            />

                            <FormField
                                label="Confirm Password"
                                name="confirm_password"
                                type="password"
                                value={formik.values.confirm_password}
                                onChange={formik.handleChange}
                                onBlur={formik.handleBlur}
                                error={formik.errors.confirm_password}
                                touched={formik.touched.confirm_password}
                                icon={KeyIcon}
                            />
                        </div>

                        <div 
                            ref={step2Ref}
                            className={`transition-all duration-500 ease-in-out ${
                                step === 1 ? 'translate-x-1 opacity-100' : 'translate-x-full opacity-0 absolute invisible'
                            }`}
                        >
                            <FormField
                                label="Weight"
                                name="weight"
                                type="number"
                                value={formik.values.weight}
                                onChange={formik.handleChange}
                                onBlur={formik.handleBlur}
                                error={formik.errors.weight}
                                touched={formik.touched.weight}
                            />

                            <FormField
                                label="Height"
                                name="height"
                                type="number"
                                value={formik.values.height}
                                onChange={formik.handleChange}
                                onBlur={formik.handleBlur}
                                error={formik.errors.height}
                                touched={formik.touched.height}
                            />

                            <SelectField
                                label="Gender"
                                name="gender"
                                value={formik.values.gender}
                                onChange={formik.handleChange}
                                onBlur={formik.handleBlur}
                                error={formik.errors.gender}
                                touched={formik.touched.gender}
                                options={genderOptions}
                            />

                            <FormField
                                label="Date of Birth"
                                name="date_of_birth"
                                type="date"
                                value={formik.values.date_of_birth}
                                onChange={formik.handleChange}
                                onBlur={formik.handleBlur}
                                error={formik.errors.date_of_birth}
                                touched={formik.touched.date_of_birth}
                            />
                        </div>
                    </div>

                    <div className="flex flex-col space-y-4 pt-4">
                        {step === 1 && (
                            <button type="button" onClick={handleBack} className="btn btn-outline border border-base-300 w-full">
                                Back
                            </button>
                        )}
                        <button
                            type="button"
                            onClick={step === 0 ? handleNext : formik.handleSubmit}
                            className="btn btn-primary w-full"
                        >
                            {step === 0 ? 'Next' : 'Register'}
                        </button>
                    </div>
                </form>

                <div className="text-center mt-6">
                    <p className="text-sm">
                        Already have an account?{' '}
                        <Link to="/login" className="link link-primary">
                            Login
                        </Link>
                    </p>
                </div>
            </div>
        </Wrapper>
    );
};

export default Register;
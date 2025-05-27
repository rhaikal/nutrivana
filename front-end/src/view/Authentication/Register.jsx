import { useEffect, useRef, useState } from 'react'
import { Link, useNavigate } from 'react-router-dom';
import { EyeIcon, EyeSlashIcon, KeyIcon, UserIcon } from "@heroicons/react/24/solid"
import Wrapper from './components/Wrapper';

const Register = () => {
    const navigate = useNavigate();
    const [showPassword, setShowPassword] = useState(false);
    const [step, setStep] = useState(0);
    const [contentHeight, setContentHeight] = useState('auto');
    const containerRef = useRef(null);
    const step1Ref = useRef(null);
    const step2Ref = useRef(null);

    const handleNext = (e) => {
        e.preventDefault();
        setStep(1);
    };

    const handleBack = (e) => {
        e.preventDefault();
        e.stopPropagation();
        setStep(0);
    };

    const handleSubmit = (e) => {
        e.preventDefault();
        console.log("Form submitted");
        navigate('/');
    };

    useEffect(() => {
        if (step === 0) {
            setContentHeight(`${step1Ref.current.offsetHeight}px`);
        } else {
            setContentHeight(`${step2Ref.current.offsetHeight}px`);
        }
    }, [step]);

    return (
        <Wrapper>
            <div>
                <h3 className="text-xl font-semibold text-center mb-6">Register new account</h3>

                <form noValidate className="flex flex-col justify-around gap-4" onSubmit={handleSubmit}>               
                    <div 
                        ref={containerRef}
                        className="relative overflow-hidden transition-all duration-500 ease-in-out pe-2"
                        style={{ height: contentHeight }}
                    >
                        <div ref={step1Ref} className={`transition-all duration-500 ease-in-out ${step === 0 ? 'translate-x-1 opacity-100' : '-translate-x-full opacity-0 absolute'}`}>
                            <fieldset className="fieldset">
                                <legend className="fieldset-legend">Username</legend>
                                <label className="input input-bordered w-full max-w-none items-center gap-2">
                                    <UserIcon className="h-4 w-4 opacity-70" />
                                    <input type="text" className="w-full" />
                                </label>
                            </fieldset>
                            
                            <fieldset className="fieldset">
                                <legend className="fieldset-legend">Password</legend>
                                <label class="input input-bordered w-full max-w-none items-center gap-2 join-item">
                                    <KeyIcon className="h-4 w-4 opacity-70" />
                                    <input type={showPassword ? "text" : "password"} class="grow" />
                                    <label className="swap">
                                        <input type="checkbox" onClick={() => setShowPassword(!showPassword)} />
                                        <div className="swap-on"><EyeSlashIcon className="h-4 w-4 opacity-70" /></div>
                                        <div className="swap-off"><EyeIcon className="h-4 w-4 opacity-70" /></div>
                                    </label>
                                </label>
                            </fieldset>
                        </div>
                        <div ref={step2Ref} className={`transition-all duration-500 ease-in-out ${step === 1 ? 'translate-x-1 opacity-100' : 'translate-x-full opacity-0 absolute'}`}>
                            <fieldset className="fieldset">
                                <legend className="fieldset-legend">Weight</legend>
                                <label className="input input-bordered w-full max-w-none items-center gap-2">
                                    <input type="number" className="grow" />
                                </label>
                            </fieldset>
                            <fieldset className="fieldset">
                                <legend className="fieldset-legend">Height</legend>
                                <label className="input input-bordered w-full max-w-none items-center gap-2">
                                    <input type="number" className="grow" />
                                </label>
                            </fieldset>
                            <fieldset className="fieldset">
                                <legend className="fieldset-legend">Gender</legend>
                                <select defaultValue="Gender" className="select w-full max-w-none">
                                    <option>Male</option>
                                    <option>Female</option>
                                </select>
                            </fieldset>
                            <fieldset className="fieldset">
                                <legend className="fieldset-legend">Date of Birth</legend>
                                <label className="input input-bordered w-full max-w-none items-center gap-2">
                                    <input type="date" className="grow" />
                                </label>
                            </fieldset>
                        </div> 
                    </div>                    
                    <div className="flex flex-col space-y-4 pt-4">
                        {step === 1 && (
                            <button type="button" onClick={handleBack} className="btn btn-outline border border-base-300 w-full">
                                Back
                            </button>
                        )}
                        <button type="submit" onClick={(e) => step === 0 ? handleNext(e) : handleSubmit(e)} className="btn btn-primary w-full">
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
    )
}

export default Register;
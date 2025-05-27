import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import Wrapper from './components/Wrapper';
import { EyeIcon, EyeSlashIcon, KeyIcon, UserIcon } from '@heroicons/react/24/solid';

const LoginPage = () => {
  const navigate = useNavigate();
  const [showPassword, setShowPassword] = useState(false);

  const handleSubmit = (e) => {
    e.preventDefault();
    navigate('/');
  };

  return (
      <Wrapper>
        <div>
          <h3 className="text-xl font-semibold text-center mb-6">Login to your account</h3>

          <form className="space-y-4" onSubmit={handleSubmit}>
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

            <div className="flex flex-col space-y-4 pt-4">
              <button type="submit" className="btn btn-primary w-full">
                Login
              </button>
            </div>
          </form>

          <div className="text-center mt-6">
            <p className="text-sm">
              Don't have an account?{' '}
              <Link to="/register" className="link link-primary">
                Register
              </Link>
            </p>
          </div>
        </div>
      </Wrapper>
  );
};

export default LoginPage;
import { useFormik } from 'formik';
import { Link } from 'react-router-dom';
import { UserIcon, KeyIcon } from '@heroicons/react/24/solid';
import Swal from '../../utils/Swal';
import Wrapper from './components/Wrapper';
import AuthModule from '../../modules/AuthModule';
import FormField from './components/FormField';

const Login = () => {
  const formik = useFormik({
    initialValues: {
      username: '',
      password: '',
    },
    onSubmit: handleSubmit
  });

  function handleSubmit(data) {
    AuthModule.login(data).then((response) => {
      localStorage.setItem('access_token', response.access_token);
      window.location.reload();
    }).catch((error) => {
      Swal.fire({
        icon: 'error',
        title: 'Error!',
        text: error?.status === 401 ? 'Incorrect username or password' : 'An error occurred during login'
      });
    });
  }

  return (
    <Wrapper>
      <div>
        <h3 className="text-xl font-semibold text-center mb-6">Login to your account</h3>

        <form className="space-y-4" onSubmit={formik.handleSubmit}>
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

export default Login;
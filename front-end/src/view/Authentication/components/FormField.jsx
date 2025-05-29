import PropTypes from 'prop-types';
import { EyeIcon, EyeSlashIcon } from '@heroicons/react/24/solid';
import { useState } from 'react';

const FormField = ({ 
  label, 
  name, 
  type = 'text', 
  value, 
  onChange, 
  onBlur, 
  error, 
  touched, 
  icon: Icon, 
  placeholder = '' 
}) => {
  const [showPassword, setShowPassword] = useState(false);
  const isPasswordField = type === 'password';
  const fieldType = isPasswordField ? (showPassword ? 'text' : 'password') : type;
  const hasError = touched && error;

  return (
    <fieldset className="fieldset">
      <legend className="fieldset-legend">{label}</legend>
      <label className={`input input-bordered ${hasError ? 'input-error' : ''} w-full max-w-none items-center gap-2`}>
        {Icon && <Icon className="h-4 w-4 opacity-70" />}
        <input
          type={fieldType}
          className={isPasswordField ? 'grow' : 'w-full'}
          name={name}
          value={value}
          onChange={onChange}
          onBlur={onBlur}
          placeholder={placeholder}
        />
        {isPasswordField && (
          <label className="swap">
            <input type="checkbox" onClick={() => setShowPassword(!showPassword)} />
            <div className="swap-on"><EyeSlashIcon className="h-4 w-4 opacity-70" /></div>
            <div className="swap-off"><EyeIcon className="h-4 w-4 opacity-70" /></div>
          </label>
        )}
      </label>
      {hasError && (
        <div className="text-error mt-1 text-sm">{error}</div>
      )}
    </fieldset>
  );
};

FormField.propTypes = {
  label: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired,
  type: PropTypes.string,
  value: PropTypes.any,
  onChange: PropTypes.func.isRequired,
  onBlur: PropTypes.func,
  error: PropTypes.string,
  touched: PropTypes.bool,
  icon: PropTypes.elementType,
  placeholder: PropTypes.string
};

export default FormField;
import PropTypes from 'prop-types';

const SelectField = ({ 
  label, 
  name, 
  value, 
  onChange, 
  onBlur, 
  error, 
  touched, 
  options = [] 
}) => {
  const hasError = touched && error;

  return (
    <fieldset className="fieldset">
      <legend className="fieldset-legend">{label}</legend>
      <select 
        className={`select w-full max-w-none ${hasError ? 'select-error' : ''}`}
        name={name}
        value={value}
        onChange={onChange}
        onBlur={onBlur}
      >
        <option value="">Select {label.toLowerCase()}</option>
        {options.map(option => (
          <option key={option.value} value={option.value}>
            {option.label}
          </option>
        ))}
      </select>
      {hasError && (
        <div className="text-error mt-1 text-sm">{error}</div>
      )}
    </fieldset>
  );
};

SelectField.propTypes = {
  label: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired,
  value: PropTypes.any,
  onChange: PropTypes.func.isRequired,
  onBlur: PropTypes.func,
  error: PropTypes.string,
  touched: PropTypes.bool,
  options: PropTypes.arrayOf(
    PropTypes.shape({
      value: PropTypes.string.isRequired,
      label: PropTypes.string.isRequired
    })
  )
};

export default SelectField;
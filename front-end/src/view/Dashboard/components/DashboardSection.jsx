import PropTypes from 'prop-types';

const DashboardSection = ({ children, className, title, action }) => {
  return (
    <div className={`card bg-base-100 shadow-sm card-xl rounded-box p-3 ${className}`} style={{ minHeight: '200px' }}>
      {(title || action) && (
        <div className="flex justify-between w-full mb-2" style={{ height: title ? '32px' : 'auto' }}>
          {title && <h2 className="card-title font-semibold">{title}</h2>}
          {action && <div className="card-actions">{action}</div>}
        </div>
      )}
      <div className={`card-body p-1 ${!title ? "place-content-center" : ""}`}>
        {children}
      </div>
    </div>
  );
};

DashboardSection.propTypes = {
  children: PropTypes.node.isRequired,
  className: PropTypes.string,
  title: PropTypes.string,
  action: PropTypes.node
};

DashboardSection.defaultProps = {
  className: '',
  title: '',
  action: null
};

export default DashboardSection;
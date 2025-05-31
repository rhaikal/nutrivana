import PropTypes from 'prop-types';
import { useContext } from 'react';
import UserContext from '../../../contexts/UserContext';

const NutritionStatus = ({ isLoading }) => {
    const { user } = useContext(UserContext);
    
    const statusMap = {
        'no status': { label: 'No Status', bgColor: 'bg-gray-100', textColor: 'text-gray-400' },
        'severely low': { label: 'Critical Deficiency', bgColor: 'bg-red-100', textColor: 'text-red-400' },
        'low': { label: 'Insufficient', bgColor: 'bg-yellow-100', textColor: 'text-yellow-400' },
        'good': { label: 'Optimal', bgColor: 'bg-green-100', textColor: 'text-green-400' },
        'possible risk of excessive': { label: 'High', bgColor: 'bg-yellow-100', textColor: 'text-yellow-400' },
        'excessive': { label: 'Dangerously High', bgColor: 'bg-red-100', textColor: 'text-red-400' },
        'obese': { label: 'Dangerously High', bgColor: 'bg-red-100', textColor: 'text-red-400' },
    };

    const currentStatus = statusMap[user?.nutritionStatus?.toLowerCase()] ?? statusMap['no status'];    
    
    return (
        <div className="card bg-base-100 shadow-sm card-xl rounded-box p-3">    
            <div className={`${isLoading ? 'skeleton' : currentStatus.bgColor} card-body items-center text-center justify-center-safe`}>
                <h1 className={`${isLoading ? 'invisible' : currentStatus.textColor} card-title text-4xl font-extrabold`}>
                    {currentStatus.label}
                </h1>
            </div>
        </div>
    );
};

NutritionStatus.propTypes = {
    isLoading: PropTypes.bool
};

NutritionStatus.defaultProps = {
    isLoading: false
};

export default NutritionStatus;
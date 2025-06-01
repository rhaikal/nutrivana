import PropTypes from 'prop-types';
import { useContext } from 'react';
import UserContext from '../../../contexts/UserContext';
import { initialNutrition } from '../../../utils/initialState';

const NutrientStat = ({ label, value, minimum }) => {
    const safeValue = value || 0;
    const safeMinimum = minimum || 0;
    const percentage = safeMinimum === 0 ? 0 : (safeValue / safeMinimum) * 100;

    let color = 'text-base';
    if (percentage >= 0) color = 'text-error';
    if (percentage > 33) color = 'text-warning';
    if (percentage > 66) color = 'text-success';
    if (percentage > 133) color = 'text-warning';
    if (percentage > 166) color = 'text-error';

    return (
        <div className={`stats bg-base-100 w-full overflow-hidden ${color}`}>
            <div className="stat">
                <div className="stat-figure">
                    <div 
                        className="radial-progress text-sm font-medium" 
                        style={{ '--value': percentage, '--size': '3rem' }} 
                        role="progressbar"
                    >
                        {percentage.toFixed(1)}
                    </div>
                </div>
                <div className="stat-title text-lg font-extrabold">{label}</div>
                <div className="stat-value">{safeValue.toFixed(2)}<span className="text-sm">/{safeMinimum.toFixed(2)}</span></div>
            </div>
        </div>
    );
};

NutrientStat.propTypes = {
    label: PropTypes.string.isRequired,
    value: PropTypes.number.isRequired,
    minimum: PropTypes.number.isRequired
};

const NutritionIntake = ({ intake, className, isLoading }) => {
    const { user } = useContext(UserContext);
    const nutrients = [
        { label: 'Energy', prop: 'energy' },
        { label: 'Protein', prop: 'protein' },
        { label: 'Total Fat', prop: 'fat' },
        { label: 'Carbohydrate', prop: 'carbohydrate' },
        { label: 'Calcium', prop: 'calcium' },
        { label: 'Iron', prop: 'iron' }
    ];

    return (
        <div className={`card bg-base-100 card-border border-base-200 grid grid-flow-col grid-rows-6 sm:grid-rows-2 gap-3 h-full ${className}`}>
            {nutrients.map((nutrient) => (
                isLoading ? 
                    <div key={nutrient.prop} className="skeleton w-full h-full" />
                :
                    <NutrientStat
                        key={nutrient.prop}
                        label={nutrient.label}
                        value={intake ? intake[nutrient.prop] : user?.intakeNutritions[nutrient.prop]}
                        minimum={user?.minimumNutritions[nutrient.prop]}
                    />
            ))}
        </div>
    );
};

NutritionIntake.propTypes = {
    intake: PropTypes.objectOf(PropTypes.number),
    className: PropTypes.string,
    isLoading: PropTypes.bool,
};

NutritionIntake.defaultProps = {
    intake: initialNutrition,
    className: '',
    isLoading: false
}

export default NutritionIntake;
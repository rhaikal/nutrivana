import { useContext } from "react";
import UserContext from "../../../contexts/UserContext";

const NutritionStatus = () => {
    const { user } = useContext(UserContext);
    
    const status = {
        'no status': { label: 'No Status', bgColor: 'bg-gray-100', textColor: 'text-gray-400' },
        'severely low': { label: 'Critical Deficiency', bgColor: 'bg-red-100', textColor: 'text-red-400' },
        'low': { label: 'Insufficient', bgColor: 'bg-yellow-100', textColor: 'text-yellow-400' },
        'good': { label: 'Optimal', bgColor: 'bg-green-100', textColor: 'text-green-400' },
        'possible risk of excessive': { label: 'High', bgColor: 'bg-yellow-100', textColor: 'text-yellow-400' },
        'excessive': { label: 'Dangerously High', bgColor: 'bg-red-100', textColor: 'text-red-400' },
    }

    const currentStatus = status[user?.nutrition_status?.toLowerCase()] ?? status['no status'];    
    return (
        <div className="card bg-base-100 shadow-sm card-xl rounded-box p-3">
            <div className={`card-body items-center text-center ${currentStatus.bgColor} justify-center-safe`}>
                <h1 className={`card-title text-4xl font-extrabold ${currentStatus.textColor}`}>{currentStatus.label}</h1>
            </div>
        </div>
    );
};

export default NutritionStatus;
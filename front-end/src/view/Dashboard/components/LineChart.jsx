import { useContext } from 'react';
import PropTypes from 'prop-types';
import {
  Chart as ChartJS,
  CategoryScale,  
  LinearScale,   
  PointElement,
  LineElement,   
  Title,
  Tooltip,
  Legend
} from 'chart.js';
import { Line } from 'react-chartjs-2';
import UserContext from '../../../contexts/UserContext';

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend
);

const LineChart = ({ isLoading }) => {
    const { user } = useContext(UserContext);

    const chartData = {
        labels: ['January', 'February', 'March', 'April', 'May', 'June', 'July'],
        datasets: [
            {
                label: 'Height',
                data: user?.growthRecords?.height,
                borderColor: '#0099CC',
                backgroundColor: '#0099CC80',
                tension: 0.1,
                fill: false,
            },
            {
                label: 'Weight',
                data: user?.growthRecords?.weight,
                borderColor: '#CC3399',
                backgroundColor: '#CC339980',
                tension: 0.1,
                fill: false,
            },
        ],
    };

    const options = {
        responsive: true,
        plugins: {
            legend: {
                position: 'top',
            },
            title: {
                display: true,
                text: 'Child Growth (Height & Weight)',
            },
        },
    };

    return isLoading ? <div className="skeleton h-full" /> : <Line data={chartData} options={options} />;
};

LineChart.propTypes = {
    isLoading: PropTypes.bool
};

LineChart.defaultProps = {
    isLoading: false
};

export default LineChart;
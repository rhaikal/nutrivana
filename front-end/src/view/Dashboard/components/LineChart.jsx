import PropTypes from 'prop-types';
import { Line } from 'react-chartjs-2';

const LineChart = ({ data, isLoading }) => {
    const chartData = {
        labels: ['January', 'February', 'March', 'April', 'May', 'June', 'July'],
        datasets: [
            {
                label: 'Height',
                data: data?.height,
                borderColor: '#0099CC',
                backgroundColor: '#0099CC80',
                tension: 0.1,
                fill: false,
            },
            {
                label: 'Weight',
                data: data?.weight,
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
    data: PropTypes.shape({
        weight: PropTypes.arrayOf(PropTypes.number),
        height: PropTypes.arrayOf(PropTypes.number)
    }),
    isLoading: PropTypes.bool
};

LineChart.defaultProps = {
    data: {
        weight: [],
        height: []
    },
    isLoading: false
};

export default LineChart;
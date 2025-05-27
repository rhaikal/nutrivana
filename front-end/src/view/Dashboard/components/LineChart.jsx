import { PropTypes } from 'prop-types'
import { Line } from "react-chartjs-2"

const LineChart = ({data}) => {
    const dataOptions = {
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

    return (
        <Line data={dataOptions} options={options} />
    )
}
LineChart.propTypes = {
    data: PropTypes.object
}
LineChart.defaultProps = {
    data: {
        weight: [],
        height: []
    }
}

export default LineChart;
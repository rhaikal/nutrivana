export const transformGrowthRecordToMonthlyArrays = (data) => {
    const currentYear = new Date().getFullYear();
    const height = Array(12).fill(null);
    const weight = Array(12).fill(null);

    data
        .filter(item => new Date(item.date).getFullYear() === currentYear)
        .sort((a, b) => {
            const dateA = new Date(a.date);
            const dateB = new Date(b.date);
            return dateA.getTime() === dateB.getTime() ? b.id - a.id : dateB - dateA;
        })
        .forEach(record => {
            const month = new Date(record.date).getMonth();
            if (height[month] === null) height[month] = record.height;
            if (weight[month] === null) weight[month] = record.weight;
        });

    return { height, weight };
}

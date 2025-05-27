export const FoodItem = ({ food, onClick }) => {
  return (
    <li className="list-row items-center-safe justify-between border-2 border-base-200 cursor-pointer hover:bg-base-300" onClick={onClick}>
      <div>
        <div className="badge badge-soft badge-info !border-blue-300 !rounded-box">{food.name}</div>
        <div className="flex gap-2 pt-2 text-accent text-sm opacity-60">
          <span>Energy: {food.energy}</span>
          -
          <span>Protein: {food.protein}</span>
          -
          <span>Total Fat: {food.fat}</span>
          -
          <span>Carbohydrate: {food.carbohydrate}</span>
          -
          <span>Calcium: {food.calcium}</span>
          -
          <span>Iron: {food.iron}</span>
        </div>
      </div>
    </li>
  );
};

export const FoodItemInput = ({ food, checked, onChange }) => {
  return (
    <li className={`list-row items-center-safe justify-between border-2 ${checked ? 'border-blue-300' : 'border-base-200'} cursor-pointer hover:bg-base-300`}>
      <div>
        <div className="pb-2 font-semibold">{food.name}</div>
        <div className="flex gap-2">
          <div className="badge badge-soft badge-info border !border-blue-300 !rounded-box">Energy: {food.energy}</div>
          <div className="badge badge-soft badge-info border !border-blue-300 !rounded-box">Protein: {food.protein}</div>
          <div className="badge badge-soft badge-info border !border-blue-300 !rounded-box">Total Fat: {food.fat}</div>
          <div className="badge badge-soft badge-info border !border-blue-300 !rounded-box">Carbohydrate: {food.carbohydrate}</div>
          <div className="badge badge-soft badge-info border !border-blue-300 !rounded-box">Calcium: {food.calcium}</div>
          <div className="badge badge-soft badge-info border !border-blue-300 !rounded-box">Iron: {food.iron}</div>
        </div>
      </div>
      <input 
        type="checkbox"
        className="checkbox checkbox-info self-center place-self-end" 
        checked={checked} 
        onChange={onChange}
      />
    </li>
  );
};

export const FoodList = ({ children, className }) => {
  return (
    <ul className={`list bg-base-100 rounded-box w-full ${className}`}>
      {children}
    </ul>
  );
};
import PropTypes from 'prop-types';
import { forwardRef, useEffect, useRef } from 'react';

export const FoodItem = ({ food, onClick, isLoading }) => {
  return ( isLoading ? 
      <div className="skeleton min-h-[105.5px]" />
    :
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

FoodItem.propTypes = {
  food: PropTypes.shape({
    name: PropTypes.string.isRequired,
    energy: PropTypes.number.isRequired,
    protein: PropTypes.number.isRequired,
    fat: PropTypes.number.isRequired,
    carbohydrate: PropTypes.number.isRequired,
    calcium: PropTypes.number.isRequired,
    iron: PropTypes.number.isRequired
  }).isRequired,
  onClick: PropTypes.func,
  isLoading: PropTypes.bool
};

FoodItem.defaultProps = {
  onClick: () => {},
  isLoading: false
};

export const FoodItemInput = ({ food, checked, onChange, className = '' }) => {
  return (
    <div className='transition-all duration-300 ease-out animate-fade-in'>
      <li 
        onClick={onChange} 
        className={`list-row items-center-safe justify-between border-2 ${checked ? 'border-blue-300' : 'border-base-200'} cursor-pointer hover:bg-base-300 ${className}`}
      >
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
    </div>
  );
};

FoodItemInput.propTypes = {
  food: PropTypes.shape({
    name: PropTypes.string.isRequired,
    energy: PropTypes.number.isRequired,
    protein: PropTypes.number.isRequired,
    fat: PropTypes.number.isRequired,
    carbohydrate: PropTypes.number.isRequired,
    calcium: PropTypes.number.isRequired,
    iron: PropTypes.number.isRequired
  }).isRequired,
  checked: PropTypes.bool.isRequired,
  onChange: PropTypes.func.isRequired,
  className: PropTypes.string
};

export const InfiniteScrollTrigger = ({ onLoadMore, isLoading, remainingCount }) => {
  const triggerRef = useRef(null);
  
  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting && !isLoading && remainingCount > 0) {
          onLoadMore();
        }
      },
      { threshold: 0.5 }
    );
    
    const currentTrigger = triggerRef.current;
    if (currentTrigger) {
      observer.observe(currentTrigger);
    }
    
    return () => {
      if (currentTrigger) {
        observer.unobserve(currentTrigger);
      }
    };
  }, [onLoadMore, isLoading, remainingCount]);
  
  if (remainingCount <= 0) return null;
  
  return (
    <li ref={triggerRef} className="list-row justify-center py-4">
      {isLoading ? (
        <div className="loading loading-spinner loading-md"></div>
      ) : (
        <button 
          className="btn btn-sm btn-outline" 
          onClick={onLoadMore}
        >
          Load more ({remainingCount} remaining)
        </button>
      )}
    </li>
  );
};

InfiniteScrollTrigger.propTypes = {
  onLoadMore: PropTypes.func.isRequired,
  isLoading: PropTypes.bool,
  remainingCount: PropTypes.number.isRequired
};

InfiniteScrollTrigger.defaultProps = {
  isLoading: false
};

export const FoodList = forwardRef(({ children, className, maxHeight }, ref) => {
  const style = maxHeight ? { maxHeight: `${maxHeight}px`, overflowY: 'auto' } : {};
  
  return (
    <div ref={ref} style={style}>
      <ul className={`list bg-base-100 rounded-box w-full ${className}`}>
        {children}
      </ul>
    </div>
  );
});
import { forwardRef, useEffect, useState, useMemo, useCallback } from 'react';
import PropTypes from 'prop-types';
import NutritionIntake from './NutritionIntake';
import { FoodItemInput, FoodList, InfiniteScrollTrigger } from './FoodList';
import { MagnifyingGlassIcon } from '@heroicons/react/24/solid';
import FoodModule from '../../../modules/FoodModule';

const FoodModalComponent = ({ onSave = () => {} }, ref) => {
    const [foods, setFoods] = useState([]);
    const [isLoading, setIsLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState('');
    const [selectedFoods, setSelectedFoods] = useState([]);
    const [visibleCount, setVisibleCount] = useState(5);
    const [isLoadingMore, setIsLoadingMore] = useState(false);
    
    const resetState = () => {
        setSearchQuery('');
        setSelectedFoods([]);
        setVisibleCount(5);
    };

    const filteredFoods = useMemo(() => {
        if (!searchQuery.trim()) return foods;
        
        const query = searchQuery.toLowerCase();
        return foods.filter(food => 
            food.name.toLowerCase().includes(query)
        );
    }, [foods, searchQuery]);
    
    const visibleFoods = useMemo(() => {
        const sortedFoods = [...filteredFoods].sort((a, b) => {
            const aSelected = selectedFoods.some(f => f.id === a.id);
            const bSelected = selectedFoods.some(f => f.id === b.id);
            return bSelected - aSelected;
        });
        
        return sortedFoods.slice(0, visibleCount);
    }, [filteredFoods, visibleCount, selectedFoods]);
    
    const totalNutrition = useMemo(() => {
        const initialValues = {
            energy: 0,
            protein: 0,
            total_fat: 0,
            carbohydrate: 0,
            calcium: 0,
            iron: 0
        };
        
        return selectedFoods.reduce((total, food) => ({
            energy: total.energy + (food.energy || 0),
            protein: total.protein + (food.protein || 0),
            total_fat: total.total_fat + (food.fat || 0),
            carbohydrate: total.carbohydrate + (food.carbohydrate || 0),
            calcium: total.calcium + (food.calcium || 0),
            iron: total.iron + (food.iron || 0)
        }), initialValues);
    }, [selectedFoods]);
    
    const handleFoodToggle = useCallback((food) => {
        const isSelected = selectedFoods.some(f => f.id === food.id);
        
        setTimeout(() => {
            setSelectedFoods(prev => 
                isSelected 
                    ? prev.filter(f => f.id !== food.id)
                    : [...prev, food]
            );
        }, 300);
    }, [selectedFoods]);
    
    const handleSearchChange = useCallback((e) => {
        setSearchQuery(e.target.value);
    }, []);
    
    const handleSave = useCallback(() => {
        console.log('Selected foods:', selectedFoods);
        if (onSave) {
            onSave(selectedFoods);
        }
    }, [selectedFoods, onSave]);
    
    const loadMore = useCallback(() => {
        if (visibleCount >= filteredFoods.length) return;
        
        setIsLoadingMore(true);
        setTimeout(() => {
            setVisibleCount(prev => Math.min(prev + 5, filteredFoods.length));
            setIsLoadingMore(false);
        }, 300);
    }, [filteredFoods.length, visibleCount]);
    
    useEffect(() => {
        const fetchFoods = async () => {
            setIsLoading(true);
            try {
                const res = await FoodModule.getFoods();
                setFoods(res);
            } catch (err) {
                console.error('Failed to fetch foods:', err);
            } finally {
                setIsLoading(false);
            }
        };
        
        fetchFoods();
    }, []);
    
    useEffect(() => {
        setVisibleCount(5);
    }, [searchQuery]);

    return (
        <dialog ref={ref} id="form_modal" className="modal" onClose={resetState}>
            <div className="modal-box w-11/12 max-w-5xl">
                <div className="card border border-base-300 mb-3">
                    <div className="card-body">
                        <NutritionIntake
                            intake={totalNutrition}
                            minimum={{
                                energy: 1350,
                                protein: 20,
                                total_fat: 45,
                                carbohydrate: 215,
                                calcium: 650,
                                iron: 7
                            }}
                            isLoading={isLoading}
                        />
                    </div>
                </div>
                
                {selectedFoods.length > 0 && (
                    <div className="border border-dashed border-blue-300 rounded-lg p-2 mb-3 bg-blue-50/20">
                        <div className="font-semibold text-blue-600 mb-2">Selected Foods</div>
                        <FoodList maxHeight={150}>
                            {selectedFoods.map(food => (
                                <FoodItemInput
                                    key={food.id}
                                    food={food}
                                    checked={true}
                                    onChange={() => handleFoodToggle(food)}
                                />
                            ))}
                        </FoodList>
                    </div>
                )}

                <label className="input mb-3">
                    <MagnifyingGlassIcon className="h-[2em] opacity-50" />
                    <input 
                        type="search" 
                        className="grow" 
                        placeholder="Search foods" 
                        value={searchQuery}
                        onChange={handleSearchChange}
                    />
                </label>
                
                <div>
                    <div className="font-semibold mb-2">Available Foods</div>
                    <FoodList maxHeight={selectedFoods.length > 0 ? 200 : 357.5}>
                        {isLoading ? (
                            Array(5).fill(0).map((_, index) => (
                                <li key={index} className="list-row">
                                    <div className="skeleton h-24 w-full"></div>
                                </li>
                            ))
                        ) : filteredFoods.length === 0 ? (
                            <li className="list-row justify-center py-8 text-gray-500">
                                No foods found matching "{searchQuery}"
                            </li>
                        ) : (
                            <>
                                {visibleFoods
                                    .filter(food => !selectedFoods.some(f => f.id === food.id))
                                    .map(food => (
                                        <FoodItemInput
                                            key={food.id}
                                            food={food}
                                            checked={false}
                                            onChange={() => handleFoodToggle(food)}
                                        />
                                    ))
                                }
                                
                                <InfiniteScrollTrigger 
                                    onLoadMore={loadMore}
                                    isLoading={isLoadingMore}
                                    remainingCount={filteredFoods.filter(food => !selectedFoods.some(f => f.id === food.id)).length - visibleCount}
                                />
                            </>
                        )}
                    </FoodList>
                </div>
                
                <div className="modal-action">
                    <form method="dialog" onSubmit={resetState}>
                        <button className="btn">Close</button>
                    </form>
                    <button 
                        className="btn btn-info" 
                        onClick={handleSave}
                        disabled={selectedFoods.length === 0}
                    >
                        Save
                    </button>
                </div>
            </div>
        </dialog>
    );
};

FoodModalComponent.propTypes = {
    onSave: PropTypes.func
};

const FoodModal = forwardRef(FoodModalComponent);
FoodModal.displayName = 'FoodModal';

export default FoodModal;
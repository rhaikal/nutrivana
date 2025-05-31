import { forwardRef, useEffect, useState, useMemo, useCallback, useContext, useImperativeHandle } from 'react';
import PropTypes from 'prop-types';
import { MagnifyingGlassIcon } from '@heroicons/react/24/solid';
import { Dialog, DialogBackdrop, DialogPanel } from '@headlessui/react';
import Swal from '../../../utils/Swal';
import FoodModule from '../../../modules/FoodModule';
import UserContext from '../../../contexts/UserContext';
import NutritionIntake from './NutritionIntake';
import { FoodItemInput, FoodList, InfiniteScrollTrigger } from './FoodList';

const FoodModalComponent = forwardRef(({ onSave = () => {}}, ref) => {
    const { user } = useContext(UserContext);

    const [foods, setFoods] = useState([]);
    const [isLoading, setIsLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState('');
    const [selectedFoods, setSelectedFoods] = useState([]);
    const [visibleCount, setVisibleCount] = useState(5);
    const [isLoadingMore, setIsLoadingMore] = useState(false);
    const [isOpen, setIsOpen] = useState(false);
    
    useImperativeHandle(ref, () => ({
        open: () => setIsOpen(true),
        close: () => setIsOpen(false)
    }));

    const resetState = () => {
        setSearchQuery('');
        setSelectedFoods([]);
        setVisibleCount(5);
        setIsOpen(false);
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
        const initialValues = user?.intakeNutritions;
        
        return selectedFoods.reduce((total, food) => ({
            energy: total.energy + (food.energy || 0),
            protein: total.protein + (food.protein || 0),
            fat: total.fat + (food.fat || 0),
            carbohydrate: total.carbohydrate + (food.carbohydrate || 0),
            calcium: total.calcium + (food.calcium || 0),
            iron: total.iron + (food.iron || 0)
        }), initialValues);
    }, [selectedFoods, user?.intakeNutritions]);
    
    const handleFoodToggle = useCallback((food) => {
        const isSelected = selectedFoods.some(f => f.id === food.id);
        
        setTimeout(() => {
            if (isSelected) {
                setSelectedFoods(prev => prev.filter(f => f.id !== food.id));
            } else if (selectedFoods.length < 4) {
                setSelectedFoods(prev => [...prev, food]);
            } else {
                Swal.fire({
                    title: 'Maximum Foods Reached',
                    text: 'You can only select up to 4 foods at a time',
                    icon: 'warning',
                    confirmButtonColor: '#3085d6',
                    confirmButtonText: 'OK'
                });
            }
        }, 300);
    }, [selectedFoods]);
    
    const handleSearchChange = useCallback((e) => {
        setSearchQuery(e.target.value);
    }, []);
    
    const handleSave = useCallback(() => {
        Swal.fire({
            title: 'Confirm Food Intake',
            text: 'Are you sure these selected foods have been eaten?',                        
            icon: 'question',
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, save it!'
        }).then((result) => {
            if (result.isConfirmed) {
                if (onSave) {
                    Promise.resolve(
                        onSave(selectedFoods.map((selectedFood) => ({ f_id: selectedFood.id })))
                    ).catch((err) => {
                        console.error('Failed to save food intake:', err);
                        Swal.fire({
                            title: 'Failed to Save Food Intake',
                            text: 'Please try again later',
                            icon: 'error',
                            confirmButtonColor: '#3085d6',
                            confirmButtonText: 'OK'
                        });
                    });
                    resetState();
                }
            }
        });
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
        <Dialog 
            as="div"
            open={isOpen}
            onClose={resetState}
            className="relative z-40"
        >
            <DialogBackdrop
                transition
                className="fixed inset-0 bg-gray-500/75 transition-opacity data-closed:opacity-0 data-enter:duration-300 data-enter:ease-out data-leave:duration-200 data-leave:ease-in"
            />
            
            <div className="fixed inset-0 flex items-center justify-center p-4">
                <DialogPanel 
                    transition
                    className="bg-base-100 rounded-box w-[91.6667%] max-w-7/12 max-h-[100vh] p-6 overflow-y-auto shadow-2xl transform transition-all data-closed:opacity-0 data-closed:scale-95 data-enter:duration-300 data-enter:ease-out data-leave:duration-200 data-leave:ease-in"
                >
                    <div className="card border border-base-300 mb-3 max-h-96 overflow-auto">
                        <div className="card-body">
                            <NutritionIntake
                                intake={totalNutrition}
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
                        <button 
                            className="btn"
                            onClick={resetState}
                        >
                            Close
                        </button>
                        <button 
                            type='button'
                            className="btn btn-info"
                            onClick={handleSave}
                            disabled={selectedFoods.length === 0}
                        >
                            Save
                        </button>
                    </div>
                </DialogPanel>
            </div>
        </Dialog>
    );
});

FoodModalComponent.propTypes = {
    onSave: PropTypes.func
};

FoodModalComponent.displayName = 'FoodModal';

export default FoodModalComponent;
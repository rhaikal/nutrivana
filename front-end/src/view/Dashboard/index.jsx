import { useContext, useEffect, useRef, useState, useMemo } from "react"
import { EllipsisHorizontalIcon } from "@heroicons/react/24/solid"
import NutritionIntake from './components/NutritionIntake';
import NutritionStatus from "./components/NutritionStatus";
import { FoodItem, FoodList } from "./components/FoodList";
import LineChart from "./components/LineChart";
import DetailModal from "./components/DetailModal";
import FoodModal from "./components/FoodModal";
import GrowthModal from "./components/GrowthModal";
import { useMediaQuery } from "../../hooks/useMediaQuery";
import DashboardSection from "./components/DashboardSection";
import UserContext from "../../contexts/UserContext";
import FoodModule from "../../modules/FoodModule";
import { formatFoodIngredients } from "../../utils/food";

const Dashboard = () => {
    const { isLoading: isFetchingUsersData, updateIntakeNutritions } = useContext(UserContext);

    const detailModal = useRef();
    const foodModal = useRef();
    const growthModal = useRef();

    const isTablet = useMediaQuery('(min-width: 640px) and (max-width: 1023px)');
    const isDesktop = useMediaQuery('(min-width: 1024px)');

    const [isInitialLoad, setIsInitialLoad] = useState(true);
    const [isFoodModalSaved, setIsFoodModalSaved] = useState(false);
    const [isLoadingRecommendations, setIsLoadingRecommendations] = useState(false);
    const [recommendedFoods, setRecommendedFoods] = useState([]);
    const [eatenFoods, setEatenFoods] = useState([]);
    const [selectedFood, setSelectedFood] = useState({});

    const topSectionLayout = useMemo(() => isDesktop ? 'grid-cols-3' : 'grid-cols-1', [isDesktop]);
    const bottomSectionLayout = useMemo(() => isDesktop ? 'grid-cols-2' : 'grid-cols-1', [isDesktop]);
    const columnSpan = useMemo(() => isDesktop || isTablet ? 'col-span-1 self-center' : 'col-span-full', [isDesktop, isTablet]);
    const rightColumnSpan = useMemo(() => isDesktop ? 'col-span-2' : isTablet ? 'col-span-1' : 'col-span-full', [isDesktop, isTablet]);

    const AddFoodButton = () => (
        <button 
            className="btn btn-primary btn-sm" 
            disabled={isInitialLoad} 
            onClick={() => foodModal.current.open()}
        >
            Add Food
        </button>
    );
    
    const handleClickFoodItem = (selectedItem) => {
        setSelectedFood(selectedItem)
        detailModal.current.open()
    }

    const handleClickLogout = () => {
        localStorage.removeItem('access_token');
        window.location.reload();
    }
    
    const handleSaveFoodModal = async (foodIds) => {
        setIsFoodModalSaved(true)
        return FoodModule.saveEatenFoods({items: foodIds})
            .then(async () => {
                fetchRecommendedFoods();
                await fetchEatenFoods();
                await updateIntakeNutritions();
            })
            .catch((error) => {
                console.error('Error saving eaten food ids:', error);
            }).finally(() => {
                setIsFoodModalSaved(false);
            });
    }

    const fetchEatenFoods = async () => {
        return FoodModule.getEatenFoods()
            .then((response) => {
                response = formatFoodIngredients(response, 'ingredient_names')
                console.log(response)
                setEatenFoods(response);
            })
            .catch((error) => {
                console.error('Error fetching eaten foods:', error);
            });
    }

    const fetchRecommendedFoods = async () => {
        setIsLoadingRecommendations(true);
        return FoodModule.getRecommendationFoods()
            .then((response) => {
                response = formatFoodIngredients(response, 'i_names')
                setRecommendedFoods(response);
            })
            .catch((error) => {
                if (error.status === 404){
                    setRecommendedFoods([])
                } else {
                    console.error('Error fetching recommended foods:', error);
                }
            })
            .finally(() => {
                setIsLoadingRecommendations(false);
            });
    }

    useEffect(() => {
        const initializeDashboard = async () => {
            setIsInitialLoad(true);

            try {
                fetchRecommendedFoods();
                await fetchEatenFoods();
            } catch (err) {
                console.error(err)
            }

            setIsInitialLoad(false)
        }

        initializeDashboard();
    }, [])

    return (
        <div className="container mx-auto">
            <div className={`grid ${topSectionLayout} gap-4 p-4`}>
                <div className={columnSpan}>
                    <div className="navbar bg-base-100 shadow-sm rounded-box pb-4 mb-3">
                        <div className="flex-1">
                            <a className="btn btn-ghost text-xl">Nutrivana</a>
                        </div>
                        <div className="dropdown dropdown-bottom dropdown-end">
                            <div tabIndex={0} role="button" className="btn btn-square btn-ghost">
                                <EllipsisHorizontalIcon className="h-8 w-8" />
                            </div>
                            <ul
                                tabIndex={0}
                                className="menu menu-sm dropdown-content bg-base-100 rounded-box z-1 mt-3 w-52 p-2 shadow">
                                <li><a onClick={() => growthModal.current.open()}>Record Growth</a></li>
                                <li><a onClick={handleClickLogout}>Log Out</a></li>
                            </ul>
                        </div>
                    </div>
                    
                    <DashboardSection>
                        <NutritionStatus isLoading={isFetchingUsersData || isInitialLoad} />
                    </DashboardSection>
                </div>

                <div className={rightColumnSpan}>
                    <div className="flex flex-col h-full">                       
                        <DashboardSection className="flex-grow">
                            <NutritionIntake
                                isLoading={isFetchingUsersData || isInitialLoad || isFoodModalSaved}
                            />
                        </DashboardSection>
                    </div>
                </div>
            </div>

            <div className={`grid ${bottomSectionLayout} gap-4 px-4 pb-4`}>
                <DashboardSection title="Growth Chart">
                    <LineChart
                        isLoading={isFetchingUsersData || isInitialLoad}
                    />
                </DashboardSection>

                <div className="grid grid-cols-1 gap-4">
                    <DashboardSection title={recommendedFoods?.length > 0 ? "Recommended Foods" : null }>
                        {isLoadingRecommendations ? 
                            <div className='skeleton h-full w-full'/> 
                            : recommendedFoods?.length === 0 ?
                                <div className="flex flex-col items-center text-center gap-4">
                                    <h1 className="card-title text-3xl text-neutral font-bold mt-4">No Recommendations Yet</h1>
                                    <p className="text-base text-neutral-500">Add some foods to your history to get personalized recommendations</p>
                                </div>                                               
                                :
                                <FoodList maxHeight={isDesktop ? 141.5 : null} className='py-2'>
                                    { recommendedFoods?.map((recommendedFood) => (
                                        <FoodItem 
                                            food={recommendedFood}
                                            onClick={() => handleClickFoodItem(recommendedFood)}
                                            isLoading={isLoadingRecommendations}
                                        />
                                    ))
                                    }
                                </FoodList>
                        }
                    </DashboardSection>

                    <DashboardSection 
                        title={eatenFoods?.length > 0 ? "Today's Eaten Foods" : null }
                        action={eatenFoods?.length > 0 ? <AddFoodButton /> : null}
                    >
                        {isInitialLoad || isFoodModalSaved ?
                            <div className='skeleton h-full w-full'/> 
                            : eatenFoods?.length === 0 ?
                                <div className="flex flex-col items-center gap-4">
                                    <h1 className="text-3xl font-bold text-neutral">No Food History</h1>
                                    <AddFoodButton />
                                </div>                            
                            :
                            <FoodList maxHeight={isDesktop ? 141.5 : null} className='py-2'>
                                {eatenFoods?.map((eatenFood) => (
                                    <FoodItem
                                        food={eatenFood}
                                        onClick={() => handleClickFoodItem(eatenFood)}
                                        isLoading={isInitialLoad || isFoodModalSaved}
                                    />
                                ))}
                            </FoodList>
                        }
                    </DashboardSection>
                </div>
            </div>

            <DetailModal food={selectedFood} ref={detailModal} />
            <FoodModal onSave={handleSaveFoodModal} ref={foodModal} />
            <GrowthModal ref={growthModal} />
        </div>
    )
}

export default Dashboard

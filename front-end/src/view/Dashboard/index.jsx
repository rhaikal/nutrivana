import { useContext, useEffect, useRef, useState, useMemo } from "react"
import { EllipsisHorizontalIcon } from "@heroicons/react/24/solid"
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

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend
);

const Dashboard = () => {
    const { isLoading: isFetchingUsersData } = useContext(UserContext);

    const detailModal = useRef();
    const foodModal = useRef();
    const growthModal = useRef();

    const isTablet = useMediaQuery('(min-width: 640px) and (max-width: 1023px)');
    const isDesktop = useMediaQuery('(min-width: 1024px)');

    const [isInitialLoad, setIsInitialLoad] = useState(true);
    const [chartData] = useState({
        weight: [4.2, 5.1, 6.3, 7.2, 7.8, 8.2, 8.6, 8.9, 9.2, 9.4, 9.7, 10.0],
        height: [52.3, 55.8, 59.4, 62.1, 64.3, 66.1, 67.8, 69.2, 70.6, 71.9, 73.1, 74.3]
    });
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

    const fetchEatenFoods = async () => {
        return FoodModule.getEatenFoods()
            .then((response) => {
                setEatenFoods(response);
            })
            .catch((error) => {
                console.error('Error fetching eaten foods:', error);
            });
    }

    const fetchRecommendedFoods = async () => {
        return FoodModule.getRecommendationList()
            .then((response) => {
                setRecommendedFoods(response);
            })
            .catch((error) => {
                if (error.status === 404){
                    setRecommendedFoods([])
                } else {
                    console.error('Error fetching recommended foods:', error);
                }
            });
    }

    useEffect(() => {
        const initializeDashboard = async () => {
            setIsInitialLoad(true)

            try {
                await Promise.all([
                    fetchRecommendedFoods(),
                    fetchEatenFoods()
                ]);
            } catch (error) {
                console.error('Error initializing dashboard:', error);
            } finally {
                setIsInitialLoad(false)
            }
        }

        initializeDashboard();
    }, [])

    useEffect(() => {
        setIsInitialLoad(isFetchingUsersData)
    }, [isFetchingUsersData])

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
                        <NutritionStatus isLoading={isInitialLoad} />
                    </DashboardSection>
                </div>

                <div className={rightColumnSpan}>
                    <div className="flex flex-col h-full">                       
                        <DashboardSection className="flex-grow">
                            <NutritionIntake
                                isLoading={isInitialLoad}
                            />
                        </DashboardSection>
                    </div>
                </div>
            </div>

            <div className={`grid ${bottomSectionLayout} gap-4 px-4 pb-4`}>
                <DashboardSection title="Growth Chart" className='max-h-fit'>
                    <LineChart 
                        data={chartData}
                        isLoading={isInitialLoad}
                    />
                </DashboardSection>

                <div className="grid grid-cols-1 gap-4">
                    <DashboardSection title={recommendedFoods?.length > 0 ? "Recommended Foods" : null }>
                        {recommendedFoods?.length === 0 ?
                            isInitialLoad ? 
                                <div className='skeleton h-full w-full'/> 
                                : 
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
                                        isLoading={isInitialLoad}
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
                        {eatenFoods?.length === 0 ?
                            isInitialLoad ? 
                                <div className='skeleton h-full w-full'/> 
                                : 
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
                                        isLoading={isInitialLoad}
                                    />
                                ))}
                            </FoodList>
                        }
                    </DashboardSection>
                </div>
            </div>

            <DetailModal food={selectedFood} ref={detailModal} />
            <FoodModal ref={foodModal} />
            <GrowthModal ref={growthModal} />
        </div>
    )
}

export default Dashboard
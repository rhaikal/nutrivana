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
import { initialNutrition } from "../../utils/initialState";
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
    const [intake, setIntake] = useState(initialNutrition);
    const [minimum, setMinimum] = useState(initialNutrition)
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
            onClick={() => foodModal.current.showModal()}
        >
            Add Food
        </button>
    );
    
    const handleClickFoodItem = (selectedItem) => {
        setSelectedFood(selectedItem)
        detailModal.current.showModal()
    }

    const handleClickLogout = () => {
        localStorage.removeItem('access_token');
        window.location.reload();
    }

    useEffect(() => {
        setIsInitialLoad(true)

        setIntake({
            energy: 100,
            protein: 8,
            total_fat: 3,
            carbohydrate: 150,
            calcium: 300,
            iron: 0.5
        })

        setMinimum({
            energy: 1350,
            protein: 20,
            total_fat: 45,
            carbohydrate: 215,
            calcium: 650,
            iron: 7
        })

        setRecommendedFoods([{
            name: "Baby Toddler cereal, rice with fruit, ready-to-eat",
            ingredients: [
                'Babyfood, water, bottled, GERBER, without added fluoride', 
                'Babyfood, cereal, rice, dry fortified', 
                'Sugars, granulated', 
                'Flour, rice, white, unenriched',
                'Baby Toddler fruit, NFS'
            ],
            energy: 130,
            protein: 2.5,
            fat: 0.5,
            carbohydrate: 28,
            calcium: 10,
            iron: 0.4
        }])

        setEatenFoods([{
            name: "Baby Toddler cereal, oatmeal with fruit, ready-to-eat",
            ingredients: [
                'Babyfood, water, bottled, GERBER, without added fluoride', 
                'Babyfood, cereal, oatmeal, dry fortified', 
                'Cereals, oats, regular and quick, not fortified, dry', 
                'Sugars, granulated', 
                'Baby Toddler fruit, NFS'
            ],
            energy: 100,
            protein: 3.5,
            fat: 3,
            carbohydrate: 15,
            calcium: 120,
            iron: 0.5
        }])

        setIsInitialLoad(false)
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
                                <li><a onClick={() => growthModal.current.showModal()}>Record Growth</a></li>
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
                                intake={intake}
                                minimum={minimum}
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
                    <DashboardSection title="Recommended Foods">
                        {recommendedFoods.length === 0 ?
                            isInitialLoad ? 
                                <div className='skeleton h-full w-full'/> 
                                : 
                                <div className="flex flex-col items-center text-center gap-4">
                                    <h1 className="card-title text-3xl text-neutral font-bold mt-4">No Recommendations Yet</h1>
                                    <p className="text-base text-neutral-500">Add some foods to your history to get personalized recommendations</p>
                                </div>                                               
                            :
                            <FoodList className='py-2'>
                                { recommendedFoods.map((recommendedFood) => (
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
                        title="Today's Eaten Foods" 
                        action={eatenFoods.length > 0 ? <AddFoodButton /> : null}
                    >
                        {eatenFoods.length === 0 ?
                            isInitialLoad ? 
                                <div className='skeleton h-full w-full'/> 
                                : 
                                <div className="flex flex-col items-center gap-4">
                                    <h1 className="text-3xl font-bold text-neutral">No Food History</h1>
                                    <AddFoodButton />
                                </div>                            
                            :
                            <FoodList className='py-2'>
                                {eatenFoods.map((eatenFood) => (
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
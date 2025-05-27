import { useEffect, useRef, useState } from "react"
import { EllipsisHorizontalIcon, MagnifyingGlassIcon } from "@heroicons/react/24/solid"
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
import { FoodItem, FoodItemInput, FoodList } from "./components/FoodList";
import LineChart from "./components/LineChart";
import DetailModal from "./components/DetailModal";
import FoodModal from "./components/FoodModal";
import GrowthModal from "./components/GrowthModal";

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
    const detailModal = useRef();
    const foodModal = useRef();
    const growthModal = useRef();

    const [intake, setIntake] = useState(initialNutrition);
    const [minimum, setMinimum] = useState(initialNutrition);
    const [dailyHistories] = useState(['test']);

    useEffect(() => {
        // fetch intake (WIP)
        setIntake({
            energy: 100,
            protein: 8,
            total_fat: 3,
            carbohydrate: 150,
            calcium: 300,
            iron: 0.5
        })

        // fetch Minimum
        setMinimum({
            energy: 1350,
            protein: 20,
            total_fat: 45,
            carbohydrate: 215,
            calcium: 650,
            iron: 7
        })
    }, [])

    return (
        <>
            <div className='grid grid-cols-1 lg:grid-cols-3 gap-4 px-6 py-3 leading-6'>
                <div className="grid grid-flow-row col-span-1 gap-4">
                    <div className="navbar bg-base-100 shadow-sm  rounded-box">
                        <div className="flex-1">
                            <a className="btn btn-ghost text-xl">Nutrivana</a>
                        </div>
                        <div className="flex-none">
                            <div className="dropdown dropdown-bottom dropdown-end">
                                <div tabIndex={0} role="button" className="btn btn-square btn-ghost">
                                    <EllipsisHorizontalIcon className="h-8 w-8" />
                                </div>
                                <ul
                                    tabIndex={0}
                                    className="menu menu-sm dropdown-content bg-base-100 rounded-box z-1 mt-3 w-52 p-2 shadow">
                                    <li><a onClick={() => growthModal.current.showModal()}>Record Growth</a></li>
                                    <li><a>Log Out</a></li>
                                </ul>
                            </div>
                        </div>
                    </div>
                    <div className="card bg-base-100 shadow-sm card-xl rounded-box p-3">
                        <NutritionStatus />
                    </div>
                </div>
                <div className="grid grid-flow-row col-span-2 gap-4">
                    <NutritionIntake 
                        intake={intake}
                        minimum={minimum}
                    />
                </div>
            </div>
            <div className='grid grid-cols-1 lg:grid-cols-2 gap-4 px-6 py-3 leading-6'>
                <div className="card bg-base-100 shadow-sm card-xl rounded-box p-3">
                    <LineChart data={{
                        weight: [4.2, 5.1, 6.3, 7.2, 7.8, 8.2, 8.6, 8.9, 9.2, 9.4, 9.7, 10.0],
                        height: [52.3, 55.8, 59.4, 62.1, 64.3, 66.1, 67.8, 69.2, 70.6, 71.9, 73.1, 74.3]                    
                    }} />
                </div>
                <div className='grid grid-flow-row gap-4'>
                    <div className="card bg-base-100 shadow-sm card-xl rounded-box p-3">
                        <div className="card-body items-center justify-center h-[10rem] p-3">
                            { dailyHistories.length === 0 ?
                                <div className="flex flex-col items-center gap-4">
                                    <div className="flex flex-col items-center text-center">
                                        <h1 className="card-title text-3xl text-neutral font-bold mt-4">No Recommendations Yet</h1>
                                        <p className="text-base text-neutral-500">Add some foods to your history to get personalized recommendations</p>
                                    </div>
                                </div>                                                                    :
                                <>
                                    <div className="flex justify-between w-full" style={{ marginBlockEnd: 'auto' }}>
                                        <h1 className="card-title font-semibold min-h-[40px]">
                                            Recommended Next Foods
                                        </h1>
                                    </div>
                                    <FoodList className='py-2'>
                                        <FoodItem 
                                            food={{
                                                name: "Baby Toddler cereal, rice with fruit, ready-to-eat",
                                                energy: 130,
                                                protein: 2.5,
                                                fat: 0.5,
                                                carbohydrate: 28,
                                                calcium: 10,
                                                iron: 0.4
                                            }}
                                        />
                                    </FoodList>
                                </>
                            }
                        </div>
                    </div>
                    <div className="card bg-base-100 shadow-sm card-xl rounded-box p-3">
                        <div className="card-body items-center justify-center h-[10rem] p-3">
                            { dailyHistories.length === 0 ?
                                <div className="flex flex-col items-center gap-4">
                                    <h1 className="text-3xl font-bold text-neutral">No Food History</h1>
                                    <button className="btn btn-primary">Add Food</button>
                                </div>                            
                                    :
                                <>
                                    <div className="flex justify-between w-full" style={{ marginBlockEnd: 'auto' }}>
                                        <h1 className="card-title font-semibold">
                                            Today's Eaten Foods
                                        </h1>
                                        <div className="card-actions btn-sm">
                                            <button className="btn btn-primary" onClick={() => foodModal.current.showModal()}>Add Food</button>
                                        </div>
                                    </div>
                                    <FoodList className='py-2'>
                                        <FoodItem
                                            food={{
                                                name: "Baby Toddler cereal, oatmeal with fruit, ready-to-eat",
                                                energy: 100,
                                                protein: 3.5,
                                                fat: 3,
                                                carbohydrate: 15,
                                                calcium: 120,
                                                iron: 0.5
                                            }}
                                            onClick={()=>detailModal.current.showModal()}
                                        />
                                    </FoodList>
                                </>
                            }
                        </div>
                    </div>
                </div>
            </div>
            <DetailModal ref={detailModal} />
            <FoodModal ref={foodModal} />
            <GrowthModal 
                ref={growthModal} 
                onSubmit={(data) => {
                    console.log('Growth data:', data);
                    // Handle the growth data here
                }}
            />
        </>
    )
}

export default Dashboard
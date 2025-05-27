import { forwardRef } from "react"
import NutritionIntake from "./NutritionIntake"
import { FoodItemInput, FoodList } from "./FoodList"
import { MagnifyingGlassIcon } from "@heroicons/react/24/solid"

const FoodModal = forwardRef((props, ref) => {
    return (
        <dialog ref={ref} id='form_modal' className="modal">
                <div className="modal-box w-11/12 max-w-5xl">
                    <div className="card border border-base-300 mb-3">
                        <div className="card-body">
                            <NutritionIntake
                                intake={{
                                    energy: 100 + 100,
                                    protein: 8 + 3.5,
                                    total_fat: 3 + 3,
                                    carbohydrate: 150 + 15,
                                    calcium: 300 + 120,
                                    iron: 0.5 + 0.5
                                }}
                                minimum={{
                                    energy: 1350,
                                    protein: 20,
                                    total_fat: 45,
                                    carbohydrate: 215,
                                    calcium: 650,
                                    iron: 7
                                }}
                            />
                        </div>
                    </div>
                    <label className="input mb-3">
                        <MagnifyingGlassIcon className="h-[2em] opacity-50" />
                        <input type="search" className="grow" placeholder="Search" />
                    </label>
                    <FoodList>
                        <FoodItemInput 
                            food={{
                                name: "Baby Toddler cereal, oatmeal with fruit, ready-to-eat",
                                energy: 100,
                                protein: 3.5,
                                fat: 3,
                                carbohydrate: 15,
                                calcium: 120,
                                iron: 0.5
                            }}
                            checked={true}
                            onChange={() => {}}
                        />
                        <FoodItemInput
                            food={{
                                name: "Baby Toddler cereal, NFS",
                                energy: Math.floor(Math.random() * 200),
                                protein: +(Math.random() * 10).toFixed(1),
                                fat: +(Math.random() * 8).toFixed(1), 
                                carbohydrate: Math.floor(Math.random() * 30),
                                calcium: Math.floor(Math.random() * 200),
                                iron: +(Math.random() * 2).toFixed(1)                            
                            }}
                            checked={false}
                            onChange={() => {}}
                        />
                    </FoodList>
                    <div className="modal-action">
                        <form method="dialog">
                            <button className="btn">Close</button>
                        </form>
                        <button className="btn btn-info">Save</button>
                    </div>
                </div>
            </dialog>
    )
})

export default FoodModal
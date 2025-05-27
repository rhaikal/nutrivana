import { forwardRef } from "react";

const DetailModal = forwardRef((props, ref) => {
    return (
        <dialog ref={ref} id='detail_modal' className="modal">
            <div className="modal-box w-11/12 max-w-5xl">
                <h3 className="font-bold text-2xl text-info pb-3">Baby Toddler cereal, oatmeal with fruit, ready-to-eat</h3>
                <div className='grid grid-cols-1 lg:grid-cols-5 gap-4 px-6'>
                    <div className="col-span-2">
                        <div className="card card-border border-base-300 bg-base-100">
                            <div className="card-body">
                                <h2 className="card-title">Nutrition</h2>
                                <div className="overflow-x-auto">
                                    <table className="table">
                                        <thead>
                                            <tr>
                                                <th>Name</th>
                                                <th>Amount</th>
                                                <th>Unit</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <tr>
                                                <td>Energy</td>
                                                <td>100</td>
                                                <td>kcal</td>
                                            </tr>
                                            <tr>
                                                <td>Protein</td>
                                                <td>3.5</td>
                                                <td>g</td>
                                            </tr>
                                            <tr>
                                                <td>Fat</td>
                                                <td>3</td>
                                                <td>g</td>
                                            </tr>
                                            <tr>
                                                <td>Carbohydrate</td>
                                                <td>15</td>
                                                <td>g</td>
                                            </tr>
                                            <tr>
                                                <td>Calcium</td>
                                                <td>120</td>
                                                <td>mg</td>
                                            </tr>
                                            <tr>
                                                <td>Iron</td>
                                                <td>0.5</td>
                                                <td>mg</td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div className="col-span-3">
                        <div className="card card-border border-base-300 bg-base-100">
                            <div className="card-body">
                                <h2 className="card-title">Ingredients</h2>
                                <div className="overflow-x-auto">
                                    <table className="table">
                                        <thead>
                                            <tr>
                                                <th>Name</th>
                                                <th>Amount (g)</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <tr>
                                                <td>Rice</td>
                                                <td>100</td>
                                            </tr>
                                            <tr>
                                                <td>Minced Chicken</td>
                                                <td>1</td>
                                            </tr>
                                            <tr>
                                                <td>Carrot</td>
                                                <td>1</td>
                                            </tr>
                                            <tr>
                                                <td>Garlic</td>
                                                <td>1</td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div className="modal-action">
                    <form method="dialog">
                        <button className="btn">Close</button>
                    </form>
                </div>
            </div>
        </dialog>
    )
});

export default DetailModal;

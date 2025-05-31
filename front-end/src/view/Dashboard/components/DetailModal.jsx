import { forwardRef } from 'react';
import PropTypes from 'prop-types';

const DetailModalComponent = ({ food }, ref) => {
    return (
        <dialog ref={ref} id="detail_modal" className="modal">
            <div className="modal-box w-11/12 max-w-5xl">
                <div className="grid grid-cols-1 lg:grid-cols-5 gap-4 px-6">
                    <div className='col-span-full'>
                        <table className="table">
                            <tbody>
                                <tr>
                                    <td className="font-semibold text-lg w-36">Food Name : </td>
                                    <td className="text-lg">{food.name}</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
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
                                                <td>{food.energy}</td>
                                                <td>kcal</td>
                                            </tr>
                                            <tr>
                                                <td>Protein</td>
                                                <td>{food.protein}</td>
                                                <td>g</td>
                                            </tr>
                                            <tr>
                                                <td>Fat</td>
                                                <td>{food.fat}</td>
                                                <td>g</td>
                                            </tr>
                                            <tr>
                                                <td>Carbohydrate</td>
                                                <td>{food.carbohydrate}</td>
                                                <td>g</td>
                                            </tr>
                                            <tr>
                                                <td>Calcium</td>
                                                <td>{food.calcium}</td>
                                                <td>mg</td>
                                            </tr>
                                            <tr>
                                                <td>Iron</td>
                                                <td>{food.iron}</td>
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
                                            </tr>
                                        </thead>
                                        <tbody>
                                            {food?.ingredients?.map((ingredient) => (
                                                <tr key={ingredient}>
                                                    <td>{ingredient}</td>
                                                </tr>
                                            ))}
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
    );
};

const DetailModal = forwardRef(DetailModalComponent);
DetailModal.displayName = 'DetailModal';

export default DetailModal;
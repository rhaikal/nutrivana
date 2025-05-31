import { forwardRef, useState, useImperativeHandle } from 'react';
import PropTypes from 'prop-types';
import { Dialog, DialogPanel, DialogBackdrop } from '@headlessui/react';

const DetailModalComponent = ({ food }, ref) => {
    const [isOpen, setIsOpen] = useState(false);
    
    useImperativeHandle(ref, () => ({
        open: () => setIsOpen(true),
        close: () => setIsOpen(false)
    }));

    return (
        <Dialog 
            open={isOpen} 
            onClose={() => setIsOpen(false)}
            className="relative z-40"
        >
            <DialogBackdrop
                transition
                className="fixed inset-0 bg-gray-500/75 transition-opacity data-closed:opacity-0 data-enter:duration-300 data-enter:ease-out data-leave:duration-200 data-leave:ease-in"
            />
            
            <div className="fixed inset-0 flex items-center justify-center p-4">
                <DialogPanel 
                    transition
                    className="bg-base-100 rounded-box w-11/12 max-w-5xl max-h-[100vh] p-6 overflow-y-auto shadow-2xl transform transition-all data-closed:opacity-0 data-closed:scale-95 data-enter:duration-300 data-enter:ease-out data-leave:duration-200 data-leave:ease-in"
                >
                    <div className="grid grid-cols-1 lg:grid-cols-5 gap-4 px-6">
                        <div className='col-span-full'>
                            <table className="table">
                                <tbody>
                                    <tr>
                                        <td className="font-semibold text-lg w-36">Food Name : </td>
                                        <td className="text-lg">{food?.f_name ?? food?.food_name}</td>
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
                        <button className="btn" onClick={() => setIsOpen(false)}>Close</button>
                    </div>
                </DialogPanel>
            </div>
        </Dialog>
    );
};

DetailModalComponent.propTypes = {
    food: PropTypes.object.isRequired
};

const DetailModal = forwardRef(DetailModalComponent);
DetailModal.displayName = 'DetailModal';

export default DetailModal;
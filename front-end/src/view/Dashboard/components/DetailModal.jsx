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
                    className="w-11/12 max-w-5xl bg-white rounded-lg shadow-xl transform transition-all data-closed:opacity-0 data-closed:scale-95 data-enter:duration-300 data-enter:ease-out data-leave:duration-200 data-leave:ease-in"
                >
                    <div className="p-6">
                        <div className="grid grid-cols-1 lg:grid-cols-5 gap-4">
                            <div className='col-span-full'>
                                <table className="w-full">
                                    <tbody>
                                        <tr>
                                            <td className="font-semibold text-lg w-36">Food Name : </td>
                                            <td className="text-lg">{food.name}</td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                            <div className="col-span-2">
                                <div className="border border-gray-200 rounded-lg bg-white">
                                    <div className="p-4">
                                        <h2 className="text-xl font-bold mb-4">Nutrition</h2>
                                        <div className="overflow-x-auto">
                                            <table className="w-full">
                                                <thead className="border-b">
                                                    <tr>
                                                        <th className="py-2 text-left">Name</th>
                                                        <th className="py-2 text-left">Amount</th>
                                                        <th className="py-2 text-left">Unit</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <tr className="border-b">
                                                        <td className="py-2">Energy</td>
                                                        <td className="py-2">{food.energy}</td>
                                                        <td className="py-2">kcal</td>
                                                    </tr>
                                                    <tr className="border-b">
                                                        <td className="py-2">Protein</td>
                                                        <td className="py-2">{food.protein}</td>
                                                        <td className="py-2">g</td>
                                                    </tr>
                                                    <tr className="border-b">
                                                        <td className="py-2">Fat</td>
                                                        <td className="py-2">{food.fat}</td>
                                                        <td className="py-2">g</td>
                                                    </tr>
                                                    <tr className="border-b">
                                                        <td className="py-2">Carbohydrate</td>
                                                        <td className="py-2">{food.carbohydrate}</td>
                                                        <td className="py-2">g</td>
                                                    </tr>
                                                    <tr className="border-b">
                                                        <td className="py-2">Calcium</td>
                                                        <td className="py-2">{food.calcium}</td>
                                                        <td className="py-2">mg</td>
                                                    </tr>
                                                    <tr className="border-b">
                                                        <td className="py-2">Iron</td>
                                                        <td className="py-2">{food.iron}</td>
                                                        <td className="py-2">mg</td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div className="col-span-3">
                                <div className="border border-gray-200 rounded-lg bg-white">
                                    <div className="p-4">
                                        <h2 className="text-xl font-bold mb-4">Ingredients</h2>
                                        <div className="overflow-x-auto">
                                            <table className="w-full">
                                                <thead className="border-b">
                                                    <tr>
                                                        <th className="py-2 text-left">Name</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    {food?.ingredients?.map((ingredient) => (
                                                        <tr key={ingredient} className="border-b">
                                                            <td className="py-2">{ingredient}</td>
                                                        </tr>
                                                    ))}
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div className="flex justify-end mt-6">
                            <button 
                                className="px-4 py-2 rounded-md hover:bg-gray-50"
                                onClick={() => setIsOpen(false)}
                            >
                                Close
                            </button>
                        </div>
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
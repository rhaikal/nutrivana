import { forwardRef, useState, useImperativeHandle } from 'react';
import { Dialog, DialogPanel, DialogBackdrop } from '@headlessui/react';

const GrowthModalComponent = (props, ref) => {
  const [isOpen, setIsOpen] = useState(false);
  
  useImperativeHandle(ref, () => ({
    open: () => setIsOpen(true),
    close: () => setIsOpen(false)
  }));

  const handleSubmit = (e) => {
    e.preventDefault();
    setIsOpen(false);
  };

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
          className="w-full max-w-md bg-white rounded-lg shadow-xl transform transition-all data-closed:opacity-0 data-closed:scale-95 data-enter:duration-300 data-enter:ease-out data-leave:duration-200 data-leave:ease-in"
        >
          <div className="p-6">
            <form onSubmit={handleSubmit}>
              <div className="mb-4">
                <label className="block text-sm font-medium mb-1">Weight (kg)</label>
                <div className="border border-gray-300 rounded-md px-3 py-2">
                  <input 
                    type="number" 
                    name="weight"
                    className="w-full focus:outline-none"
                    step="0.1"
                    min="0"
                    placeholder="Enter weight in kilograms"
                    required
                  />
                </div>
              </div>
              <div className="mb-4">
                <label className="block text-sm font-medium mb-1">Height (cm)</label>
                <div className="border border-gray-300 rounded-md px-3 py-2">
                  <input 
                    type="number"
                    name="height"
                    className="w-full focus:outline-none"
                    step="0.1"
                    min="0"
                    placeholder="Enter height in centimeters"
                    required
                  />
                </div>
              </div>
              <div className="flex justify-end gap-3 mt-6">
                <button 
                  type="button" 
                  className="px-4 py-2 rounded-md hover:bg-gray-50"
                  onClick={() => setIsOpen(false)}
                >
                  Cancel
                </button>
                <button 
                  type="submit" 
                  className="px-4 py-2 rounded-md bg-blue-500 text-white hover:bg-blue-600"
                >
                  Save
                </button>
              </div>
            </form>
          </div>
        </DialogPanel>
      </div>
    </Dialog>
  );
};

const GrowthModal = forwardRef(GrowthModalComponent);
GrowthModal.displayName = 'GrowthModal';

export default GrowthModal;
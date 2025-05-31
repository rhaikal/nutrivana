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
          className="bg-base-100 rounded-box w-[91.6667%] max-w-sm max-h-[100vh] p-6 overflow-y-auto shadow-2xl transform transition-all data-closed:opacity-0 data-closed:scale-95 data-enter:duration-300 data-enter:ease-out data-leave:duration-200 data-leave:ease-in"
        >
          <form onSubmit={handleSubmit}>
            <fieldset className="fieldset">
                <legend className="fieldset-legend">Weight (kg)</legend>
                <label className="input input-bordered w-full max-w-none items-center gap-2">
                    <input 
                        type="number" 
                        name="weight"
                        className="grow"
                        step="0.1"
                        min="0"
                        placeholder="Enter weight in kilograms"
                        required
                    />
                </label>
            </fieldset>
            <fieldset className="fieldset">
                <legend className="fieldset-legend">Height (cm)</legend>
                <label className="input input-bordered w-full max-w-none items-center gap-2">
                    <input 
                        type="number"
                        name="height"
                        className="grow"
                        step="0.1"
                        min="0"
                        placeholder="Enter height in centimeters"
                        required
                    />
                </label>
            </fieldset>
            <div className="modal-action">
                <button type="button" className="btn" onClick={() => setIsOpen(false)}>Cancel</button>
                <button type="submit" className="btn btn-primary">Save</button>
            </div>
          </form>
        </DialogPanel>
      </div>
    </Dialog>
  );
};

const GrowthModal = forwardRef(GrowthModalComponent);
GrowthModal.displayName = 'GrowthModal';

export default GrowthModal;
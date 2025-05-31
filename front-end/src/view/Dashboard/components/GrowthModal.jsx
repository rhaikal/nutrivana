import { forwardRef } from 'react';

const GrowthModalComponent = (props, ref) => {
  const handleSubmit = (e) => {
    e.preventDefault();
    ref.current.close();
  };

  return (
    <dialog ref={ref} className="modal">
      <div className="modal-box">
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
                <button type="button" className="btn" onClick={() => ref.current.close()}>Cancel</button>
                <button type="submit" className="btn btn-primary">Save</button>
            </div>
        </form>
      </div>
    </dialog>
  );
};

const GrowthModal = forwardRef(GrowthModalComponent);
GrowthModal.displayName = 'GrowthModal';

export default GrowthModal;
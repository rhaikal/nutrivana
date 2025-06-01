import { forwardRef, useState, useImperativeHandle, useContext, useEffect } from 'react';
import { Dialog, DialogPanel, DialogBackdrop } from '@headlessui/react';
import { useFormik } from 'formik';
import * as Yup from 'yup';
import Swal from '../../../utils/Swal';
import UserContext from '../../../contexts/UserContext';
import FormField from '../../../components/FormField';
import UserModule from '../../../modules/UserModule';

const GrowthModalComponent = (props, ref) => {
  const { user, updateGrowthRecords } = useContext(UserContext);
  const [isOpen, setIsOpen] = useState(false);
  
  useImperativeHandle(ref, () => ({
    open: () => setIsOpen(true),
    close: () => setIsOpen(false)
  }));

  const validationSchema = Yup.object({
    weight: Yup.number()
      .required('Weight is required')
      .positive('Weight must be positive')
      .max(60, 'Weight cannot exceed 60kg')
      .typeError('Weight must be a number'),
    height: Yup.number()
      .required('Height is required') 
      .positive('Height must be positive')
      .max(120, 'Height cannot exceed 120cm')
      .typeError('Height must be a number')
  });

  const formik = useFormik({
    initialValues: {
      weight: user?.growthRecords?.weight?.filter(w => w != null).slice(-1)[0] || '',
      height: user?.growthRecords?.height?.filter(h => h != null).slice(-1)[0] || ''
    },
    validationSchema: validationSchema,
    onSubmit: async (values, { setSubmitting }) => {
      Swal.fire({
        title: "Please Confirm Growth Records",
        text: "Please verify if these growth measurements are accurate before saving.",
        icon: 'warning',            
        showCancelButton: true,
        confirmButtonText: 'Save',      
      }).then((result) => {
        if (result.isConfirmed) {
          UserModule.updateGrowthRecords(values).then(() => {
            setIsOpen(false);
            updateGrowthRecords();
          })
        }
        
        setSubmitting(false);
      });
    },
    enableReinitialize: true,
  });

  useEffect(() => {
    if (!isOpen) formik.handleReset()
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isOpen])

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
          <form onSubmit={formik.handleSubmit}>
            <FormField
              label="Weight (kg)"
              type="number"
              name="weight"
              step="0.1"
              min="0"
              placeholder="Enter weight in kilograms"
              required
              onChange={formik.handleChange}
              onBlur={formik.handleBlur}
              value={formik.values.weight}
              touched={formik.touched.weight}
              error={formik.touched.weight && formik.errors.weight}
            />
            <FormField
              label="Height (cm)"
              type="number"
              name="height"
              step="0.1"
              min="0"
              placeholder="Enter height in centimeters"
              required
              onChange={formik.handleChange}
              onBlur={formik.handleBlur}
              value={formik.values.height}
              touched={formik.touched.height}
              error={formik.touched.height && formik.errors.height}
            />
            <div className="modal-action">
                <button type="button" className="btn" onClick={() => setIsOpen(false)}>Cancel</button>
                <button type="submit" className="btn btn-primary" disabled={formik.isSubmitting}>Save</button>
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

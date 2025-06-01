import PropTypes from 'prop-types';
import { Transition } from '@headlessui/react';

const Wrapper = ({ children }) => {
    return (
        <div className="min-h-screen flex items-center justify-center">
            <div className="card lg:card-side bg-base-100 shadow-xl max-w-5xl">
                <div className="lg:w-1/2 flex items-center justify-center px-5" style={{ backgroundColor: 'color-mix(in oklab, #8bc34a 40%, transparent)' }}>
                    <figure>
                        <img 
                            src="authentication.png"
                            alt="Login Illustration"
                            style={{ height: 'unset', objectFit: 'unset' }}
                        />
                    </figure>
                </div>

                <div className="card-body lg:w-1/2 p-10 self-center">
                <Transition
                        show={true} 
                        appear={true}
                        enter="transition-opacity duration-900"
                        enterFrom="opacity-0"
                        enterTo="opacity-100"
                >
                    {children}
                </Transition>
                </div>
            </div>
        </div>
    );
};

Wrapper.propTypes = {
    children: PropTypes.node.isRequired
};

export default Wrapper;
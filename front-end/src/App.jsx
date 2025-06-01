import { Routes, Route, Navigate } from "react-router-dom"
import { UserProvider } from "./contexts/UserContext"
import routes from "./utils/routes"

const GuestRoute = ({children}) => {
    const access_token = localStorage.getItem("access_token");
    return !access_token ? children : <Navigate to='/' replace />;
}

const PrivateRoute = ({children}) => {
    const access_token = localStorage.getItem("access_token");
    return access_token ? children : <Navigate to='/login' replace />;
}

function App() {
  return (
    <UserProvider>
      <Routes>
        {routes.map((route) => (
          <Route 
            key={route.path}
            path={route.path}
            element={
              route.isPrivate ? (
                <PrivateRoute>
                  <route.element />
                </PrivateRoute>
              ) : (
                <GuestRoute>
                  <route.element />
                </GuestRoute>
              )
            }
          />
        ))}
      </Routes>
    </UserProvider>
  )
}

export default App
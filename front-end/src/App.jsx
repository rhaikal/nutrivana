import { Routes, Route } from "react-router-dom"
import Dashboard from "./view/Dashboard"
import Login from "./view/Authentication/Login"
import Register from "./view/Authentication/Register"
import { UserProvider } from "./contexts/UserContext"

function App() {
  return (
    <UserProvider>
      <Routes>
        <Route path="/register" element={<Register />} />
        <Route path="/login" element={<Login />} />
        <Route path="/" element={<Dashboard />} />
      </Routes>
    </UserProvider>
  )
}

export default App

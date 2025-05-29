import Dashboard from "../view/Dashboard";
import Login from "../view/Authentication/Login";
import Register from "../view/Authentication/Register";

const routes = [
  {
    path: "/",
    element: Dashboard,
    isPrivate: true
  },
  {
    path: "/login",
    element: Login,
    isPrivate: false
  },
  {
    path: "/register",
    element: Register,
    isPrivate: false
  }
];

export default routes;
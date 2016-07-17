import React from "react"
import ReactDOM from "react-dom"
import DeploymentIndex from "./components/deployment_index"
import UserLogin from "./components/user_login"

ReactDOM.render(<DeploymentIndex/>, document.getElementById('deployments-container'));

let loginContainer = document.getElementById('login-container');
let userName = loginContainer.dataset.userName;
ReactDOM.render(<UserLogin userName={userName}/>, loginContainer);

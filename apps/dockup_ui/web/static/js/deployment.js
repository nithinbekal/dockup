import React from "react"
import ReactDOM from "react-dom"
import DeploymentForm from "./components/deployment_form"
export var run = function(){
  ReactDOM.render(<DeploymentForm />, document.getElementById('deployments_container'));
}

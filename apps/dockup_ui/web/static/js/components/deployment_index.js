import React, {Component} from 'react';
import DeploymentForm from './deployment_form';
import DeploymentList from './deployment_list';
class DeploymentIndex extends Component {
  constructor(props) {
    super(props);
    this.state = {
      deployments: []
    }
  }

  addDeployment(newDeployment) {
    let deploymentsArray = this.state.deployments;
    deploymentsArray = deploymentsArray.concat(newDeployment)
    this.setState({deployments: deploymentsArray});
  }
  render() {
    return (
      <div>
        <DeploymentForm newDeployment={this.addDeployment.bind(this)}/>
        <DeploymentList deployments={this.state.deployments}/>
      </div>
    )
  }
}
export default DeploymentIndex

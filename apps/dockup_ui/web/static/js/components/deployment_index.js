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

  adding_deployment(all_deployments) {
    this.setState({deployments: all_deployments});
  }
  render() {
    return (
      <div>
        <DeploymentForm add_deployment={this.adding_deployment.bind(this)}/>
        <DeploymentList deployments={this.state.deployments}/>
      </div>
    )
  }
}
export default DeploymentIndex

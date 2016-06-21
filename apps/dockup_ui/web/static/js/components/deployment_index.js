import React, {Component} from 'react';
import DeploymentForm from './deployment_form';
import DeploymentList from './deployment_list';

class DeploymentIndex extends Component {
  constructor(props) {
    super(props);
    this.state = {
      deployments: [],
      isGithub: true
    }
  }

  addDeployment(newDeployment) {
    let deploymentsArray = this.state.deployments;
    deploymentsArray = deploymentsArray.concat(newDeployment)
    this.setState({deployments: deploymentsArray});
  }

  handleClick(event) {
    if(this.state.isGithub == true) {
      this.setState({isGithub: false})
    } else {
      this.setState({isGithub: true});
    }
  }
  render() {
    var value;
    if(this.state.isGithub == true) {
      value = "Not using github?"
    } else {
      value = "Using github?";
    }
    return (
      <div>
        <div>
          <a onClick={this.handleClick.bind(this)}>{value}</a>
          <DeploymentForm newDeployment={this.addDeployment.bind(this)} isGithub={this.state.isGithub}/>
          <DeploymentList deployments={this.state.deployments}/>
        </div>
      </div>
    )
  }
}
export default DeploymentIndex

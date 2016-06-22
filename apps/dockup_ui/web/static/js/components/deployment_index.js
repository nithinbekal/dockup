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
    deploymentsArray.push(newDeployment);
    this.setState({deployments: deploymentsArray});
  }

  handleClick(event) {
    this.setState({isGithub: !this.state.isGithub})
  }

  render() {
    let displayLinkText;
    if(this.state.isGithub == true) {
      displayLinkText = "Not using github?"
    } else {
      displayLinkText = "Using github?";
    }
    return (
      <div>
        <div>
          <a onClick={this.handleClick.bind(this)}>{displayLinkText}</a>
          <DeploymentForm newDeployment={this.addDeployment.bind(this)} isGithub={this.state.isGithub}/>
          <DeploymentList deployments={this.state.deployments}/>
        </div>
      </div>
    )
  }
}
export default DeploymentIndex

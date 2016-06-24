import React, {Component} from 'react';
import ReactDOM from "react-dom";
import GithubComponent from './github_component';
import GenericComponent from './generic_component';

class DeploymentForm extends Component {
  constructor(props) {
    super(props);
    this.state = {
      username: "",
      repository: "",
      url: "",
      branch: ""
    }
    this.handleUserNameChange = this.handleUserNameChange.bind(this);
    this.handleRepositoryChange = this.handleRepositoryChange.bind(this);
    this.handleClick = this.handleClick.bind(this);
    this.handleUrlChange = this.handleUrlChange.bind(this);
    this.handleBranchChange = this.handleBranchChange.bind(this);
  }

  displayHelpText() {
    if (!this.state.username || !this.state.repository || !this.state.branch) {
      return "Please enter a github project and branch to deploy";
    }
    if ((this.props.isGithub == false) && (isAnyFieldEmpty(!this.state.url, !this.state.branch))) {
      return "Please enter a project url and branch to deploy";
    }
    return displayDeployMessage(this.props, this.state);
  }

  handleClick(e) {
    const newElement = {name: `${this.state.username}/${this.state.repository}`,
                        logs: '111',
                        url: "http://one.com"};
    this.props.newDeployment(newElement);
  }

  handleUrlChange(url) {
    this.setState({url: url});
  }

  handleBranchChange(event) {
    this.setState({branch: event.target.value});
  }

  handleUserNameChange(username) {
    this.setState({username: username});
  }

  handleRepositoryChange(repository) {
    this.setState({repository: repository});
  }


  render() {
    return (
      <div>
      { this.props.isGithub ? <GithubComponent username={this.handleUserNameChange}
        repository={this.handleRepositoryChange} /> : <GenericComponent
        url={this.handleUrlChange}  />}
      <br />
      <b>
      Branch :
        </b>
        <input name="branch" class="form-control" onChange={this.handleBranchChange} className="form-control" />
        <div>{this.displayHelpText()}</div>
        <button name="deploy" onClick={this.handleClick} disabled={(!this.state.username || !this.state.repository)} className="btn btn-primary">Deploy</button>
        </div>
    )
  }
}
const isAnyFieldEmpty = function(field1, field2) {
  return (field1 || field2);
}
const displayDeployMessage = function(props, state) {
  if ((props.isGithub == false) && isAnyFieldEmpty(state.url, state.branch)) {
    return `Click the Deploy button to deploy ${state.url} with branch: ${state.branch}`
  }
  return `Click the Deploy button to deploy https://github.com/${state.username}/${state.repository} with branch: ${state.branch}`;
}
export default DeploymentForm

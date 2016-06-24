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
    } else if ((this.props.isGithub == false) && (isAnyFieldEmpty(!this.state.url, !this.state.branch))) {
      return "Please enter a project url and branch to deploy";
    } else {
      return displayDeployMessage(this.props.isGithub, isAnyFieldEmpty(this.state.url,
                                                                       this.state.branch),
                                                                       this.state.url,
                                                                       this.state.branch,
                                                                       this.state.username,
                                                                       this.state.repository);
    }
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
const displayDeployMessage = function(isGithub, isAnyFieldEmpty, url, branch, username, repository) {
  if ((isGithub == false) && isAnyFieldEmpty) {
    return `Click the Deploy button to deploy ${url} with branch: ${branch}`
  } else {
    return `Click the Deploy button to deploy https://github.com/${username}/${repository} with branch: ${branch}`;
  }
}
export default DeploymentForm

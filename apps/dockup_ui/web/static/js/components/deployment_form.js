import React, {Component} from 'react';
import ReactDOM from "react-dom";

class DeploymentForm extends Component {
  constructor(props) {
    super(props);
    this.state = {
      username: "",
      repository: "",
      deployments: []
    }
  }

  handleUserNameChange(event) {
    this.setState({username: event.target.value});
  }

  handleRepositoryChange(event) {
    this.setState({repository: event.target.value});
  }

  displayHelpText() {
    if (!this.state.username || !this.state.repository) {
      return "Please enter a github project to deploy";
    } else {
      return `Click the Deploy button to deploy https://github.com/${this.state.username}/${this.state.repository}`;
    }
  }

  handleClick(e) {
    const newElement = {name: `${this.state.username}/${this.state.repository}`, logs: '111', url: "http://one.com"};
    this.props.newDeployment(newElement);
  }

  render() {
    return (
      <div>https://github.com/
        <input name="username" onChange={this.handleUserNameChange.bind(this)}/>/
        <input name="repository" onChange={this.handleRepositoryChange.bind(this)} />
        <button name="deploy" onClick={this.handleClick.bind(this)} disabled={(!this.state.username || !this.state.repository)}>Deploy</button>
        <br />
        <div>{this.displayHelpText()}</div>
        <br/>
      </div>
    )
  }
}
export default DeploymentForm

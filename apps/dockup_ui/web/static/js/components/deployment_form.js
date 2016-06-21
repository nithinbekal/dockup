import React, {Component} from 'react';
import ReactDOM from "react-dom";

class DeploymentForm extends Component {
  constructor(props) {
    super(props);
    this.state = {
      username: "",
      repository: "",
      url: "",
      branch: ""
    }
  }

  handleUserNameChange(event) {
    this.setState({username: event.target.value});
  }

  handleRepositoryChange(event) {
    this.setState({repository: event.target.value});
  }

  displayHelpText() {
    if (!this.state.username || !this.state.repository || !this.state.branch) {
      return "Please enter a github project and branch to deploy";
    } else if ((this.props.isGithub == false) && (!this.state.url || !this.state.branch)){
      return "Please enter a project url and branch to deploy";
    } else {
      if ((this.props.isGithub == false) && (this.state.url || this.state.branch)){
        return `Click the Deploy button to deploy ${this.state.url} with branch: ${this.state.branch}`
      }
      return `Click the Deploy button to deploy https://github.com/${this.state.username}/${this.state.repository} with branch: ${this.state.branch}`;
    }
  }

  handleClick(e) {
    const newElement = {name: `${this.state.username}/${this.state.repository}`, logs: '111', url: "http://one.com"};
    this.props.newDeployment(newElement);
  }

  handleUrlChange(event) {
    this.setState({url: event.target.value});
  }

  handleBranchChange(event) {
    this.setState({branch: event.target.value});
  }

  render() {
    var partial;
    if(this.props.isGithub == true) {
      partial = <div className="col-md-12">
                  <table>
                    <tbody>
                      <tr>
                        <td>
                          <b> https://github.com/ </b>
                        </td>
                        <td>
                          <input name="username" onChange={this.handleUserNameChange.bind(this)} className="form-control"/>
                        </td>
                        <td>
                          <b>/</b>
                        </td>
                        <td>
                          <input name="repository" onChange={this.handleRepositoryChange.bind(this)} className="form-control"/>
                        </td>
                        <td>
                          <b>.git</b>
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>
    } else {
      partial = <div>
                  Url :<input name="url" onChange={this.handleUrlChange.bind(this)} className="form-control"/>
                </div>
    }
    return (
      <div>
        {partial}
        <br />
        <b>
          Branch :
        </b>
        <br />
        <input name="branch" class="form-control" onChange={this.handleBranchChange.bind(this)} className="form-control" />
        <br />
        <div>{this.displayHelpText()}</div>
        <button name="deploy" onClick={this.handleClick.bind(this)} disabled={(!this.state.username || !this.state.repository)} className="btn btn-primary">Deploy</button>
        <br/>
      </div>
    )
  }
}
export default DeploymentForm

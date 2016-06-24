import React, {Component} from 'react';

class GithubComponent extends Component {
  constructor(props) {
    super(props);
    this.handleUserNameChange = this.handleUserNameChange.bind(this);
    this.handleRepositoryChange = this.handleRepositoryChange.bind(this);

  }

  handleUserNameChange(event) {
    this.props.username(event.target.value);
  }

  handleRepositoryChange(event) {
    this.props.repository(event.target.value);
  }


  render() {
    return (
      <div className="col-md-12">
        <table>
          <tbody>
            <tr>
              <td>
                <b> https://github.com/ </b>
              </td>
              <td>
                <input name="username" onChange={this.handleUserNameChange} className="form-control"/>
              </td>
              <td>
                <b>/</b>
              </td>
              <td>
                <input name="repository" onChange={this.handleRepositoryChange} className="form-control"/>
              </td>
              <td>
                <b>.git</b>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    )
  }
}

export default GithubComponent

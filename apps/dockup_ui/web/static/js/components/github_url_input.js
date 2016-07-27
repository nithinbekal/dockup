import React, {Component} from 'react';


class GithubUrlInput extends Component {
  constructor(props) {
    super(props);
    this.state = {
      org: "",
      repository: ""
    };
  }

  handleOrgChange(event) {
    let org = event.target.value;
    this.setState({org: org});
    this.updateUrl(org, this.state.repository);
  }

  handleRepositoryChange(event) {
    let repository = event.target.value;
    this.setState({repository: repository});
    this.updateUrl(this.state.org, repository);
  }

  updateUrl(org, repo) {
    this.props.onUrlChange(`https://github.com/${org}/${repo}`);
  }

  render() {
    return(
      <div className="form-group">
        <label>Github Project URL</label>
        <small className="github-swap-link"><a onClick={() => {this.props.onUrlTypeChange("generic")}}>Not using Github?</a></small>
        <div className="vertical-align">
          <div className="input-group">
            <div className="input-group-addon">https://github.com/</div>
            <input type="text" className="form-control" onChange={this.handleOrgChange.bind(this)}/>
            <div className="input-group-addon remove-lr-border">/</div>
            <input type="text" className="form-control" onChange={this.handleRepositoryChange.bind(this)}/>
            <div className="input-group-addon">.git</div>
          </div>
        </div>
      </div>
    )
  }
}

export default GithubUrlInput;

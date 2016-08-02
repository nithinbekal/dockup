import React, {Component} from 'react';

class DeploymentList extends Component {
  constructor(props) {
    super(props);
    this.state = {
      deployments: []
    }
    this.getDeployments();
    this.connectToDeploymentsChannel();
  }

  getDeployments() {
    let xhr = new XMLHttpRequest();
    xhr.open('GET', '/api/deployments');
    xhr.onload = () => {
      if (xhr.status === 200) {
        this.setState({deployments: JSON.parse(xhr.responseText).data});
      }
    };
    xhr.send();
  }

  updateDeploymentStatus(id, status, payload) {
    let found = false;
    let newDeployments = this.state.deployments.map((deployment) => {
      if(deployment.id == id) {
        deployment.status = status;
        if(status == "checking_urls" || status == "started") {
          deployment.urls = payload;
        } else if(status == "deployment_failed") {
          deployment.urls = null;
        } else if(status == "starting") {
          deployment.logUrl = payload.log_url;
        }
        found = true;
      }
      return deployment;
    })

    if(found) {
      this.setState({deployments: newDeployments})
    }
  }

  addDeployment(deployment) {
    this.setState({deployments: this.state.deployments.concat(deployment)});
  }

  renderDeploymentUrls(urls) {
    if(urls) {
      let urlText = Object.keys(urls).map((key, index) =>{
        return(
          <div key={index}>
            <div>
              {key} :
              {urls[key].map((map, index) => {
                return(
                    <a key={index} href={map.url}>Port {map.port}</a>
                )
              })}
            </div>
          </div>
        )
      })
      return urlText;
    } else {
      return "-";
    }
  }

  renderLogUrl(url) {
    if(url) {
      return <a href={url} target="_blank">Open</a>;
    } else {
      return "-";
    }
  }

  connectToDeploymentsChannel() {
    let channel = DockupUiSocket.getDeploymentsChannel();
    channel.on("status_updated", ({deployment, payload}) => {
      this.updateDeploymentStatus(deployment.id, deployment.status, payload);
    })

    channel.on("deployment_created", (deployment) => {
      this.addDeployment(deployment);
    })
  }

  render() {
    return (
      <div>
        <table className="table">
          <caption>Deployments</caption>
          <thead>
            <tr>
              <th>#</th>
              <th>Git URL</th>
              <th>Branch</th>
              <th>Status</th>
              <th>URLs</th>
              <th>Logs</th>
            </tr>
          </thead>
          <tbody>
            {this.state.deployments.map((deployment) => {
              return (
                <tr key={deployment.id}>
                  <td>{deployment.id}</td>
                  <td>{deployment.git_url}</td>
                  <td>{deployment.branch}</td>
                  <td>{deployment.status}</td>
                  <td>{this.renderDeploymentUrls(deployment.urls)}</td>
                  <td>{this.renderLogUrl(deployment.logUrl)}</td>
                </tr>
              )
             })}
          </tbody>
        </table>
      </div>
    )
  }
}

export default DeploymentList

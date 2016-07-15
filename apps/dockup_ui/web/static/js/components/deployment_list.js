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

  updateDeploymentStatus(id, status) {
    let found = false;
    let newDeployments = this.state.deployments.map((deployment) => {
      if(deployment.id == id) {
        deployment.status = status;
        found = true;
      }
      return deployment;
    })

    if(found) {
      this.setState({deployments: newDeployments})
    }
  }

  addDeployment(deployment) {
    // TODO
  }

  connectToDeploymentsChannel() {
    let channel = DockupUiSocket.getDeploymentsChannel();
    channel.on("update_status", ({id, status}) => {
      this.updateDeploymentStatus(id, status);
    })

    channel.on("new_deployment", (deployment) => {
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

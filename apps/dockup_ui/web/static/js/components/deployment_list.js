import React from 'react';
const DeploymentList = (props) => {
  return (
    <div>Deployments
      <table>
        <thead>
          <tr>
            <th> Name</th>
            <th> Log</th>
            <th> Url</th>
          </tr>
        </thead>
        <tbody>
        {props.deployments.map((deployment, i) => {
          return (
            <tr key={i}>
              <td key="a">{deployment.name}</td>
              <td key="b">{deployment.logs}</td>
              <td key="c">{deployment.url}</td>
            </tr>
          )})}
        </tbody>
      </table>
    </div>
  )
}

DeploymentList.propTypes = { deployments: React.PropTypes.array.isRequired };
DeploymentList.defaultProps = { deployments: [{name: "Repo 1", logs: "111", url: "http://one.com"}] };
export default DeploymentList

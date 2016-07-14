import React from 'react';

const GitUrlInput = (props) => {
  return (
    <div className="form-group">
      <label htmlFor="git-url">Git Url</label>
      <small className="github-swap-link"><a onClick={() => {props.onUrlTypeChange("github")}}>Using Github?</a></small>
      <input className="form-control" id="git-url" onChange={(e) => {props.onUrlChange(e.target.value)}} className="form-control"/>
    </div>
  )
}
export default GitUrlInput

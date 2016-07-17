import React from 'react';

let renderUserLogin = (userName) => {
  if(userName) {
    return(<div className="navbar-text">Hello, {userName}</div>)
  } else {
    return(
      <a href="/oauth/github">
        Sign in with GitHub
      </a>
    )
  }
}

const UserLogin = ({userName}) => {
  return(
    renderUserLogin(userName)
  )
}

export default UserLogin

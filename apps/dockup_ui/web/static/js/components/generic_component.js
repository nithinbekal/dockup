import React, {Component} from 'react';

class GenericComponent extends Component {

  constructor(props) {
    super(props);
    this.handleUrlChange = this.handleUrlChange.bind(this);
  }

  handleUrlChange(event) {
    this.props.url(event.target.value);
  }

  render() {
    return (
      <div>
        Url :<input name="url" onChange={this.handleUrlChange} className="form-control"/>
      </div>
    )
  }
}
export default GenericComponent

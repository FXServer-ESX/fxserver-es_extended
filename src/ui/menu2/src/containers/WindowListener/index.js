import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';

class WindowListener extends React.Component {
  componentWillMount() {
    window.addEventListener('message', this.handleEvent);
  }

  componentWillUnmount() {
    window.removeEventListener('message', this.handleEvent);
  }

  handleEvent = event => {
    const { dispatch } = this.props;
    const { type, data } = event.data;
    dispatch({ type, payload: { ...data } });
  };

  render() {
    return React.Children.only(this.props.children);
  }
}

WindowListener.propTypes = {
  dispatch: PropTypes.func.isRequired,
  children: PropTypes.element.isRequired,
};

export default connect(
  null,
  null,
)(WindowListener);

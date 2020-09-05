import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';

import styled from 'styled-components';

import GlobalStyle from '../../globalStyles';

const H1 = styled('h1')`
  font-family: Pricedown;
  visibility: ${props => props.hidden};
`;

const App = ({ hidden }) => (
  <div>
    <H1 hidden={hidden}>Hello world</H1>
    <GlobalStyle />
  </div>
);

App.propTypes = {
  hidden: PropTypes.bool.isRequired,
};

const mapStateToProps = state => ({ hidden: state.app.hidden });

export default connect(mapStateToProps)(App);

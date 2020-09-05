import { combineReducers } from 'redux';

import appReducer from 'containers/App/reducer';

export default () =>
  combineReducers({
    app: appReducer,
  });

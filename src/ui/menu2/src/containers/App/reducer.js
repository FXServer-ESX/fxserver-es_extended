export const initialState = {
  hidden: true,
};

const appReducer = (state = initialState, action) => {
  switch (action.type) {
    case 'APP_SHOW':
      return Object.assign({}, state, { hidden: false });
    case 'APP_HIDE':
      return Object.assign({}, state, { hidden: true });
    default:
      return state;
  }
};

export default appReducer;

import {OPTIONS_UI_SPEED_CHANGED} from '../constants';

const initialState = {
  value: 1.2,
};

const speed = (state = initialState, action) => {
  switch (action.type) {
    case OPTIONS_UI_SPEED_CHANGED:
      return {
        ...state,
        value: action.speed,
      };
    default:
      return state;
  }
}

export default speed
import * as types from '../constants';

export const mainSideChanged = (event, value) => {
  return {
    type: types.OPTIONS_UI_SIDE_CHANGED,
    main_side: value,
  };
}

export const pauseChanged = (event, value) => {
  return {
    type: types.OPTIONS_UI_PAUSE_CHANGED,
    pause: value,
  };
}
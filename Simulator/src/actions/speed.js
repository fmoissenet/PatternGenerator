import * as types from '../constants';

export const gaitSpeedChanged = (value) => {
  return {
    type: types.OPTIONS_UI_SPEED_CHANGED,
    speed: value,
  };
}
import {OPTIONS_UI_PAUSE_CHANGED, OPTIONS_UI_SIDE_CHANGED} from '../constants';

const initialState = {
  playback: true,
  main_side: 'right'
};

const settings = (state = initialState, action) => {
  switch (action.type) {
    case OPTIONS_UI_PAUSE_CHANGED:
      return {
        ...state,
        playback: !action.pause,
      };
    case OPTIONS_UI_SIDE_CHANGED:
      return {
        ...state,
        main_side: action.main_side,
      };
    default:
      return state;
  }
}

export default settings

import {OPTIONS_UI_CONTRACTURE_TYPE_CHANGED, OPTIONS_UI_CONTRACTURE_MUSCLE_CHANGED, OPTIONS_UI_CONTRACTURE_SEVERITY_CHANGED} from '../constants';

const initialState = {
  type: 'bilateral',
  muscle : 0, // 'Gastrocnemius'
  severity: undefined
};

const contracture = (state = initialState, action) => {
  switch (action.type) {
    case OPTIONS_UI_CONTRACTURE_TYPE_CHANGED:
      return {
        ...state,
        type: action.contracture_type,
      };
    case OPTIONS_UI_CONTRACTURE_MUSCLE_CHANGED:
      return {
        ...state,
        muscle: action.contracture_muscle,
        severity: undefined
      };
    case OPTIONS_UI_CONTRACTURE_SEVERITY_CHANGED:
      return {
        ...state,
        severity: action.contracture_severity,
      };
    default:
      return state;
  }
}

export default contracture
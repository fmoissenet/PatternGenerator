import * as types from '../constants';

export const contractureTypeChanged = (event, value) => {
  return {
    type: types.OPTIONS_UI_CONTRACTURE_TYPE_CHANGED,
    contracture_type: value,
  };
}

export const contractureMuscleChanged = (event, index, value) => {
  return {
    type: types.OPTIONS_UI_CONTRACTURE_MUSCLE_CHANGED,
    contracture_muscle: value,
  };
}

export const contractureSeverityChanged = (value) => {
  return {
    type: types.OPTIONS_UI_CONTRACTURE_SEVERITY_CHANGED,
    contracture_severity: value,
  };
}
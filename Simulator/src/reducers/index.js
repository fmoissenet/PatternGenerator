import { combineReducers } from 'redux'

import contracture from './contracture'
import settings from './settings'
import speed from './speed'

export default combineReducers({
  contracture,
  settings,
  speed,
})

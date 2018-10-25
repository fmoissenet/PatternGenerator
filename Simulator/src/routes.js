import React from 'react'
import { Router, Route, IndexRoute, browserHistory } from 'react-router'

import App from './containers/App'
import ContracturesPage from './containers/ContracturesPage'
import SpeedPage from './containers/SpeedPage'
import NoMatch from './components/NoMatch'

const Routes = props => {
  return (
    <Router history={browserHistory}>
      <Route path="/" component={App}>
        <IndexRoute component={ContracturesPage}/>
        <Route path="extras/gait_speed" component={SpeedPage}/>
        <Route path="*" component={NoMatch}/>
      </Route>
    </Router>
  )
}

export default Routes

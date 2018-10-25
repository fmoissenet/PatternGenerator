import React from 'react'
import ReactDOM from 'react-dom'
import { Provider } from 'react-redux'
import configureStore from './store'
import './index.css'

import Routes from './routes'

// Let the reducers handle initial state
const initialState = {}
const store = configureStore(initialState)

// ReactDOM.render(
//   <Provider store={store}>
//     <Routes />
//   </Provider>
// , document.getElementById('root')
// )

const render = (Component) => {
  return ReactDOM.render(
    <Provider store={store}>
        <Component/>
    </Provider>,
    document.getElementById('root')
  );
};

render(Routes);

// Does it work?
// if (module.hot) {
//   module.hot.accept('./Routes', () => {
//     const NextApp = require('./Routes').default;
//     render(NextApp);
//   });
// }
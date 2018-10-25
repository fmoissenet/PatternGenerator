import React, { Component } from 'react'
import {pink500, pink700} from 'material-ui/styles/colors'
import MuiThemeProvider from 'material-ui/styles/MuiThemeProvider'
import getMuiTheme from 'material-ui/styles/getMuiTheme'
import injectTapEventPlugin from 'react-tap-event-plugin'

// Needed for onTouchTap
// http://stackoverflow.com/a/34015469/988941
injectTapEventPlugin()

// This replaces the textColor value on the palette
// and then update the keys for each component that depends on it.
// More on Colors: http://www.material-ui.com/#/customization/colors
const muiTheme = getMuiTheme({
  palette: {
    primary1Color: pink500,
    primary2Color: pink700,
  },
  appBar: {
    height: 50,
  },
});

class App extends Component {
  
  render() {
    return (
      <MuiThemeProvider muiTheme={muiTheme}>
      {this.props.children}
      </MuiThemeProvider>
    )
  }
  
}

export default App

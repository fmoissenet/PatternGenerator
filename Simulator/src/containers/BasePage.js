import React, { Component } from 'react'

import ActionInfo from 'material-ui/svg-icons/action/info';
import AppBar from 'material-ui/AppBar';
import Drawer from 'material-ui/Drawer';
import IconButton from 'material-ui/IconButton';
import List from 'material-ui/List';
import NavigationClose from 'material-ui/svg-icons/navigation/close';
import {RadioButton, RadioButtonGroup} from 'material-ui/RadioButton';
import Subheader from 'material-ui/Subheader';
import Toggle from 'material-ui/Toggle';

import ChartPanel from "./ChartPanel"
import ScenePanel from "./ScenePanel"
import logo from './unige-logo.svg'

import InfoDialog from "../components/InfoDialog"
import './BasePage.css'

const drawerWidth=200;

const updateAnimationContent = (x) => {
  if (x.gaitInc < 0)  {
    x.gaitInc = 100;
  } else if (x.gaitInc > 100) {
    x.gaitInc = 0;
  }
  x.refs.scene.select(x.gaitInc);
  x.refs.chart.getWrappedInstance().select(x.state.currentFrameVisible ? x.gaitInc : -1);
};

class BasePage extends Component {
  
  constructor(props) {
    super(props);
    this.handleToggleDrawer = this.handleToggleDrawer.bind(this)
    this.state = {
      drawerDocked: true,
      sceneVisible: true,
      chartsVisible: true,
      currentFrameVisible: false,
      drawerOpen: true,
      infoDialogOpen: false
    };
    this.settingsOptions = null;
    this.data = undefined
    this.lastFrameTime = undefined;
    this.stepTime = undefined;
    this.gaitInc = 0;
    this.styles = {
      // Settings
      settings: {
        textAlign: 'center',
        flex: 'none'
      },
      innerdrawer: {
        padding: 10,
        flex: '1',
        overflow: 'auto' 
      },
      list: {
        padding: 0
      },
      subheader: {
        paddingLeft: 0
      },
      containerdrawerdocked: {
        borderWidth: 0,
        borderRightWidth: 1,
        borderRightColor: this.props.muiTheme.palette.borderColor,
        borderStyle:'solid',
        display: 'flex',
        flexDirection: 'column'
      },
      containerdrawerundocked: {
        display: 'flex',
        flexDirection: 'column'
      },
      toggle: {
        marginBottom: 8,
      },
      radioButton: {
        marginBottom: 8,
      },
      // Central content
      centralcontainer: {
      },
    }
    
  }
  
  handleToggleScene = (checked) => {
    let scene_visible = !this.state.sceneVisible;
    let chart_visible = this.state.chartsVisible;
    if ((!scene_visible && !chart_visible) || !this.state.drawerDocked)
      chart_visible = !chart_visible;
    let currentPauseState = !this.props.playback;
    this.props.settingsActions.pauseChanged(null, true);
    this.setState({sceneVisible: scene_visible, chartsVisible: chart_visible});
    setTimeout(() => {
      this.refs.scene.updateSizeState();
      this.refs.chart.getWrappedInstance().resize(this.refs.chartContainer.offsetWidth);
      this.props.settingsActions.pauseChanged(null, currentPauseState);
    }, 50);
  }
  
  handleToggleChart = (checked) => {
    let scene_visible = this.state.sceneVisible;
    let chart_visible = !this.state.chartsVisible;
    if ((!scene_visible && !chart_visible) || !this.state.drawerDocked)
      scene_visible = !scene_visible;
    let currentPauseState = !this.props.playback;
    this.props.settingsActions.pauseChanged(null, true);
    this.setState({sceneVisible: scene_visible, chartsVisible: chart_visible});
    setTimeout(() => {
      this.refs.scene.updateSizeState();
      this.refs.chart.getWrappedInstance().resize(this.refs.chartContainer.offsetWidth);
      this.props.settingsActions.pauseChanged(null, currentPauseState);
    }, 50);
  }
  
  handleToggleDrawer = () => {
    let currentPauseState = !this.props.playback;
    this.props.settingsActions.pauseChanged(null, true);
    this.setState({drawerOpen: !this.state.drawerOpen});
    setTimeout(() => {
      this.props.settingsActions.pauseChanged(null, currentPauseState);
    }, 300);
    let timer = setInterval(() => {
      this.refs.scene.updateSizeState();
      this.refs.chart.getWrappedInstance().resize(this.refs.chartContainer.offsetWidth);
    }, 75);
    setTimeout(() => {
      clearInterval(timer);
      if (currentPauseState)
        this.refs.chart.getWrappedInstance().select(this.gaitInc);
    }, 450)
  }

  handleToggleInfoDialog = () => this.setState({infoDialogOpen: !this.state.infoDialogOpen});
  
  handleCloseInfoDialog = () => this.setState({infoDialogOpen: false});
  
  handleResizeStates = () => {
    if (window.innerWidth < 800) {
      let sceneVisible = true;
      let chartsVisible = false;
      if (!this.state.sceneVisible && this.state.chartsVisible) {
        sceneVisible = false;
        chartsVisible = true;
      }
      this.setState({
        drawerDocked: false,
        drawerOpen: false,
        sceneVisible: sceneVisible,
        chartsVisible: chartsVisible
      });
    } else {
      this.setState({
        drawerDocked: true,
        drawerOpen: (this.state.drawerDocked ? this.state.drawerOpen : true)
      });
    }
  };
  
  handleResize = () => {
    this.handleResizeStates();
    this.refs.scene.updateSizeState();
    this.refs.chart.getWrappedInstance().resize(this.refs.chartContainer.offsetWidth);
  };
  
  handlePauseChanged = (event, value) => {
    setTimeout(() => {
      this.props.settingsActions.pauseChanged(event, value);
    }, 50)
  }
  
  handleCurrentFrameChanged = (event, value) => {
    setTimeout(() => {
      this.setState( {currentFrameVisible: value} );
      updateAnimationContent(this);
    }, 50)
  }
  
  handleKeyDown = (event) => {
    // Only in pause mode
    if (this.props.playback) {
      return;
    }
    // Right arrow
    if (event.keyCode === 39) {
      this.gaitInc += 1;
      updateAnimationContent(this);
    }
    // Left arrow
    else if (event.keyCode === 37) {
      this.gaitInc -= 1;
      updateAnimationContent(this);
    }
  }
  
  tickTime() {
    let newFrameTime = Date.now();
    let delta = (newFrameTime-this.lastFrameTime) / 1000;
    if (delta > this.stepTime)
    {
      let inc = Math.floor(delta / this.stepTime);
      this.gaitInc += inc;
      this.lastFrameTime = Date.now();
    }
  }
  
  componentWillMount() {
    if (typeof window !== 'undefined') {
      this.handleResizeStates();
    }
  }
  
  componentDidMount() {
    let ticker = (x) => {
      if (x.props.playback) {
        x.tickTime();
        updateAnimationContent(x)
      }
      x.refs.scene.updateScene();
      window.requestAnimationFrame(() => ticker(x));
    };
    window.addEventListener('resize', this.handleResize);
    this.handleResize();
    this.lastFrameTime = Date.now();
    ticker(this);
  }

  componentWillUnmount() {
    window.removeEventListener('resize', this.handleResize);
  }
  
  render() {
    let centralcontent_style = {
      transition: 'margin-left 450ms cubic-bezier(0.23, 1, 0.32, 1)',
      marginLeft: (this.state.drawerOpen ? drawerWidth : 0),
    }
    if (!this.state.drawerDocked) {
      centralcontent_style.transition = undefined;
      centralcontent_style.marginLeft = undefined;
    }
    let scene_style = {
      float: 'left',
      height: '100vh',
    };
    let charts_style = {
      float: 'left',
    };
    if (this.state.sceneVisible && this.state.chartsVisible) {
      scene_style.width = '50%';
      scene_style.display = 'inline';
      charts_style.width = '50%';
      charts_style.display = 'inline';
    } else if (this.state.sceneVisible) {
      scene_style.width = '100%';
      scene_style.display = 'inline';
      charts_style.width = '0%';
      charts_style.display = 'none';
    } else if (this.state.chartsVisible) {
      scene_style.width = '0%';
      scene_style.display = 'none';
      charts_style.width = '100%';
      charts_style.display = 'inline';
    }
    let zdepth = (this.state.drawerDocked ? 0 : undefined);
    let containerdrawer = (this.state.drawerDocked ? this.styles.containerdrawerdocked : this.styles.containerdrawerundocked);
    return (
      <div tabIndex="0" onKeyDown={ this.handleKeyDown }>
        <Drawer
          docked={ this.state.drawerDocked } zDepth={ zdepth }
          width={ drawerWidth }
          open={ this.state.drawerOpen }
          onRequestChange={ (open) => this.setState({drawerOpen: open}) }
          containerStyle={ containerdrawer }
        >
          <AppBar
            title="Settings"
            showMenuIconButton={ false }
            style={ this.styles.settings }
            iconElementRight={ <IconButton><NavigationClose /></IconButton> }
            onRightIconButtonTouchTap={ this.handleToggleDrawer }
          />
          <div style={this.styles.innerdrawer}>
            <List style={this.styles.list}>
              <Subheader style={this.styles.subheader}>User interface</Subheader>
              <Toggle
                label="Scene"
                toggled={ this.state.sceneVisible }
                onToggle={ (checked) => this.handleToggleScene(checked)}
                style={this.styles.toggle}
              />
              <Toggle
                label="Charts"
                toggled={ this.state.chartsVisible }
                onToggle={ (checked) => this.handleToggleChart(checked)}
                style={this.styles.toggle}
              />
            </List>
            <List style={this.styles.list}>
              <Subheader style={this.styles.subheader}>Playback</Subheader>
              <Toggle
                label="Pause"
                style={this.styles.toggle}
                onToggle={ this.handlePauseChanged }
              />
              <Toggle
                label="Current frame"
                style={this.styles.toggle}
                onToggle={ this.handleCurrentFrameChanged }
              />
            </List>
            <List style={this.styles.list}>
              <Subheader style={this.styles.subheader}>Main side</Subheader>
              <RadioButtonGroup name="mainSide" defaultSelected="right" onChange={ this.props.settingsActions.mainSideChanged }>
                <RadioButton
                  value="right"
                  label="Right"
                className="radioButtonRight"
                  style={this.styles.radioButton}
                  iconStyle={{fill: '#0c2476'}}
                />
                <RadioButton
                  value="left"
                  label="Left"
                  className="radioButtonLeft"
                  style={this.styles.radioButton}
                  iconStyle={{fill: '#ff5a5a'}}
                />
              </RadioButtonGroup>
            </List>
            { this.settingsOptions }
          </div>
        </Drawer>
        <div style={centralcontent_style}>
          <AppBar
            onLeftIconButtonTouchTap={this.handleToggleDrawer}
            onRightIconButtonTouchTap={this.handleToggleInfoDialog}
            title={<img src={logo} height={40} style={{marginTop:3}} alt="Logo" />}
            iconElementRight={<IconButton><ActionInfo /></IconButton>}
          />
          <div style={this.styles.centralcontainer}>
            <div style={ scene_style } >
              <ScenePanel ref='scene' data={ this.data } skeleton={ this.skeleton }/>
            </div>
            <div ref="chartContainer" style={ charts_style } >
              <ChartPanel ref='chart' data={ this.data } />
            </div>
          </div>
        </div>
        <InfoDialog
          open={this.state.infoDialogOpen}
          onRequestClose={this.handleCloseInfoDialog}
        />
      </div>
    )
  }
}

export default BasePage;

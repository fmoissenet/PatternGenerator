import React from 'react'
import BasePage from './BasePage'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'

import List from 'material-ui/List';
import muiThemeable from 'material-ui/styles/muiThemeable';
import Subheader from 'material-ui/Subheader';

import SliderTextControlled from "../components/SliderTextControlled"

import * as settingsActions from '../actions/settings'
import * as speedActions from '../actions/speed'

import data_gait_speed from '../jsons/data_gait_speed.json';
import skeleton from '../jsons/lowerbody.json';

const speed_min = 0.5;
const speed_max = 2.0;

class SpeedPage extends BasePage {
  
  constructor(props) {
    super(props);
    this.skeleton = skeleton;
    this.updateGaitData(this.props.gait_speed);
    this.settingsOptions = 
      <List style={this.styles.list}>
        <Subheader style={this.styles.subheader}>Gait speed (m/s)</Subheader>
        <SliderTextControlled
          min={ speed_min }
          max={ speed_max }
          step={0.1}
          defaultValue={1.2}
          onChange={this.props.speedActions.gaitSpeedChanged}
        />

      </List>
  }
  
  componentWillReceiveProps(nextProps) {
    if (this.props.gait_speed === nextProps.gait_speed)
       return;
    this.updateGaitData(nextProps.gait_speed);
  }
  
  updateGaitData(value) {
    let index = Math.floor((value - speed_min) * 10);
    // NOTE: The pelvis data are inverted for a reason of clinical interpretation (see issue #21).
    this.data = {
      left_thorax: [],
      left_pelvis: data_gait_speed.Left_Pelvis[index].map((x) => {return -1.0 * x}),
      left_hip: data_gait_speed.Left_Hip[index],
      left_knee: data_gait_speed.Left_Knee[index],
      left_ankle: data_gait_speed.Left_Ankle[index],
      right_thorax: [],
      right_pelvis: data_gait_speed.Right_Pelvis[index].map((x) => {return -1.0 * x}),
      right_hip: data_gait_speed.Right_Hip[index],
      right_knee: data_gait_speed.Right_Knee[index],
      right_ankle: data_gait_speed.Right_Ankle[index],
    }
    this.stepTime = data_gait_speed.Duration[index] / 101;
  }
}

const mapStateToProps = state => ({
  gait_speed: state.speed.value,
  playback: state.settings.playback,
})

const mapDispatchToProps = dispatch => ({
  speedActions: bindActionCreators(speedActions, dispatch),
  settingsActions: bindActionCreators(settingsActions, dispatch),
})

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(muiThemeable()(SpeedPage))

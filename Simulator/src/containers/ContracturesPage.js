import React from 'react'
import BasePage from './BasePage'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'

import DropDownMenu from 'material-ui/DropDownMenu'
import List from 'material-ui/List'
import MenuItem from 'material-ui/MenuItem'
import muiThemeable from 'material-ui/styles/muiThemeable'
import {RadioButton, RadioButtonGroup} from 'material-ui/RadioButton'
import Subheader from 'material-ui/Subheader'

import SliderTextControlled from "../components/SliderTextControlled"

import * as settingsActions from '../actions/settings'
import * as contractureActions from '../actions/contracture'

import data_gait_contracture from '../jsons/data_gait_contracture.json'
import skeleton from '../jsons/lowerbody+thorax.json'

import imgGastrocnemius from './Gastrocnemius.png'
import imgHamstring from './Hamstring.png'
import imgPsoas from './Psoas.png'
import imgRectusFemoris from './RectusFemoris.png'
import imgSoleus from './Soleus.png'

const musclesNames = ["Gastrocnemius", "Hamstring", "Psoas", "RectusFemoris", "Soleus"];

class ContracturesPage extends BasePage {
  
  constructor(props) {
    super(props);
    this.muscleValue = undefined;
    this.skeleton = skeleton;
    this.stepTime = 1.15 / 101; // Gait cycle duration for a gait speed of 1.2 m/s
    this.updateGaitData(this.props.contracture_type, this.props.contracture_muscle, this.props.contracture_severity);
  }
  
  componentWillReceiveProps(nextProps) {
    if ((this.props.contracture_type === nextProps.contracture_type) && (this.props.contracture_muscle === nextProps.contracture_muscle) && (this.props.contracture_severity === nextProps.contracture_severity))
       return;
    this.updateGaitData(nextProps.contracture_type, nextProps.contracture_muscle, nextProps.contracture_severity);
  }
  
  updateMuscleImg(muscle) {
    let muscleImg = {};
    switch (muscle) {
    case 0:
      muscleImg = <img src={imgGastrocnemius} alt="gastrocnemius"/>;
      break;
    case 1:
      muscleImg = <img src={imgHamstring} alt="Hamstring"/>;
      break;
    case 2:
      muscleImg = <img src={imgPsoas} alt="Psoas"/>;
      break;
    case 3:
      muscleImg = <img src={imgRectusFemoris} alt="Rectus Femoris"/>;
      break;
    case 4:
      muscleImg = <img src={imgSoleus} alt="Soleus"/>;
      break;
    default:
      break;
    }
    return muscleImg;
  }
  
  updateGaitData(type, muscle, severity) {
    let cmn = musclesNames[muscle];
    if (severity === undefined)
      severity = data_gait_contracture[cmn].SimuDefaultValue;
    let index = Math.floor((severity - data_gait_contracture[cmn].SimuRange[0]) / 5)
    let leftPrefix = [];
    let rightPrefix = [];
    if (type === 'bilateral') {
      leftPrefix = 'Bilateral_';
      rightPrefix = 'Bilateral_';
    } else if (type === 'unilateral_right') {
      leftPrefix = 'Contralateral_';
      rightPrefix = 'Ipsilateral_';
    } else if (type === 'unilateral_left') {
      leftPrefix = 'Ipsilateral_';
      rightPrefix = 'Contralateral_';
    } else {
      console.error('Undefined contracture type. Nothing done.')
      return;
    }
    if (this.muscleValue !== muscle) {
      this.muscleValue = muscle;
      let muscleImg = this.updateMuscleImg(muscle);
      this.settingsOptions =
        <div>
          <List style={this.styles.list}>
            <Subheader style={this.styles.subheader}>Contracture type</Subheader>
            <RadioButtonGroup name="lateralEffect" defaultSelected="bilateral" onChange={ this.props.contractureActions.contractureTypeChanged }>
              <RadioButton
                value="unilateral_right"
                label="Unilateral right"
                style={this.styles.radioButton}
              />
              <RadioButton
                value="unilateral_left"
                label="Unilateral left"
                style={this.styles.radioButton}
              />
              <RadioButton
                value="bilateral"
                label="Bilateral"
                style={this.styles.radioButton}
              />
            </RadioButtonGroup>
          </List>
          <List style={this.styles.list}>
            <Subheader style={this.styles.subheader}>Muscle with contracture</Subheader>
            <DropDownMenu
             value={ this.muscleValue }
             onChange={ this.props.contractureActions.contractureMuscleChanged }
             style={{width: 180, marginBottom: 8, marginTop: -16}}
             labelStyle={{paddingLeft: 0, paddingRight: 0}}
             underlineStyle={{margin: "-1px 0"}}
             iconStyle={{right: 0, paddingRight: 0}}
             autoWidth={false}>
              <MenuItem value={ 0 } primaryText={ musclesNames[0] } />
              <MenuItem value={ 1 } primaryText={ musclesNames[1] } />
              <MenuItem value={ 2 } primaryText={ musclesNames[2] } />
              <MenuItem value={ 3 } primaryText={ "Rectus Femoris" } />
              <MenuItem value={ 4 } primaryText={ musclesNames[4] } />
            </DropDownMenu>
             { muscleImg }
          </List>
          <List style={this.styles.list}>
            <Subheader style={this.styles.subheader}>Contracture severity</Subheader>
            <SliderTextControlled
              onChange={this.props.contractureActions.contractureSeverityChanged}
              min={ data_gait_contracture[cmn].SimuRange[0] }
              max={ data_gait_contracture[cmn].SimuRange[1] }
              step={ 5 }
              defaultValue={ data_gait_contracture[cmn].SimuDefaultValue }
            />
          </List>
        </div>
    }
    this.data = {
      left_thorax: data_gait_contracture[cmn][leftPrefix+'Thorax'][index],
      left_pelvis: data_gait_contracture[cmn][leftPrefix+'Pelvis'][index],
      left_hip: data_gait_contracture[cmn][leftPrefix+'Hip'][index],
      left_knee: data_gait_contracture[cmn][leftPrefix+'Knee'][index],
      left_ankle: data_gait_contracture[cmn][leftPrefix+'Ankle'][index],
      right_thorax: data_gait_contracture[cmn][rightPrefix+'Thorax'][index],
      right_pelvis: data_gait_contracture[cmn][rightPrefix+'Pelvis'][index],
      right_hip: data_gait_contracture[cmn][rightPrefix+'Hip'][index],
      right_knee: data_gait_contracture[cmn][rightPrefix+'Knee'][index],
      right_ankle: data_gait_contracture[cmn][rightPrefix+'Ankle'][index],
    }
  }
}

const mapStateToProps = state => ({
  main_side: state.settings.main_side,
  contracture_type: state.contracture.type,
  contracture_muscle: state.contracture.muscle,
  contracture_severity: state.contracture.severity,
  playback: state.settings.playback,
})

const mapDispatchToProps = dispatch => ({
  contractureActions: bindActionCreators(contractureActions, dispatch),
  settingsActions: bindActionCreators(settingsActions, dispatch),
})

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(muiThemeable()(ContracturesPage))

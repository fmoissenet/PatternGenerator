import React, { Component } from 'react'
import { connect } from 'react-redux'
import d3 from 'd3'
import LineChart from '../components/LineChart'
import { GAIT_CYCLE_PERCENT } from '../constants'
import data_gait_normal from '../jsons/data_gait_normal.json'
import "../../node_modules/c3/c3.css"

const styles = {
  panel: {
    overflowY: 'auto',
    position: 'absolute',
    top: 55,
    bottom: 0,
  }
};

const minChartHeight = 155;

class ChartPanel extends Component {
  
  constructor(props, context) {
    super(props, context);
    this.oldSelectionIndex = 0;
    this.oldSelection = [];
  }
  
  resize(w) {
    let num = (this.refs.thoraxChart !== undefined) ? 5 : 4;
    let h = Math.max(minChartHeight, this.refs.ChartPanel.offsetHeight / num);
    let size = {height: h, width: w};
    if (this.refs.thoraxChart !== undefined)
      this.refs.thoraxChart.resize(size);
    this.refs.pelvisChart.resize(size);
    this.refs.hipChart.resize(size);
    this.refs.kneeChart.resize(size);
    this.refs.ankleChart.resize(size);
  }

  select(index) {
    if ((index === -1) && (this.oldSelection.length !== 0)) {
      this.oldSelection.forEach( (c) => {
        c.style.opacity = '0';
      });
      this.oldSelection = [];
    } else {
      this.oldSelection.forEach( (c) => {
        c.style.opacity = '0';
      });
      let selection = d3.selectAll('.c3-circle-' + index)[0];
      selection.forEach( (c) => {
        c.style.opacity = '1';
      });
      this.oldSelectionIndex = index;
      this.oldSelection = selection;
    }
    
  };
  
  componentDidUpdate() {
    // Hack due to the way C3 is used to select the current frame
    setTimeout(() => {
      this.select(this.oldSelectionIndex);
    }, 50);
  }
  
  render() {
    const xData = ['x'].concat(GAIT_CYCLE_PERCENT);
    const xData0 = ['x0', 0, 100];
    const yData0 = ['y0', 0, 0];
    let thorax = [];
    let pelvis = [];
    let left_hip = [];
    let right_hip = [];
    let left_knee = [];
    let right_knee = [];
    let left_ankle = [];
    let right_ankle = [];
    if (this.props.main_side === 'right') {
      thorax = this.props.data.right_thorax;
      pelvis = this.props.data.right_pelvis;
      left_hip = this.props.data.left_hip.slice(50).concat(this.props.data.left_hip.slice(0,50));
      right_hip = this.props.data.right_hip;
      left_knee = this.props.data.left_knee.slice(50).concat(this.props.data.left_knee.slice(0,50));
      right_knee = this.props.data.right_knee;
      left_ankle = this.props.data.left_ankle.slice(50).concat(this.props.data.left_ankle.slice(0,50));
      right_ankle = this.props.data.right_ankle;
    } else {
      thorax = this.props.data.left_thorax;
      pelvis = this.props.data.left_pelvis;
      left_hip = this.props.data.left_hip;
      right_hip = this.props.data.right_hip.slice(50).concat(this.props.data.right_hip.slice(0,50));
      left_knee = this.props.data.left_knee;
      right_knee = this.props.data.right_knee.slice(50).concat(this.props.data.right_knee.slice(0,50));
      left_ankle = this.props.data.left_ankle;
      right_ankle = this.props.data.right_ankle.slice(50).concat(this.props.data.right_ankle.slice(0,50));
    }
    let chartData = {
      ThoraxTilt: [
        xData0, yData0, xData,
        ['mid'].concat(thorax),
      ],
      PelvisTilt: [
        xData0, yData0, xData,
        ['mid'].concat(pelvis),
      ],
      HipFE: [
        xData0, yData0, xData,
        ['left'].concat(left_hip),
        ['right'].concat(right_hip),
      ],
      KneeFE: [
        xData0, yData0, xData,
        ['left'].concat(left_knee),
        ['right'].concat(right_knee),
      ],
      AnkleFE: [
        xData0, yData0, xData,
        ['left'].concat(left_ankle),
        ['right'].concat(right_ankle),
      ]
    };
    let thoraxChart = (thorax.length === 0) ? null : <LineChart ref="thoraxChart" data={chartData.ThoraxTilt} norm={data_gait_normal.Thorax} height={minChartHeight} ylabel='Thorax Ext/Flex (°)' ylim={[-30,30]} yticknum={7} />; 
    return (
      <div ref="ChartPanel" style={ styles.panel }>
        { thoraxChart }
        <LineChart ref="pelvisChart" data={chartData.PelvisTilt} norm={data_gait_normal.Pelvis} height={minChartHeight} ylabel='Pelvis Tilt Ret/Ant (°)' ylim={[-25,35]} yticknum={7} />
        <LineChart ref="hipChart" data={chartData.HipFE} norm={data_gait_normal.Hip} height={minChartHeight} ylabel='Hip Ext/Flex (°)' ylim={[-30,70]} yticknum={6} />
        <LineChart ref="kneeChart" data={chartData.KneeFE} norm={data_gait_normal.Knee} height={minChartHeight} ylabel='Knee Ext/Flex (°)' ylim={[-20,80]} yticknum={6} />
        <LineChart ref="ankleChart" data={chartData.AnkleFE} norm={data_gait_normal.Ankle} height={minChartHeight} ylabel='Ankle Ext/Flex (°)' ylim={[-30,30]} yticknum={7} />
      </div>
    );
  };

}

const mapStateToProps = (state) => {
  return {
    main_side: state.settings.main_side
  }
}

ChartPanel.propTypes = {
  data: React.PropTypes.object.isRequired
}

export default connect(mapStateToProps, null, null, { withRef: true })(ChartPanel);
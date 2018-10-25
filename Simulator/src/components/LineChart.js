import React, { Component } from 'react'
import C3Chart from 'react-c3js';
import d3 from 'd3';
import { COLOR_ORANGE, COLOR_YELLOW, COLOR_BLUE, GAIT_CYCLE_PERCENT } from '../constants';
import './LineChart.css'

const margiWidth = 86;
const marginHeight = 34;

class LineChart extends Component {
  
  constructor(props) {
    super(props);
    this.NormAreaHandle = undefined;
  }
  
  select(ids, indices) {
    this.refs.c3.chart.select(ids,indices,true);
  }
  
  updateNormArea(size, norm) {
    let xscale = d3.scale.linear()
                   .range([0,(size.width - margiWidth)])
                   .domain([0,100]);
    let yscale = d3.scale.linear()
                   .range([(size.height - marginHeight),0])
                   .domain(this.props.ylim);
    let area = d3.svg.area()
                     .interpolate("cardinal")
                     .x0( function(d) { return xscale(GAIT_CYCLE_PERCENT[d]) } )
                     .x1( function(d) { return xscale(GAIT_CYCLE_PERCENT[d]) } )
                     .y0( function(d) { return yscale(norm.M[d]-norm.SD[d]) } )
                     .y1( function(d) { return yscale(norm.M[d]+norm.SD[d]) } );
    return area;
  }
  
  resize(size) {
    this.refs.c3.chart.resize(size);
    let area = this.updateNormArea(size, this.props.norm);
    this.NormAreaHandle.attr('d', area);
  }
  
  componentDidMount() {
    let indexies = d3.range( 101 );
    let area = this.updateNormArea({height: this.refs.c3.chart.element.offsetHeight, width: this.refs.c3.chart.element.offsetWidth}, this.props.norm);
    let y0 = this.refs.c3.chart.internal.main.selectAll('.c3-chart-line').filter('.c3-target-y0');
    this.NormAreaHandle = y0.append('path')
      .datum(indexies)
      .attr('class', 'area')
      .attr('d', area);
  }
  
  render() {
    return (
      <C3Chart
       ref="c3"
       data={
        { 
          xs: {
              'mid': 'x',
              'left': 'x',
              'right': 'x',
              'y0': 'x0',
          },
          columns: this.props.data, 
          type: 'line', 
          colors: {
            y0: '#aaa',
            mid: d3.rgb(COLOR_YELLOW[0]*255,COLOR_YELLOW[1]*255,COLOR_YELLOW[2]*255).toString(), 
            left: d3.rgb(COLOR_ORANGE[0]*255,COLOR_ORANGE[1]*255,COLOR_ORANGE[2]*255).toString(), 
            right: d3.rgb(COLOR_BLUE[0]*255,COLOR_BLUE[1]*255,COLOR_BLUE[2]*255).toString()
          },
          selection: {
            enabled: true
          }
        }
      }
      size={
        { 
          height: this.props.height, 
          width: this.props.width
        }
      }
      padding={
        {
          left: 70,
          right: 15 
        }
      }
      tooltip={
        {
          show: false
        }
      }
      legend={
        {
          show: false
        }
      }
      axis={
        {
          x: {
            label: 'Gait Cycle (%)',
            tick: { count: 11 },
            padding: 0
          },
          y: {
            label: {
              text: this.props.ylabel,
              position: 'outer-middle',
            },
            tick: {
              count: this.props.yticknum,
              format: d3.format('.1f'),
            },
            min: this.props.ylim[0],
            max: this.props.ylim[1],
            padding: 0
          }
        }
      }
      interaction={
        {
          enabled: false
        }
      }
      point={
        {
          focus: {
            expand: {
                enabled: false
            }
          },
          r: 4,
          show: false
        }
      }
      />
    );
  }
}

LineChart.propTypes = {
  data: React.PropTypes.array.isRequired,
  norm: React.PropTypes.object,
  height: React.PropTypes.number.isRequired,
  width: React.PropTypes.number,
  ylabel: React.PropTypes.string.isRequired,
  ylim: React.PropTypes.array.isRequired,
  yticknum: React.PropTypes.number.isRequired
}

export default LineChart;
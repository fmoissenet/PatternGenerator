import React, { Component } from 'react'

import Slider from 'material-ui/Slider';
import TextField from 'material-ui/TextField';

const styles = {
  containerslider: {
    display: 'flex',
    flexDirection: 'row wrap',
    width: '100%',
    marginTop: '-16px',
  },
  slider: {
    flex: 4,
  },
  sliderStyle: {
    marginBottom: 0,
  },
  slidervalue: {
    flex: 1,
    cursor: 'default',
    marginLeft: 10,
    marginTop: 5
  }
}

class SliderTextControlled extends Component {
  
  state = {
    slidervalue: undefined ,
  };

  handleSlider = (event, value) => {
    this.setState({slidervalue: value});
    if (this.props.onChange !== undefined)
      this.props.onChange(value);
  };

  render() {
    let value = this.state.slidervalue;
    if ((value === undefined) || (value < this.props.min) || (value > this.props.max))
      value = this.props.defaultValue;
    return (
      <div style={styles.containerslider}>
        <Slider
          min={ this.props.min }
          max={ this.props.max }
          step={ this.props.step }
          defaultValue={ this.props.defaultValue }
          style={styles.slider}
          sliderStyle={styles.sliderStyle}
          value={ value }
          onChange={this.handleSlider}
        />
        <TextField
         id="text-field-slider"
         style={styles.slidervalue}
         value={ value }
         disabled={ true }
         inputStyle={{ textAlign: 'center' }}
        />
      </div>
    );
  }
  
}

SliderTextControlled.propTypes = {
  min: React.PropTypes.number.isRequired,
  max: React.PropTypes.number.isRequired,
  step: React.PropTypes.number.isRequired,
  defaultValue: React.PropTypes.number.isRequired,
  onChange: React.PropTypes.func,
}

export default SliderTextControlled
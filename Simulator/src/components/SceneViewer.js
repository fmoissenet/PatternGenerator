import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import * as THREE from 'three';
import '../vendor/three/controls/EditorControls';

class SceneViewer extends Component {
  constructor(props, context) {
    super(props, context);
    
    this.state = { width: 0, height: 0};
    this.animationFrameId = undefined;
    
    this.renderer = null;
    
    // Scene
    this.scene = new THREE.Scene();
    this.scene.name = 'Scene';
    
    this.camera = new THREE.PerspectiveCamera( 45, 1, 1, 3000 );
    this.camera.name = 'Camera';
    
    let light = new THREE.HemisphereLight( 0xffeeee, 0x111122 );
    light.name = 'Light';
    this.scene.add( light );
    
    // Ground
    
    // let grid = new THREE.GridHelper( 500, 25 );
    // grid.name = 'Grid';
    // this.scene.add(grid);
    // let axis = new THREE.AxisHelper(25);
    // axis.name = 'GlobalAxes';
    // axis.material.linewidth = 2;
    // this.scene.add( axis );
    
    // Callbacks
    
    // this.onWindowResize = this.onWindowResize.bind(this);
    // this.startAnimate = this.startAnimate.bind(this);
    // this.stopAnimate = this.stopAnimate.bind(this);
  }
  
  componentDidMount() {
    this.renderer = new THREE.WebGLRenderer( { antialias: true } );
    this.renderer.setClearColor( 0xf0f0f0 );
    this.renderer.setPixelRatio( window.devicePixelRatio );
    this.cameraControls = new THREE.EditorControls( this.camera, this.renderer.domElement );
    ReactDOM.findDOMNode(this.refs.viewer).appendChild( this.renderer.domElement );
    // window.addEventListener('resize', this.onWindowResize, false);
    // let _this = this; // Store a this ref
    // window.requestAnimationFrame(() => { _this.updateSizeState(); });
    // this.startAnimate()
  }
  
  componentWillUnmount() {
    // window.removeEventListener('resize', this.onWindowResize, false);
    // this.stopAnimate()
/*    delete this.renderer;*/
  }

  render() {
    if (this.renderer !== null) {
      this.renderer.setSize(this.state.width, this.state.height);
      this.camera.aspect = this.state.width / this.state.height;
      this.camera.updateProjectionMatrix();
    }
    return (<div style={{width:'100%',height:'100%'}} ref="viewer"></div>)
  }
  
  startAnimate() {
    this.animationFrameId = requestAnimationFrame(this.startAnimate);
    this.updateScene()
  }
  
  stopAnimate() {
    cancelAnimationFrame(this.animationFrameId);
    this.animationFrameId = undefined;
  }
  
  updateScene() {
    this.renderer.render( this.scene, this.camera );
  }
  
  updateSizeState() {
    this.setState({width: this.refs.viewer.offsetWidth, height: this.refs.viewer.offsetHeight});
  }
  
  onWindowResize(e) {
    this.updateSizeState();
  }
}

export default SceneViewer;
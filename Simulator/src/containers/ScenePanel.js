import React from 'react'
import * as THREE from 'three';
import SceneViewer from '../components/SceneViewer';
import { COLOR_ORANGE, COLOR_YELLOW, COLOR_BLUE } from '../constants';

class ScenePanel extends SceneViewer {
  
  constructor(props, context) {
    super(props, context);
    this.skeletonhelper = null;
    this.oldSelectionIndex = 0;
  };
  
  componentDidMount() {
    super.componentDidMount();
    let scene = this.scene;
    let loader = new THREE.JSONLoader();
    let {geometry, materials} = loader.parse(this.props.skeleton);
    materials.forEach( (m) => { m.skinning = true; } );
    materials[0].color.setRGB(COLOR_BLUE[0], COLOR_BLUE[1], COLOR_BLUE[2]);
    materials[1].color.setRGB(COLOR_ORANGE[0], COLOR_ORANGE[1], COLOR_ORANGE[2]);
    materials[2].color.setRGB(COLOR_YELLOW[0], COLOR_YELLOW[1], COLOR_YELLOW[2]);
    let skinnedmesh = new THREE.SkinnedMesh( geometry,  new THREE.MultiMaterial(materials) );
    scene.add( skinnedmesh );
    this.skeletonhelper = new THREE.SkeletonHelper( skinnedmesh );
    this.skeletonhelper.material.depthTest = true;
    for (let i = 2 ; i < 17 ; ++i)
    {
      this.skeletonhelper.geometry.attributes.color.setXYZ(i, COLOR_BLUE[0], COLOR_BLUE[1], COLOR_BLUE[2]);
    }
    for (let i = 17 ; i < 32 ; ++i)
    {
      this.skeletonhelper.geometry.attributes.color.setXYZ(i, COLOR_ORANGE[0], COLOR_ORANGE[1], COLOR_ORANGE[2]);
    }
    for (let i = 32 ; i < (this.skeletonhelper.bones.length-1)*2 ; ++i)
    {
      this.skeletonhelper.geometry.attributes.color.setXYZ(i, COLOR_YELLOW[0], COLOR_YELLOW[1], COLOR_YELLOW[2]);
    }
    this.skeletonhelper.geometry.colorsNeedUpdate = true;
    this.skeletonhelper.material.linewidth = 2;
    scene.add( this.skeletonhelper );
    let sbbd = 1.95 * skinnedmesh.geometry.boundingSphere.radius;
    let pos = new THREE.Vector3();
    pos.copy(skinnedmesh.geometry.boundingSphere.center);
    pos.y -= skinnedmesh.geometry.boundingSphere.center.x;
    this.camera.position.set(sbbd, sbbd, -sbbd);
    this.camera.lookAt( pos );
    this.cameraControls.center.copy( pos );
  };
  
  componentDidUpdate() {
    this.select(this.oldSelectionIndex);
  };
  
  select(index) {
    if (this.skeletonhelper === null)
      return;
    let rightidx = index;
    let leftidx = rightidx + 50;
    if (leftidx > 100)
      leftidx -= 100;
    const deg2rad = 3.14 / 180.0;
    // const off = 0;//-3.14 / 2;
    const z = new THREE.Vector3(0,0,1);
    const eul = new THREE.Euler(3.14, 0, this.props.data.right_pelvis[rightidx] * deg2rad, 'XYZ' );
    this.skeletonhelper.bones[0].setRotationFromEuler(eul);
    this.skeletonhelper.bones[10].setRotationFromAxisAngle(z, -this.props.data.left_hip[leftidx] * deg2rad);
    this.skeletonhelper.bones[11].setRotationFromAxisAngle(z, this.props.data.left_knee[leftidx] * deg2rad);
    this.skeletonhelper.bones[12].setRotationFromAxisAngle(z, -this.props.data.left_ankle[leftidx] * deg2rad);
    this.skeletonhelper.bones[2].setRotationFromAxisAngle(z, -this.props.data.right_hip[rightidx] * deg2rad);
    this.skeletonhelper.bones[3].setRotationFromAxisAngle(z, this.props.data.right_knee[rightidx] * deg2rad);
    this.skeletonhelper.bones[4].setRotationFromAxisAngle(z, -this.props.data.right_ankle[rightidx] * deg2rad);
    if (this.skeletonhelper.bones[22].name === "Thorax") {
      this.skeletonhelper.bones[22].setRotationFromAxisAngle(z, (this.props.data.right_thorax[rightidx] - this.props.data.right_pelvis[rightidx]) * deg2rad);
    }
    this.skeletonhelper.bones[0].updateMatrixWorld(true);
    this.skeletonhelper.update();
    this.oldSelectionIndex = index;
  }
}

ScenePanel.propTypes = {
  data: React.PropTypes.object.isRequired,
  skeleton: React.PropTypes.object.isRequired
}

export default ScenePanel
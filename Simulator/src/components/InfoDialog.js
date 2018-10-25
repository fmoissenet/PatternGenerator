import React from 'react';
import Dialog from 'material-ui/Dialog';
import FlatButton from 'material-ui/FlatButton';

const InfoDialog = ({open, onRequestClose}) => {
  
  const actions = [
    <FlatButton
      label="Close"
      primary={true}
      keyboardFocused={true}
      onTouchTap={onRequestClose}
    />,
  ];
  
  return (
    <div>
      <Dialog
        title="Information"
        actions={actions}
        modal={false}
        open={open}
        onRequestClose={onRequestClose}
      >
        <h2>Welcome to the Pathological Gait Contractures Simulator</h2>
        <p>This simulator was created to synthesize and visualize gait kinematics according to the degree of contracture of the main muscles of the lower limb acting in the sagittal plane (Soleus, Gastrocnemius, Hamstring, Rectus Femoris, Psoas). Data used to create the simulation come from experimental procedures using an exoskeleton to replicate muscles contractures on the lower-limbs of healthy participants (<a href="http://dx.doi.org/10.1016/j.gaitpost.2016.09.016">10.1016/j.gaitpost.2016.09.016</a>). In total, 32 participants were included in this study, 113 different contracture emulations were experimented resulting in 855 trials and 4698 gait cycles on left side and 4709 on the right side. This simulator was developed in the context of a research project supported by the <a href="http://www.snf.ch/en/Pages/default.aspx">Swiss National Science Foundation</a>.  The title of the projet was "Data-driven computer simulation of pathological gait resulting from contractures" and the global objective was to define principles and simulate pathological gait resulting from muscle contractures (<a href="http://p3.snf.ch/project-146801">more information</a>)</p>
      </Dialog>
    </div>
  );
  
};

InfoDialog.propTypes = {
  open: React.PropTypes.bool.isRequired,
  onRequestClose: React.PropTypes.func,
}

export default InfoDialog;
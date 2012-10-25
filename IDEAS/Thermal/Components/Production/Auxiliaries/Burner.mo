﻿within IDEAS.Thermal.Components.Production.Auxiliaries;
model Burner
  "Burner for use in Boiler, based on interpolation data.  Takes into account losses of the boiler to the environment"
  import IDEAS;

  /*
  This model is based on data from XXX (get source data ruben mailede me).
  The nominal power of the original boiler is 10.1 kW bij 50/30degC water temperatures. 
  The efficiency in this point is 92.2% on higher heating value. 
   
  First, the efficiency is interpolated for the 
  return water temperature and flowrate at 5 different modulation levels. These modulation
  levels are the FUEL input power to the boiler.  The results
  are rescaled to the nominal power of the modelled heatpump (with QNom/QNom_data) and
  stored in a vector, eta_vector.
  
  Finally, the initial modulation is calculated based on the asked power and the max power at 
  operating conditions: 
  - if modulation_init < modulation_min, the boiler is OFF, modulation = 0.  
  - if modulation_init > 100%, the modulation is 100%
  - if modulation_init between modulation_min and modulation_start: hysteresis for on/off cycling.
  
  If the heat pump is on another modulation, interpolation is made to get eta at the real modulation.
  
  ATTENTION
  This model takes into account environmental heat losses of the boiler.
  In order to keep the same nominal eta's during operation, these heat losses are added
  to the computed power.  Therefore, the heat losses are only really 'losses' when the boiler is 
  NOT operating. 
  
  The eta is calculated as the heat delivered to the heatExchanger divided by the fuel consumption PFuel. 
  
  */
//protected
  parameter Thermal.Data.Interfaces.Medium medium=Data.Media.Water()
    "Medium in the component";

  final parameter Real[6] modVector = {0, 20, 40, 60, 80, 100}
    "6 modulation steps, %";
  Real eta "Instantaneous efficiency of the boiler (higher heating value)";
  Real[6] etaVector
    "Thermal efficiency (higher heating value) for 6 modulation steps, base 1";
  Real[6] QVector "Thermal power for 6 modulation steps, in kW";
  Modelica.SIunits.Power QMax
    "Maximum thermal power at specified evap and condr temperatures, in W";
  Modelica.SIunits.Power QAsked(start=0);
  parameter Modelica.SIunits.ThermalConductance UALoss
    "UA of heat losses of HP to environment";
  final parameter Modelica.SIunits.Power QNom=QDesign*betaFactor/
      fraLosDesNom
    "The power at nominal conditions (50/30) taking into account beta factor and power loss fraction";

public
  parameter Real fraLosDesNom = 1
    "Ratio of power at design conditions over power at 50/30degC";
  parameter Real betaFactor = 1 "Relative sizing compared to design heat load";
  parameter Modelica.SIunits.Power QDesign "Design heat load";
  parameter Real etaNom = 0.922
    "Nominal efficiency (higher heating value)of the xxx boiler at 50/30degC.  See datafile";
  parameter Real modulationMin(max=29)=25 "Minimal modulation percentage";
    // dont' set this to 0 or very low values, you might get negative P at very low modulations because of wrong extrapolation
  parameter Real modulationStart(min=min(30,modulationMin+5)) = 35
    "Min estimated modulation level required for start of HP";
  Real modulationInit "Initial modulation, decides on start/stop of the boiler";
  Real modulation(min=0, max=1) "Current modulation percentage";
  Modelica.SIunits.Power PFuel "Resulting fuel consumption";
  input Modelica.SIunits.Temperature THxIn "Condensor temperature";
  input Modelica.SIunits.Temperature TBoilerSet
    "Condensor setpoint temperature.  Not always possible to reach it";
  input Modelica.SIunits.MassFlowRate m_flowHx "Condensor mass flow rate";
  input Modelica.SIunits.Temperature TEnvironment
    "Temperature of environment for heat losses";

protected
  Real kgps2lph = 3600 / medium.rho * 1000 "Conversion from kg/s to l/h";
  Modelica.Blocks.Tables.CombiTable2D eta100(smoothness=Modelica.Blocks.Types.Smoothness.ContinuousDerivative, table=[0,
        100,400,700,1000,1300; 20.0,0.9015,0.9441,0.9599,0.9691,0.9753; 30.0,0.8824,
        0.9184,0.9324,0.941,0.9471; 40.0,0.8736,0.8909,0.902,0.9092,0.9143; 50.0,
        0.8676,0.8731,0.8741,0.8746,0.8774; 60.0,0.8,0.867,0.8681,0.8686,0.8689;
        70.0,0.8,0.8609,0.8619,0.8625,0.8628; 80.0,0.8,0.8547,0.8558,0.8563,0.8566])
    annotation (Placement(transformation(extent={{-58,66},{-38,86}})));
  Modelica.Blocks.Tables.CombiTable2D eta80(smoothness=Modelica.Blocks.Types.Smoothness.ContinuousDerivative,
      table=[0,100,400,700,1000,1300;20.0,0.9155,0.9587,0.9733,0.9813,0.9866;30.0,0.8937,0.9311,0.9449,0.953,0.9585;40.0,0.8753,0.9007,0.9121,0.9192,0.9242;50.0,0.8691,0.8734,0.8755,0.8804,0.884;60.0,0.8628,0.8671,0.8679,0.8683,0.8686;70.0,0.7415,0.8607,0.8616,0.862,0.8622;80.0,0.6952,0.8544,0.8552,0.8556,0.8559])
    annotation (Placement(transformation(extent={{-58,32},{-38,52}})));
  Modelica.Blocks.Tables.CombiTable2D eta60(smoothness=Modelica.Blocks.Types.Smoothness.ContinuousDerivative,
      table=[0,100,400,700,1000,1300;20.0,0.9349,0.9759,0.9879,0.9941,0.998;30.0,0.9096,0.9471,0.9595,0.9664,0.9709;40.0,0.8831,0.9136,0.9247,0.9313,0.9357;50.0,0.8701,0.8759,0.8838,0.8887,0.8921;60.0,0.8634,0.8666,0.8672,0.8675,0.8677;70.0,0.8498,0.8599,0.8605,0.8608,0.861;80.0,0.8488,0.8532,0.8538,0.8541,0.8543])
    annotation (Placement(transformation(extent={{-58,-6},{-38,14}})));
  Modelica.Blocks.Tables.CombiTable2D eta40(smoothness=Modelica.Blocks.Types.Smoothness.ContinuousDerivative,
      table=[0,100,400,700,1000,1300;20.0,0.9624,0.9947,0.9985,0.9989,0.999;30.0,0.9333,0.9661,0.9756,0.9803,0.9833;40.0,0.901,0.9306,0.94,0.9451,0.9485;50.0,0.8699,0.8871,0.8946,0.8989,0.9018;60.0,0.8626,0.8647,0.8651,0.8653,0.8655;70.0,0.8553,0.8573,0.8577,0.8579,0.8581;80.0,0.8479,0.8499,0.8503,0.8505,0.8506])
    annotation (Placement(transformation(extent={{-58,-44},{-38,-24}})));
  Modelica.Blocks.Tables.CombiTable2D eta20(smoothness=Modelica.Blocks.Types.Smoothness.ContinuousDerivative,
      table=[0,100,400,700,1000,1300;20.0,0.9969,0.9987,0.999,0.999,0.999;30.0,0.9671,0.9859,0.99,0.9921,0.9934;40.0,0.9293,0.9498,0.9549,0.9575,0.9592;50.0,0.8831,0.9003,0.9056,0.9083,0.9101;60.0,0.8562,0.857,0.8575,0.8576,0.8577;70.0,0.8398,0.8479,0.8481,0.8482,0.8483;80.0,0.8374,0.8384,0.8386,0.8387,0.8388])
    annotation (Placement(transformation(extent={{-58,-86},{-38,-66}})));

  Modelica.SIunits.HeatFlowRate QLossesToCompensate "Environment losses";
public
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a heatPort
    "heatPort connection to water in condensor"
    annotation (Placement(transformation(extent={{90,-10},{110,10}})));
  IDEAS.BaseClasses.Control.Hyst_NoEvent
                               onOff(
    uLow = modulationMin,
    uHigh = modulationStart,
    y(
    start = 0),
    enableRelease=true) "on-off, based on modulationInit"
    annotation (Placement(transformation(extent={{28,40},{48,60}})));

equation
  onOff.u = modulationInit;
  onOff.release = if noEvent(m_flowHx > 0) then 1.0 else 0.0;
  QAsked = max(0, m_flowHx * medium.cp * (TBoilerSet - THxIn));
  eta100.u1 = THxIn - 273.15;
  eta100.u2 = m_flowHx * kgps2lph;
  eta80.u1 = THxIn - 273.15;
  eta80.u2 = m_flowHx * kgps2lph;
  eta60.u1 = THxIn - 273.15;
  eta60.u2 = m_flowHx * kgps2lph;
  eta40.u1 = THxIn - 273.15;
  eta40.u2 = m_flowHx * kgps2lph;
  eta20.u1 = THxIn - 273.15;
  eta20.u2 = m_flowHx * kgps2lph;

  // all these are in kW
  etaVector[1] = 0;
  etaVector[2] = eta20.y;
  etaVector[3] = eta40.y;
  etaVector[4] = eta60.y;
  etaVector[5] = eta80.y;
  etaVector[6] = eta100.y;
  QVector = etaVector / etaNom .* modVector/100 * QNom; // in W
  QMax = QVector[6];

  modulationInit = Modelica.Math.Vectors.interpolate(QVector, modVector, QAsked);
  modulation = onOff.y * min(modulationInit, 100);

  // compensation of heat losses (only when the hp is operating)
  QLossesToCompensate = if noEvent(modulation > 0) then UALoss * (heatPort.T-TEnvironment) else 0;

  eta = Modelica.Math.Vectors.interpolate(modVector, etaVector, modulation);
  heatPort.Q_flow = - Modelica.Math.Vectors.interpolate(modVector, QVector, modulation) - QLossesToCompensate;
  PFuel = if noEvent(modulation >0) then -heatPort.Q_flow / eta else 0;

  annotation (Diagram(graphics),
              Diagram(graphics));
end Burner;

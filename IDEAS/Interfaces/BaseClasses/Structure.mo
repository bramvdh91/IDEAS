within IDEAS.Interfaces.BaseClasses;
partial model Structure "Partial model for building structure models"

  outer IDEAS.SimInfoManager sim
    "Simulation information manager for climate data"
    annotation (Placement(transformation(extent={{130,-100},{150,-80}})));

  replaceable package Medium = IDEAS.Media.Air
    constrainedby Modelica.Media.Interfaces.PartialMedium
    "Medium in the component"
      annotation (choicesAllMatching = true);

  // Building characteristics  //////////////////////////////////////////////////////////////////////////

  parameter Integer nZones(min=1)
    "Number of conditioned thermal zones in the building";
  parameter Integer nEmb(min=0) "Number of embedded systems in the building";
  parameter Modelica.SIunits.Area ATrans=100
    "Transmission heat loss area of the residential unit";
  parameter Modelica.SIunits.Area[nZones] AZones = ones(nZones)*100
    "Conditioned floor area of the zones";
  parameter Modelica.SIunits.Volume[nZones] VZones = AZones .*3
    "Conditioned volume of the zones based on external dimensions";
  final parameter Modelica.SIunits.Length C=sum(VZones)/ATrans
    "Building compactness";

  parameter Modelica.SIunits.Temperature[nZones] T_start
    "Operative zonal start temperatures";

  // Interfaces  ///////////////////////////////////////////////////////////////////////////////////////

  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a[nZones] heatPortCon
    "Internal zone nodes for convective heat gains" annotation (Placement(
        transformation(extent={{140,10},{160,30}}), iconTransformation(extent={
            {140,10},{160,30}})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a[nZones] heatPortRad
    "Internal zones node for radiative heat gains" annotation (Placement(
        transformation(extent={{140,-30},{160,-10}}), iconTransformation(extent=
           {{140,-30},{160,-10}})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_b[nEmb] heatPortEmb
    "Construction nodes for heat gains by embedded layers" annotation (
      Placement(transformation(extent={{140,50},{160,70}}), iconTransformation(
          extent={{140,50},{160,70}})));
  Modelica.Blocks.Interfaces.RealOutput[nZones] TSensor(final quantity="ThermodynamicTemperature",unit="K",displayUnit="degC", min=0)
    "Sensor temperature of the zones"
    annotation (Placement(transformation(extent={{146,-70},{166,-50}})));
  Fluid.Interfaces.FlowPort_b[nZones] flowPort_Out(redeclare package Medium = Medium)
    annotation (Placement(transformation(extent={{-30,90},{-10,110}})));
  Fluid.Interfaces.FlowPort_a[nZones] flowPort_In(redeclare package Medium = Medium)
    annotation (Placement(transformation(extent={{10,90},{30,110}})));
  outer Modelica.Fluid.System system
  annotation (Placement(transformation(extent={{100,-100},{120,-80}})));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-150,-100},
            {150,100}}), graphics={
        Rectangle(
          extent={{-150,100},{150,-100}},
          fillColor={215,215,215},
          fillPattern=FillPattern.Solid,
          lineColor={191,0,0}),
        Line(
          points={{60,8},{0,60},{-60,10},{-60,-60},{60,-60}},
          color={127,0,0},
          smooth=Smooth.None),
        Polygon(
          points={{60,8},{56,4},{0,50},{-52,8},{-52,-52},{60,-52},{60,-60},{-60,
              -60},{-60,10},{0,60},{60,8}},
          lineColor={95,95,95},
          smooth=Smooth.None,
          fillColor={95,95,95},
          fillPattern=FillPattern.Solid)}), Diagram(coordinateSystem(
          preserveAspectRatio=false, extent={{-150,-100},{150,100}}), graphics));

end Structure;

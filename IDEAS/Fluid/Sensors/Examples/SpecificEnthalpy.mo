within IDEAS.Fluid.Sensors.Examples;
model SpecificEnthalpy "Test model for the enthalpy flow rate sensors"
  extends Modelica.Icons.Example;

  package Medium = IDEAS.Media.Air "Medium model";

  IDEAS.Fluid.Sources.MassFlowSource_h sou(
    redeclare package Medium = Medium,
    use_m_flow_in=true,
    use_h_in=false,
    nPorts=2,
    X={0,1}) "Flow boundary condition"
    annotation (Placement(transformation(extent={{-40,-20},{-20,0}})));
  IDEAS.Fluid.Sources.Boundary_ph sin(
    redeclare package Medium = Medium,
    use_h_in=false,
    h=20,
    nPorts=1,
    X={0,1}) "Flow boundary condition"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={70,-12})));
  Modelica.Blocks.Sources.Ramp ramp(
    height=-2,
    offset=1,
    duration=60)
    annotation (Placement(transformation(extent={{-80,-12},{-60,8}})));
  inner Modelica.Fluid.System system
    annotation (Placement(transformation(extent={{-100,-100},{-80,-80}})));
  IDEAS.Fluid.Sensors.SpecificEnthalpy senFloSou(
    redeclare package Medium = Medium) "Sensor at the flow source"
    annotation (Placement(transformation(extent={{-10,0},{10,20}})));
  IDEAS.Fluid.Sensors.SpecificEnthalpyTwoPort senStr(
    redeclare package Medium = Medium,
    m_flow_nominal=2) "Sensor in the fluid stream"
    annotation (Placement(transformation(extent={{20,-22},{40,-2}})));
equation
  connect(ramp.y, sou.m_flow_in) annotation (Line(
      points={{-59,-2},{-40,-2}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(sou.ports[1], senFloSou.port) annotation (Line(
      points={{-20,-8},{0,-8},{0,0}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(sou.ports[2], senStr.port_a) annotation (Line(
      points={{-20,-12},{20,-12}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(senStr.port_b, sin.ports[1]) annotation (Line(
      points={{40,-12},{60,-12}},
      color={0,127,255},
      smooth=Smooth.None));
    annotation (
experiment(StopTime=1.0),
__Dymola_Commands(file="modelica://IDEAS/Resources/Scripts/Dymola/Fluid/Sensors/Examples/SpecificEnthalpy.mos"
        "Simulate and plot"),  Diagram(
        coordinateSystem(preserveAspectRatio=false,extent={{-100,-100},{100,100}}),
        graphics),
    Documentation(info="<html>
<p>
This example tests the specific enthalpy sensors.
</p>
</html>", revisions="<html>
<ul>
<li>
August 31, 2013, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"));
end SpecificEnthalpy;

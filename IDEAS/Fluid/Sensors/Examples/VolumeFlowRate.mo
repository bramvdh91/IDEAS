within IDEAS.Fluid.Sensors.Examples;
model VolumeFlowRate "Test model for the volume flow rate sensor"
  extends Modelica.Icons.Example;

  package Medium = IDEAS.Media.Air
    "Medium model";

  IDEAS.Fluid.Sources.Boundary_pT sin(
    redeclare package Medium = Medium,
    T=293.15,
    nPorts=1) "Flow boundary condition" annotation (Placement(
        transformation(extent={{80,-10},{60,10}},rotation=0)));
  IDEAS.Fluid.Sources.MassFlowSource_T masFloRat(
    redeclare package Medium = Medium,
    use_T_in=false,
    X={0.02,0.98},
    use_m_flow_in=true,
    nPorts=1) "Flow boundary condition"
     annotation (Placement(transformation(
          extent={{-50,-10},{-30,10}},rotation=0)));

  Modelica.Blocks.Sources.Ramp ramp(
    height=-20,
    offset=10,
    duration=60)
    annotation (Placement(transformation(extent={{-90,-2},{-70,18}})));
  IDEAS.Fluid.Sensors.VolumeFlowRate senDyn(
    redeclare package Medium = Medium,
    m_flow_nominal=10)
    "Sensor configured to use a dynamic model for the density"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
  IDEAS.Fluid.Sensors.VolumeFlowRate senSteSta(
    redeclare package Medium = Medium,
    m_flow_nominal=10,
    tau=0) "Sensor configured to use a steady-state model for the density"
    annotation (Placement(transformation(extent={{28,-10},{48,10}})));
equation
  connect(ramp.y, masFloRat.m_flow_in) annotation (Line(
      points={{-69,8},{-50,8}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(masFloRat.ports[1], senDyn.port_a) annotation (Line(
      points={{-30,4.44089e-16},{-20,4.44089e-16},{-20,0},{-10,0}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(senDyn.port_b, senSteSta.port_a) annotation (Line(
      points={{10,0},{28,0}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(senSteSta.port_b, sin.ports[1]) annotation (Line(
      points={{48,0},{60,0}},
      color={0,127,255},
      smooth=Smooth.None));
    annotation (Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,
            -100},{100,100}}), graphics),
experiment(StopTime=60),
__Dymola_Commands(file="modelica://IDEAS/Resources/Scripts/Dymola/Fluid/Sensors/Examples/VolumeFlowRate.mos"
        "Simulate and plot"),
    Documentation(info="<html>
<p>
This example tests the volume flow rate sensor.
One sensor is configured to be steady-state, and the other is 
configured to be dynamic.
Note that steady-state sensors can lead to numerical problems
if used incorrectly. 
See
<a href=\"modelica://IDEAS.Fluid.Sensors.UsersGuide\">
IDEAS.Fluid.Sensors.UsersGuide</a> for an explanation.
</p>
</html>", revisions="<html>
<ul>
<li>
August 31, 2013 by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"));
end VolumeFlowRate;

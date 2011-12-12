within IDEAS.Buildings.Components.BaseClasses;
model SwWindowResponse "shortwave window respones"

extends Modelica.Blocks.Interfaces.BlockIcon;

  parameter Integer nLay(min=1) "number of layers of the wall";

  parameter Real[:,nLay+1] SwAbs
    "absorbed solar radiation for each layer for look-up table as function of angle of incidence";
  parameter Real[:,2] SwTrans
    "transmitted solar radiation for look-up table as function of angle of incidence";

  Modelica.Blocks.Interfaces.RealInput solDir
    "direct solar illuminance on surface se"
    annotation (Placement(transformation(extent={{-120,40},{-80,80}})));
  Modelica.Blocks.Interfaces.RealInput solDif
    "diffuse solar illuminance on surface s"
    annotation (Placement(transformation(extent={{-120,0},{-80,40}})));
  Modelica.Blocks.Interfaces.RealInput angInc "angle of incidence"
    annotation (Placement(transformation(extent={{-120,-80},{-80,-40}})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a[nLay] iSolAbs
    "solar absorptance in the panes"
    annotation (Placement(transformation(extent={{-10,90},{10,110}})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a iSolDir
    "transmitted direct solar riadtion"
    annotation (Placement(transformation(extent={{-30,-110},{-10,-90}})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a iSolDif
    "transmitted difuse solar riadtion"
    annotation (Placement(transformation(extent={{10,-110},{30,-90}})));
  IDEAS.Buildings.Components.BaseClasses.AngleOfIncidence angDir
    "angle of incidence conversion"
    annotation (Placement(transformation(extent={{-58,-52},{-40,-34}})));
  Modelica.Blocks.Tables.CombiTable1Ds SwAbsDir(table=SwAbs, smoothness=
        Modelica.Blocks.Types.Smoothness.LinearSegments)
    "lookup table for AOI dependent absorptance"                                                      annotation (Placement(
        transformation(
        extent={{-9,-9},{9,9}},
        rotation=90,
        origin={-29,-11})));
  Modelica.Blocks.Tables.CombiTable1Ds SwTransDir(table=SwTrans, smoothness=
        Modelica.Blocks.Types.Smoothness.LinearSegments,
    columns={2}) "lookup table for AOI dependent transmittance" annotation (Placement(
        transformation(
        extent={{-9,-9},{9,9}},
        rotation=90,
        origin={-3,-11})));
  Modelica.Blocks.Tables.CombiTable1Ds SwAbsDif(table=SwAbs, smoothness=
        Modelica.Blocks.Types.Smoothness.LinearSegments)
    "lookup table for diffuse absorptance"                                                      annotation (Placement(
        transformation(
        extent={{-9,-9},{9,9}},
        rotation=90,
        origin={23,-11})));
  Modelica.Blocks.Tables.CombiTable1Ds SwTransDif(table=SwTrans, smoothness=
        Modelica.Blocks.Types.Smoothness.LinearSegments)
    "lookup table for diffuse transmittance"                                                      annotation (Placement(
        transformation(
        extent={{-9,-9},{9,9}},
        rotation=90,
        origin={49,-11})));
  Modelica.Blocks.Sources.Constant angDif(k=60)
    annotation (Placement(transformation(extent={{-90,-38},{-72,-20}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow[nLay] Abs_flow
    "solar absorptance in the panes source"
    annotation (Placement(transformation(extent={{-8,-8},{8,8}},
        rotation=90,
        origin={-8.88178e-016,78})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow Dir_flow
    "transmitted direct solar riadtion source"
    annotation (Placement(transformation(extent={{-8,-8},{8,8}},
        rotation=-90,
        origin={-20,-78})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow Dif_flow
    "transmitted difuse solar riadtion source"
    annotation (Placement(transformation(extent={{-8,-8},{8,8}},
        rotation=-90,
        origin={20,-78})));
  Modelica.Blocks.Math.Product[nLay] SwAbsDirProd annotation (Placement(
        transformation(
        extent={{-7,-7},{7,7}},
        rotation=90,
        origin={-33,19})));
  Modelica.Blocks.Math.Product SwTransDirProd annotation (Placement(
        transformation(
        extent={{-7,-7},{7,7}},
        rotation=90,
        origin={-7,19})));
  Modelica.Blocks.Math.Product[nLay] SwAbsDifProd annotation (Placement(
        transformation(
        extent={{-7,-7},{7,7}},
        rotation=90,
        origin={19,17})));
  Modelica.Blocks.Math.Product SwTransDifProd annotation (Placement(
        transformation(
        extent={{-7,-7},{7,7}},
        rotation=90,
        origin={45,17})));
  Modelica.Blocks.Math.Add[nLay] add
    annotation (Placement(transformation(extent={{8,-8},{-8,8}},
        rotation=-90,
        origin={-32,48})));
equation
  connect(angDir.angIncDeg, SwAbsDir.u) annotation (Line(
      points={{-40,-43},{-29,-43},{-29,-21.8}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(angDir.angIncDeg, SwTransDir.u) annotation (Line(
      points={{-40,-43},{-3,-43},{-3,-21.8}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(angDif.y, SwAbsDif.u) annotation (Line(
      points={{-71.1,-29},{23,-29},{23,-21.8}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(angDif.y, SwTransDif.u) annotation (Line(
      points={{-71.1,-29},{49,-29},{49,-21.8}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(angInc, angDir.angInc) annotation (Line(
      points={{-100,-60},{-66,-60},{-66,-43},{-58,-43}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(Abs_flow.port, iSolAbs) annotation (Line(
      points={{4.89859e-016,86},{0,86},{0,100}},
      color={191,0,0},
      smooth=Smooth.None));
  connect(Dir_flow.port, iSolDir) annotation (Line(
      points={{-20,-86},{-20,-100}},
      color={191,0,0},
      smooth=Smooth.None));
  connect(Dif_flow.port, iSolDif) annotation (Line(
      points={{20,-86},{20,-100}},
      color={191,0,0},
      smooth=Smooth.None));
  connect(solDif, SwTransDifProd.u1) annotation (Line(
      points={{-100,20},{-62,20},{-62,2},{40.8,2},{40.8,8.6}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(solDir, SwTransDirProd.u1) annotation (Line(
      points={{-100,60},{-60,60},{-60,4},{-11.2,4},{-11.2,10.6}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(SwAbsDir.y, SwAbsDirProd.u2) annotation (Line(
      points={{-29,-1.1},{-29,13.45},{-28.8,13.45},{-28.8,10.6}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(SwAbsDif.y, SwAbsDifProd.u2) annotation (Line(
      points={{23,-1.1},{23,4.45},{23.2,4.45},{23.2,8.6}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(SwTransDir.y[1], SwTransDirProd.u2) annotation (Line(
      points={{-3,-1.1},{-3,13.45},{-2.8,13.45},{-2.8,10.6}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(SwTransDif.y[1], SwTransDifProd.u2) annotation (Line(
      points={{49,-1.1},{49,3.45},{49.2,3.45},{49.2,8.6}},
      color={0,0,127},
      smooth=Smooth.None));

for i in 1:nLay loop
  connect(solDir, SwAbsDirProd[i].u1) annotation (Line(
      points={{-100,60},{-60,60},{-60,4},{-37.2,4},{-37.2,10.6}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(solDif, SwAbsDifProd[i].u1) annotation (Line(
      points={{-100,20},{-62,20},{-62,2},{14.8,2},{14.8,8.6}},
      color={0,0,127},
      smooth=Smooth.None));
end for;

  connect(SwTransDifProd.y, Dif_flow.Q_flow) annotation (Line(
      points={{45,24.7},{45,32},{66,32},{66,-44},{20,-44},{20,-70}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(SwTransDirProd.y, Dir_flow.Q_flow) annotation (Line(
      points={{-7,26.7},{-7,50},{80,50},{80,-54},{-20,-54},{-20,-70}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(SwAbsDirProd.y, add.u2) annotation (Line(
      points={{-33,26.7},{-33,31.35},{-36.8,31.35},{-36.8,38.4}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(SwAbsDifProd.y, add.u1) annotation (Line(
      points={{19,24.7},{19,32},{-27.2,32},{-27.2,38.4}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(add.y, Abs_flow.Q_flow) annotation (Line(
      points={{-32,56.8},{-32,62},{-4.89859e-016,62},{-4.89859e-016,70}},
      color={0,0,127},
      smooth=Smooth.None));
  annotation (Diagram(graphics));
end SwWindowResponse;
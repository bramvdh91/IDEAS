within IDEAS.Examples.TwinHouses.BaseClasses.Data.Constructions;
record door_int
  extends IDEAS.Buildings.Data.Interfaces.Construction(
    final mats={IDEAS.Examples.TwinHouses.BaseClasses.Data.Materials.wooddoor(d=0.04)});
end door_int;

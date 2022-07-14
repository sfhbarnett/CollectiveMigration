# CollectiveMigration
This is code for analising collecive cell migration (CCM) data although in practice it could also be applied to other data sources. This is downstream from particle-image velocimetry processing to generate a time-series vectorfield which is the input to this package. The package expects input data to be a series of .txt files (One for each timepoint) in columns of order x, y, u, v where u and v are the vector components at point x,y.

The package calculates vital statics for charactering CCM including root-mean-square velocity, correlation length, persistance length and instantaneous order parameter. There is also support for analysing rotational behaviour and invasion. The scripts can also output alignment maps and orientation maps.

For example scripts please run:

main_monolayer.m for FOVs that cover the entire field of view

main_pattern.m for circularly patterned cells

main_invasion.m for circularly patterned cells that subsequently invade the surrounding space.

Visualisation of cell movement (Output will be higher resoltion).

<img src="https://user-images.githubusercontent.com/45679976/175018563-fde659dc-834b-4715-9932-359bd6986e54.gif" width="400">

Requires natural sort for matlab: https://www.mathworks.com/matlabcentral/fileexchange/47434-natural-order-filename-sort

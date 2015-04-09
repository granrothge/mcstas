#SNS Instrument files for Mcstas

To compile these instruments, the component files in the ../components driectory are required.

##ARCS_full.instr 
A full model of the ARCS instrument[1]. It has a sample kernel that will provides n \delta functions in energy transfer and 2\theta, where n is a number of equally spaced points around the straight through beam. 
The output of the simulation is a Nexus[2] file that can be read in Mantid [3]. The ability to write Nexus files ready for Mantid is a relatively new feature so to run this simulation properly, you will need to use the current Mcstas development version rather than the release version.

[1] http://neutrons.ornl.gov/arcs
[2] http://www.nexusformat.org/
[3] http://www.mantidproject.org

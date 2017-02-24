#SNS Instrument files for Mcstas

To compile these instruments, the component files in the ../components driectory are required.

##ARCS_full.instr
A full model of the ARCS instrument[1]. It has a sample kernel that will provides n &#948; functions in energy transfer and 2&theta;, where n is a number of equally spaced points around the straight through beam.
The output of the simulation is a Nexus[2] file that can be read in Mantid [3].

##ARCS_full_sqw.instr
A full model of the ARCS instrument[1]. It contains the IstropicSqw kernel[4] in the sample position.  
With model3.sqw that will provide a model of the resolution for the He recoil line.
The output of the simulation is a Nexus[2] file that can be read in Mantid [3].


[1] http://neutrons.ornl.gov/arcs
[2] http://www.nexusformat.org/
[3] http://www.mantidproject.org
[4] E. Farhi et al. Journal of Computational Physics 228 (2009) 5251–5261

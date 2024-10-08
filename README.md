# RBSamping: A Resolution-based Sampling Algorithm for InSAR Surface Displacement Data

If using this code, please cite the following paper(s):

Lohman, R. B., and M. Simons (2005), Some thoughts on the use of InSAR data to constrain models of surface deformation: Noise structure and data downsampling, Geochem. Geophys. Geosyst., 6, Q01007, doi:10.1029/2004GC000841

## Introductions to R-based sampling
Unlike conventional quad-tree sampling, R-based sampling samples the data based on the resolution matrix of data (please refer to the Lohman and Simons (2005) paper for mathematical theories). This can result in better coverage of data at structures caused by the deformation source of interest, as long as the user has some prior knowledge of the source.

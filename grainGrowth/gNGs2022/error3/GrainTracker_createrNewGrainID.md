Hello,
Recently, I want to use EBSD data for the large-scale phase field simulation. However, I found that an error when `GrainTracker` automatically creates a new GrainID for some reason, which I think is probably due to the EBSD data file not being able to automatically create a new GrainID data or the `EBSDAvgData` type of data,

Here is part of the error message displayed to the terminal, and two input files,
```
[36m
*** Info ***
Using ./09_local_ebsd_misori_GBanisotropy/out_09_local_ebsd_misori_GBanisotropy_cp/0055 for recovery.[39m
[36mThe following total 2 aux variables:
  delta_theta
  kappa_op
are added for automatic output by MaterialOutputAction.[39m
Framework Information:
MOOSE Version:           git commit 9c2c6fe on 2022-03-23
LibMesh Version:         
PETSc Version:           3.16.5
SLEPc Version:           3.16.2
Current Time:            Thu Sep 22 20:09:56 2022
Executable Timestamp:    Thu Sep 22 20:09:39 2022

Parallelism:
  Num Processors:          112
  Num Threads:             1

Mesh: 
  Parallel Type:           distributed
  Mesh Dimension:          2
  Spatial Dimension:       2
  Nodes:                   
    Total:                 139183
    Local:                 420
    Min/Max/Avg:           353/2789/1242
  Elems:                   
    Total:                 124133
···
Time Step 56, time = 15.4223, dt = 0.417725
 0 Nonlinear |R| = [32m9.180162e-01[39m
 1 Nonlinear |R| = [32m5.768520e-03[39m
 2 Nonlinear |R| = [32m7.708989e-07[39m
 3 Nonlinear |R| = [32m5.226698e-11[39m
[32m Solve Converged![39m
  Finished Solving                                                                       [[33m 10.09 s[39m] [[33m   10 MB[39m]

Grain Tracker Status:
Grains active index 0: 75 -> 75
Grains active index 1: 51 -> 51
Grains active index 2: 44 -> 45++
Grains active index 3: 38 -> 38
Grains active index 4: 34 -> 34
Grains active index 5: 28 -> 28
Grains active index 6: 19 -> 19
Grains active index 7: 10 -> 10
···
[33mNucleating Grain Detected  (variable index: 0)
[39m[33mNucleating Grain Detected  (variable index: 2)
[39m[32mMarking Grain 182 as INACTIVE (variable index: 0)
[39m[33m
*****************************************************************************
Couldn't find a matching grain while working on variable index: 0
Creating new unique grain: 329
Grain ID: 329
Ghosted Entities: 
Local Entities: 
Halo Entities: 145153 145415 175509 175511 175551 175553 175555 175556 175559 175560 175561 175563 175564 175566 175567 175569 175570 175572 175573 175574 
Periodic Node IDs: 
BBoxes:
Max: (x,y,z)=( 122.867,  151.803,        0) Min: (x,y,z)=( 120.861,  149.799,        0)
Status:  MARKED
Orig IDs (rank, index): (100, 1) 
Var_index: 0
Min Entity ID: 175562
···
*****************************************************************************
[39mFinished inside of GrainTracker


[31m
*** ERROR ***
The following error occurred in the object "ebsd_reader", of type "EBSDReader".

Error! Index out of range in EBSDReader::indexFromIndex(), index: 0 size: 0[39m

application called MPI_Abort(MPI_COMM_WORLD, 1) - process 1

[31m
*** ERROR ***
The following error occurred in the object "ebsd_reader", of type "EBSDReader".

Error! Index out of range in EBSDReader::indexFromIndex(), index: 254 size: 0[39m


[31m
*** ERROR ***
The following error occurred in the object "ebsd_reader", of type "EBSDReader".

Error! Index out of range in EBSDReader::indexFromIndex(), index: 11 size: 0[39m

application called MPI_Abort(MPI_COMM_WORLD, 1) - process 2
...
```
The detailed information is as follows,
- the message displayed to terminal: slurm-7511327.txt
- the input file: ebsd_local_misori.i
- the ebsd data file: local_Ti700du_5minFill_refine_1.inl



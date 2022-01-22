import numpy as np

def writesh(dirname, filename,editFileName, threads, file, outputshfilename):
    shfile = """#!/bin/bash
# mkdir ../include/%s
# mkdir ../src/%s

cp ~/projects/moose/modules/phase_field/include/%s/%s.h ~/projects/luwu/include/%s/%s.h

cp ~/projects/moose/modules/phase_field/src/%s/%s.C ~/projects/luwu/src/%s/%s.C

code ~/projects/luwu/include/%s/%s.h
code ~/projects/luwu/src/%s/%s.C
    """ % (dirname,dirname,dirname,filename,dirname,editFileName,dirname,filename,dirname,editFileName,dirname,editFileName,dirname,editFileName)
    with open(outputshfilename, "w") as f:
        f.write(shfile)
    f.close()

writesh( "materials", "DeformedGrainMaterial","DeformedGrainMaterialGG", 1, 1, "1.sh")

# E:\Github\moose\moose\modules\phase_field\src\materials\ComputePolycrystalElasticityTensor.C
# /home/pengwei/projects/moose/modules/phase_field/src/materials/.C



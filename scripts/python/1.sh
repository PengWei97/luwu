#!/bin/bash
# mkdir ../include/materials
# mkdir ../src/materials

cp ~/projects/moose/modules/phase_field/include/materials/DeformedGrainMaterial.h ~/projects/luwu/include/materials/DeformedGrainMaterialGG.h

cp ~/projects/moose/modules/phase_field/src/materials/DeformedGrainMaterial.C ~/projects/luwu/src/materials/DeformedGrainMaterialGG.C

code ~/projects/luwu/include/materials/DeformedGrainMaterialGG.h
code ~/projects/luwu/src/materials/DeformedGrainMaterialGG.C
    
#!/bin/bash
cd /home/pw-moose/projects/luwu/examples/phasefield/GBAnisotropy
tar -cvf - ./grain_growth | pigz -9 -p 35 > older_Result.tgz 
tar -cvf - gbAnisotropyGrainGrowth_15 | pigz -9 -p 35 > gbAnisotropyGrainGrowth_15.tgz 
tar -cvf - gbAnisotropyGrainGrowth_16 | pigz -9 -p 35 > gbAnisotropyGrainGrowth_16.tgz 
tar -cvf - gbAnisotropyGrainGrowth_17 | pigz -9 -p 35 > gbAnisotropyGrainGrowth_17.tgz 
tar -cvf - gbAnisotropyGrainGrowth_18 | pigz -9 -p 35 > gbAnisotropyGrainGrowth_18.tgz 
tar -cvf - gbAnisotropyGrainGrowth_19 | pigz -9 -p 35 > gbAnisotropyGrainGrowth_19.tgz 
tar -cvf - gbAnisotropyGrainGrowth_20 | pigz -9 -p 35 > gbAnisotropyGrainGrowth_20.tgz 
tar -cvf - gbAnisotropyGrainGrowth_21 | pigz -9 -p 35 > gbAnisotropyGrainGrowth_21.tgz 
tar -cvf - gbAnisotropyGrainGrowth_22 | pigz -9 -p 35 > gbAnisotropyGrainGrowth_22.tgz 
tar -cvf - gbAnisotropyGrainGrowth_23 | pigz -9 -p 35 > gbAnisotropyGrainGrowth_23.tgz 
# 目的
1. grain_growth_2D_graintracker_numAdjacentGrain.i
2. 1600个初始晶粒，模拟了1e4
3. 算了9.5天
4. 使用pw-moose@pwmoose-PowerEdge-T640
5. 使用网格自适应

```bash
mpiexec -np 35 ~/projects/luwu/luwu-opt -i grain_growth_2D_graintracker_numAdjacentGrain.i > 1600_02.log 
```


# 晶界迁移率各向异性
## gg_100_anisotropicTheta_mob_03
> 100个晶粒模拟，考虑晶界迁移率各向异性，5倍
> 100个晶粒中有5个欧拉角为90，其他为43~45
> 耗时：68.56h-2.85D, end_time = 7516.66
> 结果：演化到最后，只有一个90晶粒异常长大
> 结论：晶界迁移率各向异性只能确定晶界迁移的速率，不能确定迁移的方向
> 
```bash
mpiexec -np 35 ~/projects/luwu/luwu-opt -i GBAnisotropic_100.i > 100_01.log
```
## gbAnisotropyGrainGrowth_00
> 10个晶粒模拟，考虑各向同性晶界能
> 耗时：6.59 min
```bash
mpiexec -np 35 ~/projects/luwu/luwu-opt -i GBAnisotropic_10.i > gbAnisotropyGrainGrowth_00.log
```

## gbAnisotropyGrainGrowth_02
> 10个晶粒模拟，考虑晶界迁移率各向异性，5倍
> 10个晶粒中有2个欧拉角为90，其他为43~45
> 耗时：35.01 min
> 结果：演化到最后，只有一个90晶粒异常长大
> 结论：晶界迁移率各向异性只能确定晶界迁移的速率，不能确定迁移的方向
```bash
mpiexec -np 35 ~/projects/luwu/luwu-opt -i GBAnisotropic_10.i > gbAnisotropyGrainGrowth_02.log
```

## gbAnisotropyGrainGrowth_03
> 10个晶粒模拟，考虑晶界迁移率各向异性，10倍
> 10个晶粒中有2个欧拉角为90，其他为43~45
> 耗时：55.5min
```bash
code ~/projects/luwu/examples/phasefield/GBAnisotropy/gbAnisotropyGrainGrowth_0*/out_gbAnisotropyGrainGrowth_04.csv
```

## **gbAnisotropyGrainGrowth_09** ￥￥￥￥￥ 
> 10个晶粒模拟，考虑晶界迁移率各向异性，rate1_HABvsLAB = 4.5; rate2_HABvsLAB = 0.5, **10倍**
> 10个晶粒中有2个欧拉角为90，其他为43~45
> 耗时：30.51min
> 结果：L_max = 0.51, L_min = 0.0051; 模拟结果与gbAnisotropyGrainGrowth_03一样（低角度晶界一样移动）
> **最优**


## gbAnisotropyGrainGrowth_10
> 10个晶粒模拟，考虑晶界迁移率各向异性，rate1_HABvsLAB = 4.95; rate2_HABvsLAB = 0.05, **100倍**
> 10个晶粒中有2个欧拉角为90，其他为43~45
> 耗时：30.51min
> 结果：L_max = 0.51, L_min = 0.51e-2, **三叉点出晶界不稳定**

## gbAnisotropyGrainGrowth_11
> 10个晶粒模拟，考虑晶界迁移率各向异性，rate1_HABvsLAB = 4; rate2_HABvsLAB = 1, **5倍**
> 10个晶粒中有2个欧拉角为90，其他为43~45
> 耗时：39.38min, **低角度晶界缓慢移动**
<!-- > 结果：L_max = 0.51, L_min = 0.51e-2 -->

## gbAnisotropyGrainGrowth_12
> 10个晶粒模拟，考虑晶界迁移率各向异性，rate1_HABvsLAB = 9.9; rate2_HABvsLAB = 0.1, **100倍**
> 10个晶粒中有2个欧拉角为90，其他为43~45
> 耗时：55.93min
> 结果：L_max = 0.01, L_min = 1, **三叉点出晶界不稳定**

## gbAnisotropyGrainGrowth_13
> 10个晶粒模拟，考虑晶界迁移率各向异性，rate1_HABvsLAB = 1; rate2_HABvsLAB = 0, 
> 10个晶粒中有2个欧拉角为90，其他为43~45
> 耗时：8.24min
> 结果：L_max = 0.1, L_min = 0.0, **晶界不稳定**

## gbAnisotropyGrainGrowth_14
> 10个晶粒模拟，考虑晶界迁移率各向异性，rate1_HABvsLAB = 45.5; rate2_HABvsLAB = 0.5, **100倍**
> 10个晶粒中有2个欧拉角为90，其他为43~45
> 耗时：55.93min
> 结果：L_max = 4.7, L_min = 5.1e-2, **晶界极具不稳定，着色异常**
> 

# 晶界能各向异性
## gbAnisotropyGrainGrowth_04
> 10个晶粒模拟，考虑晶界迁移率各向异性，5倍
> 10个晶粒中有2个欧拉角为90，其他为43~45
> 耗时：60.31 min
> 结果：演化到最后，只有一个90晶粒异常长大
> 结论：晶界迁移率各向异性只能确定晶界迁移的速率，不能确定迁移的方向


## gbAnisotropyGrainGrowth_05
> 10个晶粒模拟，考虑晶界能各向异性，rate1_HABvsLAB = 4.5; rate2_HABvsLAB = 0.5, 10倍
> 10个晶粒中有2个欧拉角为90，其他为43~45
> 耗时：56.75min

## ~gbAnisotropyGrainGrowth_06~
> 10个晶粒模拟，考虑晶界能各向异性，rate1_HABvsLAB = 4.9; rate2_HABvsLAB = 0.1, 50倍
> 10个晶粒中有2个欧拉角为90，其他为43~45
> 耗时：56.75min
> 与gbAnisotropyGrainGrowth_05结果一样

## ~gbAnisotropyGrainGrowth_07~
> 10个晶粒模拟，考虑晶界能各向异性，rate1_HABvsLAB = 4.95; rate2_HABvsLAB = 0.05, 100倍
> 10个晶粒中有2个欧拉角为90，其他为43~45
> 耗时：63.79min
> 与gbAnisotropyGrainGrowth_05结果一样

## ~gbAnisotropyGrainGrowth_08~
> 10个晶粒模拟，考虑晶界能各向异性，rate1_HABvsLAB = 4.995; rate2_HABvsLAB = 0.005, 1000倍
> 10个晶粒中有2个欧拉角为90，其他为43~45
> 耗时：58.94min
> 与gbAnisotropyGrainGrowth_05结果一样

# 晶界迁移率+晶界能各向异性
## 
```bash
mpiexec -np 30 ~/projects/luwu/luwu-opt -i GBAnisotropic_10.i > gbAnisotropyGrainGrowth_01.log
```
# 最终
## 晶界迁移率 - gbAnisotropyGrainGrowth_09
> 10个晶粒模拟，考虑晶界迁移率各向异性，rate1_HABvsLAB = 4.5; rate2_HABvsLAB = 0.5, **10倍**
> 10个晶粒中有2个欧拉角为90，其他为43~45
> 耗时：30.51min
> 结果：L_max = 0.51, L_min = 0.0051; 模拟结果与gbAnisotropyGrainGrowth_03一样（低角度晶界一样移动）
> **最优**

## 晶界能 - gbAnisotropyGrainGrowth_15
> 10个晶粒模拟，考虑晶界迁移率各向异性，rate1_HABvsLAB = 4.5; rate2_HABvsLAB = 0.5, **10倍**

## 晶界能-晶界迁移率 - gbAnisotropyGrainGrowth_16

## 弹性能各向异性 - gbAnisotropyGrainGrowth_17

## 弹性能各向异性 - 晶界能-晶界迁移率 -- gbAnisotropyGrainGrowth_18

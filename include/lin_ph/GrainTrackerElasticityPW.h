//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "GrainDataTracker.h"
#include "RankFourTensor.h"
#include "RankTwoTensor.h"

class EulerAngleProvider;

/**
 * Manage a list of elasticity tensors for the grains
 */
class GrainTrackerElasticityPW : public GrainDataTracker<RankFourTensor>
// GrainDataTracker: GrainTracker派生的类模板，以对象为基础，这些对象维护每个晶粒的物理参数
{
public:
  static InputParameters validParams();

  GrainTrackerElasticityPW(const InputParameters & parameters);
  // 常量引用：修饰形参，防止误操作，防止在函数体内修改parameters
  // 被调函数对形参做的任何操作都影响了主调函数中的实参变量。

  // InputParameters：
    // 为了简化和统一moose中对象的创建，必须通过单个InputParameters对象来创建和填充所用输入的系数
    // 确保每一个构造函数是在moose中是统一的
    // 确保可以通过moose的Factory模式来创建每一个对象
    // InputParameters是参数的集合，每个参数都有单独的属性，可用于精细控制对下的行为。
    // 
    // 可以认为是一个数据类型

protected:
  // RankFourTensor newGrain(unsigned int new_grain_id);
  // 这句话不是很理解，对于new_grain_id

  RankTwoTensor newGrain(unsigned int new_grain_id);
  // 设置为旋转张量

  /// generate random rotations when the Euler Angle provider runs out of data (otherwise error out)
  const bool _random_rotations;

  /// unrotated elasticity tensor
  RankFourTensor _C_ijkl;

  /// object providing the Euler angles
  const EulerAngleProvider & _euler;
};

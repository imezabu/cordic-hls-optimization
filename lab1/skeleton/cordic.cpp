//=========================================================================
// cordic.cpp
//=========================================================================
// @brief : A CORDIC implementation of sine and cosine functions.

#include "cordic.h"
#include <math.h>

#include <iostream>

//-----------------------------------
// cordic function
//-----------------------------------
// @param[in]  : theta - input angle
// @param[out] : s - sine output
// @param[out] : c - cosine output
void cordic(theta_type theta, cos_sin_type &s, cos_sin_type &c) {
// -----------------------------
// YOUR CODE GOES HERE
// -----------------------------
  cos_sin_type x = 0.60735;
  cos_sin_type y = 0;
#ifdef FIXED_TYPE // fixed-point design
FIXED_STEP_LOOP:
  for (int step = 0; step < 20; step++) {
    int sigma = (theta<0) ? -1:1;
    cos_sin_type new_x = x-(sigma*(y>>step));
    cos_sin_type new_y= y +(sigma*(x>>step));

    x=new_x;
    y=new_y;
    theta=theta-sigma*cordic_ctab[step];
  }

#else // floating point design

FLOAT_STEP_LOOP:
  for (int step = 0; step < NUM_ITER; step++) {
    int sigma = (theta<0) ? -1:1;
    cos_sin_type new_x = x-sigma*(y / (double)(1ULL << step));
    cos_sin_type new_y= y +sigma*(x / (double)(1ULL << step));

    x=new_x;
    y=new_y;
    theta=theta-sigma*cordic_ctab[step];
  }

#endif
  c=x; s=y;
}

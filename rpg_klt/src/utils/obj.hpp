#include <iostream>
#pragma once

#define max_block_size 256

typedef struct {
	int width;
	int height;
} params_t;

typedef struct {
	int x;
	int y;
} coor_t;

typedef struct {
	int size;
	coor_t list[];
} features;

void fit_block(int N_max_feature, params_t image_param, params_t* block );

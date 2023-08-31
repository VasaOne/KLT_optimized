#include <iostream>
#pragma once

#define max_block_size 256
#define WIDTH_IMAGE 16
#define HEIGHT_IMAGE 9
#define N_MAX_FEATURE
typedef struct {
	int width;
	int height;
} params_t;

typedef struct {
	int x;
	int y;
	int score;
} coor_t;

typedef struct features{
	int size;
	coor_t list[N_MAX_FEATURE];

	features(){ size = 0;};
} features;

void fit_block(int N_max_feature, params_t image_param, params_t* block );

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

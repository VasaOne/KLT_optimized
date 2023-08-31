#pragma once

#include "obj.hpp"
#define L 4
class KLT {
	public:
		KLT(float threshold, params_t image_param, int max_feature);
	        features get_features(float image[][5]);	
		params_t get_block_param();
		float get_threshold();
		params_t get_image_param();		
	private:
		float threshold;
		int max_feature;
		params_t image_param;
		params_t block_param;
};

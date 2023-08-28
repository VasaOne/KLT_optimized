#include "klt.hpp"




KLT::KLT(float threshold, params_t image_param, int max_feature){
	this->max_feature = max_feature;
	this->image_param = image_param;
	this->threshold = threshold;
	fit_block(max_feature, image_param, &(this->block_param));
}

features KLT::get_features(float image[][]){
	return;
}

params_t KLT::get_block_param(){
	return this->block_param;
}

float KLT::get_threshold(){
	return this->threshold;	
}

params_t get_image_param(){
	return this->image_param
}

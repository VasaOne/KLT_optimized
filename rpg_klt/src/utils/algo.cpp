#include "obj.hpp"
#include <iostream>

int get_number_feature(params_t image, int dim){
	int n = (image.width/dim)*(image.height/dim);
	return n;
}

void fit_block(int N_max_feature, params_t image_param, params_t* block ){
	int dim = 1;
	int n_feature = get_number_feature(image_param, dim);
	for(dim = 1; (dim < max_block_size) && (n_feature > N_max_feature);dim*=2){
		n_feature = get_number_feature(image_param, dim);

	
	}
	
	std::cout<< dim/2 << std::endl;
	(*block).width = dim/2;
	(*block).height = dim/2;
	return;
}

features::features(int size){
	this->size = size;
	coor_t list[size];
	return;
}

int get_px_val(int x, int y, int image[]){
	return image[x + y * WIDTH_IMAGE];		
}

int feature_score(int image[], int HookUpTable[], int treshold){
	//corner FAST test
	return 0; 	
}
/*
int main(){
	params_t image = {640,600};
	params_t block;
	int feature = 45000;
	fit_block(feature, image, &block);

	std::cout << "block dim: " << block.width <<"," << block.height  << std::endl;
	return 0;
}

*/



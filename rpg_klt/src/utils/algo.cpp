#include "obj.hpp"

int get_number_feature(params_t image, int dim){
	int n = (image.width/dim)*(image.height/dim);
	return n;
}

void fit_block(int N_max_feature, params_t image_param, params_t* block ){
	int dim = 1;
	int n_feature = get_number_feature(image_param, dim);
	for(dim = 1; (dim < max_block_size) && (n_feature > N_max_feature); dim *=2 ){
		n_feature = get_number_feature(image_param, dim);
	
	}
	std::cout << n_feature << std::endl;
	(*block).width = dim;
	(*block).height = dim;
	return;
}

int main(){
	params_t image = {640,600};
	params_t block;
	int feature = 45000;
	fit_block(feature, image, &block);

	std::cout << "block dim: " << block.width <<"," << block.height  << std::endl;
	return 0;
}



#include "obj.hpp"
#include "klt.hpp"
#include "hookup.hu"
#include "fast.hu"

__device__ int FASTalgorithme(int x, int y,int image[], int threshold){
	int score = 0;
	
	if(get_HKpoint(FASTcalculus(x,y, image, threshold))){ // test if the consecutive brighter px condition is respected
		score = feature_score_calculus( x, y, image);
	}
	else {
		score = 0;
	}
	return score;
}


__global__ void kernel_feature_calculus(int image[], params_t block_param, features *ftr_final_list, int threshold){
	extern __shared__ coor_t feature_list[]; // list of all the features to find the best one with a reduction after
	
	int max_score = 0;
	int new_score = 0;
	int x_px, y_px;
	//calculus of features
	for(int line = 0; line < block_param.height / L ; line ++) {
		//new score calculus
		x_px = blockIdx.x * block_param.width + threadIdx.x;
		y_px = blockIdx.y * block_param.height + threadIdx.y * (block_param.height / L) + line;
		new_score = FASTalgorithme( x_px, y_px, image, threshold);
		__syncthreads(); 
		if (max_score < new_score){
			new_score = max_score;
			feature_list[threadIdx.x + threadIdx.y * L ].x = x_px;
			feature_list[threadIdx.x + threadIdx.y * L ].y = y_px;
			feature_list[threadIdx.x + threadIdx.y * L ].score = max_score;
		}
	}

	//reduction to find the best feature within the block 
	int t_id = threadIdx.x + threadIdx.y * L ;
	int nb_threads_alive = L * block_param.width / 2;
	while((nb_threads_alive > 1) && (t_id <= nb_threads_alive) ){
		nb_threads_alive /=2;
		if ( feature_list[t_id + nb_threads_alive].score > feature_list[t_id].score){
			feature_list[t_id].x = feature_list[t_id + nb_threads_alive].x;
			feature_list[t_id].y = feature_list[t_id + nb_threads_alive].y;
			feature_list[t_id].score = feature_list[t_id + nb_threads_alive].score;
		} // if not, we already have the best feature on this position
	}
	if(t_id == 0){ // last t_id should be 0 accordind to the reduction process, it containes the best feature
		//ftr_final_list.list[blockIdx.x ] = (*feature_list)[0]; //not finished 
		//dont forget to uptade the lenght with atomic cuda operation
	}
	return;
}

void wrapper_kernel_feature_calculus(int image[], params_t block_param, params_t img_param, features* ftr_final_list, int threshold){

	//arg management
	int *img_device;
	cudaMalloc((void **) &img_device, sizeof(int)*img_param.width*img_param.height );
	cudaMemcpy(img_device, image, sizeof(int)*img_param.width*img_param.height, cudaMemcpyHostToDevice);
	features *ftr_device;
	cudaMalloc((void **) &ftr_device, sizeof(features));
	cudaMemcpy(ftr_device, ftr_final_list, sizeof(features), cudaMemcpyHostToDevice);


        int x_block = (int) img_param.width/block_param.width;
        int y_block = (int) img_param.height/block_param.height;
	dim3 blockDimension(x_block, y_block);
	switch(block_param.width){
	case 256 :	
	{
		dim3 threadsPerBlock(256,1);
		kernel_feature_calculus<<<blockDimension, threadsPerBlock, block_param.width*block_param.height*sizeof(coor_t)>>>(img_device, block_param, ftr_device, threshold);
		break;
	}
	case 128 :
	{
		dim3 threadsPerBlock(128,2);
		kernel_feature_calculus<<<blockDimension, threadsPerBlock, block_param.width*block_param.height*sizeof(coor_t)>>>(img_device, block_param, ftr_device, threshold);
		break;
	}
	default:
	{
		dim3 threadsPerBlock(block_param.width,4);
		kernel_feature_calculus<<<blockDimension, threadsPerBlock, block_param.width*block_param.height*sizeof(coor_t)>>>(img_device, block_param, ftr_device, threshold);
		break;
	}
	}
	cudaMemcpy(ftr_final_list, ftr_device, sizeof(int)*img_param.width*img_param.height, cudaMemcpyDeviceToHost);
	cudaFree(img_device);
	cudaFree(ftr_device);

	return;
}

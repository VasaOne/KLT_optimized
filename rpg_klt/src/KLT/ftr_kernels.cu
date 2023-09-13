#include "obj.hpp"
#include "klt.hpp"
#include "hookup.hu"
#include "fast.hu"
#include <iostream>

__device__ int alo(){
	int x = 5;
	return x;
}

__device__ int FASTalgorithme(int x, int y,int image[], int *threshold){
	int score = 0;
	score = FASTcalculus(x,y, image, (*threshold) );
	/*
	if(get_HKpoint(FASTcalculus(x,y, image, (*threshold) ))){ // test if the consecutive brighter px condition is respected
		score = feature_score_calculus( x, y, image);
	}
	else {
		score = 0;
	}*/
	return score;
}


__global__ void kernel_feature_calculus(int *image, params_t *block_param, coor_t *ftr_final_list, int *threshold){

	
	extern __shared__ coor_t feature_list[]; // list of all the features to find the best one with a reduction after
	int t_id = threadIdx.x + threadIdx.y * blockDim.x;
	int max_score = 0;
	int new_score = 0;
	int x_px, y_px; 
	//calculus of features
	for(int line = 0; line < (*block_param).height / blockDim.y ; line ++) {
		//new score calculus
		x_px = blockIdx.x * (*block_param).width + threadIdx.x;
		y_px = blockIdx.y * (*block_param).height + threadIdx.y + line*blockDim.y;
		new_score = FASTalgorithme( x_px, y_px, image, threshold);

		__syncthreads(); 
		if (max_score < new_score){
			new_score = max_score;
			feature_list[t_id].x = x_px;
			feature_list[t_id].y = y_px;
			feature_list[t_id].score = max_score;
		}
	} 

/*
	//reduction to find the best feature within the block 
	int nb_threads_alive = blockIdx.y *(* block_param).width / 2;
	while((nb_threads_alive > 1) && (t_id <= nb_threads_alive) ){
		//__syncthreads();
		nb_threads_alive /=2;
		if ( feature_list[t_id + nb_threads_alive].score > feature_list[t_id].score){
			feature_list[t_id].x = feature_list[t_id + nb_threads_alive].x;
			feature_list[t_id].y = feature_list[t_id + nb_threads_alive].y;
			feature_list[t_id].score = feature_list[t_id + nb_threads_alive].score;
		} // if not, we already have the best feature on this position
	}
	if(t_id == 0){ // last t_id should be 0 accordind to the reduction process, it containes the best feature
		ftr_final_list[0].x = feature_list[0].x; //not finished
	        ftr_final_list[0].y = feature_list[0].y; //not finished
		ftr_final_list[0].score = feature_list[0].score; //not finished	
		//dont forget to uptade the lenght with atomic cuda operation
	}*/
	 
	return;
}

__global__ void kernel_tester(int *img, coor_t* ftr, int * thresh, params_t * blk){
	//printf("marche \n");
	extern __shared__ coor_t common[];
	ftr[0].x = (* thresh)+ (*blk).width;
	ftr[0].y = img[615*364];
	return;
}

void wrapper_kernel_feature_calculus(int image[], params_t block_param, params_t img_param, features * ftr_final_list, int threshold){

	//arg management
	int *img_device;
	cudaMalloc((void **) &img_device, sizeof(int)*img_param.width*img_param.height );
	cudaMemcpy(img_device, image, sizeof(int)*img_param.width*img_param.height, cudaMemcpyHostToDevice);


	coor_t *lst_ftr_device;
	cudaMalloc((void **) &lst_ftr_device, sizeof(coor_t)*N_MAX_FEATURE);
	//cudaMemcpy(lst_ftr_device, (*ftr_final_list).list, sizeof(coor_t), cudaMemcpyHostToDevice);


	int * thresh_device;
	int * thresh_host = &threshold;
	cudaMalloc((void **) &thresh_device, sizeof(int));
	cudaMemcpy(thresh_device, thresh_host, sizeof(int), cudaMemcpyHostToDevice);

	params_t * block_device;
	params_t * block_host = &block_param;
	cudaMalloc((void **) &block_device, sizeof(params_t));
	cudaMemcpy(block_device, block_host,sizeof(params_t),cudaMemcpyHostToDevice);

        int x_block = (int) img_param.width/block_param.width;
        int y_block = (int) img_param.height/block_param.height;
	dim3 blockDimension(x_block, y_block);
	

	dim3 threadsPerBlock(1,1);
	switch(block_param.width){
	case 256 :	{
		threadsPerBlock.x = block_param.width;
		threadsPerBlock.y = 1;
		break;
	}
	case 128 : {
                threadsPerBlock.x = block_param.width;
                threadsPerBlock.y = 2;
		break;
	}
	default: {
                threadsPerBlock.x = block_param.width;
                threadsPerBlock.y = 4;
		break;
	}

	}

	kernel_feature_calculus<<<blockDimension, threadsPerBlock, sizeof(coor_t)*threadsPerBlock.x*threadsPerBlock.y>>>(img_device, block_device, lst_ftr_device, thresh_device);
	//kernel_tester<<<blockDimension,threadsPerBlock, sizeof(coor_t)*threadsPerBlock.x*threadsPerBlock.y>>>(img_device,lst_ftr_device, thresh_device, block_device);
	//cudaDeviceSynchronize();

	cudaError_t error = cudaGetLastError();
	if (error != cudaSuccess) {
    		printf("CUDA error: %s\n", cudaGetErrorString(error));
	}

	
        cudaMemcpy( (*ftr_final_list).list, lst_ftr_device, sizeof(coor_t)*N_MAX_FEATURE, cudaMemcpyDeviceToHost);
        std::cout << (*ftr_final_list).list[0].x << std::endl;
        std::cout << (*ftr_final_list).list[0].y << std::endl;
	cudaFree(img_device);
	cudaFree(lst_ftr_device);
	cudaFree(thresh_device);
	cudaFree(block_device); 

	return;
}

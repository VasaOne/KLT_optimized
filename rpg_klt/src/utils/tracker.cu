#include <stdio.h>

#include "obj.hpp"
#include "fast.hu"

#define range_condition(x,y,element_id) (0<= x + elementFAST[element_id][0]) && (x + elementFAST[element_id][0] < WIDTH_IMAGE) && (0 <= y + elementFAST[element_id][1]) && (y + elementFAST[element_id][1] < HEIGHT_IMAGE) //macro to check if a point is inside the image

#define img_val_px(x, y, image) image[y*WIDTH_IMAGE + x]


 __device__ int elementFAST[16][2] = // {... {x,y} ...}
{
	{0,3},
	{1,3},
	{2,2},
	{3,1},
	{3,0},
	{3,-1},
	{2,-2},
	{1,-3},
	{0,-3},
	{-1,-3},
	{-2,-2},
	{-3,-1},
	{-3,0},
	{-3,1},
	{-2,2},
	{-1,3}
};


__device__ int  fastBrighter(int center_px, int orbit_px, int threshold){
	if( ( (center_px - orbit_px) >= threshold) || ( (orbit_px - center_px) >= threshold ) ){
		return 1;
	}
	return 0;
}



__device__ int  FASTcalculus(int x, int y, int image[], int threshold){
	int val = 0;
	for (int element_id = 0; element_id < 16; element_id ++){ // calculus of sum of FAST elements
		if (range_condition( x, y, element_id ) ){ // check if pixel is inside the range of the image
                        int nx = x + elementFAST[element_id][0];
                        int ny = y + elementFAST[element_id][1];			
			val = val | ( fastBrighter( img_val_px(x, y, image), img_val_px(nx, ny, image), threshold ) << element_id);
		}
	}
	return val;
}

__device__ int feature_score_calculus(int x_center, int y_center, int image[]){
	int score = 0;
	for(int element_id = 0; element_id < 16; element_id ++){
		int nx = x_center + elementFAST[element_id][0];
		int ny = y_center + elementFAST[element_id][1];
		score += abs( img_val_px(nx, ny, image) - img_val_px(x_center, y_center, image) );
	}
	return score;
	

}

/*
__global__ void testor(){
	int dk = fastBrighter(56, 68, 30);
	int br_1 = fastBrighter(56, 198,30);
	int br_2 = fastBrighter(192, 56, 30);
	printf("should be dark: %i \n", dk);
	printf("should be brighter: %i \n", br_1);
	printf("should be brighter: %i \n", br_2);
	
	int small_img[16*9] = { 0,0,0,0,115,115,115,115,115,30,75,75,0,0,0,0,
       			        0,0,0,0,150,156,154,153,150,75,76,45,0,0,0,0,
                                0,0,0,4,124,124,128,127,126,12,75,46,0,0,0,0,
                                0,0,0,0,115,115,115,115,115,30,75,75,0,0,0,0,
                                0,0,0,0,150,156,154,153,150,75,76,45,0,0,0,0,
                                0,0,0,4,12,124,128,127,126,12,75,46,0,0,0,0,
                                0,0,0,0,11,115,115,115,115,30,75,75,0,0,0,0,
                                0,0,0,0,150,156,154,153,150,75,76,45,0,0,0,0,
                                0,0,0,4,12 ,14 ,12 ,127,19 ,12,7 ,6 ,0,0,0,0	
	};
	printf("get 8 7 value: %i \n", img_val_px(8, 7, small_img));
	int fast_result = FASTcalculus(8, 4, small_img, 30);
	printf("should be I dont know: %i \n", fast_result);

	int score_ftr = feature_score_calculus(8,4,small_img);
	printf("score of the feature (8,4): %i \n", score_ftr);
	return;
}

int main(){
	testor<<<1,1>>>();
	cudaDeviceSynchronize();
	return 1;
}
*/

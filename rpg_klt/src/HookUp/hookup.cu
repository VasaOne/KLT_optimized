#include <stdio.h>
#include "hookup.hu"




__device__ void set_HKpoint(int addr){
	HookUpTable[addr & 0x1FF] = HookUpTable[addr & 0x1FF] | (1 << (addr >> 13));
}

__device__ void clear_HKpoint(int addr){
	HookUpTable[addr & 0x1FF] = HookUpTable[addr & 0x1FF] & (~(1 << (addr >> 13)));
}

__device__ int get_HKpoint(int addr){
	return HookUpTable[addr & 0x1FF] & (1 << (addr >> 13));
}

__global__ void HookUpInit(int pointcondition){
	int addr = blockIdx.x * blockDim.x + threadIdx.x;
	int count = 0; // count the maximum of consecutive 1
	for(int loop = 0; loop < 2; loop ++){ // count 2 times to include the 16 -> 1 path
		for(int it = 0; it < 16; it ++){
			if((addr & (1 << it)) >> it ){
				count ++;
				if (count == pointcondition){
					set_HKpoint(addr);
					return;
				}
			} 
			else {
				count = 0;
			}
		}
	}
	clear_HKpoint(addr);
}
__global__ void testor(){
	printf("for 3: %i \n", get_HKpoint(3));
	printf("for 5: %i \n", get_HKpoint(5));
	printf("for 15: %i \n", get_HKpoint(15));
	printf("for jsp mais ca doit faire faux %i \n", get_HKpoint(0b11101110) );

}
int main(){
	printf("expected: 4");
	HookUpInit<<<32,256>>>(4);
	testor<<<1,1>>>();
	cudaDeviceSynchronize();
	return 1;
}

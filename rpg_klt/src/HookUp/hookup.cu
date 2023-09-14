#include <stdio.h>
#include "hookup.hu"
#include "klt.hpp"


__device__ char HookUpTable[HK_size];

__device__ void set_HKpoint(int addr){
	//printf("full addr: %i place: %i, val: %i \n", addr,addr & 0x1FFF, 1 << (addr >> 13) );
	HookUpTable[addr & 0x1FFF] = (HookUpTable[addr & 0x1FFF] | (1 << (addr >> 13)));
}

__device__ void clear_HKpoint(int addr){
	HookUpTable[addr & 0x1FFF] = HookUpTable[addr & 0x1FFF] & (~(1 << (addr >> 13)));
}

__device__ int get_HKpoint(int addr){
	return HookUpTable[addr & 0x1FFF] & (1 << (addr >> 13));
}

__global__ void cleanHK(){
	int t_id = threadIdx.x;
	HookUpTable[t_id] = 0;
}

__device__ void addr_Init(int addr, int pointcondition){
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

__global__ void HookUpInit(int pointcondition){
	for(int addr = 0; addr< 8192; addr++){
		int new_addr = 0;
		for (int i =0; i < 8; i++){
			new_addr = addr | ( i << 13 );
			addr_Init(new_addr, pointcondition);
		}
	}
}
__global__ void HookUpTester(int pointcondition){
        int addr = threadIdx.x;
        int new_addr = 0;
        for (int i =0; i < 256; i++){
                new_addr = addr | ( i << 8 );
                if (get_HKpoint(new_addr)){
			printf("addr: %i \n", new_addr);
		}
        }
}


void wrapper_kernel_HKinit(int pointcondition){
	cleanHK<<<256,256>>>();
	HookUpInit<<<1,1>>>(pointcondition);
	//HookUpTester<<<1,256>>>(pointcondition);
	return;
}

/*
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
*/

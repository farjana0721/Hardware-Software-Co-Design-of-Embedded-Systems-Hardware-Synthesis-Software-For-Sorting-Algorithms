#include "radixsort.h"
#include <stdio.h>

void countSort(int arr[], int n, int count)
{
	int output[20]; // output array
	int i;
	int n = sizeof(arr) / sizeof(arr[0]);
    for(i=0 ; i < n; i++){
    	if(arr[i] == count )
    		output[i]=arr[i];
    }

    for(i = 0; i < n; i++){
    	arr[i] = output[i];
    }
}

// Radix Sort
void radixsort(int arr[], int n)
{
#pragma HLS INTERFACE mode=s_axilite port=radixsort
#pragma HLS INTERFACE mode=s_axilite port=arr
#pragma HLS INTERFACE mode=s_axilite port=n

	for (int i = 0; i < 10; i++)
		countSort(arr, n, i);
}



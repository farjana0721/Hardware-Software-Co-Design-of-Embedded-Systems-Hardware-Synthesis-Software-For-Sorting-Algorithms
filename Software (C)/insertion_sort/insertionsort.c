#include "insertionsort.h"
#include <stdio.h>
#include <math.h>


/* Function to sort an array using insertion sort*/
void insertionSort(int arr[], int n)
{
#pragma HLS INTERFACE mode=s_axilite port=insertionSort
#pragma HLS INTERFACE mode=s_axilite port=arr
#pragma HLS INTERFACE mode=s_axilite port=n


    int i, key, j;
    for (i = 1; i < n; i++) {
        key = arr[i];
        j = i - 1;
        while (j >= 0 && arr[j] > key) {
            arr[j + 1] = arr[j];
            j = j - 1;
        }
        arr[j + 1] = key;
    }
}

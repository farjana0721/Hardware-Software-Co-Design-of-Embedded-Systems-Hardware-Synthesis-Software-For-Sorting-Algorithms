#include "bubble.h"
#include <stdio.h>
void swap(int* xp, int* yp)
{
    int temp = *xp;
    *xp = *yp;
    *yp = temp;
}

// A function to implement bubble sort
void bubble(int arr[], int n)
{
#pragma HLS INTERFACE mode=s_axilite port=bubble
#pragma HLS INTERFACE mode=s_axilite port=arr
#pragma HLS INTERFACE mode=s_axilite port=n

    int i, j;
    for (i = 0; i < n; i++){

        // Last i elements are already in place
        for (j = 0; j < n - i - 1; j++){
            if (arr[j] > arr[j + 1])
                swap(&arr[j], &arr[j + 1]);
        }
    }
}


#include "insertionsort.h"
#include <stdio.h>
#include <math.h>

int main(){
	int in[] = {5, 1, 4, 2, 8};
	int n = 5;
	insertionSort(in, n);

	for (int i = 0; i < n; i++)
            printf("%d ", in[i]);
        printf("\n");


}

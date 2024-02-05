#include "radixsort.h"
#include <stdio.h>

int main()
{
	    int in[] = { 5, 1, 4, 2, 8 };

	    int n = sizeof(in) / sizeof(in[0]);
	    radixsort(in, n);
	    int i;
	    for (i = 0; i < n; i++)
	                printf("%d ",in[i]);
	            printf("\n");
	    return 0;

}

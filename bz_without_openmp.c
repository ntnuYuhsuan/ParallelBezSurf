#include <stdio.h>
#include <math.h>
#include <time.h>

#define NUMS 4900

#define XMIN 0.
#define XMAX 3.
#define YMIN 0.
#define YMAX 3.

#define Z00	0.
#define Z10	1.
#define Z20	0.
#define Z30	0.

#define Z01	1.
#define Z11	6.
#define Z21	1.
#define Z31	0.

#define Z02	0.
#define Z12	1.
#define Z22	0.
#define Z32	4.

#define Z03	3.
#define Z13	2.
#define Z23	3.
#define Z33	3.

float Height(int iu, int iv);
float Height(int iu, int iv)// iu,iv = 0 .. NUMS-1
{
	float u = (float)iu / (float)(NUMS - 1);
	float v = (float)iv / (float)(NUMS - 1);

	// the basis functions:

	float bu0 = (1. - u) * (1. - u) * (1. - u);
	float bu1 = 3. * u * (1. - u) * (1. - u);
	float bu2 = 3. * u * u * (1. - u);
	float bu3 = u * u * u;

	float bv0 = (1. - v) * (1. - v) * (1. - v);
	float bv1 = 3. * v * (1. - v) * (1. - v);
	float bv2 = 3. * v * v * (1. - v);
	float bv3 = v * v * v;

	// finally, we get to compute something:

	float height = bu0 * (bv0*Z00 + bv1*Z01 + bv2*Z02 + bv3*Z03)
		+ bu1 * (bv0*Z10 + bv1*Z11 + bv2*Z12 + bv3*Z13)
		+ bu2 * (bv0*Z20 + bv1*Z21 + bv2*Z22 + bv3*Z23)
		+ bu3 * (bv0*Z30 + bv1*Z31 + bv2*Z32 + bv3*Z33);

	return height;
}

int main() {

    printf("computing withoout openmp\n");

    clock_t start, end;
    double cpu_time_used;
    
    start = clock();
    
    float fullTileArea = (((XMAX - XMIN) / (float)(NUMS - 1))  *  ((YMAX - YMIN) / (float)(NUMS - 1)));
    float volume = 0;

    for (int i = 0; i < NUMS * NUMS; i++) {
        int iu = i % NUMS;
        int iv = i / NUMS;
        float myPartialSum = 0;

        // 計算每個tile的面積
        if (((iv == 0) && (iu == 0)) || ((iv == 0) && (iu == (NUMS - 1))) || ((iv == (NUMS - 1)) && (iu == 0)) || ((iv == (NUMS - 1)) && (iu == (NUMS - 1)))) {
            myPartialSum = (Height(iu, iv) * (.25 * fullTileArea));
        }
        else if (((iv == 0) || (iv == (NUMS - 1))) || ((iu == 0) || (iu == (NUMS - 1)))) {
            myPartialSum = (Height(iu, iv) * (.5 * fullTileArea));
        }
        else {
            myPartialSum = (Height(iu, iv) * (fullTileArea));
        }

        volume += myPartialSum;
    }

    end = clock();
    cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;

    printf("Performance = %8.2lf MegaHeights/Sec\n", (NUMS * NUMS) / cpu_time_used / 1000000);
    printf("Total time :%8.2lf seconds\n", cpu_time_used);
    printf("Total Volume of bezier surface:  %f\n", volume);

    return 0;
}

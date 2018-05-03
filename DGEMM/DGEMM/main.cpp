/**
* @author: Ayoub Chouak (a.chouak@protonmail.com)
* @file:   main.c
*
*/

#include "dgemm.hpp"

#include <iostream>

#ifdef _DEBUG
	#define __DGEMM_PRINT(__m) \
	for (size_t i = 0; i < 4; i++) { \
		for (size_t j = 0; j < 4; j++) \
			std::cout << __m[i][j] << " "; \
		std::cout << std::endl; \
	}
#else
	#define __DGEMM_PRINT(__m)
#endif

using namespace std;

int main(int argc, char** argv)
{
	double matrix0[4][4] = {
		{ 1, 2, 3, 4 },
		{ 1, 2, 3, 4 },
		{ 1, 2, 3, 4 },
		{ 1, 2, 3, 4 }
	};
	double matrix1[4][4] = {
		{ 1, 2, 3, 4 },
		{ 1, 2, 3, 4 },
		{ 1, 2, 3, 4 },
		{ 1, 2, 3, 4 }
	};
	double dgemm_dst[4][4];

	// DGEMM (No AVX)
	dgemm(reinterpret_cast<double**>(matrix0), reinterpret_cast<double**>(matrix1), reinterpret_cast<double**>(dgemm_dst), sizeof(*matrix0) / sizeof(**matrix0));

	__DGEMM_PRINT(dgemm_dst)

	getchar();
}
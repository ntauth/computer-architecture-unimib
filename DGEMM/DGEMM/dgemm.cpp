/**
* @author: Ayoub Chouak (a.chouak@protonmail.com)
* @file:   dgemm.cpp
*
*/

#include "dgemm.hpp"

#include <immintrin.h>

#define WIN32_MEAN_AND_LEAN
#include <Windows.h>

void __fastcall dgemm(double** src0, double** src1, double** dst, size_t shape)
{
	SecureZeroMemory(dst, shape * shape);

	for (size_t i = 0; i < shape; i++)
	{
		for (size_t j = 0; j < shape; j++)
		{
			double* dst_flat = reinterpret_cast<double*>(dst);
			double dst_ij = 0;

			for (size_t k = 0; k < shape; k++) {
				dst_ij += reinterpret_cast<double*>(src0)[i + k * shape] * reinterpret_cast<double*>(src1)[k + j * shape];
			}

			dst_flat[i + j * shape] = dst_ij;
		}
	}
}

void __fastcall dgemm_avx(double** src0, double** src1, double** dst, size_t shape)
{
	SecureZeroMemory(dst, shape * shape);

	for (size_t i = 0; i < shape; i++)
	{
		for (size_t j = 0; j < shape; j++)
		{
			double* dst_flat = reinterpret_cast<double*>(dst);
			double dst_ij = 0;

			for (size_t k = 0; k < shape; k++) {
				dst_ij += reinterpret_cast<double*>(src0)[i + k * shape] * reinterpret_cast<double*>(src1)[k + j * shape];
			}

			dst_flat[i + j * shape] = dst_ij;
		}
	}
}
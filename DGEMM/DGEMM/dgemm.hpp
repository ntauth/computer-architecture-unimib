/**
* @author: Ayoub Chouak (a.chouak@protonmail.com)
* @file:   dgemm.hpp
*
*/

#ifndef __DGEMM_HPP
#define __DGEMM_HPP

#include <cstdint>

/*********************** DGEMM Functions **/
void __fastcall dgemm(double** src0, double** src1, double** dst, size_t shape);

#endif // __DGEMM_HPP
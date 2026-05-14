" Vim syntax file for CUDA
" Language:	CUDA C/C++
" Maintainer:	yszheda

if exists("b:current_syntax")
  finish
endif

" Load C++ syntax as base
runtime! syntax/cpp.vim

" CUDA keywords - highlighted as keywords
syn keyword cudaType         __global__ __device__ __host__ __shared__
syn keyword cudaType         __constant__ __managed__
syn keyword cudaFunction     __syncthreads __threadfence __threadfence_block
syn keyword cudaFunction     __threadfence_system __syncwarp
syn keyword cudaFunction     __ballot_sync __shfl_sync __shfl_up_sync
syn keyword cudaFunction     __shfl_down_sync __shfl_xor_sync
syn keyword cudaFunction     __ldg __popc __clz __ffs __brev __brevll
syn keyword cudaFunction     __sad __usad
syn keyword cudaFunction     __umul24 __umulhi __mul24 __mulhi
syn keyword cudaFunction     __float2int_rn __float2int_rz __float2int_ru __float2int_rd
syn keyword cudaFunction     __float2uint_rn __float2uint_rz __float2uint_ru __float2uint_rd
syn keyword cudaFunction     __int2float_rn __int2float_rz __int2float_ru __int2float_rd
syn keyword cudaFunction     __uint2float_rn __uint2float_rz __uint2float_ru __uint2float_rd
syn keyword cudaFunction     __fdividef __fma __fmul_rn __fmul_rz __fmul_ru __fmul_rd
syn keyword cudaFunction     __fadd_rn __fadd_rz __fadd_ru __fadd_rd
syn keyword cudaFunction     __dadd_rn __dadd_rz __dadd_ru __dadd_rd
syn keyword cudaFunction     __dmul_rn __dmul_rz __dmul_ru __dmul_rd
syn keyword cudaFunction     __fmaf_rn __fmaf_rz __fmaf_ru __fmaf_rd
syn keyword cudaType         dim3
syn keyword cudaFunction     blockIdx threadIdx blockDim gridIdx
syn keyword cudaType         cudaError_t
syn keyword cudaFunction     cudaMalloc cudaFree cudaMemcpy cudaMemcpy2D
syn keyword cudaFunction     cudaMallocManaged cudaDeviceSynchronize
syn keyword cudaFunction     cudaGetLastError cudaGetErrorString
syn keyword cudaFunction     cudaStreamCreate cudaStreamDestroy cudaStreamSynchronize
syn keyword cudaFunction     cudaEventCreate cudaEventDestroy cudaEventRecord
syn keyword cudaFunction     cudaEventSynchronize cudaEventElapsedTime
syn keyword cudaFunction     cudaMemset cudaMallocHost cudaFreeHost

hi def link cudaType       Type
hi def link cudaFunction   Function

let b:current_syntax = "cuda"

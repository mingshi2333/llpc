/*
 ***********************************************************************************************************************
 *
 *  Copyright (c) 2017-2023 Advanced Micro Devices, Inc. All Rights Reserved.
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in all
 *  copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *  SOFTWARE.
 *
 **********************************************************************************************************************/
/**
 ***********************************************************************************************************************
 * @file  llpcSpirvLowerExecutionGraph.cpp
 * @brief LLPC source file: contains implementation of class Llpc::SpirvLowerExecutionGraph.
 ***********************************************************************************************************************
 */
#include "llpcSpirvProcessGpuRtLibrary.h"
#include "SPIRVInternal.h"
#include "llpcContext.h"
#include "llpcSpirvLowerUtil.h"
#include "lgc/Builder.h"
#include "lgc/GpurtDialect.h"
#include "lgc/LgcContext.h"

#define DEBUG_TYPE "llpc-spirv-lower-gpurt-library"
using namespace lgc;
using namespace llvm;

namespace RtName {
static const char *AmdLibraryNames[] = {"AmdTraceRayGetStackSize",
                                        "AmdTraceRayLdsRead",
                                        "AmdTraceRayLdsWrite",
                                        "AmdTraceRayGetStackBase",
                                        "AmdTraceRayGetStackStride",
                                        "AmdTraceRayLdsStackInit",
                                        "AmdTraceRayLdsStackStore",
                                        "AmdTraceRayGetBoxSortHeuristicMode",
                                        "AmdTraceRayGetStaticFlags",
                                        "AmdTraceRayGetTriangleCompressionMode",
                                        "AmdExtD3DShaderIntrinsics_LoadDwordAtAddr",
                                        "AmdExtD3DShaderIntrinsics_LoadDwordAtAddrx2",
                                        "AmdExtD3DShaderIntrinsics_LoadDwordAtAddrx4",
                                        "AmdExtD3DShaderIntrinsics_ConvertF32toF16NegInf",
                                        "AmdExtD3DShaderIntrinsics_ConvertF32toF16PosInf"};
} // namespace RtName

namespace AmdLibraryFunc {
enum : unsigned {
  GetStackSize = 0,           // Get stack size
  LdsRead,                    // Read from LDS
  LdsWrite,                   // Write to LDS
  GetStackBase,               // Get stack base
  GetStackStride,             // Get stack stride
  LdsStackInit,               // Lds stack init
  LdsStackStore,              // Lds stack store
  GetBoxSortHeuristicMode,    // Get box sort heuristic mode
  GetStaticFlags,             // Get static flags
  GetTriangleCompressionMode, // Get triangle compression mode
  LoadDwordAtAddr,            // Load 1 dword at given address
  LoadDwordAtAddrx2,          // Load 2 dwords at given address
  LoadDwordAtAddrx4,          // Load 4 dwords at given address
  ConvertF32toF16NegInf,      // Convert f32 to f16 with rounding toward negative
  ConvertF32toF16PosInf,      // Convert f32 to f16 with rounding toward positive
  Count
};
} // namespace AmdLibraryFunc

namespace Llpc {
SpirvProcessGpuRtLibrary::SpirvProcessGpuRtLibrary() {
}

// =====================================================================================================================
// Executes this SPIR-V lowering pass on the specified LLVM module.
//
// @param [in/out] module : LLVM module to be run on
// @param [in/out] analysisManager : Analysis manager to use for this transformation
PreservedAnalyses SpirvProcessGpuRtLibrary::run(Module &module, ModuleAnalysisManager &analysisManager) {
  LLVM_DEBUG(dbgs() << "Run the pass Spirv-Lower-gpurt\n");
  SpirvLower::init(&module);
  for (auto funcIt = module.begin(), funcEnd = module.end(); funcIt != funcEnd;) {
    Function *func = &*funcIt++;
    processLibraryFunction(func);
  }
  return PreservedAnalyses::none();
}

// =====================================================================================================================
// Initialize library function pointer table
SpirvProcessGpuRtLibrary::LibraryFunctionTable::LibraryFunctionTable() {
  LibraryFuncPtr amdLibraryFuncs[] = {&SpirvProcessGpuRtLibrary::createGetStackSize,
                                      &SpirvProcessGpuRtLibrary::createLdsRead,
                                      &SpirvProcessGpuRtLibrary::createLdsWrite,
                                      &SpirvProcessGpuRtLibrary::createGetStackBase,
                                      &SpirvProcessGpuRtLibrary::createGetStackStride,
                                      &SpirvProcessGpuRtLibrary::createLdsStackInit,
                                      &SpirvProcessGpuRtLibrary::createLdsStackStore,
                                      &SpirvProcessGpuRtLibrary::createGetBoxSortHeuristicMode,
                                      &SpirvProcessGpuRtLibrary::createGetStaticFlags,
                                      &SpirvProcessGpuRtLibrary::createGetTriangleCompressionMode,
                                      &SpirvProcessGpuRtLibrary::createLoadDwordAtAddr,
                                      &SpirvProcessGpuRtLibrary::createLoadDwordAtAddrx2,
                                      &SpirvProcessGpuRtLibrary::createLoadDwordAtAddrx4,
                                      &SpirvProcessGpuRtLibrary::createConvertF32toF16NegInf,
                                      &SpirvProcessGpuRtLibrary::createConvertF32toF16PosInf

  };
  for (unsigned i = 0; i < AmdLibraryFunc::Count; ++i) {
    m_libFuncPtrs[RtName::AmdLibraryNames[i]] = amdLibraryFuncs[i];
  }
}

// =====================================================================================================================
// Clear the block before patching the function
//
// @param func : The function to process
void SpirvProcessGpuRtLibrary::processLibraryFunction(Function *&func) {
  auto &funcTable = LibraryFunctionTable::get().m_libFuncPtrs;

  auto funcIt = funcTable.find(func->getName());
  if (funcIt != funcTable.end()) {
    auto funcPtr = funcIt->second;
    m_builder->SetInsertPoint(clearBlock(func));
    (this->*funcPtr)(func);
  }
}

// =====================================================================================================================
// Create function to get stack size
//
// @param func : The function to process
void SpirvProcessGpuRtLibrary::createGetStackSize(Function *func) {
  m_builder->CreateRet(m_builder->create<GpurtGetStackSizeOp>());
}

// =====================================================================================================================
// Create function to get stack base
//
// @param func : The function to process
void SpirvProcessGpuRtLibrary::createGetStackBase(Function *func) {
  m_builder->CreateRet(m_builder->create<GpurtGetStackBaseOp>());
}

// =====================================================================================================================
// Create function to write LDS stack
//
// @param func : The function to process
void SpirvProcessGpuRtLibrary::createLdsWrite(Function *func) {
  auto argIt = func->arg_begin();
  auto int32ty = m_builder->getInt32Ty();
  Value *stackOffset = m_builder->CreateLoad(int32ty, argIt++);
  Value *stackData = m_builder->CreateLoad(int32ty, argIt);
  m_builder->CreateRet(m_builder->create<GpurtStackWriteOp>(stackOffset, stackData));
}

// =====================================================================================================================
// Create function to read LDS stack
//
// @param func : The function to process
void SpirvProcessGpuRtLibrary::createLdsRead(Function *func) {
  Value *stackIndex = func->arg_begin();
  stackIndex = m_builder->CreateLoad(m_builder->getInt32Ty(), stackIndex);
  m_builder->CreateRet(m_builder->create<GpurtStackReadOp>(stackIndex));
}

// =====================================================================================================================
// Create function to get stack stride
//
// @param func : The function to process
void SpirvProcessGpuRtLibrary::createGetStackStride(Function *func) {
  m_builder->CreateRet(m_builder->create<GpurtGetStackStrideOp>());
}

// =====================================================================================================================
// Create function to init stack LDS
//
// @param func : The function to process
void SpirvProcessGpuRtLibrary::createLdsStackInit(Function *func) {
  m_builder->CreateRet(m_builder->create<GpurtLdsStackInitOp>());
}

// =====================================================================================================================
// Create function to store stack LDS
//
// @param func : The function to process
void SpirvProcessGpuRtLibrary::createLdsStackStore(Function *func) {
  auto argIt = func->arg_begin();
  Value *stackAddr = argIt++;
  Value *lastVisited = m_builder->CreateLoad(m_builder->getInt32Ty(), argIt++);
  auto int32x4Ty = FixedVectorType::get(m_builder->getInt32Ty(), 4);
  Value *data = m_builder->CreateLoad(int32x4Ty, argIt);
  m_builder->CreateRet(m_builder->create<GpurtLdsStackStoreOp>(stackAddr, lastVisited, data));
}

// =====================================================================================================================
// Create function to get box sort heuristic mode
//
// @param func : The function to process
void SpirvProcessGpuRtLibrary::createGetBoxSortHeuristicMode(Function *func) {
  m_builder->CreateRet(m_builder->create<GpurtGetBoxSortHeuristicModeOp>());
}

// =====================================================================================================================
// Create function to get static flags
//
// @param func : The function to process
void SpirvProcessGpuRtLibrary::createGetStaticFlags(Function *func) {
  m_builder->CreateRet(m_builder->create<GpurtGetStaticFlagsOp>());
}

// =====================================================================================================================
// Create function to get triangle compression mode
//
// @param func : The function to process
void SpirvProcessGpuRtLibrary::createGetTriangleCompressionMode(Function *func) {
  m_builder->CreateRet(m_builder->create<GpurtGetTriangleCompressionModeOp>());
}

// =====================================================================================================================
// Create function to load 1 dword at given address
//
// @param func : The function to process
void SpirvProcessGpuRtLibrary::createLoadDwordAtAddr(Function *func) {
  createLoadDwordAtAddrWithType(func, m_builder->getInt32Ty());
}

// =====================================================================================================================
// Create function to load 2 dwords at given address
//
// @param func : The function to process
void SpirvProcessGpuRtLibrary::createLoadDwordAtAddrx2(Function *func) {
  auto int32x2Ty = FixedVectorType::get(m_builder->getInt32Ty(), 2);
  createLoadDwordAtAddrWithType(func, int32x2Ty);
}

// =====================================================================================================================
// Create function to load 4 dwords at given address
//
// @param func : The function to process
void SpirvProcessGpuRtLibrary::createLoadDwordAtAddrx4(Function *func) {
  auto int32x4Ty = FixedVectorType::get(m_builder->getInt32Ty(), 4);
  createLoadDwordAtAddrWithType(func, int32x4Ty);
}

// =====================================================================================================================
// Create function to load dwords at given address based on given type
//
// @param func : The function to process
// @param loadTy : Load type
void SpirvProcessGpuRtLibrary::createLoadDwordAtAddrWithType(Function *func, Type *loadTy) {
  auto argIt = func->arg_begin();

  Value *gpuLowAddr = m_builder->CreateLoad(m_builder->getInt32Ty(), argIt++);
  Value *gpuHighAddr = m_builder->CreateLoad(m_builder->getInt32Ty(), argIt++);
  Value *offset = m_builder->CreateLoad(m_builder->getInt32Ty(), argIt++);

  // Use (gpuLowAddr, gpuHighAddr) to calculate i64 gpuAddr
  gpuLowAddr = m_builder->CreateZExt(gpuLowAddr, m_builder->getInt64Ty());
  gpuHighAddr = m_builder->CreateZExt(gpuHighAddr, m_builder->getInt64Ty());
  gpuHighAddr = m_builder->CreateShl(gpuHighAddr, m_builder->getInt64(32));
  Value *gpuAddr = m_builder->CreateOr(gpuLowAddr, gpuHighAddr);

  Type *gpuAddrAsPtrTy = PointerType::get(m_builder->getContext(), SPIRAS_Global);
  auto gpuAddrAsPtr = m_builder->CreateIntToPtr(gpuAddr, gpuAddrAsPtrTy);

  // Create GEP to get the byte address with byte offset
  Value *loadPtr = m_builder->CreateGEP(m_builder->getInt8Ty(), gpuAddrAsPtr, offset);

  Value *loadValue = m_builder->CreateLoad(loadTy, loadPtr);
  m_builder->CreateRet(loadValue);
}

// =====================================================================================================================
// Create function to convert f32 to f16 with rounding toward negative
//
// @param func : The function to process
void SpirvProcessGpuRtLibrary::createConvertF32toF16NegInf(Function *func) {
  createConvertF32toF16WithRoundingMode(func, RoundingMode::TowardNegative);
}

// =====================================================================================================================
// Create function to convert f32 to f16 with rounding toward positive
//
// @param func : The function to process
void SpirvProcessGpuRtLibrary::createConvertF32toF16PosInf(Function *func) {
  createConvertF32toF16WithRoundingMode(func, RoundingMode::TowardPositive);
}

// =====================================================================================================================
// Create function to convert f32 to f16 with given rounding mode
//
// @param func : The function to process
// @param rm : Rounding mode
void SpirvProcessGpuRtLibrary::createConvertF32toF16WithRoundingMode(Function *func, RoundingMode rm) {
  auto argIt = func->arg_begin();

  Type *convertInputType = FixedVectorType::get(m_builder->getFloatTy(), 3);
  Value *inVec = m_builder->CreateLoad(convertInputType, argIt);

  Value *result = m_builder->CreateFpTruncWithRounding(inVec, FixedVectorType::get(m_builder->getHalfTy(), 3), rm);

  result = m_builder->CreateBitCast(result, FixedVectorType::get(m_builder->getInt16Ty(), 3));
  result = m_builder->CreateZExt(result, FixedVectorType::get(m_builder->getInt32Ty(), 3));

  m_builder->CreateRet(result);
}

} // namespace Llpc
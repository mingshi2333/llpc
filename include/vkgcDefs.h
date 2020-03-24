/*
 ***********************************************************************************************************************
 *
 *  Copyright (c) 2020 Advanced Micro Devices, Inc. All Rights Reserved.
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
 * @file  vkgcDefs.h
 * @brief VKGC header file: contains vulkan graphics compiler basic definitions (including interfaces and data types).
 ***********************************************************************************************************************
 */
#pragma once

#include "vulkan.h"

// Confliction of Xlib and LLVM headers
#undef True
#undef False
#undef DestroyAll
#undef Status
#undef Bool

/// LLPC major interface version.
#define LLPC_INTERFACE_MAJOR_VERSION 40

/// LLPC minor interface version.
#define LLPC_INTERFACE_MINOR_VERSION 0

#ifndef LLPC_CLIENT_INTERFACE_MAJOR_VERSION
#if VFX_INSIDE_SPVGEN
#define LLPC_CLIENT_INTERFACE_MAJOR_VERSION LLPC_INTERFACE_MAJOR_VERSION
#else
#error LLPC client version is not defined
#endif
#endif

#if LLPC_CLIENT_INTERFACE_MAJOR_VERSION < 32
#error LLPC client version is too old
#endif

//**
//**********************************************************************************************************************
//* @page VersionHistory
//* %Version History
//* | %Version | Change Description                                                                                    |
//* | -------- | ----------------------------------------------------------------------------------------------------- |
//* |     40.0 | Added DescriptorReserved12, which moves DescriptorYCbCrSampler down to 13                             |
//* |     38.2 | Added scalarThreshold to PipelineShaderOptions                                                        |
//* |     38.1 | Added unrollThreshold to PipelineShaderOptions                                                        |
//* |     38.0 | Removed CreateShaderCache in ICompiler and pShaderCache in pipeline build info                        |
//* |     37.0 | Removed the -enable-dynamic-loop-unroll option                                                        |
//* |     36.0 | Add 128 bit hash as clientHash in PipelineShaderOptions                                               |
//* |     35.0 | Added disableLicm to PipelineShaderOptions                                                            |
//* |     33.0 | Add enableLoadScalarizer option into PipelineShaderOptions.                                           |
//* |     32.0 | Add ShaderModuleOptions in ShaderModuleBuildInfo                                                      |
//* |     31.0 | Add PipelineShaderOptions::allowVaryWaveSize                                                          |
//* |     30.0 | Removed PipelineOptions::autoLayoutDesc                                                               |
//* |     28.0 | Added reconfigWorkgroupLayout to PipelineOptions and useSiScheduler to PipelineShaderOptions          |
//* |     27.0 | Remove the includeIrBinary option from PipelineOptions as only IR disassembly is now dumped           |
//* |     25.0 | Add includeIrBinary option into PipelineOptions for including IR binaries into ELF files.             |
//* |     24.0 | Add forceLoopUnrollCount option into PipelineShaderOptions.                                           |
//* |     23.0 | Add flag robustBufferAccess in PipelineOptions to check out of bounds of private array.               |
//* |     22.0 | Internal revision.                                                                                    |
//* |     21.0 | Add stage in Pipeline shader info and struct PipelineBuildInfo to simplify pipeline dump interface.   |
//*
//* IMPORTANT NOTE: All structures defined in this file that are passed as input into LLPC must be zero-initialized
//* with code such as the following before filling in the structure's fields:
//*
//*   SomeLlpcStructure someLlpcStructure = {};
//*
//* It is sufficient to perform this initialization on a containing structure.
//*
//* LLPC is free to add new fields to such structures without increasing the client interface major version, as long
//* as setting the newly added fields to a 0 (or false) value is safe, i.e. it preserves the old behavior.
//*
//**/

namespace Llpc
{

static const uint32_t  Version = LLPC_INTERFACE_MAJOR_VERSION;
static const uint32_t  InternalDescriptorSetId = static_cast<uint32_t>(-1);
static const uint32_t  MaxColorTargets = 8;

// Forward declarations
class IShaderCache;

/// Enumerates result codes of LLPC operations.
enum class Result : int32_t
{
    /// The operation completed successfully
    Success                         = 0x00000000,
    // The requested operation is delayed
    Delayed                         = 0x00000001,
    // The requested feature is unsupported
    Unsupported                     = 0x00000002,
    /// The requested operation is unavailable at this time
    ErrorUnavailable                = -(0x00000001),
    /// The operation could not complete due to insufficient system memory
    ErrorOutOfMemory                = -(0x00000002),
    /// An invalid shader code was passed to the call
    ErrorInvalidShader               = -(0x00000003),
    /// An invalid value was passed to the call
    ErrorInvalidValue               = -(0x00000004),
    /// A required input pointer passed to the call was invalid (probably null)
    ErrorInvalidPointer             = -(0x00000005),
    /// The operaton encountered an unknown error
    ErrorUnknown                    = -(0x00000006),
};

/// Represents the base data type
enum class BasicType : uint32_t
{
    Unknown = 0,          ///< Unknown
    Float,                ///< Float
    Double,               ///< Double
    Int,                  ///< Signed integer
    Uint,                 ///< Unsigned integer
    Int64,                ///< 64-bit signed integer
    Uint64,               ///< 64-bit unsigned integer
    Float16,              ///< 16-bit floating-point
    Int16,                ///< 16-bit signed integer
    Uint16,               ///< 16-bit unsigned integer
    Int8,                 ///< 8-bit signed integer
    Uint8,                ///< 8-bit unsigned integer
};

/// Enumerates LLPC shader stages.
enum ShaderStage : uint32_t
{
    ShaderStageVertex = 0,                                ///< Vertex shader
    ShaderStageTessControl,                               ///< Tessellation control shader
    ShaderStageTessEval,                                  ///< Tessellation evaluation shader
    ShaderStageGeometry,                                  ///< Geometry shader
    ShaderStageFragment,                                  ///< Fragment shader
    ShaderStageCompute,                                   ///< Compute shader
    ShaderStageCount,                                     ///< Count of shader stages
    ShaderStageInvalid = ~0u,                             ///< Invalid shader stage
    ShaderStageNativeStageCount = ShaderStageCompute + 1, ///< Native supported shader stage count
    ShaderStageGfxCount = ShaderStageFragment + 1,        ///< Count of shader stages for graphics pipeline

    ShaderStageCopyShader = ShaderStageCount,             ///< Copy shader (internal-use)
    ShaderStageCountInternal,                             ///< Count of shader stages (internal-use)
};

/// Enumerates the function of a particular node in a shader's resource mapping graph.
enum class ResourceMappingNodeType : uint32_t
{
    Unknown,                        ///< Invalid type
    DescriptorResource,             ///< Generic descriptor: resource, including texture resource, image, input
                                    ///  attachment
    DescriptorSampler,              ///< Generic descriptor: sampler
    DescriptorCombinedTexture,      ///< Generic descriptor: combined texture, combining resource descriptor with
                                    ///  sampler descriptor of the same texture, starting with resource descriptor
    DescriptorTexelBuffer,          ///< Generic descriptor: texel buffer, including texture buffer and image buffer
    DescriptorFmask,                ///< Generic descriptor: F-mask
    DescriptorBuffer,               ///< Generic descriptor: buffer, including uniform buffer and shader storage buffer
    DescriptorTableVaPtr,           ///< Descriptor table VA pointer
    IndirectUserDataVaPtr,          ///< Indirect user data VA pointer
    PushConst,                      ///< Push constant
    DescriptorBufferCompact,        ///< Compact buffer descriptor, only contains the buffer address
    StreamOutTableVaPtr,            ///< Stream-out buffer table VA pointer
#if LLPC_CLIENT_INTERFACE_MAJOR_VERSION >= 40
    DescriptorReserved12,
#elif LLPC_CLIENT_INTERFACE_MAJOR_VERSION >= 29
#endif
    DescriptorYCbCrSampler,         ///< Generic descriptor: YCbCr sampler
    Count,                          ///< Count of resource mapping node types.
};

/// Represents one node in a graph defining how the user data bound in a command buffer at draw/dispatch time maps to
/// resources referenced by a shader (t#, u#, etc.).
struct ResourceMappingNode
{
    ResourceMappingNodeType     type;   ///< Type of this node

    uint32_t    sizeInDwords;   ///< Size of this node in DWORD
    uint32_t    offsetInDwords; ///< Offset of this node (from the beginning of the resource mapping table) in DWORD

    union
    {
        /// Info for generic descriptor nodes (DescriptorResource, DescriptorSampler, DescriptorCombinedTexture,
        /// DescriptorTexelBuffer, DescriptorBuffer and DescriptorBufferCompact)
        struct
        {
            uint32_t                    set;         ///< Descriptor set
            uint32_t                    binding;     ///< Descriptor binding
        } srdRange;
        /// Info for hierarchical nodes (DescriptorTableVaPtr)
        struct
        {
            uint32_t                    nodeCount;  ///< Number of entries in the "pNext" array
            const ResourceMappingNode*  pNext;      ///< Array of node structures describing the next hierarchical
                                                    ///  level of mapping
        } tablePtr;
        /// Info for hierarchical nodes (IndirectUserDataVaPtr)
        struct
        {
            uint32_t                    sizeInDwords; ///< Size of the pointed table in DWORDS
        } userDataPtr;
    };
};

/// Represents the info of static descriptor.
struct DescriptorRangeValue
{
    ResourceMappingNodeType type;       ///< Type of this resource mapping node (currently, only sampler is supported)
    uint32_t                set;        ///< ID of descriptor set
    uint32_t                binding;    ///< ID of descriptor binding
    uint32_t                arraySize;  ///< Element count for arrayed binding
    const uint32_t*         pValue;     ///< Static SRDs
};

/// Represents graphics IP version info. See https://llvm.org/docs/AMDGPUUsage.html#processors for more
/// details.
struct GfxIpVersion
{
    uint32_t        major;              ///< Major version
    uint32_t        minor;              ///< Minor version
    uint32_t        stepping;           ///< Stepping info
};

/// Represents shader binary data.
struct BinaryData
{
    size_t          codeSize;           ///< Size of shader binary data
    const void*     pCode;              ///< Shader binary data
};

/// Represents per pipeline options.
struct PipelineOptions
{
    bool includeDisassembly;       ///< If set, the disassembly for all compiled shaders will be included in
                                   ///  the pipeline ELF.
    bool scalarBlockLayout;        ///< If set, allows scalar block layout of types.
    bool reconfigWorkgroupLayout;  ///< If set, allows automatic workgroup reconfigure to take place on compute shaders.
    bool includeIr;                ///< If set, the IR for all compiled shaders will be included in the pipeline ELF.
    bool robustBufferAccess;       ///< If set, out of bounds accesses to buffer or private array will be handled.
                                   ///  for now this option is used by LLPC shader and affects only the private array,
                                   ///  the out of bounds accesses will be skipped with this setting.
};

/// Prototype of allocator for output data buffer, used in shader-specific operations.
typedef void* (VKAPI_CALL *OutputAllocFunc)(void* pInstance, void* pUserData, size_t size);

/// Enumerates types of shader binary.
enum class BinaryType : uint32_t
{
    Unknown = 0,  ///< Invalid type
    Spirv,        ///< SPIR-V binary
    LlvmBc,       ///< LLVM bitcode
    MultiLlvmBc,  ///< Multiple LLVM bitcode
    Elf,          ///< ELF
};

/// Represents resource node data
struct ResourceNodeData
{
    ResourceMappingNodeType type;       ///< Type of this resource mapping node
    uint32_t                set;        ///< ID of descriptor set
    uint32_t                binding;    ///< ID of descriptor binding
    uint32_t                arraySize;  ///< Element count for arrayed binding
};

/// Represents the information of one shader entry in ShaderModuleExtraData
struct ShaderModuleEntryData
{
    ShaderStage             stage;              ///< Shader stage
    const char*             pEntryName;         ///< Shader entry name
    void*                   pShaderEntry;       ///< Private shader module entry info
    uint32_t                resNodeDataCount;   ///< Resource node data count
    const ResourceNodeData* pResNodeDatas;      ///< Resource node data array
    uint32_t                pushConstSize;      ///< Push constant size in byte
};

/// Represents usage info of a shader module
struct ShaderModuleUsage
{
    bool                  enableVarPtrStorageBuf;  ///< Whether to enable "VariablePointerStorageBuffer" capability
    bool                  enableVarPtr;            ///< Whether to enable "VariablePointer" capability
    bool                  useSubgroupSize;         ///< Whether gl_SubgroupSize is used
    bool                  useHelpInvocation;       ///< Whether fragment shader has helper-invocation for subgroup
    bool                  useSpecConstant;         ///< Whether specializaton constant is used
    bool                  keepUnusedFunctions;     ///< Whether to keep unused function
};

/// Represents common part of shader module data
struct ShaderModuleData
{
    uint32_t         hash[4];       ///< Shader hash code
    BinaryType       binType;       ///< Shader binary type
    BinaryData       binCode;       ///< Shader binary data
    uint32_t         cacheHash[4];  ///< Hash code for calculate pipeline cache key
    ShaderModuleUsage usage;        ///< Usage info of a shader module
};

/// Represents fragment shader output info
struct FsOutInfo
{
    uint32_t    location;       ///< Output location in resource layout
    uint32_t    index;          ///< Output index in resource layout
    BasicType   basicType;      ///< Output data type
    uint32_t    componentCount; ///< Count of components of output data
};

/// Represents extended output of building a shader module (taking extra data info)
struct ShaderModuleDataEx
{
    ShaderModuleData        common;         ///< Shader module common data
    uint32_t                codeOffset;     ///< Binary offset of binCode in ShaderModuleDataEx
    uint32_t                entryOffset;    ///< Shader entry offset in ShaderModuleDataEx
    uint32_t                resNodeOffset;  ///< Resource node offset in ShaderModuleDataEX
    uint32_t                fsOutInfoOffset;///< FsOutInfo offset in ShaderModuleDataEX
    struct
    {
        uint32_t              fsOutInfoCount;           ///< Count of fragment shader output
        const FsOutInfo*      pFsOutInfos;              ///< Fragment output info array
        uint32_t              entryCount;              ///< Shader entry count in the module
        ShaderModuleEntryData entryDatas[1];           ///< Array of all shader entries in this module
    } extra;                              ///< Represents extra part of shader module data
};

/// Represents the options for pipeline dump.
struct PipelineDumpOptions
{
    const char* pDumpDir;                  ///< Pipeline dump directory
    uint32_t    filterPipelineDumpByType;  ///< Filter which types of pipeline dump are enabled
    uint64_t    filterPipelineDumpByHash;  ///< Only dump the pipeline with this compiler hash if non-zero
    bool        dumpDuplicatePipelines;    ///< If TRUE, duplicate pipelines will be dumped to a file with a
                                           ///  numeric suffix attached
};

/// If next available quad falls outside tile aligned region of size defined by this enumeration the SC will force end
/// of vector in the SC to shader wavefront.
enum class WaveBreakSize : uint32_t
{
    None     = 0x0,        ///< No wave break by region
    _8x8     = 0x1,        ///< Outside a 8x8 pixel region
    _16x16   = 0x2,        ///< Outside a 16x16 pixel region
    _32x32   = 0x3,        ///< Outside a 32x32 pixel region
    DrawTime = 0xF,        ///< Choose wave break size per draw
};

/// Enumerates various sizing options of sub-group size for NGG primitive shader.
enum class NggSubgroupSizingType : uint32_t
{
    Auto,                           ///< Sub-group size is allocated as optimally determined
    MaximumSize,                    ///< Sub-group size is allocated to the maximum allowable size by the hardware
    HalfSize,                       ///< Sub-group size is allocated as to allow half of the maximum allowable size
                                    ///  by the hardware
    OptimizeForVerts,               ///< Sub-group size is optimized for vertex thread utilization
    OptimizeForPrims,               ///< Sub-group size is optimized for primitive thread utilization
    Explicit,                       ///< Sub-group size is allocated based on explicitly-specified vertsPerSubgroup and
                                    ///  primsPerSubgroup
};

/// Enumerates compaction modes after culling operations for NGG primitive shader.
enum NggCompactMode : uint32_t
{
    NggCompactSubgroup,             ///< Compaction is based on the whole sub-group
    NggCompactVertices,             ///< Compaction is based on vertices
};

/// Represents NGG tuning options
struct NggState
{
    bool    enableNgg;                  ///< Enable NGG mode, use an implicit primitive shader
    bool    enableGsUse;                ///< Enable NGG use on geometry shader
    bool    forceNonPassthrough;        ///< Force NGG to run in non pass-through mode
    bool    alwaysUsePrimShaderTable;   ///< Always use primitive shader table to fetch culling-control registers
    NggCompactMode compactMode;         ///< Compaction mode after culling operations

    bool    enableFastLaunch;           ///< Enable the hardware to launch subgroups of work at a faster rate
    bool    enableVertexReuse;          ///< Enable optimization to cull duplicate vertices
    bool    enableBackfaceCulling;      ///< Enable culling of primitives that don't meet facing criteria
    bool    enableFrustumCulling;       ///< Enable discarding of primitives outside of view frustum
    bool    enableBoxFilterCulling;     ///< Enable simpler frustum culler that is less accurate
    bool    enableSphereCulling;        ///< Enable frustum culling based on a sphere
    bool    enableSmallPrimFilter;      ///< Enable trivial sub-sample primitive culling
    bool    enableCullDistanceCulling;  ///< Enable culling when "cull distance" exports are present

    /// Following fields are used for NGG tuning
    uint32_t backfaceExponent;          ///< Value from 1 to UINT32_MAX that will cause the backface culling
                                        ///  algorithm to ignore area calculations that are less than
                                        ///  (10 ^ -(backfaceExponent)) / abs(w0 * w1 * w2)
                                        ///  Only valid if the NGG backface culler is enabled.
                                        ///  A value of 0 will disable the threshold.

    NggSubgroupSizingType subgroupSizing;   ///< NGG sub-group sizing type

    uint32_t primsPerSubgroup;          ///< Preferred number of GS primitives to pack into a primitive shader
                                        ///  sub-group

    uint32_t vertsPerSubgroup;          ///< Preferred number of vertices consumed by a primitive shader sub-group
};

#if LLPC_CLIENT_INTERFACE_MAJOR_VERSION >= 36
/// ShaderHash represents a 128-bit client-specified hash key which uniquely identifies a shader program.
struct ShaderHash
{
    uint64_t lower;  ///< Lower 64 bits of hash key.
    uint64_t upper;  ///< Upper 64 bits of hash key.
};
#else
typedef uint64_t ShaderHash;
#endif

/// Represents per shader stage options.
struct PipelineShaderOptions
{
#if LLPC_CLIENT_INTERFACE_MAJOR_VERSION >= 36
    ShaderHash clientHash;   ///< Client-supplied unique shader hash. A value of zero indicates that LLPC should
                             ///  calculate its own hash. This hash is used for dumping, shader replacement, SPP, etc.
                             ///  If the client provides this hash, they are responsible for ensuring it is as stable
                             ///  as possible.
#endif
    bool   trapPresent;  ///< Indicates a trap handler will be present when this pipeline is executed,
                         ///  and any trap conditions encountered in this shader should call the trap
                         ///  handler. This could include an arithmetic exception, an explicit trap
                         ///  request from the host, or a trap after every instruction when in debug
                         ///  mode.
    bool   debugMode;    ///< When set, this shader should cause the trap handler to be executed after
                         ///  every instruction.  Only valid if trapPresent is set.
    bool   enablePerformanceData; ///< Enables the compiler to generate extra instructions to gather
                                  ///  various performance-related data.
    bool   allowReZ;     ///< Allow the DB ReZ feature to be enabled.  This will cause an early-Z test
                         ///  to potentially kill PS waves before launch, and also issues a late-Z test
                         ///  in case the PS kills pixels.  Only valid for pixel shaders.
    /// Maximum VGPR limit for this shader. The actual limit used by back-end for shader compilation is the smaller
    /// of this value and whatever the target GPU supports. To effectively disable this limit, set this to UINT_MAX.
    uint32_t  vgprLimit;

    /// Maximum SGPR limit for this shader. The actual limit used by back-end for shader compilation is the smaller
    /// of this value and whatever the target GPU supports. To effectively disable this limit, set this to UINT_MAX.
    uint32_t  sgprLimit;

    /// Overrides the number of CS thread-groups which the GPU will launch per compute-unit. This throttles the
    /// shader, which can sometimes enable more graphics shader work to complete in parallel. A value of zero
    /// disables limiting the number of thread-groups to launch. This field is ignored for graphics shaders.
    uint32_t  maxThreadGroupsPerComputeUnit;

    uint32_t      waveSize;      ///< Control the number of threads per wavefront (GFX10+)
    bool          wgpMode;       ///< Whether to choose WGP mode or CU mode (GFX10+)
    WaveBreakSize waveBreakSize; ///< Size of region to force the end of a wavefront (GFX10+).
                                 ///  Only valid for fragment shaders.

    /// Force loop unroll count. "0" means using default value; "1" means disabling loop unroll.
    uint32_t  forceLoopUnrollCount;

#if LLPC_CLIENT_INTERFACE_MAJOR_VERSION >= 33
    /// Enable LLPC load scalarizer optimization.
    bool enableLoadScalarizer;
#endif
    bool allowVaryWaveSize;      ///< If set, lets the pipeline vary the wave sizes.
    /// Use the LLVM backend's SI scheduler instead of the default scheduler.
    bool      useSiScheduler;

    // Whether update descriptor root offset in ELF
    bool      updateDescInElf;

#if LLPC_CLIENT_INTERFACE_MAJOR_VERSION >= 35
    /// Disable the the LLVM backend's LICM pass.
    bool      disableLicm;
#endif
    /// Default unroll threshold for LLVM.
    uint32_t  unrollThreshold;

    /// The threshold for load scalarizer.
    uint32_t  scalarThreshold;
};

/// Represents YCbCr sampler meta data in resource descriptor
struct SamplerYCbCrConversionMetaData
{
    union
    {
        struct
        {                                            ///< e.g R12X4G12X4_UNORM_2PACK16
            uint32_t channelBitsR               : 5; ///< channelBitsR = 12
            uint32_t channelBitsG               : 5; ///< channelBitsG = 12
            uint32_t channelBitsB               : 5; ///< channelBitsB =  0
            uint32_t                            :17;
        } bitDepth;
        struct
        {
            uint32_t                            :15; ///< VkComponentSwizzle, e.g
            uint32_t swizzleR                   : 3; ///< swizzleR = VK_COMPONENT_SWIZZLE_R(3)
            uint32_t swizzleG                   : 3; ///< swizzleG = VK_COMPONENT_SWIZZLE_G(4)
            uint32_t swizzleB                   : 3; ///< swizzleB = VK_COMPONENT_SWIZZLE_B(5)
            uint32_t swizzleA                   : 3; ///< swizzleA = VK_COMPONENT_SWIZZLE_A(6)
            uint32_t                            : 5;
        } componentMapping;
        struct
        {
            uint32_t                            :27;
            uint32_t yCbCrModel                 : 3; ///< RGB_IDENTITY(0), ycbcr_identity(1),
                                                     ///  _709(2),_601(3),_2020(4)
            uint32_t yCbCrRange                 : 1; ///< ITU_FULL(0), ITU_NARROW(0)
            uint32_t forceExplicitReconstruct   : 1; ///< Disable(0), Enable(1)
        };
        uint32_t u32All;
    } word0;

    union
    {
        struct
        {
            uint32_t planes                     : 2; ///< Number of planes, normally from 1 to 3
            uint32_t lumaFilter                 : 1; ///< FILTER_NEAREST(0) or FILTER_LINEAR(1)
            uint32_t chromaFilter               : 1; ///< FILTER_NEAREST(0) or FILTER_LINEAR(1)
            uint32_t xChromaOffset              : 1; ///< COSITED_EVEN(0) or MIDPOINT(1)
            uint32_t yChromaOffset              : 1; ///< COSITED_EVEN(0) or MIDPOINT(1)
            uint32_t xSubSampled                : 1; ///< true(1) or false(0)
            uint32_t ySubSampled                : 1; ///< true(1) or false(0)
            uint32_t tileOptimal                : 1; ///< true(1) or false(0)
            uint32_t dstSelXYZW                 :12; ///< dst selection Swizzle
            uint32_t undefined                  :11;
        };
        uint32_t u32All;
    } word1;

    union
    {
        /// For YUV formats, bitCount may not equal to bitDepth, where bitCount >= bitDepth
        struct
        {
            uint32_t xBitCount                  : 6; ///< Bit count for x channel
            uint32_t yBitCount                  : 6; ///< Bit count for y channel
            uint32_t zBitCount                  : 6; ///< Bit count for z channel
            uint32_t wBitCount                  : 6; ///< Bit count for w channel
            uint32_t undefined                  : 8;
        } bitCounts;
        uint32_t u32All;
    } word2;

    union
    {
        struct
        {
            uint32_t sqImgRsrcWord1             : 32; ///< Reconstructed sqImgRsrcWord1
        };
        uint32_t u32All;
    } word3;
};

/// Represents info of a shader attached to a to-be-built pipeline.
struct PipelineShaderInfo
{
    const void*                     pModuleData;            ///< Shader module data used for pipeline building (opaque)
    const VkSpecializationInfo*     pSpecializationInfo;    ///< Specialization constant info
    const char*                     pEntryTarget;           ///< Name of the target entry point (for multi-entry)
    ShaderStage                     entryStage;             ///< Shader stage of the target entry point
    uint32_t                        descriptorRangeValueCount; ///< Count of static descriptors
    DescriptorRangeValue*           pDescriptorRangeValues;    ///< An array of static descriptors

    uint32_t                        userDataNodeCount;      ///< Count of user data nodes

    /// User data nodes, providing the root-level mapping of descriptors in user-data entries (physical registers or
    /// GPU memory) to resources referenced in this pipeline shader.
    /// NOTE: Normally, this user data will correspond to the GPU's user data registers. However, Compiler needs some
    /// user data registers for internal use, so some user data may spill to internal GPU memory managed by Compiler.
    const ResourceMappingNode*      pUserDataNodes;
    PipelineShaderOptions           options;               ///< Per shader stage tuning/debugging options
};

/// Represents color target info
struct ColorTarget
{
    bool            blendEnable;          ///< Blend will be enabled for this target at draw time
    bool            blendSrcAlphaToColor; ///< Whether source alpha is blended to color channels for this target
                                          ///  at draw time
    uint8_t         channelWriteMask;     ///< Write mask to specify destination channels
    VkFormat        format;               ///< Color attachment format
};

/// Represents info to build a graphics pipeline.
struct GraphicsPipelineBuildInfo
{
    void*               pInstance;          ///< Vulkan instance object
    void*               pUserData;          ///< User data
    OutputAllocFunc     pfnOutputAlloc;     ///< Output buffer allocator
#if LLPC_CLIENT_INTERFACE_MAJOR_VERSION < 38
    IShaderCache*       pShaderCache;       ///< Shader cache, used to search for the compiled shader data
#endif
    PipelineShaderInfo  vs;                 ///< Vertex shader
    PipelineShaderInfo  tcs;                ///< Tessellation control shader
    PipelineShaderInfo  tes;                ///< Tessellation evaluation shader
    PipelineShaderInfo  gs;                 ///< Geometry shader
    PipelineShaderInfo  fs;                 ///< Fragment shader

    /// Create info of vertex input state
    const VkPipelineVertexInputStateCreateInfo*     pVertexInput;

    struct
    {
        VkPrimitiveTopology  topology;           ///< Primitive topology
        uint32_t             patchControlPoints; ///< Number of control points per patch (valid when the topology is
                                                 ///  "patch")
        uint32_t             deviceIndex;        ///< Device index for device group
        bool                 disableVertexReuse; ///< Disable reusing vertex shader output for indexed draws
        bool                 switchWinding ;     ///< Whether to reverse vertex ordering for tessellation
        bool                 enableMultiView;    ///< Whether to enable multi-view support
    } iaState;                                   ///< Input-assembly state

    struct
    {
        bool        depthClipEnable;            ///< Enable clipping based on Z coordinate
    } vpState;                                  ///< Viewport state

    struct
    {
        bool    rasterizerDiscardEnable;        ///< Kill all rasterized pixels. This is implicitly true if stream out
                                                ///  is enabled and no streams are rasterized
        bool    innerCoverage;                  ///< Related to conservative rasterization.  Must be false if
                                                ///  conservative rasterization is disabled.
        bool    perSampleShading;               ///< Enable per sample shading
        uint32_t  numSamples;                   ///< Number of coverage samples used when rendering with this pipeline
        uint32_t  samplePatternIdx;             ///< Index into the currently bound MSAA sample pattern table that
                                                ///  matches the sample pattern used by the rasterizer when rendering
                                                ///  with this pipeline.
        uint8_t   usrClipPlaneMask;             ///< Mask to indicate the enabled user defined clip planes
        VkPolygonMode       polygonMode;        ///< Triangle rendering mode
        VkCullModeFlags     cullMode;           ///< Fragment culling mode
        VkFrontFace         frontFace;          ///< Front-facing triangle orientation
        bool                depthBiasEnable;    ///< Whether to bias fragment depth values
    } rsState;                                  ///< Rasterizer State

    struct
    {
        bool    alphaToCoverageEnable;          ///< Enable alpha to coverage
        bool    dualSourceBlendEnable;          ///< Blend state bound at draw time will use a dual source blend mode

        ColorTarget target[MaxColorTargets];    ///< Per-MRT color target info
    } cbState;                                  ///< Color target state

    NggState            nggState;           ///< NGG state used for tuning and debugging
    PipelineOptions     options;            ///< Per pipeline tuning/debugging options
};

/// Represents info to build a compute pipeline.
struct ComputePipelineBuildInfo
{
    void*               pInstance;          ///< Vulkan instance object
    void*               pUserData;          ///< User data
    OutputAllocFunc     pfnOutputAlloc;     ///< Output buffer allocator
#if LLPC_CLIENT_INTERFACE_MAJOR_VERSION < 38
    IShaderCache*       pShaderCache;       ///< Shader cache, used to search for the compiled shader data
#endif
    uint32_t            deviceIndex;        ///< Device index for device group
    PipelineShaderInfo  cs;                 ///< Compute shader
    PipelineOptions     options;            ///< Per pipeline tuning options
};

// =====================================================================================================================
/// Represents the unified of a pipeline create info.
struct PipelineBuildInfo
{
    const ComputePipelineBuildInfo*    pComputeInfo;     // Compute pipeline create info
    const GraphicsPipelineBuildInfo*   pGraphicsInfo;    // Graphic pipeline create info
};

// =====================================================================================================================
/// Represents the interfaces of a pipeline dumper.
class IPipelineDumper
{
public:
    /// Dumps SPIR-V shader binary to extenal file.
    ///
    /// @param [in]  pDumpDir     Directory of pipeline dump
    /// @param [in]  pSpirvBin    SPIR-V binary
    static void VKAPI_CALL DumpSpirvBinary(const char*                     pDumpDir,
                                           const BinaryData*               pSpirvBin);

    /// Begins to dump graphics/compute pipeline info.
    ///
    /// @param [in]  pDumpDir                 Directory of pipeline dump
    /// @param [in]  pipelineInfo             Info of the pipeline to be built
    ///
    /// @returns The handle of pipeline dump file
    static void* VKAPI_CALL BeginPipelineDump(const PipelineDumpOptions*       pDumpOptions,
                                              PipelineBuildInfo               pipelineInfo);

    /// Ends to dump graphics/compute pipeline info.
    ///
    /// @param  [in]  pDumpFile         The handle of pipeline dump file
    static void VKAPI_CALL EndPipelineDump(void* pDumpFile);

    /// Disassembles pipeline binary and dumps it to pipeline info file.
    ///
    /// @param [in]  pDumpFile        The handle of pipeline dump file
    /// @param [in]  gfxIp            Graphics IP version info
    /// @param [in]  pPipelineBin     Pipeline binary (ELF)
    static void VKAPI_CALL DumpPipelineBinary(void*                    pDumpFile,
                                              GfxIpVersion             gfxIp,
                                              const BinaryData*        pPipelineBin);

    /// Dump extra info to pipeline file.
    ///
    /// @param [in]  pDumpFile        The handle of pipeline dump file
    /// @param [in]  pStr             Extra string info to dump
    static void VKAPI_CALL DumpPipelineExtraInfo(void*                  pDumpFile,
                                                 const char*            pStr);

    /// Gets shader module hash code.
    ///
    /// @param [in]  pModuleData   Pointer to the shader module data.
    ///
    /// @returns Hash code associated this shader module.
    static uint64_t VKAPI_CALL GetShaderHash(const void* pModuleData);

    /// Calculates graphics pipeline hash code.
    ///
    /// @param [in]  pPipelineInfo  Info to build this graphics pipeline
    ///
    /// @returns Hash code associated this graphics pipeline.
    static uint64_t VKAPI_CALL GetPipelineHash(const GraphicsPipelineBuildInfo* pPipelineInfo);

    /// Calculates compute pipeline hash code.
    ///
    /// @param [in]  pPipelineInfo  Info to build this compute pipeline
    ///
    /// @returns Hash code associated this compute pipeline.
    static uint64_t VKAPI_CALL GetPipelineHash(const ComputePipelineBuildInfo* pPipelineInfo);

    /// Gets graphics pipeline name.
    ///
    /// @param [in]  pPipelineInfo  Info to build this graphics pipeline
    /// @param [out] pPipeName      The full name of this graphics pipeline
    /// @param [in]  nameBufSize    Size of the buffer to store pipeline name
    static void VKAPI_CALL GetPipelineName(const GraphicsPipelineBuildInfo* pPipelineInfo,
                                           char* pPipeName,
                                           const size_t nameBufSize);

    /// Gets compute pipeline name.
    ///
    /// @param [in]  pPipelineInfo  Info to build this compute pipeline
    /// @param [out] pPipeName      The full name of this compute pipeline
    /// @param [in]  nameBufSize    Size of the buffer to store pipeline name
    static void VKAPI_CALL GetPipelineName(const ComputePipelineBuildInfo* pPipelineInfo,
                                           char* pPipeName,
                                           const size_t nameBufSize);

};

} // Llpc

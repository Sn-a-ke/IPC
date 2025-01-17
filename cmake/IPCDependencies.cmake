# Prepare dependencies
#
# For each third-party library, if the appropriate target doesn't exist yet,
# download it via external project, and add_subdirectory to build it alongside
# this project.


# Download and update 3rd_party libraries
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})
list(REMOVE_DUPLICATES CMAKE_MODULE_PATH)
include(IPCDownloadExternal)

################################################################################
# Required libraries
################################################################################

# SuiteSparse
if(IPC_WITH_CHOLMOD)
  set(SUITESPARSE_INCLUDE_DIR_HINTS $ENV{SUITESPARSE_INC})
  set(SUITESPARSE_LIBRARY_DIR_HINTS $ENV{SUITESPARSE_LIB})
  find_package(SuiteSparse REQUIRED)
endif()

# OSQP library
if(NOT TARGET osqp::osqp)
  download_osqp()
  # Make sure the right types are used
  set(DFLOAT OFF CACHE BOOL "Use float numbers instead of doubles"   FORCE)
  set(DLONG  OFF CACHE BOOL "Use long integers (64bit) for indexing" FORCE)
  add_subdirectory(${IPC_EXTERNAL}/osqp EXCLUDE_FROM_ALL)
  if(UNIX AND NOT APPLE)
    set_target_properties(osqpstatic PROPERTIES INTERFACE_LINK_LIBRARIES ${CMAKE_DL_LIBS})
  endif()
  add_library(osqp::osqp ALIAS osqpstatic)
endif()

# libigl
if(NOT TARGET igl)
  download_libigl()
  add_subdirectory(${IPC_EXTERNAL}/libigl EXCLUDE_FROM_ALL)
endif()

# TBB
if(NOT TARGET TBB::tbb)
  download_tbb()
  set(TBB_BUILD_STATIC ON CACHE BOOL " " FORCE)
  set(TBB_BUILD_SHARED OFF CACHE BOOL " " FORCE)
  set(TBB_BUILD_TBBMALLOC OFF CACHE BOOL " " FORCE)
  set(TBB_BUILD_TBBMALLOC_PROXY OFF CACHE BOOL " " FORCE)
  set(TBB_BUILD_TESTS OFF CACHE BOOL " " FORCE)
  add_subdirectory(${IPC_EXTERNAL}/tbb EXCLUDE_FROM_ALL)
  add_library(TBB::tbb ALIAS tbb_static)
endif()

# spdlog
if(NOT TARGET spdlog::spdlog)
    download_spdlog()
    add_library(spdlog INTERFACE)
    add_library(spdlog::spdlog ALIAS spdlog)
    target_include_directories(spdlog SYSTEM INTERFACE ${IPC_EXTERNAL}/spdlog/include)
endif()

# AMGCL
if(IPC_WITH_AMGCL AND NOT TARGET amgcl::amgcl)
  download_amgcl()
  set(Boost_USE_MULTITHREADED TRUE)
  add_subdirectory(${IPC_EXTERNAL}/amgcl EXCLUDE_FROM_ALL)
endif()

# Catch2
if(IPC_WITH_TESTS AND NOT TARGET Catch2::Catch2)
    download_catch2()
    add_subdirectory(${IPC_EXTERNAL}/Catch2 catch2)
    list(APPEND CMAKE_MODULE_PATH ${IPC_EXTERNAL}/Catch2/contrib)
endif()

# finite-diff
if(NOT TARGET finitediff::finitediff)
  download_finite_diff()
  add_subdirectory(${IPC_EXTERNAL}/finite-diff EXCLUDE_FROM_ALL)
endif()

# CLI11
if(NOT TARGET CLI11::CLI11)
  download_cli11()
  add_subdirectory(${IPC_EXTERNAL}/cli11)
endif()

# eigen-gurobi
if(IPC_WITH_GUROBI AND NOT TARGET EigenGurobi::EigenGurobi)
  download_eigen_gurobi()
  add_subdirectory(${IPC_EXTERNAL}/eigen-gurobi EXCLUDE_FROM_ALL)
  add_library(EigenGurobi::EigenGurobi ALIAS EigenGurobi)
endif()

# CCD Wrapper
if(NOT TARGET ccd_wrapper::ccd_wrapper)
  download_ccd_wrapper()
  option(CCD_WRAPPER_WITH_FPRF                              "Enable floating-point root finder method"       ON)
  set(CCD_WRAPPER_WITH_RP  ${IPC_WITH_EXACT_CCD} CACHE BOOL "Enable root parity method"                   FORCE)
  set(CCD_WRAPPER_WITH_BSC ${IPC_WITH_EXACT_CCD} CACHE BOOL "Enable Bernstein sign classification method" FORCE)
  option(CCD_WRAPPER_WITH_TIGHT_INCLUSION                   "Enable Tight Inclusion method"                  ON)
  option(TIGHT_INCLUSION_WITH_NO_ZERO_TOI                   "Enable refinement if CCD produces a zero ToI"   ON)
  add_subdirectory(${IPC_EXTERNAL}/ccd-wrapper)
endif()

# MshIO
if(NOT TARGET mshio::mshio)
  download_mshio()
  add_subdirectory(${IPC_EXTERNAL}/MshIO)
endif()

# GHC Filesystem
if(NOT TARGET ghc::filesystem)
    download_filesystem()
    add_subdirectory(${IPC_EXTERNAL}/filesystem)
    add_library(ghc::filesystem ALIAS ghc_filesystem)
endif()

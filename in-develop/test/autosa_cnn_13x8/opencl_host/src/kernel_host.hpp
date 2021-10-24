#include <iostream>
#include <vector>
#include <fstream>

#define CL_HPP_CL_1_2_DEFAULT_BUILD
#define CL_HPP_TARGET_OPENCL_VERSION 120
#define CL_HPP_MINIMUM_OPENCL_VERSION 120
#define CL_HPP_ENABLE_PROGRAM_CONSTRUCTION_FROM_ARRAY_COMPATIBILITY 1
#define CL_USE_DEPRECATED_OPENCL_1_2_APIS

#include <CL/cl2.hpp>
#include <CL/cl_ext_xilinx.h>

#define OCL_CHECK(error,call)                                       \
    call;                                                           \
    if (error != CL_SUCCESS) {                                      \
      printf("%s:%d Error calling " #call ", error code is: %d\n",  \
              __FILE__,__LINE__, error);                            \
      exit(EXIT_FAILURE);                                           \
    }

std::string xclbin_file_name;

template <typename T>
struct aligned_allocator
{
  using value_type = T;
  T* allocate(std::size_t num)
  {
    void* ptr = nullptr;
    if (posix_memalign(&ptr,4096,num*sizeof(T)))
      throw std::bad_alloc();
    return reinterpret_cast<T*>(ptr);
  }
  void deallocate(T* p, std::size_t num)
  {
    free(p);
  }
};

cl::Program::Binaries import_binary_file()
{
    std::cout << "\n Loading: "<< xclbin_file_name.c_str() << "\n";
    std::ifstream bin_file(xclbin_file_name.c_str(), std::ifstream::binary);
    bin_file.seekg (0, bin_file.end);
    unsigned nb = bin_file.tellg();
    bin_file.seekg (0, bin_file.beg);
    char *buf = new char [nb];
    bin_file.read(buf, nb);

    cl::Program::Binaries bins;
    bins.push_back({buf,nb});
    return bins;
}

std::vector<cl::Device> get_devices() {
    size_t i;
    cl_int err;
    std::vector<cl::Platform> platforms;
    OCL_CHECK(err, err = cl::Platform::get(&platforms));
    cl::Platform platform;
    for (i  = 0 ; i < platforms.size(); i++){
        platform = platforms[i];
        OCL_CHECK(err, std::string platformName = platform.getInfo<CL_PLATFORM_NAME>(&err));
        if (platformName == "Xilinx"){
            std::cout << "\nFound Platform" << std::endl;
            std::cout << "\nPlatform Name: " << platformName.c_str() << std::endl;
            break;
        }
    }
    if (i == platforms.size()) {
        std::cout << "Error: Failed to find Xilinx platform" << std::endl;
        exit(EXIT_FAILURE);
    }
    //Getting ACCELERATOR Devices and selecting 1st such device
    std::vector<cl::Device> devices;
    OCL_CHECK(err, err = platform.getDevices(CL_DEVICE_TYPE_ACCELERATOR, &devices));
    return devices;
}

/* Helper Function */
void host_serialize_A(std::vector<int, aligned_allocator<int>> &A_to, std::vector<int, aligned_allocator<int>> &A_from){
  /* Variable Declaration */
  unsigned int cnt = 0;
  /* Variable Declaration */

  // array
  // io_L3
  for (int c3 = 0; c3 <= 12; c3 += 1) {
    // io_L2
    for (int c4 = 0; c4 <= 15; c4 += 1)
      for (int c5 = 0; c5 <= 255; c5 += 1)
        A_to[cnt++] = A_from[(16 * c3 + c4) * 256 + c5];
  }
}
/* Helper Function */

/* Helper Function */
void host_serialize_B(std::vector<int, aligned_allocator<int>> &B_to, std::vector<int, aligned_allocator<int>> &B_from){
  /* Variable Declaration */
  unsigned int cnt = 0;
  /* Variable Declaration */

  // array
  // io_L3
  for (int c3 = 0; c3 <= 7; c3 += 1) {
    // io_L2
    for (int c4 = 0; c4 <= 63; c4 += 1)
      for (int c5 = 0; c5 <= 255; c5 += 1)
        B_to[cnt++] = B_from[(64 * c3 + c4) * 256 + c5];
  }
}
/* Helper Function */

/* Helper Function */
void host_deserialize_C(std::vector<int, aligned_allocator<int>> &C_to, std::vector<int, aligned_allocator<int>> &C_from){
  /* Variable Declaration */
  unsigned int cnt = 0;
  /* Variable Declaration */

  // array
  // io_L3
  for (int c3 = 0; c3 <= 7; c3 += 1) {
    // io_L2
    for (int c4 = 0; c4 <= 12; c4 += 1) {
      // io_L1
      // pe
      for (int c5 = 0; c5 <= 15; c5 += 1)
        for (int c6 = 0; c6 <= 63; c6 += 1)
          C_to[(16 * c4 + c5) * 512 + (64 * c3 + c6)] = C_from[cnt++];
    }
  }
}
/* Helper Function */


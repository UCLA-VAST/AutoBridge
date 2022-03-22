#include "kernel_host.hpp"
#include <assert.h>
#include <stdio.h>
#include "kernel.h"

void init_array(data_t A[N][N])
{
  int i, j;

  for (i = 0; i < N; i++)
  {
    for (j = 0; j <= i; j++)
      A[i][j] = (data_t)(-j % N) / N + 1;
    for (j = i + 1; j < N; j++) {
      A[i][j] = 0;
    }
    A[i][i] = 1;
  }

  /* Make the matrix positive semi-definite. */
  /* not necessary for LU, but using same code as cholesky */
  int r, s, t;
  data_t B[N][N];
  for (r = 0; r < N; r++)
    for (s = 0; s < N; s++) 
      B[r][s] = 0;
  for (t = 0; t < N; t++)
    for (r = 0; r < N; r++)
      for (s = 0; s < N; s++)
        B[r][s] += A[r][t] * A[s][t];
  for (r = 0; r < N; r++)        
    for (s = 0; s < N; s++)
      A[r][s] = B[r][s];
}

void lu_cpu(data_t A[N][N], data_t L[N][N], data_t U[N][N]) {
  data_t prev_V[N][N][N];
  data_t V_tmp[N][N][N];
  data_t U_tmp[N][N][N];
  data_t L_tmp[N][N][N];

  for (int k = 0; k < N; k++)
    for (int j = k; j < N; j++)
      for (int i = k; i < N; i++) {
        if (k == 0)
          prev_V[i][j][k] = A[i][j];
        else
          prev_V[i][j][k] = V_tmp[i][j][k - 1];
        
        if (j == k) {
          U_tmp[i][j][k] = prev_V[i][j][k];
          U[j][i] = U_tmp[i][j][k];
        } else {
          U_tmp[i][j][k] = U_tmp[i][j - 1][k];

          if (i == k) {            
            L_tmp[i][j][k] = prev_V[i][j][k] / U_tmp[i][j - 1][k]; // final
            L[i][j] = L_tmp[i][j][k];
          } else {
            L_tmp[i][j][k] = L_tmp[i - 1][j][k];
          }
          V_tmp[i][j][k] = prev_V[i][j][k] - L_tmp[i][j][k] * U_tmp[i][j - 1][k];
        }
      }  
}

void lu_device(data_t A[N][N], data_t L[N][N], data_t U[N][N], int argc, char **argv)
{
  {
    if (argc != 2) {
      std::cout << "Usage: " << argv[0] << " <XCLBIN File>" << std::endl;
      return;
    }

    cl_int err;
    std::vector<cl::Device> devices = get_devices();
    cl::Device device = devices[0];
    std::string device_name = device.getInfo<CL_DEVICE_NAME>();
    std::cout << "Found Device=" << device_name.c_str() << std::endl;
    // Creating Context and Command Queue for selected device
    cl::Context context(device);
    cl::CommandQueue q(context, device);
    // Import XCLBIN
    xclbin_file_name = argv[1];
    cl::Program::Binaries kernel_bins = import_binary_file();
    // Create Program and Kernel
    devices.resize(1);
    cl::Program program(context, devices, kernel_bins);
    cl::Kernel krnl(program, "kernel0");

    // Allocate memory in host memory
    std::vector<float, aligned_allocator<float>> dev_A((24) * (24));
    std::vector<float, aligned_allocator<float>> dev_L((23) * (24));
    std::vector<float, aligned_allocator<float>> dev_U((24) * (24));

    // Initialize host buffers
    std::copy(reinterpret_cast<float *>(A), reinterpret_cast<float *>(A) + (24) * (24), dev_A.begin());
    std::copy(reinterpret_cast<float *>(L), reinterpret_cast<float *>(L) + (23) * (24), dev_L.begin());
    std::copy(reinterpret_cast<float *>(U), reinterpret_cast<float *>(U) + (24) * (24), dev_U.begin());

    // Allocate buffers in device memory
    // Buffers are allocated using CL_MEM_USE_HOST_PTR for efficient memory and
    // device-to-host communication
    std::vector<cl::Buffer> buffer_A;
    std::vector<cl::Buffer> buffer_L;
    std::vector<cl::Buffer> buffer_U;
    for (int i = 0; i < 1; i++) {
      OCL_CHECK(err,
                cl::Buffer buffer_A_tmp(context,
                                        CL_MEM_USE_HOST_PTR | CL_MEM_READ_ONLY,
                                        (24) * (24) * sizeof(float),
                                        dev_A.data(),
                                        &err));
      buffer_A.push_back(std::move(buffer_A_tmp));
    }
    for (int i = 0; i < 1; i++) {
      OCL_CHECK(err,
                cl::Buffer buffer_L_tmp(context,
                                        CL_MEM_USE_HOST_PTR | CL_MEM_READ_WRITE,
                                        (23) * (24) * sizeof(float),
                                        dev_L.data(),
                                        &err));
      buffer_L.push_back(std::move(buffer_L_tmp));
    }
    for (int i = 0; i < 1; i++) {
      OCL_CHECK(err,
                cl::Buffer buffer_U_tmp(context,
                                        CL_MEM_USE_HOST_PTR | CL_MEM_READ_WRITE,
                                        (24) * (24) * sizeof(float),
                                        dev_U.data(),
                                        &err));
      buffer_U.push_back(std::move(buffer_U_tmp));
    }

    auto host_begin = std::chrono::high_resolution_clock::now();
    auto fpga_begin = std::chrono::high_resolution_clock::now();
    auto fpga_end = std::chrono::high_resolution_clock::now();

    for (int i = 0; i < 1; i++) {
      OCL_CHECK(err,
                err = q.enqueueMigrateMemObjects({buffer_A[i]}, 0));
    }

    for (int i = 0; i < 1; i++) {
      OCL_CHECK(err,
                err = q.enqueueMigrateMemObjects({buffer_L[i]}, 0));
    }

    for (int i = 0; i < 1; i++) {
      OCL_CHECK(err,
                err = q.enqueueMigrateMemObjects({buffer_U[i]}, 0));
    }

    {
      OCL_CHECK(err, err = krnl.setArg(0, buffer_A[0]));
      OCL_CHECK(err, err = krnl.setArg(1, buffer_L[0]));
      OCL_CHECK(err, err = krnl.setArg(2, buffer_U[0]));
      q.finish();
      fpga_begin = std::chrono::high_resolution_clock::now();

      // Launch the kernel
      OCL_CHECK(err, err = q.enqueueTask(krnl));

      q.finish();
      fpga_end = std::chrono::high_resolution_clock::now();
    }

    for (int i = 0; i < 1; i++) {
      OCL_CHECK(err,
                err = q.enqueueMigrateMemObjects({buffer_L[i]}, CL_MIGRATE_MEM_OBJECT_HOST));
    }
    for (int i = 0; i < 1; i++) {
      OCL_CHECK(err,
                err = q.enqueueMigrateMemObjects({buffer_U[i]}, CL_MIGRATE_MEM_OBJECT_HOST));
    }
    q.finish();
    auto host_end = std::chrono::high_resolution_clock::now();

    // Calculate time
    std::chrono::duration<double> fpga_duration = fpga_end - fpga_begin;
    std::cout << "FPGA Time: " << fpga_duration.count() << " s" << std::endl;
    std::chrono::duration<double> host_duration = host_end - host_begin;
    std::cout << "Host Time: " << host_duration.count() << " s" << std::endl;

    // Restore data from host buffers
    std::copy(dev_L.begin(), dev_L.end(), reinterpret_cast<float *>(L));
    std::copy(dev_U.begin(), dev_U.end(), reinterpret_cast<float *>(U));
  }
}

int main(int argc, char **argv) {
  data_t A[N][N], L[N][N], U[N][N], L_golden[N][N], U_golden[N][N];

  init_array(A);
  for (int i = 0; i < N; i++)
    for (int j = 0; j < N; j++) {
      L[i][j] = 0;
      U[i][j] = 0;
      L_golden[i][j] = 0;
      U_golden[i][j] = 0;
    }
    
  lu_device(A, L, U, argc, argv);
  lu_cpu(A, L_golden, U_golden);

  int err = 0;
  for (int i = 0; i < N; i++)
    for (int j = 0; j <= i; j++) {
      if (fabs((float)L_golden[i][j] - (float)L[i][j]) > 0.001)
        err++;
    }
  for (int i = 0; i < N; i++)
    for (int j = i; j < N; j++) {
      if (fabs((float)U_golden[i][j] - (float)U[i][j]) > 0.001)
        err++;
    }

  if (err)
    printf("Failed with %d errors!\n", err);
  else
    printf("Passed!\n");

  printf("A:\n");
  for (int i = 0; i < N; i++) {
    for (int j = 0; j < N; j++) 
      printf("%f ", A[i][j]);
    printf("\n");
  }

  printf("L_golden:\n");
  for (int i = 0; i < N; i++) {
    for (int j = 0; j < N; j++) {      
      printf("%f ", (i == j)? 1.0 : L_golden[j][i]);      
    }
    printf("\n");
  }

  printf("U_golden:\n");
  for (int i = 0; i < N; i++) {
    for (int j = 0; j < N; j++) {
      printf("%f ", U_golden[i][j]);
    }
    printf("\n");
  }

  printf("L:\n");
  for (int i = 0; i < N; i++) {
    for (int j = 0; j < N; j++) {      
      printf("%f ", (i == j)? 1.0 : (j < i)? L[j][i] : 0.0);      
    }
    printf("\n");
  }

  printf("U:\n");
  for (int i = 0; i < N; i++) {
    for (int j = 0; j < N; j++) {
      printf("%f ", (j < i)? 0.0 : U[i][j]);
    }
    printf("\n");
  }

  return 0;    
}

cmake_minimum_required(VERSION 3.8 FATAL_ERROR)
project(rpg_klt LANGUAGES CXX CUDA)

#if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
#  add_compile_options(-Wall -Wextra -Wpedantic)
#endif()

#enable_language(CUDA)

find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)
find_package(sensor_msgs REQUIRED)
find_package(klt_msg REQUIRED)
find_package(OpenCV REQUIRED)
find_package(CUDA REQUIRED)
find_package(std_msgs REQUIRED)
find_package(cv_bridge REQUIRED)



include_directories( src/ )
include_directories( src/utils/ )
include_directories( src/KLT/ )
include_directories( src/HookUp/ )

set(CUDA_FILES 
	src/HookUp/hookup.cu
	src/HookUp/hookup.hu
	src/KLT/ftr_kernels.cu
	src/utils/tracker.cu
	src/utils/fast.hu)

set(CPP_FILES
	src/run_klt.cpp
	src/KLT/klt.hpp
	src/KLT/klt.cpp
	src/utils/obj.hpp
	src/utils/algo.cpp)

set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS};-O3; -dc; --gpu-code=sm_50; --gpu-architecture=compute_50)
CUDA_ADD_EXECUTABLE(klt_node ${CUDA_FILES} ${CPP_FILES})


add_executable(test_klt src/test_klt.cpp)
ament_target_dependencies(test_klt rclcpp sensor_msgs klt_msg OpenCV std_msgs cv_bridge)
ament_target_dependencies(klt_node rclcpp sensor_msgs klt_msg OpenCV)

#target_compile_options(klt_node PRIVATE $<$<COMPILE_LANGUAGE:CUDA>: -dc>)
set_target_properties(klt_node
   PROPERTIES
       CUDA_SEPARABLE_COMPILATION ON
       CUDA_RESOLVE_DEVICE_SYMBOLS ON
)
install(TARGETS klt_node DESTINATION lib/${PROJECT_NAME})
install(TARGETS test_klt DESTINATION lib/${PROJECT_NAME})

if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  # the following line skips the linter which checks for copyrights
  # comment the line when a copyright and license is added to all source files
  set(ament_cmake_copyright_FOUND TRUE)
  # the following line skips cpplint (only works in a git repo)
  # comment the line when this package is in a git repo and when
  # a copyright and license is added to all source files
  set(ament_cmake_cpplint_FOUND TRUE)
  ament_lint_auto_find_test_dependencies()
endif()

ament_package()

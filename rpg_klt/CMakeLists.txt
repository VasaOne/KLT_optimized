cmake_minimum_required(VERSION 3.8 FATAL_ERROR)
project(rpg_klt LANGUAGES CXX CUDA)

#if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
#  add_compile_options(-Wall -Wextra -Wpedantic)
#endif()

enable_language(CUDA)

find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)
find_package(sensor_msgs REQUIRED)
find_package(klt_msg REQUIRED)
find_package(OpenCV REQUIRED)

include_directories( src/ )
include_directories( src/utils/ )
include_directories( src/KLT/ )
include_directories( src/HookUp/ )

add_executable(klt_node src/run_klt.cpp
        src/KLT/klt.hpp	
	src/KLT/klt.cpp
	src/KLT/ftr_kernels.cu
	src/HookUp/hookup.cu
	src/HookUp/hookup.hu
        src/utils/obj.hpp
	src/utils/tracker.cu	
	src/utils/algo.cpp)
ament_target_dependencies(klt_node rclcpp sensor_msgs klt_msg)

add_executable(test_klt src/test_klt.cpp)
ament_target_dependencies(test_klt rclcpp sensor_msgs klt_msg OpenCV)

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

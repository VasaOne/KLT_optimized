#include "rclcpp/rclcpp.hpp"
#include "sensor_msgs/msg/image.hpp"
#include "cv_bridge/cv_bridge.hpp"
#include "std_msgs/msg/header.hpp"

#include <opencv2/opencv.hpp>

#include "klt_msg/msg/ftr.hpp"
#include "klt_msg/msg/feature_list.hpp"

#define WIDTH 640
#define HEIGHT 600

class ImageNode : public rclcpp::Node 
{
	public :
		ImageNode() : Node("test_klt") {
			cv::Mat img_grey = cv::imread("/home/student/Documents/WK/ros2_wk/src/KLT_optimized/rpg_klt/src/img/concorde.jpg", cv::IMREAD_GRAYSCALE);
			cv::Mat grey;
			cv::resize(img_grey, grey, cv::Size(WIDTH,HEIGHT));
			cv::namedWindow("test", cv::WINDOW_AUTOSIZE);
			cv::imshow("test", img_grey);
			cv::waitKey(0);
			cv::destroyWindow("test");	
			pub = this->create_publisher<sensor_msgs::msg::Image>("klt/image", 10);
			this->loop(grey); 
		}

	private :
		rclcpp::Publisher<sensor_msgs::msg::Image>::SharedPtr pub;
	

		void loop(cv::Mat img){
			char n;
			cv_bridge::CvImagePtr cv_ptr;
			sensor_msgs::msg::Image::SharedPtr msg = cv_bridge::CvImage(std_msgs::msg::Header(), "mono8", img).toImageMsg();
			while(true){
				std::cin >> n; //just to wait
				if(n == 'a' ){
				std::cout <<"end of node test" << std::endl;       
				return;
				}
				pub->publish(*msg.get());	
			}
			return;
		}

};

int main(int argc, char* argv[]){
	rclcpp::init(argc, argv);
	rclcpp::spin(std::make_shared<ImageNode>());
	rclcpp::shutdown();
	return 0;
}

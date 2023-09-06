#include "rclcpp/rclcpp.hpp"
#include "sensor_msgs/msg/image.hpp"

#include <opencv2/opencv.hpp>

#include "klt_msg/msg/ftr.hpp"
#include "klt_msg/msg/feature_list.hpp"


class ImageNode : public rclccp::Node 
{
	public :
		ImageNode(){
			cv::Mat img = cv::imread("./img/concorde.jpg");
			cv::Mat grey;
			cv::cvtColor(img, grey, COLOR_BGR2GRAY);
			cv::namedWindow("test", cv::WINDOW_AUTOSIZE);
			cv::imshow("test", grey);
			cv::watKey(0);
			cv::destroyWindow("test");

			pub = this->create_publisher<sensor_msgs::msg::Image>("klt/image", 10);
		}

	private :
		rclcpp::Publisher<sensor_msgs::msg::Image>::SharedPtr pub;
		sensor_msgs::msg::Image img();
		void imageConverter(cv::Mat grey){
			for(){
				
			}
		
		}
		void loop();

}

int main(int argc, char* argv[]){
	rclcpp::init(argc, argv);
	rclcpp::spin(std::make_shared<ImageNode>());
	rclcpp::shutdown();
	return 0;
}

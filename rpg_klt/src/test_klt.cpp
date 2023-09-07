#include "rclcpp/rclcpp.hpp"
#include "sensor_msgs/msg/image.hpp"

#include <opencv2/opencv.hpp>

#include "klt_msg/msg/ftr.hpp"
#include "klt_msg/msg/feature_list.hpp"

#define WIDTH 640
#define HEIGHT 600

class ImageNode : public rclcpp::Node 
{
	public :
		ImageNode() : Node("test_klt") {
			cv::Mat img_grey = cv::imread("./img/concorde.jpg", cv::IMREAD_GRAYSCALE);
			cv::Mat grey;
			cv::resize(img_grey, grey, cv::Size(WIDTH,HEIGHT));
			cv::namedWindow("test", cv::WINDOW_AUTOSIZE);
			cv::imshow("test", grey);
			cv::waitKey(0);
			cv::destroyWindow("test");
			this->imageConverter(grey);
			img.height = HEIGHT;
			img.width = WIDTH;
			pub = this->create_publisher<sensor_msgs::msg::Image>("klt/image", 10);
			this->loop();
		}

	private :
		rclcpp::Publisher<sensor_msgs::msg::Image>::SharedPtr pub;
		sensor_msgs::msg::Image img;
		void imageConverter(cv::Mat grey){
			for(int x =0; x < WIDTH ;x++ ){
				for(int y = 0; y<HEIGHT ; y++){
					this->img.data[x,y] = grey.at<uint8_t>(x,y);
				}
			}
			return;
		}

		void loop(){
			int n;
			while(true){
				std::cin >> n; //just to wait
				pub->publish(img);	
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

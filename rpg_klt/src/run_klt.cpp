
//ros2 include
#include "rclcpp/rclcpp.hpp"
#include "sensor_msgs/msg/image.hpp"
#include "klt_msg/msg/ftr.hpp"
#include "klt_msg/msg/feature_list.hpp"

//c++ include
#include "klt.hpp"
#include "obj.hpp"

class KltNode : public rclcpp::Node 
{
	public:
	KltNode(float threshold, params_t image_param, int max_feature) : Node("klt_node"), klt(threshold, image_param, max_feature) 
	{
		pub = this->create_publisher<klt_msg::msg::FeatureList>("klt/feature", 10);
		sub = this->create_subscription<sensor_msgs::msg::Image>("klt/image", 999, std::bind(&KltNode::img_callback, this, std::placeholders::_1));	
		RCLCPP_INFO(this->get_logger(), "node created");
	}
	private:
	rclcpp::Publisher<klt_msg::msg::FeatureList>::SharedPtr pub;
	rclcpp::Subscription<sensor_msgs::msg::Image>::SharedPtr sub;
	KLT klt;
		
	void img_callback(const sensor_msgs::msg::Image & image_msg){
		
		
	}
};

int main(int argc, char* argv[]){
	rclcpp::init(argc, argv);
	params_t image_param = {640,600};
	rclcpp::spin(std::make_shared<KltNode>(30.0,image_param ,3000));
	rclcpp::shutdown();
	return 0;
}

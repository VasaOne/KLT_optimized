#include "rclcpp/rclcpp.hpp"
#include "sensor_msgs/msg/image.hpp"
#include "klt_msg/msg/ftr.hpp"
#include "klt_msg/msg/feature_list.hpp"
class KltNode : public rclcpp::Node 
{
	public:
	KltNode() : Node("klt_node") 
	{
		pub = this->create_publisher<klt_msg::msg::FeatureList>("klt/feature", 10);
		sub = this->create_subscription<sensor_msgs::msg::Image>("klt/image", 999, std::bind(&KltNode::img_callback, this, std::placeholders::_1));	
		RCLCPP_INFO(this->get_logger(), "node created");
	}
	private:
	rclcpp::Publisher<klt_msg::msg::FeatureList>::SharedPtr pub;
	rclcpp::Subscription<sensor_msgs::msg::Image>::SharedPtr sub;
	
	void img_callback(const sensor_msgs::msg::Image & image_msg){
		RCLCPP_INFO(this->get_logger(), "finished");
		
	}
};

int main(int argc, char* argv[]){
	rclcpp::init(argc, argv);
	rclcpp::spin(std::make_shared<KltNode>());
	rclcpp::shutdown();
	return 0;
}

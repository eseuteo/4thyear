#include <ros/ros.h>
#include <geometry_msgs/Twist.h>
#include <sensor_msgs/LaserScan.h>
#include <stdlib.h>
#include <math.h>

// Some definitions to enhance code readability
#define REDUCED_FOV 90
#define DANGER_ZONE 0.7
#define HALF_CIRCUNFERENCE 180.0

// Definitions for states
#define AVOID_COLLISION 10
#define SEARCH_DOOR 11
#define KEEP_GOING 12
#define KEEP_TURNING 13
#define TURN_AROUND 14

// Global variables
sensor_msgs::LaserScan::ConstPtr laser_scan_msg;

int nearest_index_in_reduced_fov = 0;
int farthest_index_in_reduced_fov = 0;
int door_index = 0;
int num_of_measurements;
int door_count = 0;
int state = SEARCH_DOOR;

double nearest_angle;
double farthest_angle;
double door_angle;

// Some useful functions
inline bool inside_reduced_fov(int len, int i)
{
	return i > len / 3 && i < len * 2 / 3;
}

inline bool inside_door_fov(int len, int i)
{
	return i > len / 6 && i < len * 5 / 6;
}

inline double rad2deg(double radians)
{
	return radians * HALF_CIRCUNFERENCE / M_PI;
}

inline double deg2rad(double degrees)
{
	return degrees * M_PI / HALF_CIRCUNFERENCE;
}

// Function to obtain info from the environment
void obtain_info()
{
	num_of_measurements = laser_scan_msg->ranges.size();

	double angle_min = laser_scan_msg->angle_min;
	double angle_increment = laser_scan_msg->angle_increment;
	double nearest_range_in_reduced_fov = 100.0;
	double farthest_range_in_reduced_fov = 0.0;
	double cumulative_range = 0.0;

	int door_start_index = 0;
	bool started_to_see_door = false;

	for (int i = 0; i < num_of_measurements; i++)
	{
		// Reduced FOV: only a 90º slice of the normal FOV
		if (inside_reduced_fov(num_of_measurements, i))
		{
			cumulative_range += laser_scan_msg->ranges[i];
			if (laser_scan_msg->ranges[i] < nearest_range_in_reduced_fov)
			{
				nearest_index_in_reduced_fov = i;
				nearest_angle = angle_min + angle_increment * i;
				nearest_range_in_reduced_fov = laser_scan_msg->ranges[i];
			}
			if (laser_scan_msg->ranges[i] > farthest_range_in_reduced_fov)
			{
				farthest_index_in_reduced_fov = i;
				farthest_angle = angle_min + angle_increment * i;
				farthest_range_in_reduced_fov = laser_scan_msg->ranges[i];
			}
		}

		// Another reduced FOV: the 180º in front of the robot
		if (inside_door_fov(num_of_measurements, i))
		{
			if ((laser_scan_msg->ranges[i - 1] - laser_scan_msg->ranges[i]) < -2.5)
			{
				door_start_index = i;
			}
			else if (started_to_see_door && (laser_scan_msg->ranges[i - 1] - laser_scan_msg->ranges[i]) > 2.5)
			{
				door_count++;
				door_index = door_start_index + (door_start_index - i) / 2;
				door_angle = angle_min + angle_increment * door_index;
				started_to_see_door = false;
			}
		}
	}

	// If the robot is surrounded by walls
	if (cumulative_range < 230)
	{
		state = TURN_AROUND;
	}
}

void processScanCallback(const sensor_msgs::LaserScan::ConstPtr &msg)
{
	laser_scan_msg = msg;
	obtain_info();
}

int main(int argc, char **argv)
{
	ros::init(argc, argv, "exploring");
	ros::NodeHandle nh;
	ros::Subscriber sub = nh.subscribe("/laser_scan", 1000, processScanCallback);
	ros::Publisher pub = nh.advertise<geometry_msgs::Twist>("/cmd_vel", 1000);
	srand(time(0));
	ros::Rate rate(10);
	ros::Time begin = ros::Time::now();

	while (begin.toSec() == 0)
		begin = ros::Time::now();

	double ellapsed_time = 0;

	// Variables to be used to plan movement:
	// Planning movement
	int next_state = KEEP_GOING;
	int iterations = 0;
	int current_iteration = 0;

	// Determining turn direction
	int sign_helper = 0;

	// Saving velocity through iterations
	double current_turn = 0.0;
	double current_linear_velocity = 0.5;

	// In the "AVOIDING_COLLISION" state
	bool avoiding_collision = false;

	while ((ros::ok()) && (ellapsed_time < 60 * 5))
	{
		ROS_INFO("Current state: %d", state);

		geometry_msgs::Twist msg;
		ros::spinOnce();

		state = laser_scan_msg->ranges[nearest_index_in_reduced_fov] < DANGER_ZONE && !avoiding_collision ? AVOID_COLLISION : state;

		switch (state)
		{
		case TURN_AROUND:
			// Robot is in trouble, go backwards for 6 iterations and then turn
			current_linear_velocity = -0.5;
			msg.linear.x = current_linear_velocity;
			current_turn = (nearest_angle > 0) ? -1 : 1;
			current_turn *= 90;
			iterations = 6;
			current_iteration = 0;
			state = KEEP_GOING;
			next_state = KEEP_TURNING;
			avoiding_collision = true;
			break;
		case AVOID_COLLISION:
			// Regular collision avoidance. Turn to the opposite side the obstacle is
			avoiding_collision = true;
			sign_helper = (nearest_angle > 0) ? -1 : 1;
			msg.linear.x = 0.0;
			current_turn = sign_helper * (num_of_measurements * laser_scan_msg->angle_increment / 2.0) + (-sign_helper * nearest_angle) * 2;
			msg.angular.z = current_turn;
			iterations = 2;
			current_iteration = 0;
			state = KEEP_TURNING;
			next_state = SEARCH_DOOR;
			break;
		case SEARCH_DOOR:
			// If the robot has seen a door, turn towards that direction and go
			// If not:
			// 	If there is not an obstacle near, go to the farthest point
			//	Else, go forward
			if (door_count)
			{
				sign_helper = ((door_angle > 0) ? 1 : -1);
			}
			else
			{
				if (laser_scan_msg->ranges[nearest_index_in_reduced_fov] > 1.5)
				{
					sign_helper = (farthest_angle > 0) ? 1 : -1;
				}
				else
				{
					sign_helper = 0;
				}
			}
			current_linear_velocity = 0.5;
			msg.linear.x = current_linear_velocity;
			current_turn = sign_helper * (num_of_measurements * laser_scan_msg->angle_increment / 2.0) + (-sign_helper * nearest_angle) * 2;
			msg.angular.z = current_turn;
			state = door_count ? KEEP_TURNING : KEEP_GOING;
			iterations = 2;
			current_iteration = 0;
			next_state = door_count ? KEEP_GOING : SEARCH_DOOR;
			break;
		case KEEP_TURNING:
			// State for the robot to keep turning
			msg.linear.x = 0.5;
			msg.angular.z = current_turn;
			if (current_iteration++ > iterations)
			{
				state = next_state;
				iterations = std::ceil(laser_scan_msg->ranges[std::floor(num_of_measurements / 2)]) * 8;
				current_iteration = 0;
				msg.angular.z = 0.0;
				current_linear_velocity = 0.5;
				if (state == SEARCH_DOOR || state == TURN_AROUND)
				{
					avoiding_collision = false;
				}
				next_state = SEARCH_DOOR;
			}
			break;
		case KEEP_GOING:
			// State for the robot to keep going forward
			msg.linear.x = current_linear_velocity;
			msg.angular.z = 0;
			state = ++current_iteration > iterations ? next_state : KEEP_GOING;
			if (state != KEEP_GOING)
			{
				iterations = 5;
				current_iteration = 0;
			}
			break;
		}

		pub.publish(msg);
		door_count = 0;
		ROS_INFO("[robot_explorer] Sending velocity command: linear= %.2f angular=%.2f", msg.linear.x, msg.angular.z);
		rate.sleep();
		ros::spinOnce();
		ros::Time current = ros::Time::now();
		ellapsed_time = (current - begin).toSec();
		ROS_INFO("[robot_explorer] Ellpased time: %.2f", ellapsed_time);
	}
}
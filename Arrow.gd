extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var steeper_than_source_corner: bool;
var steeper_than_destination_corner: bool;
var cartesian_source_x;
var cartesian_source_y;
var cartesian_dest_x;
var cartesian_dest_y;
var source_width;
var source_height;
var dest_width;
var dest_height;
var source_center_x;
var source_center_y;
var dest_center_x;
var dest_center_y;
var source_above_destination;
var source_right_of_destination;
var slope_inverted;
var slope;
var source_peri_x;
var dest_peri_x;
var source_peri_y;
var dest_peri_y;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func line_emulator(local_slope: float,intercept: float,independent: float):
	return local_slope*independent+intercept

func connect_neurons(source_neuron_pointer,destination_neuron_pointer):
	#Get coordinates/Lengths out of neurons
	var source_neuron_upper_left = source_neuron_pointer.get_position()
	var destination_neuron_upper_left = destination_neuron_pointer.get_position()
	var source_neuron_size = source_neuron_pointer.get_node("State").get_size()
	var destination_neuron_size = destination_neuron_pointer.get_node("State").get_size()
	
	#Unpacking Coordinates/Lengths
	cartesian_source_x = source_neuron_upper_left.x
	cartesian_source_y = source_neuron_upper_left.y
	cartesian_dest_x = destination_neuron_upper_left.x
	cartesian_dest_y = destination_neuron_upper_left.y
	source_width = source_neuron_size.x
	source_height = source_neuron_size.y
	dest_width =  destination_neuron_size.x
	dest_height = destination_neuron_size.y
	
	get_geometric_centers()
	compute_steepness()
	get_relative_positions()
	get_slope()
	perimeter_intercept()
	
	#Compute Arrow Length and scale accordingly
	var dy = dest_peri_y - source_peri_y
	var dx = dest_peri_x - source_peri_x
	var arrow_length = sqrt((pow(dy,2)+pow(dx,2)))
	set_scale(Vector2(arrow_length/1584,0.2))
	
	#Set arrow tail position
	set_position(Vector2(source_peri_x,source_peri_y))
	
	 #Set Arrow Rotation
	set_rotation_degrees(rad2deg(atan2(dy,dx)))

func get_geometric_centers():
	#Checking Steepness
	#Getting Geometric Centers of Neurons 
	source_center_x = cartesian_source_x + source_width/2
	source_center_y = cartesian_source_y + source_height/2
	dest_center_x = cartesian_dest_x + dest_width/2
	dest_center_y = cartesian_dest_y + dest_height/2

func compute_steepness():
	steeper_than_source_corner = abs((source_center_y - dest_center_y)*(source_width/2)) > abs((source_height/2)*(source_center_x-dest_center_x))
	steeper_than_destination_corner = abs((source_center_y-dest_center_y)*(dest_width/2)) > abs((dest_height/2)*(source_center_x-dest_center_x))

func get_relative_positions():
	#Checking Relative Positioning
	source_above_destination = source_center_y < dest_center_y
	source_right_of_destination = source_center_x > dest_center_x
	
func get_slope():
	#Calculating Slope of Line Between Neuron Centers, as well as whether slope should be inverted or not when stored
	if abs(source_center_y-dest_center_y) > abs(source_center_x - dest_center_x):
		slope = (source_center_x-dest_center_x)/(source_center_y-dest_center_y)
		slope_inverted = true
	else:
		slope = (source_center_y-dest_center_y)/(source_center_x-dest_center_x)
		slope_inverted = false

func perimeter_intercept():
	if steeper_than_source_corner:
		#Then y of source intercept is known
		var local_slope = slope
		if not slope_inverted:
			local_slope = pow(slope,-1)
		var x_intercept = source_center_x - local_slope*source_center_y
		if source_above_destination:
			source_peri_y = source_height + cartesian_source_y
		else:
			source_peri_y = cartesian_source_y
		source_peri_x = line_emulator(local_slope,x_intercept,source_peri_y) 
	else:
		#Then x of source intercept is known
		var local_slope = slope
		if slope_inverted:
			local_slope = pow(slope,-1)
		var y_intercept = source_center_y - local_slope*source_center_x
		if source_right_of_destination:
			source_peri_x = cartesian_source_x
		else:
			source_peri_x = cartesian_source_x + source_width
		source_peri_y = line_emulator(local_slope,y_intercept,source_peri_x)
	if steeper_than_destination_corner:
		#Then y of destination intercept intercept is known
		var local_slope = slope
		if not slope_inverted:
			local_slope = pow(slope,-1)
		var x_intercept = dest_center_x - local_slope*dest_center_y
		if source_above_destination:
			dest_peri_y = cartesian_dest_y
		else:
			dest_peri_y = cartesian_dest_y + dest_height
		dest_peri_x = line_emulator(local_slope,x_intercept,dest_peri_y) 
	else:
		#Then x of destination intercept is known
		var local_slope = slope
		if slope_inverted:
			local_slope = pow(slope,-1)
		var y_intercept = dest_center_y - local_slope*dest_center_x
		if source_right_of_destination:
			dest_peri_x = cartesian_dest_x + dest_width
		else:
			dest_peri_x = cartesian_dest_x
		dest_peri_y = line_emulator(local_slope,y_intercept,dest_peri_x)
	
	
	
	

class_name CarPhysics
extends RigidBody3D

@export var steer_joints: Array[HingeJoint3D]

func _process(_delta: float) -> void:
	steer_to_angle(deg_to_rad(20))

func steer_to_angle(angle: float):
	for joint: HingeJoint3D in steer_joints:
		joint.set("angular_limit/lower", angle)
		joint.set("angular_limit/upper", angle)

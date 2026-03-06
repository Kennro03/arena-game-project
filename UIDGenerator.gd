extends Node

var _counter: int = 0

func generate(prefix: String = "") -> String:
	_counter += 1
	var timestamp := Time.get_ticks_usec()  # microseconds since engine start
	var uid := "%s_%d_%d" % [prefix, timestamp, _counter]
	#print("Generated UID : " + str(uid))
	return uid

extends Node
class_name DFile

var timings = {}

var filePath
var data
var pos = 0
	
func loadFile(path):
	filePath = path
	var file = FileAccess.open(path, FileAccess.READ)
	data = file.get_buffer(file.get_length())
	return true
	
	
func seek(offset):
	pos = offset

func get_position():
	return pos
	
func get_8():
	var ret = data[pos]
	pos+=1
	return ret

func bulkByteArr(size):
	var ret = data.slice(pos,pos+size+1)
	pos += size
	return ret

func get_16():
	var ret = data.slice(pos,pos+1+1)
	pos+=2
	
	var rety = (ret[1] << 8) + ret[0]
	return (ret[1] << 8) + ret[0]
	
func get_32u():
	var ret = data.slice(pos,pos+3+1)
	pos+=4
	return (ret[3] << 24) + (ret[2] << 16) + (ret[1] << 8 ) + ret[0]


func get_32():
	if pos == 4063337:
		breakpoint
	var ret = data.slice(pos,pos+3+1)
	var spb = StreamPeerBuffer.new()
	spb.data_array = ret
	var single_float = spb.get_32()
	pos+=4
	return single_float

func get_16u():
	var ret = data.slice(pos,pos+1+1)
	ret =  (ret[1] << 8) + ret[0]
	if (ret & 0x8000):
		ret -= 0x8000
		ret = (-32767 + ret) -1
		
	pos+=2
	return ret

func get_Vector32():
	var x = get_float32()
	var y = get_float32()
	var z = get_float32()
	return Vector3(x,y,z)

func get_float32():
	var ret = data.slice(pos,pos+3+1)
	var spb = StreamPeerBuffer.new()
	spb.data_array = ret
	var single_float = spb.get_float()
	pos+=4
	return single_float
	

func get_buffer(size):
	var ret = data.slice(pos,pos+(size-1)+1)#not sure why using -1 here
	pos+=size
	return ret
	
func get_String(length):
	var ret = data.slice(pos,pos+(length-1)+1).get_string_from_ascii()
	
	pos+=length
	return ret.to_upper()
	
	#func get_line():
	#	return data.get_line()
func get_len():
	return data.size()
		
func eof_reached():
	return pos >= data.size()

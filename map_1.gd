extends Node
@onready var main_menu= $"CanvasLayer/Main Menu"
@onready var address_entry = $"CanvasLayer/Main Menu/MarginContainer/VBoxContainer/AddressEntry"

const PORT = 9999
const Player= preload("res://main_character.tscn")
var enet_peer = ENetMultiplayerPeer.new()

func _on_host_button_pressed() -> void:
	main_menu.hide() # Replace with function body.
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer= enet_peer
	multiplayer.peer_connected.connect(add_player)
	add_player(multiplayer.get_unique_id())
	#upnp_setup()
	
func _on_join_button_pressed() -> void:
	main_menu.hide()
	enet_peer.create_client(address_entry.text,PORT)
	multiplayer.multiplayer_peer=enet_peer


func add_player(peer_id):
	var player = Player.instantiate()
	player.name= str(peer_id)
	add_child(player)

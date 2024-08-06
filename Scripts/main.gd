extends Node

@onready var main_menu = $Control/Main_Menu

const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()

const PLAYER = preload("res://Scenes/character.tscn")
	
func _unhandled_input(event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	pass

func _on_host_button_pressed():
	main_menu.hide()
	
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	
	multiplayer.peer_connected.connect(add_player) 
	
	add_player(multiplayer.get_unique_id())
	
	pass

func _on_join_button_pressed():
	main_menu.hide()
	
	enet_peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.connection_failed.connect(failed)
	pass

func add_player(peer_id):
	var player = PLAYER.instantiate()
	player.name = str(peer_id)
	print("Connection success!")
	add_child(player)
	
	pass
	
func failed():
	main_menu.show()
	
	pass
	

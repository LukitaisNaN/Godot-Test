extends Node

@onready var main_menu = $Control/Main_Menu

const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()

const PLAYER = preload("res://Scenes/character.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

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
	
	var _ip_address = $Control/MarginContainer/VBoxContainer/ipButton
	
	enet_peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = enet_peer
	
	pass # Replace with function body.

func add_player(peer_id):
	var player = PLAYER.instantiate()
	player.name = str(peer_id)
	add_child(player)

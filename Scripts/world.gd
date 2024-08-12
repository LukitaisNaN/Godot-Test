extends Node

@onready var main_menu = $Canvas_Layer/Main_Menu
@onready var adress = $Canvas_Layer/Main_Menu/VBoxContainer/ip_input

const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()

const PLAYER = preload("res://Player/character.tscn")

func _ready():
	pass

func _process(delta):
	pass


func _on_host_pressed():
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	add_player(multiplayer.get_unique_id())
	
	main_menu.hide()
	pass

func _on_join_pressed():
	enet_peer.create_client(adress.text, PORT)
	multiplayer.multiplayer_peer = enet_peer
	main_menu.hide()
	## Handle disconnections
	multiplayer.server_disconnected.connect(show_menu)
	pass

func add_player(peer_id):
	var player = PLAYER.instantiate()
	player.name = str(peer_id)
	add_child(player)
	pass
	
func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

func show_menu(myText:String):
	main_menu.show()
	adress.set_placeholder("Connection Failed")

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

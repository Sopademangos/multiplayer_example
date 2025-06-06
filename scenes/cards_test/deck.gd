extends Control

@onready var spawn: Node2D = $"../Spawn"

const card_scene = preload("res://scenes/cards_test/card_test.tscn")

var cards = [
	"res://scenes/cards_test/types/bear_trap.tres",
	"res://scenes/cards_test/types/beast.tres",
	"res://scenes/cards_test/types/bomb.tres", 
	"res://scenes/cards_test/types/box.tres",
	"res://scenes/cards_test/types/fire_trap.tres",
	"res://scenes/cards_test/types/slime.tres",
	"res://scenes/cards_test/types/snail.tres",
	"res://scenes/cards_test/types/spikes.tres",
	"res://scenes/cards_test/types/tank.tres"
]

var new_card: CardData

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	# Robar 5 cartas al azar sin repetir
	for i in range(5):
		var node_card = card_scene.instantiate()
		robar_carta_inicial()
		node_card.datos = new_card
		add_child(node_card)
		node_card.position = spawn.get_child(i).position
	#print("Cartas restantes en mazo: %s" % cards)
	get_parent().cards = cards
	cards.shuffle()

# Función para robar una carta inicial (al azar y eliminarla del mazo)
func robar_carta_inicial():
	var indice = rng.randi_range(0, cards.size() - 1)
	var card = cards[indice]
	new_card = load(card)
	cards.remove_at(indice)

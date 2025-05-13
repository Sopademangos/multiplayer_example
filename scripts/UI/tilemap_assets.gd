extends TileMapLayer

@export var loop_width_in_tiles := 200
@export var loop_height_in_tiles := 14
var occupied := {}

var big_assets = [
	{
		"size": Vector2i(2, 2),
		"tiles": {
			Vector2i(0, 0): Vector2i(0, 16),
			Vector2i(1, 0): Vector2i(1, 16),
			Vector2i(0, 1): Vector2i(0, 17),
			Vector2i(1, 1): Vector2i(1, 17),
		}
	},
	
	{
		"size": Vector2i(2, 2),
		"tiles": {
			Vector2i(0, 0): Vector2i(2, 16),
			Vector2i(1, 0): Vector2i(3, 16),
			Vector2i(0, 1): Vector2i(2, 17),
			Vector2i(1, 1): Vector2i(3, 17),
		}
	},
	
	{
		"size": Vector2i(2, 2),
		"tiles": {
			Vector2i(0, 0): Vector2i(4, 16),
			Vector2i(1, 0): Vector2i(5, 16),
			Vector2i(0, 1): Vector2i(4, 17),
			Vector2i(1, 1): Vector2i(5, 17),
		}
	},
	
	{
		"size": Vector2i(2, 2),
		"tiles": {
			Vector2i(0, 0): Vector2i(0, 18),
			Vector2i(1, 0): Vector2i(1, 18),
			Vector2i(0, 1): Vector2i(0, 19),
			Vector2i(1, 1): Vector2i(1, 19),
		}
	},
	
	{
		"size": Vector2i(2, 2),
		"tiles": {
			Vector2i(0, 0): Vector2i(2, 18),
			Vector2i(1, 0): Vector2i(3, 18),
			Vector2i(0, 1): Vector2i(2, 19),
			Vector2i(1, 1): Vector2i(3, 19),
		}
	},
	
	{
		"size": Vector2i(2, 2),
		"tiles": {
			Vector2i(0, 0): Vector2i(4, 18),
			Vector2i(1, 0): Vector2i(5, 18),
			Vector2i(0, 1): Vector2i(4, 19),
			Vector2i(1, 1): Vector2i(5, 19),
		}
	},
	
	{
		"size": Vector2i(2, 2),
		"tiles": {
			Vector2i(0, 0): Vector2i(0, 20),
			Vector2i(1, 0): Vector2i(1, 20),
			Vector2i(0, 1): Vector2i(0, 21),
			Vector2i(1, 1): Vector2i(1, 21),
		}
	},
	
	{
		"size": Vector2i(2, 2),
		"tiles": {
			Vector2i(0, 0): Vector2i(2, 20),
			Vector2i(1, 0): Vector2i(3, 20),
			Vector2i(0, 1): Vector2i(2, 21),
			Vector2i(1, 1): Vector2i(3, 21),
		}
	},
	
	{
		"size": Vector2i(2, 2),
		"tiles": {
			Vector2i(0, 0): Vector2i(2, 20),
			Vector2i(1, 0): Vector2i(3, 20),
			Vector2i(0, 1): Vector2i(2, 21),
			Vector2i(1, 1): Vector2i(3, 21),
		}
	},
	
	{
		"size": Vector2i(1, 2),
		"tiles": {
			Vector2i(0, 0): Vector2i(6, 16),
			Vector2i(0, 1): Vector2i(6, 17),
		}
	},
	
	{
		"size": Vector2i(1, 2),
		"tiles": {
			Vector2i(0, 0): Vector2i(7, 16),
			Vector2i(0, 1): Vector2i(7, 17),
		}
	},
	
	{
		"size": Vector2i(1, 2),
		"tiles": {
			Vector2i(0, 0): Vector2i(8, 16),
			Vector2i(0, 1): Vector2i(8, 17),
		}
	},
	
	{
		"size": Vector2i(1, 2),
		"tiles": {
			Vector2i(0, 0): Vector2i(9, 16),
			Vector2i(0, 1): Vector2i(9, 17),
		}
	},
	
]

var decor_assets = [
	{
		"size": Vector2i(1, 2),
		"tiles": {
			Vector2i(0, 0): Vector2i(17, 16),
			Vector2i(0, 1): Vector2i(17, 17),
		}
	},
	{
		"size": Vector2i(1, 2),
		"tiles": {
			Vector2i(0, 0): Vector2i(18, 16),
			Vector2i(0, 1): Vector2i(18, 17),
		}
	},
	{
		"size": Vector2i(1, 2),
		"tiles": {
			Vector2i(0, 0): Vector2i(18, 18),
			Vector2i(0, 1): Vector2i(18, 19),
		}
	},
	{
		"size": Vector2i(1, 2),
		"tiles": {
			Vector2i(0, 0): Vector2i(17, 18),
			Vector2i(0, 1): Vector2i(17, 19),
		}
	},
]

func _ready():
	randomize()
	place_big_assets()
	place_decors()

func place_big_assets():
	for i in 30: # número de intentos o assets
		var asset = big_assets.pick_random()
		var size = asset.size

		var x = randi_range(0, loop_width_in_tiles - size.x)
		var y = randi_range(0, loop_height_in_tiles - size.y)

		var can_place = true
		for offset in asset.tiles.keys():
			var pos = Vector2i(x, y) + offset
			if occupied.has(pos):
				can_place = false
				break

		if can_place:
			for offset in asset.tiles.keys():
				var pos = Vector2i(x, y) + offset
				var atlas_coord = asset.tiles[offset]
				set_cell(pos, 0, atlas_coord)
				occupied[pos] = true

func place_decors():
	for i in 30: # número de intentos o assets
		var asset = decor_assets.pick_random()
		var size = asset.size

		var x = randi_range(0, loop_width_in_tiles - size.x)
		var y = randi_range(0, loop_height_in_tiles - size.y)

		var can_place = true
		for offset in asset.tiles.keys():
			var pos = Vector2i(x, y) + offset
			if occupied.has(pos):
				can_place = false
				break

		if can_place:
			for offset in asset.tiles.keys():
				var pos = Vector2i(x, y) + offset
				var atlas_coord = asset.tiles[offset]
				set_cell(pos, 0, atlas_coord)
				occupied[pos] = true

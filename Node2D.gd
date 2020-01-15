extends Node2D

var state = 0
var start_position = [5,1]
var fig_types = ['T','I','O','J','L','S','Z']
var MAP_WIDTH = 19

var current_fig = fig_types[randi() % 7]

var figs = {
	'T':{
		'color':0,
		'relat_pos':[[[0,-1],[-1,0],[0,0],[1,0]],
			[[1,0],[0,-1],[0,0],[0,1]],
			[[0,1],[1,0],[0,0],[-1,0]],
			[[-1,0],[0,1],[0,0],[0,-1]]
		]
	},
	'I':{
		'color':1,
		'relat_pos':[[[0,-2],[0,-1],[0,0],[0,1]],
			[[2,0],[1,0],[0,0],[-1,0]],
			[[0,2],[0,1],[0,0],[0,-1]],
			[[-2,0],[-1,0],[0,0],[1,0]]
		]
	},
	'O':{
		'color':2,
		'relat_pos':[[[0,-1],[1,-1],[0,0],[1,0]],
			[[1,0],[1,1],[0,0],[0,1]],
			[[0,1],[-1,1],[0,0],[-1,0]],
			[[-1,0],[-1,-1],[0,0],[0,-1]]
		]
	},
	'J':{
		'color':3,
		'relat_pos':[[[1,-1],[-1,0],[0,0],[1,0]],
			[[1,1],[0,-1],[0,0],[0,1]],
			[[-1,1],[1,0],[0,0],[-1,0]],
			[[-1,-1],[0,1],[0,0],[0,-1]]
		]
	},
	'L':{
		'color':4,
		'relat_pos':[[[-1,-1],[-1,0],[0,0],[1,0]],
			[[1,-1],[0,-1],[0,0],[0,1]],
			[[1,1],[1,0],[0,0],[-1,0]],
			[[-1,1],[0,1],[0,0],[0,-1]]
		]
	},
	'S':{
		'color':5,
		'relat_pos':[[[0,-1],[1,-1],[0,0],[-1,0]],
			[[1,0],[1,1],[0,0],[0,-1]],
			[[0,1],[-1,1],[0,0],[1,0]],
			[[-1,0],[-1,-1],[0,0],[0,1]]
		]
	},
	'Z':{
		'start_pos':[[9,0],[10,0],[10,1],[11,1]],
		'color':6,
		'relat_pos':[[[-1,-1],[0,-1],[0,0],[1,0]],
			[[1,-1],[1,0],[0,0],[0,1]],
			[[1,1],[0,1],[0,0],[-1,0]],
			[[-1,1],[-1,0],[0,0],[0,-1]]
		]
	}
}

var fig_t = [[start_position[0]+figs[current_fig]['relat_pos'][state][0][0],start_position[1]+figs[current_fig]['relat_pos'][state][0][1]],
	[start_position[0]+figs[current_fig]['relat_pos'][state][1][0],start_position[1]+figs[current_fig]['relat_pos'][state][1][1]],
	[start_position[0]+figs[current_fig]['relat_pos'][state][2][0],start_position[1]+figs[current_fig]['relat_pos'][state][2][1]],
	[start_position[0]+figs[current_fig]['relat_pos'][state][3][0],start_position[1]+figs[current_fig]['relat_pos'][state][3][1]],
	]

func collision_fig (fig,x,y):
	var result = false
	for tile in fig:
		if [tile[0]+x,tile[1]+y] in fig:
			continue
		if $TileMap.get_cell(tile[0]+x,tile[1]+y) != -1:
			result = true
	return result

func draw_fig (fig,tile_t):
	for tile in fig:
		$TileMap.set_cell(tile[0],tile[1],tile_t)

func slide_fig (fig, x, y):
	for tile in fig:
		tile[0] += x
		tile[1] += y

func rotate_fig (fig, state, fig_rot):
	if state == 3:
		state = 0
	else:
		state += 1
	for i in range(len(fig)):
		fig[i][0] = fig[2][0] + fig_rot[state][i][0]
		fig[i][1] = fig[2][1] + fig_rot[state][i][1]
	return state

func clean_rows ():
	for row in range(1,MAP_WIDTH):
		var expire = true
		for col in range(1,MAP_WIDTH):
			if $TileMap.get_cell(col,row) == -1:
				expire = false
		if expire:
			for rev_row in range(row,1,-1):
				for col in range(1,MAP_WIDTH):
					$TileMap.set_cell(col,rev_row,$TileMap.get_cell(col,rev_row-1))

func _ready():
	randomize()
	draw_fig(fig_t,figs[current_fig]['color'])
	$Timer.connect("timeout", self, "_on_Timer_timeout")

func _process(delta):
	if Input.is_action_just_pressed("ui_left") and not collision_fig(fig_t,-1,0):
		draw_fig(fig_t,-1)
		slide_fig(fig_t, -1, 0)
		draw_fig(fig_t,figs[current_fig]['color'])
	if Input.is_action_just_pressed("ui_right") and not collision_fig(fig_t,1,0):
		draw_fig(fig_t,-1)
		slide_fig(fig_t, 1, 0)
		draw_fig(fig_t,figs[current_fig]['color'])
	if Input.is_action_just_pressed("ui_up"):
		draw_fig(fig_t,-1)
		state = rotate_fig(fig_t, state, figs[current_fig]['relat_pos'])
		draw_fig(fig_t,figs[current_fig]['color'])

func _on_Timer_timeout():
	if not collision_fig(fig_t,0,1):
		draw_fig(fig_t,-1)
		slide_fig(fig_t, 0, 1)
		draw_fig(fig_t,figs[current_fig]['color'])
	else:
		clean_rows ()
		state = 0
		current_fig = fig_types[randi() % 7]
		fig_t = [[start_position[0]+figs[current_fig]['relat_pos'][state][0][0],start_position[1]+figs[current_fig]['relat_pos'][state][0][1]],
			[start_position[0]+figs[current_fig]['relat_pos'][state][1][0],start_position[1]+figs[current_fig]['relat_pos'][state][1][1]],
			[start_position[0]+figs[current_fig]['relat_pos'][state][2][0],start_position[1]+figs[current_fig]['relat_pos'][state][2][1]],
			[start_position[0]+figs[current_fig]['relat_pos'][state][3][0],start_position[1]+figs[current_fig]['relat_pos'][state][3][1]],
			]
		draw_fig(fig_t,figs[current_fig]['color'])
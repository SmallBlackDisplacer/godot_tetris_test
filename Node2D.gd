extends Node2D

var state = 0
var start_position = [10,1]
#var fig_types = ['T','I','O','J','L','S','Z']
var fig_types = ['T','I','O']

var current_fig = fig_types[randi() % 3]

#var fig_t = [[10,0],[9,1],[10,1],[11,1]]
#var fig_t_rot = [[[0,-1],[-1,0],[0,0],[1,0]],[[1,0],[0,-1],[0,0],[0,1]],[[0,1],[1,0],[0,0],[-1,0]],[[-1,0],[0,1],[0,0],[0,-1]]]


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
		'start_pos':[[11,0],[9,1],[10,1],[11,1]],
		'color':3,
		'relat_pos':[]
	},
	'L':{
		'start_pos':[[9,0],[9,1],[10,1],[11,1]],
		'color':4,
		'relat_pos':[]
	},
	'S':{
		'start_pos':[[10,0],[11,0],[10,1],[9,1]],
		'color':5,
		'relat_pos':[]
	},
	'Z':{
		'start_pos':[[9,0],[10,0],[10,1],[11,1]],
		'color':6,
		'relat_pos':[]
	}
}

var fig_t = [[start_position[0]+figs[current_fig]['relat_pos'][state][0][0],start_position[1]+figs[current_fig]['relat_pos'][state][0][1]],
	[start_position[0]+figs[current_fig]['relat_pos'][state][1][0],start_position[1]+figs[current_fig]['relat_pos'][state][1][1]],
	[start_position[0]+figs[current_fig]['relat_pos'][state][2][0],start_position[1]+figs[current_fig]['relat_pos'][state][2][1]],
	[start_position[0]+figs[current_fig]['relat_pos'][state][3][0],start_position[1]+figs[current_fig]['relat_pos'][state][3][1]],
	]

func column(fig, n):
	var result = []
	for el in fig:
		result.append(el[n])
	return result

func collision_fig (fig,x,y):
	var safe_x = column(fig,0)
	var safe_y = column(fig,1)
	var result = false
	for tile in fig:
		if tile[0]+x in safe_x and tile[1]+y in safe_y:
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
	for row in range(1,19):
		var expire = true
		for col in range(1,19):
			if $TileMap.get_cell(col,row) == -1:
				expire = false
		if expire:
			for rev_row in range(row,1,-1):
				for col in range(1,19):
					$TileMap.set_cell(col,rev_row,$TileMap.get_cell(col,rev_row-1))

func _ready():
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
		current_fig = fig_types[randi() % 3]
		fig_t = [[start_position[0]+figs[current_fig]['relat_pos'][state][0][0],start_position[1]+figs[current_fig]['relat_pos'][state][0][1]],
			[start_position[0]+figs[current_fig]['relat_pos'][state][1][0],start_position[1]+figs[current_fig]['relat_pos'][state][1][1]],
			[start_position[0]+figs[current_fig]['relat_pos'][state][2][0],start_position[1]+figs[current_fig]['relat_pos'][state][2][1]],
			[start_position[0]+figs[current_fig]['relat_pos'][state][3][0],start_position[1]+figs[current_fig]['relat_pos'][state][3][1]],
			]
		draw_fig(fig_t,figs[current_fig]['color'])
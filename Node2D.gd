extends Node2D

#var x= 10
#var y = 0

var state = 0
var fig_t = [[10,0],[9,1],[10,1],[11,1]]
var fig_t_rot = [[[0,-1],[-1,0],[0,0],[1,0]],[[1,0],[0,-1],[0,0],[0,1]],[[0,1],[1,0],[0,0],[-1,0]],[[-1,0],[0,1],[0,0],[0,-1]]]

var figs = {
	'T':{
		'start_pos':[[10,0],[9,1],[10,1],[11,1]],
		'relat_pos':[[[0,-1],[-1,0],[0,0],[1,0]],
			[[1,0],[0,-1],[0,0],[0,1]],
			[[0,1],[1,0],[0,0],[-1,0]],
			[[-1,0],[0,1],[0,0],[0,-1]]
		]
	},
	'I':{
		'start_pos':[[10,0],[10,1],[10,2],[10,3]],
		'relat_pos':[[[0,-2],[0,-1],[0,0],[0,1]],
			[[2,0],[1,0],[0,0],[-1,0]],
			[[0,2],[0,1],[0,0],[0,-1]],
			[[-2,0],[-1,0],[0,0],[1,0]]
		]
	},
	'O':{
		'start_pos':[[10,0],[11,0],[10,1],[11,1]],
		'relat_pos':[[[0,-1],[1,-1],[0,0],[1,0]],
			[[1,0],[1,1],[0,0],[0,1]],
			[[0,1],[-1,1],[0,0],[-1,0]],
			[[-1,0],[-1,-1],[0,0],[0,-1]]
		]
	},
	'J':{
		'start_pos':[[11,0],[9,1],[10,1],[11,1]],
		'relat_pos':[]
	},
	'L':{
		'start_pos':[[9,0],[9,1],[10,1],[11,1]],
		'relat_pos':[]
	},
	'S':{
		'start_pos':[[10,0],[11,0],[10,1],[9,1]],
		'relat_pos':[]
	},
	'Z':{
		'start_pos':[[9,0],[10,0],[10,1],[11,1]],
		'relat_pos':[]
	}
}

func top_fig (fig):
	var top_el_y = 20
	var top_el_x
	for tile in fig:
		if tile[1] < top_el_y:
			top_el_y = tile[1]
			top_el_x = tile[0]
	return [top_el_x, top_el_y]

func bot_fig (fig):
	var bot_el_y = 0
	var bot_el_x
	for tile in fig:
		if tile[1] > bot_el_y:
			bot_el_y = tile[1]
			bot_el_x = tile[0]
	return [bot_el_x, bot_el_y]

func left_fig (fig):
	var left_el_x = 20
	var left_el_y
	for tile in fig:
		if tile[0] < left_el_x:
			left_el_x = tile[0]
			left_el_y = tile[1]
	return [left_el_x, left_el_y]

func right_fig (fig):
	var right_el_x = 0
	var right_el_y
	for tile in fig:
		if tile[0] > right_el_x:
			right_el_x = tile[0]
			right_el_y = tile[1]
	return [right_el_x, right_el_y]

func borders_fig (fig):
	return {'top':top_fig(fig),'bot':bot_fig(fig),'left':left_fig(fig),'right':right_fig(fig)}

func column(fig, n):
	var result = []
	for el in fig:
		result.append(el[n])
	return result

func collision_fig (fig,x,y,tile_t):
	var safe_x = column(fig,0)
	var safe_y = column(fig,1)
	var result = false
	for tile in fig:
		if tile[0]+x in safe_x and tile[1]+y in safe_y:
			continue
		if $TileMap.get_cell(tile[0]+x,tile[1]+y) == tile_t:
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
			if $TileMap.get_cell(col,row) != 0:
				expire = false
		if expire:
			for rev_row in range(row,1,-1):
				for col in range(1,19):
					$TileMap.set_cell(col,rev_row,$TileMap.get_cell(col,rev_row-1))

func _ready():
	draw_fig(fig_t,0)
	$Timer.connect("timeout", self, "_on_Timer_timeout")

func _process(delta):
	var borders = borders_fig(fig_t)
	if borders['bot'][1] < 19:
		if Input.is_action_just_pressed("ui_left") and borders['left'][0] > 1 and not collision_fig(fig_t,-1,0,0):
			draw_fig(fig_t,-1)
			slide_fig(fig_t, -1, 0)
			draw_fig(fig_t,0)
		if Input.is_action_just_pressed("ui_right") and borders['right'][0] < 18 and not collision_fig(fig_t,1,0,0):
			draw_fig(fig_t,-1)
			slide_fig(fig_t, 1, 0)
			draw_fig(fig_t,0)
		if Input.is_action_just_pressed("ui_up"):
			draw_fig(fig_t,-1)
			state = rotate_fig(fig_t, state, fig_t_rot)
			draw_fig(fig_t,0)

func _on_Timer_timeout():
	var borders = borders_fig(fig_t)
	if borders['bot'][1] < 18 and not collision_fig(fig_t,0,1,0):
		draw_fig(fig_t,-1)
		slide_fig(fig_t, 0, 1)
		draw_fig(fig_t,0)
	else:
		clean_rows ()
		fig_t = [[10,0],[9,1],[10,1],[11,1]]
		draw_fig(fig_t,0)
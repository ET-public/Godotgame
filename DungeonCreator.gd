extends Navigation2D

onready var tileMap := $TileMap4
onready var tileTemp := $TileMap2
onready var gM := $"../.."
onready var drevo = preload("res://Teren/Surovine/TreeTypeOne.tscn")
onready var bush = preload("res://Teren/Surovine/bushOne.tscn")
onready var kip = preload("res://Teren/Surovine/kip.tscn")
onready var kipSpawner = preload("res://Teren/Surovine/necroSpawner.tscn")
onready var kamni = [preload("res://Teren/Surovine/kamenOne.tscn"), preload("res://Teren/Surovine/kamenTwo.tscn"), preload("res://Teren/Surovine/kamenThree.tscn")]
onready var enemyManager = $"../EnemyManager"
onready var tmp3 = $TileMap3


var noIsl := []
var velikost = 5
var mS = 30
var repeats = 5
var waterSpawnChance = 30


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	createWorld()
	pass

func placeObjects(var kater, koliko : int, var tmp):
	for _i in range(koliko):
		var num = randi()%(tmp.size() -1)
		var temp = kater.instance()
		temp.position = tileMap.map_to_world(tmp[num])*4 + Vector2(16 / 2, 16/2)*4
		$YSort.call_deferred("add_child", temp)
		tmp.remove(num)
	pass

func createWorld():
	for ch in $YSort.get_children():
		ch.queue_free()
	mapCreatorCellA()
	for i in 100:
		for j in 100:
			tmp3.set_cell(i-50,j-50,1)
	for i in tileMap.get_used_cells_by_id(0):
		tmp3.set_cellv(i, -1)
	noIsl = removeIslands(findAllIslands(), true)
	var noIslTemp = noIsl.duplicate()
	for i in range(velikost):
		for j in range(velikost):
			tileMap.set_cell(i-7,j-7,0)
			pass
	tileMap.update_bitmask_region(Vector2(-mS/2,-mS/2),Vector2(mS,mS))
#	var tmp = tileMap.get_used_cells_by_id(0)
	placeObjects(drevo, 8, noIslTemp)
	placeObjects(kip, 1, noIslTemp)
	placeObjects(bush, 8, noIslTemp)
	placeObjects(kipSpawner, 1, noIslTemp)
	for _i in range(0, 10):
		var num = randi()%(noIslTemp.size() -1)

		var temp = kamni[randi()%3].instance()
		temp.position = tileMap.map_to_world(noIslTemp[num])*4 + Vector2(16 / 2, 16/2)*4
		$YSort.call_deferred("add_child", temp)
	pass # Replace with function body.
	

func randSt(minimum, maximum):
	var t = maximum - minimum + 1
	var st = (randi()%t) + minimum
	return st
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(ev):
	if ev is InputEventKey and ev.scancode == KEY_Z and not ev.echo:
		enemyManager.threadSafe = false
		createWorld()
#func _process(delta):
#	pass
var sosedi = [Vector2(0,1),Vector2(-1,0), Vector2(1,0), Vector2(0,-1)]
func removeIslands(var arr, var delete):
	if arr.size() == 1:
		return arr[0]
	var najv = -1
	var najvv = -1

	for i in arr:
		if i.size() > najvv:
			najvv = i.size()
			najv = i
	for i in arr:
		if i != najv:
			for j in i:
				if delete:
					tileMap.set_cell(j.x, j.y, 1)
	return najv
	pass

func findAllIslands():
	var otoki := []
	var tmp = tileMap.get_used_cells_by_id(0)
	var notChecked = tmp
	var checked := []
	for i in tmp:
		if i in notChecked && !(i in checked):
			var island := []
			checked.append(i)
			island.append(i)
			var toCheck := []
			for j in sosedi:
				var aj = i + j
				var sosedid = tileMap.get_cell(aj.x, aj.y)
				if aj in checked:
					continue
				checked.append(aj)
				if sosedid != 0:
					continue
				island.append(aj)
				toCheck.append(aj)
			for g in toCheck:
				for j in sosedi:
					var aj = g + j
					var sosedid = tileMap.get_cell(aj.x, aj.y)
					if aj in checked:
						continue
					checked.append(aj)
					if sosedid != 0:
						continue
					island.append(aj)
					toCheck.append(aj)
				
				pass
			otoki.append(island)
			pass
		else:
			pass
		pass
	print("St otokov")
	print(otoki.size())
	return otoki
	
	

func mapCreatorCellA():
	for i in range(-mS/2,mS/2):
		for j in range(-mS/2,mS/2):
			var temp = randi()%100
			if temp > (100-waterSpawnChance):
				temp = 1
			else:
				temp = 0
			tileMap.set_cell(i,j, temp)
			tileTemp.set_cell(i,j,temp)
			pass
	for _x in range(repeats):
		for i in range(-mS/2,mS/2):
			for j in range(-mS/2,mS/2):
				var stVode := 0
				for n in range(-1,2):
					for k in range(-1,2):
						if j == 0 && k == 0:
							pass
						elif tileMap.get_cell(i+n,j+k) == 1:
							stVode +=1
						elif tileMap.get_cell(i+n,j+k) == -1:
							stVode+=5
				if stVode < 2:
					tileTemp.set_cell(i,j,0)
				elif stVode > 3:
					tileTemp.set_cell(i,j,1)
				else:
					tileTemp.set_cell(i,j,0)
					
		for i in range(-mS/2,mS/2):
			for j in range(-mS/2,mS/2):
				tileMap.set_cell(i,j, tileTemp.get_cell(i,j))
	pass

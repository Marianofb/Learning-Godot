extends Node2D

## GAME ## 
var game : Game = null

@onready var tileMap = $"../TileMapLayer"
var aStarGrid : AStarGrid2D

func _ready() -> void:
	await owner._ready()
	game = owner as Game
	InitializeAStar()

func InitializeAStar():
	aStarGrid = AStarGrid2D.new()
	aStarGrid.region = tileMap.get_used_rect()
	aStarGrid.cell_size = Vector2(16,16)
	aStarGrid.update()
	
	# Escanear todas las celdas después de inicializar
	scan_all_grid_cells()

func GetPathToTarget(selfPosition, targetPosition) -> Array[Vector2i]:
	var path = aStarGrid.get_id_path(
		tileMap.local_to_map(selfPosition),
		tileMap.local_to_map(targetPosition)
	).slice(1)
	
	ShortenPath(path)
	
	return path

func ShortenPath(path : Array[Vector2i]):
	var pastPoint = Vector2.ZERO
	var i = 0
	while i < path.size() - 1:
		if(i > 0):
			var currentPoint = tileMap.map_to_local(path[i - 1]) - tileMap.map_to_local(path[i])
			if currentPoint == pastPoint:
				path.remove_at(i)
				path.remove_at(i-1)
			pastPoint = currentPoint
		i += 1

# Función para escanear todas las celdas del grid
func scan_all_grid_cells() -> Dictionary:
	var cells_with_objects = {}
	var grid_size = aStarGrid.region.size
	var grid_position = aStarGrid.region.position
	
	#print("Escaneando grid desde posición ", grid_position, " con tamaño ", grid_size)
	
	# Recorrer todas las celdas del grid
	for x in range(grid_position.x, grid_position.x + grid_size.x):
		for y in range(grid_position.y, grid_position.y + grid_size.y):
			var cell_pos = Vector2i(x, y)
			
			# Verificar si hay objetos en esta celda
			if is_object_in_cell(cell_pos):
				var object_name = get_object_name_in_cell(cell_pos)
				cells_with_objects[cell_pos] = object_name
				#print("Encontrado objeto '", object_name, "' en celda ", cell_pos)
	
	#print("Escaneo completado. Se encontraron ", cells_with_objects.size(), " celdas con objetos.")
	return cells_with_objects

# Función para detectar si hay un objeto en una celda específica
func is_object_in_cell(cell_position: Vector2i) -> bool:
	# Convertir posición de celda a coordenadas globales
	var global_pos = tileMap.map_to_local(cell_position)
	
	# Realizar una consulta de física
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = global_pos
	
	# Puedes configurar la máscara de colisión si es necesario
	# query.collision_mask = tu_máscara
	
	var result = space_state.intersect_point(query)
	return result.size() > 0

# Función para obtener el nombre del objeto en una celda
func get_object_name_in_cell(cell_position: Vector2i) -> String:
	var global_pos = tileMap.map_to_local(cell_position)
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = global_pos
	
	var result = space_state.intersect_point(query)
	var colliderMask : int = result[0]["collider"].get_collision_mask()
	if(colliderMask == game.GetLayerMaskObstacle()):
		#print("Collider Mask: ", colliderMask)
		aStarGrid.set_point_solid(cell_position, true)
		pass
		
	
	return ""

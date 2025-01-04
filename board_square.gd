class_name BoardSquare 
extends ColorRect

signal square_selected(at_position: Vector2)

@export var piece: Piece = null
@export var rank: int
@export var file: int

@export var dark_square_color = Color.SADDLE_BROWN
@export var light_square_color = Color.PAPAYA_WHIP
@export var selected_square_color = Color.CADET_BLUE
@export var move_candidate_color = Color.LIGHT_GREEN

var default_square_color = dark_square_color
var currently_selected: bool = false
var is_move_candidate: bool = false


func _init(square_rank: int = 0, square_file: int = 0) -> void:
	self.rank = square_rank
	self.file = square_file
	
	var is_dark = ((self.rank) + (self.file)) % 2 == 1
	self.default_square_color = dark_square_color if is_dark else light_square_color
	
func _to_string() -> String:
	return "%s @ %s" % [self.piece, Vector2(file, rank)]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.set_color(self.default_square_color)
	if piece:
		self.add_child(piece)
		
	self.set_process_input(true)
	
func remove_piece() -> void:
	if piece:
		piece.queue_free()
		piece = null
		
func add_piece(newPiece: Piece) -> void:
	self.remove_piece()
	piece = newPiece
	piece.position = size / 2
	self.add_child(piece)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func unselect() -> void:
	self.currently_selected = false
	self.set_color(self.default_square_color)

func mark_selected() -> void:
	self.currently_selected = true
	self.set_color(self.selected_square_color)
	
func mark_as_move_candidate() -> void:
	self.is_move_candidate = true
	self.set_color(self.move_candidate_color)
	
func unmark_as_move_candidate() -> void:
	self.is_move_candidate = false
	self.set_color(self.default_square_color)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if self.get_rect().has_point(event.position):
			self.set_color(Color.BLUE)
		elif self.color != self.default_square_color:
			if self.currently_selected:
				self.set_color(self.selected_square_color)
			elif self.is_move_candidate:
				self.set_color(self.move_candidate_color)
			else:
				self.set_color(self.default_square_color)
	elif event is InputEventMouseButton and event.is_released():
		if self.get_rect().has_point(event.position):
			square_selected.emit(Vector2(self.file, self.rank))

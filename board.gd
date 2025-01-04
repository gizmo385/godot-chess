class_name Board extends Node2D

# Customizing the size of the board
@export var square_size: Vector2 = Vector2(75, 75)

# A representation of the standard initial position of the board in Chess
const NUMBER_OF_RANKS = 8
const NUMBER_OF_FILES = 8
const STARTING_POSITION_FEN_STRING = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

# Pre-calculated movement for pieces
const KNIGHT_MOVEMENTS: Array[Vector2] = [
	Vector2(2, 1), Vector2(-2, 1), Vector2(2, -1), Vector2(-2, -1),
	Vector2(1, 2), Vector2(-1, 2), Vector2(1, -2), Vector2(-1, -2),
]

const KING_MOVEMENTS: Array[Vector2] = [
	Vector2(1, 0), Vector2(1, 1), Vector2(1, -1), Vector2(-1, 0), 
	Vector2(-1, 1), Vector2(-1, -1), Vector2(0, 1), Vector2(0, -1)
]

func _calculate_bishop_move_offsets() -> Array[Vector2]:
	var offsets: Array[Vector2] = []
	for offset in NUMBER_OF_FILES:
		offsets.append(Vector2(offset, offset))
		offsets.append(Vector2(-offset, offset))
		offsets.append(Vector2(offset, -offset))
		offsets.append(Vector2(-offset, -offset))
	return offsets
var BISHOP_MOVEMENTS = _calculate_bishop_move_offsets()

func _calculate_rook_move_offsets() -> Array[Vector2]:
	var offsets: Array[Vector2] = []
	for rank_or_file in NUMBER_OF_FILES:
		offsets.append(Vector2(0, rank_or_file))
		offsets.append(Vector2(0, -rank_or_file))
		offsets.append(Vector2(rank_or_file, 0))
		offsets.append(Vector2(-rank_or_file, 0))
	return offsets
	
var ROOK_MOVEMENTS = _calculate_rook_move_offsets()


# Maintaining state of the board
const NO_SQUARE_SELECTED = Vector2(-1, -1)
var currently_selected_square = NO_SQUARE_SELECTED
var move_candidates_for_currently_selected_square: Array[Vector2] = []
var squares = []
var whitePieceSquares: Dictionary = {}
var blackPieceSquares: Dictionary = {}
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for rank in range(NUMBER_OF_RANKS):
		squares.append([])
		for file in range(NUMBER_OF_FILES):
			var board_square = BoardSquare.new(rank, file)
			board_square.connect("square_selected", self._on_square_selected)
			# Scale and offset the squares from one another
			board_square.size = square_size
			board_square.position = square_size * Vector2(file, rank)
			squares[rank].append(board_square)
			self.add_child(board_square)
			
	# Put pieces in their starting positions
	self.load_fen_string(STARTING_POSITION_FEN_STRING)
			
			
func add_piece_to_square(square: Vector2, piece: Piece):
	squares[square.y][square.x].add_piece(piece)
	if piece.is_black():
		self.blackPieceSquares[square] = piece
	else:
		self.whitePieceSquares[square] = piece
	
func load_fen_string(placement: String) -> void:
	var sections = placement.split(" ")
	var rank_positions = sections[0].split("/")
	
	for current_rank in len(rank_positions):
		var positions = rank_positions[current_rank]
		var current_file = 0
		for character in positions.split():
			# If the character is an integer, it represents that many empty spaces
			if character.is_valid_int():
				current_file += int(character)
			else:
				# Otherwise, we need to add a piece to the current rank/file
				self.add_piece_to_square(Vector2(current_file, current_rank), Piece.from_fen_string(character))
				current_file += 1

	
func clear_selection() -> void:
	if self.currently_selected_square != NO_SQUARE_SELECTED:
		self.squares[self.currently_selected_square.y][self.currently_selected_square.x].unselect()
	self.currently_selected_square = NO_SQUARE_SELECTED
	
func get_square_at(at_position: Vector2) -> BoardSquare:
	return self.squares[at_position.y][at_position.x]
	
func get_piece_at(at_position: Vector2) -> Piece:
	return self.get_square_at(at_position).piece
	
func remove_piece_at(at_position: Vector2) -> void:
	var square = self.get_square_at(at_position)
	square.unselect()
	square.remove_piece()
	self.whitePieceSquares.erase(at_position)
	self.blackPieceSquares.erase(at_position)
	
func clear_move_candidates() -> void:
	for old_candidate in self.move_candidates_for_currently_selected_square:
		self.get_square_at(old_candidate).unmark_as_move_candidate()
	self.move_candidates_for_currently_selected_square = []
	
func move_piece(from_position: Vector2, to_position: Vector2) -> void:
	var piece = self.get_piece_at(from_position)
	if not piece:
		# If there isn't a piece on the current square, then whatever
		return
		
	var pieceOnTargetSquare = self.get_piece_at(to_position)
	if pieceOnTargetSquare:
		# TODO: At some point, we need to do actual move/capture validation here
		# For now, we'll just yeet the piece on the target square
		pass
		
	# Clear out the pieces at both squares
	self.remove_piece_at(to_position)
	self.remove_piece_at(currently_selected_square)
	
	# Add the piece to the new square
	self.add_piece_to_square(to_position, Piece.new(piece.pieceColor, piece.pieceType))
	self.clear_selection()

func _on_square_selected(at_position: Vector2) -> void:
	var new_candidate_moves = self.get_valid_moves_from_position(at_position)
	var move_is_valid = self.move_candidates_for_currently_selected_square.has(at_position)
	
	if currently_selected_square == at_position:
		# If someone reselects the same square they'd already selected, clear the selection
		self.clear_selection()
		self.clear_move_candidates()
	elif self.currently_selected_square == NO_SQUARE_SELECTED and not self.get_piece_at(at_position):
		# If someone selects an empty square and they haven't already selected a piece, skip it
		pass
	elif currently_selected_square == NO_SQUARE_SELECTED:
		# if they haven't selected something yet and there is a piece there, mark it as selected
		self.currently_selected_square = at_position
		self.get_square_at(at_position).mark_selected()
		self.clear_move_candidates()
		for move_candidate in new_candidate_moves:
			self.get_square_at(move_candidate).mark_as_move_candidate()
		self.move_candidates_for_currently_selected_square = new_candidate_moves
	elif move_is_valid:
		# If they've previously selected a square with a piece on it, move the piece
		self.clear_move_candidates()
		self.move_piece(self.currently_selected_square, at_position)	
	else:
		self.clear_selection()
		self.clear_move_candidates()
		
func is_position_on_board(at_position: Vector2) -> bool:
	return (
		at_position.y >= 0 
		and at_position.y < NUMBER_OF_RANKS 
		and at_position.x >= 0 
		and at_position.x < NUMBER_OF_FILES
	)
	
func is_movement_obstructed(
		from_position: Vector2, to_position: Vector2, obstructions: Dictionary,
) -> bool:
	var x_change = (to_position.x - from_position.x)
	var y_change = (to_position.y - from_position.y)
	var distance_to_destination = from_position.distance_to(to_position)
	var direction_to_destination = from_position.direction_to(to_position)
	
	if x_change == 0 or y_change == 0:
		# If one of the components isn't changing, then we want to compare the distances between the
		# potential obstruction and the destination. If the obstruction is closer, then we are
		# blocked and cannot proceed.
		for obstructive_point in obstructions.keys():
			var distance_to_obstruction = from_position.distance_to(obstructive_point)
			var direction_to_obstruction = from_position.direction_to(obstructive_point)
			if obstructive_point == from_position:
				# We can't block ourselves
				continue
			elif x_change == 0 and obstructive_point.x != from_position.x:
				# If the obstructing piece isn't in the same file as we are, ignore it
				continue
			elif y_change == 0 and obstructive_point.y != from_position.y:
				# If the obstructing piece isn't in the same file as we are, ignore it
				continue
			elif direction_to_obstruction == direction_to_destination and distance_to_obstruction < distance_to_destination:
				print("Move of %s to %s blocked by %s" % [self.get_square_at(from_position), to_position, self.get_square_at(obstructive_point)])
				return true
	else:
		# Build the line equation y = mx + b between our origin and destination point
		var line_slope = y_change / x_change
		var line_offset = from_position.y - (line_slope * from_position.x)
		for obstructive_point in obstructions.keys():
			if obstructive_point == from_position:
				# We can't block ourselves
				continue
			elif obstructive_point.y == (line_slope * obstructive_point.x) + line_offset:
				# If the obstruction point satisfies this equation and is closer to us than our
				# destination, then it's in the way and we can't move there.
				var distance_to_obstruction = from_position.distance_to(obstructive_point)
				return distance_to_obstruction < distance_to_destination
	return false

func get_valid_moves_from_position(at_position: Vector2) -> Array[Vector2]:
	var square = self.get_square_at(at_position)
	var piece = square.piece
	var move_candidates: Array[Vector2] = []
	if not piece:
		return move_candidates
	
	var can_be_obstructed = true
	match piece.pieceType:
		PieceSprite.PieceType.PAWN:
			# Pawns can move in the following way:
			# 1. One square forward away from their original starting side
			var rank_offset = 1 if piece.is_black() else -1
			var pawn_starting_rank = 1 if piece.is_black() else (NUMBER_OF_RANKS - 2)
			move_candidates.append(at_position + Vector2(0, 1 * rank_offset))
			
			# 2. Two squares if they're in their home position
			if at_position.y == pawn_starting_rank:
				move_candidates.append(at_position + Vector2(0, 2 * rank_offset))
				
			# 3. Diagonally one square forward to attack an enemy piece TODO Fix this
			for diagonal_offset in [Vector2(1, 1 * rank_offset), Vector2(-1, rank_offset)]:
				var diagonal_candidate = at_position + diagonal_offset
				var diagonal_square = self.get_square_at(diagonal_candidate)
				if diagonal_square.piece and diagonal_square.piece.is_opponent_of(piece):
					print('Adding diagonal square ', at_position + diagonal_offset)
					move_candidates.append(diagonal_candidate)
			#4. TODO: A pawn can capture another pawn via en passant
		PieceSprite.PieceType.ROOK:
			# Rooks can move in a straight  line along the current rank or file
			for offset in ROOK_MOVEMENTS:
				move_candidates.append(at_position + offset)
		PieceSprite.PieceType.KNIGHT:
			# Can move in L's and ignores obstructions
			can_be_obstructed = false
			for offset in KNIGHT_MOVEMENTS:
				move_candidates.append(at_position + offset)
		PieceSprite.PieceType.BISHOP:
			# Can move diagonally
			for offset in BISHOP_MOVEMENTS:
				move_candidates.append(at_position + offset)
		PieceSprite.PieceType.QUEEN:
			# Can move like both a rook and a bishop
			for offset in BISHOP_MOVEMENTS:
				move_candidates.append(at_position + offset)
			for offset in ROOK_MOVEMENTS:
				move_candidates.append(at_position + offset)
			# TODO: Handle queen castling
		PieceSprite.PieceType.KING:
			# Can move to all neighboring squares
			# TODO: This will need to be expanded to handle check/checkmate
			# TODO: Handle king castling
			for offset in KING_MOVEMENTS:
				move_candidates.append(at_position + offset)

	# Prune things that aren't actually valid
	var final_move_candidates: Array[Vector2] = []
	var potential_obstructions = self.whitePieceSquares if piece.is_white() else blackPieceSquares

	for candidate in move_candidates:
		# Clamp to the board edges
		if not self.is_position_on_board(candidate):
			continue
			
		# Remove pieces occupied by friendly pieces
		var candidate_piece = self.get_piece_at(candidate)
		if candidate_piece and not candidate_piece.is_opponent_of(piece):
			continue
			
		if can_be_obstructed and self.is_movement_obstructed(at_position, candidate, potential_obstructions):
			continue
		final_move_candidates.append(candidate)	
	return final_move_candidates

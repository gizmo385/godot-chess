class_name Piece extends Control



@export var sprite: PieceSprite
@export var pieceColor: PieceSprite.PieceColor
@export var pieceType: PieceSprite.PieceType

func _init(
	newPieceColor: PieceSprite.PieceColor = PieceSprite.PieceColor.WHITE, 
	newPieceType: PieceSprite.PieceType = PieceSprite.PieceType.PAWN,
) -> void:
	self.pieceColor = newPieceColor
	self.pieceType = newPieceType
	self.sprite = PieceSprite.new(newPieceColor, newPieceType)

func _ready() -> void:
	self.sprite = PieceSprite.new(self.pieceColor, self.pieceType)
	self.add_child(sprite)
	
func _to_string():
	var piece_color_string = "White" if self.is_white() else "Black"
	var piece_type_string = ""
	match self.pieceType:
		PieceSprite.PieceType.PAWN: piece_type_string = "Pawn"
		PieceSprite.PieceType.ROOK: piece_type_string = "Rook"
		PieceSprite.PieceType.KNIGHT: piece_type_string = "Knight"
		PieceSprite.PieceType.BISHOP: piece_type_string = "Bishop"
		PieceSprite.PieceType.QUEEN: piece_type_string = "Queen"
		PieceSprite.PieceType.KING: piece_type_string = "King"
	return "%s %s" % [piece_color_string, piece_type_string]
	
func is_white() -> bool:
	return self.pieceColor == PieceSprite.PieceColor.WHITE

func is_black() -> bool:
	return self.pieceColor == PieceSprite.PieceColor.BLACK
	
func is_opponent_of(other_piece: Piece) -> bool:
	return self.pieceColor != other_piece.pieceColor

static func from_fen_string(fenChar: String) -> Piece:
	var color = PieceSprite.PieceColor.WHITE if fenChar == fenChar.to_upper() else PieceSprite.PieceColor.BLACK
	var type
	match fenChar.to_upper():
		"P": type = PieceSprite.PieceType.PAWN
		"N": type = PieceSprite.PieceType.KNIGHT
		"B": type = PieceSprite.PieceType.BISHOP
		"R": type = PieceSprite.PieceType.ROOK
		"Q": type = PieceSprite.PieceType.QUEEN
		"K": type = PieceSprite.PieceType.KING
		
	return Piece.new(color, type)

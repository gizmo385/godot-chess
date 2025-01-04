class_name PieceSprite extends Sprite2D

# Defining the types of pieces
enum PieceColor {WHITE, BLACK}
enum PieceType {PAWN, BISHOP, KNIGHT, ROOK, QUEEN, KING}

# Black pieces
const BlackBishop = preload("res://art/BBishop.svg")
const BlackPawn = preload("res://art/BPawn.svg")
const BlackKnight = preload("res://art/BKnight.svg")
const BlackRook = preload("res://art/BRook.svg")
const BlackQueen = preload("res://art/BQueen.svg")
const BlackKing = preload("res://art/BKing.svg")

# White pieces
const WhiteBishop = preload("res://art/WBishop.svg")
const WhitePawn = preload("res://art/WPawn.svg")
const WhiteKnight = preload("res://art/WKnight.svg")
const WhiteRook = preload("res://art/WRook.svg")
const WhiteQueen = preload("res://art/WQueen.svg")
const WhiteKing = preload("res://art/WKing.svg")


@export var pieceColor: PieceColor
@export var pieceType: PieceType

func _init(
	newPieceColor: PieceColor = PieceColor.WHITE, 
	newPieceType: PieceType = PieceType.PAWN,
) -> void:
	self.pieceColor = newPieceColor
	self.pieceType = newPieceType
	

func _ready() -> void:
	scale = Vector2(0.5, 0.5)
	match [pieceColor, pieceType]:
		# White Pieces
		[PieceColor.WHITE, PieceType.BISHOP]:
			self.set_texture(WhiteBishop)
		[PieceColor.WHITE, PieceType.ROOK]:
			self.set_texture(WhiteRook)
		[PieceColor.WHITE, PieceType.KNIGHT]:
			self.set_texture(WhiteKnight)
		[PieceColor.WHITE, PieceType.QUEEN]:
			self.set_texture(WhiteQueen)
		[PieceColor.WHITE, PieceType.KING]:
			self.set_texture(WhiteKing)
		[PieceColor.WHITE, PieceType.PAWN]:
			self.set_texture(WhitePawn)
			
		# Black Pieces
		[PieceColor.BLACK, PieceType.BISHOP]:
			self.set_texture(BlackBishop)
		[PieceColor.BLACK, PieceType.ROOK]:
			self.set_texture(BlackRook)
		[PieceColor.BLACK, PieceType.KNIGHT]:
			self.set_texture(BlackKnight)
		[PieceColor.BLACK, PieceType.QUEEN]:
			self.set_texture(BlackQueen)
		[PieceColor.BLACK, PieceType.KING]:
			self.set_texture(BlackKing)
		[PieceColor.BLACK, PieceType.PAWN]:
			self.set_texture(BlackPawn)

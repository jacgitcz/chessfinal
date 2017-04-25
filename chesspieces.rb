
# chess pieces
class Piece
	# holds common functions
	OK = ""
	UNREACHABLE = "Unreachable destination"
	FRIENDLYDEST = "Destination is friendly"
	BLOCKEDPATH = "Path to destination is blocked"

	def reachable?(move)
		# checks if the move is at all possible for the piece
		move_delta = delta_move(move)
		# the test for what is possible is defined separately for each piece
		move_test(move_delta)
	end

	def delta_move(move)
		# returns the difference between locations ithe move as [column difference, row difference]
		fromrel, torel = move.player_relative(@player)
		move_diff = [(torel[0] - fromrel[0]),(torel[1] - fromrel[1])]
		move_diff
	end

end

# player is chosen rather than colour, because the key property
# of a piece is that it belongs to a player.
# The colour of a piece is secondary to that.
# all pieces need to have access to the board, for calling methods in the board
# type id is a single letter identifying the type of the piece.
# it is the same as the first letter of the piece class name, except for
# Knights, which use 'N'
# certain pieces (Pawns, Rooks and Kings) must keep track of whether they have been moved

class Pawn < Piece

	attr_accessor :player, :type_id, :moved

	DELTAS = [[0,1],[-1,1],[1,1],[0,2]]

	def initialize(player, board)
	  @player = player
	  @board = board
	  @type_id = 'P'
	  # keep track of whether piece has been moved before
	  @moved = false
	end

	def check_move(move)
		# checks if destination is reachable at all

		if !reachable?(move)
			return false, UNREACHABLE
		end

		# if it was a 2-step move, check if first move
		move_delta = delta_move(move)
		if (move_delta == [0,2]) and @moved
			reason = "Not first move for this pawn"
			return false, reason
		end

		# ask the board if there is a friendly piece at the destination - if so can't move
		dest_state = @board.check_destination(move.tosq)
		if dest_state == @player
			# friendly piece on destination square
			return false, FRIENDLYDEST
		end

		# for a directly forward move, can't capture, so any piece will block
		move_delta = delta_move(move)
		if move_delta == [0,1] or (!@moved and move_delta == [0,2])
			if dest_state != 0
				# forward move blocked
				reason = "Forward move blocked"
				return false, reason
			else
				# forward move clear
				return true, OK
			end
		end

		# if move is diagonal forward, check for capture or en passant
		if (move_delta == [-1,1]) or (move_delta == [1,1])
			if dest_state > 0 and dest_state != @player
				# enemy piece, can capture
				return true, ""
			elsif dest_state == 0
				# ask the board if en passant would be allowed
				ep_result = @board.en_passant_allowed?(move)
				reason = ""
				if !ep_result
					reason = "En passant not allowed"
				end
				return ep_result, reason
			else
				# should never reach here
				return false, "Unknown error"
			end
		end 
	end

	def move_test(delta)
		# check list of allowble pawn moves
		DELTAS.include?(delta)
	end
end

class Rook < Piece

	attr_accessor :player, :type_id, :moved

	def initialize(player, board)
	  @player = player
	  @board = board
	  @type_id = 'R'
	  # whether piece has been moved (affects castling)
	  @moved = false
	end

	def check_move(move)
		# returns true if move is valid
		#
		# check if dest is reachable
		#
		if !reachable?(move)
			return false, UNREACHABLE
		end

		# ask the board if there is a clear path between the from and destination locations
		clearpath = @board.path_clear?(move.fromsq, move.tosq)[0]
		if !clearpath
			# path blocked
			return false, BLOCKEDPATH
		end

		# ask the board if the destination contains a friendly piece
		dest_state = @board.check_destination(move.tosq)
		if dest_state == @player
			# destination is friendly, can't move
			return false, FRIENDLYDEST
		else
			return true, OK
		end
	end

	def move_test(delta)
		# only vertical or horizontal moves allowed
		delta[0] == 0 or delta[1] == 0
	end
end

class Knight < Piece

	DELTAS = [[2,1],[2,-1],[-2,1],[-2,-1],[1,2],[-1,2],[1,-2],[-1,-2]]

	attr_accessor :player, :type_id

	def initialize(player, board)
	  @player = player
	  @board = board
	  @type_id = 'N'
	end

	def check_move(move)
		# returns true if move is valid
		#
		# check if to square is reachable - if not move invalid

		move_valid = reachable?(move)

		if !move_valid
			return false, UNREACHABLE
		end

		# ask board if destination is occupied by a friendly piece
		dest_state = @board.check_destination(move.tosq)
		if dest_state == @player
			# destination friendly, can't move
			return false, FRIENDLYDEST
		end
		return true, OK
	end

	def move_test(delta)
		# check list of allowble knight moves
		DELTAS.include?(delta)
	end
end

class Bishop < Piece

	attr_accessor :player, :type_id

	def initialize(player, board)
	  @player = player
	  @board = board
	  @type_id = 'B'
	end

	def check_move(move)
		# returns true if move is valid

		# check if destination is reachable at all
		move_valid = reachable?(move)
		# check if to square is reachable at all - if not move invalid
		if !move_valid
			return false, UNREACHABLE
		end

		# ask the board if the path to the destination is clear
		clearpath = @board.path_clear?(move.fromsq, move.tosq)[0]
		if !clearpath
			# path blocked
			return false, BLOCKEDPATH
		end

		# ask the board if the destination square is occupied by a friendly piece
		dest_state = @board.check_destination(move.tosq)
		if dest_state == @player
			# destination is friendly, can't move
			return false, FRIENDLYDEST
		else
			return true, OK
		end
	end

	def move_test(delta)
		# only diagonal moves allowed
		delta[0].abs == delta[1].abs
	end
end

class Queen < Piece

	attr_accessor :player, :type_id

	def initialize(player, board)
	  @player = player
	  @board = board
	  @type_id = 'Q'
	end

	def check_move(move)
		# returns true if move is valid

		# check if the destination is reachable at all
		move_valid = reachable?(move)

		if !move_valid
			return false, UNREACHABLE
		end

		# ask the board if there is a clear path to the destination
		clearpath = @board.path_clear?(move.fromsq, move.tosq)[0]
		if !clearpath
			# path blocked
			return false, BLOCKEDPATH
		end

		# ask the board if the destination contains a friendly piece
		dest_state = @board.check_destination(move.tosq)
		if dest_state == @player
			# destination is friendly, can't move
			return false, FRIENDLYDEST
		else
			return true, OK
		end
	end

	def move_test(delta)
		# diagonal, vertical or horizontal moves allowed
		(delta[0].abs == delta[1].abs) or delta[0] == 0 or delta[1] == 0
	end
end

class King < Piece

	attr_accessor :player, :type_id, :moved

	def initialize(player, board)
	  @player = player
	  @board = board
	  @type_id = 'K'
	  # needed for castling
	  @moved = false
	end

	def check_move(move)
		# returns true if move is valid NB castling will be handled at board level

		# check if square is reachable at all
		move_valid = reachable?(move)
		if !move_valid
			return false, UNREACHABLE
		end

		# ask board if destination is occupied by a friendly piece
		dest_state = @board.check_destination(move.tosq)
		if dest_state == @player
			return false, FRIENDLYDEST
		end
		# ask board if destination is threatened by enemy - King musn't move into check.
		threatened, threat_locs = @board.square_threatened?(@player, move.tosq)
		if threatened
			reason = "King can't move into check"
			return false, reason
		else
			return true, OK
		end
	end

	def move_test(delta)
		# move of single square in any direction is allowed
		delta[0].abs <= 1 and delta[1].abs <= 1
	end
end

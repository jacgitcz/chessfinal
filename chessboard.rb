require "./chesspieces.rb"

class Square
# a square of a chessboard
  attr_accessor :bgcolour
  attr_reader :piece_present, :piece
  BLACKSQUARECOLOUR = 40
  def initialize
    @bgcolour = BLACKSQUARECOLOUR
    @piece_present = false
    @piece = nil
  end

  def add_piece(piece)
  	# replace the existing piece, if any, with piece
  	@piece = piece
  	@piece_present = true
  end

  def remove_piece
  	# remove the piece on this square, if any, return the removed piece
  	piece = @piece
  	@piece = nil
  	@piece_present = false
  	piece
  end

  def show
  	# display the square status
  	print "Piece present: #{@piece_present}\n"
  	if @piece_present
  		print "Piece: #{@piece.type_id} Player: #{@piece.player}\n"
  	end
  end
end

class Board
# A chessboard
  attr_accessor :board
  MAXRANK = 8
  MAXFILE = 8
  PADDING = "   "
  LONGCASTLE_CODE = 2
  SHORTCASTLE_CODE = 1
  # White square colour is actually cyan, to improve visibility of white pieces
  WHITESQUARECOLOUR = 46
  WHITE = 37
  # choose red for the "black" player to improve visibility
  RED = 31
  PLAYERCOLOURS = [0, WHITE, RED]
  PLAYER_SYMBOLS = {"P"=>"\u265f", "R"=>"\u265c", "N"=>"\u265e", "B"=>"\u265d", "Q"=>"\u265b", "K"=>"\u265a"}

  # *** Initialization routines ***

  def initialize
    @board = Array.new(MAXFILE){Array.new(MAXRANK){Square.new}}
    # We need to keep track of where the kings are for detecting check, checkmate stc.
    @king_location = [0, [], []]
    # this is used for en passant checks
    @two_step_pawn = [0, [], []]
    # if a king is in check, the corresponding entry will be true, and will also
    # contain a list of the enemy locations threatening the players king
    @in_check = [false, [false, []], [false, []]]
    make_chequerboard
    setup_pieces
    @en_passant_valid = false
    @castle_valid = false
  end

  def make_chequerboard
  	# make a chequerboard
  	# start with highest rank
  	# make sure that the top left square is white
  	# uses Linux colour control codes - change this if you do a true GUI
  	7.downto(0) do |j|
  		for i in 0..7 do
  			if ((i + j + 1) % 2) == 0
  				@board[i][j].bgcolour = WHITESQUARECOLOUR
  			end
  		end
  	end
  end

  def display_board
  	# display the board
  	# displays on the terminal using control codes and text strings
  	# for a true GUI this would be changed
  	7.downto(0) do |j|
  		# each square will have three rows
  		# if you want more rows, then increase k - but you will need to make
  		# other changes too
  		for k in 0..2 do
  			reset_background
  			if k == 1
  				# print a row index (8 down to 1 as standard chess notation)
  				print " #{j+1} "
  			else
  				print "   "
  			end
  			for i in 0..7 do
  				square = @board[i][j]
  				display_square(square,k)
  			end
  			print "\n"
  	    end
  	end
  	reset_background
  	print "   "
  	# print the file labels - a to h as in standard chess notation
  	for boardfile in 'a'..'h' do
  		print PADDING + "#{boardfile}" + PADDING
  	end
  	print "\n"
  end

  def display_square(square, subrow)
  	# display a single square on the board
  	# Some of this could be delegated to the squares - maybe later
  	bg_str = "\e[#{square.bgcolour}m"
  	if square.piece_present and subrow == 1
  		display_piece(square, bg_str)
  	else
  		display_background(bg_str)
  	end
  end

  def display_piece(square, bg)
  # display the piece on the square
  # defaults to using the single-letter piece label, shows up better
  # if you want chess symbols, then they are in PLAYER_SYMBOLS
  # but they are inconveniently small  
	piece_id = square.piece.type_id
  	piece_player = square.piece.player
#  	piece_symbol = PLAYER_SYMBOLS[piece_id]
    piece_symbol = piece_id
    fg_colour = PLAYERCOLOURS[piece_player]
    fg_str = "\e[1;#{fg_colour}m"
    print bg + PADDING + fg_str + piece_symbol + bg + PADDING
  end

  def display_background(bg)
  	print bg + PADDING + " " + PADDING
  end

  def reset_background
  	# resets termina to default colours
  	print "\e[37;49m"
  end

  def setup_pieces
  	# player 1 will be white, player 2 black
  	for pl in 1..2 do
  	  set_pawns(pl)
  	  set_rooks(pl)
  	  set_knights(pl)
  	  set_bishops(pl)
  	  set_queen(pl)
  	  set_king(pl)
    end
  	
  end

  # the pieces need to know about the board in order to use methods in the board
  # to support this, we pass self (i.e. the Board) to the pieces

  def set_pawns(player)
  	# assumes that player is 1 or 2
  	row = player_startrow(player, 1)
  	for i in 0..7 do
  		square = get_square(i,row)
  		square.add_piece(Pawn.new(player, self))
  	end
  end

  def set_rooks(player)
  	row = player_startrow(player,0)
  	@board[0][row].add_piece(Rook.new(player, self))
 	@board[7][row].add_piece(Rook.new(player, self))
  end

  def set_knights(player)
  	row = player_startrow(player,0)
  	@board[1][row].add_piece(Knight.new(player, self))
  	@board[6][row].add_piece(Knight.new(player, self))
  end

  def set_bishops(player)
  	row = player_startrow(player,0)
  	@board[2][row].add_piece(Bishop.new(player, self))
  	@board[5][row].add_piece(Bishop.new(player, self))
  end

  def set_queen(player)
  	row = player_startrow(player,0)
  	@board[3][row].add_piece(Queen.new(player, self))
  end

  def set_king(player)
  	row = player_startrow(player,0)
  	@board[4][row].add_piece(King.new(player, self))
  	# record the location of the king for later use
  	@king_location[player] = [4,row]
  end

  def player_startrow(player, offset)
  	# returns the initial back row or front row for the given player
  	# offset 0 : returns back row
  	# offset 1 : returns front row
  	# plyaer must be 1 or 2
  	if player == 1
  		row = offset
  	else
  		row = 7 - offset
  	end
  	row
  end

  def reset_board
  	# puts the board back to a fresshly set up state
  	remove_pieces
  	setup_pieces
  end

  def remove_pieces
  	# just clears all the pieces from the board
  	7.downto(0) do |j|
  		for i in 0..7 do
  			@board[i][j].remove_piece
  		end
  	end
  end

  # *** Utility ***
  def get_square(file, rank)
  	@board[file][rank]
  end

  # *** Game play routines

  # Used by Game

  def check_move(move)
  	# check if the move is valid
  	# castling is checked separately, when the 'castle' property of the move is non-zero
  	# for other moves it checks that there is a piece to be moved
  	# and that it belongs to the player
  	# if so it asks the piece to validate the move
  	reason = ""
  	castle = move.castle
  	if castle > 0
  		player = move.player
  		move_valid = castle_allowed?(player, castle)
  		@castle_valid = move_valid
  		if !move_valid
  			reason = "Castle not allowed"
  		end
  	else
  		square_loc = move.fromsq
  		square = get_square(square_loc[0], square_loc[1])
  		if !square.piece_present
  			reason = "No piece on starting square"
  			return false, reason
  		end

  		from_piece = square.piece

  		player = from_piece.player
  		if player != move.player
  			# can't move someone else's pieces
  			reason = "This piece does not belong to you"
  			return false, reason
  		end

  		move_valid, reason = from_piece.check_move(move)
  		
  		# check if moving the piece would expose the players king to check
  		if move_valid
  			if (from_piece.type_id != 'K')
  				# do a trial move to see if king would be put into check
  				in_check, threat_loc = trial_move(player, move.fromsq, move.tosq)

		  		move_valid = !in_check
		  		if in_check
		  			reason = "This move would expose your king"
		  		end
	  		end
  		end
  	end
  	return move_valid, reason
  end

  def trial_move(player, from, to)
  	# carries out the indicated move, determines whether the players king is
  	# threatened or not by the move.  It then restores the state of play before
  	# the trial move, and returns the threat status
  	# back up the destination square
  	tocol = to[0]
  	torow = to[1]
  	to_backup = get_square(tocol, torow)
  	to_piece_present = to_backup.piece_present
  	if to_piece_present
  		to_piece = to_backup.piece
  	end
  	# do the trial move
  	move_piece(from, to)
  	king_loc = @king_location[player]
  	# check for threat to player king
  	in_check, threat_locs = square_threatened?(player, king_loc)
  	# restore state
  	move_piece(to, from)
  	if to_piece_present
  		to_backup.add_piece(to_piece)
  	end
  	return in_check, threat_locs
  end

  def apply_move(move)
  	# applies the indicated move
  	# castling not yet supported
  	# it records 2-step pawn moves for use in en passant checks
  	promotion_required = false
  	promotion_location = []

  	if move.castle > 0
  		if @castle_valid
  			do_castle(move)
  		end
  	else
	  	from = move.fromsq
	  	dest = move.tosq
	  	piece = move_piece(from, dest)
	  	player = piece.player
  	  	@two_step_pawn[player] = []
	  	if piece.type_id == 'P'
	  		# check for a 2 -step move
	  		coldiff = dest[0] - from[0]
	  		rowdiff = dest[1] - from[1]
	  		delta = [coldiff.abs, rowdiff.abs]
	  		if delta == [0,2]
	  			@two_step_pawn[player] = dest
	  		end
	  	end
	  	# if it was an en passant move remove the relevant enemy piece
	  	# en passant valid would be set/cleared by the preceding check_move
  	  	if @en_passant_valid
  	  		# do the en passant capture
  	  		other = other_player(player)
	  		capture_loc = @two_step_pawn[other]
	  		capture_square = get_square(capture_loc[0], capture_loc[1])
	  		capture_square.remove_piece
	  		@two_step_pawn[other] = []
	  		@en_passant_valid = false
	  	end

	  	type = piece.type_id
	  	if type == 'P' or type == 'R' or type == 'K'
	  		# needed for en passant (pawns) and castling (rooks and kings)
	  		piece.moved = true
	  	end

	  	if type == 'K'
	  		# keep track of the players king location
	  		@king_location[player] = move.tosq
	  	end

	  	# check for pawn promotion
	  	if type == 'P'
	  		lastrow = 7
	  		if player == 2
	  			lastrow = 0
	  		end
	  		if move.tosq[1] == lastrow
	  			# we just moved a Pawn onto the last row
	  			promotion_required = true
	  			promotion_location = move.tosq
	  		end
	  	end
    end
    return promotion_required, promotion_location
  end

  def move_piece(from,to)
  	# moves a piece by removing it from the square it is on
  	# and placing it on the destination square.
  	from_square = @board[from[0]][from[1]]
  	to_square = @board[to[0]][to[1]]
  	piece = from_square.piece
  	from_square.remove_piece
  	to_square.add_piece(piece)
  	return piece
  end

  def do_castle(move)
  	# carry out a castle move
  	player = move.player
  	backrow = 0
  	if player == 2
  		backrow = 7
  	end

  	king_loc = @king_location[player]

  	if move.castle == LONGCASTLE_CODE
  		rook_loc = [0, backrow]
  		rook_dest = [3, backrow]
  		king_dest = [2, backrow]
  	else
  		rook_loc = [7, backrow]
  		rook_dest = [5, backrow]
  		king_dest = [6, backrow]
  	end

  	# move the rook
  	rook_piece = move_piece(rook_loc, rook_dest)
  	rook_piece.moved = true

  	# move the king
  	king_piece = move_piece(king_loc, king_dest)
  	king_piece.moved = true
  	@king_location[player] = king_dest
  end

  def in_check?(player)
  	# run a threatened check on the position of the players king
  	king_loc = @king_location[player]
  	in_check, threat_locs = square_threatened?(player, king_loc)
  	@in_check[player] = [in_check, threat_locs]
  	in_check
  end

  def checkmate?(player)
  	# do this check only if in_check was true
  	# return false if there is a way out of the check
  	# return true if there is no way out

  	# Are we in check? if not then what are we doing here?

  	in_check = in_check?(player)
  	if !in_check
  		return false
  	end
  	#
  	# can I take the threatening piece i.e. is the threat location threatened by me?
  	#
  	threat_loc = @in_check[player][1][0]
  	enemy = other_player(player)
  	can_take_threat, my_locs = square_threatened?(enemy, threat_loc)

  	# my_locs is a (possibly empty) list of friendly locations which have pieces
  	# threatening the enemy location

  	if can_take_threat
  		king_loc = @king_location[player]
  		if my_locs.include?(king_loc)
  			# king captures are dealt with separately below
  			# so exclude the king location from the list
  			my_locs.delete_at(my_locs.index(king_loc))
  		end
  		if my_locs.length > 0
  			# there is at least one non-king piece which could capture the threat
  			return false
  		end
  	end

  	# Can I make a blocking move? - this will be possible only for threatening Rooks,
  	# Bishops or Queens

  	# find out what the enemy piece is

  	enemy_square = get_square(threat_loc[0], threat_loc[1])
  	enemy_piece = enemy_square.piece
  	enemy_type = enemy_piece.type_id
  	if enemy_type == 'R' or enemy_type == 'B' or enemy_type == 'Q'

  		# find the path between my king and the enemy piece

		king_loc = @king_location[player]
	  	clear_path_to_my_king, pathlist = path_clear?(king_loc, threat_loc)

	  	# pathlist will be a list of locations all on the path between the
	  	# king and the threat

	  	if !clear_path_to_my_king
	  		# this should not happen - even with adjacent squares
	  		return false
	  	end

	  	# For each square in the path list, see if I can move one of my pieces
	  	# onto it, so blocking the threat

	  	pathlist.each do |loc|
	  		for row in 0..7 do
	  			for col in 0..7 do
	  				next if [col, row] == loc
	  				square = get_square(col, row)
	  				# skip if empty square
	  				next if !square.piece_present
	  				square_piece = square.piece
	  				square_player = square_piece.player
	  				# skip if enemy square
	  				next if square_player == enemy
	  				move = Move.new(player,0,[col,row], loc)
	  				# skip if current friendly piece can't reach the enemy
	  				next if !square_piece.reachable?(move)
	  				square_piece_type = square_piece.type_id
	  				# check if I can move the piece to loc

	  				# if I can move a friendly piece to the threat location
	  				# I can capture the enemy threat piece, so not checkmated
	  				case square_piece_type
	  				when 'P'then
	  					move_delta = square_piece.delta_move(move)
	  					if !square_piece.moved and move_delta == [0,2]
	  						return false
	  					elsif move_delta == [0, 1]
	  						return false
	  					end
	  				when 'R','B','Q' then
	  					if path_clear?([col,row], loc)[0]
	  						return false
	  					end
	  				when 'N' then
	  					return false
	  				end
	  			end
	  		end
	  	end
	  end

	# If I reach this point then I cant take the enemy piece, nor can I block it
	# See if my king can move out of check, including taking the threat

	adjacent = adjacent_locs(king_loc)
	move_valid = false
	adjacent.each do |location|
		move = Move.new( player, 0, king_loc, location)
		# if you can move to location it is not checkmate
		move_valid, reason = check_move(move)
		if move_valid
			break
		end
	end
	return !move_valid
  end

  def adjacent_locs(location)
  	# finds all the adjacent locations - allows for board edges
  	adj = [[-1,0],[-1,1],[0,1],[1,1],[1,0],[1,-1],[0,-1],[-1,-1]]
  	locs = []
  	adj.each do |adjloc|
  		newloc = [location[0] + adjloc[0], location[1] + adjloc[1]]
  		next if !newloc[0].between?(0,7)
  		next if !newloc[1].between?(0,7)
  		locs << newloc
  	end
  	locs
  end

  # Used by pieces

  def path_clear?(from,to)
  	# returns true if there is a clear path between from and to
  	# not required by Knights (which can jump) or by Pawns or Kings (max range 1 square)
  	#
  	# if there is a clear path, also returns a list of the locations on this path
  	# if not, returns false and an empty list
  	#
  	# This should never happen!
  	if from == to 
  		return false, []
  	end
  	
  	coldiff = to[0] - from[0]
  	rowdiff = to[1] - from[1]
  	#
  	# Adjecency test - might happen if you want to move Rook/Bshop/Queen 1 square
  	#
  	if (coldiff.abs <= 1) and (rowdiff.abs <= 1)
  		# to is adjacent to from, no possibility of blocking between from and to
  		return true, []
  	end
  	#
  	# Straight line test
  	#
  	path_list = []
  	if (coldiff == 0) or (rowdiff == 0) or (coldiff.abs == rowdiff.abs)
  		# straight line - look for a clear path
  		coldelta = coldiff <=> 0
  		rowdelta = rowdiff <=> 0
  		startcol = from[0] + coldelta
  		startrow = from[1] + rowdelta
  		# the until loop will stop 1 short of the destination
		lastcol = to[0]
		lastrow = to[1]
  		col = startcol
  		row = startrow
  		piece_on_path = false

  		# Note that we must test for equality only, not greater than or less than
  		# because the deltas could be positive or negative
  		# for horizontal moves row equals lastrow
  		# for vertical moves col equals last col
  		until (col == lastcol) and (row == lastrow) do
  			path_list << [col,row]
  			square = get_square(col, row)
  			if square.piece_present
  				piece_on_path = true
  				break
  			end
  			col += coldelta
  			row += rowdelta
  		end 

  		return !piece_on_path, path_list
  	else
  		# Not a straight line
  		return false, []
  	end
  end

  def check_destination(to)
  	# returns the player who owns (has a piece at) the location to
  	# or 0 if the location is empty
  	square = get_square(to[0], to[1])
  	if !square.piece_present
  		0
  	else
  		square.piece.player
  	end
  end

  def en_passant_allowed?(move)
  	# only used by pawns
  	# checks whether conditions for an en passant capture are met
  	#
  	# precondition a) from must be on (player relative) rank 4 (coord 3 counting from 0)
  	#
  	player = move.player
  	fromrel, torel = move.player_relative(player)
  	if fromrel[1] != 4
  		return false
  	end

  	# b) to must be a diagonal move
  	if !diagonal(fromrel,torel)
  		return false
  	end

  	# c) to must be empty
  	to_loc = move.tosq
  	to_square = get_square(to_loc[0], to_loc[1])
  	if to_square.piece_present
  		return false
  	end

  	from_loc = move.fromsq

  	# d) is there a piece on the same row and adjacent to the friendly pawn? iif not, false
  	capture_col = to_loc[0]
  	capture_row = from_loc[1]
  	capture_square = get_square(capture_col, capture_row)
  	if !capture_square.piece_present
  		return false
  	end
  	#
  	# e) is the piece to be captured an enemy pawn?
  	#
  	capture_piece = capture_square.piece
  	capture_player = other_player(move.player)
  	if capture_piece.type_id != 'P' or capture_piece.player != capture_player
  		return false
  	end
  	#
  	# f) is there a location in the other players firstmove list (enp list)? if not, false
  	#
  	firstmove_loc = @two_step_pawn[capture_player]
  	if firstmove_loc == [] or firstmove_loc != [capture_col, capture_row]
  		return false
  	end
  	#
  	# if conditions are met, set ep_allowd flag in board (for use by apply move) and return true
  	#
  	@en_passant_valid = true
  	true
  end

  def diagonal(from, to)
  	# returns true if the move is one square forward diagonnally
  	# only for pawn diagonal moves
  	coldiff = to[0] - from[0]
  	rowdiff = to[1] - from[1]
  	delta = [coldiff.abs, rowdiff.abs]
  	return delta == [1,1]
  end

  def other_player(player)
  	# returns the id for the other player
  	(player %2) + 1
  end

  def square_threatened?(friend, location)
  	#
  	# only used by Kings, and by Board to see if a player is in check
  	# friend is the player who might be threatened if they were at location
  	# if location threatened, returns true plus a list of the locations of the
  	# threatening pieces
  	# if no threat, returns false and an empty list
  	#
  	enemy = other_player(friend)
  	#
  	# cycle through all enemy pieces asking them if they have a move to the given square
  	#
  	threat_locs = []
  	threatened = false
  	for row in 0..7 do
  		for col in 0..7 do
  			# skip the location we were asked to check
  			next if [col, row] == location
  			square = get_square(col, row)
  			# skip empty squares
  			next if !square.piece_present
  			piece = square.piece
  			player = piece.player
  			# skip friendly squares
  			next if player != enemy
  			move = Move.new(enemy,0,[col,row],location)
  			# skip if the current piece cannot reach the target square
  			next if !piece.reachable?(move)

  			type = piece.type_id
  			#
  			# if the enemy piece could move to our location, it is a threat
  			#
  			case type
  			when 'P' then
  				move_delta = piece.delta_move(move)
  				if move_delta == [-1,1] or move_delta == [1,1]
  					threatened = true
  					threat_locs << [col,row]
  				end
  			when 'R','B','Q' then
  				if path_clear?(move.fromsq, location)[0]
 					threatened = true
  					threat_locs << [col,row]
  				end  			
	  		when 'N', 'K' then
 					threatened = true
  					threat_locs << [col,row]
	  		end
  		end
  	end
  	return threatened, threat_locs
  end

  def castle_allowed?(player, castle_dir)
  	# used only if castling requested
  	# castle_dir will be 1 for a "short" castle and 2 for a "long"
  	# work out rook and king positions
  	#
  	# get king loc, get king piece, check king.moved - return false if true
  	king_loc = @king_location[player]
  	king_square = get_square(king_loc[0], king_loc[1])

  	if !king_square.piece_present
  		# something has gone horribly wrong
  		return false
  	end

  	king_piece = king_square.piece

  	if king_piece.type_id != 'K'
  		# some problem - not a king in the king location!
  		return false
  	end

  	if king_piece.player != player
  		# The king doesn't belong to the player - also strange!
  		return false
  	end

  	if king_piece.moved
  		# castle is not allowed if the players king has been moved
  		return false
  	end

  	# The players have different back rows
  	if player == 2
  		backrow = 7
  	else
  		backrow = 0
  	end

  	# paranoid check - if the king hasn't been moved it should still be
  	# on the players back row
  	if king_loc[1] != backrow
  		return false
  	end

  	# set up the rook location and other squares to check
  	if castle_dir == LONGCASTLE_CODE
  		rook_loc = [0, backrow]
  		check_locs = [[2, backrow],[3,backrow]]
  	else
  		rook_loc = [7, backrow]
  		check_locs =[[5, backrow],[6, backrow]]
  	end

  	rook_square = get_square(rook_loc[0], rook_loc[1])

  	# is the rook square empty? - there should be a rook ther
  	if !rook_square.piece_present
  		# rook square empty, can't castle
  		return false
  	end

  	# is the piece on the rook square a rook?
  	rook_piece = rook_square.piece
  	if rook_piece.type_id != 'R'
  		# if it isn't a rook we can't castle
  		return false
  	end

  	# does the rook belong to the player?
  	if rook_piece.player != player
  		return false
  	end

  	# has the rook been moved at all?
  	if rook_piece.moved
  		return false
  	end

  	# Is the player's king in check? - if so we can't castle
  	if in_check?(player)
  		return false
  	end

  	# Is the path between rook and king clear?
  	if !path_clear?(rook_loc, king_loc)[0]
  		return false
  	end

  	# Are the destination or intemediate location for the king threatened by the enemy?
  	check_locs.each do |loc|
  		threatened, threat_locs = square_threatened?(player, loc)
  		if threatened
  			return false
  		end
  	end

  	# Ok, we can castle
  	return true
  end

  def promote_piece(player, loc, choice)
  	square = get_square(loc[0], loc[1])
  	if !square.piece_present
  		return false
  	end
  	current_piece = square.piece
  	if current_piece.type_id != 'P'
  		return false
  	end

  	piece_player = current_piece.player
  	if piece_player != player
  		return false
  	end

  	case choice
  	when 'r' then
  		new_piece = Rook.new(player, self)
  	when 'k' then
  		new_piece = Knight.new(player, self)
  	when 'b' then
  		new_piece = Bishop.new(player, self)
  	when 'q' then
  		new_piece = Queen.new(player, self)
  	else
  		return false
  	end

  	square.add_piece(new_piece)
  	return true
  end
end
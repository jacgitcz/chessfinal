require_relative "../chessboard"
describe Board do
	before(:all) do
		@board = Board.new
	end
	before(:each) do
		@board.remove_pieces
	end

	describe '#move_piece' do
		it 'moves a piece from one place to another' do
			from = @board.get_square(2,2)
			from.add_piece(Queen.new(1, @board))
			expect(from.piece_present).to eq true
			expect(from.piece.type_id).to eq 'Q'
			to = @board.get_square(5,5)
			expect(to.piece_present).to eq false
			@board.move_piece([2,2],[5,5])
			expect(from.piece_present).to eq false
			expect(to.piece_present).to eq true
			expect(to.piece.type_id).to eq 'Q'
		end
		it 'replaces a piece at the destination' do
			from = @board.get_square(3,3)
			from.add_piece(Queen.new(2, @board))
			to = @board.get_square(6,7)
			to.add_piece(Rook.new(1, @board))
			expect(from.piece_present).to eq true
			expect(from.piece.type_id).to eq 'Q'
			expect(from.piece.player).to eq 2
			expect(to.piece_present).to eq true
			expect(to.piece.type_id).to eq 'R'
			expect(to.piece.player).to eq 1
			@board.move_piece([3,3], [6,7])
			expect(from.piece_present).to eq false
			expect(to.piece_present).to eq true
			expect(to.piece.type_id).to eq 'Q'
			expect(to.piece.player).to eq 2
		end
	end

	describe '#check_destination' do
		it 'returns 0 for an empty square' do
			square = @board.get_square(2,5)
			expect(square.piece_present).to eq false
			expect(@board.check_destination([2,5])).to eq 0
		end
		it 'returns 1 for a square with a white piece (player 1)' do
			square = @board.get_square(1,6)
			square.add_piece(Pawn.new(1, @board))
			expect(square.piece_present).to eq true
			expect(square.piece.type_id).to eq 'P'
			expect(square.piece.player).to eq 1
			expect(@board.check_destination([1,6])).to eq 1
		end
		it 'returns 2 for a square with a black piece (player 2)' do
			square = @board.get_square(0,4)
			square.add_piece(Knight.new(2, @board))
			expect(square.piece_present).to eq true
			expect(square.piece.type_id).to eq 'N'
			expect(square.piece.player).to eq 2
			expect(@board.check_destination([0,4])).to eq 2
		end
	end

	describe '#path_clear?' do
		it 'returns true (path clear) for a piece on an empty board' do
			square1 = @board.get_square(0,0)
			square1.add_piece(Rook.new(1, @board))
			expect(@board.path_clear?([0,0],[0,7])).to eq [true, [[0,1],[0,2],[0,3],[0,4],[0,5],[0,6]]]
			expect(@board.path_clear?([0,0],[7,0])[0]).to eq true
			@board.move_piece([0,0],[3,3])
			expect(@board.path_clear?([3,3],[3,5])[0]).to eq true
			@board.move_piece([3,3],[4,3])
			expect(@board.path_clear?([4,3],[1,3])[0]).to eq true
		end
		it 'returns true (path clear) when a piece is on the destination square' do
			square2 = @board.get_square(1,4)
			square2.add_piece(Queen.new(1, @board))
			square3 = @board.get_square(6,4)
			square3.add_piece(Bishop.new(2, @board))
			expect(@board.path_clear?([1,4],[6,4])[0]).to eq true
		end
		it 'returns false (path not clear) when there is a piece between the from and to squares' do
			square4 = @board.get_square(0,7)
			square5 = @board.get_square(7,0)
			square6 = @board.get_square(4,3)
			square4.add_piece(Bishop.new(1, @board))
			square5.add_piece(King.new(2, @board))
			square6.add_piece(Knight.new(1, @board))
			expect(@board.path_clear?([0,7],[7,0])[0]).to eq false
		end
		it 'returns true if destination is an adjacent square' do
			square7 = @board.get_square(5,5)
			square7.add_piece(Queen.new(1, @board))
			expect(@board.path_clear?([5,5],[6,5])[0]).to eq true
			expect(@board.path_clear?([5,5],[5,6])[0]).to eq true
			expect(@board.path_clear?([5,5],[4,4])[0]).to eq true
		end
		it 'returns false if the path is not a straight line' do
			square7 = @board.get_square(5,5)
			square7.add_piece(Queen.new(1, @board))
			expect(@board.path_clear?([5,5],[2,6])).to eq [false, []]			
			expect(@board.path_clear?([5,5],[3,2])[0]).to eq false			
			expect(@board.path_clear?([5,5],[6,7])[0]).to eq false			
		end
	end

	describe '#check_move' do
		it 'returns true for a legal move' do
			square = @board.get_square(4,2)
			square.add_piece(Bishop.new(1, @board))
			move1 = Move.new(1,0,[4,2],[2,0])
			move2 = Move.new(1,0,[4,2],[3,2])
			expect(@board.check_move(move1)[0]).to eq true
			expect(@board.check_move(move2)[0]).to eq false
		end
		it 'returns false if move from empty square is attempted' do 
			square = @board.get_square(0,0)
			move = Move.new(2,0,[0,0],[0,1])
			expect(@board.check_move(move)[0]).to eq false
		end
		it 'returns false if there is an attempt to move a piece belonging to the other player' do
			square = @board.get_square(4,4)
			square.add_piece(Queen.new(2, @board))
			move = Move.new(1,0,[4,4],[4,7])
			expect(@board.check_move(move)[0]).to eq false
		end
		it 'returns false if the move would uncover the players king' do
			@board.set_king(1)
			square1 = @board.get_square(4,3)
			square1.add_piece(Bishop.new(1, @board))
			square1 = @board.get_square(4,6)
			square1.add_piece(Rook.new(2, @board))
			expect(@board.square_threatened?(1,[4,0])).to eq [false, []]
			move1 = Move.new(1,0,[4,3],[5,4])
			expect(@board.check_move(move1)[0]).to eq false
			move2 = Move.new(1,0,[4,0],[3,1])
			@board.check_move(move2)
			expect(@board.check_move(move2)[0]).to eq true
			@board.apply_move(move2)
			expect(@board.check_move(move1)[0]).to eq true
		end
	end

	describe '#en_passant_allowed?' do
		it 'allows en passant in when the en passant conditions are met' do 
			# place black pawn on absolute row 3
			square1 = @board.get_square(4,3)
			square1.add_piece(Pawn.new(2, @board))
			square2 = @board.get_square(5,1)
			square2.add_piece(Pawn.new(1, @board))
			move1 = Move.new(1,0,[5,1],[5,3])
			@board.apply_move(move1)
			move2 = Move.new(2,0,[4,3],[5,2])
			expect(@board.en_passant_allowed?(move2)).to eq true
		end
		it 'rejects en passant when the conditions are not met' do
			square1 = @board.get_square(2,4)
			square1.add_piece(Pawn.new(1, @board))
			square2 = @board.get_square(1,6)
			square2.add_piece(Pawn.new(2, @board))
			move1 = Move.new(2,0,[1,6],[1,5])
			move2 = Move.new(2,0,[1,5],[1,4])
			@board.apply_move(move1)
			@board.apply_move(move2)
			move3 = Move.new(1,0,[2,4],[1,5])
			expect(@board.en_passant_allowed?(move3)).to eq false
		end
	end

	describe '#square_threatened?' do
		it 'returns true for threatened squares and false for unthreatened' do 
			square1 = @board.get_square(1,6)
			square1.add_piece(Pawn.new(2, @board))
			square2 = @board.get_square(2,7)
			square2.add_piece(Knight.new(2, @board))
			square3 = @board.get_square(3,7)
			square3.add_piece(Bishop.new(2, @board))
			square4 = @board.get_square(4,7)
			square4.add_piece(Queen.new(2, @board))
			square5 = @board.get_square(5,7)
			square5.add_piece(King.new(2, @board))
			square6 = @board.get_square(6,7)
			square6.add_piece(Rook.new(2, @board))
			square7 = @board.get_square(1,3)
			square7.add_piece(Pawn.new(2, @board))
			square10 = @board.get_square(4,2)
			square10.add_piece(Pawn.new(1, @board))
			square11 = @board.get_square(6,3)
			square11.add_piece(Knight.new(1, @board))
			expect(@board.square_threatened?(1,[0,5])).to eq [true, [[1,6]]]
			expect(@board.square_threatened?(1,[1,4])).to eq [true, [[4,7]]]
			expect(@board.square_threatened?(1,[3,5])).to eq [true, [[2,7]]]
			expect(@board.square_threatened?(1,[4,3])).to eq [true, [[4,7]]]
			threatened, threatlocs = @board.square_threatened?(1,[6,4])
			expect(threatened).to eq true
			expect(threatlocs).to include([3,7])
			expect(threatlocs).to include([6,7])
			expect(@board.square_threatened?(1,[7,7])).to eq [true, [[6,7]]]
			expect(@board.square_threatened?(1,[7,3])).to eq [true, [[3,7]]]
			expect(@board.square_threatened?(1,[1,2])).to eq [false, []]
			expect(@board.square_threatened?(1,[4,1])).to eq [false, []]
			expect(@board.square_threatened?(1,[7,2])).to eq [false, []]
			move1 = Move.new(1,0,[6,3],[5,5])
			@board.apply_move(move1)
			expect(@board.square_threatened?(1,[7,3])).to eq [false, []]
		end
	end

	describe '#castle_allowed?' do
		it 'allows a long castle when conditions are met' do
			@board.set_king(2)
			rooksq = @board.get_square(0,7)
			rooksq.add_piece(Rook.new(2, @board))
			expect(@board.castle_allowed?(2, Board::LONGCASTLE_CODE)).to eq true
		end
		it 'allows a short castle when conditions are met' do
			@board.set_king(1)
			rooksq = @board.get_square(7,0)
			rooksq.add_piece(Rook.new(1, @board))
			expect(@board.castle_allowed?(1, Board::SHORTCASTLE_CODE)).to eq true
		end
		it 'returns false if the king has been moved' do
			@board.set_king(2)
			rooksq = @board.get_square(0,7)
			rooksq.add_piece(Rook.new(2, @board))
			move1 = Move.new(2,0,[4,7],[3,7])
			@board.apply_move(move1)
			move2 = Move.new(2,0,[3,7],[4,7])
			@board.apply_move(move2)
			expect(@board.castle_allowed?(2, Board::LONGCASTLE_CODE)).to eq false
		end
		it 'returns false if there is no rook in the relevant corner' do
			@board.set_king(1)
			expect(@board.castle_allowed?(1, Board::SHORTCASTLE_CODE)).to eq false
		end
		it 'returns false if the piece in the relevant corner is not a rook' do
			@board.set_king(2)
			square = @board.get_square(7,7)
			square.add_piece(Queen.new(2, @board))
			expect(@board.castle_allowed?(2, Board::SHORTCASTLE_CODE)).to eq false
		end
		it 'returns false if the rook in the relevant square belongs to the enemy' do
			@board.set_king(1)
			rooksq = @board.get_square(0,0)
			rooksq.add_piece(Rook.new(2, @board))
			expect(@board.castle_allowed?(1, Board::LONGCASTLE_CODE)).to eq false
		end
		it 'returns false if the rook in the relevant corner has been moved' do
			@board.set_king(2)
			rooksq = @board.get_square(0,7)
			rooksq.add_piece(Rook.new(2, @board))
			move1 = Move.new(2,0,[0,7],[1,7])
			@board.apply_move(move1)
			move2 = Move.new(2,0,[1,7],[0,7])
			@board.apply_move(move2)
			expect(@board.castle_allowed?(2, Board::LONGCASTLE_CODE)).to eq false
		end
		it 'returns false if the path between the rook and king is blocked' do
			@board.set_king(1)
			rooksq = @board.get_square(0,0)
			rooksq.add_piece(Rook.new(1, @board))
			blocksq = @board.get_square(2,0)
			blocksq.add_piece(Knight.new(1, @board))
			expect(@board.castle_allowed?(1, Board::LONGCASTLE_CODE)).to eq false
		end
		it 'returns false if the king is in check' do
			@board.set_king(2)
			rooksq = @board.get_square(7,7)
			rooksq.add_piece(Rook.new(2, @board))
			expect(@board.castle_allowed?(2, Board::SHORTCASTLE_CODE)).to eq true
			enemysq = @board.get_square(6,2)
			enemysq.add_piece(Queen.new(1, @board))
			move = Move.new(1,0,[6,2],[4,2])
			@board.apply_move(move)
			expect(@board.castle_allowed?(2, Board::SHORTCASTLE_CODE)).to eq false
		end
		it 'returns false if the destination and/or intermediate squares for the king are threatened' do
			@board.set_king(1)
			rooksq = @board.get_square(0,0)
			rooksq.add_piece(Rook.new(1, @board))
			enemysq = @board.get_square(1,4)
			enemysq.add_piece(Queen.new(2, @board))
			expect(@board.castle_allowed?(1, Board::LONGCASTLE_CODE)).to eq true
			move1 = Move.new(2,0,[1,4],[2,4])
			@board.apply_move(move1)
			expect(@board.castle_allowed?(1, Board::LONGCASTLE_CODE)).to eq false
			move2 = Move.new(2,0,[2,4],[3,4])
			@board.apply_move(move2)
			expect(@board.castle_allowed?(1, Board::LONGCASTLE_CODE)).to eq false
			move3 = Move.new(2,0,[3,4],[5,4])
			@board.apply_move(move3)
			expect(@board.castle_allowed?(1, Board::LONGCASTLE_CODE)).to eq true
		end

		# set up a rook and a king, no enemy pieces
		# check that castle allowed is true
		# move the rook 1 space, check that castle not allowed
		# clear, put new pieces, this time move king 1 space, check that castle not allowed
		# clear, put rook and king, add enemy piece threatening final square
		# check that castle not allowed
		# clear, put rook and king, add enemy piece threatening intemediate square
		# check that castle not allowed
		# c;ear. put rook and king, add enemy piece threatening king
		# check that castle not allowed
		# move enemy piece so none of the three critical squares are threatened
		# check that castle is allowed
	end

	describe '#in_check?' do
		it 'returns true if a king is in check from the other player and false otherwise' do
			@board.set_king(1)
			move1 = Move.new(1,0,[4,0],[3,0])
			@board.check_move(move1)
			@board.apply_move(move1)
			move2 = Move.new(1,0,[3,0],[2,0])
			@board.check_move(move2)
			@board.apply_move(move2)
			square2 = @board.get_square(5,3)
			square2.add_piece(Bishop.new(2, @board))
			expect(@board.in_check?(1)).to eq true
			move3 = Move.new(2,0,[5,3],[6,3])
			@board.check_move(move3)
			@board.apply_move(move3)
			expect(@board.in_check?(1)).to eq false
			square3 = @board.get_square(2,7)
			square3.add_piece(Rook.new(2, @board))
			expect(@board.in_check?(1)).to eq true
			square4 = @board.get_square(2,4)
			square4.add_piece(Knight.new(2, @board))
			expect(@board.in_check?(1)).to eq false
		end
	end

	describe '#checkmate?' do
		it 'returns true when king is in check and all possible destination squares are threatened' do
			@board.set_king(2)
			square1 = @board.get_square(4,6)
			square1.add_piece(Queen.new(1, @board))
			square2 = @board.get_square(4,3)
			square2.add_piece(Rook.new(1, @board))
			expect(@board.in_check?(2)).to eq true
			expect(@board.checkmate?(2)).to eq true
		end
		it 'returns false if the threat can be taken by a friendly piece' do
			@board.set_king(2)
			square1 = @board.get_square(4,6)
			square1.add_piece(Queen.new(1, @board))
			square2 = @board.get_square(4,3)
			square2.add_piece(Rook.new(1, @board))
			square3 = @board.get_square(1,6)
			square3.add_piece(Rook.new(2, @board))
			expect(@board.in_check?(2)).to eq true
			expect(@board.checkmate?(2)).to eq false
			square2.remove_piece
			move1 = Move.new(2,0,[4,7],[4,6])
			@board.check_move(move1)
			@board.apply_move(move1)
			expect(@board.in_check?(2)).to eq false
			expect(@board.checkmate?(2)).to eq false
		end
		it 'returns false if the threat can be blocked by another friendly piece' do
			@board.set_king(1)
			square4 = @board.get_square(1,5)
			square4.add_piece(Bishop.new(1, @board))
			square5 = @board.get_square(1,4)
			square5.add_piece(Bishop.new(2, @board))
			square6 = @board.get_square(4,4)
			square6.add_piece(Rook.new(2, @board))
			square7 = @board.get_square(7,4)
			square7.add_piece(Bishop.new(2, @board))
			expect(@board.in_check?(1)).to eq true
			expect(@board.checkmate?(1)).to eq false
		end
	end
end
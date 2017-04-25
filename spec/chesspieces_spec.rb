require_relative "../chessboard"
require_relative "../chessplayer"
describe Pawn do
	before(:all) do
		@board = Board.new
	end
	before(:each) do
		@board.remove_pieces
	end
	describe '#reachable?' do
		it 'returns true for 1 square forward on an empty board for both players' do
			square1 = @board.get_square(3,1)
			square2 = @board.get_square(5,6)
			square1.add_piece(Pawn.new(1, @board))
			square2.add_piece(Pawn.new(2, @board))
			move1 = Move.new(1,0,[3,1],[3,2])
			expect(square1.piece.reachable?(move1)).to eq true
			move2 = Move.new(2,0,[5,6],[5,5])
			expect(square2.piece.reachable?(move2)).to eq true
		end
		it 'returns true for 2 squares forward for both players' do
			square1 = @board.get_square(2,1)
			square2 = @board.get_square(4,6)
			square1.add_piece(Pawn.new(1, @board))
			square2.add_piece(Pawn.new(2, @board))
			move1 = Move.new(1,0,[2,1],[2,3])
			expect(square1.piece.reachable?(move1)).to eq true
			move2 = Move.new(2,0,[4,6],[4,4])
			expect(square2.piece.reachable?(move2)).to eq true
		end
		it 'returns true for 1 square diagonal forward for both directions and both players' do
			square1 = @board.get_square(5,1)
			square2 = @board.get_square(2,6)
			square1.add_piece(Pawn.new(1, @board))
			square2.add_piece(Pawn.new(2, @board))
			move1 = Move.new(1,0,[5,1],[4,2])
			move2 = Move.new(1,0,[5,1],[6,2])
			move3 = Move.new(2,0,[2,6],[1,5])
			move4 = Move.new(2,0,[2,6],[3,5])
			expect(square1.piece.reachable?(move1)).to eq true
			expect(square1.piece.reachable?(move2)).to eq true
			expect(square2.piece.reachable?(move3)).to eq true
			expect(square2.piece.reachable?(move4)).to eq true
		end
		it "returns false for more than 1 square diagonally or forward" do
			square1 = @board.get_square(4,1)
			square2 = @board.get_square(3,6)
			square1.add_piece(Pawn.new(1, @board))
			square2.add_piece(Pawn.new(2, @board))
			square1.piece.moved = true
			square2.piece.moved = true
			move1 = Move.new(1,0,[4,1],[4,4])
			move2 = Move.new(2,0,[3,6],[3,3])
			move3 = Move.new(1,0,[4,1],[6,3])
			move4 = Move.new(2,0,[3,6],[1,4])
			move5 = Move.new(2,0,[3,6],[3,3])
			expect(square1.piece.reachable?(move1)).to eq false
			expect(square2.piece.reachable?(move2)).to eq false
			expect(square1.piece.reachable?(move3)).to eq false
			expect(square2.piece.reachable?(move4)).to eq false
			expect(square2.piece.reachable?(move5)).to eq false
		end
		it 'returns false for a move sideways or backward' do 
			square1 = @board.get_square(2,2)
			square2 = @board.get_square(4,4)
			square1.add_piece(Pawn.new(1, @board))
			square2.add_piece(Pawn.new(2, @board))
			move1 = Move.new(1,0,[2,2],[1,2])
			move2 = Move.new(1,0,[2,2],[3,1])
			move3 = Move.new(1,0,[2,2],[2,1])
			move4 = Move.new(2,0,[4,4],[3,4])
			move5 = Move.new(2,0,[4,4],[5,5])
			move6 = Move.new(2,0,[4,4],[4,5])
			expect(square1.piece.reachable?(move1)).to eq false
			expect(square1.piece.reachable?(move2)).to eq false
			expect(square1.piece.reachable?(move3)).to eq false
			expect(square2.piece.reachable?(move4)).to eq false
			expect(square2.piece.reachable?(move5)).to eq false
			expect(square2.piece.reachable?(move6)).to eq false
		end
	end

	describe '#check_move' do
		it 'returns true for 1 square forward to empty square' do
			square1 = @board.get_square(2,2)
			square1.add_piece(Pawn.new(1, @board))
			move1 = Move.new( 1, 0, [2,2], [2,3])
			expect(square1.piece.check_move(move1)[0]).to eq true
		end
		it 'returns true for 2 squares forward for both players' do
			square1 = @board.get_square(2,1)
			square2 = @board.get_square(4,6)
			square1.add_piece(Pawn.new(1, @board))
			square2.add_piece(Pawn.new(2, @board))
			move1 = Move.new(1,0,[2,1],[2,3])
			expect(square1.piece.check_move(move1)[0]).to eq true
			move2 = Move.new(2,0,[4,6],[4,4])
			expect(square2.piece.check_move(move2)[0]).to eq true
		end
		it 'returns false for 2 squares forward on a second move for both players' do
			square1 = @board.get_square(2,1)
			square2 = @board.get_square(4,6)
			square1.add_piece(Pawn.new(1, @board))
			square2.add_piece(Pawn.new(2, @board))
			square1.piece.moved = true
			square2.piece.moved = true
			move1 = Move.new(1,0,[2,1],[2,3])
			expect(square1.piece.check_move(move1)[0]).to eq false
			move2 = Move.new(2,0,[4,6],[4,4])
			expect(square2.piece.check_move(move2)[0]).to eq false
		end

		it 'returns false when move forward is blocked by friendly or enemy piece' do
			square2 = @board.get_square(6,5)
			square3 = @board.get_square(6,4)
			square2.add_piece(Pawn.new(2, @board))
			square3.add_piece(Rook.new(2, @board))
			move2 = Move.new(2,0,[6,5],[6,4])
			expect(square2.piece.check_move(move2)[0]).to eq false
			square4 = @board.get_square(1,2)
			square5 = @board.get_square(1,3)
			square4.add_piece(Pawn.new(1, @board))
			square5.add_piece(Knight.new(2, @board))
			move3 = Move.new(1,0,[1,2],[1,3])
			expect(square4.piece.check_move(move3)[0]).to eq false
		end
		it 'returns true for an enemy pawn diagonally forward' do
			square1 = @board.get_square(6,2)
			square1.add_piece(Pawn.new(1, @board))
			square2 = @board.get_square(5,3)
			square2.add_piece(Bishop.new(2, @board))
			move1 = Move.new( 1, 0, [6,2], [5,3])
			expect(square1.piece.check_move(move1)[0]).to eq true
		end
		it 'returns false for diagonal forward move to empty square, no en passant conditions' do
			square = @board.get_square(2,4)
			square.add_piece(Pawn.new(2, @board))
			move = Move.new( 2, 0, [2,4], [3,3])
			expect(square.piece.check_move(move)[0]).to eq false
		end
		it 'returns false for diagonal forward move to friendly square' do
			square1 = @board.get_square(4,2)
			square1.add_piece(Pawn.new(1, @board))
			square2 = @board.get_square(5,3)
			square2.add_piece(Queen.new(1, @board))
			move = Move.new( 1, 0, [4,2], [5,3])
			expect(square1.piece.check_move(move)[0]).to eq false
		end
		it 'allows en passant captures' do 
			square1 = @board.get_square(3,4)
			square1.add_piece(Pawn.new(1, @board))
			square2 = @board.get_square(2,6)
			square2.add_piece(Pawn.new(2, @board))
			# move the black pawn 2 squares forward
			move1 = Move.new(2,0,[2,6],[2,4])
			@board.check_move(move1)
			@board.apply_move(move1)
			# check that it really was moved
			square3 = @board.get_square(2,4)
			expect(square3.piece_present).to eq true
			expect(square3.piece.type_id).to eq 'P'
			expect(square3.piece.player).to eq 2
			expect(square2.piece_present).to eq false
			# do a white en passant move
			move2 = Move.new(1,0,[3,4],[2,5])
			expect(square1.piece.check_move(move2)[0]).to eq true
			@board.apply_move(move2)
			# check that the black piece was captured
			expect(square3.piece_present).to eq false
		end
		it 'disallows en passant if the en passant opportunity is not taken' do
			square1 = @board.get_square(5,3)
			square1.add_piece(Pawn.new(2, @board))
			square2 = @board.get_square(6,1)
			square2.add_piece(Pawn.new(1, @board))
			square3 = @board.get_square(2,5)
			square3.add_piece(Rook.new(2, @board))
			square4 = @board.get_square(7,7)
			square4.add_piece(Queen.new(1, @board))
			# move the white pawn 2 squares forward
			move1 = Move.new(1,0, [6,1],[6,3])
			@board.check_move(move1)
			@board.apply_move(move1)
			# move the black rook
			move2 = Move.new(2,0, [2,5], [2,1])
			@board.check_move(move2)
			@board.apply_move(move2)
			# move the white queen
			move3 = Move.new(1,0,[7,7],[6,6])
			@board.check_move(move3)
			@board.apply_move(move3)
			# black pawn - try en passant - verify that it is disallowed
			move4 = Move.new(2,0,[5,3],[6,2])
			expect(square1.piece.check_move(move4)[0]).to eq false
		end
	end
end

describe Rook do
	before(:all) do
		@board = Board.new
	end
	before(:each) do
		@board.remove_pieces
	end

	describe '#reachable?' do
		it 'returns true for horizontal and vertical moves' do
			square = @board.get_square(1,2)
			square.add_piece(Rook.new(1, @board))
			move1 = Move.new(1,0,[1,2],[1,7])
			expect(square.piece.reachable?(move1)).to eq true
			move2 = Move.new(1,0,[1,2],[6,2])
			expect(square.piece.reachable?(move2)).to eq true
		end
		it 'returns false for diagonal and non-straight moves' do
			# check that diagonal moves and non-straight moves are rejected
			square = @board.get_square(6,7)
			square.add_piece(Rook.new(2, @board))
			move1 = Move.new( 2, 0, [6,7], [6,5])
			expect(square.piece.reachable?(move1)).to eq true
			move2 = Move.new( 2, 0, [6,7], [1,2])
			expect(square.piece.reachable?(move2)).to eq false
			move3 = Move.new( 2, 0, [6,7], [6,0])
			expect(square.piece.reachable?(move3)).to eq true
			move4 = Move.new( 2, 0, [6,7], [5,0])
			expect(square.piece.reachable?(move4)).to eq false
		end
	end
	describe '#check_move' do
		it 'returns true for legal moves to empty squares' do 
		# check that you can move to an empty square horizontally or verticall
			square = @board.get_square(2,3)
			square.add_piece(Rook.new(1, @board))
			move1 = Move.new(1,0,[2,3],[2,7])
			expect(square.piece.check_move(move1)[0]).to eq true
			move2 = Move.new(1,0,[2,3],[6,3])
			expect(square.piece.check_move(move2)[0]).to eq true
		end
		it 'returns false on an attempted move to a friendly square' do
			# check that you can't move to a square occupied by a friendly piece
			square1 = @board.get_square(4,4)
			square1.add_piece(Rook.new(2, @board))
			square2 = @board.get_square(4,6)
			square2.add_piece(Pawn.new(2, @board))
			move1 = Move.new( 2, 0, [4,4], [4,6])
			expect(square1.piece.check_move(move1)[0]).to eq false
		end
		it 'returns false if a piece (enemy or friendly) is blocking the way' do
			# check that you can't move if a piece is in the way
			square1 = @board.get_square(4,2)
			square1.add_piece(Rook.new(1, @board))
			square2 = @board.get_square(4,6)
			square2.add_piece(Queen.new(1, @board))
			move1 = Move.new( 1, 0, [4,2], [4,7])
			expect(square1.piece.check_move(move1)[0]).to eq false
			square2.remove_piece
			square2.add_piece(Knight.new(2, @board))
			move2 = Move.new( 1, 0, [4,2], [4,7])
			expect(square1.piece.check_move(move2)[0]).to eq false
		end
		it 'returns true if the destination is occupied by an enemy piece' do
			square1 = @board.get_square(7,3)
			square1.add_piece(Rook.new(2, @board))
			square2 = @board.get_square(0,3)
			square2.add_piece(Bishop.new(1, @board))
			move1 = Move.new( 2, 0, [7,3], [0,3])
			expect(square1.piece.check_move(move1)[0]).to eq true
		end
	end
end

describe Knight do
	before(:all) do
		@board = Board.new
	end
	before(:each) do
		@board.remove_pieces
	end
	describe '#reachable' do
		it 'returns true for legal moves' do 
			# put a knight in the middle of an empty board
			square = @board.get_square(3,3)
			square.add_piece(Knight.new(1, @board))
			# check that all 8 legal positions are reachable
			move1 = Move.new(1,0,[3,3],[4,5])
			move2 = Move.new(1,0,[3,3],[5,4])
			move3 = Move.new(1,0,[3,3],[5,2])
			move4 = Move.new(1,0,[3,3],[4,1])
			move5 = Move.new(1,0,[3,3],[2,1])
			move6 = Move.new(1,0,[3,3],[1,2])
			move7 = Move.new(1,0,[3,3],[1,4])
			move8 = Move.new(1,0,[3,3],[2,5])
			expect(square.piece.reachable?(move1)).to eq true
			expect(square.piece.reachable?(move2)).to eq true
			expect(square.piece.reachable?(move3)).to eq true
			expect(square.piece.reachable?(move4)).to eq true
			expect(square.piece.reachable?(move5)).to eq true
			expect(square.piece.reachable?(move6)).to eq true
			expect(square.piece.reachable?(move7)).to eq true
			expect(square.piece.reachable?(move8)).to eq true
		end
		it 'returns false for unreachable destinations' do
			# check 4 random unreachable positions
			square = @board.get_square(3,3)
			square.add_piece(Knight.new(1, @board))
			move9 = Move.new(1,0,[3,3],[3,5])
			move10 = Move.new(1,0,[3,3],[4,3])
			move11 = Move.new(1,0,[3,3],[1,1])
			move12 = Move.new(1,0,[3,3],[2,4])
			expect(square.piece.reachable?(move9)).to eq false
			expect(square.piece.reachable?(move10)).to eq false
			expect(square.piece.reachable?(move11)).to eq false
			expect(square.piece.reachable?(move12)).to eq false
		end
	end

	describe '#check_move' do
		it 'returns false for jumps to a friendly square' do 
			# put a knight on the board
			square1 = @board.get_square(5,4)
			square1.add_piece(Knight.new(2, @board))
			square2 = @board.get_square(4,6)
			square2.add_piece(Pawn.new(2, @board))
			move1 = Move.new(2,0,[5,4],[6,6])
			move2 = Move.new(2,0,[5,4],[4,6])
			expect(square1.piece.check_move(move1)[0]).to eq true
			expect(square1.piece.check_move(move2)[0]).to eq false
		end
		it 'returns true for a jump to an enemy square' do 
			# put an enemy piece on a reachable square
			square1 = @board.get_square(1,4)
			square2 = @board.get_square(2,2)
			square3 = @board.get_square(3,5)
			square1.add_piece(Knight.new(1, @board))
			square2.add_piece(Rook.new(2, @board))
			square3.add_piece(Bishop.new(1, @board))
			move1 = Move.new(1,0,[1,4],[3,5])
			move2 = Move.new(1,0,[1,4],[2,2])
			expect(square1.piece.check_move(move1)[0]).to eq false
			expect(square1.piece.check_move(move2)[0]).to eq true
		end
		it 'allows jumps over intervening pieces' do 
			# surround knight with pieces on adjacent squares
			square1 = @board.get_square(3,4)
			square1.add_piece(Knight.new(2, @board))
			square2 = @board.get_square(2,2)
			square2.add_piece(Rook.new(1, @board))
			square3 = @board.get_square(2,6)
			square3.add_piece(Queen.new(2, @board))
			square4 = @board.get_square(2,3)
			square4.add_piece(Pawn.new(2, @board))
			square5 = @board.get_square(2,4)
			square5.add_piece(Pawn.new(2, @board))
			square6 = @board.get_square(2,5)
			square6.add_piece(Queen.new(1, @board))
			square7 = @board.get_square(3,5)
			square7.add_piece(Bishop.new(1, @board))
			square8 = @board.get_square(4,5)
			square8.add_piece(Knight.new(2, @board))
			square9 = @board.get_square(4,4)
			square9.add_piece(Knight.new(1, @board))
			square10 = @board.get_square(4,3)
			square10.add_piece(Rook.new(2, @board))
			square11 = @board.get_square(3,3)
			square11.add_piece(Pawn.new(1, @board))
			move1 = Move.new(2,0,[3,4],[2,2])
			move2 = Move.new(2,0,[3,4],[4,2])
			move3 = Move.new(2,0,[3,4],[2,6])
			expect(square1.piece.check_move(move1)[0]).to eq true
			expect(square1.piece.check_move(move2)[0]).to eq true
			expect(square1.piece.check_move(move3)[0]).to eq false
		end
	end
end

describe Bishop do
	before(:all) do
		@board = Board.new
	end
	before(:each) do
		@board.remove_pieces
	end

	describe '#reachable' do
		it 'returns true for diagonal moves' do
			square = @board.get_square(3,3)
			square.add_piece(Bishop.new(1, @board))
			move1 = Move.new(1,0,[3,3],[0,0])
			move2 = Move.new(1,0,[3,3],[7,7])
			move3 = Move.new(1,0,[3,3],[5,1])
			move4 = Move.new(1,0,[3,3],[0,6])
			expect(square.piece.reachable?(move1)).to eq true
			expect(square.piece.reachable?(move2)).to eq true
			expect(square.piece.reachable?(move3)).to eq true
			expect(square.piece.reachable?(move4)).to eq true
		end
		it 'returns false for horizontal, vertical or crooked moves' do
			square = @board.get_square(5,4)
			square.add_piece(Bishop.new(2, @board))
			move1 = Move.new(2,0,[5,4],[7,4])
			move2 = Move.new(2,0,[5,4],[5,7])
			move3 = Move.new(2,0,[5,4],[2,0])
			move4 = Move.new(2,0,[5,4],[2,7])
			expect(square.piece.reachable?(move1)).to eq false
			expect(square.piece.reachable?(move2)).to eq false
			expect(square.piece.reachable?(move3)).to eq false
			expect(square.piece.reachable?(move4)).to eq true
		end
	end

	describe '#check_move' do
		it 'returns true for legal moves to empty squares' do
			square = @board.get_square(2,4)
			square.add_piece(Bishop.new(1, @board))
			move1 = Move.new(1,0,[2,4],[4,6])
			move2 = Move.new(1,0,[2,4],[5,1])
			move3 = Move.new(1,0,[2,4],[0,2])
			move4 = Move.new(1,0,[2,4],[1,5])
			expect(square.piece.check_move(move1)[0]).to eq true
			expect(square.piece.check_move(move2)[0]).to eq true
			expect(square.piece.check_move(move3)[0]).to eq true
			expect(square.piece.check_move(move4)[0]).to eq true
		end
		it 'returns false for an attempted move to a friendly square' do
			square1 = @board.get_square(6,2)
			square1.add_piece(Bishop.new(2, @board))
			square2 = @board.get_square(3,5)
			square2.add_piece(Queen.new(2, @board))
			move1 = Move.new(2,0,[6,2],[3,5])
			expect(square1.piece.check_move(move1)[0]).to eq false
		end
		it 'returns true for a move to an enemy square' do
			square1 = @board.get_square(1,2)
			square1.add_piece(Bishop.new(1, @board))
			square2 = @board.get_square(5,6)
			square2.add_piece(Rook.new(2, @board))
			move1 = Move.new(2,0,[1,2],[5,6])
			expect(square1.piece.check_move(move1)[0]).to eq true
		end
		it 'returns false if a piece (enemy or friendly) blocks the path to the destination' do
			square1 = @board.get_square(3,1)
			square1.add_piece(Bishop.new(2, @board))
			square2 = @board.get_square(6,4)
			square2.add_piece(Knight.new(1, @board))
			square3 = @board.get_square(2,2)
			square3.add_piece(Queen.new(2, @board))
			move1 = Move.new(2,0,[3,1],[7,5])
			move2 = Move.new(2,0,[3,1],[0,4])
			move3 = Move.new(2,0,[3,1],[5,3])
			expect(square1.piece.check_move(move1)[0]).to eq false
			expect(square1.piece.check_move(move2)[0]).to eq false
			expect(square1.piece.check_move(move3)[0]).to eq true
			square3.remove_piece
			expect(square1.piece.check_move(move2)[0]).to eq true
		end
	end
end

describe Queen do
	before(:all) do
		@board = Board.new
	end
	before(:each) do
		@board.remove_pieces
	end

	describe '#reachable' do
		it 'returns true for horizontal or diagonal moves' do
			square = @board.get_square(2,3)
			square.add_piece(Queen.new(1, @board))
			move1 = Move.new(1,0,[2,3],[2,7])
			move2 = Move.new(1,0,[2,3],[4,5])
			move3 = Move.new(1,0,[2,3],[5,0])
			move4 = Move.new(1,0,[2,3],[0,1])
			move5 = Move.new(1,0,[2,3],[1,3])
			expect(square.piece.reachable?(move1)).to eq true
			expect(square.piece.reachable?(move2)).to eq true
			expect(square.piece.reachable?(move3)).to eq true
			expect(square.piece.reachable?(move4)).to eq true
			expect(square.piece.reachable?(move5)).to eq true
		end
		it 'returns false for crooked moves' do
			square = @board.get_square(4,6)
			square.add_piece(Queen.new(2, @board))
			move1 = Move.new( 2, 0, [4,6],[4,0])
			move2 = Move.new( 2, 0, [4,6],[7,7])
			move3 = Move.new( 2, 0, [4,6],[0,1])
			move4 = Move.new( 2, 0, [4,6],[0,2])
			expect(square.piece.reachable?(move1)).to eq true			
			expect(square.piece.reachable?(move2)).to eq false			
			expect(square.piece.reachable?(move3)).to eq false			
			expect(square.piece.reachable?(move4)).to eq true			
		end
	end

	describe '#check_move' do
		it 'returns true for legal moves to empty squares' do
			square = @board.get_square(5,2)
			square.add_piece(Queen.new(1, @board))
			move1 = Move.new(1,0,[5,2],[7,2])
			move2 = Move.new(1,0,[5,2],[0,7])
			expect(square.piece.check_move(move1)[0]).to eq true
			expect(square.piece.check_move(move2)[0]).to eq true
		end
		it 'returns false for an attempted move to a friendly square' do
			square1 = @board.get_square(1,5)
			square1.add_piece(Queen.new(2, @board))
			square2 = @board.get_square(6,0)
			square2.add_piece(Knight.new(2, @board))
			move1 = Move.new(2,0,[1,5],[5,1])
			move2 = Move.new(2,0,[1,5],[6,0])
			expect(square1.piece.check_move(move1)[0]).to eq true
			expect(square1.piece.check_move(move2)[0]).to eq false
		end
		it 'returns true for a move to an enemy square' do
			square1 = @board.get_square(5,2)
			square1.add_piece(Queen.new(1, @board))
			square2 = @board.get_square(5,7)
			square2.add_piece(Rook.new(2, @board))
			move1 = Move.new(1,0,[5,2],[5,7])
			expect(square1.piece.check_move(move1)[0]).to eq true
		end
		it 'returns false if a piece (enemy or friendly) blocks the path to the destination' do
			square1 = @board.get_square(4,3)
			square1.add_piece(Queen.new(2, @board))
			square2 = @board.get_square(1,6)
			square2.add_piece(Bishop.new(1, @board))
			square3 = @board.get_square(3,3)
			square3.add_piece(Pawn.new(2, @board))
			square4 = @board.get_square(4,5)
			square4.add_piece(Rook.new(1, @board))
			move1 = Move.new(2,0,[4,3],[0,7])
			move2 = Move.new(2,0,[4,3],[1,3])
			move3 = Move.new(2,0,[4,3],[4,7])
			move4 = Move.new(2,0,[4,3],[2,5])
			expect(square1.piece.check_move(move1)[0]).to eq false
			expect(square1.piece.check_move(move2)[0]).to eq false
			expect(square1.piece.check_move(move3)[0]).to eq false
			expect(square1.piece.check_move(move4)[0]).to eq true
		end
	end
end

describe King do
	before(:all) do
		@board = Board.new
	end
	before(:each) do
		@board.remove_pieces
	end

	describe '#reachable' do
		it 'returns true for moves to adjacent squares' do
			square = @board.get_square(3,1)
			square.add_piece(King.new(2, @board))
			move1 = Move.new(2,0,[3,1],[2,2])
			move2 = Move.new(2,0,[3,1],[3,2])
			move3 = Move.new(2,0,[3,1],[4,2])
			move4 = Move.new(2,0,[3,1],[4,1])
			move5 = Move.new(2,0,[3,1],[4,0])
			move6 = Move.new(2,0,[3,1],[3,0])
			move7 = Move.new(2,0,[3,1],[2,0])
			move8 = Move.new(2,0,[3,1],[2,1])
			expect(square.piece.reachable?(move1)).to eq true
			expect(square.piece.reachable?(move2)).to eq true
			expect(square.piece.reachable?(move3)).to eq true
			expect(square.piece.reachable?(move4)).to eq true
			expect(square.piece.reachable?(move5)).to eq true
			expect(square.piece.reachable?(move6)).to eq true
			expect(square.piece.reachable?(move7)).to eq true
			expect(square.piece.reachable?(move8)).to eq true
		end
		it 'returns false for moves to non adjacent squares' do
			square = @board.get_square(5,5)
			square.add_piece(King.new(1, @board))
			move1 = Move.new(1,0,[5,5],[5,3])
			move2 = Move.new(1,0,[5,5],[3,7])
			move3 = Move.new(1,0,[5,5],[0,5])
			move4 = Move.new(1,0,[5,5],[4,4])
			expect(square.piece.reachable?(move1)).to eq false
			expect(square.piece.reachable?(move2)).to eq false
			expect(square.piece.reachable?(move3)).to eq false
			expect(square.piece.reachable?(move4)).to eq true
		end
	end

	describe '#check_move' do
		it 'allows moves to an adjacent square on an empty board' do
			square = @board.get_square(0,0)
			square.add_piece(King.new(2, @board))
			move1 = Move.new(2,0,[0,0],[0,1])
			move2 = Move.new(2,0,[0,0],[1,1])
			expect(square.piece.check_move(move1)[0]).to eq true
			expect(square.piece.check_move(move2)[0]).to eq true
		end
		it 'returns false for an attempted move to a friendly square' do
			square1 = @board.get_square(2,3)
			square1.add_piece(King.new(1, @board))
			square2 = @board.get_square(2,4)
			square2.add_piece(Rook.new(1, @board))
			move1 = Move.new(1,0,[2,3],[2,4])
			expect(square1.piece.check_move(move1)[0]).to eq false
		end
		it 'returns true for a move to an enemy square' do
			square1 = @board.get_square(6,4)
			square1.add_piece(King.new(2, @board))
			square2 = @board.get_square(7,5)
			square2.add_piece(Pawn.new(1, @board))
			move1 = Move.new(1,0,[6,4],[7,5])
			expect(square1.piece.check_move(move1)[0]).to eq true
		end
		it 'returns false for an attempted move into check' do
			square1 = @board.get_square(5,0)
			square1.add_piece(King.new(1, @board))
			square2 = @board.get_square(0,4)
			square2.add_piece(Bishop.new(2, @board))
			square3 = @board.get_square(5,3)
			square3.add_piece(Knight.new(2, @board))
			square4 = @board.get_square(7,7)
			square4.add_piece(Rook.new(2, @board))
			move1 = Move.new(1,0,[5,0],[4,0])
			move2 = Move.new(1,0,[5,0],[4,1])
			move3 = Move.new(1,0,[5,0],[5,1])
			move4 = Move.new(1,0,[5,0],[6,1])
			move5 = Move.new(1,0,[5,0],[6,0])
			expect(square1.piece.check_move(move1)[0]).to eq false
			expect(square1.piece.check_move(move2)[0]).to eq false
			expect(square1.piece.check_move(move3)[0]).to eq true
			expect(square1.piece.check_move(move4)[0]).to eq false
			expect(square1.piece.check_move(move5)[0]).to eq true
		end
	end
end
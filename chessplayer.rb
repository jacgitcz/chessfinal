class Player
	# this class is for human players interacting with the game
	# it may later be extended to a simple compter player
	EXITCODE = ['x','xx','xxx','quit']
	SAVECODE = ['s','ss','sss','save']
	LOADCODE = ['l','ll','lll','load']
	HELPCODE = ['h,''hh','hhh','help','?']
	LONGCASTLE = ['OOO', 'ooo']
	SHORTCASTLE = ['OO', 'oo']
	FILES = 'abcdefgh'

	attr_reader :player_num

	def initialize(player_num)
		# player number must be 1 or 2 (1 for white)
		@player_num = player_num
	end

	def get_move
	  	castle = 0
	  	goodmove = false
	  	quit = false
	  	command = ''
	  	until goodmove or quit do 
	  		helpreq = false
	  		castle = 0
	  		# regex for decoding normal moves
	  	  	moveregex = /[PRNBQK]*(?<ffile>[a-h]{1})(?<frank>[1-8]{1}) (?<tfile>[a-h]{1})(?<trank>[1-8]{1})/	
		  	puts "Player #{@player_num} : Enter a move, h or? for help, or x or quit to quit\n"	  	
		  	instr = gets.chomp
		  	# check for exit, help, and castles before checking for normal move
		  	if SAVECODE.include?(instr)
		  		quit = true
		  		command = 's'
		  	elsif LOADCODE.include?(instr)
		  		quit = true
		  		command = 'l'
		  	elsif EXITCODE.include?(instr)
		  		quit = true
		  		command = 'q'
		  	elsif HELPCODE.include?(instr)
		  	    helpreq = true 
		  	elsif LONGCASTLE.include?(instr)
		  		castle = 2
		  		goodmove = true
		  	elsif SHORTCASTLE.include?(instr)
		  		castle = 1
		  		goodmove = true
		  	end

		  	if not quit and not helpreq and not goodmove
		  		movematch = moveregex.match(instr)
		  		if movematch.nil?
		  			goodmove = false
		  			puts "\n"
		  			puts "I'm afraid I didn't understand your move - please try again"
		  			puts "\n"
		  		else
		  			# convert from standard notation to internal indices
			  		from_file = FILES.index(movematch[:ffile])
			  		from_rank = (movematch[:frank].to_i) - 1
			  		to_file = FILES.index(movematch[:tfile])
			  		to_rank = (movematch[:trank].to_i) - 1
			  		goodmove = true
		  		end
		  	end	  		

		  	if helpreq
		  		show_help
		  	end
	    end

	    if goodmove
	    	if castle > 0
	    		move = Move.new(@player_num, castle, [-1,-1], [-1,-1])
	    	else
	    		from = [from_file, from_rank]
	    		to = [to_file, to_rank]
	    		move = Move.new(@player_num, 0, from, to)
	    	end
	    elsif quit
	    	move = nil
	    end
	    return command, move
	end

	def show_help
	  	puts "\nA move will specify the square to move from and the square to move to, using standard chess\n"
		puts "notation.  The from square is entered first, then the to square, separated by a single space\n"
		puts "For example, 'e2 e4' at the start of a game would be the classic pawn to king 4.\n"
		puts "The move may be optionally preceded by a single uppercase letter denoting the piece to be moved\n"
		puts "This letter will be one of P, R, N, B, Q or K - Pawn, Rook, kNight, Bishop, Queen or King\n"
		puts "Castling is requested by OO (short castle) or OOO (long castle)"
		puts "\n"
		puts "You can exit the game by typing 'x', 'xx', 'xxx' or 'quit'\n"
		puts "You can save the game by typing 's', 'ss' 'sss', or 'save'\n"
		puts "You can load a saved game by typing 'l', 'll', 'lll' or 'load'\n"
		puts "You can display this help by typing 'h','hh','hhh', or 'help'"
		puts "\n"
	end

   	def choose_promotion(standard_loc)
		choice_regex = /(?<promchoice>[rkbq]{1}).*/
		goodchoice = false
		until goodchoice do
			puts "Player #{@player_num}, one of your pawns has reached the other side of the board at #{standard_loc}.\n"
			puts "Choose whether you want it to be promoted to a Rook, Knight, Bishop or Queen.\n"
			puts "Enter 'r' (Rook), 'k' (Knight), 'b' (Bishop) or 'q' (Queen)"
			instr = gets.chomp
			choice_str = instr.downcase
			choicematch = choice_regex.match(choice_str)
			if choicematch.nil?
				goodchoice = false
				puts "\n"
				puts "I'm sorry, that is not a good choice\n"
				puts "\n"
			else
				goodchoice = true
				choice = choicematch[:promchoice]
				return goodchoice, choice
			end
		end
	end
end

class Move
	# this class encodes a move, including exit and castle requests
	# a move always belongs to a specific player
	# I could (should?) use attr_reader, since a move would not normally be modified once created
	attr_accessor :player, :castle, :fromsq, :tosq
	def initialize(player, castle, fromsq, tosq)
		# player is the player number, 1 or 2
		@player = player
		# castle is a castle request: 0 for no castle, 1 for a 'short' castle, 2 for a 'long' castle
		@castle = castle
		# fromsq is the location to move from: format [column, row]
		@fromsq = fromsq
		# tosq is the location to move to : format [column, row]
		@tosq = tosq
	end

	def show
		# shows a Move in human-readable form.  Could modify to show standard chess notation
		showstr = "Player: #{@player} From: #{@fromsq} To: #{@tosq} Exit: #{@exitreq} Castle: #{@castle}"
	end

	def player_relative(player)
		# method to transform rank coords so that they are relative to the player
		# i.e. counting from 0 up from the player's back row
		if player == 1
			return @fromsq, @tosq
		else
			ffile = @fromsq[0]
			frank = 7 - @fromsq[1]
			tfile = @tosq[0]
			trank = 7 - @tosq[1]
			fromrel = [ffile, frank]
			torel = [tfile, trank]
			return fromrel, torel
		end
	end
end
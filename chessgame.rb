require "./chessboard.rb"
require "./chessplayer.rb"
require 'yaml'

class Game
	# the main class for launching and running the game
	COLS = "abcdefgh"

	def initialize
		@board = Board.new
		@player1 = Player.new(1)
		@player2 = Player.new(2)
		@players = [nil, @player1, @player2]
		@current_player = 1
	end

	def play_game
		@board.reset_board
		exit_game = false
		save_game = false
		load_game = false
		checkmate = false
		# player 1 always starts
		@current_player = 1
	    while !exit_game && !checkmate do
	      @board.display_board
	      player = @players[@current_player]
	      move_valid = false
	      until move_valid do
		      command, move = player.get_move
		      if command == 'q'
		      	exit_game = true
		      elsif command == 's'
		      	save_game = true
		      	save_the_game
		      	move_valid = false
		      elsif command == 'l'
		      	load_game = true
		      	load_the_game
		      	move_valid = false
		      	# redisplay the board, because it may have changed
		      	@board.display_board
		      	# set the current player, may also have changed
		      	player = @players[@current_player]
		      end


		      if exit_game
		      	puts "\nExiting game..."
		      	break
		      end

		      if !move.nil?
		      	move_valid, reason = @board.check_move(move)
		      	if !move_valid
		      		puts "**** Sorry, this move is not possible ****"
		      		puts "\n"
		      		puts " #{reason}"
		      		puts "\n"
		      	else
		      		prom_req, prom_loc = @board.apply_move(move)
		      		if prom_req		      			
			      		@board.display_board
			      		choice_valid, prom_choice = player.choose_promotion(to_chess_notation(prom_loc))
			      		# Then call promote piece in board
			      		if choice_valid
				      		prom_result = @board.promote_piece(move.player, prom_loc, prom_choice)
				      	end
				      	if !choice_valid or !prom_result
				      		puts "I'm very sorry, but something went wrong with the promotion\n"
				      	else
				      		@board.display_board
				      	end
				    end
		      	end
		      end
		  end
	      @current_player = @current_player %2 + 1
	      in_check = @board.in_check?(@current_player)
	      if in_check
	      	puts "\n"
	      	puts "***  Player #{@current_player}, you are in check! ***\n"
	      	puts "\n\n"
	      	checkmate = @board.checkmate?(@current_player)
	      	if checkmate
	      	 	puts "\n*** Sorry, Player #{@current_player}, that's checkmate! ***\n"
	      	 	puts "\n"
	      	end
	      end
	    end
	    if checkmate
	    	puts "This was the final checkmate position..."
	    	puts "\n"
	    	@board.display_board
	    	puts "\n"
	    	puts "Hit ENTER when you want to finish"
	    	instr = gets.chomp
	    	puts "Exiting now..."
	    end
	end

	def save_the_game
		puts "Saving game..."
		# get a file name from the user, or always use a fixed one
		# do File.open(filename, "w"){|f| f.puts YAML.dump(self)}
		filename = "chess_savegame.yml"
		File.open(filename, "w"){|f| f.puts YAML.dump([@board, @current_player])}
#		puts YAML.dump(self)
	end

	def load_the_game
		puts "Loading the game..."
		filename = "chess_savegame.yml"
		if File.exists?(filename)
			contents = File.open(filename, "r"){|f| f.read}
#			puts contents
			@board, @current_player = YAML.load(contents)
		else
			puts "Sorry, there is no saved game to load..."
		end
	end

	def to_chess_notation(loc)
		"#{COLS[loc[0]]}#{loc[1]+1}"
	end
end

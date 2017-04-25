# Chess program

## Context - Odin Project : Ruby Programming : Ruby Final Project

## Summary

The program allows 2 players to play chess on the command line.  It enforces all the rules of chess, including en passant, castling and pawn promotion.  Players are not allowed to make moves which
would put thier king into check.  The program detects when a player is in check, and allows only moves which would make the king safe.  It also detects checkmate.

The program uses Linux control codes for foreground and background colours.  White squares are shown as light blue, and black pieces as red.  Pieces are indicated by the first letter
of the piece name, except that knights are indicated with 'N' to prevent confusion with the king.  The program includes the unicode chess piece symbols, but currently they are not used.
On my terminal at standard font sizes they are too small to be usable.  If you wish to experiment, just change the assignment for piece_symbol in display_piece in Board.

The program also allows saving and loading games.  A fixed file name is used, so in the current version you cannot save more than one game at a time.  It would be fairly straightforward to prompt the user
for save and load file names.

## Structure

The program uses the following classes : Game, Player, Move, Board, Square and Piece.  Piece has subclasses Pawn, Rook, Knight, Bishop, Queen and King.

### Game

This class manages the game, allows saving, loading, and exit; it gets moves and other choices from the current Player, and communicates player choices to the Board.  A game is started
by instantiating this class and calling its #play_game method.

### Player

This class manages most interaction with the human player.  It allows the player to enter moves in standard chess notation, and also other commands such as saving, loading, and exit.  It provides a simple
help facility.

### Move

This class represents a move - it encodes the player making the move, whether the move is a castle and if so whether a long or a short castle.  If the move is a "normal" move, i.e. not a castle,
the move object contains the location to move from and the location to move to.  It also includes a method for converting to "player-relative" coordinates.

### Square

This class represents a single square of the board.  It has a background colour, and a flag indicating if there is a piece on the square; if so, the square references the piece.  It includes methods
remove_piece and add_piece.  add_piece simply replaces whatever was on the square before.

### Board

The Board is an 8 by 8 array of Squares.  It is the largest class, including methods to set up the board, check moves, apply moves, check if castling is allowed, and so on.  The Board is responsible for 
actually carrying out moves.

### Piece and its subclasses

Each Piece knows how it can move and any special requirements - for example a Bishop can only move diagonally, there must be a clear path between start and destination, and the destination
must not be a friendly square (i.e. a Square containing a friendly piece.)  Each piece belongs to a specific Player.  Pieces do not know their own location, nor the location of other pieces on the
Board.  When they have a requirement that depends on the disposition of pieces on the board, they call methods in the Board to carry out the appropriate check.  For example, a King will call
a Board method to see if the proposed move would put it into check.

## Basic Control Flow

The Game gets a move from the player, and asks the Board to check it.  The board does some basic checks - for example, is there a piece on the starting square, does it belong to the player?  Then it asks the relevant piece
whether the move is acceptable.  If so, the board does additional checks - e.g. would the move expose the players king? - and passes the result back to the game.

If the proposed move is valid, the Game asks the Board to apply the move.  The board carries out the move and deals with its results.  Finally, the Game asks the board to check for the other player being in check;
if so it also requests a test for checkmate.  Pawn promotion is also dealt with after applying the move.

The Game also requests the Board to display itself before each player's move, and also when the board has changed, for example due to pawn promotion.
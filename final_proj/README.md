# FPGA Chess Game
A 2 player chess game implemented in FPGA using verilog language for logic design lab final project. 

It is able to display the 8x8 chess board and pieces through VGA and uses mouse to move the pieces. 
The game logic is implemented similarly to a chess game, it has both black and white pieces,
starting with white turns and changing each player's turn after he/she has finish moving a piece.
It succesfully implements the movement of all of the pieces.  

## Block Diagram

![image](https://user-images.githubusercontent.com/75954148/216019014-edef8189-2d9d-4a71-8d37-6321e85db227.png)

## States Diagram

![image](https://user-images.githubusercontent.com/75954148/216020701-45c142c3-d5db-4e1a-9f12-da24d815ef77.png)

## States
There are 5 states for this chess game
1. Standby : state that waits until the current player select a tile that is not empty
2. Selected : state that waits the player to choose another tile where to move the piece to
3. Check : state that checks if the selected tile is possible to move to
4. Move : move the piece to that tile
5. Erase : Delete the original piece in the previous tile

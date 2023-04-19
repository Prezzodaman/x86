# Presley's Ping Pong
A pseudo 3D ping pong game In Space!™, featuring an extremely diverse range of characters who all have totally distinct skills. The rules are changed up; you now score 9 to win, and you always serve. It's a very kind game. Works fantastic at 71000 cycles/ms in DOSBox-X!
## Development
Lots and lots of fun. Originally starting as a Mega Drive game, after getting into DOS programming I decided to port it over. This game is the whole reason I added rotation to BGL, because I wanted to get that nice effect when you move your paddle left and right. On the Mega Drive I'd have had to pre-render the frames, as the way you draw graphics is unsuitable for such effects, though it is possible. Here it's all done in real-time, and it looks very nice indeed. This is also the first game I've ever programmed that simulates 3D.

## Things to look into:
* 11 points to win instead of 9 (should be easy)
* Adding the rule that if both players score the same, there's a tiebreak (2 ahead to win)
* Changing the serving rules so you don't always serve
* Make the AI more dumb, or add a difficulty setting to the title screen

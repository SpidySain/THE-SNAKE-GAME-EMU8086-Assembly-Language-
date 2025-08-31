# THE-SNAKE-GAME-EMU8086-Assembly-Language-
A console-based snake game where the player controls a snake with arrow keys, eats food to grow longer, and avoids collisions. It just like the og snake game we used to play in nokia mobiles

**Feature Details:**
**1. Snake Movement Control (Arrow Keys)**
    i. Detect arrow key presses (↑, ↓, ←, →) to change snake direction.
   ii. Snake head position updates every game tick.
   
**2. Randomly Placed Food (Increase Length) : **   
     i. Place food at random coordinates inside the game area.
    ii. If snake head position = food position → increase length and reposition food.
   iii. PLACE_FOOD  generates coordinates and draws food symbol (e.g., '*').
   
**3. Score Display: **
    i. Keep track of score (1 point per food eaten).
   ii. Display score at top of the screen.
  iii. DISPLAY_SCORE — converts score to ASCII and displays it.
  
**4. Game Over When Snake Hits Wall or Itself **
   i. If snake head X or Y goes beyond screen boundaries → Game Over.
  ii. If head coordinates match any body part → Game Over.

**5. Speed Increases as Score Grows: **
    i. The game starts at slower speed, gets faster as score increases.
    
**6. High Score Storage:** 
   i. Keep the highest score reached during the game session.
  ii. Display high scores at the start of each game.


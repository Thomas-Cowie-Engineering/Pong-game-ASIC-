# VGA Pong Game (Tiny Tapeout) ASIC.

A 2D pong game written in verilog and emulated within the Tiny Tapeout VGA playground environment. I have synthesised it and have produced a chip design for it.

In this README I'll be talking about characteristics of the project and what skills I have learnt from this.


## 🕹️ The project showcased

### GAMEPLAY

The game consists of a white border with a white dashed line across the centre of the border. There are two white paddles on either side of the screen. There's a white ball that bounces around the border of the screen and off the paddles. The two players playing the game can move the two paddles respectively up/down using a singal controller to hit the ball away. If the ball hit's the vertical border on the players side of the screen then the player opposite will gain a point. The first player to accumulate more than 5 points wins.

The reason why one controller controls both paddles is purely to get it to run nicely within the VGA playground environment. If this project was run on an fgpa the idea of two players sharing a small singal controller would not work well. If I were to take this project further it would be easy to adjust my top module to connect another controller.

<img width="350" height="350" alt="image" src="https://github.com/user-attachments/assets/25317818-a0c6-4721-b090-0a8749cf1bd3" />

By setting ui_in[0] to high (1'b1) then you can change the background colour to a nice shade of blue.

<img width="457" height="347" alt="image" src="https://github.com/user-attachments/assets/b3fa83bd-5e25-4726-b53c-50b8fb23d977" />


### GAME OVER SCREEN

If a player accumulates more than 5 points, they win and the game ends. To signify this the entire screen turns into a shade of red and nothing else is visible.

<img width="350" height="350" alt="image" src="https://github.com/user-attachments/assets/47116890-2667-4ad1-834c-b6a385dcab14" />

## 🛠️ Pin Mapping

### Dedicated Inputs (`ui_in`)
| Pin | Function | Description |
|---|---|---|
| `ui_in[0]` | Background Select | High = Blue Background, Low = Black Background |
| `ui_in[4]` | Gamepad Latch | Latch signal for the controller shift register |
| `ui_in[5]` | Gamepad Clock | Clock signal driving the gamepad controller |
| `ui_in[6]` | Gamepad Data | Serial data stream input from the controller |


### Dedicated Outputs (`uo_out`)
| Pin | Function | Description |
|---|---|---|
| `uio_out[2:0]` | left paddle players score | Stores the player's score. Can be connected to a binary LED display to display their score. |
| `ui_out[5:3]` | right paddle players score| Stores the player's score. Can be connected to a binary LED display to display their score.|

##  Synthesis

<img width="396" height="472" alt="image" src="https://github.com/user-attachments/assets/23ef7120-dff1-48c0-a1b2-72ffcc80ffa4" />

Can see my chip at: https://gds-viewer.tinytapeout.com/?pdk=sky130A&model=https%3A%2F%2Fthomas-cowie-engineering.github.io%2FSynthesis-of-VGA-game%2F%2Ftinytapeout.oas

## 📐 Engineering Skills Demonstrated

* **Hardware VGA Signal Processing**
* **Verilog** 
* **Real-Time Procedural Graphics:** Generated active display lines, borders, and moving game elements dynamically using combinational pixel coordinate logic.
* **ASIC Synthesis & Manufacturing:** Configured hardware modules to fit a physical silicon deployment workflow via Tiny Tapeout.

## 🏆 How I would take this project further

* **Add sound effects**
* **Implement and prototype the system on a FPGA** 




# VGA Pong Game (Tiny Tapeout)

A classic 2D Pong game designed for ASIC deployment via the **Tiny Tapeout** platform. This project targets a standard VGA display (640x480 @ 60Hz) using a custom hardware controller driver and a hardware-driven video sync generator.

Adapted from the *Tiny Tapeout VGA Playground*.

---

## 🕹️ Project Features

* **60Hz Hardware Physics:** Game logic updates are gated directly to the `VSYNC` hardware pulse, ensuring smooth, predictable ball and paddle movement tied directly to the monitor's refresh rate.
* **Smart Collision Engine:** Fully dynamic boundary checks for the ball bouncing off top/bottom walls, scoring zones, and player paddles.
* **Adaptive Screen Borders:** Includes a 6-pixel wide outer boundary and a dynamic dashed center line generated completely on-the-fly in logic.
* **Single-Controller Workaround:** Due to simulation limitations within the VGA Playground, both paddles are uniquely mapped to a single digital gamepad.
* **Win State Screen:** The playfield dynamically shifts to a solid red state when either player surpasses 5 points.

---

## 🛠️ Hardware & Pin Mapping

The design targets the standard **TinyVGA PMOD** pinout mapping configuration.

### Dedicated Inputs (`ui_in`)
| Pin | Function | Description |
|---|---|---|
| `ui_in[0]` | Background Select | High = Blue Background, Low = Black Background |
| `ui_in[4]` | Gamepad Latch | Latch signal for the controller shift register |
| `ui_in[5]` | Gamepad Clock | Clock signal driving the gamepad controller |
| `ui_in[6]` | Gamepad Data | Serial data stream input from the controller |

### Dedicated Outputs (`uo_out`)
The output byte is packed to interface seamlessly with the TinyVGA PMOD resistor-ladder DAC:
```verilog
assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

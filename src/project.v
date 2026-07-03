// Thomas Cowie
// VGA PONG GAME 
// Adapted from Tiny Tapeout VGA playground
`default_nettype none

// top module
module Pong (

  
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
  // Set all unused pins to 0 - errors may occur if this isn't done
  assign uio_out[7:6] = 8'd0;
  assign uio_oe  = 8'd0;

 // Defining all inputs

  wire hsync;
  wire vsync;
  reg [1:0] R;
  reg [1:0] G;
  reg [1:0] B;
  wire video_active;
  reg vsync_prev;
  wire [9:0] pix_x;
  wire [9:0] pix_y;

// Variables for the controller
  wire inp_up;
  wire inp_down;
  wire inp_left;
  wire inp_right;
  wire gamepad_present;

  // TinyVGA PMOD Hardware Mapping
  assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

  // // This defines a white border around the screen 
  // Border is 6 pixels wide.
  wire border_pixel = (pix_x < 10'd6) ||
                       (pix_x >= 10'd634) ||
                       (pix_y < 10'd6) ||
                       (pix_y >= 10'd474);

  // This defines a white dashed line across the middle of the screen
  wire center_line_pixel = (pix_x >= 10'd318) &&
                            (pix_x <= 10'd322) &&
                            (pix_y>=10'd48)&&
                            (pix_y<=10'd447)&&
                            (~pix_y[4]);   // toggles every 16 pixels: 16px dash, 16px gap


  // lp = left paddle, rp = right paddle

  // Defines the registers that stores the inital value of the top and
  // bottom y value of the left paddle
  // Stored in registers so they can change from inputs of controllers
  // creating the illusion that it's moving up and down where in fact
  // I am just redefining the border of where it is to be drawn
  reg [9:0] lp_top  = 10'd210;
  reg [9:0] lp_bottom  = 10'd270;
  // Same as lp initially I want the paddles to be directly across from eachother.
  reg [9:0] rp_top  = 10'd210;
  reg [9:0] rp_bottom  = 10'd270;

// initial starting point of the ball
// the ball is 10x10 pixels.
  reg [9:0] ball_top =10'd20;
  reg [9:0] ball_bottom = 10'd30;
  reg [9:0] ball_left =10'd50;
  reg [9:0] ball_right = 10'd60;

  // These will determine the direction the ball moves in
  // ball_y high = down, ball_y low = up
  // ball_x high = right ball_x low = left
  reg ball_y;
  reg ball_x;

 // This defines the amount of pixels the ball moves. It moves 3 pixels at a time
  reg [1:0] ball_step =10'd3;
  
  //Defines where the ball should be drawn on the screen
  wire ball_pixel = ( (pix_y > ball_top) && (pix_y < ball_bottom) && (pix_x > ball_left) && (pix_x<ball_right)  );

  //Defines where the left paddle should be drawn on the screen
  wire left_paddle_pixel  = ( (pix_x>=20 && pix_x<26) && (pix_y >=lp_top && pix_y <=lp_bottom));

  //Defines where the right paddle should be drawn on the screen
  wire right_paddle_pixel = (pix_x >= 10'd614) && (pix_x < 10'd620) &&
                             (pix_y >= rp_top) && (pix_y < rp_bottom);

 // Controller variables 
  reg inp_up_prev;
  wire up_pressed = inp_up & ~inp_up_prev;

  reg inp_down_prev;
  wire down_pressed = inp_down & ~inp_down_prev;

  reg inp_left_prev; 
  wire left_pressed = inp_left & ~inp_left_prev;

  reg inp_right_prev; 
  wire right_pressed = inp_right & ~inp_right_prev;

  // Defines the registers that store the score of the left paddle and the right paddle
  reg [2:0] lp_score;
  reg [2:0] rp_score;

 // Assigns the scores of the paddles to two respective output pins.
 // If this was implemented on a FPGA you could visually see the score by connecting these output pins to two Binary LED displays.

  assign uio_out[2:0] = lp_score;
  assign uio_out[5:3] = rp_score;

  // Defines how far the right and left paddles move up/down
  reg [5:0] move_value = 10'd30 ;


//Submodule Instantiations

  hvsync_generator vga_sync_gen (
      .clk(clk),
      .reset(~rst_n),
      .hsync(hsync),
      .vsync(vsync),
      .display_on(video_active),
      .hpos(pix_x),
      .vpos(pix_y)
  );

  gamepad_pmod_single driver (
      // Inputs:
      .rst_n(rst_n),
      .clk(clk),
      .pmod_data(ui_in[6]),
      .pmod_clk(ui_in[5]),
      .pmod_latch(ui_in[4]),
      // Outputs:
      .up(inp_up),
      .down(inp_down),
      .left(inp_left),
      .right(inp_right),
      .is_present(gamepad_present)
  );

  // Everything that happens in this block happens at the posotive edge of the clock

  always @(posedge clk) begin
    // Active low reset
    if (~rst_n) begin
      R <= 2'b00;
      G <= 2'b00;
      B <= 2'b00;

      inp_up_prev    <= 1'b0;
      inp_down_prev  <= 1'b0;
      inp_left_prev  <= 1'b0;
      inp_right_prev <= 1'b0;
      lp_score <= 0;
      rp_score <= 0;

      ball_x <= 1'b1;
      ball_y <= 1'b1;

    end else begin

    // if ui_in[0] is high then set the background colour to blue
    // if not then the background colour is black
    if (ui_in[0]) begin
    R <= 2'b00;
    G <= 2'b00;
    B <= 2'b01;
    end else begin 
    R <= 2'b00;
    G <= 2'b00;
    B <= 2'b00; 
    end

    // Track last cycle's button state so *_pressed can detect a fresh edge.
    inp_up_prev    <= inp_up;
    inp_down_prev  <= inp_down;
    inp_left_prev  <= inp_left;
    inp_right_prev <= inp_right;

    // Tracks last cycle's VSYNC state
    vsync_prev <= vsync;

    // Moves ball every frame. Must do this or ball moves too fast.
    if (vsync && ~vsync_prev) begin
        // Ball movement logic happens here...
    end
        vsync_prev <= vsync;

    // If the score of either pannel exceeds 5 points then set the screen to a red colour
    if (lp_score >5 || rp_score > 5) begin
        R <= 2'b11;
        G <= 2'b00;
        B <= 2'b00;
      end

    // if not then carry onto the game logic
    else begin

    // Draw a white pixel on the screen if:
    // The electron beam is within the border of the display AND...
    // The electron beam is at a border pixel OR...
    // The electron beam is at a centre line pixel OR...
    // The electron beam is at a left paddle pixel OR...
    // The electron beam is at a right paddle pixel OR...
    // The electron beam is at a ball pixel.

    if (video_active && (border_pixel || center_line_pixel || left_paddle_pixel || right_paddle_pixel ||  ball_pixel)) begin
      R <= 2'b11;
      G <= 2'b11;
      B <= 2'b11;
    end

    // If the up button on the controller is pressed AND
    // Moving the left paddle up by 'move_value' doesn't move outside the border
    // Then move it up by 'move_value'
    if (up_pressed && ((lp_top - move_value) >6))begin
      lp_top <= lp_top - move_value;
      lp_bottom <= lp_bottom - move_value;

    end

    // If the bottom button on the controller is pressed AND
    // Moving the left paddle down by 'move_value' doesn't it move outside the border
    // Then move it down by 'move_value'
      if (down_pressed && (lp_bottom - move_value < 10'd450))begin
      lp_top <= lp_top + move_value;
      lp_bottom <= lp_bottom + move_value;

    end


    // Due to how VGA playground simulates the controller I can't add another controller and simulate it.
    // To work around this to move the right paddle up and down I'll just be wiring it to the left and right arrows of the same controller.
    

   // If the left button on the controller is pressed AND
    // Moving the right paddle up by 'move_value' doesn't move outside the border
    // Then move it up by 'move_value'
    if (left_pressed && ((rp_top - move_value) >6))begin

      rp_top <= rp_top - move_value;
      rp_bottom <= rp_bottom - move_value;

    end

    // If the right button on the controller is pressed AND
    // Moving the right paddle up by 'move_value' doesn't move outside the border
    // Then move it up by 'move_value'
      if (right_pressed && (rp_bottom - move_value < 10'd450))begin
      rp_top <= rp_top + move_value;
      rp_bottom <= rp_bottom + move_value;

    end

    // Moves ball every frame. Must do this or ball moves too fast.
    if (vsync&&~vsync_prev)begin

      
      if (ball_x) begin 

        // Bounce the ball of the right paddle or the right wall if it hit's it.
        if ( (ball_right + ball_step > 634) ||
     ( (ball_right + ball_step > 614) &&
       (ball_bottom >= rp_top) && (ball_top <= rp_bottom) ) ) begin
  ball_x <= 1'b0;
        // if the ball hit's the right wall then the left paddle player gets a point
         if  (ball_right + ball_step > 634) begin
          lp_score <= lp_score + 1'b1;
         end
        end
        else begin 
        // moves ball right
          ball_left <= ball_left + ball_step;
          ball_right <= ball_right + ball_step;
        end
      end

      if (~ball_x) begin
        // If the ball hits the left wall or left paddle then bounce it away
        if ((ball_left - ball_step)<10'd6 || ( (ball_left - ball_step < 26 ) &&
       (ball_bottom >= lp_top) && (ball_top <= lp_bottom)))begin
          ball_x<= 1'b1;
          // If the ball hits the left wall then the right paddle player gains a point.
          if ( (ball_left - ball_step) <10'd6)begin
            rp_score <= rp_score +1'b1;
          end

        end
        else begin 
          // moves ball left
          ball_left <= ball_left - ball_step;
          ball_right <= ball_right - ball_step;
        end
      end


      if (ball_y) begin
        // if the ball hit's the bottom of the border bounce it away
        if (ball_bottom + ball_step > 10'd474) begin
          ball_y <= 1'b0;
        end
        else begin
          // Moves the ball down
          ball_top <= ball_top + ball_step;
          ball_bottom <= ball_bottom + ball_step;
        end
      end
      if (~ball_y) begin 
        // if the ball hits the top of the border bounce it away
        if (ball_top - ball_step < 10'd6) begin
          ball_y <= 1'b1;
        end 
        else begin
          // moves the ball up
          ball_top <= ball_top - ball_step;
          ball_bottom <= ball_bottom - ball_step;
        end
      end
    end
      end 
    end
  end
  
endmodule

// End of HDL script.


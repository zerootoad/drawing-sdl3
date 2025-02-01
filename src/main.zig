// Documentation comments are made using copilot!

const c = @cImport({
    @cInclude("SDL3/SDL.h");
});

const std = @import("std");

pub fn main() !void {
    // Initialize SDL with all available subsystems.
    // If initialization fails, log the error and return.
    if (c.SDL_Init(c.SDL_INIT_VIDEO) == false) {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return;
    }

    // Ensure SDL resources are cleaned up on function exit.
    defer c.SDL_Quit();

    // Create an SDL window with the specified title, position, dimensions, and flags.
    // If window creation fails, log the error and return.
    const window = c.SDL_CreateWindow(
        "SDL2 WINDOW GANG!", // Window title
        800, // Width of the window
        600, // Height of the window
        c.SDL_WINDOW_OPENGL, // Window flags
    ) orelse {
        // Log the error message if window creation fails
        c.SDL_Log("Unable to create window: %s", c.SDL_GetError());
        return;
    };

    // Ensure the window is destroyed when it is no longer needed
    defer c.SDL_DestroyWindow(window);

    // Uncomment these following lines if you want to create a window and renderer at the same time.
    // and remove the previous window creation and destruction.
    // const win: *c.SDL_Window = undefined;
    // const rend: *c.SDL_Renderer = undefined;
    // const window = c.SDL_CreateWindowAndRenderer(800, 600, null, win, rend) orelse {
    //     c.SDL_Log("Unable to create window and renderer: %s", c.SDL_GetError());
    //     return;
    // };
    // defer c.SDL_DestroyWindow(win);
    // defer c.SDL_DestroyRenderer(rend);

    // Uncomment the following lines if u wanna use a window ce and image surface isntead of rendering.
    // const surface = c.SDL_GetWindowSurface(window) orelse {
    //     c.SDL_Log("Unable to get window surface: %s", c.SDL_GetError());
    //     return;
    // };
    // defer c.SDL_FreeSurface(surface);

    // const imagesurface = c.SDL_LoadBMP("src/image.bmp") orelse {
    //     c.SDL_Log("Unable to load image.bmp file: %s", c.SDL_GetError());
    //     return;
    // };
    // defer c.SDL_FreeSurface(imagesurface);

    // Uncomment the following lines if you want to fill the window with black and blit the image to the window surface.
    // _ = c.SDL_FillRect(surface, null, c.SDL_MapRGB(surface.*.format, 0, 0, 0));

    // _ = c.SDL_BlitSurface(imagesurface, null, surface, null);
    // _ = c.SDL_UpdateWindowSurface(window);

    // Create a renderer for the window. If creation fails, log the error and return.
    const renderer = c.SDL_CreateRenderer(window, 0) orelse {
        c.SDL_Log("Unable to create renderer: %s", c.SDL_GetError());
        return;
    };

    // Ensure the renderer is destroyed when it goes out of scope.
    defer c.SDL_DestroyRenderer(renderer);

    // Clear the current rendering target with the drawing color.
    _ = c.SDL_RenderClear(renderer);

    // Set the color used for drawing operations (Rect, Line and Clear).
    _ = c.SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);

    // Update the screen with any rendering performed since the previous call.
    _ = c.SDL_RenderPresent(renderer);

    // SDL_Event structure to handle events
    var event: c.SDL_Event = undefined;

    // Boolean to control the main loop
    var running = true;

    // Boolean to track if the mouse button is held down
    var m1hold = false;

    // Previous x-coordinate of the mouse
    var prevx: f32 = -1;

    // Previous y-coordinate of the mouse
    var prevy: f32 = -1;

    // Loop while running
    while (running) {
        while (c.SDL_PollEvent(&event) != false) { // Loop if an event is available.
            switch (event.type) { // Switch on the type of event.
                c.SDL_EVENT_QUIT => running = false, // If the event is a quit event, stop running.
                c.SDL_EVENT_KEY_DOWN => { // If the event is a keydown event.
                    switch (event.key.key) { // Switch on the key pressed.
                        c.SDLK_ESCAPE => running = false,
                        c.SDLK_Q => {
                            _ = c.SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
                            _ = c.SDL_RenderClear(renderer);
                            _ = c.SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
                            _ = c.SDL_RenderPresent(renderer);
                        },
                        else => {},
                    }
                },
                c.SDL_EVENT_MOUSE_BUTTON_DOWN => { //If the event is a mouse button down event.
                    switch (event.button.button) { //Switch on the button pressed.
                        c.SDL_BUTTON_LEFT => {
                            // Print a debug message indicating that the left mouse button (M1) is being held.
                            std.debug.print("Holding M1\n", .{});

                            // Set the m1hold flag to true, indicating that the left mouse button is currently held down.
                            m1hold = true;

                            // Store the current x-coordinate of the mouse button event in prevx.
                            prevx = event.button.x;

                            // Store the current y-coordinate of the mouse button event in prevy.
                            prevy = event.button.y;
                        },
                        else => {},
                    }
                },
                c.SDL_EVENT_MOUSE_BUTTON_UP => { // If the event is a mouse button up event.
                    switch (event.button.button) { //Switch on the button released.
                        c.SDL_BUTTON_LEFT => {
                            // Print a message indicating that the M1 button has been released.
                            std.debug.print("Released M1\n", .{});

                            // Set the m1hold flag to false, indicating that the M1 button is no longer being held.
                            m1hold = false;

                            // Reset the previous x and y coordinates to -1.
                            prevx = -1;
                            prevy = -1;
                        },
                        else => {},
                    }
                },
                c.SDL_EVENT_MOUSE_MOTION => { //If the event is a general mouse motion event.
                    // Check if the mouse button is held down and previous coordinates are valid
                    if (m1hold and prevx != -1 and prevy != -1) {
                        // Get the current mouse coordinates
                        const x = event.motion.x;
                        const y = event.motion.y;

                        // Print the current drawing coordinates to the debug output
                        std.debug.print("Drawing at ({};{})\n", .{ x, y });

                        // Draw a line from the previous coordinates to the current coordinates
                        _ = c.SDL_RenderLine(renderer, prevx, prevy, x, y);

                        // Update the previous coordinates to the current coordinates
                        prevx = x;
                        prevy = y;
                    }
                },
                else => {},
            }
        }
        // Presents the current rendering to the screen.
        _ = c.SDL_RenderPresent(renderer);

        // Waits for 100 milliseconds before continuing.
        c.SDL_Delay(100);
    }
}

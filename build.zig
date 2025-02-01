const std = @import("std");

/// The build function is the entry point for the build system.
/// It sets up the build configuration, adds an executable target,
/// links necessary libraries, installs the executable, and creates
/// a run step to execute the built application.
///
/// @param b The build context.
pub fn build(b: *std.Build) void {
    // Get the target options from the command line or default values.
    const target = b.standardTargetOptions(.{});
    // Get the optimization options from the command line or default values.
    const optimize = b.standardOptimizeOption(.{});

    // Add an executable target to the build.
    const exe = b.addExecutable(.{
        .name = "learningsdl", // Name of the executable.
        .root_source_file = b.path("src/main.zig"), // Path to the root source file.
        .target = target, // Target options.
        .optimize = optimize, // Optimization options.
    });

    // Link the executable with the C standard library.
    exe.linkLibC();
    // Link the executable with the SDL2 library.
    exe.linkSystemLibrary("SDL3");

    // Install the executable as a build artifact.
    b.installArtifact(exe);

    // Create a run command to execute the built executable.
    const run_cmd = b.addRunArtifact(exe);
    // Ensure the run command depends on the install step.
    run_cmd.step.dependOn(b.getInstallStep());

    // Allow passing command line arguments to the executable.
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // Add a "run" step to the build system to run the application.
    const run_step = b.step("run", "Run the app");
    // Ensure the "run" step depends on the run command.
    run_step.dependOn(&run_cmd.step);
}

//! Logic for starting the graphics pipeline

use bevy::app::{App, Plugin, Startup};

/// Adds game logic for rendering the game world.
///
/// This should only contain logic to render and the game simulation should run without this.
pub struct GraphicsPlugin;

impl Plugin for GraphicsPlugin {
    fn build(&self, app: &mut App) {
        app.add_systems(Startup, hello_graphics);
    }
}

fn hello_graphics() {
    println!("hello from the graphics plugin!");
}

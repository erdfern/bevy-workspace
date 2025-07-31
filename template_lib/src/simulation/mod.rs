//! Simulation logic.
//! Decouple from rendering.

use bevy::app::{Plugin, Startup};

pub struct SimulationPlugin;

impl Plugin for SimulationPlugin {
    fn build(&self, app: &mut bevy::app::App) {
        app.add_systems(Startup, hello_simulation);
    }
}

fn hello_simulation() {
    println!("hello from the simulation plugin!");
}

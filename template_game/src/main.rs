use bevy::prelude::*;
use template_lib::{graphics::GraphicsPlugin, player::PlayerPlugin, simulation::SimulationPlugin};

fn main() {
    App::new()
        .add_plugins(DefaultPlugins)
        .add_plugins(SimulationPlugin)
        .add_plugins(GraphicsPlugin)
        .add_plugins(PlayerPlugin)
        .run();
}

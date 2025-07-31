pub mod graphics;
pub mod player;
pub mod simulation;

pub mod testing {
    // use super::*;

    use bevy::{MinimalPlugins, app::App};

    use crate::{graphics::GraphicsPlugin, player::PlayerPlugin, simulation::SimulationPlugin};

    /// Build a minimal bevy app
    pub fn minimal_app() -> App {
        let mut app = App::new();
        app.add_plugins(MinimalPlugins);

        app
    }

    /// Build an app which runs our simulation
    pub fn simulation_app() -> App {
        let mut app = App::new();
        app.add_plugins(SimulationPlugin);

        app
    }

    /// Build an app which users can interact with
    pub fn interaction_app() -> App {
        let mut app = simulation_app();
        app.add_plugins(bevy::input::InputPlugin)
            .add_plugins(GraphicsPlugin)
            .add_plugins(PlayerPlugin);
        app
    }
}

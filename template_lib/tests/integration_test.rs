use template_lib::testing::{interaction_app, minimal_app, simulation_app};

#[test]
pub fn minimal_app_can_update() {
    let mut app = minimal_app();
    app.update()
}

#[test]
fn simulation_app_can_update() {
    let mut app = simulation_app();

    app.update()
}

#[test]
fn interaction_app_can_update() {
    let mut app = interaction_app();

    app.update()
}

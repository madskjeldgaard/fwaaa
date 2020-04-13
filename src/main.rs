use nannou::noise::{NoiseFn, Perlin};
use nannou::prelude::*;
use nannou_osc as osc;
use nannou_osc::Type;

fn main() {
    nannou::app(model).update(update).simple_window(view).run();
}

struct Model {
    sender: osc::Sender<osc::Connected>,
}

fn model(_app: &App) -> Model {
    let port = 1952;
    let target_addr = format!("{}:{}", "127.0.0.1", port);
    let sender = osc::sender().unwrap().connect(target_addr).unwrap();

    Model { sender }
}

fn update(_app: &App, _model: &mut Model, _update: Update) {}

fn send_osc(sender: &osc::Sender<osc::Connected>, path: String, value: f32) {
    let arg = vec![Type::Float(value)];
    sender.send((path, arg)).ok();
}

fn view(app: &App, model: &Model, frame: Frame) {
    // The drawing mechanism
    let draw = app.draw();

    // Clear background
    draw.background().color(BLACK);

    // Screen boundaries
    let win = app.window_rect();

    // Time
    let t = app.time;

    // Perlin noise generator
    let n = Perlin::new();

    // Draw some circles
    let num_circles = 10;

    for i in 0..num_circles {
        let radius = 10.0;

        let index = i as f64;
        let time = t as f64;

        // Two noise generators
        let noise1 = n.get([time + index, time + index]);
        let noise2 = n.get([time + (index * 2.0), time + (index * 3.0)]);

        let x = map_range(
            noise1,
            -1.0,
            1.0,
            win.left() + (i as f32 * radius),
            win.right(),
        );
        let y = map_range(
            noise2,
            -1.0,
            1.0,
            win.bottom() + (i as f32 * radius),
            win.top(),
        );

        // Draw the circle
        draw.ellipse()
            .radius(radius)
            .rgba(255.0, 255.0, 255.0, 1.0)
            .x_y(x, y);

        // Send osc data for circle
        let xpath = format!("/circle{}/x", i);
        let normx = map_range(x, win.left(), win.right(), 0.0, 1.0);
        send_osc(&model.sender, xpath, normx);

        let ypath = format!("/circle{}/y", i);
        let normy = map_range(y, win.bottom(), win.top(), 0.0, 1.0);
        send_osc(&model.sender, ypath, normy);
    }

    draw.to_frame(app, &frame).unwrap();
}

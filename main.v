import gg
import gx
import rand
import math

// Windows size
const screen_width = 800
const screen_height = 600

// Amounts used to construct simlation
const ant_amount = 1000
const food_amount = 2000

//  spawn points of ants and food
const ant_spawn = [200, 200]
const food_spawn = [[100, 100], [500, 500], [700, 300], [100, 230]]
const spawn_range = 20

const ant_color = gx.red
const food_color = gx.green
const bg_color = gx.black

const ant_size = 2
const food_size = 2

pub struct Ant {
	mut:
		x f64
		y f64
		food bool
		direction f64
		color gg.Color = ant_color
}

fn (mut ant Ant) update () {
	ant.x += math.cos(ant.direction*math.pi)
	ant.y += math.sin(ant.direction*math.pi)
	ant.direction += rand.f64_in_range(-0.2, 0.2) or {0}

	if ant.x < 0 { ant.x = 0.0 
				   ant.direction=math.pi-ant.direction }
	if ant.x > screen_width { ant.x = screen_width
							  ant.direction=math.pi-ant.direction }
	if ant.y < 0 { ant.y = 0.0
				   ant.direction=math.pi-ant.direction }
	if ant.y > screen_height { ant.y = screen_height
							   ant.direction=math.pi-ant.direction }
}

fn new_ant() Ant {
	return Ant{x: ant_spawn[0] 
			   y: ant_spawn[1]
			   direction : rand.f64n(2) or { 0 }}
}

struct Food {
	mut:
		x int
		y int
		color gg.Color = food_color
}

fn new_food() Food {
	mut rand_spawn := rand.element(food_spawn) or { [0, 0] }
	return Food{x: rand.int_in_range(rand_spawn[0]-spawn_range, rand_spawn[0]+spawn_range) or {rand_spawn[0]}
				y: rand.int_in_range(rand_spawn[1]-spawn_range, rand_spawn[1]+spawn_range) or {rand_spawn[1]}} 
}

struct Sim {
	mut:
		ants []Ant
		foods []Food
}

fn (mut sim Sim) update() {
	for mut ant in sim.ants {
		ant.update()
	}
}

fn new_sim() Sim {
	mut ant_list := []Ant{}
	mut food_list := []Food{}
	for _ in 0 .. ant_amount { ant_list << new_ant() }
	for _ in 0 .. food_amount { food_list << new_food() }

	return Sim {
		ants: ant_list
		foods: food_list
	}
}

struct App {
	mut:
		gg &gg.Context = unsafe { nil }
		sim Sim
}

fn print_app(app &App) {
	for ant in app.sim.ants {
		app.gg.draw_circle_filled(int(ant.x), int(ant.y), ant_size, ant.color)
	}
	for food in app.sim.foods {
		app.gg.draw_circle_filled(food.x, food.y, food_size, food_color)
	}
}

fn frame(mut app App) {
	app.gg.begin()
	app.sim.update()
	print_app(&app)
	app.gg.end()
}

fn main() {
	mut app := App {
		gg: 0
		sim: new_sim()
	}
	app.gg = gg.new_context(
		bg_color: bg_color
		frame_fn: frame
		user_data: &app
		width: screen_width
		height: screen_height
		create_window: true
		window_title: 'Ant Colony'
	)
	app.gg.run()
}
import gg
import gx
import rand
import math

// Windows size
const screen_width = 800
const screen_height = 600

// Amounts used to construct simlation
const ant_amount = 100
const food_amount = 1000

//  spawn points of ants and food
const ant_spawn = [200, 200]
const food_spawn = [[100, 100], [500, 100], [800, 750], [0, 0]]
const spawn_range = 20

const ant_color = gx.red
const food_color = gx.green

const ant_size = 5
const food_size = 5

struct Ant {
	mut:
		x int
		y int
		food bool
		direction f64
		color gg.Color = ant_color
}

fn new_ant() Ant {
	return Ant{x: ant_spawn[0] 
			   y: ant_spawn[1]
			   direction : rand.f64n(2) or { 0 }}
}

fn (ant Ant) update () {
	ant.x+=math.cos(direction*math.pi)
	ant.y+=sin(direction*math.pi)
	direction += rand.f64_in_range(-0.2, 0.2) or {0}
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

fn (sim Sim) update() {
	for ant in sim.ants {
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
		app.gg.draw_circle_filled(ant.x, ant.y, ant_size, ant.color)
	}
	for food in app.sim.foods {
		app.gg.draw_circle_filled(food.x, food.y, food_size, food_color)
	}
}

fn frame(mut app App) {
	app.gg.begin()
	print_app(app)
	app.gg.end()
}

fn main() {
	mut app := App {
		gg: 0
		sim: new_sim()
	}
	app.gg = gg.new_context(
		bg_color: gx.white
		frame_fn: frame
		user_data: &app
		width: screen_width
		height: screen_height
		create_window: true
		window_title: 'Ant Colony'
	)
	app.gg.run()
}
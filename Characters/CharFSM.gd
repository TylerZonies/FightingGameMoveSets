extends StateMachine

var current_move_direction = 1
var turn_lerp = 0.2
var buffer_dash = false
var remaining_jumps

func _ready():
	add_state('idle')
	add_state('dash')
	add_state('run')
	add_state('hit_stun')
	add_state('jump')
	add_state('fall')
	add_state('land')
	add_state('turn')
	add_state('dash_turn')
	add_state('slide')
	add_state('idle_buffer')
	add_state('crouch')
	add_state('jump_squat')
	call_deferred('set_state', states.idle)
	remaining_jumps = parent.jumps
	print(states)

func _state_logic(delta):
	if state == states.jump or state == states.fall:
		parent.apply_gravity()
		if parent.x_direction != 0:
			parent.velocity.x = lerp(parent.velocity.x, parent.max_speed * parent.x_direction, parent.air_lerp)
		if remaining_jumps > 0 and parent.y_direction == 1:
				remaining_jumps -= 1
				parent.jump()
				if parent.x_direction != 0:
					parent.velocity.x = parent.max_speed * parent.x_direction
		#if parent.velocity.x < parent.max_speed * parent.x_direction:
		#	parent.velocity.x += parent.air_speed * parent.x_direction
	elif parent.y_direction == 1:
		if parent.short_hop_timer.is_stopped():
			parent.jump()
		else:
			parent.jump(false)
	match state:
		states.idle:
			parent.velocity.x = 0
			
			
		states.dash:
			parent.sprite.flip_h = current_move_direction == -1
			#parent.move(current_move_direction, delta)*
			parent.velocity.x = parent.ground_speed * current_move_direction 
			#if parent.y_direction == 1:
			#	parent.jump()
		states.run:
			parent.sprite.flip_h = current_move_direction == -1
			parent.velocity.x = parent.ground_speed * current_move_direction 
			#if parent.y_direction == 1:
			#	parent.jump()
		states.slide:
			parent.velocity.x = lerp(parent.velocity.x, 0, 0.2)
			#if parent.y_direction == 1:
			#	parent.jump()
		states.turn:
			parent.velocity.x = lerp(parent.velocity.x, 0, turn_lerp) 
			#if parent.y_direction == 1:
			#	parent.jump()
		
		#states.jump:
		#	if remaining_jumps > 0 and parent.y_direction == 1:
		#		remaining_jumps -= 1
		#		parent.jump()
		#states.fall: 
		#	if remaining_jumps > 0 and parent.y_direction == 1:
		#		remaining_jumps -= 1
		#		parent.jump()

func _get_transition(delta):
	match state:
		states.idle:
			if !parent.check_on_floor():
				if parent.velocity.y < 0:
					return states.jump
				else:
					return states.fall
			elif parent.x_direction != 0:
				return states.dash
			elif parent.y_direction == -1:
				return states.crouch
		states.dash:
			if parent.check_on_floor():
				if parent.x_direction == 0:
					return states.idle_buffer
				elif parent.y_direction == -1:
					return states.crouch
				elif parent.dash_timer.is_stopped():
					return states.run
				#elif abs(parent.velocity.x) < parent.ground_speed:
					#return states.slide
				elif parent.x_direction != current_move_direction && parent.x_direction != 0:
					return states.dash_turn
			else:
				return states.jump
		states.run:
			if parent.check_on_floor():
				if parent.x_direction == 0:
					return states.idle_buffer
				#elif abs(parent.velocity.x) < parent.ground_speed:
					#return states.slide
				elif parent.y_direction == -1:
					return states.crouch
				elif parent.x_direction != current_move_direction && parent.x_direction != 0:
					return states.turn
					
			else:
				return states.jump
		states.jump:
			if parent.velocity.y >= 0:
				return states.fall
		states.fall:
			if parent.check_on_floor():
				return states.land
		states.land:
			if parent.check_on_floor():
				return states.idle
			else:
				return states.jump
		states.slide:
			if parent.check_on_floor():
				if abs(parent.velocity.x) < 10:
					return states.idle
				elif parent.y_direction == -1:
					return states.crouch
				elif parent.x_direction != 0:
					return states.turn
			else:
				return states.jump
		states.turn:
			if parent.check_on_floor():
				if abs(parent.velocity.x) < 10:
					if current_move_direction != 0:
						return states.run
					else:
						return states.idle
				elif parent.y_direction == -1:
					return states.crouch
			else:
				return states.jump
		states.dash_turn:
			if parent.check_on_floor():
				if current_move_direction != 0:
					return states.dash
				elif parent.y_direction == -1:
					return states.crouch
				else:
					return states.idle_buffer
			else:
				return states.jump
		states.idle_buffer:
			if parent.check_on_floor():
				if parent.y_direction == -1:
					return states.crouch
				if parent.idle_buffer_timer.is_stopped():
					if parent.x_direction == 0:
						return states.slide
					return states.idle
				if parent.x_direction != 0:
					if parent.x_direction == current_move_direction:
						if buffer_dash:
							return states.dash
						else:
							return states.run
					if current_move_direction != parent.x_direction:
						if buffer_dash:
							return states.dash_turn
						else:
							return states.turn
			else:
				return states.jump
		states.crouch:
			if parent.check_on_floor():
				if parent.y_direction != -1:
					return states.idle
			else:
				return states.jump

func _enter_state(old_state, new_state):
#	parent.label.text = new_state
	print(new_state)
	match new_state:
		states.idle:
			parent.label.text = 'idle'
			#play idle animation
			pass
		states.dash:
			if parent.dash_timer.is_stopped() or old_state == states.dash_turn:
				parent.dash_timer.start(0.4)
			current_move_direction = parent.x_direction
			parent.label.text = 'dash'
			#play dash animation
			
		states.run:
			parent.label.text = 'run'
			if previous_state == states.turn:
				current_move_direction = parent.x_direction
			
		states.slide:
			#do slide animation
			parent.label.text = 'slide'
			pass
		states.turn:
			parent.label.text = 'turn'
			current_move_direction = parent.x_direction
			#parent.turn_timer.start(0.5)
			turn_lerp = 0.2
		states.dash_turn:
			#play dash turn animation
			parent.label.text = 'dash_turn'
			#parent.turn_timer.start(0.5)
			turn_lerp = .5
		states.idle_buffer:
			parent.label.text = 'idle_buffer'
			parent.idle_buffer_timer.start()
			buffer_dash = old_state == states.dash
		states.land:
			remaining_jumps = parent.jumps
			parent.velocity.y = 0
		states.jump:
			parent.short_hop_timer.stop()
			parent.label.text = 'jump'
			if old_state != states.fall:
				remaining_jumps -= 1
		states.fall:
			parent.label.text = 'fall'
			if old_state != states.jump:
				remaining_jumps -= 1
		states.crouch:
			parent.short_hop_timer.start()
			parent.label.text = 'crouch'
			parent.sprite.animation = 'crouch'
			parent.velocity.x = 0
			#parent.set_fall_through_platform(false)

func _exit_state(old_state, new_state):
	match old_state:
		states.dash:
			#parent.dash_timer.stop()
			pass
		states.turn:
			parent.turn_timer.stop()
		states.crouch:
			#if new_state != states.jump:
			parent.sprite.animation = 'idle'
			#parent.set_fall_through_platform(true)


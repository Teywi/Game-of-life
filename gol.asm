	addi sp, zero, CUSTOM_VAR_END
    ;;    game state memory location
    .equ CURR_STATE, 0x1000              ; current game state
    .equ GSA_ID, 0x1004                  ; gsa currently in use for drawing
    .equ PAUSE, 0x1008                   ; is the game paused or running
    .equ SPEED, 0x100C                   ; game speed
    .equ CURR_STEP,  0x1010              ; game current step
    .equ SEED, 0x1014                    ; game seed
    .equ GSA0, 0x1018                    ; GSA0 starting address
    .equ GSA1, 0x1038                    ; GSA1 starting address
    .equ SEVEN_SEGS, 0x1198              ; 7-segment display addresses
    .equ CUSTOM_VAR_START, 0x1200        ; Free range of addresses for custom variable definition
    .equ CUSTOM_VAR_END, 0x1300
    .equ LEDS, 0x2000                    ; LED address
    .equ RANDOM_NUM, 0x2010              ; Random number generator address
    .equ BUTTONS, 0x2030                 ; Buttons addresses

    ;; states
    .equ INIT, 0
    .equ RAND, 1
    .equ RUN, 2

    ;; constants
    .equ N_SEEDS, 4
    .equ N_GSA_LINES, 8
    .equ N_GSA_COLUMNS, 12
    .equ MAX_SPEED, 10
    .equ MIN_SPEED, 1
    .equ PAUSED, 0x00
    .equ RUNNING, 0x01



main:

	; BEGIN:game_of_life
	game_of_life: ;NEED to keep t0
		addi sp, sp, -4  ;;down 4 la stack (to push)
		stw ra, 0(sp)		;; stock la ra dans la stack
		call reset_game 
		ldw ra, 0(sp)  ;; viens recuperer lancienne ra
		addi sp, sp, 4	;; up 4 la stack (to pop)

addi t0, zero, 1
stw t0, SEED(zero)
addi t0, zero, 0x821
stw t0, CURR_STEP(zero)
addi t0, zero, RUNNING
stw t0, PAUSE(zero)
addi t0, zero, RUN
stw t0, CURR_STATE(zero)

		addi sp, sp, -4  ;;down 4 la stack (to push)
		stw ra, 0(sp)		;; stock la ra dans la stack
		call get_input 
		ldw ra, 0(sp)  ;; viens recuperer lancienne ra
		addi sp, sp, 4	;; up 4 la stack (to pop)
		
		add t0, zero, v0
		
		main_game_loop:
			add a0, zero, t0
			addi sp, sp, -8  ;;down 8 la stack (to push)
			stw ra, 0(sp)		;; stock la ra dans la stack
			stw t0, 4(sp)
			call select_action 
			ldw t0, 4(sp)
			ldw ra, 0(sp)  ;; viens recuperer lancienne ra
			addi sp, sp, 8	;; up 8 la stack (to pop)

			add a0, zero, t0
			addi sp, sp, -4  ;;down 4 la stack (to push)
			stw ra, 0(sp)		;; stock la ra dans la stack
			call update_state 
			ldw ra, 0(sp)  ;; viens recuperer lancienne ra
			addi sp, sp, 4	;; up 4 la stack (to pop)

			addi sp, sp, -4  ;;down 4 la stack (to push)
			stw ra, 0(sp)		;; stock la ra dans la stack
			call update_gsa ;;mets toutes les leds a 0
			ldw ra, 0(sp)  ;; viens recuperer lancienne ra
			addi sp, sp, 4	;; up 4 la stack (to pop)

			addi sp, sp, -4  ;;down 4 la stack (to push)
			stw ra, 0(sp)		;; stock la ra dans la stack
			call mask ;;mets toutes les leds a 0
			ldw ra, 0(sp)  ;; viens recuperer lancienne ra
			addi sp, sp, 4	;; up 4 la stack (to pop)

			addi sp, sp, -4  ;;down 4 la stack (to push)
			stw ra, 0(sp)		;; stock la ra dans la stack
			call draw_gsa ;;mets toutes les leds a 0
			ldw ra, 0(sp)  ;; viens recuperer lancienne ra
			addi sp, sp, 4	;; up 4 la stack (to pop)

			addi sp, sp, -4  ;;down 4 la stack (to push)
			stw ra, 0(sp)		;; stock la ra dans la stack
		;	call wait ;;mets toutes les leds a 0
			ldw ra, 0(sp)  ;; viens recuperer lancienne ra
			addi sp, sp, 4	;; up 4 la stack (to pop)
			
			addi sp, sp, -4  ;;down 4 la stack (to push)
			stw ra, 0(sp)		;; stock la ra dans la stack
			call decrement_step ;;mets toutes les leds a 0
			ldw ra, 0(sp)  ;; viens recuperer lancienne ra
			addi sp, sp, 4	;; up 4 la stack (to pop)
			
			;addi t3, zero, PAUSED	
			;stw t3, PAUSE(zero) ;for debugging
			add t1, v0, zero
			;add t1, zero, zero

			addi sp, sp, -8  ;;down 4 la stack (to push)
			stw ra, 0(sp)		;; stock la ra dans la stack
			stw t1, 4(sp)
			call get_input ;;mets toutes les leds a 0
			ldw t1, 4(sp)
			ldw ra, 0(sp)  ;; viens recuperer lancienne ra
			addi sp, sp, 8	;; up 4 la stack (to pop)

			add t0, zero, v0
			
			beq t1, zero, main_game_loop

		br game_of_life
		ret
	; END:game_of_life
	
    
	; BEGIN:clear_leds
	clear_leds:
		add t0, zero, zero
		stw t0, LEDS(zero)
		stw t0, LEDS+4(zero)
		stw t0, LEDS+8(zero)

		ret
	; END:clear_leds

	; BEGIN:set_pixel    
	set_pixel:

		add t0, a0, zero   ;;remainder
		add t1, a1, zero	 ;; quotient
		addi t6, zero, 3
		add t3, zero, zero
		
		loop_pixel:
			bge t6, t0, end_set_pixel
			addi t0, t0, -4
			addi t3, t3, 4 ;; one word = 4 byte
			br loop_pixel
	
	
		end_set_pixel:
		slli t0, t0, 3 ;; (x%4)*8
		add t0, t0, t1 ;; (x%4)*8 + y
		addi t4, zero, 1
		sll t0, t4, t0 ;; shift left 1 by (x%4)*8 + y

		
		ldw t5, LEDS(t3) ;;getting LEDS(i)
		or t5, t5, t0  ;;masking
		stw t5, LEDS(t3)	;;storing back in LEDS(i)
		ret
	; END:set_pixel


	; BEGIN:wait
	wait:
		addi t0, zero, 1
		slli t0, t0, 19 ;For debuggin put again 19
		ldw t1, SPEED(zero)

		wait_loop:
			sub t0, t0, t1
			bge zero, t0, end_wait_loop	;; if counter <= 0  (we can stop)
			br wait_loop
		
		end_wait_loop:
		ret
	; END:wait


	; BEGIN:get_gsa
	get_gsa:
		ldw t0, GSA_ID(zero)
		slli t2, a0, 2  ; t2 = 4*y
		bne t0, zero, get_gsa1 ;;if gsa_id = 1 go to 1 else go to next line

		get_gsa0:
			ldw v0, GSA0(t2)
			br end_get_gsa
		
		get_gsa1:
			ldw v0, GSA1(t2)

		end_get_gsa:
		ret
	; END:get_gsa

	
	; BEGIN:set_gsa
	set_gsa:
		ldw t0, GSA_ID(zero)
		slli t2, a1, 2  ; t2 = 4*y
		beq t0, zero, set_gsa0 ;;if gsa_id = 1 go to 0 else go to next line

		set_gsa1:
			stw a0, GSA1(t2)
			br end_set_gsa
		
		set_gsa0:
			stw a0, GSA0(t2)

		end_set_gsa:
			ret
	; END:set_gsa


	; BEGIN:draw_gsa
	draw_gsa:  ;;NEED to keep t6
		addi sp, sp, -4  ;;down 4 la stack (to push)
		stw ra, 0(sp)		;; stock la ra dans la stack
		call clear_leds ;;mets toutes les leds a 0
		ldw ra, 0(sp)  ;; viens recuperer lancienne ra
		addi sp, sp, 4	;; up 4 la stack (to pop)

		add a0, zero, zero  ;;set the line of the gsa to 0
		addi t3, zero, N_GSA_LINES  ;; condition darret du counter (ligne)

		add t6, zero, zero ;;counter


		gsa0_loop:
			beq t6, t3, end_draw_gsa
	
			add a0, zero, t6

			addi sp, sp, -8  ;;down 8 la stack (to push)
			stw ra, 0(sp)		;; stock la ra dans la stack call get_gsa  ;; into v0
			stw t6, 4(sp)		;;stock le register
			call get_gsa    ;;call get_gsa and put the return value in v0
			ldw t6, 4(sp)
			ldw ra, 0(sp)  ;; viens recuperer lancienne ra
			addi sp, sp, 8	;; up 8 la stack (to pop)

			addi t3, zero, N_GSA_LINES
			add t0, zero, zero

			add t7, v0, zero  ;; gsa into t7
			

			andi t1, t7, 1
			andi t2, t7, 0b10 ;; a mettre en normal
			srli t2, t2, 1
			slli t2, t2, 8
			or t1, t1, t2
			andi t2, t7, 0b100 ;; a mettre en normal
			srli t2, t2, 2
			slli t2, t2, 16 
			or t1, t1, t2
			andi t2, t7, 0b1000 ;; a mettre en normal
			srli t2, t2, 3
			slli t2, t2, 24 
			or t1, t1, t2  ;; on finit le mask
			sll t1, t1, t6  ;; on le shift de y (ligne gsa)
			ldw t5, LEDS(t0) 
			or t5, t5, t1
			stw t5, LEDS(t0) ;; on vient faire les changements sur les leds
			addi t0, t0, 4 ;;on vient chercher ladresse des leds suivantes
			

			andi t1, t7, 0b10000 ;; a mettre en normal
			srli t1, t1, 4
			andi t2, t7, 0b100000 ;; a mettre en normal
			srli t2, t2, 5
			slli t2, t2, 8
			or t1, t1, t2
			andi t2, t7, 0b1000000 ;; a mettre en normal
			srli t2, t2, 6
			slli t2, t2, 16 
			or t1, t1, t2
			andi t2, t7, 0b10000000 ;; a mettre en normal
			srli t2, t2, 7
			slli t2, t2, 24 
			or t1, t1, t2  ;; on finit le mask
			sll t1, t1, t6  ;; on le shift de y (ligne gsa)
			ldw t5, LEDS(t0) 
			or t5, t5, t1
			stw t5, LEDS(t0) ;; on vient faire les changements sur les leds
			addi t0, t0, 4 ;;on vient chercher ladresse des leds suivantes


			andi t1, t7, 0b100000000 ;; a mettre en normal
			srli t1, t1, 8
			andi t2, t7, 0b1000000000 ;; a mettre en normal
			srli t2, t2, 9
			slli t2, t2, 8
			or t1, t1, t2
			andi t2, t7, 0b10000000000 ;; a mettre en normal
			srli t2, t2, 10
			slli t2, t2, 16 
			or t1, t1, t2
			andi t2, t7, 0b100000000000 ;; a mettre en normal
			srli t2, t2, 11
			slli t2, t2, 24 
			or t1, t1, t2  ;; on finit le mask
			sll t1, t1, t6  ;; on le shift de y (ligne gsa)
			ldw t5, LEDS(t0) 
			or t5, t5, t1
			stw t5, LEDS(t0) ;; on vient faire les changements sur les leds

			addi t6, t6, 1
			br gsa0_loop
		
		end_draw_gsa:
		ret
	; END:draw_gsa


	; BEGIN:random_gsa
	random_gsa:		;;NEED t4
		addi t2, zero, N_GSA_COLUMNS ;y-coord
		addi t4, zero, N_GSA_LINES ;;lines

		add t5, zero, zero ;;it will be the random line

	loop_random_line:
		beq t4, zero, end_loop_random
		addi t4, t4, -1
			
	loop_random_y:
		beq t2, zero, after_loop_random
		addi t2, t2, -1

		ldw t3, RANDOM_NUM(zero) ;;t3 = random number
		slli t3, t3, 31
		srli t3, t3, 31 ;;shift to get only the first bit
		
		slli t5, t5, 1
		add t5, t5, t3 ;add the curr pixel
		
		br loop_random_y
		
	after_loop_random:

		add a0, zero, t5 ;;set the line
		add a1, zero, t4  ;;set the y-coord

		addi sp, sp, -8 ;;decrease the stack of 8
		stw ra, 0(sp) ;;stock return address in stack
		stw t4, 4(sp) ;;stock the register
		call set_gsa
		ldw t4, 4(sp)
		ldw ra, 0(sp) ;;take the previous ra back
		addi sp, sp, 8 ;;increase the stack of 8
		
		addi t2, zero, N_GSA_COLUMNS
		add t5, zero, zero
		br loop_random_line

	end_loop_random:
		ret
	; END:random_gsa


	
	; BEGIN:change_speed
	change_speed:
    	ldw t0,  SPEED(zero)  
		slli t1, t0, 24
		srli t1, t1, 24
		beq a0, zero, speed_add_one

		speed_sub_one:
			addi t2, zero, MIN_SPEED
			beq t1, t2, end_change_speed
			addi t1, t1, -1
			br end_change_speed

		speed_add_one:
			addi t2, zero, MAX_SPEED
			beq t1, t2, end_change_speed
			addi t1, t1, 1
		
		end_change_speed:	
		srli t0, t0, 8
		slli t0, t0, 8
		or t1, t1, t0
		stw t1, SPEED(zero)

		ret
	; END:change_speed


	; BEGIN:pause_game
	pause_game:
		ldw t0, PAUSE(zero)  ;;xor 1 = inverse last bit
		slli t0, t0, 31
		srli t0, t0, 31
		xori t0, t0, 1
		stw t0, PAUSE(zero)
		ret
	; END:pause_game


	; BEGIN:change_steps
	change_steps:
		ldw t0, CURR_STEP(zero)
		beq a2, zero, no_add_2 ;; if button 2 is at 0 then skip
		addi t0, t0, 0x100  ;;if we are here it means we should add 0x100

		no_add_2:
			beq a1, zero, no_add_3 ;; button 3 is at 0 then skip
			addi t0, t0, 0x10 ;;if we are here it means we should add 0x010
		
		no_add_3:
			beq a0, zero, no_add_4 ;; button 4 is at 0 then skip
			addi t0, t0, 0x1 ;;if we are here it means we should add 0x001
 
		no_add_4:
			stw t0, CURR_STEP(zero)
		ret
	; END:change_steps


	; BEGIN:increment_seed
	increment_seed: ;;NEED to keep t3, t5
		ldw t0, CURR_STATE(zero)
		addi t1, zero, INIT 
		beq t0, t1, increment_seed_init ;check if curr_state = INIT

	increment_seed_rand:
		;;push
		addi sp, sp, -4 ;;decrease the stack of 4
		stw ra, 0(sp) ;;stock return address in stack
		call random_gsa
		ldw ra, 0(sp) ;;take the previous ra back
		addi sp, sp, 4 ;;increase the stack of 4
		br end_increment_seed
		
	increment_seed_init:
		ldw t1, SEED(zero)
		addi t0, zero, N_SEEDS
		beq t0, t1, increment_seed_rand
		addi t1, t1, 1 ;;does we have to go to state rand if limit is reached
		stw t1, SEED(zero) 
		beq t1, t0, increment_seed_rand
		slli t1, t1, 2 ;;number of the seed *4
		ldw t5, SEEDS(t1) ;; seed0, seeed1 ...
		add t3, zero, zero
		addi t4, zero, N_GSA_LINES


		loop_increment:  ;;NEED to keep t3, t5
			beq t3, t4, end_increment_seed  ;; if y = 8 we stop
			ldw a0, 0(t5)
			add a1, t3, zero

			addi sp, sp, -12 ;;decrease the stack of 12
			stw ra, 0(sp) ;;stock return address in stack
			stw t3, 4(sp) ;;stock both registers
			stw t5, 8(sp)
			call set_gsa
			ldw t5, 8(sp)
			ldw t3, 4(sp)
			ldw ra, 0(sp) ;;take the previous ra back
			addi sp, sp, 12 ;;increase the stack of &2

			addi t4, zero, N_GSA_LINES		
			addi t5, t5, 4
			addi t3, t3, 1
			br loop_increment

	end_increment_seed:
		ret		
	; END:increment_seed
	

	; BEGIN:update_state
	update_state:  ;all buttons were wrong
		add t2, a0, zero

		slli t3, t2, 31
		srli t3, t3, 31 ;;t3 => i=0

		slli t4, t2, 30
		srli t4, t4, 31 ;;t4 => i=1

		slli t5, t2, 29
		srli t5, t5, 31 ;;t5 => i=2

		slli t6, t2, 28
		srli t6, t6, 31 ;;t6 => i=3

		slli t7, t2, 27
		srli t7, t7, 31 ;;t7 => i=4
		
		ldw t0, CURR_STATE(zero)
		addi t1, zero, RAND
		beq t0, t1, rand_state  ;; if current_state = rand then go to rand_state
		addi t1, zero, RUN
		beq t0, t1, run_state  ;; if current_state = run then go to run_state


		init_state:
			bne t3, zero, init_to_rand  ;;if b0 = 1  then check if b0 = N
			beq t4, zero, end_update_state  ;; if b1 = 0 then nothing to do
			addi t0, zero, RUN  ;; we change the state to RUN
			stw t0, CURR_STATE(zero)
			addi t0, zero, RUNNING  ;;set the game to running when you reach run state
			stw t0, PAUSE(zero)
			br end_update_state
		
		init_to_rand:
			ldw t1, SEED(zero)		;; on check si la seed actuelle est egale au nombre de seed 
			addi t2, zero, N_SEEDS
			bne t1, t2, end_update_state
			addi t0, zero, RAND
			stw t0, CURR_STATE(zero)
			br end_update_state

		rand_state:
			beq t4, zero, end_update_state  ;; if b1 = 0 then nothing to do
			addi t0, zero, RUN
			stw t0, CURR_STATE(zero)
			addi t0, zero, RUNNING  ;;set the game to running when you reach run state
			stw t0, PAUSE(zero)
			br end_update_state	

		run_state:
			beq t6, zero, end_update_state ;; if b3 = 0 then nothing to do
			br run_to_init

		run_to_init:
			addi sp, sp, -4 ;;decrease the stack of 4
			stw ra, 0(sp) ;;stock return address in stack
			call reset_game
			ldw ra, 0(sp) ;;take the previous ra back
			addi sp, sp, 4 ;;increase the stack of 4

			br end_update_state

		end_update_state:

			ret
	; END:update_state


	; BEGIN:select_action
	select_action: ;;NEED to keep t0 at multiple places
		add t0, zero, a0 ;t0 = inputs (buttons)
		ldw t1, CURR_STATE(zero)
		addi t2, zero, RUN
		bne t1, t2, select_action_init_rand ;curr_state != RUN then go INIT/RAND

	select_action_run:
		slli t4, t0, 31 ;;wrong button before
		srli t4, t4, 31 ;t4 = input of Button0
		addi t5, zero, 1
		beq t4, t5, select_start_pause	 
		br select_increase_speed

	select_start_pause: ;;NEED to keep t0
		addi sp, sp, -8 ;;decrease the stack of 8
		stw ra, 0(sp) ;;stock return address in stack
		stw t0, 4(sp) ;;stock the register
		call pause_game
		ldw t0, 4(sp)
		ldw ra, 0(sp) ;;take the previous ra back
		addi sp, sp, 8 ;;increase the stack of 4


	select_increase_speed:
		slli t4, t0, 30 ;;button before wrong 
		srli t4, t4, 31 ;t4 = input of Button1
		addi t5, zero, 1
		beq t4, t5, select_increase_speed_confirmed
		br select_decrease_speed

	select_increase_speed_confirmed: ;;NEED to keep t0
		add a0, zero, zero ;a0 = 0 to increment
		;;push
		addi sp, sp, -8 ;;decrease the stack of 8
		stw ra, 0(sp) ;;stock return address in stack
		stw t0, 4(sp)
		call change_speed
		ldw t0, 4(sp)
		ldw ra, 0(sp) ;;take the previous ra back
		addi sp, sp, 8 ;;increase the stack of 8
		
	select_decrease_speed:
		slli t4, t0, 29
		srli t4, t4, 31 ;t4 = input of Button2
		addi t5, zero, 1
		beq t4, t5, select_decrease_speed_confirmed
		br select_new_random_state
	
	select_decrease_speed_confirmed: ;;NEED to keep t0 (but not necessary because end 
		addi a0, zero, 1 ;a0 = 1 to decrease speed
		addi sp, sp, -8 ;;decrease the stack of 4
		stw ra, 0(sp) ;;stock return address in stack
		stw t0, 4(sp)
		call change_speed
		ldw t0, 4(sp)
		ldw ra, 0(sp) ;;take the previous ra back
		addi sp, sp, 8 ;;increase the stack of 4
		br select_new_random_state
		

	select_new_random_state:
		slli t4, t0, 27
		srli t4, t4, 31
		addi t5, zero, 1
		beq t4, t5, select_new_random_state_confirmed
		br end_select_action
	
	select_new_random_state_confirmed:
		addi sp, sp, -4 ;;decrease the stack of 4
		stw ra, 0(sp) ;;stock return address in stack
		call random_gsa
		ldw ra, 0(sp) ;;take the previous ra back
		addi sp, sp, 4 ;;increase the stack of 4
		br end_select_action
	
	
	select_action_init_rand:
		slli t4, t0, 31 ;wrong button before
		srli t4, t4, 31 ;t4 = input of Button0
		addi t5, zero, 1
		beq t4, t5, select_increment_seed	 
		br select_set_steps

	select_increment_seed: ;;NEED to keep t0

		addi sp, sp, -8 ;;decrease the stack of 4
		stw ra, 0(sp) ;;stock return address in stack
		stw t0, 4(sp)
		call increment_seed
		ldw t0, 4(sp)
		ldw ra, 0(sp) ;;take the previous ra back
		addi sp, sp, 8 ;;increase the stack of 4
		br select_set_steps



	select_set_steps: ;;NEED to keep t0 (but not necessary because end of function)
		slli t4, t0, 27 ;wrong before
		srli t4, t4, 31 ;t4 = input of Button4
		add a0, t4, zero

		slli t4, t0, 28 ;wrong before
		srli t4, t4, 31 ;t4 = input of Button3
		add a1, t4, zero

		slli t4, t0, 29 ;wrong before
		srli t4, t4, 31 ;t4 = input of Button2
		add a2, t4, zero
		

		addi sp, sp, -4 ;;decrease the stack of 4
		stw ra, 0(sp) ;;stock return address in stack
		call change_steps
		ldw ra, 0(sp) ;;take the previous ra back
		addi sp, sp, 4 ;;increase the stack of 4
		br end_select_action
		

	end_select_action:
		ret
	; END:select_action


	; BEGIN:cell_fate
	cell_fate:
		add t0, a0, zero ;number of neighbors
		add t1, a1, zero ;state of the cell
		
		beq t1, zero, cell_fate_dead

	cell_fate_alive:
		cmpgeui t3, t0, 2 ;t3 = 1 if #neighbors >= 2 else 0
		cmpltui t4, t0, 4 ;t3 = 1 if #neighbors < 4 else 0
		and t3, t3, t4
		br cell_fate_end

	cell_fate_dead:
		cmpeqi t3, t0, 3 ;t3 = 1 if #neighbors == 3 else 0
		br cell_fate_end
	
	cell_fate_end:
		add v0, t3, zero
		ret
	; END:cell_fate

	
	; BEGIN:find_neighbours
	find_neighbours:  ;;NEED to keep t0,t1,t2,t7
		add t7, a0, zero ;;x-coordinatee
		addi t0, a1, -1 ;;y-coords - 1
		bge t0, zero, neighbours_no_add_8  ;; if <0 add 8
		addi t0, t0, 8

		neighbours_no_add_8:
		add t1, a1, zero ;y-coords
		addi t2, a1, 1 ;y-coords + 1
		addi t3, zero, N_GSA_LINES
		bne t2, t3, neighbours_no_sub_8 ;; if = 8 sub 8
		addi t2, t2, -8

		neighbours_no_sub_8:
		add a0, t0, zero  ;;above line
		addi sp, sp, -20 ;;decrease the stack of 16
		stw ra, 0(sp) ;;stock return address in stack
		stw t0, 4(sp)
		stw t1, 8(sp)
		stw t2, 12(sp)
		stw t7, 16(sp)
		call get_gsa
		ldw t7, 16(sp)
		ldw t2, 12(sp)
		ldw t1, 8(sp)
		ldw t0, 4(sp)
		ldw ra, 0(sp) ;;take the previous ra back
		addi sp, sp, 20 ;;increase the stack of 16

		addi t3, zero, 0b111
		addi t4, t7, 11
		sll t3, t3, t4  ;;shift de x-coordinate + 11 et isoler les 3 groupes de 12 et or
		srli t4, t3, 24
		slli t5, t3, 8
		srli t5, t5, 20
		slli t6, t3, 20
		srli t6, t6, 20
		or t3, t4, t5
		or t3, t3, t6  ;;1 where the neighbours are
		and t0, t3, v0  ;; 1 where the neighbours are lit up
		

		add a0, t1, zero ;;center line
		addi sp, sp, -20 ;;decrease the stack of 16
		stw ra, 0(sp) ;;stock return address in stack
		stw t0, 4(sp)
		stw t1, 8(sp)
		stw t2, 12(sp)
		stw t7, 16(sp)
		call get_gsa
		ldw t7, 16(sp)
		ldw t2, 12(sp)
		ldw t1, 8(sp)
		ldw t0, 4(sp)
		ldw ra, 0(sp) ;;take the previous ra back
		addi sp, sp, 20 ;;increase the stack of 16

		addi t3, zero, 0b111 ;; dont want to get the one in the center
		addi t4, t7, 11
		sll t3, t3, t4  ;;shift de x-coordinate + 11 et isoler les 3 groupes de 12 et or
		srli t4, t3, 24
		slli t5, t3, 8
		srli t5, t5, 20
		slli t6, t3, 20
		srli t6, t6, 20

		or t3, t4, t5
		or t3, t3, t6  ;;1 where the neighbours are
		and t1, t3, v0  ;; 1 where the neighbours are lit up

		addi t3, zero, 1  ;;check if the x-coordinate of the gsa is on
		sll t3, t3, t7
		and t3, t3, v0  
		srl v1, t3, t7  ;;state of the center cell

		
		add a0, t2, zero ;;below line
		addi sp, sp, -24 ;;decrease the stack of 16
		stw ra, 0(sp) ;;stock return address in stack
		stw t0, 4(sp)
		stw t1, 8(sp)
		stw t2, 12(sp)
		stw t7, 16(sp)
		stw v1, 20(sp)
		call get_gsa
		ldw v1, 20(sp)
		ldw t7, 16(sp)
		ldw t2, 12(sp)
		ldw t1, 8(sp)
		ldw t0, 4(sp)
		ldw ra, 0(sp) ;;take the previous ra back
		addi sp, sp, 24 ;;increase the stack of 16

		addi t3, zero, 0b111
		addi t4, t7, 11
		sll t3, t3, t4  ;;shift de x-coordinate + 11 et isoler les 3 groupes de 12 et or
		srli t4, t3, 24
		slli t5, t3, 8
		srli t5, t5, 20
		slli t6, t3, 20
		srli t6, t6, 20

		or t3, t4, t5
		or t3, t3, t6  ;;1 where the neighbours are
		and t2, t3, v0  ;; 1 where the neighbours are lit up

	addi t3, zero, 12
        add t5, zero, zero    ;;counter for loop
        add t4, zero, zero    ;;counter for bits at 1

        loop_count_bits1:
            beq t5, t3, after_loop1
            andi t6, t0, 1 ;;check if last bit at 1
            add t4, t4, t6  ;;add it to counter
            srli t0, t0, 1 ;;shift one right

            addi t5, t5, 1  ;;increase counter
            br loop_count_bits1

        after_loop1:
            add t5, zero, zero    ;;counter for loop
        loop_count_bits2:
            beq t5, t3, after_loop2
            andi t6, t1, 1 ;;check if last bit at 1
            add t4, t4, t6  ;;add it to counter
            srli t1, t1, 1 ;;shift one right

            addi t5, t5, 1  ;;increase counter
            br loop_count_bits2

        after_loop2:
            add t5, zero, zero    ;;counter for loop
        loop_count_bits3:
            beq t5, t3, end_neighbours
            andi t6, t2, 1 ;;check if last bit at 1
            add t4, t4, t6  ;;add it to counter
            srli t2, t2, 1 ;;shift one right

            addi t5, t5, 1  ;;increase counter
            br loop_count_bits3

		end_neighbours:
			sub t4, t4, v1
			add v0, zero, t4 ;;return the counter
			ret
	; END:find_neighbours

	
	; BEGIN:update_gsa
	update_gsa: ;;NEED to keep t0, t1, t2
		ldw t0, PAUSE(zero)
		beq t0, zero, end_update_gsa
		addi t0, zero, N_GSA_LINES
		addi t1, zero, N_GSA_COLUMNS
		
	
		loop_update_line:
			beq t0, zero, change_gsa_id
			addi t0, t0, -1
			addi t1, zero, N_GSA_COLUMNS
			add t2, zero, zero

		
		loop_update_column:
			beq t1, zero, update_line_gsa
			addi t1, t1, -1
			add a0, zero, t1  ;;x-coordinate
			add a1, zero, t0  ;;y-coordinate
			
			;;push
			addi sp, sp, -16 ;;decrease the stack of 16
			stw ra, 0(sp) ;;stock return address in stack
			stw t0, 4(sp)
			stw t1, 8(sp)
			stw t2, 12(sp)
			call find_neighbours
			ldw t2, 12(sp)
			ldw t1, 8(sp)
			ldw t0, 4(sp)
			ldw ra, 0(sp) ;;take the previous ra back
			addi sp, sp, 16 ;;increase the stack of 16
			
			add a0, zero, v0
			add a1, zero, v1

			;;push
			addi sp, sp, -16 ;;decrease the stack of 16
			stw ra, 0(sp) ;;stock return address in stack
			stw t0, 4(sp)
			stw t1, 8(sp)
			stw t2, 12(sp)
			call cell_fate
			ldw t2, 12(sp)
			ldw t1, 8(sp)
			ldw t0, 4(sp)
			ldw ra, 0(sp) ;;take the previous ra back
			addi sp, sp, 16 ;;increase the stack of 16
			
			sll t3, v0, t1 ;;shift
			or t2, t2, t3 ;;put the bit in the right place

			br loop_update_column
			
		update_line_gsa:
			ldw t4, GSA_ID(zero)
			xori t4, t4, 1 ;;reverse the bit
			stw t4, GSA_ID(zero)
			
			add a0, zero, t2
			add a1, zero, t0

			addi sp, sp, -8 ;;decrease the stack of 8
			stw ra, 0(sp) ;;stock return address in stack
			stw t0, 4(sp)
			call set_gsa
			ldw t0, 4(sp)
			ldw ra, 0(sp) ;;take the previous ra back
			addi sp, sp, 8 ;;increase the stack of 8
			
			ldw t4, GSA_ID(zero)
			xori t4, t4, 1 ;;reverse the bit
			stw t4, GSA_ID(zero)

			
			br loop_update_line 
		

		change_gsa_id:
			ldw t4, GSA_ID(zero)
			xori t4, t4, 1 ;;reverse the bit
			stw t4, GSA_ID(zero)
		end_update_gsa:
			ret
	; END:update_gsa


	; BEGIN:mask
	mask: ;;NEED to keep t3, t5
		ldw t0, SEED(zero) ;number of the seed

		slli t0, t0, 2  ;;t0*4
		ldw t2, MASKS(t0) ;Nth mask

		
		add t3, zero, zero ;t3 is the counter
		addi t7, zero, N_GSA_LINES

	mask_loop:  ;;NEED to keep t3, t5
		beq t3, t7, end_mask

		add a0, zero, t3 ;;put the line as an arg for the getter
		;;push
		addi sp, sp, -12 ;;decrease the stack of 12
		stw ra, 0(sp) ;;stock return address in stack
		stw t3, 4(sp)
		stw t2, 8(sp)
		call get_gsa
		ldw t2, 8(sp)
		ldw t3, 4(sp)
		ldw ra, 0(sp) ;;take the previous ra back
		addi sp, sp, 12 ;;increase the stack of 12

		ldw t5, 0(t2)

		
		and a0, t5, v0 ;;mask and get_gsa
		add a1, t3, zero ;y-coord

		addi sp, sp, -12 ;;decrease the stack of 12
		stw ra, 0(sp) ;;stock return address in stack
		stw t3, 4(sp)
		stw t2, 8(sp)
		call set_gsa
		ldw t2, 8(sp)
		ldw t3, 4(sp)
		ldw ra, 0(sp) ;;take the previous ra back
		addi sp, sp, 12 ;;increase the stack of 12
		
		addi t2, t2, 4

		addi t3, t3, 1
		addi t7, zero, N_GSA_LINES
		br mask_loop

	end_mask:
		ret
	; END:mask


	; BEGIN:get_input
	get_input:
		ldw t0, BUTTONS+4(zero) ;edgecapture
		add v0, zero, t0
		stw zero, BUTTONS+4(zero) ;;set edgecapture to 0
		ret
	; END:get_input


	; BEGIN:decrement_step
	decrement_step:
		ldw t0, CURR_STATE(zero)
		ldw t2, PAUSE(zero)
		ldw t3, CURR_STEP(zero)
		addi t1, zero, RUN
		beq t0, t1, decrement_step_run
		
	decrement_step_init_rand_pause:
		add v0, zero, zero  ;;return 0
		br display_segment

	decrement_step_run:
		beq t2, zero, decrement_step_init_rand_pause ;; if the game is paused; treat like init
		beq t3, zero, decrement_step_zero ;; if current_step = 0 then return 1
		addi t3,  t3, -1  ;;decrement by 1 and display
		stw t3, CURR_STEP(zero)
		br display_segment
	
	display_segment:
		andi t4, t3, 0b1111  ;;units
		slli t4, t4, 2  ;;*4 to match the number to the letter font
		ldw t4, font_data(t4) ;;get the correct font
		andi t5, t3, 0b11110000  ;;tens
		srli t5, t5, 4  ;;delete the zeros at the end
		slli t5, t5, 2  ;;*4 to match the number to the letter font
		ldw t5, font_data(t5) ;;get the correct font
		andi t6, t3, 0b111100000000 ;;hundreds
		srli t6, t6, 8  ;;delete the zeros at the end
		slli t6, t6, 2  ;;*4 to match the number to the letter font
		ldw t6, font_data(t6) ;;get the correct font
		andi t7, t3, 0b1111000000000000  ;;overflow of hundreds
		srli t7, t7, 12	 ;;delete the zeros at the end
		slli t7, t7, 2	 ;;*4 to match the number to the letter font
		ldw t7, font_data(t7) ;;get the correct font


		stw t4, SEVEN_SEGS+12(zero) ;;store each one in the correct seven_segment
		stw t5, SEVEN_SEGS+8(zero)
		stw t6, SEVEN_SEGS+4(zero)
		stw t7, SEVEN_SEGS(zero)

		
	
		br end_decrement_step
	
	decrement_step_zero:
		addi v0, zero, 1
		br end_decrement_step

	end_decrement_step:
		ret
	; END:decrement_step


	; BEGIN:reset_game
	reset_game: ;;NEED to keep t0, t1
		addi t0, zero, 1
		stw t0, CURR_STEP(zero) ;;set current_step to 1
		stw zero, SEED(zero)  ;;seed0 is selected
		stw zero, CURR_STATE(zero)  ;;current_state to 0 (INIT)
		stw zero, GSA_ID(zero)  ;;gsa_id is set to 0
		stw zero, PAUSE(zero)  ;;set pause to 0, game is paused
		stw t0, SPEED(zero)  ;;speed is set to 0
		

		addi t0, zero, 4	;;Display on the segment
		ldw t0, font_data(t0)
		stw t0, SEVEN_SEGS+12(zero) 

		ldw t0, font_data(zero)
		stw t0, SEVEN_SEGS+8(zero)
		stw t0, SEVEN_SEGS+4(zero)
		stw t0, SEVEN_SEGS(zero)

		addi t0, zero, seed0	;;Draw seed0 on the LEDS
		add t1, zero, zero ;;counter
		addi t2, zero, N_GSA_LINES

		reset_leds_loop: ;;NEED to keep t0, t1
			beq t1, t2, end_reset_leds_loop
			add a1, zero, t1
			ldw a0, 0(t0)

			addi sp, sp, -12 ;;decrease the stack of 12
			stw ra, 0(sp) ;;stock return address in stack
			stw t0, 4(sp)
			stw t1, 8(sp)
			call set_gsa
			ldw t1, 8(sp)
			ldw t0, 4(sp)
			ldw ra, 0(sp) ;;take the previous ra back
			addi sp, sp, 12 ;;increase the stack of 12

			addi t1, t1, 1  ;;increase counter
			addi t0, t0, 4	;;increase pointer to line of seed0
			addi t2, zero, N_GSA_LINES

			br reset_leds_loop
			
		end_reset_leds_loop:
			addi sp, sp, -4 ;;decrease the stack of 4
			stw ra, 0(sp) ;;stock return address in stack
			call draw_gsa
			ldw ra, 0(sp) ;;take the previous ra back
			addi sp, sp, 4 ;;increase the stack of 4
			ret
	; END:reset_game


font_data:
    .word 0xFC ; 0
    .word 0x60 ; 1
    .word 0xDA ; 2
    .word 0xF2 ; 3
    .word 0x66 ; 4
    .word 0xB6 ; 5
    .word 0xBE ; 6
    .word 0xE0 ; 7
    .word 0xFE ; 8
    .word 0xF6 ; 9
    .word 0xEE ; A
    .word 0x3E ; B
    .word 0x9C ; C
    .word 0x7A ; D
    .word 0x9E ; E
    .word 0x8E ; F

seed0:
    .word 0xC00
    .word 0xC00
    .word 0x000
    .word 0x060
    .word 0x0A0
    .word 0x0C6
    .word 0x006
    .word 0x000 

seed1:
    .word 0x000
    .word 0x000
    .word 0x05C
    .word 0x040
    .word 0x240
    .word 0x200
    .word 0x20E
    .word 0x000

seed2:
    .word 0x000
    .word 0x010
    .word 0x020
    .word 0x038
    .word 0x000
    .word 0x000
    .word 0x000
    .word 0x000

seed3:
    .word 0x000
    .word 0x000
    .word 0x090
    .word 0x008
    .word 0x088
    .word 0x078
    .word 0x000
    .word 0x000


SEEDS:
    .word seed0
    .word seed1
    .word seed2
    .word seed3

mask0:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF

mask1:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0x1FF
	.word 0x1FF
	.word 0x1FF

mask2:
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF

mask3:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0x000

mask4:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0x000

MASKS:
    .word mask0
    .word mask1
    .word mask2
    .word mask3
    .word mask4

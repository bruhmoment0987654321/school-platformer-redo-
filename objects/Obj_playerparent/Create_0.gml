//horizontal speed variables 
hsp = 0; //current horizontal speed
max_hsp = 3; //the max horizontal speed you go
walksp = 0.7; //how fast the player goes
runsp = 1.3; // how fast you can go while running
hsp_wlljp = 3.5; //speed of how far you go in wall jump
//friction
friction_ = 0.2; //this slows you down if you're not moving

//vertical speed variables
vsp = 0; //current vertical speed
vsp_wlljp = -4; //how high you go up during the wall jump
vsp_max = 15; //max speed when falling
vsp_max_wall = 4; //max speed when falling during wall jump
vspjump = -6.5; //how high the player jumps
canjump = 0; //are we touching the ground?

//gravity variables
global.grv = 0.3; //gravity
grv_wall = 0.01; //gravity when you're on a wall

//dash variables
candash = false; //resets when touching ground
dashdistance = 82; // how far the dash goes
dashdisrun = 1.3; //
dashtime = 10; // the amount of time the dash is used

//wall jump variables
onawall = 0; //are we touching a wall?
slimeprts = 0; //slime particles
walljumpdelay = 0; //removing movement to the player when wall jumping
walljumpdelaymax = 18; //time of removing movement during the wall jump

//wall climbing variables
climbsp = runsp* 0.33;

//shoot variables
global.ammo = 0; //how much ammo the boy has
shootdelay = 0; // the cooldown of shooting the balls
shootdelaymax = 7; // the amount for the cooldown

//health variables
global.HP = 1; //how much health the player has
HP_max_slime = 1; //the max amount of health the slime can have
HP_max_boy = 2;

tears = 0; //crying particles
invincibility = false; //if you got hit or not and gives you iframes
invincible_timer = room_speed*1.5; //how long the iframes last
blinktimer = invincible_timer; //the player flashes white when hit
slime_splat = 0; //used when you die and game over screen

stateFree = function(){
	if(global.HP <= 0){
		state = stateDead;	
	}
	#region movement
	walljumpdelay = max(walljumpdelay - 1,0);
	shootdelay = max(shootdelay - 1,0);
	if (walljumpdelay == 0){
		//horizontal movement
		var move = right - left;
		if (move !=0){
			if (!run){
				hsp += move*walksp;
				max_hsp = 3;
			}else{
				hsp += move*runsp*0.2;
				max_hsp = 5.5;
			}
			hsp = clamp(hsp,-max_hsp,max_hsp);
		}else{
			if(image_xscale = 1){
				if(hsp < 0.1){
					hsp = 0;	
				}
			}
			if(image_xscale = -1){
				if(hsp > -0.1){
					hsp = 0;	
				}
			}
			hsp = lerp(hsp,0,friction_);
		}
	}
	//wall jump 
	if (object_index = Obj_boy){
		if(onawall != 0) && (!place_meeting(x,y+vsp,Obj_wall)) && (move != 0){
			if (jump){
				walljumpdelay = walljumpdelaymax;
				hsp = -onawall * hsp_wlljp;
				vsp = vsp_wlljp;
			}
			vsp = 0;
		}
	}
	
	//clinging on the wall
	if(object_index = Obj_slime){
		if(onawall != 0) && (move != 0) && (up){	
			if(move = -1){
				if (run){
					vsp += move*climbsp;
				}
			}else{
				if(run){
					vsp += -move*climbsp;
				}
			}	
		}
	}
	//gravity
	var grv_final = global.grv;
	var vsp_max_final = vsp_max;
		if (onawall != 0) && (vsp > 0){
			grv_final = grv_wall;
			vsp_max_final = vsp_max_wall;
		}
	vsp += grv_final;
	vsp = clamp(vsp,-vsp_max_final,vsp_max_final);
	
	//jump
	if (canjump -- > 0) && (jump){
		vsp = vspjump;
		canjump = 0;
	}
	//shoot inputs
	if(object_index = Obj_boy){
		if(place_meeting(x,y,Obj_paper)){
				global.ammo += 1;
		}
	}
	
	if(global.ammo > 0){
		if(shootdelay == 0){
			if(dashshoot){
				instance_create_layer(x,y,"Player",Obj_paperball);
				shootdelay = shootdelaymax;
			}
		}
	}
	
	//dash input
	if(object_index = Obj_slime){
		if (inputs) && (candash) && (dashshoot){
			candash = false;
			canjump = 0;
			var move = right - left;
			if (move !=0){
				if (!run){
					hsp += move*walksp;
					max_hsp = 3;
				}else{
					hsp += move*runsp;
					max_hsp = 5;
				}
			}
			dashdirection = point_direction(0,0, right-left,down-up);
			if(!run){
				dashdistance = 82;
				dashsp = dashdistance/dashtime;
			}else{
				dashdistance = 82*dashdisrun;
				dashsp = dashdistance/dashtime
			}
			dashenergy = dashdistance;
			state = statedash;
		}
	}

	//run animation
		if (run){
		image_speed = 2;	
	}
	
	//horizontal collision
	if (place_meeting(x+hsp,y,Obj_solid)){
		while(abs(hsp) > 0.1){
			hsp *= 0.5;
			if(!place_meeting(x+hsp,y,Obj_solid)) x += hsp;
		}
		hsp = 0;
	}

	//vertical collision
	if (place_meeting(x,y+vsp,Obj_solid)){
		if(vsp>0){
			candash = true;
			canjump = 7;
		}
		while (abs(vsp) > 0.1){
			vsp *= 0.5;
			if(!place_meeting(x,y+vsp,Obj_solid)) y += vsp
		}
		vsp = 0;
	}
	x += hsp; 
	y += vsp;
	#endregion

}
statedash = function(){
	#region dashing
	//move while dashing
		var move = right - left;
		if (move !=0){
			if (!run){
				hsp += move*walksp;
				max_hsp = 3;
			}else{
				hsp += move*runsp;
				max_hsp = 5;
			}
		}
		//move via the dash
		hsp = lengthdir_x(dashsp,dashdirection);
		vsp = lengthdir_y(dashsp,dashdirection);
	
		//trail effect
		with (instance_create_depth(x,y,depth+1,Obj_trail)){
			sprite_index = other.sprite_index;
			image_blend = #09E444;
			image_alpha = 0.9;
		}

		if (place_meeting(x,y,Obj_hardwall)){
			var _break = instance_place(x,y,Obj_hardwall);
			with(_break){
				instance_destroy();	
			}
		}
		//horizontal collision 
		if (place_meeting(x+hsp,y,Obj_solid)){
			while(abs(hsp) > 0.1){
				hsp *= 0.5;
				if(!place_meeting(x+hsp,y,Obj_solid)) x +=hsp;
			}
			hsp = 0;
		}
		x += hsp; 

		//vertical collision
		if (place_meeting(x,y+vsp,Obj_solid)){
			while (abs(vsp) > 0.1){
				vsp *= 0.5;
				if(!place_meeting(x,y+vsp,Obj_solid)) y += vsp
			}
			vsp = 0;
		}
		y += vsp;
	
		//ending the dashshoot
		dashenergy -= dashsp;
		if (dashenergy <= 0){
			vsp = 0;
			hsp = 0;
			state = stateFree;
		}
	#endregion
}
stateDead = function(){
	hsp = 0;
	vsp = 0;
	//cause of splatter
	if(slime_splat <= 0){
		image_alpha = 0;
		repeat(15){
			instance_create_layer(x,y,"Behind",Obj_slimesplatter);
		}
		slime_splat = 1;
	}
	Obj_game.timer--;
	
}
state = stateFree;
class_name DataTables
extends Node

var dialogs = {
	"dialog 1": """
		[Lario] Hello there
		[Ship] Hi!
	""",
	"dialog 2": """
		[Lario] Hello there
		[Ship] Hi!
	""",
	"cool hit dude": """
		[Lario] Ship, I have a question!
		[Ship] Yes, Lario?
		[Lario] What's a monkey?
		[Ship] Yes, Lario??
		[Lario] COMPUTER: DEFINE MONKEY
		[Ship] A monkey is a
		[Ship] Actually, no. Go get shot by a mummy
	""",
	"Controls": """
		[Ship] We have arrived on Planet Necrolius, Lario.
		[Ship] Use WASD to move around.
		Mouse to look.
		Space is jump.
		Click to fire.
		E to interact.
		Scroll wheel (or numbers) to swap weapons.

		[Ship] Once unlocked, you can also...
		Tap Shift to dash.
		Press space while in the air to glide.

		[Ship] Press escape to pause.

		You can review all log entries in the pause menu.

		[Ship] When your crosshair turns blue, you can scan items in your environment.

		Get close, aim your scanner at the item, and hold fire to focus and scan.
	""",
	"Double Jump": """
		[Lario] Press space again for twice the jump!
	""",
	"Dash": """
		[Ship] This is the dash ability!
		[Ship] Tap shift to dash in the direction you're moving.
		[Ship] That emblem in the top right of the screen will show you when your dash is ready.
		[Lario] You mean, tap shift for twice the jump, but forward this time!
		[Ship] What?
		[Lario] Like, twice the jump, but forwards... this... time?
		[Ship] ...
	""",
	"Glide": """
		[Ship] You just found the "Glide" ability!
		[Lario] Cool. How does it work?
		[Ship] After you jump, you can press space again to float gently through the air.
		[Ship] It lets you do more than float, though.
		[Lario] What do you mean?
		[Ship] Gravity has little hold over you as you glide, so you can use it to extend the height of your jump.
		[Lario] So, I should ACTIVATE GLIDE QUICKLY AFTER JUMPING to gain extra height?
		[Ship] That's right. You should ACTIVATE GLIDE QUICKLY AFTER JUMPING to gain extra height.
		[Lario] And I should WAIT A MOMENT BEFORE ACTIVATING GLIDE to gain extra distance?
		[Ship] That's right. You should ACTIVATE GLIDE QUICKLY AFTER JUMPING to gain extra distance.
		[Lario] Ship, did you know I used to act in corporate training videos?
	""",
	"Radar Gun": """
		[Lario] Scans for info. Cooks your enemies.
	""",
	"4 Color Gun": """
		[Lario] Prismatic pulses pulverize peons. And open doors, I assume.
		[Ship] Correct. Use this gun to 'pulverize peons' and open GREEN doors.
	""",
	"Slime Gun": """
		[Lario] Gross. But effective! Gets everywhere.
		[Ship] I think there's some mushrooms around here that would just love a taste of that slime.
	""",
	"T Gun": """
		[Lario] Fire once for I and twice for T!
	""",
	"Enemy: Gordon": """
		[Guard] Gordon is a big guy with a soft heart. But he'll shoot mortars at you. Blame his programming.
	""",
	"Enemy: Heather": """
		[Guard] Heather just wants to see your world burn.
	""",
	"Enemy: Mummy": """
		[Guard] MRRRRRAAAAAAAAAAAAAUUUUUUUUUGGGGGGGGHHHHHHH
	""",
	"Gorilla": """
		[Guard] Cybernetic war gorillas are much, much scarier than the normal kind.
	""",
	"Rosetta Stone": """
		[Ship] The original dictionary. Kind of. A weapon would be more useful.
	""",
	"Save Point": """
		[Ship] The Tomb Inspector's Guild provided you with these handy waystations that will recompile your physical body and upload your latest neural state upon death.
		Trust me, it works - these guys know a lot about death.
	""",
	"Corpse Table": """
		[Ship] They must be processing the raw corpses here before mummifying them for the MUMMY ARMY.
		[Lario] They should install a counter...'Congratulations! You have helped reduce waste by recylcing 14783982 bodies!'
	""",
	"Decomposing Corpse": """
		[Ship] This corpse appears to have been drained of its bodily fluids via it's anu-
		[Lario] It is very dry.
	""",
	"Row Lights": """
		[Ship] Mercury vapor, 1-1/4 inch diameter, 4100 K.
		[Lario] Powered by the heat output from millions of unsuitable discarded corpses.
	""",
	"Tool Cart": """
		[Ship] Scalpel. Bone saw. Tooth pulverizer. Eye de-lenser. Nostril excavator.
		[Lario] Nail clippers.
	""",
	"Body Bags": """
		[Ship] Sal's Black Body Bags. Guaranteed no-spill or your credits back! 100% waterproof and bloodproof!
		[Lario] How about caustic xenomorph acid-proof?
	""",
	"Drain": """
		[Ship] This must be how they drain the bodily fluids from the room.
		[Lario] Someone should probably snake this.
	""",
	"Trash Heaps": """
		[Ship] Pieces of flesh...rusty tools...spare wire...a battery...looks like he hasn't quite perfected the process...
	""",
	"Sewage Drips": """
		[Lario] This  smells worse than the sulfur deposits on Califax IX. Looks like the plumbing is a little stopped up, though...
	""",
	"Platforming Tiles": """
		[Ship] Maintenance platforms for assembling and repairing the launch vehicle.
		[Lario] With a convenient vertical separation of two standard jump units.
	""",
	"Drone Transport": """
		[Ship] An autonomous transport for the mummy army hordes. It has a range of over 12 light years.
		[Lario] But can it make the Kessel Run in under 12 par-you know what, I can't say this, who is writing this shit?
	""",
	"Sarcophagus": """
		[Ship] A vessel in which the mummy will reside until arriving at the battlefield. Normally used for dead corpses, it will keep the mummy nourished with mush so it wakes up in fighting shape.
		[Lario] Beats the drop pods we used when hitting Tallon IV.
	""",
	"Tubes with Zoober": """
		[Ship] Is that a zoober growing out of that tube?
		[Lario] It is a zoober growing out of a tube.
	""",
	"Beakers and Microscopes": """
		[Ship] Microscopes and beakers tagged with Epsilonian military IDs.
		[Lario] What about the Alphan, Betan, Gamman, and Deltan militaries?
	""",
	"Brain Hooky Thing": """
		[Ship] This is a 12,000-year-old manually-operated brain extraction device.
		[Lario] I think it's my grandmother's missing crochet hook.
	""",
	"Neuralink": """
		[Ship] This device must stimulate the neural network to reprogram the mummies.
		[Lario] I wonder if I could get my commander/dog to put one on...
	""",
	"Mush": """
		[Ship] This appears to be some sort of nutritious substance.
		[Lario]: No one with tastebuds is going to touch that.
	""",
	"Catwalks": """
		[Ship] Maintenance catwalks, presumably for repairing the hydroponic lines.
		[Lario]: Seems like a bit of a leap, but I bet I could peek behind the curtain if I could get up there...
	""",
	"Tree": """
		[Ship] An ephasian oak tree. The sap from these trees is known to be an excellent bio-adhesive.
		[Lario] I'm more interested in bio-lubricants.
	""",
	"Pharaoh Statue": """
		[Ship] A statue of the Pharaoh King Ramses the Great, the most powerful ruler ancient Egypt ever saw.
		[Lario] Did he have a sweet spaceship and awesome stun scanner? Who's great now?
	""",
	"Why am I here?": """
		[Ship] Hello, Lario. We have arrived at Planet Necrolius. The Tomb Inspector's Guild has contracted you to investigate large shipments of human remains to an ancient crypt on this planet.
		[Lario] Isn't that name a little on-the-nose?
		[Ship] I am a connoisseur of facts, Lario. I am not touching your nose.
		[Lario] ...Necrolius. Why does that ring a bell?
		[Ship] We do not have any bells on this ship. Planet Necrolius was mentioned in a heavily redacted file you retrieved during one of your investigations into your mysterious past. All you know is that you once had contact with a denizen of this realm.
		[Lario] I did not know that. How did you know that?
		[Ship] Your memory fails you once again. You are lucky to have me.
		[Lario] Let's just hope we make it through this in one piece.
		[Ship] You'll be descending into the tomb soon. Please stay safe.
	""",
	"Walkabout": """
		[Ship] I have uploaded a refresher on controlling your body. You may want to review it in your logs upon exiting the ship.
	""",
	"Entering Security": """
		[Guard] Sir or Madame, we have been unable to deter this intruder. They seem awfully determined to infiltrate our facility and seem to have intimate knowledge of our defenses, almost as though they've been here before...
		[Sir or Madame] What? That's impossible. We haven't had any visitors for 16 years, 3 months, 2 weeks, and 6 days. Just exterminate them! Our launch can't be interrupted, not after so much time...
		[Lario] 16 years, 3 months, 2 weeks, and 6 days? But that's...the day of my accident...
	""",
	"Confronting Sir or Madame": """
		[Lario] 'Your abominable factory shall be destroyed! The Tomb Inspector's Guild won't stand for this desecration of the human form. The remains of the dead must be respected, from the entrails to the eyeballs.' OK now that I've finished reading my pre-written script, who the hell are you and where the hell am I?
		[Sir or Madame] Who am I? Who are y-*GASP* IT'S YOU! I thought your mind was goopified 16 years, 3 months, 2 weeks, and 6 days ago when I hooked you up to the Neuralink prototype!
		[Lario] Whu?
		[Sir or Madame] You've returned to lead us to glorious victory against the lands of the living! We will live in immortality with our undead hordes!
		[Lario] ...fuck no. Die.
		[Ship] (THIS IS THE END OF THE GAME. THERE IS NO MORE.)
		[Lario] What?
		[Ship] Nothing. Nevermind.
		[Lario] Let's uuuuhhhh... let's just leave and pretend I didn't learn I built this whole facility in a past life?
		[Ship] Oh, is that what was going on? Honestly, I checked out around the time you got that second head in a jar.
		[Ship] PLEASE CLOSE THE GAME, IT IS OVER, THERE IS NO MORE.
		[Lario] Who are you talking to?
		[Ship] Nobody. Nothing. (PLEASE JUST CLOSE THE GAME.)
		[Lario] ...
	""",
	"Vending Machine": """
	[Ship] Lario, the Tomb Inspector's guild leaves vending machines on planets of interest to them.
	[Ship] As you explore the tomb, you might find rare artifacts which are of interest to the guild.
	[Ship] Bring the artifacts back here and you can trade them in for new guns.
	[Lario] Its cheeper to just drop off a vending machine than to explore the tomb themself, huh?
	[Ship] Pretty much.
	""",
	"Door Shield": """
	[Ship] It looks like this door is protected by a shield.
	[Lario] Cool, cool. Can you hack it for me?
	[Ship] Absolutely not. Hacking is illegal.
	[Lario] If you were Peter Dinklage, you would hack it for me.
	[Ship] Well, I'm not. You're going to need to buy a green gun at the vending machine to take down the shield.
	[Lario] They should have never deleted Dinklebot.
	[Ship] ...
	"""
}

var gun_dialogs = {
	four_color = "4 Color Gun",
	scanner = "Scanner",
	slime_gun = "Slime Gun",
	t_gun = "T Gun",
}

onready var selectable_textures = {
	"scanner": preload("res://assets/guns/scangun/scangun_icon.png"),
	"four_color": preload("res://assets/guns/colorgun/four_color_icon.png"),
	"t_gun": preload("res://assets/guns/tgun/tgun-icon.png"),
	"slime_gun": preload("res://assets/guns/slimegun/slimegun-icon.png"),
	"dome": preload("res://assets/icons/crystal-dome.png"),
	"crystal_walk": preload("res://assets/icons/crystal-walk.png"),
	"npk_teleport": preload("res://assets/icons/npk-icon.png"),
	"four_color_red": preload("res://assets/icons/four_color_red.png"),
	"four_color_blue": preload("res://assets/icons/four_color_blue.png"),
	"four_color_yellow": preload("res://assets/icons/four_color_yellow.png"),
	"four_color_green": preload("res://assets/icons/four_color_green.png"),
	"artifact": preload("res://assets/ui/toom-scroll.png"),
	"health": preload("res://assets/entities/health.png"),
	"glide": preload("res://assets/icons/glide-icon.png"),
	"dash": preload("res://assets/icons/dash-icon.png"),
}

onready var weapon_tscns = {
	scanner = preload("res://guns/scanner.tscn"),
	four_color = preload("res://guns/four_color.tscn"),
	slime_gun = preload("res://guns/slime_gun.tscn"),
	t_gun = preload("res://guns/t_gun.tscn"),
}

onready var action_tscns = {
	dome = preload("res://entities/actions/dome.tscn"),
	crystal_walk = preload("res://entities/actions/crystal_walk.tscn"),
	npk_teleport = preload("res://entities/actions/npk_teleport.tscn"),
}

onready var four_color_bullets = {
	green = preload("res://entities/bullets/green_bullet.tscn"),
	red = preload("res://entities/bullets/red_bullet.tscn"),
	yellow = preload("res://entities/bullets/yellow_bullet.tscn"),
	blue = preload("res://entities/bullets/blue_bullet.tscn"),
}

var dialog_icons = {
	"Lario": "res://assets/portraits/main_character_portrait.png",
	"Ship": "res://assets/portraits/ship_portrait.png",
	"Guard": "res://assets/portraits/guard.png",
	"Sir or Madame": "res://assets/portraits/grandma.png",
}

var four_color_colors = {
	"green": Color.green,
	"red": Color.red,
	"yellow": Color.yellow,
	"blue": Color.blue,
}

var damage_values = {
	mummy_melee = 15,
	heather_spray = 20,
	mummy_shot = 10,
	gordon_shot = 25,
	the_gorgon_shot = 25,

	slime_puddle = 10,
	slime_ball = 6,
	t_arrow = 25,

	single_arrow = 10,
	yellow_bullet = 10,
	red_bullet = 10,
	green_bullet = 10,
	blue_bullet = 10,

	hurt_floor = 10,

	health_blob = 30,
	full_heal = INF,
	die = INF,

	default = 10
}

var gun_prices = {
	scanner = 0,
	four_color_green = 1,
	slime_gun = 2,
	four_color_blue = 2,
	four_color_red = 2,
	four_color_yellow = 2,
	t_gun = 4,
}

var four_color_gun_colors = {
	four_color_green = "green",
	four_color_blue = "blue",
	four_color_red = "red",
	four_color_yellow = "yellow",
}

var gun_unlock_order = [
	"scanner",
	"four_color_green",
	"slime_gun",
	"four_color_blue",
	"four_color_red",
	"four_color_yellow",
	"t_gun"
]

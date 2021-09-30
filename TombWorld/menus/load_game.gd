extends Control

onready var saves = $HBoxContainer/MarginContainer/VBoxContainer/scroll/saves
var slots = [ "slot_1_save", "slot_2_save", "slot_3_save" ]

func _ready():
	for slot in slots:
		if G.saves.save_exists(slot):
			get_node("HBoxContainer/MarginContainer/VBoxContainer/slots/%s/label" % slot).text = G.saves.get_save_friendly_name(slot)

func _slot_1_pressed(): G.saves.load_slot("slot_1_save")
func _slot_2_pressed(): G.saves.load_slot("slot_2_save")
func _slot_3_pressed(): G.saves.load_slot("slot_3_save")
	

func _on_back_pressed():
	G.load_menu("main_menu")

extends Control

signal team_name_entered

var _character_index : int = 0
var _name : String = ""

onready var _name_label : Label = $Panel/Name as Label


func _ready() -> void:
	($Panel/GridContainer/A as Button).grab_focus()


func on_a_pressed() -> void:
	_add_letter_to_name("A")


func on_b_pressed() -> void:
	_add_letter_to_name("B")


func on_c_pressed() -> void:
	_add_letter_to_name("C")


func on_d_pressed() -> void:
	_add_letter_to_name("D")


func on_e_pressed() -> void:
	_add_letter_to_name("E")


func on_f_pressed() -> void:
	_add_letter_to_name("F")


func on_g_pressed() -> void:
	_add_letter_to_name("G")


func on_h_pressed() -> void:
	_add_letter_to_name("H")


func on_i_pressed() -> void:
	_add_letter_to_name("I")


func on_j_pressed() -> void:
	_add_letter_to_name("J")


func on_k_pressed() -> void:
	_add_letter_to_name("K")


func on_l_pressed() -> void:
	_add_letter_to_name("L")


func on_m_pressed() -> void:
	_add_letter_to_name("M")


func on_n_pressed() -> void:
	_add_letter_to_name("N")


func on_o_pressed() -> void:
	_add_letter_to_name("O")


func on_p_pressed() -> void:
	_add_letter_to_name("P")


func on_q_pressed() -> void:
	_add_letter_to_name("Q")


func on_r_pressed() -> void:
	_add_letter_to_name("R")


func on_s_pressed() -> void:
	_add_letter_to_name("S")


func on_t_pressed() -> void:
	_add_letter_to_name("T")


func on_u_pressed() -> void:
	_add_letter_to_name("U")


func on_v_pressed() -> void:
	_add_letter_to_name("V")


func on_w_pressed() -> void:
	_add_letter_to_name("W")


func on_x_pressed() -> void:
	_add_letter_to_name("X")


func on_y_pressed() -> void:
	_add_letter_to_name("Y")


func on_z_pressed() -> void:
	_add_letter_to_name("Z")


func on_space_pressed() -> void:
	_add_letter_to_name(" ")


func on_delete_pressed() -> void:
	_remove_letter_from_name()


func on_done_pressed() -> void:
	emit_signal("team_name_entered", _name)


func _add_letter_to_name(letter : String) -> void:
	if _character_index < 14:
		_name += letter
		_character_index += 1
		_name_label.text = _name + "_"
	elif _character_index == 14:
		_name += letter
		_character_index += 1
		_name_label.text = _name


func _remove_letter_from_name() -> void:
	if _character_index != -1:
		_name.erase(_character_index, 1)
		_character_index -= 1
		
		_name_label.text = _name + "_"

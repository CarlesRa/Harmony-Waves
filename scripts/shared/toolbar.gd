extends PanelContainer

@onready var label: Label = %LevelLabel
@onready var snapsLabel: Label = %SnapsToWinLabel

var snaps_to_win
var current_snaps

func _ready() -> void:
	GameManager.connect("level_changed", _update_level_label)
	GameManager.connect("snaps_to_win_sign", _update_snaps_to_win_label)
	GameManager.connect("current_snaps_sign", _update_current_snaps_label)
	
func _update_level_label(label_text: String) -> void:
	if label_text:
		label.text = label_text
		return
	label.text = 'Level'

func _update_snaps_to_win_label(value: int) -> void:
	snaps_to_win = value
	snapsLabel.text = "Snaps to Win: %s of %s" % [current_snaps, snaps_to_win]
	
	
func _update_current_snaps_label(value: int) -> void:
	current_snaps = value
	snapsLabel.text = "Snaps to Win: %s of %s" % [current_snaps, snaps_to_win]
	

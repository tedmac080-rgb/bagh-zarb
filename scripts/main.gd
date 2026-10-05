extends Control

const SAVE_PATH := "user://progress.json"
const QUESTIONS := [
	{"a": 2, "b": 3, "answers": [6, 5, 8]},
	{"a": 2, "b": 4, "answers": [8, 6, 10]},
	{"a": 1, "b": 5, "answers": [5, 6, 4]},
	{"a": 2, "b": 5, "answers": [10, 8, 12]},
	{"a": 2, "b": 6, "answers": [12, 10, 14]}
]

var question_index := 0
var correct_count := 0
var attempts := 0
var mastery := 0.0
var retention := 0.0
var progress := 0
var question_label: Label
var feedback_label: Label
var garden_label: Label
var progress_bar: ProgressBar
var answer_box: VBoxContainer

func _ready() -> void:
	layout_direction = Control.LAYOUT_DIRECTION_RTL
	_load_progress()
	_build_ui()
	_show_question()

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color("#F7F0DD")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 54
	root.offset_right = -54
	root.offset_top = 70
	root.offset_bottom = -60
	root.add_theme_constant_override("separation", 28)
	add_child(root)

	var title := Label.new()
	title.text = "باغِ ضرب"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 52)
	title.add_theme_color_override("font_color", Color("#174A3A"))
	root.add_child(title)

	var companions := Label.new()
	companions.text = "شهرزاد و شهروز، خواهر و برادرِ باغبان"
	companions.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	companions.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	companions.add_theme_font_size_override("font_size", 25)
	companions.add_theme_color_override("font_color", Color("#5C5141"))
	root.add_child(companions)

	garden_label = Label.new()
	garden_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	garden_label.add_theme_font_size_override("font_size", 32)
	garden_label.add_theme_color_override("font_color", Color("#8A2F25"))
	root.add_child(garden_label)

	progress_bar = ProgressBar.new()
	progress_bar.min_value = 0
	progress_bar.max_value = 5
	progress_bar.value = progress
	progress_bar.show_percentage = false
	progress_bar.custom_minimum_size = Vector2(0, 34)
	root.add_child(progress_bar)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 40)
	root.add_child(spacer)

	question_label = Label.new()
	question_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	question_label.add_theme_font_size_override("font_size", 72)
	question_label.add_theme_color_override("font_color", Color("#173D34"))
	root.add_child(question_label)

	var hint := Label.new()
	hint.text = "به گروه‌ها فکر کن؛ عجله‌ای نیست."
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 25)
	hint.add_theme_color_override("font_color", Color("#6C705F"))
	root.add_child(hint)

	answer_box = VBoxContainer.new()
	answer_box.add_theme_constant_override("separation", 18)
	root.add_child(answer_box)

	feedback_label = Label.new()
	feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_label.add_theme_font_size_override("font_size", 30)
	feedback_label.add_theme_color_override("font_color", Color("#174A3A"))
	root.add_child(feedback_label)

	var footer := Label.new()
	footer.text = "هدهد راهنماست؛ اشتباه یعنی یک فرصت دیگر برای کشف."
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	footer.add_theme_font_size_override("font_size", 22)
	footer.add_theme_color_override("font_color", Color("#7A6A4E"))
	root.add_child(footer)
	_refresh_garden_text()

func _show_question() -> void:
	if question_index >= QUESTIONS.size():
		_finish_session()
		return
	for child in answer_box.get_children():
		child.queue_free()
	var q: Dictionary = QUESTIONS[question_index]
	question_label.text = "%d × %d = ؟" % [q.a, q.b]
	feedback_label.text = ""
	var answers: Array = q.answers.duplicate()
	answers.shuffle()
	for value in answers:
		var button := Button.new()
		button.text = str(value)
		button.custom_minimum_size = Vector2(0, 110)
		button.add_theme_font_size_override("font_size", 42)
		button.pressed.connect(_answer.bind(int(value), int(q.a) * int(q.b)))
		answer_box.add_child(button)

func _answer(value: int, expected: int) -> void:
	attempts += 1
	if value == expected:
		correct_count += 1
		mastery = min(100.0, mastery + 12.0)
		retention = min(100.0, retention + 6.0)
		progress = min(5, progress + 1)
		progress_bar.value = progress
		feedback_label.text = "آفرین! بخشی از باغ سیب جان گرفت 🌱"
		_refresh_garden_text()
		_save_progress()
		question_index += 1
		await get_tree().create_timer(0.8).timeout
		_show_question()
	else:
		mastery = max(0.0, mastery - 2.0)
		feedback_label.text = "یک بار دیگر نگاه کن؛ می‌توانی گروه‌ها را در ذهنت بسازی."
		_save_progress()

func _refresh_garden_text() -> void:
	var states := [
		"باغ سیب هنوز منتظر آب و شکوفه‌هاست",
		"جوی آب آرام به باغ رسید 💧",
		"جوانه‌ها بیدار شدند 🌱",
		"درخت‌ها سبزتر شدند 🌿",
		"سیب‌ها روی شاخه‌ها نشستند 🍎",
		"باغ سیب شکوفا شد؛ دروازه‌ی باغ هلو نزدیک است ✨"
	]
	garden_label.text = states[clampi(progress, 0, states.size() - 1)]

func _finish_session() -> void:
	question_label.text = "آفرین!"
	for child in answer_box.get_children():
		child.queue_free()
	feedback_label.text = "امروز باغ سیب را آبادتر کردی. آموخته‌ها در روزهای بعد دوباره برمی‌گردند تا در ذهنت ماندگار شوند."
	var restart := Button.new()
	restart.text = "مرور دوباره"
	restart.custom_minimum_size = Vector2(0, 110)
	restart.add_theme_font_size_override("font_size", 34)
	restart.pressed.connect(_restart_session)
	answer_box.add_child(restart)

func _restart_session() -> void:
	question_index = 0
	correct_count = 0
	attempts = 0
	_show_question()

func _save_progress() -> void:
	var data := {
		"version": 1,
		"garden": "apple_garden",
		"garden_progress": progress,
		"mastery": mastery,
		"retention": retention,
		"last_session_unix": int(Time.get_unix_time_from_system())
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))

func _load_progress() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		progress = int(parsed.get("garden_progress", 0))
		mastery = float(parsed.get("mastery", 0.0))
		retention = float(parsed.get("retention", 0.0))

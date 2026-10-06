extends Control

const SAVE_PATH := "user://bagh_zarb_product_slice.json"
const CREAM := Color("#fff6df")
const INK := Color("#173f35")
const TEAL := Color("#087a7c")
const GOLD := Color("#e4b84e")
const ORANGE := Color("#ee8a2d")
const RED := Color("#c83e42")
const GREEN := Color("#4f9857")

var state := {"stage":0,"shamsehs":0,"garden_awake":false,"festival_unlocked":false}
var layer: Control
var feedback: Label
var task_title: Label
var apples_placed := 0
var basket_counts := [0,0,0]
var target_each := 2
var rng := RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	load_state()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	show_home()

func clear_screen():
	for c in get_children():
		c.queue_free()
	layer = Control.new()
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(layer)

func add_background():
	var bg=TextureRect.new()
	bg.texture=load("res://assets/apple_garden.svg")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED
	layer.add_child(bg)
	var veil=ColorRect.new()
	veil.color=Color(0.04,0.12,0.08,0.08)
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(veil)

func panel_style(color:Color=CREAM, radius:=28, border:=Color("#d8ad52")):
	var s=StyleBoxFlat.new()
	s.bg_color=color
	s.corner_radius_top_left=radius; s.corner_radius_top_right=radius
	s.corner_radius_bottom_left=radius; s.corner_radius_bottom_right=radius
	s.border_width_left=3; s.border_width_right=3; s.border_width_top=3; s.border_width_bottom=3
	s.border_color=border
	s.shadow_color=Color(0,0,0,.18); s.shadow_size=10; s.shadow_offset=Vector2(0,7)
	s.content_margin_left=24; s.content_margin_right=24; s.content_margin_top=16; s.content_margin_bottom=16
	return s

func make_label(text:String, size_px:int, color:Color=INK):
	var l=Label.new()
	l.text=text
	l.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size",size_px)
	l.add_theme_color_override("font_color",color)
	l.layout_direction=Control.LAYOUT_DIRECTION_RTL
	return l

func make_button(text:String, cb:Callable, color:=ORANGE):
	var b=Button.new()
	b.text=text
	b.custom_minimum_size=Vector2(300,76)
	b.add_theme_font_size_override("font_size",28)
	b.add_theme_color_override("font_color",Color.WHITE)
	b.add_theme_stylebox_override("normal",panel_style(color,24,Color("#f7d06a")))
	b.add_theme_stylebox_override("hover",panel_style(color.lightened(.08),24,Color.WHITE))
	b.add_theme_stylebox_override("pressed",panel_style(color.darkened(.08),24,GOLD))
	b.pressed.connect(cb)
	return b

func show_home():
	clear_screen()
	add_background()
	var logo=TextureRect.new()
	logo.texture=load("res://assets/logo.svg")
	logo.position=Vector2(580,55); logo.size=Vector2(760,260)
	logo.expand_mode=TextureRect.EXPAND_IGNORE_SIZE; logo.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	layer.add_child(logo)

	var card=PanelContainer.new()
	card.position=Vector2(610,315); card.size=Vector2(700,610)
	card.add_theme_stylebox_override("panel",panel_style(Color("#fff7e7e8"),36,GOLD))
	layer.add_child(card)
	var box=VBoxContainer.new(); box.alignment=BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation",18); card.add_child(box)
	var welcome=make_label("شهروز و شهرزاد منتظر تو هستند",27)
	box.add_child(welcome)
	var garden=make_label("🍎  باغ سیب",42,TEAL); box.add_child(garden)
	var sub=make_label("گروه‌های برابر را بساز و باغ را بیدار کن",22); box.add_child(sub)
	var play=make_button("شروع بازی",func(): start_garden(),ORANGE); play.size_flags_horizontal=Control.SIZE_SHRINK_CENTER; box.add_child(play)
	var mapb=make_button("باغ‌های من",func(): show_map(),TEAL); mapb.size_flags_horizontal=Control.SIZE_SHRINK_CENTER; box.add_child(mapb)
	var fest=make_button("جشن باغ",func(): show_festival(),Color("#9a6cb1")); fest.size_flags_horizontal=Control.SIZE_SHRINK_CENTER
	fest.disabled=!bool(state["festival_unlocked"]); box.add_child(fest)
	var stats=make_label("شمسه‌ها  ✦  "+str(state["shamsehs"])+"        پیشرفت باغ  "+str(min(100,int(state["stage"])*25))+"٪",20)
	box.add_child(stats)

	var bird=TextureRect.new(); bird.texture=load("res://assets/hoopoe.svg")
	bird.position=Vector2(1360,140); bird.size=Vector2(220,180); bird.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	layer.add_child(bird)

func show_map():
	clear_screen(); add_background()
	var p=PanelContainer.new(); p.position=Vector2(180,100); p.size=Vector2(1560,850)
	p.add_theme_stylebox_override("panel",panel_style(Color("#fff9ebf2"),34,GOLD)); layer.add_child(p)
	var vb=VBoxContainer.new(); vb.add_theme_constant_override("separation",18); p.add_child(vb)
	vb.add_child(make_label("باغ‌های من",44,TEAL))
	vb.add_child(make_label("هر باغ یک مهارت تازه؛ هر دروازه یک ماجرای جدید",21))
	var grid=GridContainer.new(); grid.columns=4; grid.add_theme_constant_override("h_separation",18); grid.add_theme_constant_override("v_separation",18); vb.add_child(grid)
	var names=["🍎\nباغ سیب","🍑\nباغ هلو","🔴\nباغ انار","🍇\nباغ انگور","🍊\nباغ نارنج","🌹\nباغ گل محمدی","🌸\nباغ زعفران","✨\nباغ هزاررنگ"]
	for i in range(8):
		var b=Button.new(); b.text=names[i]; b.custom_minimum_size=Vector2(350,220); b.add_theme_font_size_override("font_size",26)
		b.add_theme_stylebox_override("normal",panel_style(Color("#fff3d7"),24,GOLD))
		b.disabled=i>0
		grid.add_child(b)
	var back=make_button("بازگشت",func(): show_home(),TEAL); back.size_flags_horizontal=Control.SIZE_SHRINK_CENTER; vb.add_child(back)

func start_garden():
	clear_screen(); add_background()
	build_hud()
	var card=PanelContainer.new(); card.position=Vector2(460,120); card.size=Vector2(1000,170)
	card.add_theme_stylebox_override("panel",panel_style(Color("#fff8eaf2"),28,GOLD)); layer.add_child(card)
	var vb=VBoxContainer.new(); vb.alignment=BoxContainer.ALIGNMENT_CENTER; card.add_child(vb)
	task_title=make_label("بساز",34,TEAL); vb.add_child(task_title)
	vb.add_child(make_label("۳ سبد بساز؛ در هر سبد دقیقاً ۲ سیب بگذار",25))
	vb.add_child(make_label("اول گروه‌ها را می‌سازیم؛ بعد خودِ ضرب را کشف می‌کنیم.",18,Color("#58665e")))
	
	var work=PanelContainer.new(); work.position=Vector2(260,330); work.size=Vector2(1400,560)
	work.add_theme_stylebox_override("panel",panel_style(Color("#fdf3d7dd"),34,Color("#c89b46"))); layer.add_child(work)
	var wb=VBoxContainer.new(); wb.add_theme_constant_override("separation",12); work.add_child(wb)
	var source=HBoxContainer.new(); source.alignment=BoxContainer.ALIGNMENT_CENTER; source.add_theme_constant_override("separation",14); wb.add_child(source)
	var hint=make_label("یک سیب بردار، بعد سبد مقصد را لمس کن",20); source.add_child(hint)
	var apple=TextureButton.new(); apple.texture_normal=load("res://assets/apple.svg"); apple.custom_minimum_size=Vector2(95,95)
	apple.ignore_texture_size=true; apple.stretch_mode=TextureButton.STRETCH_KEEP_ASPECT_CENTERED; source.add_child(apple)
	
	var baskets=HBoxContainer.new(); baskets.alignment=BoxContainer.ALIGNMENT_CENTER; baskets.add_theme_constant_override("separation",55); wb.add_child(baskets)
	for i in range(3):
		baskets.add_child(make_basket(i))
	feedback=make_label("هدهد: گروه‌های برابر یعنی همه‌ی سبدها به یک اندازه پُر شوند.",20,INK)
	wb.add_child(feedback)
	var reset=make_button("از نو",func(): reset_baskets(),TEAL); reset.custom_minimum_size=Vector2(180,58); reset.size_flags_horizontal=Control.SIZE_SHRINK_CENTER; wb.add_child(reset)

func build_hud():
	var home=make_button("خانه",func(): show_home(),TEAL); home.position=Vector2(38,30); home.size=Vector2(150,58); home.custom_minimum_size=Vector2(150,58); layer.add_child(home)
	var badge=PanelContainer.new(); badge.position=Vector2(1510,30); badge.size=Vector2(360,70); badge.add_theme_stylebox_override("panel",panel_style(Color("#fff6d9ee"),24,GOLD)); layer.add_child(badge)
	badge.add_child(make_label("✦  "+str(state["shamsehs"])+"     باغ سیب",22,INK))
	var dots=make_label("●  ○  ○  ○",24,GOLD); dots.position=Vector2(820,38); dots.size=Vector2(280,55); layer.add_child(dots)

func make_basket(idx:int):
	var p=PanelContainer.new(); p.custom_minimum_size=Vector2(340,330); p.add_theme_stylebox_override("panel",panel_style(Color("#fffaf0e8"),26,Color("#c79747")))
	var vb=VBoxContainer.new(); vb.alignment=BoxContainer.ALIGNMENT_CENTER; p.add_child(vb)
	var img=TextureRect.new(); img.texture=load("res://assets/basket.svg"); img.custom_minimum_size=Vector2(300,180); img.expand_mode=TextureRect.EXPAND_IGNORE_SIZE; img.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED; vb.add_child(img)
	var count=make_label(apples_text(basket_counts[idx]),31,RED); count.name="Count"; vb.add_child(count)
	var b=make_button("سبد "+str(idx+1),func(): add_to_basket(idx),TEAL); b.custom_minimum_size=Vector2(220,58); vb.add_child(b)
	p.name="Basket"+str(idx)
	return p

func apples_text(n:int):
	if n==0: return "خالی"
	return "🍎 ".repeat(n)

func add_to_basket(idx:int):
	if basket_counts[idx] >= target_each:
		feedback.text="این سبد کامل است؛ یک سبد دیگر را انتخاب کن."
		return
	basket_counts[idx]+=1
	var p=layer.find_child("Basket"+str(idx),true,false)
	if p:
		var c=p.find_child("Count",true,false)
		if c: c.text=apples_text(basket_counts[idx])
	if basket_counts[0]==2 and basket_counts[1]==2 and basket_counts[2]==2:
		state["shamsehs"]=int(state["shamsehs"])+1
		state["stage"]=max(1,int(state["stage"]))
		save_state()
		feedback.text="آفرین! ۳ گروهِ ۲تایی ساختی. حالا ببین این یعنی چه ضربی."
		await get_tree().create_timer(.8).timeout
		show_bridge()

func reset_baskets():
	basket_counts=[0,0,0]
	start_garden()

func show_bridge():
	clear_screen(); add_background(); build_hud()
	var bird=TextureRect.new(); bird.texture=load("res://assets/hoopoe.svg"); bird.position=Vector2(1420,190); bird.size=Vector2(240,200); bird.expand_mode=TextureRect.EXPAND_IGNORE_SIZE; layer.add_child(bird)
	var p=PanelContainer.new(); p.position=Vector2(610,155); p.size=Vector2(700,420); p.add_theme_stylebox_override("panel",panel_style(Color("#fff8eae8"),34,GOLD)); layer.add_child(p)
	var vb=VBoxContainer.new(); vb.alignment=BoxContainer.ALIGNMENT_CENTER; vb.add_theme_constant_override("separation",16); p.add_child(vb)
	vb.add_child(make_label("کشف کردی!",34,TEAL))
	vb.add_child(make_label("۲ + ۲ + ۲ = ۶",42,INK))
	vb.add_child(make_label("۳ × ۲ = ۶",56,RED))
	vb.add_child(make_label("جوی آب دوباره جان گرفت ✨",22,GREEN))
	var next=make_button("ادامه در باغ",func(): show_find(),ORANGE); next.size_flags_horizontal=Control.SIZE_SHRINK_CENTER; vb.add_child(next)

func show_find():
	clear_screen(); add_background(); build_hud()
	# Compact storybook ribbon: the garden remains the hero.
	var ribbon=PanelContainer.new(); ribbon.position=Vector2(535,105); ribbon.size=Vector2(850,150)
	ribbon.add_theme_stylebox_override("panel",panel_style(Color("#fff7e5e8"),30,GOLD)); layer.add_child(ribbon)
	var rv=VBoxContainer.new(); rv.alignment=BoxContainer.ALIGNMENT_CENTER; ribbon.add_child(rv)
	rv.add_child(make_label("پیدا کن",30,TEAL))
	rv.add_child(make_label("۴ × ۲",48,INK))
	rv.add_child(make_label("روی سنگی بپر که جواب درست روی آن است",18))
	# Answer stones live inside the water channel, not in a quiz popup.
	var values=[6,8,10]
	var xs=[690,910,1130]
	for i in range(3):
		var stone=Button.new()
		stone.text=str(values[i]); stone.position=Vector2(xs[i],610); stone.size=Vector2(180,105)
		stone.add_theme_font_size_override("font_size",34)
		stone.add_theme_color_override("font_color",INK)
		stone.add_theme_stylebox_override("normal",panel_style(Color("#f4dfad"),50,Color("#b68747")))
		stone.add_theme_stylebox_override("hover",panel_style(Color("#fff1c7"),50,GOLD))
		var v=values[i]; stone.pressed.connect(func(): check_find(v)); layer.add_child(stone)
	var bird=TextureRect.new(); bird.texture=load("res://assets/hoopoe.svg"); bird.position=Vector2(1420,225); bird.size=Vector2(230,190); bird.expand_mode=TextureRect.EXPAND_IGNORE_SIZE; layer.add_child(bird)
	feedback=make_label("هدهد: چهار گروهِ دوتایی را در باغ پیدا کن.",21,CREAM)
	feedback.position=Vector2(620,800); feedback.size=Vector2(680,70); layer.add_child(feedback)

func check_find(v:int):
	if v==8:
		state["shamsehs"]=int(state["shamsehs"])+1; state["stage"]=max(2,int(state["stage"])); save_state()
		feedback.text="درست است! ۲ + ۲ + ۲ + ۲ = ۸"
		await get_tree().create_timer(.7).timeout
		show_complete()
	else:
		feedback.text="هنوز نه. چهار گروه درست کن و در هر گروه فقط ۲ سیب بگذار."

func show_complete():
	clear_screen(); add_background(); build_hud()
	var p=PanelContainer.new(); p.position=Vector2(430,180); p.size=Vector2(1060,700); p.add_theme_stylebox_override("panel",panel_style(Color("#fff8eaf2"),38,GOLD)); layer.add_child(p)
	var vb=VBoxContainer.new(); vb.alignment=BoxContainer.ALIGNMENT_CENTER; vb.add_theme_constant_override("separation",20); p.add_child(vb)
	vb.add_child(make_label("کامل کن",38,TEAL))
	vb.add_child(make_label("۵ × ۲ = ۱۰",36,GREEN))
	vb.add_child(make_label("یک گروهِ ۲تایی دیگر اضافه کن",23))
	vb.add_child(make_label("۶ × ۲ = ۱۰ + ۲ = ؟",52,INK))
	var row=HBoxContainer.new(); row.alignment=BoxContainer.ALIGNMENT_CENTER; row.add_theme_constant_override("separation",24); vb.add_child(row)
	for n in [10,12,14]:
		var b=make_button(str(n),func(v=n): check_complete(v),ORANGE); b.custom_minimum_size=Vector2(190,90); row.add_child(b)
	feedback=make_label("از چیزی که بلدی، جواب تازه را بساز.",20); vb.add_child(feedback)

func check_complete(v:int):
	if v==12:
		state["shamsehs"]=int(state["shamsehs"])+1; state["stage"]=4; state["garden_awake"]=true; state["festival_unlocked"]=true; save_state()
		show_awake()
	else:
		feedback.text="به ۱۰ فقط یک گروهِ ۲تایی اضافه می‌کنیم."

func show_awake():
	clear_screen(); add_background()
	var glow=ColorRect.new(); glow.color=Color(1,.82,.25,.12); glow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); layer.add_child(glow)
	var p=PanelContainer.new(); p.position=Vector2(560,230); p.size=Vector2(800,560); p.add_theme_stylebox_override("panel",panel_style(Color("#fff8eaf0"),42,GOLD)); layer.add_child(p)
	var vb=VBoxContainer.new(); vb.alignment=BoxContainer.ALIGNMENT_CENTER; vb.add_theme_constant_override("separation",20); p.add_child(vb)
	vb.add_child(make_label("باغ بیدار شد!",52,TEAL))
	vb.add_child(make_label("🌿  💧  🍎  🐦",54))
	vb.add_child(make_label("آب جاری شد، سیب‌ها برگشتند و هدهد دوباره آواز خواند.",24))
	vb.add_child(make_label("۳ شمسه برای یادگیری امروز",23,GOLD))
	var fest=make_button("جشن باغ",func(): show_festival(),Color("#9a6cb1")); fest.size_flags_horizontal=Control.SIZE_SHRINK_CENTER; vb.add_child(fest)
	var home=make_button("بازگشت به خانه",func(): show_home(),TEAL); home.size_flags_horizontal=Control.SIZE_SHRINK_CENTER; vb.add_child(home)

func show_festival():
	clear_screen(); add_background()
	var p=PanelContainer.new(); p.position=Vector2(480,180); p.size=Vector2(960,700); p.add_theme_stylebox_override("panel",panel_style(Color("#fff5e7f2"),40,Color("#b47bc4"))); layer.add_child(p)
	var vb=VBoxContainer.new(); vb.alignment=BoxContainer.ALIGNMENT_CENTER; vb.add_theme_constant_override("separation",22); p.add_child(vb)
	vb.add_child(make_label("جشن این هفته",46,Color("#82539a")))
	vb.add_child(make_label("یادآوری کوتاه؛ بدون باخت و بدون عجله",22))
	vb.add_child(make_label("۷ × ۲ = ؟",58,INK))
	var row=HBoxContainer.new(); row.alignment=BoxContainer.ALIGNMENT_CENTER; row.add_theme_constant_override("separation",20); vb.add_child(row)
	for n in [12,14,16]:
		var b=make_button(str(n),func(v=n): festival_answer(v),Color("#9a6cb1")); b.custom_minimum_size=Vector2(180,86); row.add_child(b)
	feedback=make_label("اول از حافظه جواب بده؛ اگر لازم شد هدهد کمک می‌کند.",19); vb.add_child(feedback)

func festival_answer(v:int):
	if v==14:
		feedback.text="آفرین! یادگار این هفته: آبنمای کاشی‌کاری ✨"
		state["shamsehs"]=int(state["shamsehs"])+1; save_state()
	else:
		feedback.text="هدهد می‌گوید: هفت گروهِ دوتایی را آرام بشمار."

func save_state():
	var f=FileAccess.open(SAVE_PATH,FileAccess.WRITE)
	if f: f.store_string(JSON.stringify(state))

func load_state():
	if FileAccess.file_exists(SAVE_PATH):
		var f=FileAccess.open(SAVE_PATH,FileAccess.READ)
		var parsed=JSON.parse_string(f.get_as_text())
		if typeof(parsed)==TYPE_DICTIONARY: state.merge(parsed,true)

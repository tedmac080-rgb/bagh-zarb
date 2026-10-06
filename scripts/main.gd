extends Control

const SAVE_PATH := "user://bagh_zarb_v2.json"
const CREAM := Color("#F8F0D8")
const INK := Color("#173F35")
const GOLD := Color("#D8A943")
const PANEL := Color("#FFF9E9")
const WATER := Color("#55B8C6")
const GREEN := Color("#4D8B58")
const DARK_GREEN := Color("#24533D")
const SOFT_RED := Color("#B9504E")

const GARDENS := [
	{"name":"باغ سیب","emoji":"🍎","accent":"#B9504E","tables":[1,2],"desc":"گروه‌های برابر و ضرب‌های ۱ و ۲"},
	{"name":"باغ هلو","emoji":"🍑","accent":"#E99B7A","tables":[5,10],"desc":"ضرب‌های لنگر ۵ و ۱۰"},
	{"name":"باغ انار","emoji":"🔴","accent":"#9D343C","tables":[3,4],"desc":"ساختن ضرب‌های ۳ و ۴"},
	{"name":"باغ انگور","emoji":"🍇","accent":"#76578F","tables":[6],"desc":"ضرب ۶ و ساختن از دانسته‌ها"},
	{"name":"باغ نارنج","emoji":"🍊","accent":"#D98235","tables":[9],"desc":"ضرب ۹ و مرور ترکیبی"},
	{"name":"باغ گل محمدی","emoji":"🌹","accent":"#C16B82","tables":[7],"desc":"ضرب ۷ با راهبرد"},
	{"name":"باغ زعفران","emoji":"🌸","accent":"#7C5A9A","tables":[8],"desc":"ضرب ۸ و مرور پیشرفته"},
	{"name":"باغ هزاررنگ","emoji":"✨","accent":"#C69C42","tables":[2,3,4,5,6,7,8,9,10],"desc":"تسلط ترکیبی همه‌ی باغ‌ها"}
]

var state := {"garden":0,"stage":0,"mastery":{},"retention":{},"keepsakes":[],"shamsehs":0}
var rng := RandomNumberGenerator.new()
var current_question := {}
var mode := "home"
var root_box: VBoxContainer
var garden_canvas: Control
var content_box: VBoxContainer
var feedback: Label
var progress_label: Label

class GardenCanvas:
	extends Control
	var level := 0
	var garden_index := 0
	var accent := Color("#B9504E")
	func _draw():
		var w=size.x; var h=size.y
		draw_rect(Rect2(0,0,w,h), Color("#DCEAC8"))
		draw_rect(Rect2(0,h*0.68,w,h*0.32), Color("#B9D49B"))
		# distant Iranian garden wall
		draw_rect(Rect2(0,h*0.13,w,h*0.12), Color("#E8D6AF"))
		for x in range(30,int(w),150):
			draw_circle(Vector2(x,h*0.13),22,Color("#E8D6AF"))
		# central Persian gate
		var gx=w*0.5
		draw_rect(Rect2(gx-72,h*0.05,144,h*0.22),Color("#D6B77E"))
		draw_circle(Vector2(gx,h*0.14),48,Color("#5FA8A0"))
		draw_rect(Rect2(gx-42,h*0.14,84,h*0.13),Color("#6E4E36"))
		# water channel becomes alive
		var wc = WATER if level>=1 else Color("#A8B8AE")
		draw_polygon(PackedVector2Array([Vector2(w*.44,h*.27),Vector2(w*.56,h*.27),Vector2(w*.62,h),Vector2(w*.38,h)]),PackedColorArray([wc]))
		# trees
		for i in range(8):
			var side=-1 if i%2==0 else 1
			var row=i/2
			var px=gx+side*(150+row*95)
			var py=h*.38+row*52
			draw_rect(Rect2(px-8,py+30,16,62),Color("#79543B"))
			var leaf=Color("#7B9871") if level==0 else GREEN
			draw_circle(Vector2(px,py+18),54,leaf)
			draw_circle(Vector2(px-30,py+32),34,leaf)
			draw_circle(Vector2(px+30,py+32),34,leaf)
			if level>=2:
				for k in range(5):
					var a=float(k)*1.256
					draw_circle(Vector2(px+cos(a)*30,py+22+sin(a)*25),7,accent)
		# flower beds / birds at higher restoration
		if level>=3:
			for x in range(70,int(w)-40,95):
				draw_circle(Vector2(x,h*.86),8,Color("#E8A5B6"))
				draw_circle(Vector2(x+14,h*.87),7,Color("#F2C36B"))
		if level>=4:
			for x in [w*.25,w*.72]:
				draw_arc(Vector2(x,h*.24),18,3.4,5.9,12,DARK_GREEN,3)
				draw_arc(Vector2(x+32,h*.24),18,3.4,5.9,12,DARK_GREEN,3)
	func configure(idx:int, restoration:int):
		garden_index=idx; level=restoration
		accent=Color(GARDENS[idx]["accent"])
		queue_redraw()

func _ready():
	rng.randomize()
	load_state()
	build_shell()
	show_home()

func build_shell():
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg=ColorRect.new(); bg.color=CREAM; bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); add_child(bg)
	var margin=MarginContainer.new(); margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left",36); margin.add_theme_constant_override("margin_right",36)
	margin.add_theme_constant_override("margin_top",24); margin.add_theme_constant_override("margin_bottom",24); add_child(margin)
	root_box=VBoxContainer.new(); root_box.add_theme_constant_override("separation",16); margin.add_child(root_box)

func clear_root():
	for c in root_box.get_children(): c.queue_free()

func title(text:String, size_px:=36):
	var l=Label.new(); l.text=text; l.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size",size_px); l.add_theme_color_override("font_color",INK); return l

func body(text:String, size_px:=22):
	var l=Label.new(); l.text=text; l.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; l.add_theme_font_size_override("font_size",size_px)
	l.add_theme_color_override("font_color",Color("#4D554D")); return l

func button(text:String, cb:Callable, min_h:=68):
	var b=Button.new(); b.text=text; b.custom_minimum_size=Vector2(0,min_h)
	b.add_theme_font_size_override("font_size",24); b.add_theme_color_override("font_color",INK)
	b.pressed.connect(cb); return b

func show_home():
	mode="home"; clear_root()
	root_box.add_child(title("باغ ضرب",48))
	root_box.add_child(body("ماجرای شهروز و شهرزاد؛ خواهر و برادر باغبان"))
	var canvas=GardenCanvas.new(); canvas.custom_minimum_size=Vector2(0,430); root_box.add_child(canvas)
	canvas.configure(int(state["garden"]),min(4,int(state["stage"])))
	var g=GARDENS[int(state["garden"])]
	root_box.add_child(title(str(g["emoji"])+"  "+str(g["name"]),32))
	root_box.add_child(body(str(g["desc"])))
	root_box.add_child(button("ادامه‌ی ماجرا",func(): start_garden()))
	var row=HBoxContainer.new(); row.add_theme_constant_override("separation",12); root_box.add_child(row)
	var mapb=button("باغ‌های من",func(): show_map(),58); mapb.size_flags_horizontal=Control.SIZE_EXPAND_FILL; row.add_child(mapb)
	var fest=button("جشن باغ",func(): start_festival(),58); fest.size_flags_horizontal=Control.SIZE_EXPAND_FILL; row.add_child(fest)
	root_box.add_child(body("شمسه‌ها: "+str(state["shamsehs"])+"   •   یادگارهای باغ: "+str(state["keepsakes"].size()),18))

func show_map():
	mode="map"; clear_root(); root_box.add_child(title("باغ‌های من",40))
	var grid=GridContainer.new(); grid.columns=4; grid.size_flags_vertical=Control.SIZE_EXPAND_FILL; root_box.add_child(grid)
	for i in range(GARDENS.size()):
		var unlocked=i<=int(state["garden"])
		var g=GARDENS[i]
		var txt=str(g["emoji"])+"\n"+str(g["name"])+"\n"+("آباد شده" if i<int(state["garden"]) else ("در حال یادگیری" if unlocked else "قفل"))
		var b=button(txt,func(idx=i): select_garden(idx),120)
		b.disabled=!unlocked; b.size_flags_horizontal=Control.SIZE_EXPAND_FILL; grid.add_child(b)
	root_box.add_child(button("بازگشت",func(): show_home(),58))

func select_garden(idx:int):\n\tif idx<=int(state["garden"]):\n\t\tstate["garden"]=idx\n\t\tstate["stage"]=0\n\t\tsave_state()\n\t\tstart_garden()\n\nfunc start_garden():
	mode="garden"; clear_root()
	var gi=int(state["garden"]); var g=GARDENS[gi]
	var top=HBoxContainer.new(); root_box.add_child(top)
	var back=button("‹ خانه",func(): show_home(),52); top.add_child(back)
	var tl=title(str(g["emoji"])+" "+str(g["name"]),34); tl.size_flags_horizontal=Control.SIZE_EXPAND_FILL; top.add_child(tl)
	progress_label=body("",18); top.add_child(progress_label)
	garden_canvas=GardenCanvas.new(); garden_canvas.custom_minimum_size=Vector2(0,390); root_box.add_child(garden_canvas)
	garden_canvas.configure(gi,min(4,int(state["stage"])))
	content_box=VBoxContainer.new(); content_box.add_theme_constant_override("separation",12); root_box.add_child(content_box)
	feedback=body("شهروز و شهرزاد منتظرند باغ را با ضرب‌ها بیدار کنی.",19); root_box.add_child(feedback)
	next_activity()

func next_activity():
	for c in content_box.get_children(): c.queue_free()
	var stage=int(state["stage"]); var gi=int(state["garden"])
	progress_label.text="بخش "+str(stage+1)+" از ۵"
	if stage>=5:
		complete_garden(); return
	var kind=["build","find","build","complete","find"][stage]
	current_question=make_question(gi,kind)
	if kind=="build": render_build()
	elif kind=="complete": render_complete()
	else: render_find()

func make_question(gi:int, kind:String):
	var tables:Array=GARDENS[gi]["tables"]; var a=int(tables[rng.randi_range(0,tables.size()-1)])
	var b=rng.randi_range(2,9)
	return {"a":a,"b":b,"answer":a*b,"kind":kind,"tries":0}

func render_build():
	var a=int(current_question["a"]); var b=int(current_question["b"])
	content_box.add_child(title("بساز: "+str(a)+" گروهِ "+str(b)+"تایی",28))
	content_box.add_child(body("سیب‌ها را بشمار؛ هر سبد یک گروه برابر است.",18))
	var groups=HBoxContainer.new(); groups.alignment=BoxContainer.ALIGNMENT_CENTER; groups.add_theme_constant_override("separation",14); content_box.add_child(groups)
	for i in range(a):
		var box=PanelContainer.new(); var vb=VBoxContainer.new(); box.add_child(vb)
		var apples=Label.new(); apples.text="● ".repeat(b); apples.add_theme_font_size_override("font_size",25); apples.add_theme_color_override("font_color",SOFT_RED)
		vb.add_child(apples); var gl=body(str(b),16); vb.add_child(gl); groups.add_child(box)
	var answers=make_choices(a*b,[a*b-b,a*b+b]); content_box.add_child(answers)

func render_find():
	var a=int(current_question["a"]); var b=int(current_question["b"])
	content_box.add_child(title("پیدا کن",25))
	content_box.add_child(title(str(a)+" × "+str(b)+" = ؟",44))
	content_box.add_child(make_choices(a*b,[a*b-a,a*b+b]))

func render_complete():
	var a=int(current_question["a"]); var b=int(current_question["b"]); var anchor=max(1,b-1)
	content_box.add_child(title("کامل کن",25))
	content_box.add_child(body(str(a)+" × "+str(anchor)+" = "+str(a*anchor)+"  را می‌دانی.",20))
	content_box.add_child(title(str(a)+" × "+str(b)+" = "+str(a*anchor)+" + "+str(a)+" = ؟",36))
	content_box.add_child(make_choices(a*b,[a*anchor,a*b+a]))

func make_choices(correct:int, distractors:Array):
	var row=HBoxContainer.new(); row.alignment=BoxContainer.ALIGNMENT_CENTER; row.add_theme_constant_override("separation",18)
	var vals=[correct,int(distractors[0]),int(distractors[1])]; vals.shuffle()
	for v in vals:
		var b=button(str(v),func(value=v): answer(value),70); b.custom_minimum_size.x=170; row.add_child(b)
	return row

func answer(value:int):
	var correct=int(current_question["answer"]); var key=str(current_question["a"])+"x"+str(current_question["b"])
	current_question["tries"]=int(current_question["tries"])+1
	if value==correct:
		var independent=int(current_question["tries"])==1
		var old=float(state["mastery"].get(key,0))
		state["mastery"][key]=min(100.0,old+(18.0 if independent else 8.0))
		if independent: state["retention"][key]=min(100.0,float(state["retention"].get(key,0))+10.0)
		state["shamsehs"]=int(state["shamsehs"])+1
		feedback.text="آفرین! با این ضرب، باغ کمی زنده‌تر شد."
		state["stage"]=int(state["stage"])+1; save_state()
		garden_canvas.configure(int(state["garden"]),min(4,int(state["stage"])))
		await get_tree().create_timer(0.65).timeout
		next_activity()
	else:
		feedback.text="هنوز نه؛ اشکالی ندارد. به گروه‌ها نگاه کن و دوباره بساز."
		if int(current_question["tries"])>=2:
			feedback.text="راهنمای هدهد: "+str(current_question["a"])+" گروه داریم و در هر گروه "+str(current_question["b"])+" تاست؛ آرام بشمار."

func complete_garden():
	for c in content_box.get_children(): c.queue_free()
	garden_canvas.configure(int(state["garden"]),4)
	content_box.add_child(title("باغ آباد شد! ✨",36))
	if int(state["garden"])<GARDENS.size()-1:
		var nxt=GARDENS[int(state["garden"])+1]
		content_box.add_child(body("دروازه باز شد؛ آن‌طرف "+str(nxt["emoji"])+" "+str(nxt["name"])+" منتظر توست.",22))
		content_box.add_child(button("عبور از دروازه",func(): state["garden"]=int(state["garden"])+1; state["stage"]=0; save_state(); start_garden()))
	else:
		content_box.add_child(body("تو همه‌ی باغ‌ها را بیدار کردی. حالا جشن هزاررنگ آماده است.",22))
		content_box.add_child(button("جشن نهایی",func(): start_festival()))
	content_box.add_child(button("بازگشت به خانه",func(): show_home(),54))

var festival_left:=0
func start_festival():
	mode="festival"; festival_left=8; clear_root(); root_box.add_child(title("جشن باغ 🎐",42))
	root_box.add_child(body("۸ یادآوری کوتاه از باغ‌های قبلی؛ بدون عجله و بدون باخت.",20))
	content_box=VBoxContainer.new(); content_box.add_theme_constant_override("separation",14); root_box.add_child(content_box)
	feedback=body("",19); root_box.add_child(feedback); festival_question()

func festival_question():
	for c in content_box.get_children(): c.queue_free()
	if festival_left<=0:
		var keeps=["چراغ ایرانی","آشیانه‌ی هدهد","نیمکت کاشی‌کاری","کوزه‌ی باغ","آبنمای کوچک"]
		var prize=keeps[rng.randi_range(0,keeps.size()-1)]
		if !state["keepsakes"].has(prize): state["keepsakes"].append(prize)
		save_state(); content_box.add_child(title("یادگار این جشن: "+prize+" ✨",32)); content_box.add_child(button("دیدن باغ‌ها",func(): show_map())); return
	var max_g=int(state["garden"]); var gi=rng.randi_range(0,max_g)
	current_question=make_question(gi,"festival")
	content_box.add_child(body("یادآوری "+str(9-festival_left)+" از ۸",18))
	content_box.add_child(title(str(current_question["a"])+" × "+str(current_question["b"])+" = ؟",44))
	content_box.add_child(make_choices(int(current_question["answer"]),[int(current_question["answer"])-int(current_question["a"]),int(current_question["answer"])+int(current_question["b"])]))

func save_state():
	var file=FileAccess.open(SAVE_PATH,FileAccess.WRITE)
	if file: file.store_string(JSON.stringify(state))

func load_state():
	if FileAccess.file_exists(SAVE_PATH):
		var file=FileAccess.open(SAVE_PATH,FileAccess.READ)
		var parsed=JSON.parse_string(file.get_as_text())
		if typeof(parsed)==TYPE_DICTIONARY: state.merge(parsed,true)

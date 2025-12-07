extends GPUParticles3D

@export var anim: AnimationPlayer
@export var audio: AudioStreamPlayer3D
@export var sounds_to_silence: Array[AudioStreamPlayer3D]
@export var video_player: VideoStreamPlayer
@export var max_points: int = 100
@export var particle_scale: float = 4.0

var code_progress : int = 0
const CODE = "badapple"
func _input(event: InputEvent) -> void:
	if not video_player:
		return
	if video_player.is_playing():
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var c:String= OS.get_keycode_string(event.keycode).to_lower()
		if c.length() == 1:
			if c == CODE[code_progress]:
				code_progress += 1
				if code_progress >= CODE.length():
					begin_bad_apple()
					code_progress = 0
			else:
				code_progress = 0


func _ready() -> void:
	if process_material is ParticleProcessMaterial:
		process_material.gravity = Vector3.ZERO
		amount = max_points
	#this condition is for starting the video if this is the top-level node
	# for the test scene
	if get_tree().get_current_scene() == self:
		begin_bad_apple()
func begin_bad_apple() -> void:
	const end_speed:float = 2.31
	var tween : Tween = get_tree().create_tween()
	if anim:
		tween.tween_property(anim,"speed_scale", end_speed, 3.0)
	if audio:
		tween.tween_property(audio,"volume_db", -15, 3.0)
	for sound in sounds_to_silence:
		tween.tween_property(sound,"volume_db", -80, 1.0)
		video_player.finished.connect(end_playback)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.finished.connect(start_playback)

func start_playback() -> void:
	if video_player:
		video_player.play()
		emitting = true

func end_playback() -> void:
	if video_player:
		video_player.stop()
		emitting = false
		video_player.finished.disconnect(end_playback)
		for sound in sounds_to_silence:
			sound.volume_db = 0

const frame_time: float = 0.1
var update_time:float = 0
func _physics_process(delta: float) -> void:
	if not video_player:
		return
	if not video_player.is_playing():
		return
	update_time += delta
	if update_time >= frame_time:
		update_time -= frame_time
		update_tex_from_video()
		


func update_tex_from_video() -> void:
	if video_player and process_material is ParticleProcessMaterial:
		var tex: Texture2D = video_player.get_video_texture()
		if tex:
			set_from_texture(tex)

func set_from_texture(tex: Texture2D) -> void:
	if not (tex and process_material is ParticleProcessMaterial):
		return
	var img: Image = tex.get_image()
	if img.is_empty():
		return

	var white_points := get_white_points(img)
	if white_points.is_empty():
		return

	var sampled_points := sample_points(white_points, max_points)
	var point_count := sampled_points.size()
	if point_count == 0:
		return

	var img_out := Image.create(point_count, 1, false, Image.FORMAT_RGBF)
	for i in range(point_count):
		var p: Vector2 = sampled_points[i]
		img_out.set_pixel(i, 0, Color(p.x * particle_scale, p.y * particle_scale, 0.0))

	if img_out.is_empty():
		return

	var new_tex := ImageTexture.create_from_image(img_out)
	process_material.emission_point_texture = new_tex
	process_material.emission_point_count = point_count
	amount_ratio = float(white_points.size()) / (img.get_width() * img.get_height())

func sample_points(arr: Array[Vector2], n: int) -> Array[Vector2]:
	if arr.is_empty():
		return []
	if arr.size() <= n:
		return arr.duplicate()
	var result: Array[Vector2] = []
	var taken := {}
	var arr_size := arr.size()
	while result.size() < n:
		var idx := randi() % arr_size
		if not taken.has(idx):
			taken[idx] = true
			result.append(arr[idx])
	return result

func get_white_points(img: Image) -> Array[Vector2]:
	var white_points: Array[Vector2] = []
	var w := img.get_width()
	var h := img.get_height()
	if w == 0 or h == 0:
		return white_points
	for x in range(w):
		for y in range(h):
			var c := img.get_pixel(x, y)
			if c.r > 0.9 and c.g > 0.9 and c.b > 0.9:
				white_points.append(Vector2(float(x) / float(w), 1.0 - (float(y) / float(h))))
	return white_points
	

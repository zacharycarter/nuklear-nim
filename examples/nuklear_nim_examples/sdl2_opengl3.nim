import sdl2, opengl
import "../../nuklear" as nk
import "../roboto_regular"

var
  win_w:cint = 1280
  win_h:cint = 720
  w, h, display_w, display_h: cint

const MAX_VERTEX_BUFFER = 512 * 1024
const MAX_ELEMENT_BUFFER = 128 * 1024

var fb_scale : vec2 = newVec2(0.0, 0.0)

proc down(key: cint): bool =
    sdl2.get_keyboard_state()[int(get_scancode_from_key(key))] != 0

proc `+`[T](a: ptr T, b: int): ptr T =
    if b >= 0:
        cast[ptr T](cast[uint](a) + cast[uint](b * a[].sizeof))
    else:
        cast[ptr T](cast[uint](a) - cast[uint](-1 * b * a[].sizeof))

template offsetof(typ, field): untyped = (var dummy: typ; cast[uint](addr(dummy.field)) - cast[uint](addr(dummy)))

template alignof(typ) : uint =
  if sizeof(typ) > 1:
    offsetof(tuple[c: char, x: typ], x)
  else:
    1

type
  vertex = object
    position: array[2, float]
    uv: array[2, float]
    col: array[4, char]

var config : convert_config

proc allocate(a2: handle; old: pointer; a4: uint): pointer {.cdecl.} =
  if not old.isNil:
    old.dealloc()

  return alloc(a4)

proc deallocate(a2: handle; old: pointer) {.cdecl.} =
  dealloc(old)

var allocator : plugin_alloc = allocate
var deallocator : plugin_free = deallocate

var vertex_layout {.global.} = @[
  draw_vertex_layout_element(
    attribute: VERTEX_POSITION,
    format: FORMAT_FLOAT,
    offset: offsetof(vertex, position)
  ),
  draw_vertex_layout_element(
    attribute: VERTEX_TEXCOORD,
    format: FORMAT_FLOAT,
    offset: offsetof(vertex, uv)
  ),
  draw_vertex_layout_element(
    attribute: VERTEX_COLOR,
    format: FORMAT_R8G8B8A8,
    offset: offsetof(vertex, col)
  ),
  draw_vertex_layout_element(
    attribute: VERTEX_ATTRIBUTE_COUNT,
    format: FORMAT_COUNT,
    offset: 0
  )
]

type device = object
  cmds: buffer
  null: draw_null_texture
  vbo, vao, ebo: GLuint
  prog: GLuint
  vert_shader: GLuint
  frag_shader: GLuint
  attrib_pos: GLint
  attrib_uv: GLint
  attrib_col: GLint
  uniform_tex: GLint
  uniform_proj: GLint
  font_tex: GLuint

var ctx : context
var dev {.global.} : device = device()

var fontAtlas : font_atlas
var fontConfig : font_config


proc set_style(ctx: var context) =
  var style : array[COLOR_COUNT.ord, nk.color]
  style[COLOR_TEXT.ord] = newColorRGBA(20, 20, 20, 255);
  style[COLOR_WINDOW.ord] = newColorRGBA(202, 212, 214, 215);
  style[COLOR_HEADER.ord] = newColorRGBA(137, 182, 224, 220);
  style[COLOR_BORDER.ord] = newColorRGBA(140, 159, 173, 255);
  style[COLOR_BUTTON.ord] = newColorRGBA(137, 182, 224, 255);
  style[COLOR_BUTTON_HOVER.ord] = newColorRGBA(142, 187, 229, 255);
  style[COLOR_BUTTON_ACTIVE.ord] = newColorRGBA(147, 192, 234, 255);
  style[COLOR_TOGGLE.ord] = newColorRGBA(177, 210, 210, 255);
  style[COLOR_TOGGLE_HOVER.ord] = newColorRGBA(182, 215, 215, 255);
  style[COLOR_TOGGLE_CURSOR.ord] = newColorRGBA(137, 182, 224, 255);
  style[COLOR_SELECT.ord] = newColorRGBA(177, 210, 210, 255);
  style[COLOR_SELECT_ACTIVE.ord] = newColorRGBA(137, 182, 224, 255);
  style[COLOR_SLIDER.ord] = newColorRGBA(177, 210, 210, 255);
  style[COLOR_SLIDER_CURSOR.ord] = newColorRGBA(137, 182, 224, 245);
  style[COLOR_SLIDER_CURSOR_HOVER.ord] = newColorRGBA(142, 188, 229, 255);
  style[COLOR_SLIDER_CURSOR_ACTIVE.ord] = newColorRGBA(147, 193, 234, 255);
  style[COLOR_PROPERTY.ord] = newColorRGBA(210, 210, 210, 255);
  style[COLOR_EDIT.ord] = newColorRGBA(210, 210, 210, 225);
  style[COLOR_EDIT_CURSOR.ord] = newColorRGBA(20, 20, 20, 255);
  style[COLOR_COMBO.ord] = newColorRGBA(210, 210, 210, 255);
  style[COLOR_CHART.ord] = newColorRGBA(210, 210, 210, 255);
  style[COLOR_CHART_COLOR.ord] = newColorRGBA(137, 182, 224, 255);
  style[COLOR_CHART_COLOR_HIGHLIGHT.ord] = newColorRGBA( 255, 0, 0, 255);
  style[COLOR_SCROLLBAR.ord] = newColorRGBA(190, 200, 200, 255);
  style[COLOR_SCROLLBAR_CURSOR.ord] = newColorRGBA(64, 84, 95, 255);
  style[COLOR_SCROLLBAR_CURSOR_HOVER.ord] = newColorRGBA(70, 90, 100, 255);
  style[COLOR_SCROLLBAR_CURSOR_ACTIVE.ord] = newColorRGBA(75, 95, 105, 255);
  style[COLOR_TAB_HEADER.ord] = newColorRGBA(156, 193, 220, 255);

  ctx.newStyleFromTable(style[0])

proc device_init() =
  var status: GLint
  init(dev.cmds)
  dev.prog = glCreateProgram();
  dev.vert_shader = glCreateShader(GL_VERTEX_SHADER);
  dev.frag_shader = glCreateShader(GL_FRAGMENT_SHADER);

  var vertex_shader = """
    #version 150
    in vec2 Position;
    in vec2 TexCoord;
    in vec4 Color;
    out vec2 Frag_UV;
    out vec4 Frag_Color;
    uniform mat4 ProjMtx;
    void main() {
        Frag_UV = TexCoord;
        Frag_Color = Color;
        gl_Position = ProjMtx * vec4(Position.xy, 0, 1);
    }
  """
  var fragment_shader  = """
    #version 150
    precision mediump float;
    uniform sampler2D Texture;
    in vec2 Frag_UV;
    in vec4 Frag_Color;
    out vec4 Out_Color;
    void main() {
        Out_Color = Frag_Color * texture(Texture, Frag_UV.st);
    }
  """

  let vertCStringArray = allocCStringArray([vertex_shader])
  let fragCStringArray = allocCStringArray([fragment_shader])
  glShaderSource(dev.vert_shader, 1, vertCStringArray, nil)

  glShaderSource(dev.frag_shader, 1, fragCStringArray, nil)

  glCompileShader(dev.vert_shader);
  glCompileShader(dev.frag_shader);
  glGetShaderiv(dev.vert_shader, GL_COMPILE_STATUS, addr status);
  assert(status == GL_TRUE.cint);
  glGetShaderiv(dev.frag_shader, GL_COMPILE_STATUS, addr status);
  assert(status == GL_TRUE.cint);
  glAttachShader(dev.prog, dev.vert_shader);
  glAttachShader(dev.prog, dev.frag_shader);
  glLinkProgram(dev.prog);
  glGetProgramiv(dev.prog, GL_LINK_STATUS, addr status);
  assert(status == GL_TRUE.cint);

  dev.uniform_tex = glGetUniformLocation(dev.prog, "Texture");
  dev.uniform_proj = glGetUniformLocation(dev.prog, "ProjMtx");
  dev.attrib_pos = glGetAttribLocation(dev.prog, "Position");
  dev.attrib_uv = glGetAttribLocation(dev.prog, "TexCoord");
  dev.attrib_col = glGetAttribLocation(dev.prog, "Color");

  # buffer setup
  glGenBuffers(1, addr dev.vbo);
  glGenBuffers(1, addr dev.ebo);
  glGenVertexArrays(1, addr dev.vao);

  glBindVertexArray(dev.vao);
  glBindBuffer(GL_ARRAY_BUFFER, dev.vbo);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, dev.ebo);

  glEnableVertexAttribArray((GLuint)dev.attrib_pos);
  glEnableVertexAttribArray((GLuint)dev.attrib_uv);
  glEnableVertexAttribArray((GLuint)dev.attrib_col);

  let vs = GLsizei sizeof(vertex)
  let vp = offsetof(vertex, position)
  let vt = offsetof(vertex, uv)
  let vc = offsetof(vertex, col)
  glVertexAttribPointer((GLuint)dev.attrib_pos, 2, cGL_FLOAT, GL_FALSE, vs, cast[pointer](vp))
  glVertexAttribPointer((GLuint)dev.attrib_uv, 2, cGL_FLOAT, GL_FALSE, vs, cast[pointer](vt))
  glVertexAttribPointer((GLuint)dev.attrib_col, 4, cGL_UNSIGNED_BYTE, GL_TRUE, vs, cast[pointer](vc))

  glBindTexture(GL_TEXTURE_2D, 0);
  glBindBuffer(GL_ARRAY_BUFFER, 0);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
  glBindVertexArray(0);

proc sdlErrorHandler(): void =
  echo getError()
  quit(QUIT_FAILURE)

# INIT
var err = sdl2.init(INIT_EVERYTHING)
if err == SdlError: sdlErrorHandler()

discard set_hint("SDL_HINT_VIDEO_HIGHDPI_DISABLED", "0".cstring)
discard glSetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE)
discard glSetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3.cint)
discard glSetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 2.cint)
discard glSetAttribute(SDL_GL_DOUBLEBUFFER, 1.cint)
discard glSetSwapInterval(1.cint)
var win = createWindow("GUI Lysa",
                       SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
                       win_w, win_h, SDL_WINDOW_OPENGL)
if win == nil: sdlErrorHandler()
var glContext = glCreateContext(win)
if glContext == nil: sdlErrorHandler()

loadExtensions()
glViewport(0, 0, win_w, win_h)
win.getSize(win_w, win_h)

fontAtlas.init()
fontAtlas.open()

let roboto_ttf = addr s_robotoRegularTtf

var font = fontAtlas.addFromMemory(roboto_ttf, uint sizeof(s_robotoRegularTtf), 13.0'f32, nil)

let image = fontAtlas.bake(w, h, FONT_ATLAS_RGBA32)
glGenTextures(1, addr dev.font_tex);
glBindTexture(GL_TEXTURE_2D, dev.font_tex);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
glTexImage2D(GL_TEXTURE_2D, 0, GLint GL_RGBA, (GLsizei)w, (GLsizei)h, 0, GL_RGBA, GL_UNSIGNED_BYTE, image);
fontAtlas.close(handle_id(int32 dev.font_tex), dev.null)

discard ctx.init(font.handle)
device_init()

set_style(ctx)

var
  evt = sdl2.default_event
  running = true
  background = newColorRGB(28,48,62)
  mouseX, mouseY: cint
  button: uint8

# LOOP
while running:

  # EVENTS
  while sdl2.poll_event(evt):
    if K_ESCAPE.down or evt.kind == QuitEvent:
      running = false

  # INPUT
  input_begin(addr ctx)

  button = getMouseState(mouseX, mouseY)
  inputButton(ctx, nk.BUTTON_LEFT, mouseX.int32, mouseY.int32, button == sdl2.BUTTON_LEFT);
  inputButton(ctx, nk.BUTTON_MIDDLE, mouseX.int32, mouseY.int32, button == sdl2.BUTTON_MIDDLE);
  inputButton(ctx, nk.BUTTON_RIGHT, mouseX.int32, mouseY.int32, button == sdl2.BUTTON_RIGHT);
  inputMotion(ctx, cint mouseX, cint mouseY)

  closeInput(ctx)

  # BUILD GUI
  if ctx.open("test", newRect(50, 50, 230, 250), WINDOW_BORDER.ord or WINDOW_MOVABLE.ord or WINDOW_SCALABLE.ord or WINDOW_MINIMIZABLE.ord or WINDOW_TITLE.ord):
    const
      EASY = false
      HARD = true

    var op {.global.}: bool = EASY

    var property {.global.}: cint = 20

    layoutStaticRow(ctx, 30, 80, 2)
    if buttonLabel(ctx, "button"): echo "button pressed"
    if buttonLabel(ctx, "button2"): echo "button2 pressed"

    layoutDynamicRow(ctx, 30, 2)
    if optionLabel(ctx, "easy", op == EASY):
      op = EASY
    if optionLabel(ctx, "hard", op == HARD):
      op = HARD

    layoutDynamicRow(ctx, 25, 1)
    propertyInt(ctx, "Compression:", 0, property, 100, 10, 1)

    layoutDynamicRow(ctx, 20, 1)
    label(ctx, "background:", uint32 TEXT_LEFT)

    layoutDynamicRow(ctx, 25, 1)
    if comboBeginColor(ctx, background, newVec2(ctx.width, 400)):
      layoutDynamicRow(ctx, 120, 1)
      background = color_picker(ctx, background, RGBA)
      layoutDynamicRow(ctx, 25, 1)

      background.r = char(propertyI(ctx, "#R:", 0, background.r.cint, 255, 1, 1.0))
      background.g = char(propertyI(ctx, "#G:", 0, background.g.cint, 255, 1, 1.0))
      background.b = char(propertyI(ctx, "#B:", 0, background.b.cint, 255, 1, 1.0))
      background.a = char(propertyI(ctx, "#A:", 0, background.a.cint, 255, 1, 1.0))
      comboEnd(ctx)
  ctx.close()

  # DRAWING
  var bg : array[4, cfloat]

  background.fv(bg[0])

  win.getSize(win_w, win_h);
  glGetDrawableSize(win, display_w, display_h)
  fb_scale.x = display_w / win_w
  fb_scale.y = display_h / win_h
  glViewport(0, 0, win_w, win_h)
  glClear(GL_COLOR_BUFFER_BIT)
  glClearColor(bg[0], bg[1], bg[2], bg[3])

  var ortho = [
    [2.0f, 0.0f, 0.0f, 0.0f],
    [0.0f,-2.0f, 0.0f, 0.0f],
    [0.0f, 0.0f,-1.0f, 0.0f],
    [-1.0f,1.0f, 0.0f, 1.0f]
  ]
  ortho[0][0] /= (GLfloat)win_w;
  ortho[1][1] /= (GLfloat)win_h;

  glEnable(GL_BLEND);
  glBlendEquation(GL_FUNC_ADD);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glDisable(GL_CULL_FACE);
  glDisable(GL_DEPTH_TEST);
  glEnable(GL_SCISSOR_TEST);
  glActiveTexture(GL_TEXTURE0);

  glUseProgram(dev.prog);
  glUniform1i(dev.uniform_tex, 0);

  glUniformMatrix4fv(dev.uniform_proj, 1, GL_FALSE, addr ortho[0][0])
  glViewport(0,0,(GLsizei)display_w,(GLsizei)display_h);

  var cmd : ptr draw_command
  var offset: ptr draw_index

  glBindVertexArray(dev.vao);
  glBindBuffer(GL_ARRAY_BUFFER, dev.vbo);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, dev.ebo);

  glBufferData(GL_ARRAY_BUFFER, MAX_VERTEX_BUFFER, nil, GL_STREAM_DRAW);
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, MAX_ELEMENT_BUFFER, nil, GL_STREAM_DRAW);

  var vertices = glMapBuffer(GL_ARRAY_BUFFER, GL_WRITE_ONLY);
  var elements = glMapBuffer(GL_ELEMENT_ARRAY_BUFFER, GL_WRITE_ONLY);

  # convert commands to verteces
  config.vertex_layout = addr vertex_layout[0]
  config.vertex_size = uint sizeof(vertex);
  config.vertex_alignment = alignof(vertex);
  config.null = dev.null;
  config.circle_segment_count = 22;
  config.curve_segment_count = 22;
  config.arc_segment_count = 22;
  config.global_alpha = 1.0f;
  config.shape_AA = ANTI_ALIASING_ON;
  config.line_AA = ANTI_ALIASING_ON;

  var vbuf, ebuf : buffer
  init(vbuf, vertices, MAX_VERTEX_BUFFER)
  init(ebuf, elements, MAX_ELEMENT_BUFFER)

  convertDrawCommands(ctx, dev.cmds, vbuf, ebuf, config)

  discard glUnmapBuffer(GL_ARRAY_BUFFER);
  discard glUnmapBuffer(GL_ELEMENT_ARRAY_BUFFER);

  cmd = firstDrawCommand(ctx, dev.cmds)
  while not isNil(cmd):
    if cmd.elem_count != 0:
      glBindTexture(GL_TEXTURE_2D, GLuint cast[int](cmd.texture))
      glScissor(
                  (GLint)(cmd.clip_rect.x * fb_scale.x),
                  (GLint)((float(win_h) - float(cmd.clip_rect.y + cmd.clip_rect.h)) * fb_scale.y),
                  (GLint)(cmd.clip_rect.w * fb_scale.x),
                  (GLint)(cmd.clip_rect.h * fb_scale.y));
      glDrawElements(GL_TRIANGLES, (GLsizei)cmd.elem_count, GL_UNSIGNED_SHORT, offset);
      offset = offset  + int cmd.elem_count

    cmd = nextDrawCommand(cmd, dev.cmds, ctx)

  ctx.clear()

  glUseProgram(0);
  glBindBuffer(GL_ARRAY_BUFFER, 0);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
  glBindVertexArray(0);
  glDisable(GL_BLEND);
  glDisable(GL_SCISSOR_TEST);

  glSwapWindow(win);

# CLEANUP
fontAtlas.clear()
ctx.free()
glDetachShader(dev.prog, dev.vert_shader);
glDetachShader(dev.prog, dev.frag_shader);
glDeleteShader(dev.vert_shader);
glDeleteShader(dev.frag_shader);
glDeleteProgram(dev.prog);
glDeleteTextures(1, addr dev.font_tex);
glDeleteBuffers(1, addr dev.vbo);
glDeleteBuffers(1, addr dev.ebo);
free(dev.cmds);
glDeleteContext(glContext)
win.destroy()
sdl2.quit()

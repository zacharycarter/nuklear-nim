import glfw3 as glfw, opengl

# import ../roboto_regular

import nuklear

const WINDOW_WIDTH = 800
const WINDOW_HEIGHT = 600

const MAX_VERTEX_BUFFER = 512 * 1024
const MAX_ELEMENT_BUFFER = 128 * 1024

var fb_scale : nk_vec2 = new_nk_vec2(0.0, 0.0)

proc `+`[T](a: ptr T, b: int): ptr T =
    if b >= 0:
        cast[ptr T](cast[uint](a) + cast[uint](b * a[].sizeof))
    else:
        cast[ptr T](cast[uint](a) - cast[uint](-1 * b * a[].sizeof))

type
  glfw_vertex = object
    position: array[2, float]
    uv: array[2, float]
    col: array[4, char]

var config : nk_convert_config

proc allocate(a2: nk_handle; old: pointer; a4: uint): pointer {.cdecl.} =
  if not old.isNil:
    old.dealloc()

  return alloc(a4)

proc deallocate(a2: nk_handle; old: pointer) {.cdecl.} =
  dealloc(old)

var allocator = nk_allocator(alloc: allocate, free: deallocate)

var win : glfw.Window

var vertex_layout {.global.} = @[
  nk_draw_vertex_layout_element(
    attribute: NK_VERTEX_POSITION,
    format: NK_FORMAT_FLOAT,
    offset: cast[uint](offsetof(glfw_vertex, position))
  ),
  nk_draw_vertex_layout_element(
    attribute: NK_VERTEX_TEXCOORD,
    format: NK_FORMAT_FLOAT,
    offset: cast[uint](offsetof(glfw_vertex, uv))
  ),
  nk_draw_vertex_layout_element(
    attribute: NK_VERTEX_COLOR,
    format: NK_FORMAT_R8G8B8A8,
    offset: cast[uint](offsetof(glfw_vertex, col))
  ),
  nk_draw_vertex_layout_element(
    attribute: NK_VERTEX_ATTRIBUTE_COUNT,
    format: NK_FORMAT_COUNT,
    offset: cast[uint](0)
  )
]

type device = object
  cmds: nk_buffer
  null: nk_draw_null_texture
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

var ctx : nk_context
var dev {.global.} : device = device()

var fontAtlas : nk_font_atlas

var w, h: cint = 0
var width,height: cint = 0
var display_width, display_height : cint = 0

proc set_style(ctx: var nk_context) =
  var style : array[NK_COLOR_COUNT.ord, nk_color]
  style[NK_COLOR_TEXT.ord] = nk_rgba(20, 20, 20, 255);
  style[NK_COLOR_WINDOW.ord] = nk_rgba(202, 212, 214, 215);
  style[NK_COLOR_HEADER.ord] = nk_rgba(137, 182, 224, 220);
  style[NK_COLOR_BORDER.ord] = nk_rgba(140, 159, 173, 255);
  style[NK_COLOR_BUTTON.ord] = nk_rgba(137, 182, 224, 255);
  style[NK_COLOR_BUTTON_HOVER.ord] = nk_rgba(142, 187, 229, 255);
  style[NK_COLOR_BUTTON_ACTIVE.ord] = nk_rgba(147, 192, 234, 255);
  style[NK_COLOR_TOGGLE.ord] = nk_rgba(177, 210, 210, 255);
  style[NK_COLOR_TOGGLE_HOVER.ord] = nk_rgba(182, 215, 215, 255);
  style[NK_COLOR_TOGGLE_CURSOR.ord] = nk_rgba(137, 182, 224, 255);
  style[NK_COLOR_SELECT.ord] = nk_rgba(177, 210, 210, 255);
  style[NK_COLOR_SELECT_ACTIVE.ord] = nk_rgba(137, 182, 224, 255);
  style[NK_COLOR_SLIDER.ord] = nk_rgba(177, 210, 210, 255);
  style[NK_COLOR_SLIDER_CURSOR.ord] = nk_rgba(137, 182, 224, 245);
  style[NK_COLOR_SLIDER_CURSOR_HOVER.ord] = nk_rgba(142, 188, 229, 255);
  style[NK_COLOR_SLIDER_CURSOR_ACTIVE.ord] = nk_rgba(147, 193, 234, 255);
  style[NK_COLOR_PROPERTY.ord] = nk_rgba(210, 210, 210, 255);
  style[NK_COLOR_EDIT.ord] = nk_rgba(210, 210, 210, 225);
  style[NK_COLOR_EDIT_CURSOR.ord] = nk_rgba(20, 20, 20, 255);
  style[NK_COLOR_COMBO.ord] = nk_rgba(210, 210, 210, 255);
  style[NK_COLOR_CHART.ord] = nk_rgba(210, 210, 210, 255);
  style[NK_COLOR_CHART_COLOR.ord] = nk_rgba(137, 182, 224, 255);
  style[NK_COLOR_CHART_COLOR_HIGHLIGHT.ord] = nk_rgba( 255, 0, 0, 255);
  style[NK_COLOR_SCROLLBAR.ord] = nk_rgba(190, 200, 200, 255);
  style[NK_COLOR_SCROLLBAR_CURSOR.ord] = nk_rgba(64, 84, 95, 255);
  style[NK_COLOR_SCROLLBAR_CURSOR_HOVER.ord] = nk_rgba(70, 90, 100, 255);
  style[NK_COLOR_SCROLLBAR_CURSOR_ACTIVE.ord] = nk_rgba(75, 95, 105, 255);
  style[NK_COLOR_TAB_HEADER.ord] = nk_rgba(156, 193, 220, 255);

  nk_style_from_table(addr ctx, addr style[0])

proc device_init() =
  var status: GLint
  #buffer_init(addr dev.cmds, addr allocator, 512 * 1024)
  nk_buffer_init(addr dev.cmds, addr allocator, 512 * 1024)
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

  let vs = GLsizei sizeof(glfw_vertex)
  let vp = offsetof(glfw_vertex, position)
  let vt = offsetof(glfw_vertex, uv)
  let vc = offsetof(glfw_vertex, col)
  glVertexAttribPointer((GLuint)dev.attrib_pos, 2, cGL_FLOAT, GL_FALSE, vs, cast[pointer](vp))
  glVertexAttribPointer((GLuint)dev.attrib_uv, 2, cGL_FLOAT, GL_FALSE, vs, cast[pointer](vt))
  glVertexAttribPointer((GLuint)dev.attrib_col, 4, cGL_UNSIGNED_BYTE, GL_TRUE, vs, cast[pointer](vc))

  glBindTexture(GL_TEXTURE_2D, 0);
  glBindBuffer(GL_ARRAY_BUFFER, 0);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
  glBindVertexArray(0);

if not glfw.Init() == 1:
  quit(QUIT_FAILURE)

proc glfwErrorHandler(error: cint; message: cstring): void {.cdecl.} =
  echo "got glfw error: ", message
  quit(QUIT_FAILURE)

discard glfw.SetErrorCallback(glfwErrorHandler)

glfw.WindowHint(CONTEXT_VERSION_MAJOR, 3)
glfw.WindowHint(CONTEXT_VERSION_MINOR, 3)
glfw.WindowHint(OPENGL_PROFILE, OPENGL_CORE_PROFILE)
if defined(macosx):
  glfw.WindowHint(OPENGL_FORWARD_COMPAT, GL_TRUE.cint)
win = glfw.CreateWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Demo", nil, nil)
glfw.MakeContextCurrent(win)
glfw.GetWindowSize(win, addr width, addr height)

loadExtensions()
glViewport(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)

nk_font_atlas_init(addr fontAtlas, addr allocator)
nk_font_atlas_begin(addr fontAtlas)

# let roboto_ttf = addr s_robotoRegularTtf

# var font = nk_font_atlas_add_from_memory(addr fontAtlas, roboto_ttf, uint sizeof(s_robotoRegularTtf), 13.0'f32, nil)
var font = nk_font_atlas_add_default(addr fontAtlas, 13, nil)

let image = nk_font_atlas_bake(addr fontAtlas, addr w, addr h, NK_FONT_ATLAS_RGBA32)
glGenTextures(1, addr dev.font_tex);
glBindTexture(GL_TEXTURE_2D, dev.font_tex);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
glTexImage2D(GL_TEXTURE_2D, 0, GLint GL_RGBA, (GLsizei)w, (GLsizei)h, 0, GL_RGBA, GL_UNSIGNED_BYTE, image);

nk_font_atlas_end(addr fontAtlas, nk_handle_id(int32 dev.font_tex), addr dev.null)

discard nk_init(addr ctx, addr allocator, addr font.handle)
device_init()

set_style(ctx)

#discard init(addr ctx, addr customAllocator, cast[ptr user_font](addr font))

var background: nk_colorf = nk_color_cf(nk_rgb(28,48,62))
var mouseX, mouseY: float
while glfw.WindowShouldClose(win) == 0:
  glfw.PollEvents();

  nk_input_begin(addr ctx)

  glfw.GetCursorPos(win, addr mouseX, addr mouseY)
  nk_input_button(addr ctx, NK_BUTTON_LEFT, mouseX.cint, mouseY.cint, cint(glfw.GetMouseButton(win, glfw.MOUSE_BUTTON_LEFT) == glfw.PRESS))
  nk_input_button(addr ctx, NK_BUTTON_MIDDLE, mouseX.cint, mouseY.cint, cint(glfw.GetMouseButton(win, glfw.MOUSE_BUTTON_MIDDLE) == glfw.PRESS))
  nk_input_button(addr ctx, NK_BUTTON_RIGHT, mouseX.cint, mouseY.cint, cint(glfw.GetMouseButton(win, glfw.MOUSE_BUTTON_RIGHT) == glfw.PRESS))
  nk_input_motion(addr ctx, cint mouseX, cint mouseY)

  nk_input_end(addr ctx)

  if nk_begin(addr ctx, "test".cstring, new_nk_rect(50, 50, 230, 250), NK_WINDOW_BORDER.ord or NK_WINDOW_MOVABLE.ord or NK_WINDOW_SCALABLE.ord or NK_WINDOW_MINIMIZABLE.ord or NK_WINDOW_TITLE.ord).bool:
    const
      EASY = false
      HARD = true

    var op {.global.}: bool = EASY

    var property {.global.}: cint = 20

    nk_layout_row_static(addr ctx, 30, 80, 1)
    if nk_button_label(addr ctx, "button".cstring).bool: echo "button pressed"
    nk_layout_row_dynamic(addr ctx, 30, 2)

    if nk_option_label(addr ctx, "easy".cstring, (op == EASY).cint).bool:
      op = EASY
    if nk_option_label(addr ctx, "hard".cstring, (op == HARD).cint).bool:
      op = HARD
    nk_layout_row_dynamic(addr ctx, 25, 1)
    nk_property_int(addr ctx, "Compression:".cstring, 0, addr property, 100, 10, 1)
    nk_layout_row_dynamic(addr ctx, 20, 1)
    nk_label(addr ctx, "background:", uint32 NK_TEXT_LEFT)
    nk_layout_row_dynamic(addr ctx, 25, 1)
    if nk_combo_begin_color(addr ctx, nk_rgb_cf(background), new_nk_vec2(nk_widget_width(addr ctx), 400)).bool:
      nk_layout_row_dynamic(addr ctx, 120, 1)
      background = nk_color_picker(addr ctx, background, NK_RGBA)
      nk_layout_row_dynamic(addr ctx, 25, 1)

      background.r = cfloat(nk_propertyi(addr ctx, "#R:", 0, background.r.cint, 255, 1, 1.0))
      background.g = cfloat(nk_propertyi(addr ctx, "#G:", 0, background.g.cint, 255, 1, 1.0))
      background.b = cfloat(nk_propertyi(addr ctx, "#B:", 0, background.b.cint, 255, 1, 1.0))
      background.a = cfloat(nk_propertyi(addr ctx, "#A:", 0, background.a.cint, 255, 1, 1.0))
      nk_combo_end(addr ctx)
  nk_end(addr ctx)

  glfw.GetWindowSize(win, addr width, addr height);
  glfw.GetFramebufferSize(win, addr display_width, addr display_height)
  fb_scale.x = display_width / width
  fb_scale.y = display_height / height
  glViewport(0, 0, width, height)
  glClear(GL_COLOR_BUFFER_BIT)
  glClearColor(background.r, background.g, background.b, background.a)

  var ortho = [
    [2.0f, 0.0f, 0.0f, 0.0f],
    [0.0f,-2.0f, 0.0f, 0.0f],
    [0.0f, 0.0f,-1.0f, 0.0f],
    [-1.0f,1.0f, 0.0f, 1.0f]
  ]
  ortho[0][0] /= (GLfloat)width;
  ortho[1][1] /= (GLfloat)height;

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
  glViewport(0,0,(GLsizei)display_width,(GLsizei)display_height);

  var cmd : ptr nk_draw_command
  var offset: ptr nk_draw_index

  glBindVertexArray(dev.vao);
  glBindBuffer(GL_ARRAY_BUFFER, dev.vbo);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, dev.ebo);

  glBufferData(GL_ARRAY_BUFFER, MAX_VERTEX_BUFFER, nil, GL_STREAM_DRAW);
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, MAX_ELEMENT_BUFFER, nil, GL_STREAM_DRAW);

  var vertices = glMapBuffer(GL_ARRAY_BUFFER, GL_WRITE_ONLY);
  var elements = glMapBuffer(GL_ELEMENT_ARRAY_BUFFER, GL_WRITE_ONLY);

  ##  fill convert configuration
  config.vertex_layout = addr vertex_layout[0]
  config.vertex_size = uint sizeof(glfw_vertex);
  config.vertex_alignment = cast[uint](alignof(glfw_vertex))
  config.null = dev.null;
  config.circle_segment_count = 22;
  config.curve_segment_count = 22;
  config.arc_segment_count = 22;
  config.global_alpha = 1.0f;
  config.shape_AA = NK_ANTI_ALIASING_ON;
  config.line_AA = NK_ANTI_ALIASING_ON;

  var vbuf, ebuf : nk_buffer
  nk_buffer_init_fixed(addr vbuf, vertices, MAX_VERTEX_BUFFER)
  nk_buffer_init_fixed(addr ebuf, elements, MAX_ELEMENT_BUFFER)

  discard nk_convert(addr ctx, addr dev.cmds, addr vbuf, addr ebuf, addr config)

  discard glUnmapBuffer(GL_ARRAY_BUFFER);
  discard glUnmapBuffer(GL_ELEMENT_ARRAY_BUFFER);

  cmd = nk_draw_begin(addr ctx, addr dev.cmds)
  while not isNil(cmd):
    if cmd.elem_count != 0:
      glBindTexture(GL_TEXTURE_2D, GLuint cast[int](cmd.texture))
      glScissor(
                  (GLint)(cmd.clip_rect.x * fb_scale.x),
                  (GLint)((float(height) - float(cmd.clip_rect.y + cmd.clip_rect.h)) * fb_scale.y),
                  (GLint)(cmd.clip_rect.w * fb_scale.x),
                  (GLint)(cmd.clip_rect.h * fb_scale.y));
      glDrawElements(GL_TRIANGLES, (GLsizei)cmd.elem_count, GL_UNSIGNED_SHORT, offset);
      offset = offset  + int cmd.elem_count

    cmd = nk_draw_next(cmd, addr dev.cmds, addr ctx)


  nk_clear(addr ctx)


  glUseProgram(0);
  glBindBuffer(GL_ARRAY_BUFFER, 0);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
  glBindVertexArray(0);
  glDisable(GL_BLEND);
  glDisable(GL_SCISSOR_TEST);

  glfw.SwapBuffers(win);

nk_font_atlas_clear(addr fontAtlas)
nk_free(addr ctx)
glDetachShader(dev.prog, dev.vert_shader);
glDetachShader(dev.prog, dev.frag_shader);
glDeleteShader(dev.vert_shader);
glDeleteShader(dev.frag_shader);
glDeleteProgram(dev.prog);
glDeleteTextures(1, addr dev.font_tex);
glDeleteBuffers(1, addr dev.vbo);
glDeleteBuffers(1, addr dev.ebo);
nk_buffer_free(addr dev.cmds);
glfw.Terminate()
import glfw3 as glfw, opengl

import roboto_regular

import nuklear/nuklearpp

const WINDOW_WIDTH = 800
const WINDOW_HEIGHT = 600

const MAX_VERTEX_BUFFER = 512 * 1024
const MAX_ELEMENT_BUFFER = 128 * 1024

template offsetof(typ, field): expr = (var dummy: typ; cast[uint](addr(dummy.field)) - cast[uint](addr(dummy)))

template alignof(typ) : uint =
  if sizeof(typ) > 1:
    offsetof(tuple[c: char, x: typ], x)
  else:
    1

type
  nk_glfw_vertex = object
    position: array[2, float]
    uv: array[2, float]
    col: array[4, nk_byte]

var config : nk_convert_config

var vertex_layout {.global.} = @[
  nk_draw_vertex_layout_element(
    attribute: NK_VERTEX_POSITION,
    format: NK_FORMAT_FLOAT, 
    offset: offsetof(nk_glfw_vertex, position)
  ),
  nk_draw_vertex_layout_element(
    attribute: NK_VERTEX_TEXCOORD,
    format: NK_FORMAT_FLOAT, 
    offset: offsetof(nk_glfw_vertex, uv)
  ),
  nk_draw_vertex_layout_element(
    attribute: NK_VERTEX_COLOR,
    format: NK_FORMAT_FLOAT, 
    offset: offsetof(nk_glfw_vertex, col)
  ),
  nk_draw_vertex_layout_element(
    attribute: NK_VERTEX_ATTRIBUTE_COUNT,
    format: NK_FORMAT_COUNT,
    offset: 0
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
var ctxp : ptr nk_context
var dev {.global.} : device = device()

var fontAtlas : nk_font_atlas
var fontConfig : nk_font_config

var w, h: cint = 0
var width,height: cint = 0
var display_width, display_height : cint = 0

var win {.global.} : glfw.Window

proc device_init() =
  var status: GLint
  nk_buffer_init_default(addr dev.cmds)
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

  let vs = GLsizei sizeof(nk_glfw_vertex)
  let vp = offsetof(nk_glfw_vertex, position)
  let vt = offsetof(nk_glfw_vertex, uv)
  let vc = offsetof(nk_glfw_vertex, col)
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

nk_font_atlas_init_default(addr fontAtlas)

nk_font_atlas_begin(addr fontAtlas)

let roboto_ttf = addr s_robotoRegularTtf

let font = nk_font_atlas_add_from_memory(addr fontAtlas, roboto_ttf, nk_size sizeof(s_robotoRegularTtf), 13, nil)

let image = nk_font_atlas_bake(addr fontAtlas, addr w, addr h, NK_FONT_ATLAS_RGBA32)

nk_font_atlas_end(addr fontAtlas, nk_handle_id(cint dev.font_tex), addr dev.null)

discard nk_init_default(addr ctx, addr font.handle)

device_init()


var background = nk_rgb(28,48,62)
while glfw.WindowShouldClose(win) == 0:
  glfw.PollEvents();

  if nk_begin(addr ctx, "test", nk_rect(50, 50, 230, 250), nk_flags NK_WINDOW_BORDER.cint or NK_WINDOW_MOVABLE.cint or NK_WINDOW_SCALABLE.cint or NK_WINDOW_MINIMIZABLE.cint or NK_WINDOW_TITLE.cint) == 1:
    const
      EASY = 0
      HARD = 1

    var op: cint = EASY
    var property: cint = 20

    nk_layout_row_static(addr ctx, 30, 80, 1)
    if nk_button_label(addr ctx, "button") == 1:
      echo "Button Pressed"
    
  nk_end(addr ctx)

  var bg : array[4, cfloat]
  
  nk_color_fv(addr bg[0], background)

  glfw.GetWindowSize(win, addr width, addr height);
  glfw.GetFramebufferSize(win, addr display_width, addr display_height)
  glViewport(0, 0, width, height)
  glClear(GL_COLOR_BUFFER_BIT)
  glClearColor(bg[0], bg[1], bg[2], bg[3])

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
  
  glUniformMatrix4fv(0, 1, GL_FALSE, addr ortho[0][0])
  glViewport(0,0,(GLsizei)display_width,(GLsizei)display_height);

  var cmd : ptr nk_draw_command

  glBindVertexArray(dev.vao);
  glBindBuffer(GL_ARRAY_BUFFER, dev.vbo);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, dev.ebo);

  glBufferData(GL_ARRAY_BUFFER, MAX_VERTEX_BUFFER, nil, GL_STREAM_DRAW);
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, MAX_ELEMENT_BUFFER, nil, GL_STREAM_DRAW);

  var vertices = glMapBuffer(GL_ARRAY_BUFFER, GL_WRITE_ONLY);
  var elements = glMapBuffer(GL_ELEMENT_ARRAY_BUFFER, GL_WRITE_ONLY);

  ##  fill convert configuration
  
  #nk_memset(addr config, 0, nk_size sizeof(config))
  config = nk_convert_config()
  config.vertex_layout = addr vertex_layout[0]
  config.vertex_size = nk_size sizeof(nk_glfw_vertex);
  config.vertex_alignment = alignof(nk_glfw_vertex);
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

  nk_convert(addr ctx, addr dev.cmds, addr vbuf, addr ebuf, addr config)

  discard glUnmapBuffer(GL_ARRAY_BUFFER);
  discard glUnmapBuffer(GL_ELEMENT_ARRAY_BUFFER);

  var b = nk_draw_begin(addr ctx, addr dev.cmds)
  while not b.isNil:
    b = nk_draw_next(cmd, addr dev.cmds, addr ctx)

  nk_clear(addr ctx)


  glUseProgram(0);
  glBindBuffer(GL_ARRAY_BUFFER, 0);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
  glBindVertexArray(0);
  glDisable(GL_BLEND);
  glDisable(GL_SCISSOR_TEST);

  glfw.SwapBuffers(win);
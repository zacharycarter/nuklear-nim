import opengl, glfw3 as glfw, nuklearpp

type
  nk_glfw_init_state* = enum
    NK_GLFW3_DEFAULT = 0, NK_GLFW3_INSTALL_CALLBACKS

type
  nk_glfw_device* = object
    cmds*: nk_buffer
    null*: nk_draw_null_texture
    vbo*: GLuint
    vao*: GLuint
    ebo*: GLuint
    prog*: GLuint
    vert_shdr*: GLuint
    frag_shdr*: GLuint
    attrib_pos*: GLint
    attrib_uv*: GLint
    attrib_col*: GLint
    uniform_tex*: GLint
    uniform_proj*: GLint
    font_tex*: GLuint

type
  nk_glfw_vertex* = object
    position*: array[2, cfloat]
    uv*: array[2, cfloat]
    col*: array[4, nk_byte]

## static
type
  nk_glfw* = object
    win*: glfw.Window
    width*: cint
    height*: cint
    display_width*: cint
    display_height*: cint
    ogl*: nk_glfw_device
    ctx*: nk_context
    atlas*: nk_font_atlas
    fb_scale*: nuk_vec2
    text*: array[256, cuint]
    text_len*: cint
    scroll*: cfloat

var nukGLFW* {.global.} : nk_glfw

proc nk_glfw3_device_create*() =
    var status: GLint
    var vertex_shader = """
      #version 150
      uniform mat4 ProjMtx;
      in vec2 Position;
      in vec2 TexCoord;
      in vec4 Color;
      out vec2 Frag_UV;
      out vec4 Frag_Color;
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
    var dev: ptr nk_glfw_device = addr(nukGLFW.ogl)
    nk_buffer_init_default(addr(dev.cmds))
    dev.prog = glCreateProgram()
    dev.vert_shdr = glCreateShader(GL_VERTEX_SHADER)
    dev.frag_shdr = glCreateShader(GL_FRAGMENT_SHADER)

    let vertCStringArray = allocCStringArray([vertex_shader])
    let fragCStringArray = allocCStringArray([fragment_shader])
    glShaderSource(dev.vert_shdr, 1, vertCStringArray, nil)
    glShaderSource(dev.frag_shdr, 1, fragCStringArray, nil)
    glCompileShader(dev.vert_shdr)
    glCompileShader(dev.frag_shdr)
    glGetShaderiv(dev.vert_shdr, GL_COMPILE_STATUS, addr(status))
    assert(status == GL_TRUE.cint)
    glGetShaderiv(dev.frag_shdr, GL_COMPILE_STATUS, addr(status))
    assert(status == GL_TRUE.cint)
    glAttachShader(dev.prog, dev.vert_shdr)
    glAttachShader(dev.prog, dev.frag_shdr)
    glLinkProgram(dev.prog)
    glGetProgramiv(dev.prog, GL_LINK_STATUS, addr(status))
    assert(status == GL_TRUE.cint)
    dev.uniform_tex = glGetUniformLocation(dev.prog, "Texture")
    dev.uniform_proj = glGetUniformLocation(dev.prog, "ProjMtx")
    dev.attrib_pos = glGetAttribLocation(dev.prog, "Position")
    dev.attrib_uv = glGetAttribLocation(dev.prog, "TexCoord")
    dev.attrib_col = glGetAttribLocation(dev.prog, "Color")
    ##  buffer setup
    var vs: GLsizei = GLsizei sizeof(nk_glfw_vertex)
    glGenBuffers(1, addr(dev.vbo))
    glGenBuffers(1, addr(dev.ebo))
    glGenVertexArrays(1, addr(dev.vao))
    glBindVertexArray(dev.vao)
    glBindBuffer(GL_ARRAY_BUFFER, dev.vbo)
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, dev.ebo)
    glEnableVertexAttribArray(cast[GLuint](dev.attrib_pos))
    glEnableVertexAttribArray(cast[GLuint](dev.attrib_uv))
    glEnableVertexAttribArray(cast[GLuint](dev.attrib_col))
    glVertexAttribPointer(GLuint dev.attrib_pos, GLint 2, cGL_FLOAT, GL_FALSE, GLsizei sizeof(nk_glfw_vertex), nil)
    glVertexAttribPointer(GLuint dev.attrib_uv, GLint 2, cGL_FLOAT, GL_FALSE, GLsizei sizeof(nk_glfw_vertex), cast[pointer](sizeof(array[2, cfloat])))
    glVertexAttribPointer(GLuint dev.attrib_col, GLint 4, cGL_UNSIGNED_BYTE, GL_TRUE, GLsizei sizeof(nk_glfw_vertex), cast[pointer](sizeof(array[2, cfloat]) * 2))
    glBindTexture(GL_TEXTURE_2D, 0)
    glBindBuffer(GL_ARRAY_BUFFER, 0)
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0)
    glBindVertexArray(0)

proc nk_glfw3_init*(win: glfw.Window; init_state: nk_glfw_init_state): ptr nk_context =
    nukGLFW.win = win
    #if init_state == NK_GLFW3_INSTALL_CALLBACKS:
      #glfwSetScrollCallback(win, nk_gflw3_scroll_callback)
      #glfwSetCharCallback(win, nk_glfw3_char_callback)
    discard nk_init_default(addr(nukGLFW.ctx), nil)
    #nukGLFW.ctx.clip.copy = nk_glfw3_clipbard_copy
    #nukGLFW.ctx.clip.paste = nk_glfw3_clipbard_paste
    #nukGLFW.ctx.clip.userdata = nk_handle_ptr(0)
    nk_glfw3_device_create()
    return addr(nukGLFW.ctx)

proc nk_glfw3_font_stash_begin*(atlas: ptr ptr nk_font_atlas) =
  nk_font_atlas_init_default(addr(nukGLFW.atlas))
  nk_font_atlas_begin(addr(nukGLFW.atlas))
  atlas[] = addr(nukGLFW.atlas)

proc nk_glfw3_device_upload_atlas*(image: pointer; width: cint; height: cint) =
  var dev: ptr nk_glfw_device = addr(nukGLFW.ogl)
  glGenTextures(1, addr(dev.font_tex))
  glBindTexture(GL_TEXTURE_2D, dev.font_tex)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
  glTexImage2D(GL_TEXTURE_2D, GLint 0, GLint GL_RGBA, cast[GLsizei](width),
               cast[GLsizei](height), 0, GL_RGBA, GL_UNSIGNED_BYTE, image)


proc nk_glfw3_font_stash_end*() =
  var image: pointer
  var
    w: cint
    h: cint
  image = nk_font_atlas_bake(addr(nukGLFW.atlas), addr(w), addr(h), NK_FONT_ATLAS_RGBA32)
  nk_glfw3_device_upload_atlas(image, w, h)
  nk_font_atlas_end(addr(nukGLFW.atlas),
                    nk_handle_id(cast[cint](nukGLFW.ogl.font_tex)),
                    addr(nukGLFW.ogl.null))
  if not nukGLFW.atlas.default_font.isNil:
    nk_style_set_font(addr(nukGLFW.ctx), addr(nukGLFW.atlas.default_font.handle))
  
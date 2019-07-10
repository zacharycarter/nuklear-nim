
import 
  bgfxdotnim as bgfx, 
  nuklear,
  sdl2 as sdl

import
  ../roboto_regular,
  fpumath

import
  imgui_fs,
  imgui_vs

const TEXT_MAX* = 256

type
  bgfx_vertex* = object
    position: array[2, cfloat]
    uv: array[2, cfloat]
    col: array[4, nk_byte]

type
  IMGUIDevice = object
    cmds: nk_buffer
    vsh: bgfx_shader_handle_t
    fsh: bgfx_shader_handle_t
    sph: bgfx_program_handle_t
    vdecl: ptr bgfx_vertex_decl_t
    uh: bgfx_uniform_handle_t
    cc: nk_convert_config
    null: nk_draw_null_texture
    fah: bgfx_texture_handle_t
    vb: nk_buffer
    ib: nk_buffer
    vertexLayout: array[4, nk_draw_vertex_layout_element]

var
  ctx*: nk_context
  dev*: IMGUIDevice
  fa*: nk_font_atlas
  textLen*: int
  text*: string
  scroll: float
  projection: array[16, cfloat]
  viewId:uint8

proc get_avail_transient_vertex_buffers(vertexCount: uint32, vdecl: ptr bgfx_vertex_decl_t) : bool =
  if bgfx_get_avail_transient_vertex_buffer(vertexCount, vdecl) >= vertexCount:
    return true
  return false

proc get_avail_transient_index_buffers(vdecl: ptr bgfx_vertex_decl_t, indexCount: uint32) : bool =
  if bgfx_get_avail_transient_index_buffer(indexCount) >= indexCount:
    return true
  return false

proc init*(vid: uint8): bool =
  viewId = vid
  text = newString(TEXT_MAX)
  # discard glfw.SetCharCallback(graphics.rootWindow, glfw_char_callback)
  let rendererType = bgfx_get_renderer_type()
  nk_buffer_init_default(addr dev.cmds)
  dev.vsh = bgfx_create_shader(bgfx_make_ref(addr vs[0], uint32 sizeof(vs)))
  dev.fsh = bgfx_create_shader(bgfx_make_ref(addr fs[0], uint32 sizeof(fs)))
  dev.sph = bgfx_create_program(dev.vsh, dev.fsh, true)

  dev.uh = bgfx_create_uniform("s_texture", BGFX_UNIFORM_TYPE_SAMPLER, 1)

  dev.vdecl = createShared(bgfx_vertex_decl_t)
  bgfx_vertex_decl_begin(dev.vdecl, rendererType)
  bgfx_vertex_decl_add(dev.vdecl, BGFX_ATTRIB_POSITION, 2, BGFX_ATTRIB_TYPE_FLOAT, false, false)
  bgfx_vertex_decl_add(dev.vdecl, BGFX_ATTRIB_TEXCOORD0, 2, BGFX_ATTRIB_TYPE_FLOAT, false, false)
  bgfx_vertex_decl_add(dev.vdecl, BGFX_ATTRIB_COLOR0, 4, BGFX_ATTRIB_TYPE_UINT8, true, false)
  bgfx_vertex_decl_end(dev.vdecl)
  
  dev.vertexLayout = [
    nk_draw_vertex_layout_element(
        attribute: NK_VERTEX_POSITION,
        format: NK_FORMAT_FLOAT, 
        offset: dev.vdecl.offset[BGFX_ATTRIB_POSITION]
      ),
      nk_draw_vertex_layout_element(
        attribute: NK_VERTEX_TEXCOORD,
        format: NK_FORMAT_FLOAT, 
        offset: dev.vdecl.offset[BGFX_ATTRIB_TEXCOORD0]
      ),
      nk_draw_vertex_layout_element(
        attribute: NK_VERTEX_COLOR,
        format: NK_FORMAT_R8G8B8A8, 
        offset: dev.vdecl.offset[BGFX_ATTRIB_COLOR0]
      ),
      nk_draw_vertex_layout_element(
        attribute: NK_VERTEX_ATTRIBUTE_COUNT,
        format: NK_FORMAT_COUNT,
        offset: 0
      )
  ]

  dev.cc.vertex_layout = addr dev.vertexLayout[0]
  dev.cc.vertex_size = nk_size sizeof(bgfx_vertex)
  dev.cc.vertex_alignment = nk_size alignof(bgfx_vertex)
  dev.cc.null = dev.null
  dev.cc.circle_segment_count = 22
  dev.cc.curve_segment_count = 22
  dev.cc.arc_segment_count = 22
  dev.cc.global_alpha = 1.0
  dev.cc.shape_AA = NK_ANTIALIASING_OFF
  dev.cc.line_AA = NK_ANTIALIASING_OFF

  discard nk_init_default(addr ctx, nil)

  nk_font_atlas_init_default(addr fa)
  nk_font_atlas_begin(addr fa)

  let roboto_ttf = addr s_robotoRegularTtf

  var fontConfig = nk_font_config(
    oversample_h: cuchar 3,
    oversample_v: cuchar 2
  )
  var font = nk_font_atlas_add_from_memory(addr fa, roboto_ttf, nk_size sizeof(s_robotoRegularTtf), 18, nil)
  # var font = nk_font_atlas_add_from_file(addr fa, "NotoSans-Regular.ttf", 18, nil)
  # Uncomment for default font
  # var font = nk_font_atlas_add_default(addr fa, 13, nil)

  var w, h : cint
  let image = nk_font_atlas_bake(addr fa, addr w, addr h, NK_FONT_ATLAS_RGBA32)
  echo w
  echo h
  let layerBytes = uint32(w * h * 4)
  # var mem = bgfx_alloc(layerBytes)
  # echo mem.size
  # copyMem(addr mem.data, image, layerBytes)
  let mem = bgfx_copy(image, layerBytes)
  dev.fah = bgfx_create_texture_2d(uint16 w, uint16 h, false, 1, BGFX_TEXTURE_FORMAT_RGBA8, 0, mem)
  nk_font_atlas_end(addr fa, nk_handle_id(cint dev.fah.idx), addr dev.null)

  # if fa.default_font != nil:
  #   nk_style_set_font(addr ctx, addr fa.default_font.handle)
  nk_style_set_font(addr ctx, addr font.handle)

  return true

proc setProjectionMatrix*(projectionMatrix: Mat4, view: uint8) =
  projection = projectionMatrix
  bgfx_set_view_transform(view, nil, addr projection[0])

# proc startUpdate*(imgui: var IMGUI) =
#   openInput(ctx)

# proc finishUpdate*(imgui: var IMGUI) =
#   closeInput(ctx)

var background: nk_colorf = nk_color_cf(nk_rgb(28,48,62))

proc render*() =
  var ortho: Mat4
  let caps = bgfx_get_caps()
  mtxOrtho(ortho, 0.0, 960'f32, 540'f32, 0.0, 0.0, 1000.0, 0.0, caps.homogeneousDepth)
  bgfx_set_view_transform(0, nil, addr ortho[0])
  bgfx_set_view_rect(0, 0, 0, 960'u16, 540'u16)

  if nk_begin(addr ctx, "test", new_nk_rect(50, 50, 230, 250), NK_WINDOW_BORDER.ord or NK_WINDOW_MOVABLE.ord or NK_WINDOW_SCALABLE.ord or NK_WINDOW_MINIMIZABLE.ord or NK_WINDOW_TITLE.ord) != 0:
    const
      EASY = false
      HARD = true

    var op: bool = EASY

    var property: cint = 20

    nk_layout_row_static(addr ctx, 30, 80, 1)
    if nk_button_label(addr ctx, "button").bool: echo "button pressed"
    nk_layout_row_dynamic(addr ctx, 30, 2)

    if nk_option_label(addr ctx, "easy", (op == EASY).cint).bool:
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

  
  bgfx_touch(0)
  var tvb : bgfx_transient_vertex_buffer_t
  var tib : bgfx_transient_index_buffer_t
  # if get_avail_transient_vertex_buffers(65536, dev.vdecl) and
  #   get_avail_transient_index_buffers(dev.vdecl, 65536*2):

  nk_buffer_init_default(addr dev.vb)
  nk_buffer_init_default(addr dev.ib)

  discard nk_convert(addr ctx, addr dev.cmds, addr dev.vb, addr dev.ib, addr dev.cc)
      
  bgfx_alloc_transient_vertex_buffer(addr tvb, uint32(dev.vb.allocated div dev.vdecl.stride), dev.vdecl)
  copyMem(tvb.data, dev.vb.memory.`ptr`, dev.vb.allocated)

  bgfx_alloc_transient_index_buffer(addr tib, uint32(dev.ib.allocated.int / sizeof(uint16)))
  copyMem(tib.data, dev.ib.memory.`ptr`, dev.ib.allocated)
  
  var offset : uint32 = 0
  var cmd : ptr nk_draw_command = nk_draw_begin(addr ctx, addr dev.cmds)
  while not isNil(cmd):
    if cmd.elem_count == 0:
      continue
    
    let scissorX : uint16 = uint16 max(cmd.clip_rect.x, 0.0)
    let scissorY : uint16 = uint16 max(cmd.clip_rect.y, 0.0)
    let scissorW : uint16 = uint16 min(cmd.clip_rect.w, 0.0)
    let scissorH : uint16 = uint16 min(cmd.clip_rect.h, 0.0)
    # discard bgfx_set_scissor(scissorX, scissorY, scissorW, scissorH)

    bgfx_set_state( 0'u64 or BGFX_STATE_WRITE_RGB or BGFX_STATE_WRITE_A or
                        BGFX_STATE_BLEND_FUNC( BGFX_STATE_BLEND_SRC_ALPHA, BGFX_STATE_BLEND_INV_SRC_ALPHA ), 0)
    
    bgfx_set_texture(0, dev.uh, dev.fah, high(uint32))

    bgfx_set_transient_vertex_buffer(0, addr tvb, 0, uint32(dev.vb.allocated div dev.vdecl.stride))
    bgfx_set_transient_index_buffer( addr tib, offset, cmd.elem_count)

    bgfx_submit(0, dev.sph, 0, false)

    offset += cmd.elem_count

    cmd = nk_draw_next(cmd, addr dev.cmds, addr ctx)
  nk_clear(addr ctx)

proc dispose*() =
  bgfx_destroy_texture(dev.fah)
  bgfx_destroy_uniform(dev.uh)
  bgfx_destroy_program(dev.sph)

  freeShared(dev.vdecl)
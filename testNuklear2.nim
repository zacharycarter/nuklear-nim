import glfw3 as glfw, opengl

import nuklear/nuklearpp

type device = object
  cmds: nk_buffer
  null: nk_draw_null_texture
  font_tex: GLuint

var ctx : nk_context
var ctxp : ptr nk_context
var dev : device = device()

var fontAtlas : nk_font_atlas
var fontConfig : nk_font_config

var w, h: cint = 0

nk_font_atlas_init_default(addr fontAtlas)

nk_font_atlas_begin(addr fontAtlas)

let font =  nk_font_atlas_add_default(addr fontAtlas, 13, nil)

let image = nk_font_atlas_bake(addr fontAtlas, addr w, addr h, NK_FONT_ATLAS_RGBA32)

nk_font_atlas_end(addr fontAtlas, nk_handle_id(cint dev.font_tex), addr dev.null)

discard nk_init_default(addr ctx, addr font.handle)

nk_font_atlas_init_default(addr fontAtlas)

echo nk_begin(addr ctx, "test", nk_rect(0,0,5,5), nk_flags NK_WINDOW_TITLE.cint)

nk_end(addr ctx)
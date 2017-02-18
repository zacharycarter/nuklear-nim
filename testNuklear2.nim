import glfw3 as glfw, opengl

import nuklear/nuklearpp

var ctx : nk_context
var ctxp : ptr nk_context

discard nk_init_default(addr ctx, nil)

echo nk_begin(addr ctx, "test", nk_rect(0,0,5,5), nk_flags 0)
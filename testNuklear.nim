import glfw3 as glfw, opengl

import nuklear/nuklearpp
import nuklear/nuklear_glfw3

const
  NK_INCLUDE_FIXED_TYPES* = true
  NK_INCLUDE_STANDARD_IO* = true
  NK_INCLUDE_STANDARD_VARARGS* = true
  NK_INCLUDE_DEFAULT_ALLOCATOR* = true
  NK_INCLUDE_VERTEX_BUFFER_OUTPUT* = true
  NK_INCLUDE_FONT_BAKING* = true
  NK_INCLUDE_DEFAULT_FONT* = true
  NK_IMPLEMENTATION* = true

const
  WINDOW_WIDTH* = 1200
  WINDOW_HEIGHT* = 800
  MAX_VERTEX_BUFFER* = 512 * 1024
  MAX_ELEMENT_BUFFER* = 128 * 1024

template UNUSED*(a: untyped): untyped =
  cast[nil](a)

template MIN*(a, b: untyped): untyped =
  (if (a) < (b): (a) else: (b))

template MAX*(a, b: untyped): untyped =
  (if (a) < (b): (b) else: (a))

template LEN*(a: untyped): untyped =
  (sizeof((a) div sizeof((a)[0])))

proc error_callback*(e: cint; d: cstring) {.cdecl.} =
  setupForeignThreadGc()
  echo d

proc main*(): cint =
  ##  Platform
  var win: glfw.Window
  var
    width: cint = 0
    height: cint = 0
  var ctx: ptr nk_context
  var background: nk_color
  ##  GLFW
  discard glfw.SetErrorCallback(error_callback)
  if glfw.Init() == 0:
    echo "GLFW FAILED TO INIT"
    quit(QUIT_FAILURE)
  glfw.WindowHint(CONTEXT_VERSION_MAJOR, 3)
  glfw.WindowHint(CONTEXT_VERSION_MINOR, 3)
  glfw.WindowHint(OPENGL_PROFILE, OPENGL_CORE_PROFILE)
  glfw.WindowHint(OPENGL_FORWARD_COMPAT, GL_TRUE.cint)
  win = glfw.CreateWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Demo", nil, nil)
  glfw.MakeContextCurrent(win)
  glfw.GetWindowSize(win, addr(width), addr(height))
  ##  OpenGL
  loadExtensions()
  glViewport(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
  ctx = nk_glfw3_init(win, NK_GLFW3_INSTALL_CALLBACKS)
  
  ##  Load Fonts: if none of these are loaded a default font will be used
  ##  Load Cursor: if you uncomment cursor loading please hide the cursor
  var atlas: ptr nk_font_atlas
  nk_glfw3_font_stash_begin(addr(atlas))
  ## struct nk_font *droid = nk_font_atlas_add_from_file(atlas, "../../../extra_font/DroidSans.ttf", 14, 0);
  ## struct nk_font *roboto = nk_font_atlas_add_from_file(atlas, "../../../extra_font/Roboto-Regular.ttf", 14, 0);
  ## struct nk_font *future = nk_font_atlas_add_from_file(atlas, "../../../extra_font/kenvector_future_thin.ttf", 13, 0);
  ## struct nk_font *clean = nk_font_atlas_add_from_file(atlas, "../../../extra_font/ProggyClean.ttf", 12, 0);
  ## struct nk_font *tiny = nk_font_atlas_add_from_file(atlas, "../../../extra_font/ProggyTiny.ttf", 10, 0);
  ## struct nk_font *cousine = nk_font_atlas_add_from_file(atlas, "../../../extra_font/Cousine-Regular.ttf", 13, 0);
  nk_glfw3_font_stash_end()
  ## nk_style_load_all_cursors(ctx, atlas->cursors);
  ## nk_style_set_font(ctx, &droid->handle);
  ##  style.c
  ## set_style(ctx, THEME_WHITE);
  ## set_style(ctx, THEME_RED);
  ## set_style(ctx, THEME_BLUE);
  ## set_style(ctx, THEME_DARK);
  background = nk_rgb(28, 48, 62)
  
  while glfw.WindowShouldClose(win) != 1:
    ##  Input
    glfw.PollEvents()
    nk_glfw3_new_frame()
    ##  GUI
    echo nk_begin(ctx, "Demo", nk_rect(50, 50, 230, 250), nk_flags NK_WINDOW_BORDER.cint or
        NK_WINDOW_MOVABLE.cint or NK_WINDOW_SCALABLE.cint or NK_WINDOW_MINIMIZABLE.cint or
        NK_WINDOW_TITLE.cint)
      #const
      #  EASY = 0
      #  HARD = 1
      #var op: cint = EASY
      #var property: cint = 20
      #nk_layout_row_static(ctx, 30, 80, 1)
      #if nk_button_label(ctx, "button"): fprintf(stdout, "button pressed\x0A")
      #nk_layout_row_dynamic(ctx, 30, 2)
      #if nk_option_label(ctx, "easy", op == EASY): op = EASY
      #if nk_option_label(ctx, "hard", op == HARD): op = HARD
      #nk_layout_row_dynamic(ctx, 25, 1)
      #nk_property_int(ctx, "Compression:", 0, addr(property), 100, 10, 1)
      #nk_layout_row_dynamic(ctx, 20, 1)
      #nk_label(ctx, "background:", NK_TEXT_LEFT)
      #nk_layout_row_dynamic(ctx, 25, 1)
      #if nk_combo_begin_color(ctx, background, nk_vec2(nk_widget_width(ctx), 400)):
      #  nk_layout_row_dynamic(ctx, 120, 1)
      #  background = nk_color_picker(ctx, background, NK_RGBA)
      #  nk_layout_row_dynamic(ctx, 25, 1)
      #  background.r = cast[nk_byte](nk_propertyi(ctx, "#R:", 0, background.r, 255, 1, 1))
      #  background.g = cast[nk_byte](nk_propertyi(ctx, "#G:", 0, background.g, 255, 1, 1))
      #  background.b = cast[nk_byte](nk_propertyi(ctx, "#B:", 0, background.b, 255, 1, 1))
      #  background.a = cast[nk_byte](nk_propertyi(ctx, "#A:", 0, background.a, 255, 1, 1))
      #  nk_combo_end(ctx)
    nk_end(ctx)
    ##  -------------- EXAMPLES ----------------
    ## calculator(ctx);
    ## overview(ctx);
    ## node_editor(ctx);
    ##  -----------------------------------------
    ##  Draw
    var bg: array[4, cfloat]
    #nk_color_fv(bg, background)
    glfw.GetWindowSize(win, addr(width), addr(height))
    glViewport(0, 0, width, height)
    glClear(GL_COLOR_BUFFER_BIT)
    glClearColor(bg[0], bg[1], bg[2], bg[3])
    ##  IMPORTANT: `nk_glfw_render` modifies some global OpenGL state
    ##  with blending, scissor, face culling, depth test and viewport and
    ##  defaults everything back into a default state.
    ##  Make sure to either a.) save and restore or b.) reset your own state after
    ##  rendering the UI.
    #nk_glfw3_render(NK_ANTI_ALIASING_ON, MAX_VERTEX_BUFFER, MAX_ELEMENT_BUFFER)
    glfw.SwapBuffers(win)
  #nk_glfw3_shutdown()
  glfw.Terminate()
  return 0

discard main()
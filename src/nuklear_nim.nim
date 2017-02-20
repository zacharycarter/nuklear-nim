{.deadCodeElim: on.}

{.compile: "bind.c".}

type
  nk_char* = char
  nk_uchar* = cuchar
  nk_byte* = cuchar
  nk_short* = cshort
  nk_ushort* = cushort
  nk_int* = cint
  nk_uint* = cuint
  nk_size* = culong
  nk_ptr* = culong
  nk_hash* = nk_uint
  nk_flags* = nk_uint
  nk_rune* = nk_uint
  dummy_array407* = array[if (sizeof((nk_short)) == 2): 1 else: - 1, char]
  dummy_array408* = array[if (sizeof((nk_ushort)) == 2): 1 else: - 1, char]
  dummy_array409* = array[if (sizeof((nk_uint)) == 4): 1 else: - 1, char]
  dummy_array410* = array[if (sizeof((nk_int)) == 4): 1 else: - 1, char]
  dummy_array411* = array[if (sizeof((nk_byte)) == 1): 1 else: - 1, char]
  dummy_array412* = array[if (sizeof((nk_flags)) >= 4): 1 else: - 1, char]
  dummy_array413* = array[if (sizeof((nk_rune)) >= 4): 1 else: - 1, char]
  dummy_array414* = array[if (sizeof((nk_size)) >= sizeof(pointer)): 1 else: - 1, char]
  dummy_array415* = array[if (sizeof((nk_ptr)) >= sizeof(pointer)): 1 else: - 1, char]
 #nk_buffer* = object
  

## struct nk_allocator;


#type
  #nk_command_buffer* = object
  
  #nk_draw_command* = object
  

## struct nk_convert_config;

type
  #nk_style_item* = object
  
  #nk_text_edit* = object
  
  #nk_draw_list* = object
  
  #nk_user_font* = object
  
  #nk_panel* = object
  
  #nk_context* = object
  
  #nk_draw_vertex_layout_element* = object
  
  #nk_style_button* = object
  
  #nk_style_toggle* = object
  
  #nk_style_selectable* = object
  
  nk_style_slide* = object
  
  #nk_style_progress* = object
  
  #nk_style_scrollbar* = object
  
  #nk_style_edit* = object
  
  #nk_style_property* = object
  
  #nk_style_chart* = object
  
  #nk_style_combo* = object
  
  #nk_style_tab* = object
  
  #nk_style_window_header* = object
  
  #nk_style_window* = object
  

const
  nk_false* = 0
  nk_true* = 1

type
  nk_color* = object
    r*: nk_byte
    g*: nk_byte
    b*: nk_byte
    a*: nk_byte

  nuk_colorf* = object
    r*: cfloat
    g*: cfloat
    b*: cfloat
    a*: cfloat

  nuk_vec2* = object
    x*: cfloat
    y*: cfloat

  nuk_vec2i* = object
    x*: cshort
    y*: cshort

  nuk_rect* = object
    x*: cfloat
    y*: cfloat
    w*: cfloat
    h*: cfloat

  nuk_recti* = object
    x*: cshort
    y*: cshort
    w*: cshort
    h*: cshort

  nk_glyph* = array[4, char]
  nk_handle* = object {.union.}
    `ptr`*: pointer
    id*: cint

  nuk_image* = object
    handle*: nk_handle
    w*: cushort
    h*: cushort
    region*: array[4, cushort]

  nk_cursor* = object
    img*: nuk_image
    size*: nuk_vec2
    offset*: nuk_vec2

  nk_scroll* = object
    x*: nk_uint
    y*: nk_uint

  nk_heading* {.size: sizeof(cint).} = enum
    NK_UP, NK_RIGHT, NK_DOWN, NK_LEFT

type
  nk_user_font_glyph* = object
    uv*: array[2, nuk_vec2]      ##  texture coordinates
    offset*: nuk_vec2           ##  offset between top left and glyph
    width*: cfloat
    height*: cfloat            ##  size of the glyph
    xadvance*: cfloat          ##  offset to the next glyph
  
  nk_text_width_f* = proc (a2: nk_handle; h: cfloat; a4: cstring; len: cint): cfloat {.cdecl.}
  nk_query_font_glyph_f* = proc (handle: nk_handle; font_height: cfloat;
                              glyph: ptr nk_user_font_glyph; codepoint: nk_rune;
                              next_codepoint: nk_rune) {.cdecl.}
  nk_user_font* = object
    userdata*: nk_handle
    height*: cfloat
    width*: nk_text_width_f
    query* :nk_query_font_glyph_f
    texture*: nk_handle

  nk_font_coord_type* {.size: sizeof(cint).} = enum
    NK_COORD_UV, NK_COORD_PIXEL

  nk_memory_status* = object
    memory*: pointer
    `type`*: cuint
    size*: nk_size
    allocated*: nk_size
    needed*: nk_size
    calls*: nk_size

  nk_allocation_type* {.size: sizeof(cint).} = enum
    NK_BUFFER_FIXED, NK_BUFFER_DYNAMIC


type
  nk_buffer_allocation_type* {.size: sizeof(cint).} = enum
    NK_BUFFER_FRONT, NK_BUFFER_BACK, NK_BUFFER_MAX

type
  nk_anti_aliasing* {.size: sizeof(cint).} = enum
    NK_ANTI_ALIASING_OFF, NK_ANTI_ALIASING_ON

type
  nk_plugin_alloc* = proc (a2: nk_handle; old: pointer; a4: nk_size): pointer {.cdecl.}
  nk_plugin_free* = proc (a2: nk_handle; old: pointer) {.cdecl.}
  nk_allocator* = object
    userdata*: nk_handle
    alloc*: nk_plugin_alloc
    free*: nk_plugin_free

  nk_buffer_marker* = object
    active*: cint
    offset*: nk_size

  nk_memory* = object
    `ptr`*: pointer
    size*: nk_size

  nk_buffer* = object
    marker*: array[NK_BUFFER_MAX, nk_buffer_marker]
    pool*: nk_allocator
    `type`*: nk_allocation_type
    memory*: nk_memory
    grow_factor*: cfloat
    allocated*: nk_size
    needed*: nk_size
    calls*: nk_size
    size*: nk_size

type
  nk_command_buffer* = object
    base*: ptr nk_buffer
    clip*: nuk_rect
    use_clipping*: cint
    userdata*: nk_handle
    begin*: nk_size
    `end`*: nk_size
    last*: nk_size

type
  nk_panel_type* {.size: sizeof(cint).} = enum
    NK_PANEL_WINDOW = (1 shl (0)), NK_PANEL_GROUP = (1 shl (1)),
    NK_PANEL_POPUP = (1 shl (2)), NK_PANEL_CONTEXTUAL = (1 shl (4)),
    NK_PANEL_COMBO = (1 shl (5)), NK_PANEL_MENU = (1 shl (6)),
    NK_PANEL_TOOLTIP = (1 shl (7))

type
  nk_chart_type* {.size: sizeof(cint).} = enum
    NK_CHART_LINES, NK_CHART_COLUMN, NK_CHART_MAX

type
  nk_style_item_type* {.size: sizeof(cint).} = enum
    NK_STYLE_ITEM_COLOR, NK_STYLE_ITEM_IMAGE

type
  nk_button_behavior* {.size: sizeof(cint).} = enum
    NK_BUTTON_DEFAULT, NK_BUTTON_REPEATER

type
  nk_buttons* {.size: sizeof(cint).} = enum
    NK_BUTTON_LEFT, NK_BUTTON_MIDDLE, NK_BUTTON_RIGHT, NK_BUTTON_MAX

type
  nk_keys* {.size: sizeof(cint).} = enum
    NK_KEY_NONE, NK_KEY_SHIFT, NK_KEY_CTRL, NK_KEY_DEL, NK_KEY_ENTER, NK_KEY_TAB,
    NK_KEY_BACKSPACE, NK_KEY_COPY, NK_KEY_CUT, NK_KEY_PASTE, NK_KEY_UP, NK_KEY_DOWN,
    NK_KEY_LEFT, NK_KEY_RIGHT, NK_KEY_TEXT_INSERT_MODE, NK_KEY_TEXT_REPLACE_MODE,
    NK_KEY_TEXT_RESET_MODE, NK_KEY_TEXT_LINE_START, NK_KEY_TEXT_LINE_END,
    NK_KEY_TEXT_START, NK_KEY_TEXT_END, NK_KEY_TEXT_UNDO, NK_KEY_TEXT_REDO,
    NK_KEY_TEXT_SELECT_ALL, NK_KEY_TEXT_WORD_LEFT, NK_KEY_TEXT_WORD_RIGHT,
    NK_KEY_SCROLL_START, NK_KEY_SCROLL_END, NK_KEY_SCROLL_DOWN, NK_KEY_SCROLL_UP,
    NK_KEY_MAX

type
  nk_style_cursor* {.size: sizeof(cint).} = enum
    NK_CURSOR_ARROW, NK_CURSOR_TEXT, NK_CURSOR_MOVE, NK_CURSOR_RESIZE_VERTICAL,
    NK_CURSOR_RESIZE_HORIZONTAL, NK_CURSOR_RESIZE_TOP_LEFT_DOWN_RIGHT,
    NK_CURSOR_RESIZE_TOP_RIGHT_DOWN_LEFT, NK_CURSOR_COUNT

type
  nk_draw_vertex_layout_attribute* {.size: sizeof(cint).} = enum
    NK_VERTEX_POSITION, NK_VERTEX_COLOR, NK_VERTEX_TEXCOORD,
    NK_VERTEX_ATTRIBUTE_COUNT

type
  nk_draw_vertex_layout_format* {.size: sizeof(cint).} = enum
    NK_FORMAT_SCHAR, NK_FORMAT_SSHORT, NK_FORMAT_SINT, NK_FORMAT_UCHAR,
    NK_FORMAT_USHORT, NK_FORMAT_UINT, NK_FORMAT_FLOAT, NK_FORMAT_DOUBLE,
    NK_FORMAT_COLOR_BEGIN, NK_FORMAT_R16G15B16, NK_FORMAT_R32G32B32,
    NK_FORMAT_R8G8B8A8, NK_FORMAT_R16G15B16A16, NK_FORMAT_R32G32B32A32,
    NK_FORMAT_R32G32B32A32_FLOAT, NK_FORMAT_R32G32B32A32_DOUBLE, NK_FORMAT_RGB32,
    NK_FORMAT_RGBA32, NK_FORMAT_COUNT

type
  nk_draw_vertex_layout_element* = object
    attribute*: nk_draw_vertex_layout_attribute
    format*: nk_draw_vertex_layout_format
    offset*: nk_size

  nk_draw_command* = object
    elem_count*: cuint
    clip_rect*: nuk_rect
    texture*: nk_handle

  nk_draw_list* = object
    clip_rect*: nuk_rect
    circle_vtx*: array[12, nuk_vec2]
    config*: nk_convert_config
    buffer*: ptr nk_buffer
    vertices*: ptr nk_buffer
    elements*: ptr nk_buffer
    element_count*: cuint
    vertex_count*: cuint
    cmd_count*: cuint
    cmd_offset*: nk_size
    path_count*: cuint
    path_offset*: cuint

  nk_draw_null_texture* = object
    texture*: nk_handle
    uv*: nuk_vec2

  nk_convert_config* = object
    global_alpha*: cfloat
    line_AA*: nk_anti_aliasing
    shape_AA*: nk_anti_aliasing
    circle_segment_count*: cuint
    arc_segment_count*: cuint
    curve_segment_count*: cuint
    null*: nk_draw_null_texture
    vertex_layout*: ptr nk_draw_vertex_layout_element
    vertex_size*: nk_size
    vertex_alignment*: nk_size

  nk_list_view* = object
    begin*: cint
    `end`*: cint
    count*: cint
    total_height*: cint
    ctx*: ptr nk_context
    scroll_pointer*: ptr nk_uint
    scroll_value*: nk_uint

  nk_symbol_type* {.size: sizeof(cint).} = enum
    NK_SYMBOL_NONE, NK_SYMBOL_X, NK_SYMBOL_UNDERSCORE, NK_SYMBOL_CIRCLE_SOLID,
    NK_SYMBOL_CIRCLE_OUTLINE, NK_SYMBOL_RECT_SOLID, NK_SYMBOL_RECT_OUTLINE,
    NK_SYMBOL_TRIANGLE_UP, NK_SYMBOL_TRIANGLE_DOWN, NK_SYMBOL_TRIANGLE_LEFT,
    NK_SYMBOL_TRIANGLE_RIGHT, NK_SYMBOL_PLUS, NK_SYMBOL_MINUS, NK_SYMBOL_MAX

  nk_menu_state* = object
    x*: cfloat
    y*: cfloat
    w*: cfloat
    h*: cfloat
    offset*: nk_scroll

  nk_row_layout* = object
    `type`*: nk_panel_row_layout_type
    index*: cint
    height*: cfloat
    columns*: cint
    ratio*: ptr cfloat
    item_width*: cfloat
    item_height*: cfloat
    item_offset*: cfloat
    filled*: cfloat
    item*: nuk_rect
    tree_depth*: cint
    templates*: array[16, cfloat]

  nk_popup_buffer* = object
    begin*: nk_size
    parent*: nk_size
    last*: nk_size
    `end`*: nk_size
    active*: cint

  nk_chart_slot* = object
    `type`*: nk_chart_type
    color*: nk_color
    highlight*: nk_color
    min*: cfloat
    max*: cfloat
    range*: cfloat
    count*: cint
    last*: nuk_vec2
    index*: cint

  nk_chart* = object
    slot*: cint
    x*: cfloat
    y*: cfloat
    w*: cfloat
    h*: cfloat
    slots*: array[4, nk_chart_slot]

  nk_panel_row_layout_type* {.size: sizeof(cint).} = enum
    NK_LAYOUT_DYNAMIC_FIXED = 0, NK_LAYOUT_DYNAMIC_ROW, NK_LAYOUT_DYNAMIC_FREE,
    NK_LAYOUT_DYNAMIC, NK_LAYOUT_STATIC_FIXED, NK_LAYOUT_STATIC_ROW,
    NK_LAYOUT_STATIC_FREE, NK_LAYOUT_STATIC, NK_LAYOUT_TEMPLATE, NK_LAYOUT_COUNT

  nk_panel* = object
    `type`*: nk_panel_type
    flags*: nk_flags
    bounds*: nuk_rect
    offset_x*: ptr nk_uint
    offset_y*: ptr nk_uint
    at_x*: cfloat
    at_y*: cfloat
    max_x*: cfloat
    footer_height*: cfloat
    header_height*: cfloat
    border*: cfloat
    has_scrolling*: cuint
    clip*: nuk_rect
    menu*: nk_menu_state
    row*: nk_row_layout
    chart*: nk_chart
    popup_buffer*: nk_popup_buffer
    buffer*: ptr nk_command_buffer
    parent*: ptr nk_panel

  nk_window* = object
    `seq`*: cuint
    name*: nk_hash
    name_string*: array[64, char]
    flags*: nk_flags
    bounds*: nuk_rect
    scrollbar*: nk_scroll
    buffer*: nk_command_buffer
    layout*: ptr nk_panel
    scrollbar_hiding_timer*: cfloat
    property*: nk_property_state
    popup*: nk_popup_state
    edit*: nk_edit_state
    scrolled*: cuint
    tables*: ptr nk_table
    table_count*: cushort
    table_size*: cushort
    next*: ptr nk_window
    prev*: ptr nk_window
    parent*: ptr nk_window

  nk_popup_state* = object
    win*: ptr nk_window
    `type`*: nk_panel_type
    name*: nk_hash
    active*: cint
    combo_count*: cuint
    con_count*: cuint
    con_old*: cuint
    active_con*: cuint
    header*: nuk_rect

  nk_edit_state* = object
    name*: nk_hash
    `seq`*: cuint
    old*: cuint
    active*: cint
    prev*: cint
    cursor*: cint
    sel_start*: cint
    sel_end*: cint
    scrollbar*: nk_scroll
    mode*: cuchar
    single_line*: cuchar

  nk_property_state* = object
    active*: cint
    prev*: cint
    buffer*: array[64, char]
    length*: cint
    cursor*: cint
    name*: nk_hash
    `seq`*: cuint
    old*: cuint
    state*: cint

  nk_style_item_data* = object {.union.}
    image*: nuk_image
    color*: nk_color

  nk_style_item* = object
    `type`*: nk_style_item_type
    data*: nk_style_item_data

  nk_config_stack_style_item_element* = object
    address*: ptr nk_style_item
    old_value*: nk_style_item

  nk_config_stack_float_element* = object
    address*: ptr cfloat
    old_value*: cfloat

  nk_config_stack_vec2_element* = object
    address*: ptr nuk_vec2
    old_value*: nuk_vec2

  nk_config_stack_flags_element* = object
    address*: ptr nk_flags
    old_value*: nk_flags

  nk_config_stack_color_element* = object
    address*: ptr nk_color
    old_value*: nk_color

  nk_config_stack_user_font_element* = object
    address*: ptr ptr nk_user_font
    old_value*: ptr nk_user_font

  nk_config_stack_button_behavior_element* = object
    address*: ptr nk_button_behavior
    old_value*: nk_button_behavior

  nk_config_stack_style_item* = object
    head*: cint
    elements*: array[16, nk_config_stack_style_item_element]

  nk_config_stack_float* = object
    head*: cint
    elements*: array[32, nk_config_stack_float_element]

  nk_config_stack_vec2* = object
    head*: cint
    elements*: array[16, nk_config_stack_vec2_element]

  nk_config_stack_flags* = object
    head*: cint
    elements*: array[32, nk_config_stack_flags_element]

  nk_config_stack_color* = object
    head*: cint
    elements*: array[32, nk_config_stack_color_element]

  nk_config_stack_user_font* = object
    head*: cint
    elements*: array[8, nk_config_stack_user_font_element]

  nk_config_stack_button_behavior* = object
    head*: cint
    elements*: array[8, nk_config_stack_button_behavior_element]

  nk_configuration_stacks* = object
    style_items*: nk_config_stack_style_item
    floats*: nk_config_stack_float
    vectors*: nk_config_stack_vec2
    flags*: nk_config_stack_flags
    colors*: nk_config_stack_color
    fonts*: nk_config_stack_user_font
    button_behaviors*: nk_config_stack_button_behavior

  nk_table* = object
    `seq`*: cuint
    #keys*: array[(((if (sizeof(nk_window)) < (sizeof(nk_panel)): (sizeof(nk_panel)) else: (
       # sizeof(nk_window))) div sizeof((nk_uint))) div 2), nk_hash]
    #values*: array[(((if (sizeof(nk_window)) < (sizeof(nk_panel)): (sizeof(nk_panel)) else: (
     #   sizeof(nk_window))) div sizeof((nk_uint))) div 2), nk_uint]
    next*: ptr nk_table
    prev*: ptr nk_table

  nk_page_data* = object {.union.}
    tbl*: nk_table
    pan*: nk_panel
    win*: nk_window

  nk_page_element* = object
    data*: nk_page_data
    next*: ptr nk_page_element
    prev*: ptr nk_page_element

  nk_page* = object
    size*: cuint
    next*: ptr nk_page
    win*: array[1, nk_page_element]

  nk_pool* = object
    alloc*: nk_allocator
    `type`*: nk_allocation_type
    page_count*: cuint
    pages*: ptr nk_page
    freelist*: ptr nk_page_element
    capacity*: cuint
    size*: nk_size
    cap*: nk_size

  nk_mouse_button* = object
    down*: cint
    clicked*: cuint
    clicked_pos*: nuk_vec2

  nk_mouse* = object
    buttons*: array[NK_BUTTON_MAX, nk_mouse_button]
    pos*: nuk_vec2
    prev*: nuk_vec2
    delta*: nuk_vec2
    scroll_delta*: cfloat
    grab*: cuchar
    grabbed*: cuchar
    ungrab*: cuchar

  nk_key* = object
    down*: cint
    clicked*: cuint

  nk_keyboard* = object
    keys*: array[NK_KEY_MAX, nk_key]
    text*: array[16, char]
    text_len*: cint

  nk_input* = object
    keyboard*: nk_keyboard
    mouse*: nk_mouse

  nk_context* = object
    input*: nk_input
    style*: nk_style
    memory*: nk_buffer
    clip*: nk_clipboard
    last_widget_state*: nk_flags
    button_behavior*: nk_button_behavior
    stacks*: nk_configuration_stacks
    delta_time_seconds*: cfloat
    draw_list*: nk_draw_list
    text_edit*: nk_text_edit
    overlay*: nk_command_buffer
    build*: cint
    use_pool*: cint
    pool*: nk_pool
    begin*: ptr nk_window
    `end`*: ptr nk_window
    active*: ptr nk_window
    current*: ptr nk_window
    freelist*: ptr nk_page_element
    count*: cuint
    `seq`*: cuint

  nk_plugin_paste* = proc (a2: nk_handle; a3: ptr nk_text_edit) {.cdecl.}
  nk_plugin_copy* = proc (a2: nk_handle; a3: cstring; len: cint) {.cdecl.}
  
  nk_clipboard* = object
    userdata*: nk_handle
    paste*: nk_plugin_paste
    copy*: nk_plugin_copy
    
  nk_text_edit* = object
    clip*: nk_clipboard
    `string`*: nk_str
    filter*: nk_plugin_filter
    scrollbar*: nuk_vec2
    cursor*: cint
    select_start*: cint
    select_end*: cint
    mode*: cuchar
    cursor_at_end_of_line*: cuchar
    initialized*: cuchar
    has_preferred_x*: cuchar
    single_line*: cuchar
    active*: cuchar
    padding1*: cuchar
    preferred_x*: cfloat
    undo*: nk_text_undo_state

  nk_plugin_filter* = proc (a2: ptr nk_text_edit; unicode: nk_rune): cint {.cdecl.}

  nk_text_undo_record* = object
    where*: cint
    insert_length*: cshort
    delete_length*: cshort
    char_storage*: cshort

  nk_text_undo_state* = object
    undo_rec*: array[99, nk_text_undo_record]
    undo_char*: array[999, nk_rune]
    undo_point*: cshort
    redo_point*: cshort
    undo_char_point*: cshort
    redo_char_point*: cshort

  nk_text_edit_type* {.size: sizeof(cint).} = enum
    NK_TEXT_EDIT_SINGLE_LINE, NK_TEXT_EDIT_MULTI_LINE

  nk_style_text* = object
    color*: nk_color
    padding*: nuk_vec2

  nk_style_button* = object
    normal*: nk_style_item
    hover*: nk_style_item
    active*: nk_style_item
    border_color*: nk_color
    text_background*: nk_color
    text_normal*: nk_color
    text_hover*: nk_color
    text_active*: nk_color
    text_alignment*: nk_flags
    border*: cfloat
    rounding*: cfloat
    padding*: nuk_vec2
    image_padding*: nuk_vec2
    touch_padding*: nuk_vec2
    userdata*: nk_handle
    draw_begin*: proc (a2: ptr nk_command_buffer; userdata: nk_handle) {.cdecl.}
    draw_end*: proc (a2: ptr nk_command_buffer; userdata: nk_handle) {.cdecl.}

  nk_style_toggle* = object
    normal*: nk_style_item
    hover*: nk_style_item
    active*: nk_style_item
    border_color*: nk_color
    cursor_normal*: nk_style_item
    cursor_hover*: nk_style_item
    text_normal*: nk_color
    text_hover*: nk_color
    text_active*: nk_color
    text_background*: nk_color
    text_alignment*: nk_flags
    padding*: nuk_vec2
    touch_padding*: nuk_vec2
    spacing*: cfloat
    border*: cfloat
    userdata*: nk_handle
    draw_begin*: proc (a2: ptr nk_command_buffer; a3: nk_handle) {.cdecl.}
    draw_end*: proc (a2: ptr nk_command_buffer; a3: nk_handle) {.cdecl.}

  nk_style_selectable* = object
    normal*: nk_style_item
    hover*: nk_style_item
    pressed*: nk_style_item
    normal_active*: nk_style_item
    hover_active*: nk_style_item
    pressed_active*: nk_style_item
    text_normal*: nk_color
    text_hover*: nk_color
    text_pressed*: nk_color
    text_normal_active*: nk_color
    text_hover_active*: nk_color
    text_pressed_active*: nk_color
    text_background*: nk_color
    text_alignment*: nk_flags
    rounding*: cfloat
    padding*: nuk_vec2
    touch_padding*: nuk_vec2
    image_padding*: nuk_vec2
    userdata*: nk_handle
    draw_begin*: proc (a2: ptr nk_command_buffer; a3: nk_handle) {.cdecl.}
    draw_end*: proc (a2: ptr nk_command_buffer; a3: nk_handle) {.cdecl.}

  nk_style_slider* = object
    normal*: nk_style_item
    hover*: nk_style_item
    active*: nk_style_item
    border_color*: nk_color
    bar_normal*: nk_color
    bar_hover*: nk_color
    bar_active*: nk_color
    bar_filled*: nk_color
    cursor_normal*: nk_style_item
    cursor_hover*: nk_style_item
    cursor_active*: nk_style_item
    border*: cfloat
    rounding*: cfloat
    bar_height*: cfloat
    padding*: nuk_vec2
    spacing*: nuk_vec2
    cursor_size*: nuk_vec2
    show_buttons*: cint
    inc_button*: nk_style_button
    dec_button*: nk_style_button
    inc_symbol*: nk_symbol_type
    dec_symbol*: nk_symbol_type
    userdata*: nk_handle
    draw_begin*: proc (a2: ptr nk_command_buffer; a3: nk_handle) {.cdecl.}
    draw_end*: proc (a2: ptr nk_command_buffer; a3: nk_handle) {.cdecl.}

  nk_style_progress* = object
    normal*: nk_style_item
    hover*: nk_style_item
    active*: nk_style_item
    border_color*: nk_color
    cursor_normal*: nk_style_item
    cursor_hover*: nk_style_item
    cursor_active*: nk_style_item
    cursor_border_color*: nk_color
    rounding*: cfloat
    border*: cfloat
    cursor_border*: cfloat
    cursor_rounding*: cfloat
    padding*: nuk_vec2
    userdata*: nk_handle
    draw_begin*: proc (a2: ptr nk_command_buffer; a3: nk_handle) {.cdecl.}
    draw_end*: proc (a2: ptr nk_command_buffer; a3: nk_handle) {.cdecl.}

  nk_style_scrollbar* = object
    normal*: nk_style_item
    hover*: nk_style_item
    active*: nk_style_item
    border_color*: nk_color
    cursor_normal*: nk_style_item
    cursor_hover*: nk_style_item
    cursor_active*: nk_style_item
    cursor_border_color*: nk_color
    border*: cfloat
    rounding*: cfloat
    border_cursor*: cfloat
    rounding_cursor*: cfloat
    padding*: nuk_vec2
    show_buttons*: cint
    inc_button*: nk_style_button
    dec_button*: nk_style_button
    inc_symbol*: nk_symbol_type
    dec_symbol*: nk_symbol_type
    userdata*: nk_handle
    draw_begin*: proc (a2: ptr nk_command_buffer; a3: nk_handle) {.cdecl.}
    draw_end*: proc (a2: ptr nk_command_buffer; a3: nk_handle) {.cdecl.}

  nk_style_edit* = object
    normal*: nk_style_item
    hover*: nk_style_item
    active*: nk_style_item
    border_color*: nk_color
    scrollbar*: nk_style_scrollbar
    cursor_normal*: nk_color
    cursor_hover*: nk_color
    cursor_text_normal*: nk_color
    cursor_text_hover*: nk_color
    text_normal*: nk_color
    text_hover*: nk_color
    text_active*: nk_color
    selected_normal*: nk_color
    selected_hover*: nk_color
    selected_text_normal*: nk_color
    selected_text_hover*: nk_color
    border*: cfloat
    rounding*: cfloat
    cursor_size*: cfloat
    scrollbar_size*: nuk_vec2
    padding*: nuk_vec2
    row_padding*: cfloat

  nk_style_property* = object
    normal*: nk_style_item
    hover*: nk_style_item
    active*: nk_style_item
    border_color*: nk_color
    label_normal*: nk_color
    label_hover*: nk_color
    label_active*: nk_color
    sym_left*: nk_symbol_type
    sym_right*: nk_symbol_type
    border*: cfloat
    rounding*: cfloat
    padding*: nuk_vec2
    edit*: nk_style_edit
    inc_button*: nk_style_button
    dec_button*: nk_style_button
    userdata*: nk_handle
    draw_begin*: proc (a2: ptr nk_command_buffer; a3: nk_handle) {.cdecl.}
    draw_end*: proc (a2: ptr nk_command_buffer; a3: nk_handle) {.cdecl.}

  nk_style_chart* = object
    background*: nk_style_item
    border_color*: nk_color
    selected_color*: nk_color
    color*: nk_color
    border*: cfloat
    rounding*: cfloat
    padding*: nuk_vec2

  nk_style_combo* = object
    normal*: nk_style_item
    hover*: nk_style_item
    active*: nk_style_item
    border_color*: nk_color
    label_normal*: nk_color
    label_hover*: nk_color
    label_active*: nk_color
    symbol_normal*: nk_color
    symbol_hover*: nk_color
    symbol_active*: nk_color
    button*: nk_style_button
    sym_normal*: nk_symbol_type
    sym_hover*: nk_symbol_type
    sym_active*: nk_symbol_type
    border*: cfloat
    rounding*: cfloat
    content_padding*: nuk_vec2
    button_padding*: nuk_vec2
    spacing*: nuk_vec2

  nk_style_tab* = object
    background*: nk_style_item
    border_color*: nk_color
    text*: nk_color
    tab_maximize_button*: nk_style_button
    tab_minimize_button*: nk_style_button
    node_maximize_button*: nk_style_button
    node_minimize_button*: nk_style_button
    sym_minimize*: nk_symbol_type
    sym_maximize*: nk_symbol_type
    border*: cfloat
    rounding*: cfloat
    indent*: cfloat
    padding*: nuk_vec2
    spacing*: nuk_vec2

  nk_style_header_align* {.size: sizeof(cint).} = enum
    NK_HEADER_LEFT, NK_HEADER_RIGHT

  nk_style_window_header* = object
    normal*: nk_style_item
    hover*: nk_style_item
    active*: nk_style_item
    close_button*: nk_style_button
    minimize_button*: nk_style_button
    close_symbol*: nk_symbol_type
    minimize_symbol*: nk_symbol_type
    maximize_symbol*: nk_symbol_type
    label_normal*: nk_color
    label_hover*: nk_color
    label_active*: nk_color
    align*: nk_style_header_align
    padding*: nuk_vec2
    label_padding*: nuk_vec2
    spacing*: nuk_vec2

  nk_style_window* = object
    header*: nk_style_window_header
    fixed_background*: nk_style_item
    background*: nk_color
    border_color*: nk_color
    popup_border_color*: nk_color
    combo_border_color*: nk_color
    contextual_border_color*: nk_color
    menu_border_color*: nk_color
    group_border_color*: nk_color
    tooltip_border_color*: nk_color
    scaler*: nk_style_item
    border*: cfloat
    combo_border*: cfloat
    contextual_border*: cfloat
    menu_border*: cfloat
    group_border*: cfloat
    tooltip_border*: cfloat
    popup_border*: cfloat
    rounding*: cfloat
    spacing*: nuk_vec2
    scrollbar_size*: nuk_vec2
    min_size*: nuk_vec2
    padding*: nuk_vec2
    group_padding*: nuk_vec2
    popup_padding*: nuk_vec2
    combo_padding*: nuk_vec2
    contextual_padding*: nuk_vec2
    menu_padding*: nuk_vec2
    tooltip_padding*: nuk_vec2

  nk_style* = object
    font*: ptr nk_user_font
    cursors*: array[NK_CURSOR_COUNT, ptr nk_cursor]
    cursor_active*: ptr nk_cursor
    cursor_last*: ptr nk_cursor
    cursor_visible*: cint
    text*: nk_style_text
    button*: nk_style_button
    contextual_button*: nk_style_button
    menu_button*: nk_style_button
    option*: nk_style_toggle
    checkbox*: nk_style_toggle
    selectable*: nk_style_selectable
    slider*: nk_style_slider
    progress*: nk_style_progress
    property*: nk_style_property
    edit*: nk_style_edit
    chart*: nk_style_chart
    scrollh*: nk_style_scrollbar
    scrollv*: nk_style_scrollbar
    tab*: nk_style_tab
    combo*: nk_style_combo
    window*: nk_style_window

  nk_str* = object
    buffer*: nk_buffer
    len*: cint

type
  nk_modify* {.size: sizeof(cint).} = enum
    NK_FIXED = nk_false, NK_MODIFIABLE = nk_true


type
  nk_orientation* {.size: sizeof(cint).} = enum
    NK_VERTICAL, NK_HORIZONTAL


type
  nk_collapse_states* {.size: sizeof(cint).} = enum
    NK_MINIMIZED = nk_false, NK_MAXIMIZED = nk_true


type
  nk_show_states* {.size: sizeof(cint).} = enum
    NK_HIDDEN = nk_false, NK_SHOWN = nk_true


type
  nk_chart_event* {.size: sizeof(cint).} = enum
    NK_CHART_HOVERING = 0x00000001, NK_CHART_CLICKED = 0x00000002


type
  nk_color_format* {.size: sizeof(cint).} = enum
    NK_RGB, NK_RGBA


type
  nk_popup_type* {.size: sizeof(cint).} = enum
    NK_POPUP_STATIC, NK_POPUP_DYNAMIC


type
  nk_layout_format* {.size: sizeof(cint).} = enum
    NK_DYNAMIC, NK_STATIC


type
  nk_tree_type* {.size: sizeof(cint).} = enum
    NK_TREE_NODE, NK_TREE_TAB


type
  nk_style_colors* {.size: sizeof(cint).} = enum
    NK_COLOR_TEXT, NK_COLOR_WINDOW, NK_COLOR_HEADER, NK_COLOR_BORDER,
    NK_COLOR_BUTTON, NK_COLOR_BUTTON_HOVER, NK_COLOR_BUTTON_ACTIVE,
    NK_COLOR_TOGGLE, NK_COLOR_TOGGLE_HOVER, NK_COLOR_TOGGLE_CURSOR,
    NK_COLOR_SELECT, NK_COLOR_SELECT_ACTIVE, NK_COLOR_SLIDER,
    NK_COLOR_SLIDER_CURSOR, NK_COLOR_SLIDER_CURSOR_HOVER,
    NK_COLOR_SLIDER_CURSOR_ACTIVE, NK_COLOR_PROPERTY, NK_COLOR_EDIT,
    NK_COLOR_EDIT_CURSOR, NK_COLOR_COMBO, NK_COLOR_CHART, NK_COLOR_CHART_COLOR,
    NK_COLOR_CHART_COLOR_HIGHLIGHT, NK_COLOR_SCROLLBAR, NK_COLOR_SCROLLBAR_CURSOR,
    NK_COLOR_SCROLLBAR_CURSOR_HOVER, NK_COLOR_SCROLLBAR_CURSOR_ACTIVE,
    NK_COLOR_TAB_HEADER, NK_COLOR_COUNT


type
  nk_widget_layout_states* {.size: sizeof(cint).} = enum
    NK_WIDGET_INVALID, NK_WIDGET_VALID, NK_WIDGET_ROM


type
  nk_widget_states* {.size: sizeof(cint).} = enum
    NK_WIDGET_STATE_MODIFIED = (1 shl (1)), NK_WIDGET_STATE_INACTIVE = (1 shl (2)),
    NK_WIDGET_STATE_ENTERED = (1 shl (3)), NK_WIDGET_STATE_HOVER = (1 shl (4)),
    NK_WIDGET_STATE_ACTIVED = (1 shl (5)), NK_WIDGET_STATE_LEFT = (1 shl (6))
    
const NK_WIDGET_STATE_HOVERED = nk_widget_states(NK_WIDGET_STATE_HOVER.cint or NK_WIDGET_STATE_MODIFIED.cint) 
const NK_WIDGET_STATE_ACTIVE = nk_widget_states(NK_WIDGET_STATE_ACTIVED.cint or NK_WIDGET_STATE_MODIFIED.cint)


type
  nk_text_align* {.size: sizeof(cint).} = enum
    NK_TEXT_ALIGN_LEFT = 0x00000001, NK_TEXT_ALIGN_CENTERED = 0x00000002,
    NK_TEXT_ALIGN_RIGHT = 0x00000004, NK_TEXT_ALIGN_TOP = 0x00000008,
    NK_TEXT_ALIGN_MIDDLE = 0x00000010, NK_TEXT_ALIGN_BOTTOM = 0x00000020


type
  nk_text_alignment* {.size: sizeof(cint).} = enum
    NK_TEXT_LEFT = NK_TEXT_ALIGN_MIDDLE.cint or NK_TEXT_ALIGN_LEFT.cint,
    NK_TEXT_CENTERED = NK_TEXT_ALIGN_MIDDLE.cint or NK_TEXT_ALIGN_CENTERED.cint,
    NK_TEXT_RIGHT = NK_TEXT_ALIGN_MIDDLE.cint or NK_TEXT_ALIGN_RIGHT.cint


type
  nk_edit_flags* {.size: sizeof(cint).} = enum
    NK_EDIT_DEFAULT = 0, NK_EDIT_READ_ONLY = (1 shl (0)),
    NK_EDIT_AUTO_SELECT = (1 shl (1)), NK_EDIT_SIG_ENTER = (1 shl (2)),
    NK_EDIT_ALLOW_TAB = (1 shl (3)), NK_EDIT_NO_CURSOR = (1 shl (4)),
    NK_EDIT_SELECTABLE = (1 shl (5)), NK_EDIT_CLIPBOARD = (1 shl (6)),
    NK_EDIT_CTRL_ENTER_NEWLINE = (1 shl (7)),
    NK_EDIT_NO_HORIZONTAL_SCROLL = (1 shl (8)),
    NK_EDIT_ALWAYS_INSERT_MODE = (1 shl (9)), NK_EDIT_MULTILINE = (1 shl (11)),
    NK_EDIT_GOTO_END_ON_ACTIVATE = (1 shl (12))


type
  nk_edit_types* {.size: sizeof(cint).} = enum
    NK_EDIT_SIMPLE = NK_EDIT_ALWAYS_INSERT_MODE,
    NK_EDIT_FIELD = NK_EDIT_SIMPLE.cint or NK_EDIT_SELECTABLE.cint or NK_EDIT_CLIPBOARD.cint,  
    NK_EDIT_EDITOR = NK_EDIT_SELECTABLE.cint or NK_EDIT_MULTILINE.cint or NK_EDIT_ALLOW_TAB.cint or NK_EDIT_CLIPBOARD.cint,
    NK_EDIT_BOX = NK_EDIT_ALWAYS_INSERT_MODE.cint or NK_EDIT_SELECTABLE.cint or NK_EDIT_MULTILINE.cint or NK_EDIT_ALLOW_TAB.cint or NK_EDIT_CLIPBOARD.cint


type
  nk_edit_events* {.size: sizeof(cint).} = enum
    NK_EDIT_ACTIVE = (1 shl (0)), NK_EDIT_INACTIVE = (1 shl (1)),
    NK_EDIT_ACTIVATED = (1 shl (2)), NK_EDIT_DEACTIVATED = (1 shl (3)),
    NK_EDIT_COMMITED = (1 shl (4))


type
  nk_panel_flags* {.size: sizeof(cint).} = enum
    NK_WINDOW_BORDER = (1 shl (0)), NK_WINDOW_MOVABLE = (1 shl (1)),
    NK_WINDOW_SCALABLE = (1 shl (2)), NK_WINDOW_CLOSABLE = (1 shl (3)),
    NK_WINDOW_MINIMIZABLE = (1 shl (4)), NK_WINDOW_NO_SCROLLBAR = (1 shl (5)),
    NK_WINDOW_TITLE = (1 shl (6)), NK_WINDOW_SCROLL_AUTO_HIDE = (1 shl (7)),
    NK_WINDOW_BACKGROUND = (1 shl (8)), NK_WINDOW_SCALE_LEFT = (1 shl (9))

proc nk_buffer_init_default*(a2: ptr nk_buffer) {.cdecl,
    importc: "nk_buffer_init_default".}
proc nk_buffer_init*(a2: ptr nk_buffer; a3: ptr nk_allocator; size: nk_size) {.cdecl,
    importc: "nk_buffer_init".}
proc nk_buffer_init_fixed*(a2: ptr nk_buffer; memory: pointer; size: nk_size) {.cdecl,
    importc: "nk_buffer_init_fixed".}
proc nk_buffer_info*(a2: ptr nk_memory_status; a3: ptr nk_buffer) {.cdecl,
    importc: "nk_buffer_info".}
proc nk_buffer_push*(a2: ptr nk_buffer; `type`: nk_buffer_allocation_type;
                    memory: pointer; size: nk_size; align: nk_size) {.cdecl,
    importc: "nk_buffer_push".}
proc nk_buffer_mark*(a2: ptr nk_buffer; `type`: nk_buffer_allocation_type) {.cdecl,
    importc: "nk_buffer_mark".}
proc nk_buffer_reset*(a2: ptr nk_buffer; `type`: nk_buffer_allocation_type) {.cdecl,
    importc: "nk_buffer_reset".}
proc nk_buffer_clear*(a2: ptr nk_buffer) {.cdecl, importc: "nk_buffer_clear".}
proc nk_buffer_free*(a2: ptr nk_buffer) {.cdecl, importc: "nk_buffer_free".}
proc nk_buffer_memory*(a2: ptr nk_buffer): pointer {.cdecl,
    importc: "nk_buffer_memory".}
proc nk_buffer_memory_const*(a2: ptr nk_buffer): pointer {.cdecl,
    importc: "nk_buffer_memory_const".}
proc nk_buffer_total*(a2: ptr nk_buffer): nk_size {.cdecl, importc: "nk_buffer_total".}


proc nk_str_init*(a2: ptr nk_str; a3: ptr nk_allocator; size: nk_size) {.cdecl,
    importc: "nk_str_init".}
proc nk_str_init_fixed*(a2: ptr nk_str; memory: pointer; size: nk_size) {.cdecl,
    importc: "nk_str_init_fixed".}
proc nk_str_clear*(a2: ptr nk_str) {.cdecl, importc: "nk_str_clear".}
proc nk_str_free*(a2: ptr nk_str) {.cdecl, importc: "nk_str_free".}
proc nk_str_append_text_char*(a2: ptr nk_str; a3: cstring; a4: cint): cint {.cdecl,
    importc: "nk_str_append_text_char".}
proc nk_str_append_str_char*(a2: ptr nk_str; a3: cstring): cint {.cdecl,
    importc: "nk_str_append_str_char".}
proc nk_str_append_text_utf8*(a2: ptr nk_str; a3: cstring; a4: cint): cint {.cdecl,
    importc: "nk_str_append_text_utf8".}
proc nk_str_append_str_utf8*(a2: ptr nk_str; a3: cstring): cint {.cdecl,
    importc: "nk_str_append_str_utf8".}
proc nk_str_append_text_runes*(a2: ptr nk_str; a3: ptr nk_rune; a4: cint): cint {.cdecl,
    importc: "nk_str_append_text_runes".}
proc nk_str_append_str_runes*(a2: ptr nk_str; a3: ptr nk_rune): cint {.cdecl,
    importc: "nk_str_append_str_runes".}
proc nk_str_insert_at_char*(a2: ptr nk_str; pos: cint; a4: cstring; a5: cint): cint {.
    cdecl, importc: "nk_str_insert_at_char".}
proc nk_str_insert_at_rune*(a2: ptr nk_str; pos: cint; a4: cstring; a5: cint): cint {.
    cdecl, importc: "nk_str_insert_at_rune".}
proc nk_str_insert_text_char*(a2: ptr nk_str; pos: cint; a4: cstring; a5: cint): cint {.
    cdecl, importc: "nk_str_insert_text_char".}
proc nk_str_insert_str_char*(a2: ptr nk_str; pos: cint; a4: cstring): cint {.cdecl,
    importc: "nk_str_insert_str_char".}
proc nk_str_insert_text_utf8*(a2: ptr nk_str; pos: cint; a4: cstring; a5: cint): cint {.
    cdecl, importc: "nk_str_insert_text_utf8".}
proc nk_str_insert_str_utf8*(a2: ptr nk_str; pos: cint; a4: cstring): cint {.cdecl,
    importc: "nk_str_insert_str_utf8".}
proc nk_str_insert_text_runes*(a2: ptr nk_str; pos: cint; a4: ptr nk_rune; a5: cint): cint {.
    cdecl, importc: "nk_str_insert_text_runes".}
proc nk_str_insert_str_runes*(a2: ptr nk_str; pos: cint; a4: ptr nk_rune): cint {.cdecl,
    importc: "nk_str_insert_str_runes".}
proc nk_str_remove_chars*(a2: ptr nk_str; len: cint) {.cdecl,
    importc: "nk_str_remove_chars".}
proc nk_str_remove_runes*(str: ptr nk_str; len: cint) {.cdecl,
    importc: "nk_str_remove_runes".}
proc nk_str_delete_chars*(a2: ptr nk_str; pos: cint; len: cint) {.cdecl,
    importc: "nk_str_delete_chars".}
proc nk_str_delete_runes*(a2: ptr nk_str; pos: cint; len: cint) {.cdecl,
    importc: "nk_str_delete_runes".}
proc nk_str_at_char*(a2: ptr nk_str; pos: cint): cstring {.cdecl,
    importc: "nk_str_at_char".}
proc nk_str_at_rune*(a2: ptr nk_str; pos: cint; unicode: ptr nk_rune; len: ptr cint): cstring {.
    cdecl, importc: "nk_str_at_rune".}
proc nk_str_rune_at*(a2: ptr nk_str; pos: cint): nk_rune {.cdecl,
    importc: "nk_str_rune_at".}
proc nk_str_at_char_const*(a2: ptr nk_str; pos: cint): cstring {.cdecl,
    importc: "nk_str_at_char_const".}
proc nk_str_at_const*(a2: ptr nk_str; pos: cint; unicode: ptr nk_rune; len: ptr cint): cstring {.
    cdecl, importc: "nk_str_at_const".}
proc nk_str_get*(a2: ptr nk_str): cstring {.cdecl, importc: "nk_str_get".}
proc nk_str_get_const*(a2: ptr nk_str): cstring {.cdecl, importc: "nk_str_get_const".}
proc nk_str_len*(a2: ptr nk_str): cint {.cdecl, importc: "nk_str_len".}
proc nk_str_len_char*(a2: ptr nk_str): cint {.cdecl, importc: "nk_str_len_char".}

type
  nk_text_edit_mode* {.size: sizeof(cint).} = enum
    NK_TEXT_EDIT_MODE_VIEW, NK_TEXT_EDIT_MODE_INSERT, NK_TEXT_EDIT_MODE_REPLACE


proc nk_filter_default*(a2: ptr nk_text_edit; unicode: nk_rune): cint {.cdecl,
    importc: "nk_filter_default".}
proc nk_filter_ascii*(a2: ptr nk_text_edit; unicode: nk_rune): cint {.cdecl,
    importc: "nk_filter_ascii".}
proc nk_filter_float*(a2: ptr nk_text_edit; unicode: nk_rune): cint {.cdecl,
    importc: "nk_filter_float".}
proc nk_filter_decimal*(a2: ptr nk_text_edit; unicode: nk_rune): cint {.cdecl,
    importc: "nk_filter_decimal".}
proc nk_filter_hex*(a2: ptr nk_text_edit; unicode: nk_rune): cint {.cdecl,
    importc: "nk_filter_hex".}
proc nk_filter_oct*(a2: ptr nk_text_edit; unicode: nk_rune): cint {.cdecl,
    importc: "nk_filter_oct".}
proc nk_filter_binary*(a2: ptr nk_text_edit; unicode: nk_rune): cint {.cdecl,
    importc: "nk_filter_binary".}
proc nk_textedit_init*(a2: ptr nk_text_edit; a3: ptr nk_allocator; size: nk_size) {.
    cdecl, importc: "nk_textedit_init".}
proc nk_textedit_init_fixed*(a2: ptr nk_text_edit; memory: pointer; size: nk_size) {.
    cdecl, importc: "nk_textedit_init_fixed".}
proc nk_textedit_free*(a2: ptr nk_text_edit) {.cdecl, importc: "nk_textedit_free".}
proc nk_textedit_text*(a2: ptr nk_text_edit; a3: cstring; total_len: cint) {.cdecl,
    importc: "nk_textedit_text".}
proc nk_textedit_delete*(a2: ptr nk_text_edit; where: cint; len: cint) {.cdecl,
    importc: "nk_textedit_delete".}
proc nk_textedit_delete_selection*(a2: ptr nk_text_edit) {.cdecl,
    importc: "nk_textedit_delete_selection".}
proc nk_textedit_select_all*(a2: ptr nk_text_edit) {.cdecl,
    importc: "nk_textedit_select_all".}
proc nk_textedit_cut*(a2: ptr nk_text_edit): cint {.cdecl, importc: "nk_textedit_cut".}
proc nk_textedit_paste*(a2: ptr nk_text_edit; a3: cstring; len: cint): cint {.cdecl,
    importc: "nk_textedit_paste".}
proc nk_textedit_undo*(a2: ptr nk_text_edit) {.cdecl, importc: "nk_textedit_undo".}
proc nk_textedit_redo*(a2: ptr nk_text_edit) {.cdecl, importc: "nk_textedit_redo".}
type
  nk_command_type* {.size: sizeof(cint).} = enum
    NK_COMMAND_NOP, NK_COMMAND_SCISSOR, NK_COMMAND_LINE, NK_COMMAND_CURVE,
    NK_COMMAND_RECT, NK_COMMAND_RECT_FILLED, NK_COMMAND_RECT_MULTI_COLOR,
    NK_COMMAND_CIRCLE, NK_COMMAND_CIRCLE_FILLED, NK_COMMAND_ARC,
    NK_COMMAND_ARC_FILLED, NK_COMMAND_TRIANGLE, NK_COMMAND_TRIANGLE_FILLED,
    NK_COMMAND_POLYGON, NK_COMMAND_POLYGON_FILLED, NK_COMMAND_POLYLINE,
    NK_COMMAND_TEXT, NK_COMMAND_IMAGE


type
  nk_command* = object
    `type`*: nk_command_type
    next*: nk_size

  nk_command_scissor* = object
    header*: nk_command
    x*: cshort
    y*: cshort
    w*: cushort
    h*: cushort

  nk_command_line* = object
    header*: nk_command
    line_thickness*: cushort
    begin*: nuk_vec2i
    `end`*: nuk_vec2i
    color*: nk_color

  nk_command_curve* = object
    header*: nk_command
    line_thickness*: cushort
    begin*: nuk_vec2i
    `end`*: nuk_vec2i
    ctrl*: array[2, nuk_vec2i]
    color*: nk_color

  nk_command_rect* = object
    header*: nk_command
    rounding*: cushort
    line_thickness*: cushort
    x*: cshort
    y*: cshort
    w*: cushort
    h*: cushort
    color*: nk_color

  nk_command_rect_filled* = object
    header*: nk_command
    rounding*: cushort
    x*: cshort
    y*: cshort
    w*: cushort
    h*: cushort
    color*: nk_color

  nk_command_rect_multi_color* = object
    header*: nk_command
    x*: cshort
    y*: cshort
    w*: cushort
    h*: cushort
    left*: nk_color
    top*: nk_color
    bottom*: nk_color
    right*: nk_color

  nk_command_triangle* = object
    header*: nk_command
    line_thickness*: cushort
    a*: nuk_vec2i
    b*: nuk_vec2i
    c*: nuk_vec2i
    color*: nk_color

  nk_command_triangle_filled* = object
    header*: nk_command
    a*: nuk_vec2i
    b*: nuk_vec2i
    c*: nuk_vec2i
    color*: nk_color

  nk_command_circle* = object
    header*: nk_command
    x*: cshort
    y*: cshort
    line_thickness*: cushort
    w*: cushort
    h*: cushort
    color*: nk_color

  nk_command_circle_filled* = object
    header*: nk_command
    x*: cshort
    y*: cshort
    w*: cushort
    h*: cushort
    color*: nk_color

  nk_command_arc* = object
    header*: nk_command
    cx*: cshort
    cy*: cshort
    r*: cushort
    line_thickness*: cushort
    a*: array[2, cfloat]
    color*: nk_color

  nk_command_arc_filled* = object
    header*: nk_command
    cx*: cshort
    cy*: cshort
    r*: cushort
    a*: array[2, cfloat]
    color*: nk_color

  nk_command_polygon* = object
    header*: nk_command
    color*: nk_color
    line_thickness*: cushort
    point_count*: cushort
    points*: array[1, nuk_vec2i]

  nk_command_polygon_filled* = object
    header*: nk_command
    color*: nk_color
    point_count*: cushort
    points*: array[1, nuk_vec2i]

  nk_command_polyline* = object
    header*: nk_command
    color*: nk_color
    line_thickness*: cushort
    point_count*: cushort
    points*: array[1, nuk_vec2i]

  nk_command_image* = object
    header*: nk_command
    x*: cshort
    y*: cshort
    w*: cushort
    h*: cushort
    img*: nuk_image
    col*: nk_color

  nk_command_text* = object
    header*: nk_command
    font*: ptr nk_user_font
    background*: nk_color
    foreground*: nk_color
    x*: cshort
    y*: cshort
    w*: cushort
    h*: cushort
    height*: cfloat
    length*: cint
    string*: array[1, char]

  nk_command_clipping* {.size: sizeof(cint).} = enum
    NK_CLIPPING_OFF = nk_false, NK_CLIPPING_ON = nk_true


proc nk_stroke_line*(b: ptr nk_command_buffer; x0: cfloat; y0: cfloat; x1: cfloat;
                    y1: cfloat; line_thickness: cfloat; a8: nk_color) {.cdecl,
    importc: "nk_stroke_line".}
proc nk_stroke_curve*(a2: ptr nk_command_buffer; a3: cfloat; a4: cfloat; a5: cfloat;
                     a6: cfloat; a7: cfloat; a8: cfloat; a9: cfloat; a10: cfloat;
                     line_thickness: cfloat; a12: nk_color) {.cdecl,
    importc: "nk_stroke_curve".}
proc nk_stroke_rect*(a2: ptr nk_command_buffer; a3: nuk_rect; rounding: cfloat;
                    line_thickness: cfloat; a6: nk_color) {.cdecl,
    importc: "nk_stroke_rect".}
proc nk_stroke_circle*(a2: ptr nk_command_buffer; a3: nuk_rect; line_thickness: cfloat;
                      a5: nk_color) {.cdecl, importc: "nk_stroke_circle".}
proc nk_stroke_arc*(a2: ptr nk_command_buffer; cx: cfloat; cy: cfloat; radius: cfloat;
                   a_min: cfloat; a_max: cfloat; line_thickness: cfloat; a9: nk_color) {.
    cdecl, importc: "nk_stroke_arc".}
proc nk_stroke_triangle*(a2: ptr nk_command_buffer; a3: cfloat; a4: cfloat; a5: cfloat;
                        a6: cfloat; a7: cfloat; a8: cfloat; line_thichness: cfloat;
                        a10: nk_color) {.cdecl, importc: "nk_stroke_triangle".}
proc nk_stroke_polyline*(a2: ptr nk_command_buffer; points: ptr cfloat;
                        point_count: cint; line_thickness: cfloat; col: nk_color) {.
    cdecl, importc: "nk_stroke_polyline".}
proc nk_stroke_polygon*(a2: ptr nk_command_buffer; a3: ptr cfloat; point_count: cint;
                       line_thickness: cfloat; a6: nk_color) {.cdecl,
    importc: "nk_stroke_polygon".}
proc nk_fill_rect*(a2: ptr nk_command_buffer; a3: nuk_rect; rounding: cfloat;
                  a5: nk_color) {.cdecl, importc: "nk_fill_rect".}
proc nk_fill_rect_multi_color*(a2: ptr nk_command_buffer; a3: nuk_rect; left: nk_color;
                              top: nk_color; right: nk_color; bottom: nk_color) {.
    cdecl, importc: "nk_fill_rect_multi_color".}
proc nk_fill_circle*(a2: ptr nk_command_buffer; a3: nuk_rect; a4: nk_color) {.cdecl,
    importc: "nk_fill_circle".}
proc nk_fill_arc*(a2: ptr nk_command_buffer; cx: cfloat; cy: cfloat; radius: cfloat;
                 a_min: cfloat; a_max: cfloat; a8: nk_color) {.cdecl,
    importc: "nk_fill_arc".}
proc nk_fill_triangle*(a2: ptr nk_command_buffer; x0: cfloat; y0: cfloat; x1: cfloat;
                      y1: cfloat; x2: cfloat; y2: cfloat; a9: nk_color) {.cdecl,
    importc: "nk_fill_triangle".}
proc nk_fill_polygon*(a2: ptr nk_command_buffer; a3: ptr cfloat; point_count: cint;
                     a5: nk_color) {.cdecl, importc: "nk_fill_polygon".}
proc nk_push_scissor*(a2: ptr nk_command_buffer; a3: nuk_rect) {.cdecl,
    importc: "nk_push_scissor".}
proc nk_draw_image*(a2: ptr nk_command_buffer; a3: nuk_rect; a4: ptr nuk_image;
                   a5: nk_color) {.cdecl, importc: "nk_draw_image".}
proc nk_draw_text*(a2: ptr nk_command_buffer; a3: nuk_rect; text: cstring; len: cint;
                  a6: ptr nk_user_font; a7: nk_color; a8: nk_color) {.cdecl,
    importc: "nk_draw_text".}
proc nk_next*(a2: ptr nk_context; a3: ptr nk_command): ptr nk_command {.cdecl,
    importc: "nk__next".}
proc nk_begin*(a2: ptr nk_context): ptr nk_command {.cdecl, importc: "nk__begin".}


proc nk_input_has_mouse_click*(a2: ptr nk_input; a3: nk_buttons): cint {.cdecl,
    importc: "nk_input_has_mouse_click".}
proc nk_input_has_mouse_click_in_rect*(a2: ptr nk_input; a3: nk_buttons; a4: nuk_rect): cint {.
    cdecl, importc: "nk_input_has_mouse_click_in_rect".}
proc nk_input_has_mouse_click_down_in_rect*(a2: ptr nk_input; a3: nk_buttons;
    a4: nuk_rect; down: cint): cint {.cdecl, importc: "nk_input_has_mouse_click_down_in_rect".}
proc nk_input_is_mouse_click_in_rect*(a2: ptr nk_input; a3: nk_buttons; a4: nuk_rect): cint {.
    cdecl, importc: "nk_input_is_mouse_click_in_rect".}
proc nk_input_is_mouse_click_down_in_rect*(i: ptr nk_input; id: nk_buttons;
    b: nuk_rect; down: cint): cint {.cdecl,
                               importc: "nk_input_is_mouse_click_down_in_rect".}
proc nk_input_any_mouse_click_in_rect*(a2: ptr nk_input; a3: nuk_rect): cint {.cdecl,
    importc: "nk_input_any_mouse_click_in_rect".}
proc nk_input_is_mouse_prev_hovering_rect*(a2: ptr nk_input; a3: nuk_rect): cint {.
    cdecl, importc: "nk_input_is_mouse_prev_hovering_rect".}
proc nk_input_is_mouse_hovering_rect*(a2: ptr nk_input; a3: nuk_rect): cint {.cdecl,
    importc: "nk_input_is_mouse_hovering_rect".}
proc nk_input_mouse_clicked*(a2: ptr nk_input; a3: nk_buttons; a4: nuk_rect): cint {.
    cdecl, importc: "nk_input_mouse_clicked".}
proc nk_input_is_mouse_down*(a2: ptr nk_input; a3: nk_buttons): cint {.cdecl,
    importc: "nk_input_is_mouse_down".}
proc nk_input_is_mouse_pressed*(a2: ptr nk_input; a3: nk_buttons): cint {.cdecl,
    importc: "nk_input_is_mouse_pressed".}
proc nk_input_is_mouse_released*(a2: ptr nk_input; a3: nk_buttons): cint {.cdecl,
    importc: "nk_input_is_mouse_released".}
proc nk_input_is_key_pressed*(a2: ptr nk_input; a3: nk_keys): cint {.cdecl,
    importc: "nk_input_is_key_pressed".}
proc nk_input_is_key_released*(a2: ptr nk_input; a3: nk_keys): cint {.cdecl,
    importc: "nk_input_is_key_released".}
proc nk_input_is_key_down*(a2: ptr nk_input; a3: nk_keys): cint {.cdecl,
    importc: "nk_input_is_key_down".}
  
type
  nk_draw_index* = nk_ushort
  nk_draw_list_stroke* = enum
    NK_STROKE_OPEN = nk_false, NK_STROKE_CLOSED = nk_true

const
  NK_FORMAT_R8G8B8 = NK_FORMAT_COLOR_BEGIN
  NK_FORMAT_COLOR_END = NK_FORMAT_RGBA32


proc nk_draw_list_init*(a2: ptr nk_draw_list) {.cdecl, importc: "nk_draw_list_init".}
proc nk_draw_list_setup*(a2: ptr nk_draw_list; a3: ptr nk_convert_config;
                        cmds: ptr nk_buffer; vertices: ptr nk_buffer;
                        elements: ptr nk_buffer) {.cdecl,
    importc: "nk_draw_list_setup".}
proc nk_draw_list_clear*(a2: ptr nk_draw_list) {.cdecl,
    importc: "nk_draw_list_clear".}
proc nk_draw_list_begin*(a2: ptr nk_draw_list; a3: ptr nk_buffer): ptr nk_draw_command {.
    cdecl, importc: "nk__draw_list_begin".}
proc nk_draw_list_next*(a2: ptr nk_draw_command; a3: ptr nk_buffer;
                        a4: ptr nk_draw_list): ptr nk_draw_command {.cdecl,
    importc: "nk__draw_list_next".}
proc nk_draw_list_end*(a2: ptr nk_draw_list; a3: ptr nk_buffer): ptr nk_draw_command {.
    cdecl, importc: "nk__draw_list_end".}
proc nk_draw_list_clear*(list: ptr nk_draw_list) {.cdecl,
    importc: "nk_draw_list_clear".}
proc nk_draw_list_path_clear*(a2: ptr nk_draw_list) {.cdecl,
    importc: "nk_draw_list_path_clear".}
proc nk_draw_list_path_line_to*(a2: ptr nk_draw_list; pos: nuk_vec2) {.cdecl,
    importc: "nk_draw_list_path_line_to".}
proc nk_draw_list_path_arc_to_fast*(a2: ptr nk_draw_list; center: nuk_vec2;
                                   radius: cfloat; a_min: cint; a_max: cint) {.cdecl,
    importc: "nk_draw_list_path_arc_to_fast".}
proc nk_draw_list_path_arc_to*(a2: ptr nk_draw_list; center: nuk_vec2; radius: cfloat;
                              a_min: cfloat; a_max: cfloat; segments: cuint) {.cdecl,
    importc: "nk_draw_list_path_arc_to".}
proc nk_draw_list_path_rect_to*(a2: ptr nk_draw_list; a: nuk_vec2; b: nuk_vec2;
                               rounding: cfloat) {.cdecl,
    importc: "nk_draw_list_path_rect_to".}
proc nk_draw_list_path_curve_to*(a2: ptr nk_draw_list; p2: nuk_vec2; p3: nuk_vec2;
                                p4: nuk_vec2; num_segments: cuint) {.cdecl,
    importc: "nk_draw_list_path_curve_to".}
proc nk_draw_list_path_fill*(a2: ptr nk_draw_list; a3: nk_color) {.cdecl,
    importc: "nk_draw_list_path_fill".}
proc nk_draw_list_path_stroke*(a2: ptr nk_draw_list; a3: nk_color;
                              closed: nk_draw_list_stroke; thickness: cfloat) {.
    cdecl, importc: "nk_draw_list_path_stroke".}
proc nk_draw_list_stroke_line*(a2: ptr nk_draw_list; a: nuk_vec2; b: nuk_vec2;
                              a5: nk_color; thickness: cfloat) {.cdecl,
    importc: "nk_draw_list_stroke_line".}
proc nk_draw_list_stroke_rect*(a2: ptr nk_draw_list; rect: nuk_rect; a4: nk_color;
                              rounding: cfloat; thickness: cfloat) {.cdecl,
    importc: "nk_draw_list_stroke_rect".}
proc nk_draw_list_stroke_triangle*(a2: ptr nk_draw_list; a: nuk_vec2; b: nuk_vec2;
                                  c: nuk_vec2; a6: nk_color; thickness: cfloat) {.
    cdecl, importc: "nk_draw_list_stroke_triangle".}
proc nk_draw_list_stroke_circle*(a2: ptr nk_draw_list; center: nuk_vec2;
                                radius: cfloat; a5: nk_color; segs: cuint;
                                thickness: cfloat) {.cdecl,
    importc: "nk_draw_list_stroke_circle".}
proc nk_draw_list_stroke_curve*(a2: ptr nk_draw_list; p0: nuk_vec2; cp0: nuk_vec2;
                               cp1: nuk_vec2; p1: nuk_vec2; a7: nk_color;
                               segments: cuint; thickness: cfloat) {.cdecl,
    importc: "nk_draw_list_stroke_curve".}
proc nk_draw_list_stroke_poly_line*(a2: ptr nk_draw_list; pnts: ptr nuk_vec2;
                                   cnt: cuint; a5: nk_color;
                                   a6: nk_draw_list_stroke; thickness: cfloat;
                                   a8: nk_anti_aliasing) {.cdecl,
    importc: "nk_draw_list_stroke_poly_line".}
proc nk_draw_list_fill_rect*(a2: ptr nk_draw_list; rect: nuk_rect; a4: nk_color;
                            rounding: cfloat) {.cdecl,
    importc: "nk_draw_list_fill_rect".}
proc nk_draw_list_fill_rect_multi_color*(a2: ptr nk_draw_list; rect: nuk_rect;
                                        left: nk_color; top: nk_color;
                                        right: nk_color; bottom: nk_color) {.cdecl,
    importc: "nk_draw_list_fill_rect_multi_color".}
proc nk_draw_list_fill_triangle*(a2: ptr nk_draw_list; a: nuk_vec2; b: nuk_vec2;
                                c: nuk_vec2; a6: nk_color) {.cdecl,
    importc: "nk_draw_list_fill_triangle".}
proc nk_draw_list_fill_circle*(a2: ptr nk_draw_list; center: nuk_vec2; radius: cfloat;
                              col: nk_color; segs: cuint) {.cdecl,
    importc: "nk_draw_list_fill_circle".}
proc nk_draw_list_fill_poly_convex*(a2: ptr nk_draw_list; points: ptr nuk_vec2;
                                   count: cuint; a5: nk_color; a6: nk_anti_aliasing) {.
    cdecl, importc: "nk_draw_list_fill_poly_convex".}
proc nk_draw_list_add_image*(a2: ptr nk_draw_list; texture: nuk_image; rect: nuk_rect;
                            a5: nk_color) {.cdecl,
    importc: "nk_draw_list_add_image".}
proc nk_draw_list_add_text*(a2: ptr nk_draw_list; a3: ptr nk_user_font; a4: nuk_rect;
                           text: cstring; len: cint; font_height: cfloat; a8: nk_color) {.
    cdecl, importc: "nk_draw_list_add_text".}

proc nk_style_item_image*(img: nuk_image): nk_style_item {.cdecl,
    importc: "nk_style_item_image".}
proc nk_style_item_color*(a2: nk_color): nk_style_item {.cdecl,
    importc: "nk_style_item_color".}
proc nk_style_item_hide*(): nk_style_item {.cdecl, importc: "nk_style_item_hide".}


type
  nk_panel_set* {.size: sizeof(cint).} = enum
    NK_PANEL_SET_NONBLOCK = NK_PANEL_CONTEXTUAL.cint or NK_PANEL_COMBO.cint or NK_PANEL_MENU.cint or
        NK_PANEL_TOOLTIP.cint,
    NK_PANEL_SET_POPUP = NK_PANEL_SET_NONBLOCK.cint or NK_PANEL_POPUP.cint,
    NK_PANEL_SET_SUB = NK_PANEL_SET_POPUP.cint or NK_PANEL_GROUP.cint


type
  #nk_table* = object
  
  nk_window_flags* {.size: sizeof(cint).} = enum
    NK_WINDOW_PRIVATE = (1 shl (10)), NK_WINDOW_ROM = (1 shl (11)),
    NK_WINDOW_HIDDEN = (1 shl (12)), NK_WINDOW_CLOSED = (1 shl (13)),
    NK_WINDOW_MINIMIZED = (1 shl (14)), NK_WINDOW_REMOVE_ROM = (1 shl (15))

const
  NK_WINDOW_DYNAMIC = NK_WINDOW_PRIVATE

proc nk_init_default*(a2: ptr nk_context; a3: ptr nk_user_font): cint {.cdecl, importc: "nk_init_default".}
proc nk_init_fixed*(a2: ptr nk_context; memory: pointer; size: nk_size;
                   a5: ptr nk_user_font): cint {.cdecl, importc: "nk_init_fixed".}
proc nk_init*(a2: ptr nk_context; a3: ptr nk_allocator; a4: ptr nk_user_font): cint {.
    cdecl, importc: "nk_init".}
proc nk_init_custom*(a2: ptr nk_context; cmds: ptr nk_buffer; pool: ptr nk_buffer;
                    a5: ptr nk_user_font): cint {.cdecl, importc: "nk_init_custom".}
proc nk_clear*(a2: ptr nk_context) {.cdecl, importc: "nk_clear".}
proc nk_free*(a2: ptr nk_context) {.cdecl, importc: "nk_free".}
proc nk_begin*(a2: ptr nk_context; title: cstring; bounds: nuk_rect; flags: nk_flags): cint {.
    cdecl, importc: "nk_begin".}
proc nk_begin_titled*(a2: ptr nk_context; name: cstring; title: cstring;
                     bounds: nuk_rect; flags: nk_flags): cint {.cdecl,
    importc: "nk_begin_titled".}
proc nk_end*(a2: ptr nk_context) {.cdecl, importc: "nk_end".}
proc nk_window_find*(ctx: ptr nk_context; name: cstring): ptr nk_window {.cdecl,
    importc: "nk_window_find".}
proc nk_window_get_bounds*(a2: ptr nk_context): nuk_rect {.cdecl,
    importc: "nk_window_get_bounds".}
proc nk_window_get_position*(a2: ptr nk_context): nuk_vec2 {.cdecl,
    importc: "nk_window_get_position".}
proc nk_window_get_size*(a2: ptr nk_context): nuk_vec2 {.cdecl,
    importc: "nk_window_get_size".}
proc nk_window_get_width*(a2: ptr nk_context): cfloat {.cdecl,
    importc: "nk_window_get_width".}
proc nk_window_get_height*(a2: ptr nk_context): cfloat {.cdecl,
    importc: "nk_window_get_height".}
proc nk_window_get_panel*(a2: ptr nk_context): ptr nk_panel {.cdecl,
    importc: "nk_window_get_panel".}
proc nk_window_get_content_region*(a2: ptr nk_context): nuk_rect {.cdecl,
    importc: "nk_window_get_content_region".}
proc nk_window_get_content_region_min*(a2: ptr nk_context): nuk_vec2 {.cdecl,
    importc: "nk_window_get_content_region_min".}
proc nk_window_get_content_region_max*(a2: ptr nk_context): nuk_vec2 {.cdecl,
    importc: "nk_window_get_content_region_max".}
proc nk_window_get_content_region_size*(a2: ptr nk_context): nuk_vec2 {.cdecl,
    importc: "nk_window_get_content_region_size".}
proc nk_window_get_canvas*(a2: ptr nk_context): ptr nk_command_buffer {.cdecl,
    importc: "nk_window_get_canvas".}
proc nk_window_has_focus*(a2: ptr nk_context): cint {.cdecl,
    importc: "nk_window_has_focus".}
proc nk_window_is_collapsed*(a2: ptr nk_context; a3: cstring): cint {.cdecl,
    importc: "nk_window_is_collapsed".}
proc nk_window_is_closed*(a2: ptr nk_context; a3: cstring): cint {.cdecl,
    importc: "nk_window_is_closed".}
proc nk_window_is_hidden*(a2: ptr nk_context; a3: cstring): cint {.cdecl,
    importc: "nk_window_is_hidden".}
proc nk_window_is_active*(a2: ptr nk_context; a3: cstring): cint {.cdecl,
    importc: "nk_window_is_active".}
proc nk_window_is_hovered*(a2: ptr nk_context): cint {.cdecl,
    importc: "nk_window_is_hovered".}
proc nk_window_is_any_hovered*(a2: ptr nk_context): cint {.cdecl,
    importc: "nk_window_is_any_hovered".}
proc nk_item_is_any_active*(a2: ptr nk_context): cint {.cdecl,
    importc: "nk_item_is_any_active".}
proc nk_window_set_bounds*(a2: ptr nk_context; a3: nuk_rect) {.cdecl,
    importc: "nk_window_set_bounds".}
proc nk_window_set_position*(a2: ptr nk_context; a3: nuk_vec2) {.cdecl,
    importc: "nk_window_set_position".}
proc nk_window_set_size*(a2: ptr nk_context; a3: nuk_vec2) {.cdecl,
    importc: "nk_window_set_size".}
proc nk_window_set_focus*(a2: ptr nk_context; name: cstring) {.cdecl,
    importc: "nk_window_set_focus".}
proc nk_window_close*(ctx: ptr nk_context; name: cstring) {.cdecl,
    importc: "nk_window_close".}
proc nk_window_collapse*(a2: ptr nk_context; name: cstring; a4: nk_collapse_states) {.
    cdecl, importc: "nk_window_collapse".}
proc nk_window_collapse_if*(a2: ptr nk_context; name: cstring; a4: nk_collapse_states;
                           cond: cint) {.cdecl, importc: "nk_window_collapse_if".}
proc nk_window_show*(a2: ptr nk_context; name: cstring; a4: nk_show_states) {.cdecl,
    importc: "nk_window_show".}
proc nk_window_show_if*(a2: ptr nk_context; name: cstring; a4: nk_show_states;
                       cond: cint) {.cdecl, importc: "nk_window_show_if".}
proc nk_layout_row_dynamic*(a2: ptr nk_context; height: cfloat; cols: cint) {.cdecl,
    importc: "nk_layout_row_dynamic".}
proc nk_layout_row_static*(a2: ptr nk_context; height: cfloat; item_width: cint;
                          cols: cint) {.cdecl, importc: "nk_layout_row_static".}
proc nk_layout_row_begin*(a2: ptr nk_context; a3: nk_layout_format;
                         row_height: cfloat; cols: cint) {.cdecl,
    importc: "nk_layout_row_begin".}
proc nk_layout_row_push*(a2: ptr nk_context; value: cfloat) {.cdecl,
    importc: "nk_layout_row_push".}
proc nk_layout_row_end*(a2: ptr nk_context) {.cdecl, importc: "nk_layout_row_end".}
proc nk_layout_row*(a2: ptr nk_context; a3: nk_layout_format; height: cfloat;
                   cols: cint; ratio: ptr cfloat) {.cdecl, importc: "nk_layout_row".}
proc nk_layout_row_template_begin*(a2: ptr nk_context; height: cfloat) {.cdecl,
    importc: "nk_layout_row_template_begin".}
proc nk_layout_row_template_push_dynamic*(a2: ptr nk_context) {.cdecl,
    importc: "nk_layout_row_template_push_dynamic".}
proc nk_layout_row_template_push_variable*(a2: ptr nk_context; min_width: cfloat) {.
    cdecl, importc: "nk_layout_row_template_push_variable".}
proc nk_layout_row_template_push_static*(a2: ptr nk_context; width: cfloat) {.cdecl,
    importc: "nk_layout_row_template_push_static".}
proc nk_layout_row_template_end*(a2: ptr nk_context) {.cdecl,
    importc: "nk_layout_row_template_end".}
proc nk_layout_space_begin*(a2: ptr nk_context; a3: nk_layout_format; height: cfloat;
                           widget_count: cint) {.cdecl,
    importc: "nk_layout_space_begin".}
proc nk_layout_space_push*(a2: ptr nk_context; a3: nuk_rect) {.cdecl,
    importc: "nk_layout_space_push".}
proc nk_layout_space_end*(a2: ptr nk_context) {.cdecl,
    importc: "nk_layout_space_end".}
proc nk_layout_space_bounds*(a2: ptr nk_context): nuk_rect {.cdecl,
    importc: "nk_layout_space_bounds".}
proc nk_layout_space_to_screen*(a2: ptr nk_context; a3: nuk_vec2): nuk_vec2 {.cdecl,
    importc: "nk_layout_space_to_screen".}
proc nk_layout_space_to_local*(a2: ptr nk_context; a3: nuk_vec2): nuk_vec2 {.cdecl,
    importc: "nk_layout_space_to_local".}
proc nk_layout_space_rect_to_screen*(a2: ptr nk_context; a3: nuk_rect): nuk_rect {.cdecl,
    importc: "nk_layout_space_rect_to_screen".}
proc nk_layout_space_rect_to_local*(a2: ptr nk_context; a3: nuk_rect): nuk_rect {.cdecl,
    importc: "nk_layout_space_rect_to_local".}
proc nk_layout_ratio_from_pixel*(a2: ptr nk_context; pixel_width: cfloat): cfloat {.
    cdecl, importc: "nk_layout_ratio_from_pixel".}
proc nk_group_begin*(a2: ptr nk_context; title: cstring; a4: nk_flags): cint {.cdecl,
    importc: "nk_group_begin".}
proc nk_group_scrolled_offset_begin*(a2: ptr nk_context; x_offset: ptr nk_uint;
                                    y_offset: ptr nk_uint; a5: cstring; a6: nk_flags): cint {.
    cdecl, importc: "nk_group_scrolled_offset_begin".}
proc nk_group_scrolled_begin*(a2: ptr nk_context; a3: ptr nk_scroll; title: cstring;
                             a5: nk_flags): cint {.cdecl,
    importc: "nk_group_scrolled_begin".}
proc nk_group_scrolled_end*(a2: ptr nk_context) {.cdecl,
    importc: "nk_group_scrolled_end".}
proc nk_group_end*(a2: ptr nk_context) {.cdecl, importc: "nk_group_end".}
proc nk_list_view_begin*(a2: ptr nk_context; `out`: ptr nk_list_view; id: cstring;
                        a5: nk_flags; row_height: cint; row_count: cint): cint {.cdecl,
    importc: "nk_list_view_begin".}
proc nk_list_view_end*(a2: ptr nk_list_view) {.cdecl, importc: "nk_list_view_end".}
proc nk_tree_push_hashed*(a2: ptr nk_context; a3: nk_tree_type; title: cstring;
                         initial_state: nk_collapse_states; hash: cstring;
                         len: cint; seed: cint): cint {.cdecl,
    importc: "nk_tree_push_hashed".}
proc nk_tree_image_push_hashed*(a2: ptr nk_context; a3: nk_tree_type; a4: nuk_image;
                               title: cstring; initial_state: nk_collapse_states;
                               hash: cstring; len: cint; seed: cint): cint {.cdecl,
    importc: "nk_tree_image_push_hashed".}
proc nk_tree_pop*(a2: ptr nk_context) {.cdecl, importc: "nk_tree_pop".}
proc nk_tree_state_push*(a2: ptr nk_context; a3: nk_tree_type; title: cstring;
                        state: ptr nk_collapse_states): cint {.cdecl,
    importc: "nk_tree_state_push".}
proc nk_tree_state_image_push*(a2: ptr nk_context; a3: nk_tree_type; a4: nuk_image;
                              title: cstring; state: ptr nk_collapse_states): cint {.
    cdecl, importc: "nk_tree_state_image_push".}
proc nk_tree_state_pop*(a2: ptr nk_context) {.cdecl, importc: "nk_tree_state_pop".}
proc nk_text*(a2: ptr nk_context; a3: cstring; a4: cint; a5: nk_flags) {.cdecl,
    importc: "nk_text".}
proc nk_text_colored*(a2: ptr nk_context; a3: cstring; a4: cint; a5: nk_flags;
                     a6: nk_color) {.cdecl, importc: "nk_text_colored".}
proc nk_text_wrap*(a2: ptr nk_context; a3: cstring; a4: cint) {.cdecl,
    importc: "nk_text_wrap".}
proc nk_text_wrap_colored*(a2: ptr nk_context; a3: cstring; a4: cint; a5: nk_color) {.
    cdecl, importc: "nk_text_wrap_colored".}
proc nk_label*(a2: ptr nk_context; a3: cstring; align: nk_flags) {.cdecl,
    importc: "nk_label".}
proc nk_label_colored*(a2: ptr nk_context; a3: cstring; align: nk_flags; a5: nk_color) {.
    cdecl, importc: "nk_label_colored".}
proc nk_label_wrap*(a2: ptr nk_context; a3: cstring) {.cdecl, importc: "nk_label_wrap".}
proc nk_label_colored_wrap*(a2: ptr nk_context; a3: cstring; a4: nk_color) {.cdecl,
    importc: "nk_label_colored_wrap".}
proc nk_image*(a2: ptr nk_context; a3: nuk_image) {.cdecl, importc: "nk_image".}
proc nk_button_set_behavior*(a2: ptr nk_context; a3: nk_button_behavior) {.cdecl,
    importc: "nk_button_set_behavior".}
proc nk_button_push_behavior*(a2: ptr nk_context; a3: nk_button_behavior): cint {.
    cdecl, importc: "nk_button_push_behavior".}
proc nk_button_pop_behavior*(a2: ptr nk_context): cint {.cdecl,
    importc: "nk_button_pop_behavior".}
proc nk_button_text*(a2: ptr nk_context; title: cstring; len: cint): cint {.cdecl,
    importc: "nk_button_text".}
proc nk_button_label*(a2: ptr nk_context; title: cstring): cint {.cdecl,
    importc: "nk_button_label".}
proc nk_button_color*(a2: ptr nk_context; a3: nk_color): cint {.cdecl,
    importc: "nk_button_color".}
proc nk_button_symbol*(a2: ptr nk_context; a3: nk_symbol_type): cint {.cdecl,
    importc: "nk_button_symbol".}
proc nk_button_image*(a2: ptr nk_context; img: nuk_image): cint {.cdecl,
    importc: "nk_button_image".}
proc nk_button_symbol_label*(a2: ptr nk_context; a3: nk_symbol_type; a4: cstring;
                            text_alignment: nk_flags): cint {.cdecl,
    importc: "nk_button_symbol_label".}
proc nk_button_symbol_text*(a2: ptr nk_context; a3: nk_symbol_type; a4: cstring;
                           a5: cint; alignment: nk_flags): cint {.cdecl,
    importc: "nk_button_symbol_text".}
proc nk_button_image_label*(a2: ptr nk_context; img: nuk_image; a4: cstring;
                           text_alignment: nk_flags): cint {.cdecl,
    importc: "nk_button_image_label".}
proc nk_button_image_text*(a2: ptr nk_context; img: nuk_image; a4: cstring; a5: cint;
                          alignment: nk_flags): cint {.cdecl,
    importc: "nk_button_image_text".}
proc nk_button_text_styled*(a2: ptr nk_context; a3: ptr nk_style_button;
                           title: cstring; len: cint): cint {.cdecl,
    importc: "nk_button_text_styled".}
proc nk_button_label_styled*(a2: ptr nk_context; a3: ptr nk_style_button;
                            title: cstring): cint {.cdecl,
    importc: "nk_button_label_styled".}
proc nk_button_symbol_styled*(a2: ptr nk_context; a3: ptr nk_style_button;
                             a4: nk_symbol_type): cint {.cdecl,
    importc: "nk_button_symbol_styled".}
proc nk_button_image_styled*(a2: ptr nk_context; a3: ptr nk_style_button; img: nuk_image): cint {.
    cdecl, importc: "nk_button_image_styled".}
proc nk_button_symbol_label_styled*(a2: ptr nk_context; a3: ptr nk_style_button;
                                   a4: nk_symbol_type; a5: cstring;
                                   text_alignment: nk_flags): cint {.cdecl,
    importc: "nk_button_symbol_label_styled".}
proc nk_button_symbol_text_styled*(a2: ptr nk_context; a3: ptr nk_style_button;
                                  a4: nk_symbol_type; a5: cstring; a6: cint;
                                  alignment: nk_flags): cint {.cdecl,
    importc: "nk_button_symbol_text_styled".}
proc nk_button_image_label_styled*(a2: ptr nk_context; a3: ptr nk_style_button;
                                  img: nuk_image; a5: cstring;
                                  text_alignment: nk_flags): cint {.cdecl,
    importc: "nk_button_image_label_styled".}
proc nk_button_image_text_styled*(a2: ptr nk_context; a3: ptr nk_style_button;
                                 img: nuk_image; a5: cstring; a6: cint;
                                 alignment: nk_flags): cint {.cdecl,
    importc: "nk_button_image_text_styled".}
proc nk_check_label*(a2: ptr nk_context; a3: cstring; active: cint): cint {.cdecl,
    importc: "nk_check_label".}
proc nk_check_text*(a2: ptr nk_context; a3: cstring; a4: cint; active: cint): cint {.cdecl,
    importc: "nk_check_text".}
proc nk_check_flags_label*(a2: ptr nk_context; a3: cstring; flags: cuint; value: cuint): cuint {.
    cdecl, importc: "nk_check_flags_label".}
proc nk_check_flags_text*(a2: ptr nk_context; a3: cstring; a4: cint; flags: cuint;
                         value: cuint): cuint {.cdecl,
    importc: "nk_check_flags_text".}
proc nk_checkbox_label*(a2: ptr nk_context; a3: cstring; active: ptr cint): cint {.cdecl,
    importc: "nk_checkbox_label".}
proc nk_checkbox_text*(a2: ptr nk_context; a3: cstring; a4: cint; active: ptr cint): cint {.
    cdecl, importc: "nk_checkbox_text".}
proc nk_checkbox_flags_label*(a2: ptr nk_context; a3: cstring; flags: ptr cuint;
                             value: cuint): cint {.cdecl,
    importc: "nk_checkbox_flags_label".}
proc nk_checkbox_flags_text*(a2: ptr nk_context; a3: cstring; a4: cint;
                            flags: ptr cuint; value: cuint): cint {.cdecl,
    importc: "nk_checkbox_flags_text".}
proc nk_radio_label*(a2: ptr nk_context; a3: cstring; active: ptr cint): cint {.cdecl,
    importc: "nk_radio_label".}
proc nk_radio_text*(a2: ptr nk_context; a3: cstring; a4: cint; active: ptr cint): cint {.
    cdecl, importc: "nk_radio_text".}
proc nk_option_label*(a2: ptr nk_context; a3: cstring; active: cint): cint {.cdecl,
    importc: "nk_option_label".}
proc nk_option_text*(a2: ptr nk_context; a3: cstring; a4: cint; active: cint): cint {.
    cdecl, importc: "nk_option_text".}
proc nk_selectable_label*(a2: ptr nk_context; a3: cstring; align: nk_flags;
                         value: ptr cint): cint {.cdecl,
    importc: "nk_selectable_label".}
proc nk_selectable_text*(a2: ptr nk_context; a3: cstring; a4: cint; align: nk_flags;
                        value: ptr cint): cint {.cdecl,
    importc: "nk_selectable_text".}
proc nk_selectable_image_label*(a2: ptr nk_context; a3: nuk_image; a4: cstring;
                               align: nk_flags; value: ptr cint): cint {.cdecl,
    importc: "nk_selectable_image_label".}
proc nk_selectable_image_text*(a2: ptr nk_context; a3: nuk_image; a4: cstring; a5: cint;
                              align: nk_flags; value: ptr cint): cint {.cdecl,
    importc: "nk_selectable_image_text".}
proc nk_select_label*(a2: ptr nk_context; a3: cstring; align: nk_flags; value: cint): cint {.
    cdecl, importc: "nk_select_label".}
proc nk_select_text*(a2: ptr nk_context; a3: cstring; a4: cint; align: nk_flags;
                    value: cint): cint {.cdecl, importc: "nk_select_text".}
proc nk_select_image_label*(a2: ptr nk_context; a3: nuk_image; a4: cstring;
                           align: nk_flags; value: cint): cint {.cdecl,
    importc: "nk_select_image_label".}
proc nk_select_image_text*(a2: ptr nk_context; a3: nuk_image; a4: cstring; a5: cint;
                          align: nk_flags; value: cint): cint {.cdecl,
    importc: "nk_select_image_text".}
proc nk_slide_float*(a2: ptr nk_context; min: cfloat; val: cfloat; max: cfloat;
                    step: cfloat): cfloat {.cdecl, importc: "nk_slide_float".}
proc nk_slide_int*(a2: ptr nk_context; min: cint; val: cint; max: cint; step: cint): cint {.
    cdecl, importc: "nk_slide_int".}
proc nk_slider_float*(a2: ptr nk_context; min: cfloat; val: ptr cfloat; max: cfloat;
                     step: cfloat): cint {.cdecl, importc: "nk_slider_float".}
proc nk_slider_int*(a2: ptr nk_context; min: cint; val: ptr cint; max: cint; step: cint): cint {.
    cdecl, importc: "nk_slider_int".}
proc nk_progress*(a2: ptr nk_context; cur: ptr nk_size; max: nk_size; modifyable: cint): cint {.
    cdecl, importc: "nk_progress".}
proc nk_prog*(a2: ptr nk_context; cur: nk_size; max: nk_size; modifyable: cint): nk_size {.
    cdecl, importc: "nk_prog".}
proc nk_color_picker*(a2: ptr nk_context; a3: nk_color; a4: nk_color_format): nk_color {.
    cdecl, importc: "nk_color_picker".}
proc nk_color_pick*(a2: ptr nk_context; a3: ptr nk_color; a4: nk_color_format): cint {.
    cdecl, importc: "nk_color_pick".}
proc nk_property_int*(a2: ptr nk_context; name: cstring; min: cint; val: ptr cint;
                     max: cint; step: cint; inc_per_pixel: cfloat) {.cdecl,
    importc: "nk_property_int".}
proc nk_property_float*(a2: ptr nk_context; name: cstring; min: cfloat; val: ptr cfloat;
                       max: cfloat; step: cfloat; inc_per_pixel: cfloat) {.cdecl,
    importc: "nk_property_float".}
proc nk_property_double*(a2: ptr nk_context; name: cstring; min: cdouble;
                        val: ptr cdouble; max: cdouble; step: cdouble;
                        inc_per_pixel: cfloat) {.cdecl,
    importc: "nk_property_double".}
proc nk_propertyi*(a2: ptr nk_context; name: cstring; min: cint; val: cint; max: cint;
                  step: cint; inc_per_pixel: cfloat): cint {.cdecl,
    importc: "nk_propertyi".}
proc nk_propertyf*(a2: ptr nk_context; name: cstring; min: cfloat; val: cfloat;
                  max: cfloat; step: cfloat; inc_per_pixel: cfloat): cfloat {.cdecl,
    importc: "nk_propertyf".}
proc nk_propertyd*(a2: ptr nk_context; name: cstring; min: cdouble; val: cdouble;
                  max: cdouble; step: cdouble; inc_per_pixel: cfloat): cdouble {.cdecl,
    importc: "nk_propertyd".}
proc nk_edit_focus*(a2: ptr nk_context; flags: nk_flags) {.cdecl,
    importc: "nk_edit_focus".}
proc nk_edit_unfocus*(a2: ptr nk_context) {.cdecl, importc: "nk_edit_unfocus".}
proc nk_edit_string*(a2: ptr nk_context; a3: nk_flags; buffer: cstring; len: ptr cint;
                    max: cint; a7: nk_plugin_filter): nk_flags {.cdecl,
    importc: "nk_edit_string".}
proc nk_edit_buffer*(a2: ptr nk_context; a3: nk_flags; a4: ptr nk_text_edit;
                    a5: nk_plugin_filter): nk_flags {.cdecl,
    importc: "nk_edit_buffer".}
proc nk_edit_string_zero_terminated*(a2: ptr nk_context; a3: nk_flags;
                                    buffer: cstring; max: cint; a6: nk_plugin_filter): nk_flags {.
    cdecl, importc: "nk_edit_string_zero_terminated".}
proc nk_chart_begin*(a2: ptr nk_context; a3: nk_chart_type; num: cint; min: cfloat;
                    max: cfloat): cint {.cdecl, importc: "nk_chart_begin".}
proc nk_chart_begin_colored*(a2: ptr nk_context; a3: nk_chart_type; a4: nk_color;
                            active: nk_color; num: cint; min: cfloat; max: cfloat): cint {.
    cdecl, importc: "nk_chart_begin_colored".}
proc nk_chart_add_slot*(ctx: ptr nk_context; a3: nk_chart_type; count: cint;
                       min_value: cfloat; max_value: cfloat) {.cdecl,
    importc: "nk_chart_add_slot".}
proc nk_chart_add_slot_colored*(ctx: ptr nk_context; a3: nk_chart_type; a4: nk_color;
                               active: nk_color; count: cint; min_value: cfloat;
                               max_value: cfloat) {.cdecl,
    importc: "nk_chart_add_slot_colored".}
proc nk_chart_push*(a2: ptr nk_context; a3: cfloat): nk_flags {.cdecl,
    importc: "nk_chart_push".}
proc nk_chart_push_slot*(a2: ptr nk_context; a3: cfloat; a4: cint): nk_flags {.cdecl,
    importc: "nk_chart_push_slot".}
proc nk_chart_end*(a2: ptr nk_context) {.cdecl, importc: "nk_chart_end".}
proc nk_plot*(a2: ptr nk_context; a3: nk_chart_type; values: ptr cfloat; count: cint;
             offset: cint) {.cdecl, importc: "nk_plot".}
proc nk_plot_function*(a2: ptr nk_context; a3: nk_chart_type; userdata: pointer;
    value_getter: proc (user: pointer; index: cint): cfloat {.cdecl.}; count: cint;
                      offset: cint) {.cdecl, importc: "nk_plot_function".}
proc nk_popup_begin*(a2: ptr nk_context; a3: nk_popup_type; a4: cstring; a5: nk_flags;
                    bounds: nuk_rect): cint {.cdecl, importc: "nk_popup_begin".}
proc nk_popup_close*(a2: ptr nk_context) {.cdecl, importc: "nk_popup_close".}
proc nk_popup_end*(a2: ptr nk_context) {.cdecl, importc: "nk_popup_end".}
proc nk_combo*(a2: ptr nk_context; items: cstringArray; count: cint; selected: cint;
              item_height: cint; size: nuk_vec2): cint {.cdecl, importc: "nk_combo".}
proc nk_combo_separator*(a2: ptr nk_context; items_separated_by_separator: cstring;
                        separator: cint; selected: cint; count: cint;
                        item_height: cint; size: nuk_vec2): cint {.cdecl,
    importc: "nk_combo_separator".}
proc nk_combo_string*(a2: ptr nk_context; items_separated_by_zeros: cstring;
                     selected: cint; count: cint; item_height: cint; size: nuk_vec2): cint {.
    cdecl, importc: "nk_combo_string".}
proc nk_combo_callback*(a2: ptr nk_context; item_getter: proc (a2: pointer; a3: cint;
    a4: cstringArray) {.cdecl.}; userdata: pointer; selected: cint; count: cint;
                       item_height: cint; size: nuk_vec2): cint {.cdecl,
    importc: "nk_combo_callback".}
proc nk_combobox*(a2: ptr nk_context; items: cstringArray; count: cint;
                 selected: ptr cint; item_height: cint; size: nuk_vec2) {.cdecl,
    importc: "nk_combobox".}
proc nk_combobox_string*(a2: ptr nk_context; items_separated_by_zeros: cstring;
                        selected: ptr cint; count: cint; item_height: cint;
                        size: nuk_vec2) {.cdecl, importc: "nk_combobox_string".}
proc nk_combobox_separator*(a2: ptr nk_context;
                           items_separated_by_separator: cstring; separator: cint;
                           selected: ptr cint; count: cint; item_height: cint;
                           size: nuk_vec2) {.cdecl,
    importc: "nk_combobox_separator".}
proc nk_combobox_callback*(a2: ptr nk_context; item_getter: proc (a2: pointer; a3: cint;
    a4: cstringArray) {.cdecl.}; a4: pointer; selected: ptr cint; count: cint;
                          item_height: cint; size: nuk_vec2) {.cdecl,
    importc: "nk_combobox_callback".}
proc nk_combo_begin_text*(a2: ptr nk_context; selected: cstring; a4: cint; size: nuk_vec2): cint {.
    cdecl, importc: "nk_combo_begin_text".}
proc nk_combo_begin_label*(a2: ptr nk_context; selected: cstring; size: nuk_vec2): cint {.
    cdecl, importc: "nk_combo_begin_label".}
proc nk_combo_begin_color*(a2: ptr nk_context; color: nk_color; size: nuk_vec2): cint {.
    cdecl, importc: "nk_combo_begin_color".}
proc nk_combo_begin_symbol*(a2: ptr nk_context; a3: nk_symbol_type; size: nuk_vec2): cint {.
    cdecl, importc: "nk_combo_begin_symbol".}
proc nk_combo_begin_symbol_label*(a2: ptr nk_context; selected: cstring;
                                 a4: nk_symbol_type; size: nuk_vec2): cint {.cdecl,
    importc: "nk_combo_begin_symbol_label".}
proc nk_combo_begin_symbol_text*(a2: ptr nk_context; selected: cstring; a4: cint;
                                a5: nk_symbol_type; size: nuk_vec2): cint {.cdecl,
    importc: "nk_combo_begin_symbol_text".}
proc nk_combo_begin_image*(a2: ptr nk_context; img: nuk_image; size: nuk_vec2): cint {.
    cdecl, importc: "nk_combo_begin_image".}
proc nk_combo_begin_image_label*(a2: ptr nk_context; selected: cstring; a4: nuk_image;
                                size: nuk_vec2): cint {.cdecl,
    importc: "nk_combo_begin_image_label".}
proc nk_combo_begin_image_text*(a2: ptr nk_context; selected: cstring; a4: cint;
                               a5: nuk_image; size: nuk_vec2): cint {.cdecl,
    importc: "nk_combo_begin_image_text".}
proc nk_combo_item_label*(a2: ptr nk_context; a3: cstring; alignment: nk_flags): cint {.
    cdecl, importc: "nk_combo_item_label".}
proc nk_combo_item_text*(a2: ptr nk_context; a3: cstring; a4: cint; alignment: nk_flags): cint {.
    cdecl, importc: "nk_combo_item_text".}
proc nk_combo_item_image_label*(a2: ptr nk_context; a3: nuk_image; a4: cstring;
                               alignment: nk_flags): cint {.cdecl,
    importc: "nk_combo_item_image_label".}
proc nk_combo_item_image_text*(a2: ptr nk_context; a3: nuk_image; a4: cstring; a5: cint;
                              alignment: nk_flags): cint {.cdecl,
    importc: "nk_combo_item_image_text".}
proc nk_combo_item_symbol_label*(a2: ptr nk_context; a3: nk_symbol_type; a4: cstring;
                                alignment: nk_flags): cint {.cdecl,
    importc: "nk_combo_item_symbol_label".}
proc nk_combo_item_symbol_text*(a2: ptr nk_context; a3: nk_symbol_type; a4: cstring;
                               a5: cint; alignment: nk_flags): cint {.cdecl,
    importc: "nk_combo_item_symbol_text".}
proc nk_combo_close*(a2: ptr nk_context) {.cdecl, importc: "nk_combo_close".}
proc nk_combo_end*(a2: ptr nk_context) {.cdecl, importc: "nk_combo_end".}
proc nk_contextual_begin*(a2: ptr nk_context; a3: nk_flags; a4: nuk_vec2;
                         trigger_bounds: nuk_rect): cint {.cdecl,
    importc: "nk_contextual_begin".}
proc nk_contextual_item_text*(a2: ptr nk_context; a3: cstring; a4: cint; align: nk_flags): cint {.
    cdecl, importc: "nk_contextual_item_text".}
proc nk_contextual_item_label*(a2: ptr nk_context; a3: cstring; align: nk_flags): cint {.
    cdecl, importc: "nk_contextual_item_label".}
proc nk_contextual_item_image_label*(a2: ptr nk_context; a3: nuk_image; a4: cstring;
                                    alignment: nk_flags): cint {.cdecl,
    importc: "nk_contextual_item_image_label".}
proc nk_contextual_item_image_text*(a2: ptr nk_context; a3: nuk_image; a4: cstring;
                                   len: cint; alignment: nk_flags): cint {.cdecl,
    importc: "nk_contextual_item_image_text".}
proc nk_contextual_item_symbol_label*(a2: ptr nk_context; a3: nk_symbol_type;
                                     a4: cstring; alignment: nk_flags): cint {.cdecl,
    importc: "nk_contextual_item_symbol_label".}
proc nk_contextual_item_symbol_text*(a2: ptr nk_context; a3: nk_symbol_type;
                                    a4: cstring; a5: cint; alignment: nk_flags): cint {.
    cdecl, importc: "nk_contextual_item_symbol_text".}
proc nk_contextual_close*(a2: ptr nk_context) {.cdecl,
    importc: "nk_contextual_close".}
proc nk_contextual_end*(a2: ptr nk_context) {.cdecl, importc: "nk_contextual_end".}
proc nk_tooltip*(a2: ptr nk_context; a3: cstring) {.cdecl, importc: "nk_tooltip".}
proc nk_tooltip_begin*(a2: ptr nk_context; width: cfloat): cint {.cdecl,
    importc: "nk_tooltip_begin".}
proc nk_tooltip_end*(a2: ptr nk_context) {.cdecl, importc: "nk_tooltip_end".}
proc nk_menubar_begin*(a2: ptr nk_context) {.cdecl, importc: "nk_menubar_begin".}
proc nk_menubar_end*(a2: ptr nk_context) {.cdecl, importc: "nk_menubar_end".}
proc nk_menu_begin_text*(a2: ptr nk_context; title: cstring; title_len: cint;
                        align: nk_flags; size: nuk_vec2): cint {.cdecl,
    importc: "nk_menu_begin_text".}
proc nk_menu_begin_label*(a2: ptr nk_context; a3: cstring; align: nk_flags;
                         size: nuk_vec2): cint {.cdecl,
    importc: "nk_menu_begin_label".}
proc nk_menu_begin_image*(a2: ptr nk_context; a3: cstring; a4: nuk_image; size: nuk_vec2): cint {.
    cdecl, importc: "nk_menu_begin_image".}
proc nk_menu_begin_image_text*(a2: ptr nk_context; a3: cstring; a4: cint;
                              align: nk_flags; a6: nuk_image; size: nuk_vec2): cint {.
    cdecl, importc: "nk_menu_begin_image_text".}
proc nk_menu_begin_image_label*(a2: ptr nk_context; a3: cstring; align: nk_flags;
                               a5: nuk_image; size: nuk_vec2): cint {.cdecl,
    importc: "nk_menu_begin_image_label".}
proc nk_menu_begin_symbol*(a2: ptr nk_context; a3: cstring; a4: nk_symbol_type;
                          size: nuk_vec2): cint {.cdecl,
    importc: "nk_menu_begin_symbol".}
proc nk_menu_begin_symbol_text*(a2: ptr nk_context; a3: cstring; a4: cint;
                               align: nk_flags; a6: nk_symbol_type; size: nuk_vec2): cint {.
    cdecl, importc: "nk_menu_begin_symbol_text".}
proc nk_menu_begin_symbol_label*(a2: ptr nk_context; a3: cstring; align: nk_flags;
                                a5: nk_symbol_type; size: nuk_vec2): cint {.cdecl,
    importc: "nk_menu_begin_symbol_label".}
proc nk_menu_item_text*(a2: ptr nk_context; a3: cstring; a4: cint; align: nk_flags): cint {.
    cdecl, importc: "nk_menu_item_text".}
proc nk_menu_item_label*(a2: ptr nk_context; a3: cstring; alignment: nk_flags): cint {.
    cdecl, importc: "nk_menu_item_label".}
proc nk_menu_item_image_label*(a2: ptr nk_context; a3: nuk_image; a4: cstring;
                              alignment: nk_flags): cint {.cdecl,
    importc: "nk_menu_item_image_label".}
proc nk_menu_item_image_text*(a2: ptr nk_context; a3: nuk_image; a4: cstring; len: cint;
                             alignment: nk_flags): cint {.cdecl,
    importc: "nk_menu_item_image_text".}
proc nk_menu_item_symbol_text*(a2: ptr nk_context; a3: nk_symbol_type; a4: cstring;
                              a5: cint; alignment: nk_flags): cint {.cdecl,
    importc: "nk_menu_item_symbol_text".}
proc nk_menu_item_symbol_label*(a2: ptr nk_context; a3: nk_symbol_type; a4: cstring;
                               alignment: nk_flags): cint {.cdecl,
    importc: "nk_menu_item_symbol_label".}
proc nk_menu_close*(a2: ptr nk_context) {.cdecl, importc: "nk_menu_close".}
proc nk_menu_end*(a2: ptr nk_context) {.cdecl, importc: "nk_menu_end".}
proc nk_convert*(a2: ptr nk_context; cmds: ptr nk_buffer; vertices: ptr nk_buffer;
                elements: ptr nk_buffer; a6: ptr nk_convert_config) {.cdecl,
    importc: "nk_convert".}
proc nk_draw_begin*(a2: ptr nk_context; a3: ptr nk_buffer): ptr nk_draw_command {.cdecl,
    importc: "nk__draw_begin".}
proc nk_draw_end*(a2: ptr nk_context; a3: ptr nk_buffer): ptr nk_draw_command {.cdecl,
    importc: "nk__draw_end".}
proc nk_draw_next*(a2: ptr nk_draw_command; a3: ptr nk_buffer; a4: ptr nk_context): ptr nk_draw_command {.
    cdecl, importc: "nk__draw_next".}
proc nk_input_begin*(a2: ptr nk_context) {.cdecl, importc: "nk_input_begin".}
proc nk_input_motion*(a2: ptr nk_context; x: cint; y: cint) {.cdecl,
    importc: "nk_input_motion".}
proc nk_input_key*(a2: ptr nk_context; a3: nk_keys; down: cint) {.cdecl,
    importc: "nk_input_key".}
proc nk_input_button*(a2: ptr nk_context; a3: nk_buttons; x: cint; y: cint; down: cint) {.
    cdecl, importc: "nk_input_button".}
proc nk_input_scroll*(a2: ptr nk_context; y: cfloat) {.cdecl,
    importc: "nk_input_scroll".}
proc nk_input_char*(a2: ptr nk_context; a3: char) {.cdecl, importc: "nk_input_char".}
proc nk_input_glyph*(a2: ptr nk_context; a3: nk_glyph) {.cdecl,
    importc: "nk_input_glyph".}
proc nk_input_unicode*(a2: ptr nk_context; a3: nk_rune) {.cdecl,
    importc: "nk_input_unicode".}
proc nk_input_end*(a2: ptr nk_context) {.cdecl, importc: "nk_input_end".}
proc nk_style_default*(a2: ptr nk_context) {.cdecl, importc: "nk_style_default".}
proc nk_style_from_table*(a2: ptr nk_context; a3: ptr nk_color) {.cdecl,
    importc: "nk_style_from_table".}
proc nk_style_load_cursor*(a2: ptr nk_context; a3: nk_style_cursor; a4: ptr nk_cursor) {.
    cdecl, importc: "nk_style_load_cursor".}
proc nk_style_load_all_cursors*(a2: ptr nk_context; a3: ptr nk_cursor) {.cdecl,
    importc: "nk_style_load_all_cursors".}
proc nk_style_get_color_by_name*(a2: nk_style_colors): cstring {.cdecl,
    importc: "nk_style_get_color_by_name".}
proc nk_style_set_font*(a2: ptr nk_context; a3: ptr nk_user_font) {.cdecl,
    importc: "nk_style_set_font".}
proc nk_style_set_cursor*(a2: ptr nk_context; a3: nk_style_cursor): cint {.cdecl,
    importc: "nk_style_set_cursor".}
proc nk_style_show_cursor*(a2: ptr nk_context) {.cdecl,
    importc: "nk_style_show_cursor".}
proc nk_style_hide_cursor*(a2: ptr nk_context) {.cdecl,
    importc: "nk_style_hide_cursor".}
proc nk_style_push_font*(a2: ptr nk_context; a3: ptr nk_user_font): cint {.cdecl,
    importc: "nk_style_push_font".}
proc nk_style_push_float*(a2: ptr nk_context; a3: ptr cfloat; a4: cfloat): cint {.cdecl,
    importc: "nk_style_push_float".}
proc nk_style_push_vec2*(a2: ptr nk_context; a3: ptr nuk_vec2; a4: nuk_vec2): cint {.cdecl,
    importc: "nk_style_push_vec2".}
proc nk_style_push_style_item*(a2: ptr nk_context; a3: ptr nk_style_item;
                              a4: nk_style_item): cint {.cdecl,
    importc: "nk_style_push_style_item".}
proc nk_style_push_flags*(a2: ptr nk_context; a3: ptr nk_flags; a4: nk_flags): cint {.
    cdecl, importc: "nk_style_push_flags".}
proc nk_style_push_color*(a2: ptr nk_context; a3: ptr nk_color; a4: nk_color): cint {.
    cdecl, importc: "nk_style_push_color".}
proc nk_style_pop_font*(a2: ptr nk_context): cint {.cdecl,
    importc: "nk_style_pop_font".}
proc nk_style_pop_float*(a2: ptr nk_context): cint {.cdecl,
    importc: "nk_style_pop_float".}
proc nk_style_pop_vec2*(a2: ptr nk_context): cint {.cdecl,
    importc: "nk_style_pop_vec2".}
proc nk_style_pop_style_item*(a2: ptr nk_context): cint {.cdecl,
    importc: "nk_style_pop_style_item".}
proc nk_style_pop_flags*(a2: ptr nk_context): cint {.cdecl,
    importc: "nk_style_pop_flags".}
proc nk_style_pop_color*(a2: ptr nk_context): cint {.cdecl,
    importc: "nk_style_pop_color".}
proc nk_widget_bounds*(a2: ptr nk_context): nuk_rect {.cdecl,
    importc: "nk_widget_bounds".}
proc nk_widget_position*(a2: ptr nk_context): nuk_vec2 {.cdecl,
    importc: "nk_widget_position".}
proc nk_widget_size*(a2: ptr nk_context): nuk_vec2 {.cdecl, importc: "nk_widget_size".}
proc nk_widget_width*(a2: ptr nk_context): cfloat {.cdecl, importc: "nk_widget_width".}
proc nk_widget_height*(a2: ptr nk_context): cfloat {.cdecl,
    importc: "nk_widget_height".}
proc nk_widget_is_hovered*(a2: ptr nk_context): cint {.cdecl,
    importc: "nk_widget_is_hovered".}
proc nk_widget_is_mouse_clicked*(a2: ptr nk_context; a3: nk_buttons): cint {.cdecl,
    importc: "nk_widget_is_mouse_clicked".}
proc nk_widget_has_mouse_click_down*(a2: ptr nk_context; a3: nk_buttons; down: cint): cint {.
    cdecl, importc: "nk_widget_has_mouse_click_down".}
proc nk_spacing*(a2: ptr nk_context; cols: cint) {.cdecl, importc: "nk_spacing".}
proc nk_widget*(a2: ptr nuk_rect; a3: ptr nk_context): nk_widget_layout_states {.cdecl,
    importc: "nk_widget".}
proc nk_widget_fitting*(a2: ptr nuk_rect; a3: ptr nk_context; a4: nuk_vec2): nk_widget_layout_states {.
    cdecl, importc: "nk_widget_fitting".}
proc nk_rgb*(r: cint; g: cint; b: cint): nk_color {.cdecl, importc: "nk_rgb".}
proc nk_rgb_iv*(rgb: ptr cint): nk_color {.cdecl, importc: "nk_rgb_iv".}
proc nk_rgb_bv*(rgb: ptr nk_byte): nk_color {.cdecl, importc: "nk_rgb_bv".}
proc nk_rgb_f*(r: cfloat; g: cfloat; b: cfloat): nk_color {.cdecl, importc: "nk_rgb_f".}
proc nk_rgb_fv*(rgb: ptr cfloat): nk_color {.cdecl, importc: "nk_rgb_fv".}
proc nk_rgb_hex*(rgb: cstring): nk_color {.cdecl, importc: "nk_rgb_hex".}
proc nk_rgba*(r: cint; g: cint; b: cint; a: cint): nk_color {.cdecl, importc: "nk_rgba".}
proc nk_rgba_u32*(a2: nk_uint): nk_color {.cdecl, importc: "nk_rgba_u32".}
proc nk_rgba_iv*(rgba: ptr cint): nk_color {.cdecl, importc: "nk_rgba_iv".}
proc nk_rgba_bv*(rgba: ptr nk_byte): nk_color {.cdecl, importc: "nk_rgba_bv".}
proc nk_rgba_f*(r: cfloat; g: cfloat; b: cfloat; a: cfloat): nk_color {.cdecl,
    importc: "nk_rgba_f".}
proc nk_rgba_fv*(rgba: ptr cfloat): nk_color {.cdecl, importc: "nk_rgba_fv".}
proc nk_rgba_hex*(rgb: cstring): nk_color {.cdecl, importc: "nk_rgba_hex".}
proc nk_hsv*(h: cint; s: cint; v: cint): nk_color {.cdecl, importc: "nk_hsv".}
proc nk_hsv_iv*(hsv: ptr cint): nk_color {.cdecl, importc: "nk_hsv_iv".}
proc nk_hsv_bv*(hsv: ptr nk_byte): nk_color {.cdecl, importc: "nk_hsv_bv".}
proc nk_hsv_f*(h: cfloat; s: cfloat; v: cfloat): nk_color {.cdecl, importc: "nk_hsv_f".}
proc nk_hsv_fv*(hsv: ptr cfloat): nk_color {.cdecl, importc: "nk_hsv_fv".}
proc nk_hsva*(h: cint; s: cint; v: cint; a: cint): nk_color {.cdecl, importc: "nk_hsva".}
proc nk_hsva_iv*(hsva: ptr cint): nk_color {.cdecl, importc: "nk_hsva_iv".}
proc nk_hsva_bv*(hsva: ptr nk_byte): nk_color {.cdecl, importc: "nk_hsva_bv".}
proc nk_hsva_f*(h: cfloat; s: cfloat; v: cfloat; a: cfloat): nk_color {.cdecl,
    importc: "nk_hsva_f".}
proc nk_hsva_fv*(hsva: ptr cfloat): nk_color {.cdecl, importc: "nk_hsva_fv".}
proc nk_color_f*(r: ptr cfloat; g: ptr cfloat; b: ptr cfloat; a: ptr cfloat; a6: nk_color) {.
    cdecl, importc: "nk_color_f".}
proc nk_color_fv*(rgba_out: ptr cfloat; a3: nk_color) {.cdecl, importc: "nk_color_fv".}
proc nk_color_d*(r: ptr cdouble; g: ptr cdouble; b: ptr cdouble; a: ptr cdouble; a6: nk_color) {.
    cdecl, importc: "nk_color_d".}
proc nk_color_dv*(rgba_out: ptr cdouble; a3: nk_color) {.cdecl, importc: "nk_color_dv".}
proc nk_color_u32*(a2: nk_color): nk_uint {.cdecl, importc: "nk_color_u32".}
proc nk_color_hex_rgba*(output: cstring; a3: nk_color) {.cdecl,
    importc: "nk_color_hex_rgba".}
proc nk_color_hex_rgb*(output: cstring; a3: nk_color) {.cdecl,
    importc: "nk_color_hex_rgb".}
proc nk_color_hsv_i*(out_h: ptr cint; out_s: ptr cint; out_v: ptr cint; a5: nk_color) {.
    cdecl, importc: "nk_color_hsv_i".}
proc nk_color_hsv_b*(out_h: ptr nk_byte; out_s: ptr nk_byte; out_v: ptr nk_byte;
                    a5: nk_color) {.cdecl, importc: "nk_color_hsv_b".}
proc nk_color_hsv_iv*(hsv_out: ptr cint; a3: nk_color) {.cdecl,
    importc: "nk_color_hsv_iv".}
proc nk_color_hsv_bv*(hsv_out: ptr nk_byte; a3: nk_color) {.cdecl,
    importc: "nk_color_hsv_bv".}
proc nk_color_hsv_f*(out_h: ptr cfloat; out_s: ptr cfloat; out_v: ptr cfloat; a5: nk_color) {.
    cdecl, importc: "nk_color_hsv_f".}
proc nk_color_hsv_fv*(hsv_out: ptr cfloat; a3: nk_color) {.cdecl,
    importc: "nk_color_hsv_fv".}
proc nk_color_hsva_i*(h: ptr cint; s: ptr cint; v: ptr cint; a: ptr cint; a6: nk_color) {.
    cdecl, importc: "nk_color_hsva_i".}
proc nk_color_hsva_b*(h: ptr nk_byte; s: ptr nk_byte; v: ptr nk_byte; a: ptr nk_byte;
                     a6: nk_color) {.cdecl, importc: "nk_color_hsva_b".}
proc nk_color_hsva_iv*(hsva_out: ptr cint; a3: nk_color) {.cdecl,
    importc: "nk_color_hsva_iv".}
proc nk_color_hsva_bv*(hsva_out: ptr nk_byte; a3: nk_color) {.cdecl,
    importc: "nk_color_hsva_bv".}
proc nk_color_hsva_f*(out_h: ptr cfloat; out_s: ptr cfloat; out_v: ptr cfloat;
                     out_a: ptr cfloat; a6: nk_color) {.cdecl,
    importc: "nk_color_hsva_f".}
proc nk_color_hsva_fv*(hsva_out: ptr cfloat; a3: nk_color) {.cdecl,
    importc: "nk_color_hsva_fv".}
proc nk_handle_ptr*(a2: pointer): nk_handle {.cdecl, importc: "nk_handle_ptr".}
proc nk_handle_id*(a2: cint): nk_handle {.cdecl, importc: "nk_handle_id".}
proc nk_image_handle*(a2: nk_handle): nuk_image {.cdecl, importc: "nk_image_handle".}
proc nk_image_ptr*(a2: pointer): nuk_image {.cdecl, importc: "nk_image_ptr".}
proc nk_image_id*(a2: cint): nuk_image {.cdecl, importc: "nk_image_id".}
proc nk_image_is_subimage*(img: ptr nuk_image): cint {.cdecl,
    importc: "nk_image_is_subimage".}
proc nk_subimage_ptr*(a2: pointer; w: cushort; h: cushort; sub_region: nuk_rect): nuk_image {.
    cdecl, importc: "nk_subimage_ptr".}
proc nk_subimage_id*(a2: cint; w: cushort; h: cushort; sub_region: nuk_rect): nuk_image {.
    cdecl, importc: "nk_subimage_id".}
proc nk_subimage_handle*(a2: nk_handle; w: cushort; h: cushort; sub_region: nuk_rect): nuk_image {.
    cdecl, importc: "nk_subimage_handle".}
proc nk_murmur_hash*(key: pointer; len: cint; seed: nk_hash): nk_hash {.cdecl,
    importc: "nk_murmur_hash".}
proc nk_triangle_from_direction*(result: ptr nuk_vec2; r: nuk_rect; pad_x: cfloat;
                                pad_y: cfloat; a6: nk_heading) {.cdecl,
    importc: "nk_triangle_from_direction".}
proc nk_vec2*(x: cfloat; y: cfloat): nuk_vec2 {.cdecl, importc: "nk_vec2".}
proc nk_vec2i*(x: cint; y: cint): nuk_vec2 {.cdecl, importc: "nk_vec2i".}
proc nk_vec2v*(xy: ptr cfloat): nuk_vec2 {.cdecl, importc: "nk_vec2v".}
proc nk_vec2iv*(xy: ptr cint): nuk_vec2 {.cdecl, importc: "nk_vec2iv".}
proc nk_get_null_rect*(): nuk_rect {.cdecl, importc: "nk_get_null_rect".}
proc nk_rect*(x: cfloat; y: cfloat; w: cfloat; h: cfloat): nuk_rect {.cdecl,
    importc: "nk_rect".}
proc nk_recti*(x: cint; y: cint; w: cint; h: cint): nuk_rect {.cdecl, importc: "nk_recti".}
proc nk_recta*(pos: nuk_vec2; size: nuk_vec2): nuk_rect {.cdecl, importc: "nk_recta".}
proc nk_rectv*(xywh: ptr cfloat): nuk_rect {.cdecl, importc: "nk_rectv".}
proc nk_rectiv*(xywh: ptr cint): nuk_rect {.cdecl, importc: "nk_rectiv".}
proc nk_rect_pos*(a2: nuk_rect): nuk_vec2 {.cdecl, importc: "nk_rect_pos".}
proc nk_rect_size*(a2: nuk_rect): nuk_vec2 {.cdecl, importc: "nk_rect_size".}
proc nk_strlen*(str: cstring): cint {.cdecl, importc: "nk_strlen".}
proc nk_stricmp*(s1: cstring; s2: cstring): cint {.cdecl, importc: "nk_stricmp".}
proc nk_stricmpn*(s1: cstring; s2: cstring; n: cint): cint {.cdecl,
    importc: "nk_stricmpn".}
proc nk_strtoi*(str: cstring; endptr: cstringArray): cint {.cdecl,
    importc: "nk_strtoi".}
proc nk_strtof*(str: cstring; endptr: cstringArray): cfloat {.cdecl,
    importc: "nk_strtof".}
proc nk_strtod*(str: cstring; endptr: cstringArray): cdouble {.cdecl,
    importc: "nk_strtod".}
proc nk_strfilter*(text: cstring; regexp: cstring): cint {.cdecl,
    importc: "nk_strfilter".}
proc nk_strmatch_fuzzy_string*(str: cstring; pattern: cstring; out_score: ptr cint): cint {.
    cdecl, importc: "nk_strmatch_fuzzy_string".}
proc nk_strmatch_fuzzy_text*(txt: cstring; txt_len: cint; pattern: cstring;
                            out_score: ptr cint): cint {.cdecl,
    importc: "nk_strmatch_fuzzy_text".}
proc nk_utf_decode*(a2: cstring; a3: ptr nk_rune; a4: cint): cint {.cdecl,
    importc: "nk_utf_decode".}
proc nk_utf_encode*(a2: nk_rune; a3: cstring; a4: cint): cint {.cdecl,
    importc: "nk_utf_encode".}
proc nk_utf_len*(a2: cstring; byte_len: cint): cint {.cdecl, importc: "nk_utf_len".}
proc nk_utf_at*(buffer: cstring; length: cint; index: cint; unicode: ptr nk_rune;
               len: ptr cint): cstring {.cdecl, importc: "nk_utf_at".}


type
  nk_baked_font* = object
    height*: cfloat
    ascent*: cfloat
    descent*: cfloat
    glyph_offset*: nk_rune
    glyph_count*: nk_rune
    ranges*: ptr nk_rune

  nk_font_config* = object
    next*: ptr nk_font_config
    ttf_blob*: pointer
    ttf_size*: nk_size
    ttf_data_owned_by_atlas*: cuchar
    merge_mode*: cuchar
    pixel_snap*: cuchar
    oversample_v*: cuchar
    oversample_h*: cuchar
    padding*: array[3, cuchar]
    size*: cfloat
    coord_type*: nk_font_coord_type
    spacing*: nuk_vec2
    range*: ptr nk_rune
    font*: ptr nk_baked_font
    fallback_glyph*: nk_rune

  nk_font_glyph* = object
    codepoint*: nk_rune
    xadvance*: cfloat
    x0*: cfloat
    y0*: cfloat
    x1*: cfloat
    y1*: cfloat
    w*: cfloat
    h*: cfloat
    u0*: cfloat
    v0*: cfloat
    u1*: cfloat
    v1*: cfloat

  nk_font* = object
    next*: ptr nk_font
    handle*: nk_user_font
    info*: nk_baked_font
    scale*: cfloat
    glyphs*: ptr nk_font_glyph
    fallback*: ptr nk_font_glyph
    fallback_codepoint*: nk_rune
    texture*: nk_handle
    config*: ptr nk_font_config

  nk_font_atlas_format* {.size: sizeof(cint).} = enum
    NK_FONT_ATLAS_ALPHA8, NK_FONT_ATLAS_RGBA32


type
  nk_font_atlas* = object
    pixel*: pointer
    tex_width*: cint
    tex_height*: cint
    permanent*: nk_allocator
    temporary*: nk_allocator
    custom*: nuk_recti
    cursors*: array[NK_CURSOR_COUNT, nk_cursor]
    glyph_count*: cint
    glyphs*: ptr nk_font_glyph
    default_font*: ptr nk_font
    fonts*: ptr nk_font
    config*: ptr nk_font_config
    font_num*: cint


proc nk_font_default_glyph_ranges*(): ptr nk_rune {.cdecl,
    importc: "nk_font_default_glyph_ranges".}
proc nk_font_chinese_glyph_ranges*(): ptr nk_rune {.cdecl,
    importc: "nk_font_chinese_glyph_ranges".}
proc nk_font_cyrillic_glyph_ranges*(): ptr nk_rune {.cdecl,
    importc: "nk_font_cyrillic_glyph_ranges".}
proc nk_font_korean_glyph_ranges*(): ptr nk_rune {.cdecl,
    importc: "nk_font_korean_glyph_ranges".}
proc nk_font_atlas_init_default*(a2: ptr nk_font_atlas) {.cdecl,
    importc: "nk_font_atlas_init_default".}
proc nk_font_atlas_init*(a2: ptr nk_font_atlas; a3: ptr nk_allocator) {.cdecl,
    importc: "nk_font_atlas_init".}
proc nk_font_atlas_init_custom*(a2: ptr nk_font_atlas; persistent: ptr nk_allocator;
                               transient: ptr nk_allocator) {.cdecl,
    importc: "nk_font_atlas_init_custom".}
proc nk_font_atlas_begin*(a2: ptr nk_font_atlas) {.cdecl,
    importc: "nk_font_atlas_begin".}
proc nk_font_atlas_add*(a2: ptr nk_font_atlas; a3: ptr nk_font_config): ptr nk_font {.
    cdecl, importc: "nk_font_atlas_add".}
proc nk_font_atlas_add_from_memory*(atlas: ptr nk_font_atlas; memory: pointer;
                                   size: nk_size; height: cfloat;
                                   config: ptr nk_font_config): ptr nk_font {.cdecl,
    importc: "nk_font_atlas_add_from_memory".}
proc nk_font_atlas_add_compressed*(a2: ptr nk_font_atlas; memory: pointer;
                                  size: nk_size; height: cfloat;
                                  a6: ptr nk_font_config): ptr nk_font {.cdecl,
    importc: "nk_font_atlas_add_compressed".}
proc nk_font_atlas_add_compressed_base85*(a2: ptr nk_font_atlas; data: cstring;
    height: cfloat; config: ptr nk_font_config): ptr nk_font {.cdecl,
    importc: "nk_font_atlas_add_compressed_base85".}
proc nk_font_atlas_bake*(a2: ptr nk_font_atlas; width: ptr cint; height: ptr cint;
                        a5: nk_font_atlas_format): pointer {.cdecl,
    importc: "nk_font_atlas_bake".}
proc nk_font_atlas_end*(a2: ptr nk_font_atlas; tex: nk_handle;
                       a4: ptr nk_draw_null_texture) {.cdecl,
    importc: "nk_font_atlas_end".}
proc nk_font_find_glyph*(a2: ptr nk_font; unicode: nk_rune): ptr nk_font_glyph {.cdecl,
    importc: "nk_font_find_glyph".}
proc nk_font_atlas_cleanup*(atlas: ptr nk_font_atlas) {.cdecl,
    importc: "nk_font_atlas_cleanup".}
proc nk_font_atlas_clear*(a2: ptr nk_font_atlas) {.cdecl,
    importc: "nk_font_atlas_clear".}
proc nk_font_atlas_add_default*(a2: ptr nk_font_atlas; height: cfloat;
                               a4: ptr nk_font_config): ptr nk_font {.cdecl, importc: "nk_font_atlas_add_default".}
proc nk_font_atlas_add_from_file*(atlas: ptr nk_font_atlas; file_path: cstring;
                                 height: cfloat; a5: ptr nk_font_config): ptr nk_font {.cdecl, importc: "nk_font_atlas_add_from_file".}

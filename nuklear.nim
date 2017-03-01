#[
 Nuklear - 1.33.0 - public domain
 no warrenty implied; use at your own risk.
 authored from 2015-2016 by Micha Mettke

ABOUT:
    This is a minimal state graphical user interface single header toolkit
    written in ANSI C and licensed under public domain.
    It was designed as a simple embeddable user interface for application and does
    not have any dependencies, a default renderbackend or OS window and input handling
    but instead provides a very modular library approach by using simple input state
    for input and draw commands describing primitive shapes as output.
    So instead of providing a layered library that tries to abstract over a number
    of platform and render backends it only focuses on the actual UI.

VALUES:
    - Graphical user interface toolkit
    - Single header library
    - Written in C89 (a.k.a. ANSI C or ISO C90)
    - Small codebase (~17kLOC)
    - Focus on portability, efficiency and simplicity
    - No dependencies (not even the standard library if not wanted)
    - Fully skinnable and customizable
    - Low memory footprint with total memory control if needed or wanted
    - UTF-8 support
    - No global or hidden state
    - Customizable library modules (you can compile and use only what you need)
    - Optional font baker and vertex buffer output

USAGE:
    This library is self contained in one single header file and can be used either
    in header only mode or in implementation mode. The header only mode is used
    by default when included and allows including this header in other headers
    and does not contain the actual implementation.

    The implementation mode requires to define  the preprocessor macro
    NK_IMPLEMENTATION in *one* .c/.cpp file before #includeing this file, e.g.:

        #define NK_IMPLEMENTATION
        #include "nuklear.h"

    Also optionally define the symbols listed in the section "OPTIONAL DEFINES"
    below in header and implementation mode if you want to use additional functionality
    or need more control over the library.
    IMPORTANT:  Every time you include "nuklear.h" you have to define the same flags.
                This is very important not doing it either leads to compiler errors
                or even worse stack corruptions.

FEATURES:
    - Absolutely no platform dependend code
    - Memory management control ranging from/to
        - Ease of use by allocating everything from standard library
        - Control every byte of memory inside the library
    - Font handling control ranging from/to
        - Use your own font implementation for everything
        - Use this libraries internal font baking and handling API
    - Drawing output control ranging from/to
        - Simple shapes for more high level APIs which already have drawing capabilities
        - Hardware accessible anti-aliased vertex buffer output
    - Customizable colors and properties ranging from/to
        - Simple changes to color by filling a simple color table
        - Complete control with ability to use skinning to decorate widgets
    - Bendable UI library with widget ranging from/to
        - Basic widgets like buttons, checkboxes, slider, ...
        - Advanced widget like abstract comboboxes, contextual menus,...
    - Compile time configuration to only compile what you need
        - Subset which can be used if you do not want to link or use the standard library
    - Can be easily modified to only update on user input instead of frame updates

OPTIONAL DEFINES:
    NK_PRIVATE
        If defined declares all functions as static, so they can only be accessed
        inside the file that contains the implementation

    NK_INCLUDE_FIXED_TYPES
        If defined it will include header <stdint.h> for fixed sized types
        otherwise nuklear tries to select the correct type. If that fails it will
        throw a compiler error and you have to select the correct types yourself.
        <!> If used needs to be defined for implementation and header <!>

    NK_INCLUDE_DEFAULT_ALLOCATOR
        if defined it will include header <stdlib.h> and provide additional functions
        to use this library without caring for memory allocation control and therefore
        ease memory management.
        <!> Adds the standard library with malloc and free so don't define if you
            don't want to link to the standard library <!>
        <!> If used needs to be defined for implementation and header <!>

    NK_INCLUDE_STANDARD_IO
        if defined it will include header <stdio.h> and provide
        additional functions depending on file loading.
        <!> Adds the standard library with fopen, fclose,... so don't define this
            if you don't want to link to the standard library <!>
        <!> If used needs to be defined for implementation and header <!>

    NK_INCLUDE_STANDARD_VARARGS
        if defined it will include header <stdarg.h> and provide
        additional functions depending on variable arguments
        <!> Adds the standard library with va_list and  so don't define this if
            you don't want to link to the standard library<!>
        <!> If used needs to be defined for implementation and header <!>

    NK_INCLUDE_VERTEX_BUFFER_OUTPUT
        Defining this adds a vertex draw command list backend to this
        library, which allows you to convert queue commands into vertex draw commands.
        This is mainly if you need a hardware accessible format for OpenGL, DirectX,
        Vulkan, Metal,...
        <!> If used needs to be defined for implementation and header <!>

    NK_INCLUDE_FONT_BAKING
        Defining this adds the `stb_truetype` and `stb_rect_pack` implementation
        to this library and provides font baking and rendering.
        If you already have font handling or do not want to use this font handler
        you don't have to define it.
        <!> If used needs to be defined for implementation and header <!>

    NK_INCLUDE_DEFAULT_FONT
        Defining this adds the default font: ProggyClean.ttf into this library
        which can be loaded into a font atlas and allows using this library without
        having a truetype font
        <!> Enabling this adds ~12kb to global stack memory <!>
        <!> If used needs to be defined for implementation and header <!>

    NK_INCLUDE_COMMAND_USERDATA
        Defining this adds a userdata pointer into each command. Can be useful for
        example if you want to provide custom shaders depending on the used widget.
        Can be combined with the style structures.
        <!> If used needs to be defined for implementation and header <!>

    NK_BUTTON_TRIGGER_ON_RELEASE
        Different platforms require button clicks occuring either on buttons being
        pressed (up to down) or released (down to up).
        By default this library will react on buttons being pressed, but if you
        define this it will only trigger if a button is released.
        <!> If used it is only required to be defined for the implementation part <!>

    NK_ZERO_COMMAND_MEMORY
        Defining this will zero out memory for each drawing command added to a
        drawing queue (inside nk_command_buffer_push). Zeroing command memory
        is very useful for fast checking (using memcmp) if command buffers are
        equal and avoid drawing frames when nothing on screen has changed since
        previous frame.

    NK_ASSERT
        If you don't define this, nuklear will use <assert.h> with assert().
        <!> Adds the standard library so define to nothing of not wanted <!>
        <!> If used needs to be defined for implementation and header <!>

    NK_BUFFER_DEFAULT_INITIAL_SIZE
        Initial buffer size allocated by all buffers while using the default allocator
        functions included by defining NK_INCLUDE_DEFAULT_ALLOCATOR. If you don't
        want to allocate the default 4k memory then redefine it.
        <!> If used needs to be defined for implementation and header <!>

    NK_MAX_NUMBER_BUFFER
        Maximum buffer size for the conversion buffer between float and string
        Under normal circumstances this should be more than sufficient.
        <!> If used needs to be defined for implementation and header <!>

    NK_INPUT_MAX
        Defines the max number of bytes which can be added as text input in one frame.
        Under normal circumstances this should be more than sufficient.
        <!> If used it is only required to be defined for the implementation part <!>

    NK_MEMSET
        You can define this to 'memset' or your own memset implementation
        replacement. If not nuklear will use its own version.
        <!> If used it is only required to be defined for the implementation part <!>

    NK_MEMCPY
        You can define this to 'memcpy' or your own memcpy implementation
        replacement. If not nuklear will use its own version.
        <!> If used it is only required to be defined for the implementation part <!>

    NK_SQRT
        You can define this to 'sqrt' or your own sqrt implementation
        replacement. If not nuklear will use its own slow and not highly
        accurate version.
        <!> If used it is only required to be defined for the implementation part <!>

    NK_SIN
        You can define this to 'sinf' or your own sine implementation
        replacement. If not nuklear will use its own approximation implementation.
        <!> If used it is only required to be defined for the implementation part <!>

    NK_COS
        You can define this to 'cosf' or your own cosine implementation
        replacement. If not nuklear will use its own approximation implementation.
        <!> If used it is only required to be defined for the implementation part <!>

    NK_STRTOD
        You can define this to `strtod` or your own string to double conversion
        implementation replacement. If not defined nuklear will use its own
        imprecise and possibly unsafe version (does not handle nan or infinity!).
        <!> If used it is only required to be defined for the implementation part <!>

    NK_DTOA
        You can define this to `dtoa` or your own double to string conversion
        implementation replacement. If not defined nuklear will use its own
        imprecise and possibly unsafe version (does not handle nan or infinity!).
        <!> If used it is only required to be defined for the implementation part <!>

    NK_VSNPRINTF
        If you define `NK_INCLUDE_STANDARD_VARARGS` as well as `NK_INCLUDE_STANDARD_IO`
        and want to be safe define this to `vsnprintf` on compilers supporting
        later versions of C or C++. By default nuklear will check for your stdlib version
        in C as well as compiler version in C++. if `vsnprintf` is available
        it will define it to `vsnprintf` directly. If not defined and if you have
        older versions of C or C++ it will be defined to `vsprintf` which is unsafe.
        <!> If used it is only required to be defined for the implementation part <!>

    NK_BYTE
    NK_INT16
    NK_UINT16
    NK_INT32
    NK_UINT32
    NK_SIZE_TYPE
    NK_POINTER_TYPE
        If you compile without NK_USE_FIXED_TYPE then a number of standard types
        will be selected and compile time validated. If they are incorrect you can
        define the correct types by overloading these type defines.

CREDITS:
    Developed by Micha Mettke and every direct or indirect contributor.

    Embeds stb_texedit, stb_truetype and stb_rectpack by Sean Barret (public domain)
    Embeds ProggyClean.ttf font by Tristan Grimmer (MIT license).

    Big thank you to Omar Cornut (ocornut@github) for his imgui library and
    giving me the inspiration for this library, Casey Muratori for handmade hero
    and his original immediate mode graphical user interface idea and Sean
    Barret for his amazing single header libraries which restored my faith
    in libraries and brought me to create some of my own.

LICENSE:
    This software is dual-licensed to the public domain and under the following
    license: you are granted a perpetual, irrevocable license to copy, modify,
    publish and distribute this file as you see fit.
]#
{.deadCodeElim: on.}

{.compile: "src/bind.c".}

import macros

macro find_size(a,b: untyped): untyped =
  if sizeof(a) < sizeof(b):
    sizeof(b)
  else:
    sizeof(a) div sizeof(uint32) div 2

type
  style_slide* = object
  

const
  nk_false* = 0
  nk_true* = 1
    

type
  handle* = pointer
  
  color* = object
    r*: char
    g*: char
    b*: char
    a*: char

  colorf* = object
    r*: float32
    g*: float32
    b*: float32
    a*: float32

  vec2* = object
    x*: float32
    y*: float32

  vec2i* = object
    x*: int16
    y*: int16

  rect* = object
    x*: float32
    y*: float32
    w*: float32
    h*: float32

  recti* = object
    x*: int16
    y*: int16
    w*: int16
    h*: int16

  glyph* = array[4, char]

  img* = object {.byCopy.}
    handle*: handle
    w*: uint16
    h*: uint16
    region*: array[4, uint16]

  cursor* = object
    img*: img
    size*: vec2
    offset*: vec2

  scroll* = object
    x*: uint32
    y*: uint32

  heading* {.size: sizeof(int32).} = enum
    UP, RIGHT, DOWN, LEFT

type
  user_font_glyph* = object
    uv*: array[2, vec2]      ##  texture coordinates
    offset*: vec2           ##  offset between top left and glyph
    width*: float32
    height*: float32            ##  size of the glyph
    xadvance*: float32          ##  offset to the next glyph
  
  text_width_f* = proc (a2: handle; h: float32; a4: cstring; len: int32): float32 {.cdecl.}
  query_font_glyph_f* = proc (handle: handle; font_height: float32;
                              glyph: ptr user_font_glyph; codepoint: uint32;
                              next_codepoint: uint32) {.cdecl.}
  user_font* = object
    userdata*: handle
    height*: float32
    width*: text_width_f
    query* :query_font_glyph_f
    texture*: handle

  font_coord_type* {.size: sizeof(int32).} = enum
    COORD_UV, COORD_PIXEL

  memory_status* = object
    memory*: pointer
    typ*: cuint
    size*: uint
    allocated*: uint
    needed*: uint
    calls*: uint

  allocation_type* {.size: sizeof(int32).} = enum
    BUFFER_FIXED, BUFFER_DYNAMIC


type
  buffer_allocation_type* {.size: sizeof(int32).} = enum
    BUFFER_FRONT, BUFFER_BACK, BUFFER_MAX

type
  anti_aliasing* {.size: sizeof(int32).} = enum
    ANTI_ALIASING_OFF, ANTI_ALIASING_ON

##################################################################
 #
 #                          MEMORY BUFFER
 #
##################################################################
#[  A basic (double)-buffer with linear allocation and resetting as only
    freeing policy. The buffer's main purpose is to control all memory management
    inside the GUI toolkit and still leave memory control as much as possible in
    the hand of the user while also making sure the library is easy to use if
    not as much control is needed.
    In general all memory inside this library can be provided from the user in
    three different ways.
    The first way and the one providing most control is by just passing a fixed
    size memory block. In this case all control lies in the hand of the user
    since he can exactly control where the memory comes from and how much memory
    the library should consume. Of course using the fixed size API removes the
    ability to automatically resize a buffer if not enough memory is provided so
    you have to take over the resizing. While being a fixed sized buffer sounds
    quite limiting, it is very effective in this library since the actual memory
    consumption is quite stable and has a fixed upper bound for a lot of cases.
    If you don't want to think about how much memory the library should allocate
    at all time or have a very dynamic UI with unpredictable memory consumption
    habits but still want control over memory allocation you can use the dynamic
    allocator based API. The allocator consists of two callbacks for allocating
    and freeing memory and optional userdata so you can plugin your own allocator.
    The final and easiest way can be used by defining
    NK_INCLUDE_DEFAULT_ALLOCATOR which uses the standard library memory
    allocation functions malloc and free and takes over complete control over
    memory in this library.
]#

type
  plugin_alloc* = proc (a2: handle; old: pointer; a4: uint): pointer {.cdecl.}
  plugin_free* = proc (a2: handle; old: pointer) {.cdecl.}
  allocator* = object
    userdata*: handle
    alloc*: plugin_alloc
    free*: plugin_free

  buffer_marker* = object
    active*: int32
    offset*: uint

  memory* = object
    pointr*: pointer
    size*: uint

  buffer* = object
    marker*: array[BUFFER_MAX, buffer_marker]
    pool*: allocator
    typ*: allocation_type
    memory*: memory
    grow_factor*: float32
    allocated*: uint
    needed*: uint
    calls*: uint
    size*: uint

proc buffer_init_default(a2: ptr buffer) {.importc: "nk_buffer_init_default".}
proc init*(b: var buffer) =
    buffer_init_default(addr b)

proc buffer_init(a2: ptr buffer; a3: ptr allocator; size: uint) {.importc: "nk_buffer_init".}
proc init*(b: var buffer, a: var allocator, size: uint) =
    buffer_init(addr b, addr a, size)

proc buffer_init_fixed(a2: ptr buffer; memory: pointer; size: uint) {.importc: "nk_buffer_init_fixed".}
proc init*(b: var buffer, memory: pointer, size:uint) =
  buffer_init_fixed(addr b, memory, size)

proc buffer_info(a2: ptr memory_status; a3: ptr buffer) {.importc: "nk_buffer_info".}
proc info*(b: var buffer, ms: var memory_status) =
  buffer_info(addr ms, addr b)

proc buffer_push(a2: ptr buffer; typ: buffer_allocation_type;
                    memory: pointer; size: uint; align: uint) {.importc: "nk_buffer_push".}
proc push*(b: var buffer, `type`: buffer_allocation_type, memory: pointer, size, align: uint) =
  buffer_push(addr b, `type`, memory, size, align)

proc buffer_mark*(a2: ptr buffer; typ: buffer_allocation_type) {.importc: "nk_buffer_mark".}
proc mark*(b: var buffer, `type`: buffer_allocation_type) =
  buffer_mark(addr b, `type`)

proc buffer_reset(a2: ptr buffer; typ: buffer_allocation_type) {.importc: "nk_buffer_reset".}
proc reset*(b: var buffer, `type`: buffer_allocation_type) =
  buffer_reset(addr b, `type`)

proc buffer_clear(a2: ptr buffer) {.importc: "nk_buffer_clear".}
proc clear*(b: var buffer) =
  buffer_clear(addr b)

proc buffer_free(a2: ptr buffer) {.importc: "nk_buffer_free".}
proc free*(b: var buffer) =
  buffer_free(addr b)

proc buffer_memory(a2: ptr buffer): pointer {.importc: "nk_buffer_memory".}
proc bufferMemory*(b: var buffer): pointer =
  buffer_memory(addr b)

proc buffer_memory_const(a2: ptr buffer): pointer {.importc: "nk_buffer_memory_const".}
proc bufferMemoryConst*(b: var buffer): pointer =
  buffer_memory_const(addr b)

proc buffer_total*(a2: ptr buffer): uint {.importc: "nk_buffer_total".}
proc total*(b: var buffer): uint =
  buffer_total(addr b)

##################################################################
 #*
 #                          STRING
 #
###################################################################
##  Basic string buffer which is only used in context with the text editor
 #  to manage and manipulate dynamic or fixed size string content. This is _NOT_
 #  the default string handling method. The only instance you should have any contact
 #  with this API is if you interact with an `nk_text_edit` object inside one of the
 #  copy and paste functions and even there only for more advanced cases. */
type
  str* = object
    buffer*: buffer
    len*: int32

proc str_init(a2: ptr str; a3: ptr allocator; size: uint) {.importc: "nk_str_init".}
proc init*(s: var str, a: var allocator, size: uint) =
  str_init(addr s, addr a, size)

proc str_init_fixed(a2: ptr str; memory: pointer; size: uint) {.importc: "nk_str_init_fixed".}
proc initFixed*(s: var str, memory: pointer, size: uint) =
  str_init_fixed(addr s, memory, size)

proc str_clear(a2: ptr str) {.importc: "nk_str_clear".}
proc clear*(s: var str) =
  str_clear(addr s)

proc str_free(a2: ptr str) {.importc: "nk_str_free".}
proc free*(s: var str) =
  str_free(addr s)

proc str_append_text_char(a2: ptr str; a3: cstring; a4: int32): int32 {.importc: "nk_str_append_text_char".}
proc appendTextChar*(s: var str, t: string, c: int32): int32 =
  str_append_text_char(addr s, t, c)

proc str_append_str_char(a2: ptr str; a3: cstring): int32 {.importc: "nk_str_append_str_char".}
proc appendStrChar*(s: var str, t: string): int32 =
  str_append_str_char(addr s, t)

proc str_append_text_utf8(a2: ptr str; a3: cstring; a4: int32): int32 {.importc: "nk_str_append_text_utf8".}
proc appendTextUTF8*(s: var str, t: string, u: int32): int32 =
  str_append_text_utf8(addr s, t, u)

proc str_append_str_utf8(a2: ptr str; a3: cstring): int32 {.importc: "nk_str_append_str_utf8".}
proc appendStrUTF8*(s: var str, t: string): int32 =
  str_append_str_utf8(addr s, t)

proc str_append_text_runes(a2: ptr str; a3: ptr uint32; a4: int32): int32 {.importc: "nk_str_append_text_runes".}
proc appendTextRunes*(s: var str, u: var uint32, i: int32): int32 =
  str_append_text_runes(addr s, addr u, i)

proc str_append_str_runes(a2: ptr str; a3: ptr uint32): int32 {.importc: "nk_str_append_str_runes".}
proc appendStrRunes*(s: var str, u: var uint32): int32 =
  str_append_str_runes(addr s, addr u)

proc str_insert_at_char(a2: ptr str; pos: int32; a4: cstring; a5: int32): int32 {. importc: "nk_str_insert_at_char".}
proc insertAtChar*(s: var str, pos: int32, t: string, i: int32): int32 =
  str_insert_at_char(addr s, pos, t, i)

proc str_insert_at_rune(a2: ptr str; pos: int32; a4: cstring; a5: int32): int32 {. importc: "nk_str_insert_at_rune".}
proc insertAtRune*(s: var str, pos: int32, t: string, i: int32): int32 =
  str_insert_at_rune(addr s, pos, t, i)

proc str_insert_text_char(a2: ptr str; pos: int32; a4: cstring; a5: int32): int32 {. importc: "nk_str_insert_text_char".}
proc insertTextChar*(s: var str, pos: int32, t: string, i: int32): int32 =
  str_insert_text_char(addr s, pos, t, i)

proc str_insert_str_char(a2: ptr str; pos: int32; a4: cstring): int32 {.importc: "nk_str_insert_str_char".}
proc insertStrChar*(s: var str, pos: int32, t: string): int32 =
  str_insert_str_char(addr s, pos, t)

proc str_insert_text_utf8(a2: ptr str; pos: int32; a4: cstring; a5: int32): int32 {. importc: "nk_str_insert_text_utf8".}
proc insertTextUTF8*(s: var str, pos: int32, t: string, i: int32): int32 =
  str_insert_text_utf8(addr s, pos, t, i)

proc str_insert_str_utf8(a2: ptr str; pos: int32; a4: cstring): int32 {.importc: "nk_str_insert_str_utf8".}
proc insertStrUTF8*(s: var str, pos: int32, t: string): int32 =
  str_insert_str_utf8(addr s, pos, t)

proc str_insert_text_runes(a2: ptr str; pos: int32; a4: ptr uint32; a5: int32): int32 {. importc: "nk_str_insert_text_runes".}
proc insertTextRunes*(s: var str, pos: int32, u: var uint32, i: int32): int32 =
  str_insert_text_runes(addr s, pos, addr u, i)

proc str_insert_str_runes(a2: ptr str; pos: int32; a4: ptr uint32): int32 {.importc: "nk_str_insert_str_runes".}
proc insertStrRunes*(s: var str, pos: int32, u: var uint32): int32 =
  str_insert_str_runes(addr s, pos, addr u)

proc str_remove_chars(a2: ptr str; len: int32) {.importc: "nk_str_remove_chars".}
proc removeChars*(s: var str, len: int32) =
  str_remove_chars(addr s, len)

proc str_remove_runes(str: ptr str; len: int32) {.importc: "nk_str_remove_runes".}
proc removeRunes*(s: var str, len: int32) =
  str_remove_runes(addr s, len)

proc str_delete_chars(a2: ptr str; pos: int32; len: int32) {.importc: "nk_str_delete_chars".}
proc deleteChars*(s: var str, pos: int32, len: int32) =
  str_delete_chars(addr s, pos, len)

proc str_delete_runes(a2: ptr str; pos: int32; len: int32) {.importc: "nk_str_delete_runes".}
proc deleteRunes*(s: var str, pos: int32, len: int32) =
  str_delete_runes(addr s, pos, len)

proc str_at_char(a2: ptr str; pos: int32): cstring {.importc: "nk_str_at_char".}
proc atChar*(s: var str, pos: int32) : string =
  $str_at_char(addr s, pos)

proc str_at_rune(a2: ptr str; pos: int32; unicode: ptr uint32; len: ptr int32): cstring {. importc: "nk_str_at_rune".}
proc atRune*(s: var str, pos: int32, unicode: var uint32, len: var int32) : string =
  $str_at_rune(addr s, pos, addr unicode, addr len)

proc str_rune_at(a2: ptr str; pos: int32): uint32 {.importc: "nk_str_rune_at".}
proc runeAt*(s: var str, pos: int32): uint32 =
  str_rune_at(addr s, pos)

proc str_at_char_const(a2: ptr str; pos: int32): cstring {.importc: "nk_str_at_char_const".}
proc atCharConst*(s: var str, pos: int32): string =
  $str_at_char_const(addr s, pos)

proc str_at_const(a2: ptr str; pos: int32; unicode: ptr uint32; len: ptr int32): cstring {. importc: "nk_str_at_const".}
proc atConst*(s: var str, pos: int32, unicode: var uint32, len: var int32): string =
  $str_at_const(addr s, pos, addr unicode, addr len)

proc str_get(a2: ptr str): cstring {.importc: "nk_str_get".}
proc get*(s: var str): string =
  $str_get(addr s)

proc str_get_const(a2: ptr str): cstring {.importc: "nk_str_get_const".}
proc getConst*(s: var str): string =
  $str_get_const(addr s)

proc str_len(a2: ptr str): int32 {.importc: "nk_str_len".}
proc len*(s: var str): int32 =
  str_len(addr s)

proc str_len_char(a2: ptr str): int32 {.importc: "nk_str_len_char".}
proc lenChar*(s: var str): int32 =
  str_len_char(addr s)

type
  command_buffer* = object
    base*: ptr buffer
    clip*: rect
    use_clipping*: int32
    userdata*: handle
    begin*: uint
    e*: uint
    last*: uint

type
  panel_type* {.size: sizeof(int32).} = enum
    PANEL_WINDOW = (1 shl (0)), PANEL_GROUP = (1 shl (1)),
    PANEL_POPUP = (1 shl (2)), PANEL_CONTEXTUAL = (1 shl (4)),
    PANEL_COMBO = (1 shl (5)), PANEL_MENU = (1 shl (6)),
    PANEL_TOOLTIP = (1 shl (7))

type
  chart_type* {.size: sizeof(int32).} = enum
    charT_LINES, charT_COLUMN, charT_MAX

type
  style_item_type* {.size: sizeof(int32).} = enum
    STYLE_ITEM_COLOR, STYLE_ITEM_IMAGE

type
  button_behavior* {.size: sizeof(int32).} = enum
    BUTTON_DEFAULT, BUTTON_REPEATER

type
  buttons* {.size: sizeof(int32).} = enum
    BUTTON_LEFT, BUTTON_MIDDLE, BUTTON_RIGHT, BUTTON_MAX

type
  keys* {.size: sizeof(int32).} = enum
    KEY_NONE, KEY_SHIFT, KEY_CTRL, KEY_DEL, KEY_ENTER, KEY_TAB,
    KEY_BACKSPACE, KEY_COPY, KEY_CUT, KEY_PASTE, KEY_UP, KEY_DOWN,
    KEY_LEFT, KEY_RIGHT, KEY_TEXT_INSERT_MODE, KEY_TEXT_REPLACE_MODE,
    KEY_TEXT_RESET_MODE, KEY_TEXT_LINE_START, KEY_TEXT_LINE_END,
    KEY_TEXT_START, KEY_TEXT_END, KEY_TEXT_UNDO, KEY_TEXT_REDO,
    KEY_TEXT_SELECT_ALL, KEY_TEXT_WORD_LEFT, KEY_TEXT_WORD_RIGHT,
    KEY_SCROLL_START, KEY_SCROLL_END, KEY_SCROLL_DOWN, KEY_SCROLL_UP,
    KEY_MAX

type
  style_cursor* {.size: sizeof(int32).} = enum
    CURSOR_ARROW, CURSOR_TEXT, CURSOR_MOVE, CURSOR_RESIZE_VERTICAL,
    CURSOR_RESIZE_HORIZONTAL, CURSOR_RESIZE_TOP_LEFT_DOWN_RIGHT,
    CURSOR_RESIZE_TOP_RIGHT_DOWN_LEFT, CURSOR_COUNT

type
  draw_vertex_layout_attribute* {.size: sizeof(int32).} = enum
    VERTEX_POSITION, VERTEX_COLOR, VERTEX_TEXCOORD,
    VERTEX_ATTRIBUTE_COUNT

type
  draw_vertex_layout_format* {.size: sizeof(int32).} = enum
    FORMAT_SCHAR, FORMAT_SSHORT, FORMAT_SINT, FORMAT_UCHAR,
    FORMAT_USHORT, FORMAT_UINT, FORMAT_FLOAT, FORMAT_DOUBLE,
    FORMAT_COLOR_BEGIN, FORMAT_R16G15B16, FORMAT_R32G32B32,
    FORMAT_R8G8B8A8, FORMAT_R16G15B16A16, FORMAT_R32G32B32A32,
    FORMAT_R32G32B32A32_FLOAT, FORMAT_R32G32B32A32_DOUBLE, FORMAT_RGB32,
    FORMAT_RGBA32, FORMAT_COUNT

type
  draw_vertex_layout_element* = object
    attribute*: draw_vertex_layout_attribute
    format*: draw_vertex_layout_format
    offset*: uint

  draw_command* = object
    elem_count*: cuint
    clip_rect*: rect
    texture*: handle

  draw_list* = object
    clip_rect*: rect
    circle_vtx*: array[12, vec2]
    config*: convert_config
    buffer*: ptr buffer
    vertices*: ptr buffer
    elements*: ptr buffer
    element_count*: cuint
    vertex_count*: cuint
    cmd_count*: cuint
    cmd_offset*: uint
    path_count*: cuint
    path_offset*: cuint

  draw_null_texture* = object
    texture*: handle
    uv*: vec2

  convert_config* = object
    global_alpha*: float32
    line_AA*: anti_aliasing
    shape_AA*: anti_aliasing
    circle_segment_count*: cuint
    arc_segment_count*: cuint
    curve_segment_count*: cuint
    null*: draw_null_texture
    vertex_layout*: ptr draw_vertex_layout_element
    vertex_size*: uint
    vertex_alignment*: uint

  list_view* = object
    begin*: int32
    e*: int32
    count*: int32
    total_height*: int32
    ctx*: ptr context
    scroll_pointer*: ptr uint32
    scroll_value*: uint32

  symbol_type* {.size: sizeof(int32).} = enum
    SYMBOL_NONE, SYMBOL_X, SYMBOL_UNDERSCORE, SYMBOL_CIRCLE_SOLID,
    SYMBOL_CIRCLE_OUTLINE, SYMBOL_RECT_SOLID, SYMBOL_RECT_OUTLINE,
    SYMBOL_TRIANGLE_UP, SYMBOL_TRIANGLE_DOWN, SYMBOL_TRIANGLE_LEFT,
    SYMBOL_TRIANGLE_RIGHT, SYMBOL_PLUS, SYMBOL_MINUS, SYMBOL_MAX

  menu_state* = object
    x*: float32
    y*: float32
    w*: float32
    h*: float32
    offset*: scroll

  row_layout* = object
    typ*: panel_row_layout_type
    index*: int32
    height*: float32
    columns*: int32
    ratio*: ptr float32
    item_width*: float32
    item_height*: float32
    item_offset*: float32
    filled*: float32
    item*: rect
    tree_depth*: int32
    templates*: array[16, float32]

  popup_buffer* = object
    begin*: uint
    parent*: uint
    last*: uint
    e*: uint
    active*: int32

  chart_slot* = object
    typ*: chart_type
    color*: color
    highlight*: color
    min*: float32
    max*: float32
    range*: float32
    count*: int32
    last*: vec2
    index*: int32

  chart* = object
    slot*: int32
    x*: float32
    y*: float32
    w*: float32
    h*: float32
    slots*: array[4, chart_slot]

  panel_row_layout_type* {.size: sizeof(int32).} = enum
    LAYOUT_DYNAMIC_FIXED = 0, LAYOUT_DYNAMIC_ROW, LAYOUT_DYNAMIC_FREE,
    LAYOUT_DYNAMIC, LAYOUT_STATIC_FIXED, LAYOUT_STATIC_ROW,
    LAYOUT_STATIC_FREE, LAYOUT_STATIC, LAYOUT_TEMPLATE, LAYOUT_COUNT

  panel* = object
    typ*: panel_type
    flags*: uint32
    bounds*: rect
    offset_x*: ptr uint32
    offset_y*: ptr uint32
    at_x*: float32
    at_y*: float32
    max_x*: float32
    footer_height*: float32
    header_height*: float32
    border*: float32
    has_scrolling*: cuint
    clip*: rect
    menu*: menu_state
    row*: row_layout
    chart*: chart
    popup_buffer*: popup_buffer
    buffer*: ptr command_buffer
    parent*: ptr panel

  window* = object
    s*: cuint
    name*: uint32
    name_string*: array[64, char]
    flags*: uint32
    bounds*: rect
    scrollbar*: scroll
    buffer*: command_buffer
    layout*: ptr panel
    scrollbar_hiding_timer*: float32
    property*: property_state
    popup*: popup_state
    edit*: edit_state
    scrolled*: cuint
    tables*: ptr table
    table_count*: uint16
    table_size*: uint16
    next*: ptr window
    prev*: ptr window
    parent*: ptr window

  popup_state* = object
    win*: ptr window
    typ*: panel_type
    name*: uint32
    active*: int32
    combo_count*: cuint
    con_count*: cuint
    con_old*: cuint
    active_con*: cuint
    header*: rect

  edit_state* = object
    name*: uint32
    s*: cuint
    old*: cuint
    active*: int32
    prev*: int32
    cursor*: int32
    sel_start*: int32
    sel_end*: int32
    scrollbar*: scroll
    mode*: cuchar
    single_line*: cuchar

  property_state* = object
    active*: int32
    prev*: int32
    buffer*: array[64, char]
    length*: int32
    cursor*: int32
    name*: uint32
    s*: cuint
    old*: cuint
    state*: int32

  style_item_data* = object {.union.}
    image*: img
    color*: color

  style_item* = object
    typ*: style_item_type
    data*: style_item_data

  config_stack_style_item_element* = object
    address*: ptr style_item
    old_value*: style_item

  config_stack_float_element* = object
    address*: ptr float32
    old_value*: float32

  config_stack_vec2_element* = object
    address*: ptr vec2
    old_value*: vec2

  config_stack_flags_element* = object
    address*: ptr uint32
    old_value*: uint32

  config_stack_color_element* = object
    address*: ptr color
    old_value*: color

  config_stack_user_font_element* = object
    address*: ptr ptr user_font
    old_value*: ptr user_font

  config_stack_button_behavior_element* = object
    address*: ptr button_behavior
    old_value*: button_behavior

  config_stack_style_item* = object
    head*: int32
    elements*: array[16, config_stack_style_item_element]

  config_stack_float* = object
    head*: int32
    elements*: array[32, config_stack_float_element]

  config_stack_vec2* = object
    head*: int32
    elements*: array[16, config_stack_vec2_element]

  config_stack_flags* = object
    head*: int32
    elements*: array[32, config_stack_flags_element]

  config_stack_color* = object
    head*: int32
    elements*: array[32, config_stack_color_element]

  config_stack_user_font* = object
    head*: int32
    elements*: array[8, config_stack_user_font_element]

  config_stack_button_behavior* = object
    head*: int32
    elements*: array[8, config_stack_button_behavior_element]

  configuration_stacks* = object
    style_items*: config_stack_style_item
    floats*: config_stack_float
    vectors*: config_stack_vec2
    flags*: config_stack_flags
    colors*: config_stack_color
    fonts*: config_stack_user_font
    button_behaviors*: config_stack_button_behavior

  table* = object
    s*: cuint
    keys: array[find_size(window, panel), uint32]
    values: array[find_size(window, panel), uint32]
    next*: ptr table
    prev*: ptr table

  page_data* = object {.union.}
    tbl*: table
    pan*: panel
    win*: window

  page_element* = object
    data*: page_data
    next*: ptr page_element
    prev*: ptr page_element

  page* = object
    size*: cuint
    next*: ptr page
    win*: array[1, page_element]

  pool* = object
    alloc*: allocator
    typ*: allocation_type
    page_count*: cuint
    pages*: ptr page
    freelist*: ptr page_element
    capacity*: cuint
    size*: uint
    cap*: uint

  mouse_button* = object
    down*: int32
    clicked*: cuint
    clicked_pos*: vec2

  mouse* = object
    buttons*: array[BUTTON_MAX, mouse_button]
    pos*: vec2
    prev*: vec2
    delta*: vec2
    scroll_delta*: float32
    grab*: cuchar
    grabbed*: cuchar
    ungrab*: cuchar

  key* = object
    down*: int32
    clicked*: cuint

  keyboard* = object
    keys*: array[KEY_MAX, key]
    text*: array[16, char]
    text_len*: int32

  input* = object
    keyboard*: keyboard
    mouse*: mouse

  context* = object
    input*: input
    style*: style
    memory*: buffer
    clip*: clipboard
    last_widget_state*: uint32
    button_behavior*: button_behavior
    stacks*: configuration_stacks
    delta_time_seconds*: float32
    draw_list*: draw_list
    text_edit*: text_edit
    overlay*: command_buffer
    build*: int32
    use_pool*: int32
    pool*: pool
    begin*: ptr window
    e*: ptr window
    active*: ptr window
    current*: ptr window
    freelist*: ptr page_element
    count*: cuint
    s*: cuint

  plugin_paste* = proc (a2: handle; a3: ptr text_edit) {.cdecl.}
  plugin_copy* = proc (a2: handle; a3: cstring; len: int32) {.cdecl.}
  
  clipboard* = object
    userdata*: handle
    paste*: plugin_paste
    copy*: plugin_copy
    
  text_edit* = object
    clip*: clipboard
    str*: str
    filter*: plugin_filter
    scrollbar*: vec2
    cursor*: int32
    select_start*: int32
    select_end*: int32
    mode*: cuchar
    cursor_at_end_of_line*: cuchar
    initialized*: cuchar
    has_preferred_x*: cuchar
    single_line*: cuchar
    active*: cuchar
    padding1*: cuchar
    preferred_x*: float32
    undo*: text_undo_state

  plugin_filter = proc (a2: ptr text_edit; unicode: uint32): int32 {.cdecl.}
  InputFilter* = proc(te: var text_edit, unicode: uint32): int32 {.closure, cdecl.}


  text_undo_record* = object
    where*: int32
    insert_length*: int16
    delete_length*: int16
    char_storage*: int16

  text_undo_state* = object
    undo_rec*: array[99, text_undo_record]
    undo_char*: array[999, uint32]
    undo_point*: int16
    redo_point*: int16
    undo_char_point*: int16
    redo_char_point*: int16

  text_edit_type* {.size: sizeof(int32).} = enum
    TEXT_EDIT_SINGLE_LINE, TEXT_EDIT_MULTI_LINE

  style_text* = object
    color*: color
    padding*: vec2

  style_button* = object
    normal*: style_item
    hover*: style_item
    active*: style_item
    border_color*: color
    text_background*: color
    text_normal*: color
    text_hover*: color
    text_active*: color
    text_alignment*: uint32
    border*: float32
    rounding*: float32
    padding*: vec2
    image_padding*: vec2
    touch_padding*: vec2
    userdata*: handle
    draw_begin*: proc (a2: ptr command_buffer; userdata: handle) {.cdecl.}
    draw_end*: proc (a2: ptr command_buffer; userdata: handle) {.cdecl.}

  style_toggle* = object
    normal*: style_item
    hover*: style_item
    active*: style_item
    border_color*: color
    cursor_normal*: style_item
    cursor_hover*: style_item
    text_normal*: color
    text_hover*: color
    text_active*: color
    text_background*: color
    text_alignment*: uint32
    padding*: vec2
    touch_padding*: vec2
    spacing*: float32
    border*: float32
    userdata*: handle
    draw_begin*: proc (a2: ptr command_buffer; a3: handle) {.cdecl.}
    draw_end*: proc (a2: ptr command_buffer; a3: handle) {.cdecl.}

  style_selectable* = object
    normal*: style_item
    hover*: style_item
    pressed*: style_item
    normal_active*: style_item
    hover_active*: style_item
    pressed_active*: style_item
    text_normal*: color
    text_hover*: color
    text_pressed*: color
    text_normal_active*: color
    text_hover_active*: color
    text_pressed_active*: color
    text_background*: color
    text_alignment*: uint32
    rounding*: float32
    padding*: vec2
    touch_padding*: vec2
    image_padding*: vec2
    userdata*: handle
    draw_begin*: proc (a2: ptr command_buffer; a3: handle) {.cdecl.}
    draw_end*: proc (a2: ptr command_buffer; a3: handle) {.cdecl.}

  style_slider* = object
    normal*: style_item
    hover*: style_item
    active*: style_item
    border_color*: color
    bar_normal*: color
    bar_hover*: color
    bar_active*: color
    bar_filled*: color
    cursor_normal*: style_item
    cursor_hover*: style_item
    cursor_active*: style_item
    border*: float32
    rounding*: float32
    bar_height*: float32
    padding*: vec2
    spacing*: vec2
    cursor_size*: vec2
    show_buttons*: int32
    inc_button*: style_button
    dec_button*: style_button
    inc_symbol*: symbol_type
    dec_symbol*: symbol_type
    userdata*: handle
    draw_begin*: proc (a2: ptr command_buffer; a3: handle) {.cdecl.}
    draw_end*: proc (a2: ptr command_buffer; a3: handle) {.cdecl.}

  style_progress* = object
    normal*: style_item
    hover*: style_item
    active*: style_item
    border_color*: color
    cursor_normal*: style_item
    cursor_hover*: style_item
    cursor_active*: style_item
    cursor_border_color*: color
    rounding*: float32
    border*: float32
    cursor_border*: float32
    cursor_rounding*: float32
    padding*: vec2
    userdata*: handle
    draw_begin*: proc (a2: ptr command_buffer; a3: handle) {.cdecl.}
    draw_end*: proc (a2: ptr command_buffer; a3: handle) {.cdecl.}

  style_scrollbar* = object
    normal*: style_item
    hover*: style_item
    active*: style_item
    border_color*: color
    cursor_normal*: style_item
    cursor_hover*: style_item
    cursor_active*: style_item
    cursor_border_color*: color
    border*: float32
    rounding*: float32
    border_cursor*: float32
    rounding_cursor*: float32
    padding*: vec2
    show_buttons*: int32
    inc_button*: style_button
    dec_button*: style_button
    inc_symbol*: symbol_type
    dec_symbol*: symbol_type
    userdata*: handle
    draw_begin*: proc (a2: ptr command_buffer; a3: handle) {.cdecl.}
    draw_end*: proc (a2: ptr command_buffer; a3: handle) {.cdecl.}

  style_edit* = object
    normal*: style_item
    hover*: style_item
    active*: style_item
    border_color*: color
    scrollbar*: style_scrollbar
    cursor_normal*: color
    cursor_hover*: color
    cursor_text_normal*: color
    cursor_text_hover*: color
    text_normal*: color
    text_hover*: color
    text_active*: color
    selected_normal*: color
    selected_hover*: color
    selected_text_normal*: color
    selected_text_hover*: color
    border*: float32
    rounding*: float32
    cursor_size*: float32
    scrollbar_size*: vec2
    padding*: vec2
    row_padding*: float32

  style_property* = object
    normal*: style_item
    hover*: style_item
    active*: style_item
    border_color*: color
    label_normal*: color
    label_hover*: color
    label_active*: color
    sym_left*: symbol_type
    sym_right*: symbol_type
    border*: float32
    rounding*: float32
    padding*: vec2
    edit*: style_edit
    inc_button*: style_button
    dec_button*: style_button
    userdata*: handle
    draw_begin*: proc (a2: ptr command_buffer; a3: handle) {.cdecl.}
    draw_end*: proc (a2: ptr command_buffer; a3: handle) {.cdecl.}

  style_chart* = object
    background*: style_item
    border_color*: color
    selected_color*: color
    color*: color
    border*: float32
    rounding*: float32
    padding*: vec2

  style_combo* = object
    normal*: style_item
    hover*: style_item
    active*: style_item
    border_color*: color
    label_normal*: color
    label_hover*: color
    label_active*: color
    symbol_normal*: color
    symbol_hover*: color
    symbol_active*: color
    button*: style_button
    sym_normal*: symbol_type
    sym_hover*: symbol_type
    sym_active*: symbol_type
    border*: float32
    rounding*: float32
    content_padding*: vec2
    button_padding*: vec2
    spacing*: vec2

  style_tab* = object
    background*: style_item
    border_color*: color
    text*: color
    tab_maximize_button*: style_button
    tab_minimize_button*: style_button
    node_maximize_button*: style_button
    node_minimize_button*: style_button
    sym_minimize*: symbol_type
    sym_maximize*: symbol_type
    border*: float32
    rounding*: float32
    indent*: float32
    padding*: vec2
    spacing*: vec2

  style_header_align* {.size: sizeof(int32).} = enum
    HEADER_LEFT, HEADER_RIGHT

  style_window_header* = object
    normal*: style_item
    hover*: style_item
    active*: style_item
    close_button*: style_button
    minimize_button*: style_button
    close_symbol*: symbol_type
    minimize_symbol*: symbol_type
    maximize_symbol*: symbol_type
    label_normal*: color
    label_hover*: color
    label_active*: color
    align*: style_header_align
    padding*: vec2
    label_padding*: vec2
    spacing*: vec2

  style_window* = object
    header*: style_window_header
    fixed_background*: style_item
    background*: color
    border_color*: color
    popup_border_color*: color
    combo_border_color*: color
    contextual_border_color*: color
    menu_border_color*: color
    group_border_color*: color
    tooltip_border_color*: color
    scaler*: style_item
    border*: float32
    combo_border*: float32
    contextual_border*: float32
    menu_border*: float32
    group_border*: float32
    tooltip_border*: float32
    popup_border*: float32
    rounding*: float32
    spacing*: vec2
    scrollbar_size*: vec2
    min_size*: vec2
    padding*: vec2
    group_padding*: vec2
    popup_padding*: vec2
    combo_padding*: vec2
    contextual_padding*: vec2
    menu_padding*: vec2
    tooltip_padding*: vec2

  style* = object
    font*: ptr user_font
    cursors*: array[CURSOR_COUNT, ptr cursor]
    cursor_active*: ptr cursor
    cursor_last*: ptr cursor
    cursor_visible*: int32
    text*: style_text
    button*: style_button
    contextual_button*: style_button
    menu_button*: style_button
    option*: style_toggle
    checkbox*: style_toggle
    selectable*: style_selectable
    slider*: style_slider
    progress*: style_progress
    property*: style_property
    edit*: style_edit
    chart*: style_chart
    scrollh*: style_scrollbar
    scrollv*: style_scrollbar
    tab*: style_tab
    combo*: style_combo
    window*: style_window

type
  modify* {.size: sizeof(int32).} = enum
    FIXED = false, MODIFIABLE = true


type
  orientation* {.size: sizeof(int32).} = enum
    VERTICAL, HORIZONTAL


type
  collapse_states* {.size: sizeof(int32).} = enum
    MINIMIZED = false, MAXIMIZED = true


type
  show_states* {.size: sizeof(int32).} = enum
    HIDDEN = false, SHOWN = true


type
  chart_event* {.size: sizeof(int32).} = enum
    charT_HOVERING = 0x00000001, charT_CLICKED = 0x00000002


type
  color_format* {.size: sizeof(int32).} = enum
    RGB, RGBA


type
  popup_type* {.size: sizeof(int32).} = enum
    POPUP_STATIC, POPUP_DYNAMIC


type
  layout_format* {.size: sizeof(int32).} = enum
    DYNAMIC, STATIC


type
  tree_type* {.size: sizeof(int32).} = enum
    TREE_NODE, TREE_TAB


type
  style_colors* {.size: sizeof(int32).} = enum
    COLOR_TEXT, COLOR_WINDOW, COLOR_HEADER, COLOR_BORDER,
    COLOR_BUTTON, COLOR_BUTTON_HOVER, COLOR_BUTTON_ACTIVE,
    COLOR_TOGGLE, COLOR_TOGGLE_HOVER, COLOR_TOGGLE_CURSOR,
    COLOR_SELECT, COLOR_SELECT_ACTIVE, COLOR_SLIDER,
    COLOR_SLIDER_CURSOR, COLOR_SLIDER_CURSOR_HOVER,
    COLOR_SLIDER_CURSOR_ACTIVE, COLOR_PROPERTY, COLOR_EDIT,
    COLOR_EDIT_CURSOR, COLOR_COMBO, COLOR_CHART, COLOR_CHART_COLOR,
    COLOR_CHART_COLOR_HIGHLIGHT, COLOR_SCROLLBAR, COLOR_SCROLLBAR_CURSOR,
    COLOR_SCROLLBAR_CURSOR_HOVER, COLOR_SCROLLBAR_CURSOR_ACTIVE,
    COLOR_TAB_HEADER, COLOR_COUNT


type
  widget_layout_states* {.size: sizeof(int32).} = enum
    WIDGET_INVALID, WIDGET_VALID, WIDGET_ROM


type
  widget_states* {.size: sizeof(int32).} = enum
    WIDGET_STATE_MODIFIED = (1 shl (1)), WIDGET_STATE_INACTIVE = (1 shl (2)),
    WIDGET_STATE_ENTERED = (1 shl (3)), WIDGET_STATE_HOVER = (1 shl (4)),
    WIDGET_STATE_ACTIVED = (1 shl (5)), WIDGET_STATE_LEFT = (1 shl (6))
    
const WIDGET_STATE_HOVERED = widget_states(WIDGET_STATE_HOVER.int32 or WIDGET_STATE_MODIFIED.int32) 
const WIDGET_STATE_ACTIVE = widget_states(WIDGET_STATE_ACTIVED.int32 or WIDGET_STATE_MODIFIED.int32)


type
  text_align* {.size: sizeof(int32).} = enum
    TEXT_ALIGN_LEFT = 0x00000001, TEXT_ALIGN_CENTERED = 0x00000002,
    TEXT_ALIGN_RIGHT = 0x00000004, TEXT_ALIGN_TOP = 0x00000008,
    TEXT_ALIGN_MIDDLE = 0x00000010, TEXT_ALIGN_BOTTOM = 0x00000020


type
  text_alignment* {.size: sizeof(int32).} = enum
    TEXT_LEFT = TEXT_ALIGN_MIDDLE.int32 or TEXT_ALIGN_LEFT.int32,
    TEXT_CENTERED = TEXT_ALIGN_MIDDLE.int32 or TEXT_ALIGN_CENTERED.int32,
    TEXT_RIGHT = TEXT_ALIGN_MIDDLE.int32 or TEXT_ALIGN_RIGHT.int32


type
  edit_flags* {.size: sizeof(int32).} = enum
    EDIT_DEFAULT = 0, EDIT_READ_ONLY = (1 shl (0)),
    EDIT_AUTO_SELECT = (1 shl (1)), EDIT_SIG_ENTER = (1 shl (2)),
    EDIT_ALLOW_TAB = (1 shl (3)), EDIT_NO_CURSOR = (1 shl (4)),
    EDIT_SELECTABLE = (1 shl (5)), EDIT_CLIPBOARD = (1 shl (6)),
    EDIT_CTRL_ENTER_NEWLINE = (1 shl (7)),
    EDIT_NO_HORIZONTAL_SCROLL = (1 shl (8)),
    EDIT_ALWAYS_INSERT_MODE = (1 shl (9)), EDIT_MULTILINE = (1 shl (11)),
    EDIT_GOTO_END_ON_ACTIVATE = (1 shl (12))


type
  edit_types* {.size: sizeof(int32).} = enum
    EDIT_SIMPLE = EDIT_ALWAYS_INSERT_MODE,
    EDIT_FIELD = EDIT_SIMPLE.int32 or EDIT_SELECTABLE.int32 or EDIT_CLIPBOARD.int32,  
    EDIT_EDITOR = EDIT_SELECTABLE.int32 or EDIT_MULTILINE.int32 or EDIT_ALLOW_TAB.int32 or EDIT_CLIPBOARD.int32,
    EDIT_BOX = EDIT_ALWAYS_INSERT_MODE.int32 or EDIT_SELECTABLE.int32 or EDIT_MULTILINE.int32 or EDIT_ALLOW_TAB.int32 or EDIT_CLIPBOARD.int32


type
  edit_events* {.size: sizeof(int32).} = enum
    EDIT_ACTIVE = (1 shl (0)), EDIT_INACTIVE = (1 shl (1)),
    EDIT_ACTIVATED = (1 shl (2)), EDIT_DEACTIVATED = (1 shl (3)),
    EDIT_COMMITED = (1 shl (4))


type
  panel_flags* {.size: sizeof(int32).} = enum
    WINDOW_BORDER = (1 shl (0)), WINDOW_MOVABLE = (1 shl (1)),
    WINDOW_SCALABLE = (1 shl (2)), WINDOW_CLOSABLE = (1 shl (3)),
    WINDOW_MINIMIZABLE = (1 shl (4)), WINDOW_NO_SCROLLBAR = (1 shl (5)),
    WINDOW_TITLE = (1 shl (6)), WINDOW_SCROLL_AUTO_HIDE = (1 shl (7)),
    WINDOW_BACKGROUND = (1 shl (8)), WINDOW_SCALE_LEFT = (1 shl (9))


type
  text_edit_mode* {.size: sizeof(int32).} = enum
    TEXT_EDIT_MODE_VIEW, TEXT_EDIT_MODE_INSERT, TEXT_EDIT_MODE_REPLACE


proc filter_default(a2: ptr text_edit; unicode: uint32): int32 {.importc: "nk_filter_default", cdecl.}
var defaultFilter* : InputFilter = proc(te: var text_edit, unicode: uint32): int32 {.closure, cdecl.} =
  filter_default(addr te, unicode)

proc filter_ascii(a2: ptr text_edit; unicode: uint32): int32 {.importc: "nk_filter_ascii".}
var asciiFilter* : InputFilter = proc(te: var text_edit, unicode: uint32): int32 {.closure, cdecl.} =
  filter_ascii(addr te, unicode)

proc filter_float(a2: ptr text_edit; unicode: uint32): int32 {.importc: "nk_filter_float".}
var floatFilter*: InputFilter = proc(te: var text_edit, unicode: uint32): int32 {.closure, cdecl.} =
  filter_float(addr te, unicode)

proc filter_decimal(a2: ptr text_edit; unicode: uint32): int32 {.importc: "nk_filter_decimal".}
var decimalFilter*: InputFilter = proc(te: var text_edit, unicode: uint32): int32 {.closure, cdecl.} =
  filter_decimal(addr te, unicode)

proc filter_hex(a2: ptr text_edit; unicode: uint32): int32 {.importc: "nk_filter_hex".}
var hexFilter*: InputFilter = proc(te: var text_edit, unicode: uint32): int32 {.closure, cdecl.} =
  filter_hex(addr te, unicode)

proc filter_oct(a2: ptr text_edit; unicode: uint32): int32 {.importc: "nk_filter_oct".}
var octFilter*: InputFilter = proc(te: var text_edit, unicode: uint32): int32 {.closure, cdecl.} =
  filter_oct(addr te, unicode)

proc filter_binary(a2: ptr text_edit; unicode: uint32): int32 {.importc: "nk_filter_binary".}
var binaryFilter*: InputFilter = proc(te: var text_edit, unicode: uint32): int32 {.closure, cdecl.} =
  filter_binary(addr te, unicode)

proc textedit_init(a2: ptr text_edit; a3: ptr allocator; size: uint) {. importc: "nk_textedit_init".}
proc init*(te: var text_edit, a: var allocator, size: uint) =
  textedit_init(addr te, addr a, size)

proc textedit_init_fixed(a2: ptr text_edit; memory: pointer; size: uint) {. importc: "nk_textedit_init_fixed".}
proc initFixed*(te: var text_edit, memory: pointer, size: uint) =
  textedit_init_fixed(addr te, memory, size)

proc textedit_free(a2: ptr text_edit) {.importc: "nk_textedit_free".}
proc free*(te: var text_edit) =
  textedit_free(addr te)

proc textedit_text(a2: ptr text_edit; a3: cstring; total_len: int32) {.importc: "nk_textedit_text".}
proc text*(te: var text_edit, t: string, totalLen: int32) =
  textedit_text(addr te, t, totalLen)

proc textedit_delete(a2: ptr text_edit; where: int32; len: int32) {.importc: "nk_textedit_delete".}
proc delete*(te: var text_edit, where: int32, len: int32) =
  textedit_delete(addr te, where, len)

proc textedit_delete_selection*(a2: ptr text_edit) {.importc: "nk_textedit_delete_selection".}
proc deleteSelection*(te: var text_edit) =
  textedit_delete_selection(addr te)

proc textedit_select_all(a2: ptr text_edit) {.importc: "nk_textedit_select_all".}
proc selectAll*(te: var text_edit) =
  textedit_select_all(addr te)

proc textedit_cut(a2: ptr text_edit): int32 {.importc: "nk_textedit_cut".}
proc cut*(te: var text_edit): int32 =
  textedit_cut(addr te)

proc textedit_paste(a2: ptr text_edit; a3: cstring; len: int32): int32 {.importc: "nk_textedit_paste".}
proc paste*(te: var text_edit, text: string, len: int32): int32 =
  textedit_paste(addr te, text, len)

proc textedit_undo*(a2: ptr text_edit) {.importc: "nk_textedit_undo".}
proc undo*(te: var text_edit) =
  textedit_undo(addr te)

proc textedit_redo(a2: ptr text_edit) {.importc: "nk_textedit_redo".}
proc redo*(te: var text_edit) =
  textedit_redo(addr te)

type
  command_type* {.size: sizeof(int32).} = enum
    COMMAND_NOP, COMMAND_SCISSOR, COMMAND_LINE, COMMAND_CURVE,
    COMMAND_RECT, COMMAND_RECT_FILLED, COMMAND_RECT_MULTI_COLOR,
    COMMAND_CIRCLE, COMMAND_CIRCLE_FILLED, COMMAND_ARC,
    COMMAND_ARC_FILLED, COMMAND_TRIANGLE, COMMAND_TRIANGLE_FILLED,
    COMMAND_POLYGON, COMMAND_POLYGON_FILLED, COMMAND_POLYLINE,
    COMMAND_TEXT, COMMAND_IMAGE


type
  command* = object
    typ*: command_type
    next*: uint

  command_scissor* = object
    header*: command
    x*: int16
    y*: int16
    w*: uint16
    h*: uint16

  command_line* = object
    header*: command
    line_thickness*: uint16
    begin*: vec2i
    e*: vec2i
    color*: color

  command_curve* = object
    header*: command
    line_thickness*: uint16
    begin*: vec2i
    e*: vec2i
    ctrl*: array[2, vec2i]
    color*: color

  command_rect* = object
    header*: command
    rounding*: uint16
    line_thickness*: uint16
    x*: int16
    y*: int16
    w*: uint16
    h*: uint16
    color*: color

  command_rect_filled* = object
    header*: command
    rounding*: uint16
    x*: int16
    y*: int16
    w*: uint16
    h*: uint16
    color*: color

  command_rect_multi_color* = object
    header*: command
    x*: int16
    y*: int16
    w*: uint16
    h*: uint16
    left*: color
    top*: color
    bottom*: color
    right*: color

  command_triangle* = object
    header*: command
    line_thickness*: uint16
    a*: vec2i
    b*: vec2i
    c*: vec2i
    color*: color

  command_triangle_filled* = object
    header*: command
    a*: vec2i
    b*: vec2i
    c*: vec2i
    color*: color

  command_circle* = object
    header*: command
    x*: int16
    y*: int16
    line_thickness*: uint16
    w*: uint16
    h*: uint16
    color*: color

  command_circle_filled* = object
    header*: command
    x*: int16
    y*: int16
    w*: uint16
    h*: uint16
    color*: color

  command_arc* = object
    header*: command
    cx*: int16
    cy*: int16
    r*: uint16
    line_thickness*: uint16
    a*: array[2, float32]
    color*: color

  command_arc_filled* = object
    header*: command
    cx*: int16
    cy*: int16
    r*: uint16
    a*: array[2, float32]
    color*: color

  command_polygon* = object
    header*: command
    color*: color
    line_thickness*: uint16
    point_count*: uint16
    points*: array[1, vec2i]

  command_polygon_filled* = object
    header*: command
    color*: color
    point_count*: uint16
    points*: array[1, vec2i]

  command_polyline* = object
    header*: command
    color*: color
    line_thickness*: uint16
    point_count*: uint16
    points*: array[1, vec2i]

  command_image* = object
    header*: command
    x*: int16
    y*: int16
    w*: uint16
    h*: uint16
    img*: img
    col*: color

  command_text* = object
    header*: command
    font*: ptr user_font
    background*: color
    foreground*: color
    x*: int16
    y*: int16
    w*: uint16
    h*: uint16
    height*: float32
    length*: int32
    string*: array[1, char]

  command_clipping* {.size: sizeof(int32).} = enum
    CLIPPING_OFF = nk_false, CLIPPING_ON = nk_true


proc stroke_line(b: ptr command_buffer; x0: float32; y0: float32; x1: float32;
                    y1: float32; line_thickness: float32; a8: color) {.importc: "nk_stroke_line".}
proc strokeLine*(cmdBuf: var command_buffer, x0, y0, x1, y1, lineThickness: float32, col: color) =
  stroke_line(addr cmdBuf, x0, y0, x1, y1, lineThickness, col)

proc stroke_curve(a2: ptr command_buffer; a3: float32; a4: float32; a5: float32;
                     a6: float32; a7: float32; a8: float32; a9: float32; a10: float32;
                     line_thickness: float32; a12: color) {.importc: "nk_stroke_curve".}
proc strokeCurve*(cmdBuf: var command_buffer, ax, ay, ctrl0x, ctrl0y, ctrl1x, ctrl1y, bx, by, lineThickness: float32, col: color) =
  stroke_curve(addr cmdBuf, ax, ay, ctrl0x, ctrl0y, ctrl1x, ctrl1y, bx, by, lineThickness, col)

proc stroke_rect(a2: ptr command_buffer; a3: rect; rounding: float32;
                    line_thickness: float32; a6: color) {.importc: "nk_stroke_rect".}
proc strokeRect*(cmdBuf: var command_buffer, r: rect, rounding, lineThickness: float32, col: color) =
  stroke_rect(addr cmdBuf, r, rounding, lineThickness, col)

proc stroke_circle(a2: ptr command_buffer; a3: rect; line_thickness: float32;
                      a5: color) {.importc: "nk_stroke_circle".}
proc strokeCircle*(cmdBuf: var command_buffer, r: rect, lineThickness: float32, col: color) =
  stroke_circle(addr cmdBuf, r, lineThickness, col)

proc stroke_arc(a2: ptr command_buffer; cx: float32; cy: float32; radius: float32;
                   a_min: float32; a_max: float32; line_thickness: float32; a9: color) {. importc: "nk_stroke_arc".}
proc strokeArc*(cmdBuf: var command_buffer, cx, cy, radius, aMin, aMax, lineThickness: float32, col: color) =
  stroke_arc(addr cmdBuf, cx, cy, radius, aMin, aMax, lineThickness, col)

proc stroke_triangle(a2: ptr command_buffer; a3: float32; a4: float32; a5: float32;
                        a6: float32; a7: float32; a8: float32; line_thichness: float32;
                        a10: color) {.importc: "nk_stroke_triangle".}
proc strokeTriangle*(cmdBuf: var command_buffer, x0, y0, x1, y1, x2, y2, lineThickness: float32, col: color) =
  stroke_triangle(addr cmdBuf, x0, y0, x1, y1, x2, y2, lineThickness, col)

proc stroke_polyline(a2: ptr command_buffer; points: ptr float32;
                        point_count: int32; line_thickness: float32; col: color) {. importc: "nk_stroke_polyline".}
proc strokePolyLine*(cmdBuf: var command_buffer, points: var float32, pointCount: int32, lineThickness: float32, col: color) =
  stroke_polyline(addr cmdBuf, addr points, pointCount, lineThickness, col)

proc stroke_polygon(a2: ptr command_buffer; a3: ptr float32; point_count: int32;
                       line_thickness: float32; a6: color) {.importc: "nk_stroke_polygon".}
proc strokePolygon*(cmdBuf: var command_buffer, points: var float32, pointCount: int32, lineThickness: float32, col: color) =
  stroke_polygon(addr cmdBuf, addr points, pointCount, lineThickness, col)

proc fill_rect(a2: ptr command_buffer; a3: rect; rounding: float32;
                  a5: color) {.importc: "nk_fill_rect".}
proc fillRect*(cmdBuf: var command_buffer, r: rect, rounding: float32, col: color) =
  fill_rect(addr cmdBuf, r, rounding, col)

proc fill_rect_multi_color(a2: ptr command_buffer; a3: rect; left: color;
                              top: color; right: color; bottom: color) {. importc: "nk_fill_rect_multi_color".}
proc fillRectMultiColor*(cmdBuf: var command_buffer, r: rect, left, top, right, bottom: color) =
  fill_rect_multi_color(addr cmdBuf, r, left, top, right, bottom)

proc fill_circle(a2: ptr command_buffer; a3: rect; a4: color) {.importc: "nk_fill_circle".}
proc fillCircle*(cmdBuf: var command_buffer, r: rect, col: color) =
  fill_circle(addr cmdBuf, r, col)

proc fill_arc(a2: ptr command_buffer; cx: float32; cy: float32; radius: float32;
                 a_min: float32; a_max: float32; a8: color) {.importc: "nk_fill_arc".}
proc fillArc*(cmdBuf: var command_buffer, cx, cy, radius, aMin, aMax: float32, col: color) =
  fill_arc(addr cmdBuf, cx, cy, radius, aMin, aMax, col)

proc fill_triangle(a2: ptr command_buffer; x0: float32; y0: float32; x1: float32;
                      y1: float32; x2: float32; y2: float32; a9: color) {.importc: "nk_fill_triangle".}
proc fillTriangle*(cmdBuf: var command_buffer, x0, y0, x1, y1, x2, y2: float32, col: color) =
  fill_triangle(addr cmdBuf, x0, y0, x1, y1, x2, y2, col)

proc fill_polygon(a2: ptr command_buffer; a3: ptr float32; point_count: int32;
                     a5: color) {.importc: "nk_fill_polygon".}
proc fillPolygon*(cmdBuf: var command_buffer, points: var float32, pointCount: int32, col: color) =
  fill_polygon(addr cmdBuf, addr points, pointCount, col)

proc push_scissor(a2: ptr command_buffer; a3: rect) {.importc: "nk_push_scissor".}
proc pushScissor*(cmdBuf: var command_buffer, r: rect) =
  push_scissor(addr cmdBuf, r)

proc draw_image(a2: ptr command_buffer; a3: rect; a4: ptr img;
                   a5: color) {.importc: "nk_draw_image".}
proc drawImage*(cmdBuf: var command_buffer, r: rect, img: var img, col: color) =
  draw_image(addr cmdBuf, r, addr img, col)

proc draw_text*(a2: ptr command_buffer; a3: rect; text: cstring; len: int32;
                  a6: ptr user_font; a7: color; a8: color) {.importc: "nk_draw_text".}
proc next*(a2: ptr context; a3: ptr command): ptr command {.importc: "nk__next".}
proc begin*(a2: ptr context): ptr command {.importc: "nk__begin".}


proc input_has_mouse_click*(a2: ptr input; a3: buttons): int32 {.importc: "nk_input_has_mouse_click".}
proc input_has_mouse_click_in_rect*(a2: ptr input; a3: buttons; a4: rect): int32 {. importc: "nk_input_has_mouse_click_in_rect".}
proc input_has_mouse_click_down_in_rect*(a2: ptr input; a3: buttons;
    a4: rect; down: int32): int32 {.importc: "nk_input_has_mouse_click_down_in_rect".}
proc input_is_mouse_click_in_rect*(a2: ptr input; a3: buttons; a4: rect): int32 {. importc: "nk_input_is_mouse_click_in_rect".}
proc input_is_mouse_click_down_in_rect*(i: ptr input; id: buttons;
    b: rect; down: int32): int32 {.                           importc: "nk_input_is_mouse_click_down_in_rect".}
proc input_any_mouse_click_in_rect*(a2: ptr input; a3: rect): int32 {.importc: "nk_input_any_mouse_click_in_rect".}
proc input_is_mouse_prev_hovering_rect*(a2: ptr input; a3: rect): int32 {. importc: "nk_input_is_mouse_prev_hovering_rect".}
proc input_is_mouse_hovering_rect*(a2: ptr input; a3: rect): int32 {.importc: "nk_input_is_mouse_hovering_rect".}
proc input_mouse_clicked*(a2: ptr input; a3: buttons; a4: rect): int32 {. importc: "nk_input_mouse_clicked".}
proc input_is_mouse_down*(a2: ptr input; a3: buttons): int32 {.importc: "nk_input_is_mouse_down".}
proc input_is_mouse_pressed*(a2: ptr input; a3: buttons): int32 {.importc: "nk_input_is_mouse_pressed".}
proc input_is_mouse_released*(a2: ptr input; a3: buttons): int32 {.importc: "nk_input_is_mouse_released".}
proc input_is_key_pressed*(a2: ptr input; a3: keys): int32 {.importc: "nk_input_is_key_pressed".}
proc input_is_key_released*(a2: ptr input; a3: keys): int32 {.importc: "nk_input_is_key_released".}
proc input_is_key_down*(a2: ptr input; a3: keys): int32 {.importc: "nk_input_is_key_down".}
  
type
  draw_index* = int16
  draw_list_stroke* = enum
    STROKE_OPEN = nk_false, STROKE_CLOSED = nk_true

const
  FORMAT_R8G8B8 = FORMAT_COLOR_BEGIN
  FORMAT_COLOR_END = FORMAT_RGBA32


proc draw_list_init*(a2: ptr draw_list) {.importc: "nk_draw_list_init".}
proc draw_list_setup*(a2: ptr draw_list; a3: ptr convert_config;
                        cmds: ptr buffer; vertices: ptr buffer;
                        elements: ptr buffer) {.importc: "nk_draw_list_setup".}
proc draw_list_clear*(a2: ptr draw_list) {.importc: "nk_draw_list_clear".}
proc draw_list_begin*(a2: ptr draw_list; a3: ptr buffer): ptr draw_command {. importc: "nk__draw_list_begin".}
proc draw_list_next*(a2: ptr draw_command; a3: ptr buffer;
                        a4: ptr draw_list): ptr draw_command {.importc: "nk__draw_list_next".}
proc draw_list_end*(a2: ptr draw_list; a3: ptr buffer): ptr draw_command {. importc: "nk__draw_list_end".}
proc draw_list_clear*(list: ptr draw_list) {.importc: "nk_draw_list_clear".}
proc draw_list_path_clear*(a2: ptr draw_list) {.importc: "nk_draw_list_path_clear".}
proc draw_list_path_line_to*(a2: ptr draw_list; pos: vec2) {.importc: "nk_draw_list_path_line_to".}
proc draw_list_path_arc_to_fast*(a2: ptr draw_list; center: vec2;
                                   radius: float32; a_min: int32; a_max: int32) {.importc: "nk_draw_list_path_arc_to_fast".}
proc draw_list_path_arc_to*(a2: ptr draw_list; center: vec2; radius: float32;
                              a_min: float32; a_max: float32; segments: cuint) {.importc: "nk_draw_list_path_arc_to".}
proc draw_list_path_rect_to*(a2: ptr draw_list; a: vec2; b: vec2;
                               rounding: float32) {.importc: "nk_draw_list_path_rect_to".}
proc draw_list_path_curve_to*(a2: ptr draw_list; p2: vec2; p3: vec2;
                                p4: vec2; num_segments: cuint) {.importc: "nk_draw_list_path_curve_to".}
proc draw_list_path_fill*(a2: ptr draw_list; a3: color) {.importc: "nk_draw_list_path_fill".}
proc draw_list_path_stroke*(a2: ptr draw_list; a3: color;
                              closed: draw_list_stroke; thickness: float32) {. importc: "nk_draw_list_path_stroke".}
proc draw_list_stroke_line*(a2: ptr draw_list; a: vec2; b: vec2;
                              a5: color; thickness: float32) {.importc: "nk_draw_list_stroke_line".}
proc draw_list_stroke_rect*(a2: ptr draw_list; rect: rect; a4: color;
                              rounding: float32; thickness: float32) {.importc: "nk_draw_list_stroke_rect".}
proc draw_list_stroke_triangle*(a2: ptr draw_list; a: vec2; b: vec2;
                                  c: vec2; a6: color; thickness: float32) {. importc: "nk_draw_list_stroke_triangle".}
proc draw_list_stroke_circle*(a2: ptr draw_list; center: vec2;
                                radius: float32; a5: color; segs: cuint;
                                thickness: float32) {.importc: "nk_draw_list_stroke_circle".}
proc draw_list_stroke_curve*(a2: ptr draw_list; p0: vec2; cp0: vec2;
                               cp1: vec2; p1: vec2; a7: color;
                               segments: cuint; thickness: float32) {.importc: "nk_draw_list_stroke_curve".}
proc draw_list_stroke_poly_line*(a2: ptr draw_list; pnts: ptr vec2;
                                   cnt: cuint; a5: color;
                                   a6: draw_list_stroke; thickness: float32;
                                   a8: anti_aliasing) {.importc: "nk_draw_list_stroke_poly_line".}
proc draw_list_fill_rect*(a2: ptr draw_list; rect: rect; a4: color;
                            rounding: float32) {.importc: "nk_draw_list_fill_rect".}
proc draw_list_fill_rect_multi_color*(a2: ptr draw_list; rect: rect;
                                        left: color; top: color;
                                        right: color; bottom: color) {.importc: "nk_draw_list_fill_rect_multi_color".}
proc draw_list_fill_triangle*(a2: ptr draw_list; a: vec2; b: vec2;
                                c: vec2; a6: color) {.importc: "nk_draw_list_fill_triangle".}
proc draw_list_fill_circle*(a2: ptr draw_list; center: vec2; radius: float32;
                              col: color; segs: cuint) {.importc: "nk_draw_list_fill_circle".}
proc draw_list_fill_poly_convex*(a2: ptr draw_list; points: ptr vec2;
                                   count: cuint; a5: color; a6: anti_aliasing) {. importc: "nk_draw_list_fill_poly_convex".}
proc draw_list_add_image*(a2: ptr draw_list; texture: img; rect: rect;
                            a5: color) {.importc: "nk_draw_list_add_image".}
proc draw_list_add_text*(a2: ptr draw_list; a3: ptr user_font; a4: rect;
                           text: cstring; len: int32; font_height: float32; a8: color) {. importc: "nk_draw_list_add_text".}

proc style_item_image*(img: img): style_item {.importc: "nk_style_item_image".}
proc style_item_color*(a2: color): style_item {.importc: "nk_style_item_color".}
proc style_item_hide*(): style_item {.importc: "nk_style_item_hide".}


type
  panel_set* {.size: sizeof(int32).} = enum
    PANEL_SET_NONBLOCK = PANEL_CONTEXTUAL.int32 or PANEL_COMBO.int32 or PANEL_MENU.int32 or
        PANEL_TOOLTIP.int32,
    PANEL_SET_POPUP = PANEL_SET_NONBLOCK.int32 or PANEL_POPUP.int32,
    PANEL_SET_SUB = PANEL_SET_POPUP.int32 or PANEL_GROUP.int32


type
  window_flags* {.size: sizeof(int32).} = enum
    WINDOW_PRIVATE = (1 shl (10)), WINDOW_ROM = (1 shl (11)),
    WINDOW_HIDDEN = (1 shl (12)), WINDOW_CLOSED = (1 shl (13)),
    WINDOW_MINIMIZED = (1 shl (14)), WINDOW_REMOVE_ROM = (1 shl (15))

const
  WINDOW_DYNAMIC = WINDOW_PRIVATE

proc init_default*(a2: ptr context; a3: ptr user_font): int32 {.importc: "nk_init_default".}
proc init_fixed*(a2: ptr context; memory: pointer; size: uint;
                   a5: ptr user_font): int32 {.importc: "nk_init_fixed".}
proc init*(a2: ptr context; a3: ptr allocator; a4: ptr user_font): int32 {. importc: "nk_init".}
proc init_custom*(a2: ptr context; cmds: ptr buffer; pool: ptr buffer;
                    a5: ptr user_font): int32 {.importc: "nk_init_custom".}
proc clear*(a2: ptr context) {.importc: "nk_clear".}
proc free*(a2: ptr context) {.importc: "nk_free".}
proc begin*(a2: ptr context; title: cstring; bounds: rect; flags: uint32): int32 {. importc: "nk_begin".}
proc begin_titled*(a2: ptr context; name: cstring; title: cstring;
                     bounds: rect; flags: uint32): int32 {.importc: "nk_begin_titled".}
proc `end`*(a2: ptr context) {.importc: "nk_end".}
proc window_find*(ctx: ptr context; name: cstring): ptr window {.importc: "nk_window_find".}
proc window_get_bounds*(a2: ptr context): rect {.importc: "nk_window_get_bounds".}
proc window_get_position*(a2: ptr context): vec2 {.importc: "nk_window_get_position".}
proc window_get_size*(a2: ptr context): vec2 {.importc: "nk_window_get_size".}
proc window_get_width*(a2: ptr context): float32 {.importc: "nk_window_get_width".}
proc window_get_height*(a2: ptr context): float32 {.importc: "nk_window_get_height".}
proc window_get_panel*(a2: ptr context): ptr panel {.importc: "nk_window_get_panel".}
proc window_get_content_region*(a2: ptr context): rect {.importc: "nk_window_get_content_region".}
proc window_get_content_region_min*(a2: ptr context): vec2 {.importc: "nk_window_get_content_region_min".}
proc window_get_content_region_max*(a2: ptr context): vec2 {.importc: "nk_window_get_content_region_max".}
proc window_get_content_region_size*(a2: ptr context): vec2 {.importc: "nk_window_get_content_region_size".}
proc window_get_canvas*(a2: ptr context): ptr command_buffer {.importc: "nk_window_get_canvas".}
proc window_has_focus*(a2: ptr context): int32 {.importc: "nk_window_has_focus".}
proc window_is_collapsed*(a2: ptr context; a3: cstring): int32 {.importc: "nk_window_is_collapsed".}
proc window_is_closed*(a2: ptr context; a3: cstring): int32 {.importc: "nk_window_is_closed".}
proc window_is_hidden*(a2: ptr context; a3: cstring): int32 {.importc: "nk_window_is_hidden".}
proc window_is_active*(a2: ptr context; a3: cstring): int32 {.importc: "nk_window_is_active".}
proc window_is_hovered*(a2: ptr context): int32 {.importc: "nk_window_is_hovered".}
proc window_is_any_hovered*(a2: ptr context): int32 {.importc: "nk_window_is_any_hovered".}
proc item_is_any_active*(a2: ptr context): int32 {.importc: "nk_item_is_any_active".}
proc window_set_bounds*(a2: ptr context; a3: rect) {.importc: "nk_window_set_bounds".}
proc window_set_position*(a2: ptr context; a3: vec2) {.importc: "nk_window_set_position".}
proc window_set_size*(a2: ptr context; a3: vec2) {.importc: "nk_window_set_size".}
proc window_set_focus*(a2: ptr context; name: cstring) {.importc: "nk_window_set_focus".}
proc window_close*(ctx: ptr context; name: cstring) {.importc: "nk_window_close".}
proc window_collapse*(a2: ptr context; name: cstring; a4: collapse_states) {. importc: "nk_window_collapse".}
proc window_collapse_if*(a2: ptr context; name: cstring; a4: collapse_states;
                           cond: int32) {.importc: "nk_window_collapse_if".}
proc window_show*(a2: ptr context; name: cstring; a4: show_states) {.importc: "nk_window_show".}
proc window_show_if*(a2: ptr context; name: cstring; a4: show_states;
                       cond: int32) {.importc: "nk_window_show_if".}
proc layout_row_dynamic*(a2: ptr context; height: float32; cols: int32) {.importc: "nk_layout_row_dynamic".}
proc layout_row_static*(a2: ptr context; height: float32; item_width: int32;
                          cols: int32) {.importc: "nk_layout_row_static".}
proc layout_row_begin*(a2: ptr context; a3: layout_format;
                         row_height: float32; cols: int32) {.importc: "nk_layout_row_begin".}
proc layout_row_push*(a2: ptr context; value: float32) {.importc: "nk_layout_row_push".}
proc layout_row_end*(a2: ptr context) {.importc: "nk_layout_row_end".}
proc layout_row*(a2: ptr context; a3: layout_format; height: float32;
                   cols: int32; ratio: ptr float32) {.importc: "nk_layout_row".}
proc layout_row_template_begin*(a2: ptr context; height: float32) {.importc: "nk_layout_row_template_begin".}
proc layout_row_template_push_dynamic*(a2: ptr context) {.importc: "nk_layout_row_template_push_dynamic".}
proc layout_row_template_push_variable*(a2: ptr context; min_width: float32) {. importc: "nk_layout_row_template_push_variable".}
proc layout_row_template_push_static*(a2: ptr context; width: float32) {.importc: "nk_layout_row_template_push_static".}
proc layout_row_template_end*(a2: ptr context) {.importc: "nk_layout_row_template_end".}
proc layout_space_begin*(a2: ptr context; a3: layout_format; height: float32;
                           widget_count: int32) {.importc: "nk_layout_space_begin".}
proc layout_space_push*(a2: ptr context; a3: rect) {.importc: "nk_layout_space_push".}
proc layout_space_end*(a2: ptr context) {.importc: "nk_layout_space_end".}
proc layout_space_bounds*(a2: ptr context): rect {.importc: "nk_layout_space_bounds".}
proc layout_space_to_screen*(a2: ptr context; a3: vec2): vec2 {.importc: "nk_layout_space_to_screen".}
proc layout_space_to_local*(a2: ptr context; a3: vec2): vec2 {.importc: "nk_layout_space_to_local".}
proc layout_space_rect_to_screen*(a2: ptr context; a3: rect): rect {.importc: "nk_layout_space_rect_to_screen".}
proc layout_space_rect_to_local*(a2: ptr context; a3: rect): rect {.importc: "nk_layout_space_rect_to_local".}
proc layout_ratio_from_pixel*(a2: ptr context; pixel_width: float32): float32 {. importc: "nk_layout_ratio_from_pixel".}
proc group_begin*(a2: ptr context; title: cstring; a4: uint32): int32 {.importc: "nk_group_begin".}
proc group_scrolled_offset_begin*(a2: ptr context; x_offset: ptr uint32;
                                    y_offset: ptr uint32; a5: cstring; a6: uint32): int32 {. importc: "nk_group_scrolled_offset_begin".}
proc group_scrolled_begin*(a2: ptr context; a3: ptr scroll; title: cstring;
                             a5: uint32): int32 {.importc: "nk_group_scrolled_begin".}
proc group_scrolled_end*(a2: ptr context) {.importc: "nk_group_scrolled_end".}
proc group_end*(a2: ptr context) {.importc: "nk_group_end".}
proc list_view_begin*(a2: ptr context; o: ptr list_view; id: cstring;
                        a5: uint32; row_height: int32; row_count: int32): int32 {.importc: "nk_list_view_begin".}
proc list_view_end*(a2: ptr list_view) {.importc: "nk_list_view_end".}
proc tree_push_hashed*(a2: ptr context; a3: tree_type; title: cstring;
                         initial_state: collapse_states; hash: cstring;
                         len: int32; seed: int32): int32 {.importc: "nk_tree_push_hashed".}
proc tree_image_push_hashed*(a2: ptr context; a3: tree_type; a4: img;
                               title: cstring; initial_state: collapse_states;
                               hash: cstring; len: int32; seed: int32): int32 {.importc: "nk_tree_image_push_hashed".}
proc tree_pop*(a2: ptr context) {.importc: "nk_tree_pop".}
proc tree_state_push*(a2: ptr context; a3: tree_type; title: cstring;
                        state: ptr collapse_states): int32 {.importc: "nk_tree_state_push".}
proc tree_state_image_push*(a2: ptr context; a3: tree_type; a4: img;
                              title: cstring; state: ptr collapse_states): int32 {. importc: "nk_tree_state_image_push".}
proc tree_state_pop*(a2: ptr context) {.importc: "nk_tree_state_pop".}
proc text*(a2: ptr context; a3: cstring; a4: int32; a5: uint32) {.importc: "nk_text".}
proc text_colored*(a2: ptr context; a3: cstring; a4: int32; a5: uint32;
                     a6: color) {.importc: "nk_text_colored".}
proc text_wrap*(a2: ptr context; a3: cstring; a4: int32) {.importc: "nk_text_wrap".}
proc text_wrap_colored*(a2: ptr context; a3: cstring; a4: int32; a5: color) {. importc: "nk_text_wrap_colored".}
proc label*(a2: ptr context; a3: cstring; align: uint32) {.importc: "nk_label".}
proc label_colored*(a2: ptr context; a3: cstring; align: uint32; a5: color) {. importc: "nk_label_colored".}
proc label_wrap*(a2: ptr context; a3: cstring) {.importc: "nk_label_wrap".}
proc label_colored_wrap*(a2: ptr context; a3: cstring; a4: color) {.importc: "nk_label_colored_wrap".}
proc image*(a2: ptr context; a3: img) {.importc: "nk_image".}
proc button_set_behavior*(a2: ptr context; a3: button_behavior) {.importc: "nk_button_set_behavior".}
proc button_push_behavior*(a2: ptr context; a3: button_behavior): int32 {. importc: "nk_button_push_behavior".}
proc button_pop_behavior*(a2: ptr context): int32 {.importc: "nk_button_pop_behavior".}
proc button_text*(a2: ptr context; title: cstring; len: int32): int32 {.importc: "nk_button_text".}
proc button_label*(a2: ptr context; title: cstring): int32 {.importc: "nk_button_label".}
proc button_color*(a2: ptr context; a3: color): int32 {.importc: "nk_button_color".}
proc button_symbol*(a2: ptr context; a3: symbol_type): int32 {.importc: "nk_button_symbol".}
proc button_image*(a2: ptr context; i: img): int32 {.importc: "nk_button_image".}
proc button_symbol_label*(a2: ptr context; a3: symbol_type; a4: cstring;
                            text_alignment: uint32): int32 {.importc: "nk_button_symbol_label".}
proc button_symbol_text*(a2: ptr context; a3: symbol_type; a4: cstring;
                           a5: int32; alignment: uint32): int32 {.importc: "nk_button_symbol_text".}
proc button_image_label*(a2: ptr context; i: img; a4: cstring;
                           text_alignment: uint32): int32 {.importc: "nk_button_image_label".}
proc button_image_text*(a2: ptr context; i: img; a4: cstring; a5: int32;
                          alignment: uint32): int32 {.importc: "nk_button_image_text".}
proc button_text_styled*(a2: ptr context; a3: ptr style_button;
                           title: cstring; len: int32): int32 {.importc: "nk_button_text_styled".}
proc button_label_styled*(a2: ptr context; a3: ptr style_button;
                            title: cstring): int32 {.importc: "nk_button_label_styled".}
proc button_symbol_styled*(a2: ptr context; a3: ptr style_button;
                             a4: symbol_type): int32 {.importc: "nk_button_symbol_styled".}
proc button_image_styled*(a2: ptr context; a3: ptr style_button; i: img): int32 {. importc: "nk_button_image_styled".}
proc button_symbol_label_styled*(a2: ptr context; a3: ptr style_button;
                                   a4: symbol_type; a5: cstring;
                                   text_alignment: uint32): int32 {.importc: "nk_button_symbol_label_styled".}
proc button_symbol_text_styled*(a2: ptr context; a3: ptr style_button;
                                  a4: symbol_type; a5: cstring; a6: int32;
                                  alignment: uint32): int32 {.importc: "nk_button_symbol_text_styled".}
proc button_image_label_styled*(a2: ptr context; a3: ptr style_button;
                                  i: img; a5: cstring;
                                  text_alignment: uint32): int32 {.importc: "nk_button_image_label_styled".}
proc button_image_text_styled*(a2: ptr context; a3: ptr style_button;
                                 i: img; a5: cstring; a6: int32;
                                 alignment: uint32): int32 {.importc: "nk_button_image_text_styled".}
proc check_label*(a2: ptr context; a3: cstring; active: int32): int32 {.importc: "nk_check_label".}
proc check_text*(a2: ptr context; a3: cstring; a4: int32; active: int32): int32 {.importc: "nk_check_text".}
proc check_flags_label*(a2: ptr context; a3: cstring; flags: cuint; value: cuint): cuint {. importc: "nk_check_flags_label".}
proc check_flags_text*(a2: ptr context; a3: cstring; a4: int32; flags: cuint;
                         value: cuint): cuint {.importc: "nk_check_flags_text".}
proc checkbox_label*(a2: ptr context; a3: cstring; active: ptr int32): int32 {.importc: "nk_checkbox_label".}
proc checkbox_text*(a2: ptr context; a3: cstring; a4: int32; active: ptr int32): int32 {. importc: "nk_checkbox_text".}
proc checkbox_flags_label*(a2: ptr context; a3: cstring; flags: ptr cuint;
                             value: cuint): int32 {.importc: "nk_checkbox_flags_label".}
proc checkbox_flags_text*(a2: ptr context; a3: cstring; a4: int32;
                            flags: ptr cuint; value: cuint): int32 {.importc: "nk_checkbox_flags_text".}
proc radio_label*(a2: ptr context; a3: cstring; active: ptr int32): int32 {.importc: "nk_radio_label".}
proc radio_text*(a2: ptr context; a3: cstring; a4: int32; active: ptr int32): int32 {. importc: "nk_radio_text".}
proc option_label*(a2: ptr context; a3: cstring; active: int32): int32 {.importc: "nk_option_label".}
proc option_text*(a2: ptr context; a3: cstring; a4: int32; active: int32): int32 {. importc: "nk_option_text".}
proc selectable_label*(a2: ptr context; a3: cstring; align: uint32;
                         value: ptr int32): int32 {.importc: "nk_selectable_label".}
proc selectable_text*(a2: ptr context; a3: cstring; a4: int32; align: uint32;
                        value: ptr int32): int32 {.importc: "nk_selectable_text".}
proc selectable_image_label*(a2: ptr context; a3: img; a4: cstring;
                               align: uint32; value: ptr int32): int32 {.importc: "nk_selectable_image_label".}
proc selectable_image_text*(a2: ptr context; a3: img; a4: cstring; a5: int32;
                              align: uint32; value: ptr int32): int32 {.importc: "nk_selectable_image_text".}
proc select_label*(a2: ptr context; a3: cstring; align: uint32; value: int32): int32 {. importc: "nk_select_label".}
proc select_text*(a2: ptr context; a3: cstring; a4: int32; align: uint32;
                    value: int32): int32 {.importc: "nk_select_text".}
proc select_image_label*(a2: ptr context; a3: img; a4: cstring;
                           align: uint32; value: int32): int32 {.importc: "nk_select_image_label".}
proc select_image_text*(a2: ptr context; a3: img; a4: cstring; a5: int32;
                          align: uint32; value: int32): int32 {.importc: "nk_select_image_text".}
proc slide_float*(a2: ptr context; min: float32; val: float32; max: float32;
                    step: float32): float32 {.importc: "nk_slide_float".}
proc slide_int*(a2: ptr context; min: int32; val: int32; max: int32; step: int32): int32 {. importc: "nk_slide_int".}
proc slider_float*(a2: ptr context; min: float32; val: ptr float32; max: float32;
                     step: float32): int32 {.importc: "nk_slider_float".}
proc slider_int*(a2: ptr context; min: int32; val: ptr int32; max: int32; step: int32): int32 {. importc: "nk_slider_int".}
proc progress*(a2: ptr context; cur: ptr uint; max: uint; modifyable: int32): int32 {. importc: "nk_progress".}
proc prog*(a2: ptr context; cur: uint; max: uint; modifyable: int32): uint {. importc: "nk_prog".}
proc color_picker*(a2: ptr context; a3: color; a4: color_format): color {. importc: "nk_color_picker".}
proc color_pick*(a2: ptr context; a3: ptr color; a4: color_format): int32 {. importc: "nk_color_pick".}
proc property_int*(a2: ptr context; name: cstring; min: int32; val: ptr int32;
                     max: int32; step: int32; inc_per_pixel: float32) {.importc: "nk_property_int".}
proc property_float*(a2: ptr context; name: cstring; min: float32; val: ptr float32;
                       max: float32; step: float32; inc_per_pixel: float32) {.importc: "nk_property_float".}
proc property_double*(a2: ptr context; name: cstring; min: cdouble;
                        val: ptr cdouble; max: cdouble; step: cdouble;
                        inc_per_pixel: float32) {.importc: "nk_property_double".}
proc propertyi*(a2: ptr context; name: cstring; min: int32; val: int32; max: int32;
                  step: int32; inc_per_pixel: float32): int32 {.importc: "nk_propertyi".}
proc propertyf*(a2: ptr context; name: cstring; min: float32; val: float32;
                  max: float32; step: float32; inc_per_pixel: float32): float32 {.importc: "nk_propertyf".}
proc propertyd*(a2: ptr context; name: cstring; min: cdouble; val: cdouble;
                  max: cdouble; step: cdouble; inc_per_pixel: float32): cdouble {.importc: "nk_propertyd".}
proc edit_focus*(a2: ptr context; flags: uint32) {.importc: "nk_edit_focus".}
proc edit_unfocus*(a2: ptr context) {.importc: "nk_edit_unfocus".}
proc edit_string(a2: ptr context; a3: uint32; buffer: cstring; len: ptr int32;
                    max: int32; a7: plugin_filter): uint32 {.importc: "nk_edit_string".}
proc editString*(ctx: var context, u: uint32, buffer: string, len: var int32, max: int32, f: InputFilter): uint32 =
  edit_string(addr ctx, u, buffer, addr len, max, cast[plugin_filter](f))
  

proc edit_buffer*(a2: ptr context; a3: uint32; a4: ptr text_edit;
                    a5: plugin_filter): uint32 {.importc: "nk_edit_buffer".}
                    
proc edit_string_zero_terminated*(a2: ptr context; a3: uint32;
                                    buffer: cstring; max: int32; a6: plugin_filter): uint32 {. importc: "nk_edit_string_zero_terminated".}
proc chart_begin*(a2: ptr context; a3: chart_type; num: int32; min: float32;
                    max: float32): int32 {.importc: "nk_chart_begin".}
proc chart_begin_colored*(a2: ptr context; a3: chart_type; a4: color;
                            active: color; num: int32; min: float32; max: float32): int32 {. importc: "nk_chart_begin_colored".}
proc chart_add_slot*(ctx: ptr context; a3: chart_type; count: int32;
                       min_value: float32; max_value: float32) {.importc: "nk_chart_add_slot".}
proc chart_add_slot_colored*(ctx: ptr context; a3: chart_type; a4: color;
                               active: color; count: int32; min_value: float32;
                               max_value: float32) {.importc: "nk_chart_add_slot_colored".}
proc chart_push*(a2: ptr context; a3: float32): uint32 {.importc: "nk_chart_push".}
proc chart_push_slot*(a2: ptr context; a3: float32; a4: int32): uint32 {.importc: "nk_chart_push_slot".}
proc chart_end*(a2: ptr context) {.importc: "nk_chart_end".}
proc plot*(a2: ptr context; a3: chart_type; values: ptr float32; count: int32;
             offset: int32) {.importc: "nk_plot".}
proc plot_function*(a2: ptr context; a3: chart_type; userdata: pointer;
    value_getter: proc (user: pointer; index: int32): float32 {.cdecl.}; count: int32;
                      offset: int32) {.importc: "nk_plot_function".}
proc popup_begin*(a2: ptr context; a3: popup_type; a4: cstring; a5: uint32;
                    bounds: rect): int32 {.importc: "nk_popup_begin".}
proc popup_close*(a2: ptr context) {.importc: "nk_popup_close".}
proc popup_end*(a2: ptr context) {.importc: "nk_popup_end".}
proc combo*(a2: ptr context; items: cstringArray; count: int32; selected: int32;
              item_height: int32; size: vec2): int32 {.importc: "nk_combo".}
proc combo_separator*(a2: ptr context; items_separated_by_separator: cstring;
                        separator: int32; selected: int32; count: int32;
                        item_height: int32; size: vec2): int32 {.importc: "nk_combo_separator".}
proc combo_string*(a2: ptr context; items_separated_by_zeros: cstring;
                     selected: int32; count: int32; item_height: int32; size: vec2): int32 {. importc: "nk_combo_string".}
proc combo_callback*(a2: ptr context; item_getter: proc (a2: pointer; a3: int32;
    a4: cstringArray) {.cdecl.}; userdata: pointer; selected: int32; count: int32;
                       item_height: int32; size: vec2): int32 {.importc: "nk_combo_callback".}
proc combobox*(a2: ptr context; items: cstringArray; count: int32;
                 selected: ptr int32; item_height: int32; size: vec2) {.importc: "nk_combobox".}
proc combobox_string*(a2: ptr context; items_separated_by_zeros: cstring;
                        selected: ptr int32; count: int32; item_height: int32;
                        size: vec2) {.importc: "nk_combobox_string".}
proc combobox_separator*(a2: ptr context;
                           items_separated_by_separator: cstring; separator: int32;
                           selected: ptr int32; count: int32; item_height: int32;
                           size: vec2) {.importc: "nk_combobox_separator".}
proc combobox_callback*(a2: ptr context; item_getter: proc (a2: pointer; a3: int32;
    a4: cstringArray) {.cdecl.}; a4: pointer; selected: ptr int32; count: int32;
                          item_height: int32; size: vec2) {.importc: "nk_combobox_callback".}
proc combo_begin_text*(a2: ptr context; selected: cstring; a4: int32; size: vec2): int32 {. importc: "nk_combo_begin_text".}
proc combo_begin_label*(a2: ptr context; selected: cstring; size: vec2): int32 {. importc: "nk_combo_begin_label".}
proc combo_begin_color*(a2: ptr context; color: color; size: vec2): int32 {. importc: "nk_combo_begin_color".}
proc combo_begin_symbol*(a2: ptr context; a3: symbol_type; size: vec2): int32 {. importc: "nk_combo_begin_symbol".}
proc combo_begin_symbol_label*(a2: ptr context; selected: cstring;
                                 a4: symbol_type; size: vec2): int32 {.importc: "nk_combo_begin_symbol_label".}
proc combo_begin_symbol_text*(a2: ptr context; selected: cstring; a4: int32;
                                a5: symbol_type; size: vec2): int32 {.importc: "nk_combo_begin_symbol_text".}
proc combo_begin_image*(a2: ptr context; i: img; size: vec2): int32 {. importc: "nk_combo_begin_image".}
proc combo_begin_image_label*(a2: ptr context; selected: cstring; a4: img;
                                size: vec2): int32 {.importc: "nk_combo_begin_image_label".}
proc combo_begin_image_text*(a2: ptr context; selected: cstring; a4: int32;
                               a5: img; size: vec2): int32 {.importc: "nk_combo_begin_image_text".}
proc combo_item_label*(a2: ptr context; a3: cstring; alignment: uint32): int32 {. importc: "nk_combo_item_label".}
proc combo_item_text*(a2: ptr context; a3: cstring; a4: int32; alignment: uint32): int32 {. importc: "nk_combo_item_text".}
proc combo_item_image_label*(a2: ptr context; a3: img; a4: cstring;
                               alignment: uint32): int32 {.importc: "nk_combo_item_image_label".}
proc combo_item_image_text*(a2: ptr context; a3: img; a4: cstring; a5: int32;
                              alignment: uint32): int32 {.importc: "nk_combo_item_image_text".}
proc combo_item_symbol_label*(a2: ptr context; a3: symbol_type; a4: cstring;
                                alignment: uint32): int32 {.importc: "nk_combo_item_symbol_label".}
proc combo_item_symbol_text*(a2: ptr context; a3: symbol_type; a4: cstring;
                               a5: int32; alignment: uint32): int32 {.importc: "nk_combo_item_symbol_text".}
proc combo_close*(a2: ptr context) {.importc: "nk_combo_close".}
proc combo_end*(a2: ptr context) {.importc: "nk_combo_end".}
proc contextual_begin*(a2: ptr context; a3: uint32; a4: vec2;
                         trigger_bounds: rect): int32 {.importc: "nk_contextual_begin".}
proc contextual_item_text*(a2: ptr context; a3: cstring; a4: int32; align: uint32): int32 {. importc: "nk_contextual_item_text".}
proc contextual_item_label*(a2: ptr context; a3: cstring; align: uint32): int32 {. importc: "nk_contextual_item_label".}
proc contextual_item_image_label*(a2: ptr context; a3: img; a4: cstring;
                                    alignment: uint32): int32 {.importc: "nk_contextual_item_image_label".}
proc contextual_item_image_text*(a2: ptr context; a3: img; a4: cstring;
                                   len: int32; alignment: uint32): int32 {.importc: "nk_contextual_item_image_text".}
proc contextual_item_symbol_label*(a2: ptr context; a3: symbol_type;
                                     a4: cstring; alignment: uint32): int32 {.importc: "nk_contextual_item_symbol_label".}
proc contextual_item_symbol_text*(a2: ptr context; a3: symbol_type;
                                    a4: cstring; a5: int32; alignment: uint32): int32 {. importc: "nk_contextual_item_symbol_text".}
proc contextual_close*(a2: ptr context) {.importc: "nk_contextual_close".}
proc contextual_end*(a2: ptr context) {.importc: "nk_contextual_end".}
proc tooltip*(a2: ptr context; a3: cstring) {.importc: "nk_tooltip".}
proc tooltip_begin*(a2: ptr context; width: float32): int32 {.importc: "nk_tooltip_begin".}
proc tooltip_end*(a2: ptr context) {.importc: "nk_tooltip_end".}
proc menubar_begin*(a2: ptr context) {.importc: "nk_menubar_begin".}
proc menubar_end*(a2: ptr context) {.importc: "nk_menubar_end".}
proc menu_begin_text*(a2: ptr context; title: cstring; title_len: int32;
                        align: uint32; size: vec2): int32 {.importc: "nk_menu_begin_text".}
proc menu_begin_label*(a2: ptr context; a3: cstring; align: uint32;
                         size: vec2): int32 {.importc: "nk_menu_begin_label".}
proc menu_begin_image*(a2: ptr context; a3: cstring; a4: img; size: vec2): int32 {. importc: "nk_menu_begin_image".}
proc menu_begin_image_text*(a2: ptr context; a3: cstring; a4: int32;
                              align: uint32; a6: img; size: vec2): int32 {. importc: "nk_menu_begin_image_text".}
proc menu_begin_image_label*(a2: ptr context; a3: cstring; align: uint32;
                               a5: img; size: vec2): int32 {.importc: "nk_menu_begin_image_label".}
proc menu_begin_symbol*(a2: ptr context; a3: cstring; a4: symbol_type;
                          size: vec2): int32 {.importc: "nk_menu_begin_symbol".}
proc menu_begin_symbol_text*(a2: ptr context; a3: cstring; a4: int32;
                               align: uint32; a6: symbol_type; size: vec2): int32 {. importc: "nk_menu_begin_symbol_text".}
proc menu_begin_symbol_label*(a2: ptr context; a3: cstring; align: uint32;
                                a5: symbol_type; size: vec2): int32 {.importc: "nk_menu_begin_symbol_label".}
proc menu_item_text*(a2: ptr context; a3: cstring; a4: int32; align: uint32): int32 {. importc: "nk_menu_item_text".}
proc menu_item_label*(a2: ptr context; a3: cstring; alignment: uint32): int32 {. importc: "nk_menu_item_label".}
proc menu_item_image_label*(a2: ptr context; a3: img; a4: cstring;
                              alignment: uint32): int32 {.importc: "nk_menu_item_image_label".}
proc menu_item_image_text*(a2: ptr context; a3: img; a4: cstring; len: int32;
                             alignment: uint32): int32 {.importc: "nk_menu_item_image_text".}
proc menu_item_symbol_text*(a2: ptr context; a3: symbol_type; a4: cstring;
                              a5: int32; alignment: uint32): int32 {.importc: "nk_menu_item_symbol_text".}
proc menu_item_symbol_label*(a2: ptr context; a3: symbol_type; a4: cstring;
                               alignment: uint32): int32 {.importc: "nk_menu_item_symbol_label".}
proc menu_close*(a2: ptr context) {.importc: "nk_menu_close".}
proc menu_end*(a2: ptr context) {.importc: "nk_menu_end".}
proc convert*(a2: ptr context; cmds: ptr buffer; vertices: ptr buffer;
                elements: ptr buffer; a6: ptr convert_config) {.importc: "nk_convert".}
proc draw_begin*(a2: ptr context; a3: ptr buffer): ptr draw_command {.importc: "nk__draw_begin".}
proc draw_end*(a2: ptr context; a3: ptr buffer): ptr draw_command {.importc: "nk__draw_end".}
proc draw_next*(a2: ptr draw_command; a3: ptr buffer; a4: ptr context): ptr draw_command {. importc: "nk__draw_next".}
proc input_begin*(a2: ptr context) {.importc: "nk_input_begin".}
proc input_motion*(a2: ptr context; x: int32; y: int32) {.importc: "nk_input_motion".}
proc input_key*(a2: ptr context; a3: keys; down: int32) {.importc: "nk_input_key".}
proc input_button*(a2: ptr context; a3: buttons; x: int32; y: int32; down: int32) {. importc: "nk_input_button".}
proc input_scroll*(a2: ptr context; y: float32) {.importc: "nk_input_scroll".}
proc input_char*(a2: ptr context; a3: char) {.importc: "nk_input_char".}
proc input_glyph*(a2: ptr context; a3: glyph) {.importc: "nk_input_glyph".}
proc input_unicode*(a2: ptr context; a3: uint32) {.importc: "nk_input_unicode".}
proc input_end*(a2: ptr context) {.importc: "nk_input_end".}
proc style_default*(a2: ptr context) {.importc: "nk_style_default".}
proc style_from_table*(a2: ptr context; a3: ptr color) {.importc: "nk_style_from_table".}
proc style_load_cursor*(a2: ptr context; a3: style_cursor; a4: ptr cursor) {. importc: "nk_style_load_cursor".}
proc style_load_all_cursors*(a2: ptr context; a3: ptr cursor) {.importc: "nk_style_load_all_cursors".}
proc style_get_color_by_name*(a2: style_colors): cstring {.importc: "nk_style_get_color_by_name".}
proc style_set_font*(a2: ptr context; a3: ptr user_font) {.importc: "nk_style_set_font".}
proc style_set_cursor*(a2: ptr context; a3: style_cursor): int32 {.importc: "nk_style_set_cursor".}
proc style_show_cursor*(a2: ptr context) {.importc: "nk_style_show_cursor".}
proc style_hide_cursor*(a2: ptr context) {.importc: "nk_style_hide_cursor".}
proc style_push_font*(a2: ptr context; a3: ptr user_font): int32 {.importc: "nk_style_push_font".}
proc style_push_float*(a2: ptr context; a3: ptr float32; a4: float32): int32 {.importc: "nk_style_push_float".}
proc style_push_vec2*(a2: ptr context; a3: ptr vec2; a4: vec2): int32 {.importc: "nk_style_push_vec2".}
proc style_push_style_item*(a2: ptr context; a3: ptr style_item;
                              a4: style_item): int32 {.importc: "nk_style_push_style_item".}
proc style_push_flags*(a2: ptr context; a3: ptr uint32; a4: uint32): int32 {. importc: "nk_style_push_flags".}
proc style_push_color*(a2: ptr context; a3: ptr color; a4: color): int32 {. importc: "nk_style_push_color".}
proc style_pop_font*(a2: ptr context): int32 {.importc: "nk_style_pop_font".}
proc style_pop_float*(a2: ptr context): int32 {.importc: "nk_style_pop_float".}
proc style_pop_vec2*(a2: ptr context): int32 {.importc: "nk_style_pop_vec2".}
proc style_pop_style_item*(a2: ptr context): int32 {.importc: "nk_style_pop_style_item".}
proc style_pop_flags*(a2: ptr context): int32 {.importc: "nk_style_pop_flags".}
proc style_pop_color*(a2: ptr context): int32 {.importc: "nk_style_pop_color".}
proc widget_bounds*(a2: ptr context): rect {.importc: "nk_widget_bounds".}
proc widget_position*(a2: ptr context): vec2 {.importc: "nk_widget_position".}
proc widget_size*(a2: ptr context): vec2 {.importc: "nk_widget_size".}
proc widget_width*(a2: ptr context): float32 {.importc: "nk_widget_width".}
proc widget_height*(a2: ptr context): float32 {.importc: "nk_widget_height".}
proc widget_is_hovered*(a2: ptr context): int32 {.importc: "nk_widget_is_hovered".}
proc widget_is_mouse_clicked*(a2: ptr context; a3: buttons): int32 {.importc: "nk_widget_is_mouse_clicked".}
proc widget_has_mouse_click_down*(a2: ptr context; a3: buttons; down: int32): int32 {. importc: "nk_widget_has_mouse_click_down".}
proc spacing*(a2: ptr context; cols: int32) {.importc: "nk_spacing".}
proc widget*(a2: ptr rect; a3: ptr context): widget_layout_states {.importc: "nk_widget".}
proc widget_fitting*(a2: ptr rect; a3: ptr context; a4: vec2): widget_layout_states {. importc: "nk_widget_fitting".}
proc rgb*(r: int32; g: int32; b: int32): color {.importc: "nk_rgb".}
proc rgb_iv*(rgb: ptr int32): color {.importc: "nk_rgb_iv".}
proc rgb_bv*(rgb: ptr char): color {.importc: "nk_rgb_bv".}
proc rgb_f*(r: float32; g: float32; b: float32): color {.importc: "nk_rgb_f".}
proc rgb_fv*(rgb: ptr float32): color {.importc: "nk_rgb_fv".}
proc rgb_hex*(rgb: cstring): color {.importc: "nk_rgb_hex".}
proc rgba*(r: int32; g: int32; b: int32; a: int32): color {.importc: "nk_rgba".}
proc rgba_u32*(a2: uint32): color {.importc: "nk_rgba_u32".}
proc rgba_iv*(rgba: ptr int32): color {.importc: "nk_rgba_iv".}
proc rgba_bv*(rgba: ptr char): color {.importc: "nk_rgba_bv".}
proc rgba_f*(r: float32; g: float32; b: float32; a: float32): color {.importc: "nk_rgba_f".}
proc rgba_fv*(rgba: ptr float32): color {.importc: "nk_rgba_fv".}
proc rgba_hex*(rgb: cstring): color {.importc: "nk_rgba_hex".}
proc hsv*(h: int32; s: int32; v: int32): color {.importc: "nk_hsv".}
proc hsv_iv*(hsv: ptr int32): color {.importc: "nk_hsv_iv".}
proc hsv_bv*(hsv: ptr char): color {.importc: "nk_hsv_bv".}
proc hsv_f*(h: float32; s: float32; v: float32): color {.importc: "nk_hsv_f".}
proc hsv_fv*(hsv: ptr float32): color {.importc: "nk_hsv_fv".}
proc hsva*(h: int32; s: int32; v: int32; a: int32): color {.importc: "nk_hsva".}
proc hsva_iv*(hsva: ptr int32): color {.importc: "nk_hsva_iv".}
proc hsva_bv*(hsva: ptr char): color {.importc: "nk_hsva_bv".}
proc hsva_f*(h: float32; s: float32; v: float32; a: float32): color {.importc: "nk_hsva_f".}
proc hsva_fv*(hsva: ptr float32): color {.importc: "nk_hsva_fv".}
proc newColorf*(r: ptr float32; g: ptr float32; b: ptr float32; a: ptr float32; a6: color) {. importc: "nk_color_f".}
proc colorfv*(rgba_out: ptr float32; a3: color) {.importc: "nk_color_fv".}
proc color_d*(r: ptr cdouble; g: ptr cdouble; b: ptr cdouble; a: ptr cdouble; a6: color) {. importc: "nk_color_d".}
proc color_dv*(rgba_out: ptr cdouble; a3: color) {.importc: "nk_color_dv".}
proc color_u32*(a2: color): uint32 {.importc: "nk_color_u32".}
proc color_hex_rgba*(output: cstring; a3: color) {.importc: "nk_color_hex_rgba".}
proc color_hex_rgb*(output: cstring; a3: color) {.importc: "nk_color_hex_rgb".}
proc color_hsv_i*(out_h: ptr int32; out_s: ptr int32; out_v: ptr int32; a5: color) {. importc: "nk_color_hsv_i".}
proc color_hsv_b*(out_h: ptr char; out_s: ptr char; out_v: ptr char;
                    a5: color) {.importc: "nk_color_hsv_b".}
proc color_hsv_iv*(hsv_out: ptr int32; a3: color) {.importc: "nk_color_hsv_iv".}
proc color_hsv_bv*(hsv_out: ptr char; a3: color) {.importc: "nk_color_hsv_bv".}
proc color_hsv_f*(out_h: ptr float32; out_s: ptr float32; out_v: ptr float32; a5: color) {. importc: "nk_color_hsv_f".}
proc color_hsv_fv*(hsv_out: ptr float32; a3: color) {.importc: "nk_color_hsv_fv".}
proc color_hsva_i*(h: ptr int32; s: ptr int32; v: ptr int32; a: ptr int32; a6: color) {. importc: "nk_color_hsva_i".}
proc color_hsva_b*(h: ptr char; s: ptr char; v: ptr char; a: ptr char;
                     a6: color) {.importc: "nk_color_hsva_b".}
proc color_hsva_iv*(hsva_out: ptr int32; a3: color) {.importc: "nk_color_hsva_iv".}
proc color_hsva_bv*(hsva_out: ptr char; a3: color) {.importc: "nk_color_hsva_bv".}
proc color_hsva_f*(out_h: ptr float32; out_s: ptr float32; out_v: ptr float32;
                     out_a: ptr float32; a6: color) {.importc: "nk_color_hsva_f".}
proc color_hsva_fv*(hsva_out: ptr float32; a3: color) {.importc: "nk_color_hsva_fv".}
proc handle_ptr*(a2: pointer): handle {.importc: "nk_handle_ptr".}
proc handle_id*(a2: int32): handle {.importc: "nk_handle_id".}
proc image_handle*(a2: handle): img {.importc: "nk_image_handle".}
proc image_ptr*(a2: pointer): img {.importc: "nk_image_ptr".}
proc image_id*(a2: int32): img {.importc: "nk_image_id".}
proc image_is_subimage*(i: ptr img): int32 {.importc: "nk_image_is_subimage".}
proc subimage_ptr*(a2: pointer; w: uint16; h: uint16; sub_region: rect): img {. importc: "nk_subimage_ptr".}
proc subimage_id*(a2: int32; w: uint16; h: uint16; sub_region: rect): img {. importc: "nk_subimage_id".}
proc subimage_handle*(a2: handle; w: uint16; h: uint16; sub_region: rect): img {. importc: "nk_subimage_handle".}
proc murmur_hash*(key: pointer; len: int32; seed: uint32): uint32 {.importc: "nk_murmur_hash".}
proc triangle_from_direction*(result: ptr vec2; r: rect; pad_x: float32;
                                pad_y: float32; a6: heading) {.importc: "nk_triangle_from_direction".}
proc newVec2*(x: float32; y: float32): vec2 {.importc: "nk_vec2".}
proc newVec2i*(x: int32; y: int32): vec2 {.importc: "nk_vec2i".}
proc vec2v*(xy: ptr float32): vec2 {.importc: "nk_vec2v".}
proc vec2iv*(xy: ptr int32): vec2 {.importc: "nk_vec2iv".}
proc get_null_rect*(): rect {.importc: "nk_get_null_rect".}
proc newRect*(x: float32; y: float32; w: float32; h: float32): rect {.importc: "nk_rect".}
proc newRecti*(x: int32; y: int32; w: int32; h: int32): rect {.importc: "nk_recti".}
proc recta*(pos: vec2; size: vec2): rect {.importc: "nk_recta".}
proc rectv*(xywh: ptr float32): rect {.importc: "nk_rectv".}
proc rectiv*(xywh: ptr int32): rect {.importc: "nk_rectiv".}
proc rect_pos*(a2: rect): vec2 {.importc: "nk_rect_pos".}
proc rect_size*(a2: rect): vec2 {.importc: "nk_rect_size".}
proc strlen*(str: cstring): int32 {.importc: "nk_strlen".}
proc stricmp*(s1: cstring; s2: cstring): int32 {.importc: "nk_stricmp".}
proc stricmpn*(s1: cstring; s2: cstring; n: int32): int32 {.importc: "nk_stricmpn".}
proc strtoi*(str: cstring; endptr: cstringArray): int32 {.importc: "nk_strtoi".}
proc strtof*(str: cstring; endptr: cstringArray): float32 {.importc: "nk_strtof".}
proc strtod*(str: cstring; endptr: cstringArray): cdouble {.importc: "nk_strtod".}
proc strfilter*(text: cstring; regexp: cstring): int32 {.importc: "nk_strfilter".}
proc strmatch_fuzzy_string*(str: cstring; pattern: cstring; out_score: ptr int32): int32 {. importc: "nk_strmatch_fuzzy_string".}
proc strmatch_fuzzy_text*(txt: cstring; txt_len: int32; pattern: cstring;
                            out_score: ptr int32): int32 {.importc: "nk_strmatch_fuzzy_text".}
proc utf_decode*(a2: cstring; a3: ptr uint32; a4: int32): int32 {.importc: "nk_utf_decode".}
proc utf_encode*(a2: uint32; a3: cstring; a4: int32): int32 {.importc: "nk_utf_encode".}
proc utf_len*(a2: cstring; byte_len: int32): int32 {.importc: "nk_utf_len".}
proc utf_at*(buffer: cstring; length: int32; index: int32; unicode: ptr uint32;
               len: ptr int32): cstring {.importc: "nk_utf_at".}


type
  baked_font* = object
    height*: float32
    ascent*: float32
    descent*: float32
    glyph_offset*: uint32
    glyph_count*: uint32
    ranges*: ptr uint32

  font_config* = object
    next*: ptr font_config
    ttf_blob*: pointer
    ttf_size*: uint
    ttf_data_owned_by_atlas*: cuchar
    merge_mode*: cuchar
    pixel_snap*: cuchar
    oversample_v*: cuchar
    oversample_h*: cuchar
    padding*: array[3, cuchar]
    size*: float32
    coord_type*: font_coord_type
    spacing*: vec2
    range*: ptr uint32
    font*: ptr baked_font
    fallback_glyph*: uint32

  font_glyph* = object
    codepoint*: uint32
    xadvance*: float32
    x0*: float32
    y0*: float32
    x1*: float32
    y1*: float32
    w*: float32
    h*: float32
    u0*: float32
    v0*: float32
    u1*: float32
    v1*: float32

  font* = object
    next*: ptr font
    handle*: user_font
    info*: baked_font
    scale*: float32
    glyphs*: ptr font_glyph
    fallback*: ptr font_glyph
    fallback_codepoint*: uint32
    texture*: handle
    config*: ptr font_config

  font_atlas_format* {.size: sizeof(int32).} = enum
    FONT_ATLAS_ALPHA8, FONT_ATLAS_RGBA32


type
  font_atlas* = object
    pixel*: pointer
    tex_width*: int32
    tex_height*: int32
    permanent*: allocator
    temporary*: allocator
    custom*: recti
    cursors*: array[CURSOR_COUNT, cursor]
    glyph_count*: int32
    glyphs*: ptr font_glyph
    default_font*: ptr font
    fonts*: ptr font
    config*: ptr font_config
    font_num*: int32


proc font_default_glyph_ranges*(): ptr uint32 {.importc: "nk_font_default_glyph_ranges".}
proc font_chinese_glyph_ranges*(): ptr uint32 {.importc: "nk_font_chinese_glyph_ranges".}
proc font_cyrillic_glyph_ranges*(): ptr uint32 {.importc: "nk_font_cyrillic_glyph_ranges".}
proc font_korean_glyph_ranges*(): ptr uint32 {.importc: "nk_font_korean_glyph_ranges".}
proc font_atlas_init_default*(a2: ptr font_atlas) {.importc: "nk_font_atlas_init_default".}
proc font_atlas_init*(a2: ptr font_atlas; a3: ptr allocator) {.importc: "nk_font_atlas_init".}
proc font_atlas_init_custom*(a2: ptr font_atlas; persistent: ptr allocator;
                               transient: ptr allocator) {.importc: "nk_font_atlas_init_custom".}
proc font_atlas_begin*(a2: ptr font_atlas) {.importc: "nk_font_atlas_begin".}
proc font_atlas_add*(a2: ptr font_atlas; a3: ptr font_config): ptr font {. importc: "nk_font_atlas_add".}
proc font_atlas_add_from_memory*(atlas: ptr font_atlas; memory: pointer;
                                   size: uint; height: float32;
                                   config: ptr font_config): ptr font {.importc: "nk_font_atlas_add_from_memory".}
proc font_atlas_add_compressed*(a2: ptr font_atlas; memory: pointer;
                                  size: uint; height: float32;
                                  a6: ptr font_config): ptr font {.importc: "nk_font_atlas_add_compressed".}
proc addCompressed*(atlas: var font_atlas, memory: pointer, size: uint, height: float32, config: var font_config) : font =
  font_atlas_add_compressed(addr atlas, memory, size, height, addr config)[]

proc font_atlas_add_compressed_base85(a2: ptr font_atlas; data: cstring;
    height: float32; config: ptr font_config): ptr font {.importc: "nk_font_atlas_add_compressed_base85".}
proc addCompressedBase85*(atlas: var font_atlas, data: string, height: float32, config: var font_config): font =
  font_atlas_add_compressed_base85(addr atlas, data, height, addr config)[]

proc font_atlas_bake(a2: ptr font_atlas; width: ptr int32; height: ptr int32;
                        a5: font_atlas_format): pointer {.importc: "nk_font_atlas_bake".}
proc bake*(atlas: var font_atlas, width, height: var int32, format: font_atlas_format): pointer =
  font_atlas_bake(addr atlas, addr width, addr height, format)

proc font_atlas_end(a2: ptr font_atlas; tex: handle;
                       a4: ptr draw_null_texture) {.importc: "nk_font_atlas_end".}
proc `end`*(atlas: var font_atlas, tex: handle, null: var draw_null_texture) =
  font_atlas_end(addr atlas, tex, addr null)

proc font_find_glyph(a2: ptr font; unicode: uint32): ptr font_glyph {.importc: "nk_font_find_glyph".}
proc findGlyph*(f: var font, unicode: uint32): font_glyph =
  font_find_glyph(addr f, unicode)[]

proc font_atlas_cleanup(atlas: ptr font_atlas) {.importc: "nk_font_atlas_cleanup".}
proc cleanup*(atlas: var font_atlas) =
  font_atlas_cleanup(addr atlas)

proc font_atlas_clear(a2: ptr font_atlas) {.importc: "nk_font_atlas_clear".}
proc clear*(atlas: var font_atlas) =
  font_atlas_clear(addr atlas)

proc font_atlas_add_default(a2: ptr font_atlas; height: float32;
                               a4: ptr font_config): ptr font {.importc: "nk_font_atlas_add_default".}
proc add*(atlas: var font_atlas, height: float32, fontConfig: var font_config): font =
  font_atlas_add_default(addr atlas, height, addr fontConfig)[]

proc font_atlas_add_from_file*(atlas: ptr font_atlas; file_path: cstring;
                                 height: float32; a5: ptr font_config): ptr font {.importc: "nk_font_atlas_add_from_file".}
proc addFromFile*(atlas: var font_atlas, filePath: string, height: float32, fontConfig: var font_config): font =
  font_atlas_add_from_file(addr atlas, filePath, height, addr fontConfig)[]
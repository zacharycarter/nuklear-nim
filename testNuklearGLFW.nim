import glfw3 as glfw, opengl

var win : glfw.Window

const WINDOW_WIDTH = 800
const WINDOW_HEIGHT = 600

var width, height : cint

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


while glfw.WindowShouldClose(win) == 0:
  glfw.PollEvents();

  glfw.SwapBuffers(win);
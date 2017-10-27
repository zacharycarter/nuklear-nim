# nuklear-nim
These are Nim bindings to the Nuklear Immediate Mode GUI library : https://github.com/vurtun/nuklear/ 

## Working Examples

* [GLFW + OpenGL](https://github.com/zacharycarter/nuklear-nim/blob/master/examples/nuklear_nim_examples/glfw3_opengl3.nim)
* [SDL2 + OpenGL](https://github.com/zacharycarter/nuklear-nim/blob/master/examples/nuklear_nim_examples/sdl2_opengl3.nim)

To build the examples, you need to update the Nuklear submodule and install necessary Nim libraries (either GLFW or SDL2).

The commands ``git submodule init`` and ``git sumbodule update`` should get you an up-to-date copy of ``nuklear.h``.

## Screenshots

![nuklear-nim](http://i.imgur.com/70pnfMP.png)

This repository is a WIP and will be undergoing heavy changes. The bindings should be relatively stable - 
some more functionality from Nuklear will be added over time.

If you notice anything missing / not working / have suggestions for improvement, please submit an issue or pull request for review.

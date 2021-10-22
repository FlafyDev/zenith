
#include <assert.h>
#include <chrono>
#include "embedder.h"
#include <GLFW/glfw3.h>
#include <iostream>

static_assert(FLUTTER_ENGINE_VERSION == 1, "");

static const size_t kInitialWindowWidth = 800;
static const size_t kInitialWindowHeight = 600;

void GLFWcursorPositionCallbackAtPhase(GLFWwindow *window,
                                       FlutterPointerPhase phase, double x,
                                       double y) {
  FlutterPointerEvent event = {};
  event.struct_size = sizeof(event);
  event.phase = phase;
  event.x = x;
  event.y = y;
  event.timestamp =
      std::chrono::duration_cast<std::chrono::microseconds>(
          std::chrono::high_resolution_clock::now().time_since_epoch())
          .count();
  FlutterEngineSendPointerEvent(
      reinterpret_cast<FlutterEngine>(glfwGetWindowUserPointer(window)), &event,
      1);
}

void GLFWcursorPositionCallback(GLFWwindow *window, double x, double y) {
  GLFWcursorPositionCallbackAtPhase(window, FlutterPointerPhase::kMove, x, y);
}

void GLFWmouseButtonCallback(GLFWwindow *window, int key, int action,
                             int mods) {
  if (key == GLFW_MOUSE_BUTTON_1 && action == GLFW_PRESS) {
    double x, y;
    glfwGetCursorPos(window, &x, &y);
    GLFWcursorPositionCallbackAtPhase(window, FlutterPointerPhase::kDown, x, y);
    glfwSetCursorPosCallback(window, GLFWcursorPositionCallback);
  }

  if (key == GLFW_MOUSE_BUTTON_1 && action == GLFW_RELEASE) {
    double x, y;
    glfwGetCursorPos(window, &x, &y);
    GLFWcursorPositionCallbackAtPhase(window, FlutterPointerPhase::kUp, x, y);
    glfwSetCursorPosCallback(window, nullptr);
  }
}

static void GLFWKeyCallback(GLFWwindow *window, int key, int scancode,
                            int action, int mods) {
  if (key == GLFW_KEY_ESCAPE && action == GLFW_PRESS) {
    glfwSetWindowShouldClose(window, GLFW_TRUE);
  }
}

void GLFWwindowSizeCallback(GLFWwindow *window, int width, int height) {
  FlutterWindowMetricsEvent event = {};
  event.struct_size = sizeof(event);
  event.width = width;
  event.height = height;

  std::cout << width << std::endl;
  std::cout << height << std::endl;

  event.pixel_ratio = 1.0;
  FlutterEngineSendWindowMetricsEvent(
      reinterpret_cast<FlutterEngine>(glfwGetWindowUserPointer(window)),
      &event);
}

bool RunFlutter(GLFWwindow *window) {
  FlutterRendererConfig config = {};
  config.type = kOpenGL;
  config.open_gl.struct_size = sizeof(config.open_gl);
  config.open_gl.make_current = [](void *userdata) -> bool {
    glfwMakeContextCurrent((GLFWwindow *)userdata);
    return true;
  };
  config.open_gl.clear_current = [](void *) -> bool {
    glfwMakeContextCurrent(nullptr); // is this even a thing?
    return true;
  };
  config.open_gl.present = [](void *userdata) -> bool {
    glfwSwapBuffers((GLFWwindow *)userdata);
    return true;
  };
  config.open_gl.fbo_callback = [](void *) -> uint32_t {
    return 0; // FBO0
  };

#define MY_PROJECT "/home/roscale/CLionProjects/flutter_embedder/data"
  FlutterProjectArgs args = {
      .struct_size = sizeof(FlutterProjectArgs),
      .assets_path = MY_PROJECT "/flutter_assets", // This directory is generated by `flutter build bundle`
      .icu_data_path = MY_PROJECT "/icudtl.dat", // Find this in your bin/cache directory.
  };
  FlutterEngine engine = nullptr;
  auto result = FlutterEngineRun(FLUTTER_ENGINE_VERSION, &config, // renderer
                                 &args, window, &engine);
  assert(result == kSuccess && engine != nullptr);

  glfwSetWindowUserPointer(window, engine);

  GLFWwindowSizeCallback(window, kInitialWindowWidth, kInitialWindowHeight);

  return true;
}

int main(int argc, const char *argv[]) {

  auto result = glfwInit();
  assert(result == GLFW_TRUE);

  auto window = glfwCreateWindow(kInitialWindowWidth, kInitialWindowHeight,
                                 "Flutter", NULL, NULL);
  assert(window != nullptr);

  bool runResult = RunFlutter(window);
  assert(runResult);

  glfwSetKeyCallback(window, GLFWKeyCallback);

  glfwSetWindowSizeCallback(window, GLFWwindowSizeCallback);

  glfwSetMouseButtonCallback(window, GLFWmouseButtonCallback);

  while (!glfwWindowShouldClose(window)) {
//    std::cout << "Looping..." << std::endl;
    glfwWaitEvents();
  }

  glfwDestroyWindow(window);
  glfwTerminate();

  return EXIT_SUCCESS;
}
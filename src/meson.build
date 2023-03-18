globber = run_command('find', '.', '-name', '*.cpp', '-o', '-name', '*.cc', check: true)
src = globber.stdout().strip().split('\n')

incdirs = [
  include_directories('third_party'),
  include_directories('third_party/rapidjson/include'),
] 

executable('zenith', src,
  include_directories: incdirs,
  cpp_args: [
    '-DWLR_USE_UNSTABLE', 
    '-O',
    '-MMD',
    '-MP',
    '-g',
  ],
  build_rpath: '$ORIGIN/lib',
  install_rpath: '$ORIGIN/../lib',
  install: true,
  dependencies: [
    dependency(f'libflutter-engine-@type@'),
    dependency('wayland-server'),
    dependency('wayland-client'),
    dependency('wlroots'),
    dependency('xkbcommon'),
    dependency('libinput'),
    dependency('epoxy'),
    dependency('pixman-1'),
    dependency('egl'),
    dependency('pam'),
    dependency('libdrm'),
    dependency('gl', 'opengl'),
  ],
)

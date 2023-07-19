globber = run_command('find', '.', '-name', '*.cpp', '-o', '-name', '*.cc', check: true)
src = globber.stdout().strip().split('\n')

incdirs = [
  include_directories('third_party'),
  include_directories('third_party/rapidjson/include'),
] 


if type == 'debug'
  typeArg = '-DDEBUG'
elif type == 'profile'
  typeArg = '-DPROFILE'
elif type == 'release'
  typeArg = '-DRELEASE'
endif

executable('zenith', src,
  include_directories: incdirs,
  cpp_args: [
    '-DWLR_USE_UNSTABLE', 
    typeArg,
    '-O',
    # '-MMD',
    # '-MP',
    '-g',
  ],
  override_options : ['c_std=c20'],
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

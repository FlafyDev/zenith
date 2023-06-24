project('Zenith', 'cpp', 'c',
  version: run_command('yq', '.version', join_paths(meson.source_root(), 'pubspec.yaml'), check: true).stdout().strip(),
)
version = meson.project_version()
type = 'debug'

fs = import('fs')

flutter_root = fs.parent(fs.parent(find_program('flutter', required: true).full_path()))

if not fs.exists('.dart_tool')
  run_command('flutter', 'pub', 'get', check: true)
endif
meson.add_install_script('meson/install_assets.sh', type)
install_data(join_paths(dependency(f'libflutter-engine-@type@').get_pkgconfig_variable('libdir'), f'libflutter_engine_@type@.so'), install_dir: 'lib', rename: 'libflutter_engine.so')

subdir('src')


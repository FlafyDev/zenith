project('Zenith', 'cpp', 'c',
  version: run_command('yq', '.version', join_paths(meson.source_root(), 'pubspec.yaml'), check: true).stdout().strip(),
)
version = meson.project_version()
type = 'release'

fs = import('fs')

flutter_root = fs.parent(fs.parent(find_program('flutter', required: true).full_path()))
# flutter_engine_revision = run_command('meson/flutter_engine_revision.sh', check: true).stdout().strip()
# message(flutter_engine_revision)

if not fs.exists('.dart_tool')
  run_command('flutter', 'pub', 'get', check: true)
endif
meson.add_install_script('meson/install_assets.sh', type)
install_data(join_paths(dependency(f'libflutter-engine-@type@').get_pkgconfig_variable('libdir'), f'libflutter_engine_@type@.so'), install_dir: 'lib', rename: 'libflutter_engine.so')


# arch = 'x64'
# 
# flutter_engine_name = f'libflutter_engine_@type@_@arch@_@flutter_engine_revision@.so'
# 
# flutter_engine = custom_target('flutter_engine',
#   output: [ flutter_engine_name ],
#   command: [
#     'meson/download_flutter_engine.sh',
#     flutter_engine_revision,
#     arch,
#     type,
#   ],
#   build_by_default: true,
# )

# install_data(flutter_engine.full_path(), install_dir: 'lib', rename: 'libflutter_engine.so')

# custom_target('assets',
#   command: [
#     join_paths(flutter_root, 'packages/flutter_tools/bin/tool_backend.sh'),
#     'linux-x64',
#     'debug',
#   ],
#   env: {
#     'FLUTTER_ROOT': flutter_root,
#     'PROJECT_DIR': meson.source_root(),
#     'DART_OBFUSCATION': 'false',
#     'TRACK_WIDGET_CREATION': 'true',
#     'TREE_SHAKE_ICONS': 'false',
#     'VERBOSE_SCRIPT_LOGGING': 'true',
#     'PACKAGE_CONFIG': join_paths(meson.source_root(), '.dart_tool/package_config.json'),
#     'FLUTTER_TARGET': 'lib/main.dart',
#   },
#   build_always_stale: true,
#   build_by_default: true,
#   # install: true,
#   # install_dir: join_paths('lib', 'flutter_assets'),
#   output: ['build', 'linux/flutter/ephemeral/icudtl.dat'],
# )


# install_subdir('build/flutter_assets', install_dir: 'data')
# install_data('linux/flutter/ephemeral/icudtl.dat', install_dir: 'data')

# run_command('flutter', 'pub', 'get', check: true)
# run_command(join_paths(flutter_root, 'packages/flutter_tools/bin/tool_backend.sh'), 'linux-x64', 'debug', env: {
#   'FLUTTER_ROOT': flutter_root,
#   'PROJECT_DIR': meson.source_root(),
#   'DART_OBFUSCATION': 'false',
#   'TRACK_WIDGET_CREATION': 'true',
#   'TREE_SHAKE_ICONS': 'false',
#   'VERBOSE_SCRIPT_LOGGING': 'true',
#   'PACKAGE_CONFIG': join_paths(meson.source_root(), '.dart_tool/package_config.json'),
#   'FLUTTER_TARGET': 'lib/main.dart',
# }, check: true)
# 
# install_subdir('build/flutter_assets', install_dir: join_paths(get_option('prefix'), 'share', 'zenith'))

# run_command('cp', '-r', join_paths(meson.source_root(), 'build/flutter_assets'), join_paths(meson.source_root(), 'build/'), check: true)
# run_command('rm', '-rf', join_paths(meson.source_root(), 'build'), check: true)
# run_command('')


subdir('src')


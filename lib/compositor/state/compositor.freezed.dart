// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'compositor.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$Compositor {
  Map<int, SurfaceCommitState> get surfacesState =>
      throw _privateConstructorUsedError;
  List<int> get mappedXdgSurfaces => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CompositorCopyWith<Compositor> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompositorCopyWith<$Res> {
  factory $CompositorCopyWith(
          Compositor value, $Res Function(Compositor) then) =
      _$CompositorCopyWithImpl<$Res, Compositor>;
  @useResult
  $Res call(
      {Map<int, SurfaceCommitState> surfacesState,
      List<int> mappedXdgSurfaces});
}

/// @nodoc
class _$CompositorCopyWithImpl<$Res, $Val extends Compositor>
    implements $CompositorCopyWith<$Res> {
  _$CompositorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? surfacesState = null,
    Object? mappedXdgSurfaces = null,
  }) {
    return _then(_value.copyWith(
      surfacesState: null == surfacesState
          ? _value.surfacesState
          : surfacesState // ignore: cast_nullable_to_non_nullable
              as Map<int, SurfaceCommitState>,
      mappedXdgSurfaces: null == mappedXdgSurfaces
          ? _value.mappedXdgSurfaces
          : mappedXdgSurfaces // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_CompositorCopyWith<$Res>
    implements $CompositorCopyWith<$Res> {
  factory _$$_CompositorCopyWith(
          _$_Compositor value, $Res Function(_$_Compositor) then) =
      __$$_CompositorCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Map<int, SurfaceCommitState> surfacesState,
      List<int> mappedXdgSurfaces});
}

/// @nodoc
class __$$_CompositorCopyWithImpl<$Res>
    extends _$CompositorCopyWithImpl<$Res, _$_Compositor>
    implements _$$_CompositorCopyWith<$Res> {
  __$$_CompositorCopyWithImpl(
      _$_Compositor _value, $Res Function(_$_Compositor) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? surfacesState = null,
    Object? mappedXdgSurfaces = null,
  }) {
    return _then(_$_Compositor(
      surfacesState: null == surfacesState
          ? _value._surfacesState
          : surfacesState // ignore: cast_nullable_to_non_nullable
              as Map<int, SurfaceCommitState>,
      mappedXdgSurfaces: null == mappedXdgSurfaces
          ? _value._mappedXdgSurfaces
          : mappedXdgSurfaces // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ));
  }
}

/// @nodoc

class _$_Compositor implements _Compositor {
  const _$_Compositor(
      {required final Map<int, SurfaceCommitState> surfacesState,
      required final List<int> mappedXdgSurfaces})
      : _surfacesState = surfacesState,
        _mappedXdgSurfaces = mappedXdgSurfaces;

  final Map<int, SurfaceCommitState> _surfacesState;
  @override
  Map<int, SurfaceCommitState> get surfacesState {
    if (_surfacesState is EqualUnmodifiableMapView) return _surfacesState;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_surfacesState);
  }

  final List<int> _mappedXdgSurfaces;
  @override
  List<int> get mappedXdgSurfaces {
    if (_mappedXdgSurfaces is EqualUnmodifiableListView)
      return _mappedXdgSurfaces;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mappedXdgSurfaces);
  }

  @override
  String toString() {
    return 'Compositor(surfacesState: $surfacesState, mappedXdgSurfaces: $mappedXdgSurfaces)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Compositor &&
            const DeepCollectionEquality()
                .equals(other._surfacesState, _surfacesState) &&
            const DeepCollectionEquality()
                .equals(other._mappedXdgSurfaces, _mappedXdgSurfaces));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_surfacesState),
      const DeepCollectionEquality().hash(_mappedXdgSurfaces));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CompositorCopyWith<_$_Compositor> get copyWith =>
      __$$_CompositorCopyWithImpl<_$_Compositor>(this, _$identity);
}

abstract class _Compositor implements Compositor {
  const factory _Compositor(
      {required final Map<int, SurfaceCommitState> surfacesState,
      required final List<int> mappedXdgSurfaces}) = _$_Compositor;

  @override
  Map<int, SurfaceCommitState> get surfacesState;
  @override
  List<int> get mappedXdgSurfaces;
  @override
  @JsonKey(ignore: true)
  _$$_CompositorCopyWith<_$_Compositor> get copyWith =>
      throw _privateConstructorUsedError;
}

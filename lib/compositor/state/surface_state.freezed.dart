// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'surface_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$SurfaceState {
  SurfaceRole get role => throw _privateConstructorUsedError;
  int get textureId => throw _privateConstructorUsedError;
  Rect get rect => throw _privateConstructorUsedError;
  int get scale => throw _privateConstructorUsedError;
  List<SubsurfaceState> get subsurfacesBelow =>
      throw _privateConstructorUsedError;
  List<SubsurfaceState> get subsurfacesAbove =>
      throw _privateConstructorUsedError;
  Rect get inputRegion => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SurfaceStateCopyWith<SurfaceState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SurfaceStateCopyWith<$Res> {
  factory $SurfaceStateCopyWith(
          SurfaceState value, $Res Function(SurfaceState) then) =
      _$SurfaceStateCopyWithImpl<$Res, SurfaceState>;
  @useResult
  $Res call(
      {SurfaceRole role,
      int textureId,
      Rect rect,
      int scale,
      List<SubsurfaceState> subsurfacesBelow,
      List<SubsurfaceState> subsurfacesAbove,
      Rect inputRegion});
}

/// @nodoc
class _$SurfaceStateCopyWithImpl<$Res, $Val extends SurfaceState>
    implements $SurfaceStateCopyWith<$Res> {
  _$SurfaceStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? role = null,
    Object? textureId = null,
    Object? rect = freezed,
    Object? scale = null,
    Object? subsurfacesBelow = null,
    Object? subsurfacesAbove = null,
    Object? inputRegion = freezed,
  }) {
    return _then(_value.copyWith(
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as SurfaceRole,
      textureId: null == textureId
          ? _value.textureId
          : textureId // ignore: cast_nullable_to_non_nullable
              as int,
      rect: freezed == rect
          ? _value.rect
          : rect // ignore: cast_nullable_to_non_nullable
              as Rect,
      scale: null == scale
          ? _value.scale
          : scale // ignore: cast_nullable_to_non_nullable
              as int,
      subsurfacesBelow: null == subsurfacesBelow
          ? _value.subsurfacesBelow
          : subsurfacesBelow // ignore: cast_nullable_to_non_nullable
              as List<SubsurfaceState>,
      subsurfacesAbove: null == subsurfacesAbove
          ? _value.subsurfacesAbove
          : subsurfacesAbove // ignore: cast_nullable_to_non_nullable
              as List<SubsurfaceState>,
      inputRegion: freezed == inputRegion
          ? _value.inputRegion
          : inputRegion // ignore: cast_nullable_to_non_nullable
              as Rect,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_SurfaceStateCopyWith<$Res>
    implements $SurfaceStateCopyWith<$Res> {
  factory _$$_SurfaceStateCopyWith(
          _$_SurfaceState value, $Res Function(_$_SurfaceState) then) =
      __$$_SurfaceStateCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {SurfaceRole role,
      int textureId,
      Rect rect,
      int scale,
      List<SubsurfaceState> subsurfacesBelow,
      List<SubsurfaceState> subsurfacesAbove,
      Rect inputRegion});
}

/// @nodoc
class __$$_SurfaceStateCopyWithImpl<$Res>
    extends _$SurfaceStateCopyWithImpl<$Res, _$_SurfaceState>
    implements _$$_SurfaceStateCopyWith<$Res> {
  __$$_SurfaceStateCopyWithImpl(
      _$_SurfaceState _value, $Res Function(_$_SurfaceState) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? role = null,
    Object? textureId = null,
    Object? rect = freezed,
    Object? scale = null,
    Object? subsurfacesBelow = null,
    Object? subsurfacesAbove = null,
    Object? inputRegion = freezed,
  }) {
    return _then(_$_SurfaceState(
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as SurfaceRole,
      textureId: null == textureId
          ? _value.textureId
          : textureId // ignore: cast_nullable_to_non_nullable
              as int,
      rect: freezed == rect
          ? _value.rect
          : rect // ignore: cast_nullable_to_non_nullable
              as Rect,
      scale: null == scale
          ? _value.scale
          : scale // ignore: cast_nullable_to_non_nullable
              as int,
      subsurfacesBelow: null == subsurfacesBelow
          ? _value._subsurfacesBelow
          : subsurfacesBelow // ignore: cast_nullable_to_non_nullable
              as List<SubsurfaceState>,
      subsurfacesAbove: null == subsurfacesAbove
          ? _value._subsurfacesAbove
          : subsurfacesAbove // ignore: cast_nullable_to_non_nullable
              as List<SubsurfaceState>,
      inputRegion: freezed == inputRegion
          ? _value.inputRegion
          : inputRegion // ignore: cast_nullable_to_non_nullable
              as Rect,
    ));
  }
}

/// @nodoc

class _$_SurfaceState implements _SurfaceState {
  const _$_SurfaceState(
      {required this.role,
      required this.textureId,
      required this.rect,
      required this.scale,
      required final List<SubsurfaceState> subsurfacesBelow,
      required final List<SubsurfaceState> subsurfacesAbove,
      required this.inputRegion})
      : _subsurfacesBelow = subsurfacesBelow,
        _subsurfacesAbove = subsurfacesAbove;

  @override
  final SurfaceRole role;
  @override
  final int textureId;
  @override
  final Rect rect;
  @override
  final int scale;
  final List<SubsurfaceState> _subsurfacesBelow;
  @override
  List<SubsurfaceState> get subsurfacesBelow {
    if (_subsurfacesBelow is EqualUnmodifiableListView)
      return _subsurfacesBelow;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subsurfacesBelow);
  }

  final List<SubsurfaceState> _subsurfacesAbove;
  @override
  List<SubsurfaceState> get subsurfacesAbove {
    if (_subsurfacesAbove is EqualUnmodifiableListView)
      return _subsurfacesAbove;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subsurfacesAbove);
  }

  @override
  final Rect inputRegion;

  @override
  String toString() {
    return 'SurfaceState(role: $role, textureId: $textureId, rect: $rect, scale: $scale, subsurfacesBelow: $subsurfacesBelow, subsurfacesAbove: $subsurfacesAbove, inputRegion: $inputRegion)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_SurfaceState &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.textureId, textureId) ||
                other.textureId == textureId) &&
            const DeepCollectionEquality().equals(other.rect, rect) &&
            (identical(other.scale, scale) || other.scale == scale) &&
            const DeepCollectionEquality()
                .equals(other._subsurfacesBelow, _subsurfacesBelow) &&
            const DeepCollectionEquality()
                .equals(other._subsurfacesAbove, _subsurfacesAbove) &&
            const DeepCollectionEquality()
                .equals(other.inputRegion, inputRegion));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      role,
      textureId,
      const DeepCollectionEquality().hash(rect),
      scale,
      const DeepCollectionEquality().hash(_subsurfacesBelow),
      const DeepCollectionEquality().hash(_subsurfacesAbove),
      const DeepCollectionEquality().hash(inputRegion));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_SurfaceStateCopyWith<_$_SurfaceState> get copyWith =>
      __$$_SurfaceStateCopyWithImpl<_$_SurfaceState>(this, _$identity);
}

abstract class _SurfaceState implements SurfaceState {
  const factory _SurfaceState(
      {required final SurfaceRole role,
      required final int textureId,
      required final Rect rect,
      required final int scale,
      required final List<SubsurfaceState> subsurfacesBelow,
      required final List<SubsurfaceState> subsurfacesAbove,
      required final Rect inputRegion}) = _$_SurfaceState;

  @override
  SurfaceRole get role;
  @override
  int get textureId;
  @override
  Rect get rect;
  @override
  int get scale;
  @override
  List<SubsurfaceState> get subsurfacesBelow;
  @override
  List<SubsurfaceState> get subsurfacesAbove;
  @override
  Rect get inputRegion;
  @override
  @JsonKey(ignore: true)
  _$$_SurfaceStateCopyWith<_$_SurfaceState> get copyWith =>
      throw _privateConstructorUsedError;
}

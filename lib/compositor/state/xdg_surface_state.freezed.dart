// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'xdg_surface_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$XdgSurfaceState {
  XdgSurfaceRole get role => throw _privateConstructorUsedError;
  Rect get rect => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $XdgSurfaceStateCopyWith<XdgSurfaceState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $XdgSurfaceStateCopyWith<$Res> {
  factory $XdgSurfaceStateCopyWith(
          XdgSurfaceState value, $Res Function(XdgSurfaceState) then) =
      _$XdgSurfaceStateCopyWithImpl<$Res, XdgSurfaceState>;
  @useResult
  $Res call({XdgSurfaceRole role, Rect rect});
}

/// @nodoc
class _$XdgSurfaceStateCopyWithImpl<$Res, $Val extends XdgSurfaceState>
    implements $XdgSurfaceStateCopyWith<$Res> {
  _$XdgSurfaceStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? role = null,
    Object? rect = freezed,
  }) {
    return _then(_value.copyWith(
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as XdgSurfaceRole,
      rect: freezed == rect
          ? _value.rect
          : rect // ignore: cast_nullable_to_non_nullable
              as Rect,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_XdgSurfaceStateCopyWith<$Res>
    implements $XdgSurfaceStateCopyWith<$Res> {
  factory _$$_XdgSurfaceStateCopyWith(
          _$_XdgSurfaceState value, $Res Function(_$_XdgSurfaceState) then) =
      __$$_XdgSurfaceStateCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({XdgSurfaceRole role, Rect rect});
}

/// @nodoc
class __$$_XdgSurfaceStateCopyWithImpl<$Res>
    extends _$XdgSurfaceStateCopyWithImpl<$Res, _$_XdgSurfaceState>
    implements _$$_XdgSurfaceStateCopyWith<$Res> {
  __$$_XdgSurfaceStateCopyWithImpl(
      _$_XdgSurfaceState _value, $Res Function(_$_XdgSurfaceState) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? role = null,
    Object? rect = freezed,
  }) {
    return _then(_$_XdgSurfaceState(
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as XdgSurfaceRole,
      rect: freezed == rect
          ? _value.rect
          : rect // ignore: cast_nullable_to_non_nullable
              as Rect,
    ));
  }
}

/// @nodoc

class _$_XdgSurfaceState implements _XdgSurfaceState {
  const _$_XdgSurfaceState({required this.role, required this.rect});

  @override
  final XdgSurfaceRole role;
  @override
  final Rect rect;

  @override
  String toString() {
    return 'XdgSurfaceState(role: $role, rect: $rect)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_XdgSurfaceState &&
            (identical(other.role, role) || other.role == role) &&
            const DeepCollectionEquality().equals(other.rect, rect));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, role, const DeepCollectionEquality().hash(rect));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_XdgSurfaceStateCopyWith<_$_XdgSurfaceState> get copyWith =>
      __$$_XdgSurfaceStateCopyWithImpl<_$_XdgSurfaceState>(this, _$identity);
}

abstract class _XdgSurfaceState implements XdgSurfaceState {
  const factory _XdgSurfaceState(
      {required final XdgSurfaceRole role,
      required final Rect rect}) = _$_XdgSurfaceState;

  @override
  XdgSurfaceRole get role;
  @override
  Rect get rect;
  @override
  @JsonKey(ignore: true)
  _$$_XdgSurfaceStateCopyWith<_$_XdgSurfaceState> get copyWith =>
      throw _privateConstructorUsedError;
}

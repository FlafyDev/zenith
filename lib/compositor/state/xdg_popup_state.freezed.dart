// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'xdg_popup_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$XdgPopupState {
  int get parentId => throw _privateConstructorUsedError;
  Rect get rect => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $XdgPopupStateCopyWith<XdgPopupState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $XdgPopupStateCopyWith<$Res> {
  factory $XdgPopupStateCopyWith(
          XdgPopupState value, $Res Function(XdgPopupState) then) =
      _$XdgPopupStateCopyWithImpl<$Res, XdgPopupState>;
  @useResult
  $Res call({int parentId, Rect rect});
}

/// @nodoc
class _$XdgPopupStateCopyWithImpl<$Res, $Val extends XdgPopupState>
    implements $XdgPopupStateCopyWith<$Res> {
  _$XdgPopupStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? parentId = null,
    Object? rect = freezed,
  }) {
    return _then(_value.copyWith(
      parentId: null == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as int,
      rect: freezed == rect
          ? _value.rect
          : rect // ignore: cast_nullable_to_non_nullable
              as Rect,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_XdgPopupStateCopyWith<$Res>
    implements $XdgPopupStateCopyWith<$Res> {
  factory _$$_XdgPopupStateCopyWith(
          _$_XdgPopupState value, $Res Function(_$_XdgPopupState) then) =
      __$$_XdgPopupStateCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int parentId, Rect rect});
}

/// @nodoc
class __$$_XdgPopupStateCopyWithImpl<$Res>
    extends _$XdgPopupStateCopyWithImpl<$Res, _$_XdgPopupState>
    implements _$$_XdgPopupStateCopyWith<$Res> {
  __$$_XdgPopupStateCopyWithImpl(
      _$_XdgPopupState _value, $Res Function(_$_XdgPopupState) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? parentId = null,
    Object? rect = freezed,
  }) {
    return _then(_$_XdgPopupState(
      parentId: null == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as int,
      rect: freezed == rect
          ? _value.rect
          : rect // ignore: cast_nullable_to_non_nullable
              as Rect,
    ));
  }
}

/// @nodoc

class _$_XdgPopupState implements _XdgPopupState {
  const _$_XdgPopupState({required this.parentId, required this.rect});

  @override
  final int parentId;
  @override
  final Rect rect;

  @override
  String toString() {
    return 'XdgPopupState(parentId: $parentId, rect: $rect)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_XdgPopupState &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId) &&
            const DeepCollectionEquality().equals(other.rect, rect));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, parentId, const DeepCollectionEquality().hash(rect));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_XdgPopupStateCopyWith<_$_XdgPopupState> get copyWith =>
      __$$_XdgPopupStateCopyWithImpl<_$_XdgPopupState>(this, _$identity);
}

abstract class _XdgPopupState implements XdgPopupState {
  const factory _XdgPopupState(
      {required final int parentId,
      required final Rect rect}) = _$_XdgPopupState;

  @override
  int get parentId;
  @override
  Rect get rect;
  @override
  @JsonKey(ignore: true)
  _$$_XdgPopupStateCopyWith<_$_XdgPopupState> get copyWith =>
      throw _privateConstructorUsedError;
}

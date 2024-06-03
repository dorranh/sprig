// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SprigDetails _$SprigDetailsFromJson(Map<String, dynamic> json) {
  return _SprigDetails.fromJson(json);
}

/// @nodoc
mixin _$SprigDetails {
  String get id => throw _privateConstructorUsedError;
  String get structure => throw _privateConstructorUsedError;
  String get format => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SprigDetailsCopyWith<SprigDetails> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SprigDetailsCopyWith<$Res> {
  factory $SprigDetailsCopyWith(
          SprigDetails value, $Res Function(SprigDetails) then) =
      _$SprigDetailsCopyWithImpl<$Res, SprigDetails>;
  @useResult
  $Res call({String id, String structure, String format, String? name});
}

/// @nodoc
class _$SprigDetailsCopyWithImpl<$Res, $Val extends SprigDetails>
    implements $SprigDetailsCopyWith<$Res> {
  _$SprigDetailsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? structure = null,
    Object? format = null,
    Object? name = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      structure: null == structure
          ? _value.structure
          : structure // ignore: cast_nullable_to_non_nullable
              as String,
      format: null == format
          ? _value.format
          : format // ignore: cast_nullable_to_non_nullable
              as String,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SprigDetailsImplCopyWith<$Res>
    implements $SprigDetailsCopyWith<$Res> {
  factory _$$SprigDetailsImplCopyWith(
          _$SprigDetailsImpl value, $Res Function(_$SprigDetailsImpl) then) =
      __$$SprigDetailsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String structure, String format, String? name});
}

/// @nodoc
class __$$SprigDetailsImplCopyWithImpl<$Res>
    extends _$SprigDetailsCopyWithImpl<$Res, _$SprigDetailsImpl>
    implements _$$SprigDetailsImplCopyWith<$Res> {
  __$$SprigDetailsImplCopyWithImpl(
      _$SprigDetailsImpl _value, $Res Function(_$SprigDetailsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? structure = null,
    Object? format = null,
    Object? name = freezed,
  }) {
    return _then(_$SprigDetailsImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      structure: null == structure
          ? _value.structure
          : structure // ignore: cast_nullable_to_non_nullable
              as String,
      format: null == format
          ? _value.format
          : format // ignore: cast_nullable_to_non_nullable
              as String,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SprigDetailsImpl with DiagnosticableTreeMixin implements _SprigDetails {
  const _$SprigDetailsImpl(
      {required this.id,
      required this.structure,
      required this.format,
      this.name});

  factory _$SprigDetailsImpl.fromJson(Map<String, dynamic> json) =>
      _$$SprigDetailsImplFromJson(json);

  @override
  final String id;
  @override
  final String structure;
  @override
  final String format;
  @override
  final String? name;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SprigDetails(id: $id, structure: $structure, format: $format, name: $name)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'SprigDetails'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('structure', structure))
      ..add(DiagnosticsProperty('format', format))
      ..add(DiagnosticsProperty('name', name));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SprigDetailsImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.structure, structure) ||
                other.structure == structure) &&
            (identical(other.format, format) || other.format == format) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, structure, format, name);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SprigDetailsImplCopyWith<_$SprigDetailsImpl> get copyWith =>
      __$$SprigDetailsImplCopyWithImpl<_$SprigDetailsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SprigDetailsImplToJson(
      this,
    );
  }
}

abstract class _SprigDetails implements SprigDetails {
  const factory _SprigDetails(
      {required final String id,
      required final String structure,
      required final String format,
      final String? name}) = _$SprigDetailsImpl;

  factory _SprigDetails.fromJson(Map<String, dynamic> json) =
      _$SprigDetailsImpl.fromJson;

  @override
  String get id;
  @override
  String get structure;
  @override
  String get format;
  @override
  String? get name;
  @override
  @JsonKey(ignore: true)
  _$$SprigDetailsImplCopyWith<_$SprigDetailsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

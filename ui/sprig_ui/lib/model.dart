import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'model.freezed.dart';
part 'model.g.dart';

/// A sprig's detailed metadata
@freezed
class SprigDetails with _$SprigDetails {
  const factory SprigDetails(
      {required String id,
      required String structure,
      required String format,
      String? name}) = _SprigDetails;

  factory SprigDetails.fromJson(Map<String, Object?> json) =>
      _$SprigDetailsFromJson(json);
}

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vector_math/vector_math_64.dart';

class Matrix4Converter implements JsonConverter<Matrix4, List<dynamic>> {
  const Matrix4Converter();

  @override
  Matrix4 fromJson(List<dynamic> json) {
    return Matrix4.fromList(json.map((e) => (e as num).toDouble()).toList());
  }

  @override
  List<dynamic> toJson(Matrix4 object) {
    return object.storage.toList();
  }
}

class ColorConverter implements JsonConverter<Color, int> {
  const ColorConverter();

  @override
  Color fromJson(int json) => Color(json);

  @override
  int toJson(Color object) => object.value;
}

class OffsetConverter implements JsonConverter<Offset, Map<String, dynamic>> {
  const OffsetConverter();

  @override
  Offset fromJson(Map<String, dynamic> json) {
    return Offset((json['dx'] as num).toDouble(), (json['dy'] as num).toDouble());
  }

  @override
  Map<String, dynamic> toJson(Offset object) {
    return {'dx': object.dx, 'dy': object.dy};
  }
}

class TextStyleConverter implements JsonConverter<TextStyle, Map<String, dynamic>> {
  const TextStyleConverter();

  @override
  TextStyle fromJson(Map<String, dynamic> json) {
    return TextStyle(
      fontSize: (json['fontSize'] as num?)?.toDouble(),
      color: json['color'] != null ? Color(json['color'] as int) : null,
      fontFamily: json['fontFamily'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson(TextStyle object) {
    return {
      if (object.fontSize != null) 'fontSize': object.fontSize,
      if (object.color != null) 'color': object.color!.value,
      if (object.fontFamily != null) 'fontFamily': object.fontFamily,
    };
  }
}

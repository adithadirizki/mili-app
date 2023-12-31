import 'package:flutter/widgets.dart';
import 'package:miliv2/src/utils/formatter.dart';

List<Widget> modelBuilder<M>(
        List<M> models, Widget Function(int index, M model) builder) =>
    models
        .asMap()
        .map<int, Widget>(
            (index, model) => MapEntry(index, builder(index, model)))
        .values
        .toList();

bool intToBool(dynamic e) => e as int == 1;

int boolToInt(bool e) => e ? 1 : 0;

int offsetLimitEncoder(dynamic e) => e is int ? e : 0;

String intToStr(dynamic e) => e.toString();

int strToInt(dynamic e) => e is int ? e : parseInt(e.toString());

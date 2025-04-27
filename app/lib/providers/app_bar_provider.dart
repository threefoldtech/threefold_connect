import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appBarActionsBuilderProvider = StateProvider<List<Widget> Function(BuildContext context)?>((ref) => null);
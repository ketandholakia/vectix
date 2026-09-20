import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vx_element.dart';

final clipboardProvider = StateProvider<List<VxElement>>((ref) => []);

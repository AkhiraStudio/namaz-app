import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/home_widget_service.dart';

final homeWidgetServiceProvider = Provider<HomeWidgetService>((ref) {
  return HomeWidgetService();
});

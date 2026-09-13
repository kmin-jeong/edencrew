import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/theme.dart';
import 'data/remote/stock_api_client.dart';
import 'state/favorite_controller.dart';
import 'state/watchlist_controller.dart';
import 'state/search_controller.dart' as app_search;
import 'presentation/navigation/root_shell.dart';

void main() {
  final apiClient = StockApiClient();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoriteController()),
        ChangeNotifierProvider(create: (_) => WatchlistController(apiClient)),
        ChangeNotifierProvider(
          create: (_) => app_search.SearchController(apiClient),
        ),
      ],
      child: const EdencrewAssignmentApp(),
    ),
  );
}

class EdencrewAssignmentApp extends StatelessWidget {
  const EdencrewAssignmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '이든크루 평가 과제',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      home: const RootShell(),
    );
  }
}

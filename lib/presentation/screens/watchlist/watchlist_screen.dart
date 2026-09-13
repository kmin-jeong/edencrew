import 'package:edencrew_assignment_starter/domain/models/sort_option.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/favorite_controller.dart';
import '../../../state/watchlist_controller.dart';
import '../../../theme/theme.dart';
import '../../widgets/sort_bottom_sheet.dart';
import '../../widgets/watchlist_item.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final favoriteIds = context.read<FavoriteController>().favoriteIds;
      context.read<WatchlistController>().syncWithFavorites(favoriteIds);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dimens = context.dimens;
    final watchlist = context.watch<WatchlistController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('관심'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<WatchlistController>().refresh(),
          ),
        ],
      ),
      body: watchlist.isEmpty
          ? _EmptyWatchlist(colors: colors, dimens: dimens)
          : RefreshIndicator(
              onRefresh: () => context.read<WatchlistController>().refresh(),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: dimens.space4,
                      vertical: dimens.space2,
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () async {
                          final selected = await showSortBottomSheet(
                            context,
                            current: watchlist.sortOption,
                          );
                          if (selected != null) {
                            context.read<WatchlistController>().changeSort(
                              selected,
                            );
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: dimens.space3,
                            vertical: dimens.space2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.accentBg,
                            borderRadius: BorderRadius.circular(
                              dimens.radiusMd,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                watchlist.sortOption.label,
                                style: TextStyle(
                                  color: colors.accentDefault,
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(width: dimens.space1),
                              Icon(
                                Icons.expand_more,
                                size: dimens.iconSm,
                                color: colors.accentDefault,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: watchlist.sortedStocks.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: colors.borderSubtle),
                      itemBuilder: (context, index) {
                        return WatchlistItem(
                          stock: watchlist.sortedStocks[index],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _EmptyWatchlist extends StatelessWidget {
  final AppColors colors;
  final AppDimens dimens;
  const _EmptyWatchlist({required this.colors, required this.dimens});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_border, size: 48, color: colors.textTertiary),
          SizedBox(height: dimens.space3),
          Text(
            '관심 종목이 없습니다',
            style: TextStyle(color: colors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

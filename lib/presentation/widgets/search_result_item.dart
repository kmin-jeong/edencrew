import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/dto/stock_dtos.dart';
import '../../domain/models/domestic_stock.dart';
import '../../state/favorite_controller.dart';
import '../../theme/theme.dart';
import 'highlighted_text.dart';

class SearchResultItem extends StatelessWidget {
  final SearchItemDto item;
  final String query;
  final VoidCallback onTap;

  const SearchResultItem({
    super.key,
    required this.item,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dimens = context.dimens;
    final canonicalId = DomesticStock.canonicalIdOf(item.code);
    final isFavorite = context.watch<FavoriteController>().isFavorite(
      canonicalId,
    );

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: dimens.rowMinHeight),
        padding: EdgeInsets.symmetric(
          horizontal: dimens.space4,
          vertical: dimens.space2,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  HighlightedText(
                    text: item.name,
                    query: query,
                    baseStyle: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: AppTypography.medium,
                      fontSize: 15,
                    ),
                    highlightColor: colors.searchHighlight,
                  ),
                  SizedBox(height: dimens.space1),
                  Text(
                    '${item.code} · ${item.typeName}',
                    style: TextStyle(color: colors.textTertiary, fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: isFavorite
                    ? colors.favoriteActive
                    : colors.favoriteInactive,
              ),
              onPressed: () {
                final wasFavorite = isFavorite;
                context.read<FavoriteController>().toggle(canonicalId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          wasFavorite ? Icons.star_border : Icons.star,
                          color: colors.favoriteActive,
                          size: dimens.iconSm,
                        ),
                        SizedBox(width: dimens.space2),
                        Text(wasFavorite ? '관심이 해제되었습니다' : '관심이 등록되었습니다'),
                      ],
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

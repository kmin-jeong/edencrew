import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/search_controller.dart' as app_search;
import '../../../theme/theme.dart';
import '../../widgets/search_result_item.dart';
import '../detail/stock_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dimens = context.dimens;
    final search = context.watch<app_search.SearchController>();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _textController,
          onChanged: (value) =>
              context.read<app_search.SearchController>().onQueryChanged(value),
          style: TextStyle(color: colors.textPrimary),
          decoration: InputDecoration(
            hintText: '종목명을 입력하세요',
            hintStyle: TextStyle(color: colors.textTertiary),
            border: InputBorder.none,
            suffixIcon: search.query.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.close,
                      size: dimens.iconSm,
                      color: colors.textTertiary,
                    ),
                    onPressed: () {
                      _textController.clear();
                      context.read<app_search.SearchController>().clear();
                    },
                  )
                : null,
          ),
        ),
      ),
      body: _buildBody(context, search, colors, dimens),
    );
  }

  Widget _buildBody(
    BuildContext context,
    app_search.SearchController search,
    AppColors colors,
    AppDimens dimens,
  ) {
    if (search.query.isEmpty) {
      return _InitialState(colors: colors, dimens: dimens);
    }
    if (search.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: colors.accentDefault),
      );
    }
    if (search.results.isEmpty) {
      return _NoResultsState(
        query: search.query,
        colors: colors,
        dimens: dimens,
      );
    }
    return ListView.separated(
      itemCount: search.results.length,
      separatorBuilder: (_, __) =>
          Divider(height: 1, color: colors.borderSubtle),
      itemBuilder: (context, index) {
        final item = search.results[index];
        return SearchResultItem(
          item: item,
          query: search.query,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  StockDetailScreen(canonicalId: 'domestic:${item.code}'),
            ),
          ),
        );
      },
    );
  }
}

class _InitialState extends StatelessWidget {
  final AppColors colors;
  final AppDimens dimens;
  const _InitialState({required this.colors, required this.dimens});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search, size: 48, color: colors.textTertiary),
          SizedBox(height: dimens.space3),
          Text(
            '종목을 검색해 보세요',
            style: TextStyle(color: colors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _NoResultsState extends StatelessWidget {
  final String query;
  final AppColors colors;
  final AppDimens dimens;
  const _NoResultsState({
    required this.query,
    required this.colors,
    required this.dimens,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: dimens.space5),
        child: Text(
          "'$query'와 일치하는 검색 결과를 찾지 못했습니다.",
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.textSecondary, fontSize: 14),
        ),
      ),
    );
  }
}

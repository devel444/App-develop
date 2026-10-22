import 'package:flutter/material.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/widgets/page_arrows.dart';
import 'package:sticker_world/core/widgets/pattern_background.dart';
import 'package:sticker_world/core/widgets/screen_frame.dart';
import 'package:sticker_world/features/records/calendar_page.dart';
import 'package:sticker_world/features/records/report_page.dart';

/// 기록 탭. 1페이지 달력, 2페이지 성장 리포트 (◀ ▶ 또는 옆으로 넘기기).
class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  static const _pageCount = 2;

  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenFrame(
      title: '기록',
      color: AppColors.pink,
      pattern: BgPattern.dots,
      child: Column(
        children: [
          Expanded(
            child: PageArrows(
              onPrevious: _page > 0 ? () => _goTo(_page - 1) : null,
              onNext: _page < _pageCount - 1 ? () => _goTo(_page + 1) : null,
              child: PageView(
                controller: _controller,
                onPageChanged: (page) => setState(() => _page = page),
                children: const [CalendarPage(), ReportPage()],
              ),
            ),
          ),
          const SizedBox(height: 8),
          PageDots(count: _pageCount, index: _page),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

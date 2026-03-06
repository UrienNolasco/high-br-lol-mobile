import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class PlayerSearchBar extends StatefulWidget {
  const PlayerSearchBar({
    super.key,
    required this.onSearch,
    this.isLoading = false,
  });

  final void Function(String gameName, String tagLine) onSearch;
  final bool isLoading;

  @override
  State<PlayerSearchBar> createState() => _PlayerSearchBarState();
}

class _PlayerSearchBarState extends State<PlayerSearchBar> {
  final _controller = TextEditingController();

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isLoading) return;

    final parts = text.split('#');
    final gameName = parts[0].trim();
    final tagLine = parts.length > 1 ? parts[1].trim() : 'BR1';

    if (gameName.isEmpty) return;
    widget.onSearch(gameName, tagLine);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: _controller,
        style: AppTypography.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Jogador#BR1',
          prefixIcon: widget.isLoading
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.accent,
                    ),
                  ),
                )
              : const Icon(Icons.search, color: AppColors.textMuted, size: 20),
        ),
        onSubmitted: (_) => _submit(),
      ),
    );
  }
}

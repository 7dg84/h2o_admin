import 'package:flutter/material.dart';

class ReusableCrudTable<T> extends StatelessWidget {
  final List<String> headers;
  final List<int> flexes;
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) rowBuilder;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final int itemsPerPage;
  final Function(int) onPageChanged;
  final String emptyMessage;

  const ReusableCrudTable({
    required this.headers,
    required this.flexes,
    required this.items,
    required this.rowBuilder,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.itemsPerPage,
    required this.onPageChanged,
    this.emptyMessage = 'No hay elementos para mostrar.',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(0, totalCount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Table Header
              Container(
                color: Colors.blue[50],
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: List.generate(headers.length, (i) {
                    return Expanded(
                      flex: flexes[i],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          headers[i],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              // Table Body
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    emptyMessage,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              else
                ...List.generate(
                  items.length,
                  (index) {
                    final item = items[index];
                    final isLastItem = index == items.length - 1;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: rowBuilder(context, item, index),
                        ),
                        if (!isLastItem)
                          Divider(
                            height: 1,
                            color: Colors.grey[300],
                          ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Pagination
        if (totalCount > 0)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mostrando ${startIndex + 1}-${endIndex} de $totalCount elementos',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: currentPage > 1
                        ? () => onPageChanged(currentPage - 1)
                        : null,
                  ),
                  ..._buildPageButtons(),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: currentPage < totalPages
                        ? () => onPageChanged(currentPage + 1)
                        : null,
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  List<Widget> _buildPageButtons() {
    final List<Widget> buttons = [];
    final int maxButtons = 5;
    int startPage = 1;
    int endPage = totalPages;

    if (totalPages > maxButtons) {
      if (currentPage <= (maxButtons ~/ 2)) {
        endPage = maxButtons;
      } else if (currentPage > totalPages - (maxButtons ~/ 2)) {
        startPage = totalPages - maxButtons + 1;
      } else {
        startPage = currentPage - (maxButtons ~/ 2);
        endPage = currentPage + (maxButtons ~/ 2);
      }
    }

    for (int i = startPage; i <= endPage; i++) {
      final isSelected = currentPage == i;
      buttons.add(
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: SizedBox(
            width: 50, // standard pagination button size
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? Colors.blue[700] : Colors.white,
                foregroundColor: isSelected ? Colors.white : Colors.grey[700],
                elevation: isSelected ? 2 : 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: BorderSide(
                    color: isSelected ? Colors.blue[700]! : Colors.grey[300]!,
                  ),
                ),
              ),
              onPressed: () => onPageChanged(i),
              child: Text(i.toString()),
            ),
          ),
        ),
      );
    }

    return buttons;
  }
}

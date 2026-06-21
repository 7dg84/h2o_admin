import 'package:flutter/material.dart';

typedef SectionTap = void Function(int index);

class RightSideMenu extends StatelessWidget {
  final List<String> sections;
  final int selectedIndex;
  final SectionTap onTap;

  const RightSideMenu(
      {Key? key,
      required this.sections,
      required this.selectedIndex,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            ...List.generate(sections.length, (i) {
              final selected = i == selectedIndex;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selected ? Colors.blue : Colors.white,
                    foregroundColor: selected ? Colors.white : Colors.black87,
                    elevation: selected ? 2 : 0,
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  ),
                  onPressed: () => onTap(i),
                  child: Align(
                      alignment: Alignment.centerLeft, child: Text(sections[i])),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _VerticalMenuHeader extends StatefulWidget {
  final List<String> sections;
  final int selectedIndex;
  final SectionTap onTap;

  const _VerticalMenuHeader({
    required this.sections,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  State<_VerticalMenuHeader> createState() => _VerticalMenuHeaderState();
}

class _VerticalMenuHeaderState extends State<_VerticalMenuHeader> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final currentSection = widget.sections[widget.selectedIndex];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Bar clickable
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.menu, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Text(
                        'Menú: ',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        currentSection,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          // Collapsible/Scrollable body
          if (_isExpanded)
            Container(
              constraints: const BoxConstraints(maxHeight: 250),
              color: Colors.grey[50],
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(widget.sections.length, (i) {
                    final selected = i == widget.selectedIndex;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selected ? Colors.blue : Colors.white,
                          foregroundColor: selected ? Colors.white : Colors.black87,
                          elevation: selected ? 2 : 0,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: selected ? Colors.blue : const Color(0xFFE2E8F0),
                            ),
                          ),
                        ),
                        onPressed: () {
                          widget.onTap(i);
                          setState(() {
                            _isExpanded = false;
                          });
                        },
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(widget.sections[i]),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AdminLayout extends StatelessWidget {
  final Widget child;
  final List<String> sections;
  final int selectedIndex;
  final SectionTap onSelect;

  const AdminLayout(
      {Key? key,
      required this.child,
      required this.sections,
      required this.selectedIndex,
      required this.onSelect})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      body: SafeArea(
        child: isPortrait
            ? Column(
                children: [
                  _VerticalMenuHeader(
                    sections: sections,
                    selectedIndex: selectedIndex,
                    onTap: onSelect,
                  ),
                  Expanded(child: child),
                ],
              )
            : Row(
                children: [
                  SizedBox(
                    width: 140,
                    child: RightSideMenu(
                        sections: sections,
                        selectedIndex: selectedIndex,
                        onTap: onSelect),
                  ),
                  Expanded(child: child),
                ],
              ),
      ),
    );
  }
}

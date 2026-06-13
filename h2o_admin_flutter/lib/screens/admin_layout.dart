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
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            SizedBox(
              width: 240,
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

// entry_search.dart
import 'package:flutter/material.dart';

class EntrySearchBar extends StatefulWidget {
  final String title;
  final bool isSearching;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<bool> onSearchToggled;

  const EntrySearchBar({
    super.key,
    required this.title,
    required this.isSearching,
    required this.onSearchChanged,
    required this.onSearchToggled,
  });

  @override
  _EntrySearchBarState createState() => _EntrySearchBarState();
}

class _EntrySearchBarState extends State<EntrySearchBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Builds the text field shown when searching.
  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Search...',
        border: InputBorder.none,
      ),
      onChanged: widget.onSearchChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: widget.isSearching
              ? _buildSearchField()
              : Text(
            widget.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        // The icon button toggles the search on/off
        IconButton(
          icon: Icon(widget.isSearching ? Icons.close : Icons.search),
          onPressed: () {
            if (widget.isSearching) {
              _searchController.clear();
              widget.onSearchChanged('');
            }
            widget.onSearchToggled(!widget.isSearching);
          },
        ),
      ],
    );
  }
}

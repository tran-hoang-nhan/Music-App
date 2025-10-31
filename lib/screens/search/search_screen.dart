import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../services/jamendo/jamendo_controller.dart';
import '../../models/song.dart';
import '../offline_banner.dart';
import 'widgets/search_bar.dart';
import 'widgets/search_results.dart';
import 'widgets/search_suggestions.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Song> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isEmpty) {
        setState(() {
          _hasSearched = false;
          _searchResults = [];
          _isLoading = false;
        });
        return;
      }
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final jamendoController = Provider.of<JamendoController>(context, listen: false);
      final results = await jamendoController.search.searchTracks(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text('Tìm kiếm'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            SearchBarWidget(
              controller: _searchController,
              onSearch: _performSearch,
              onChanged: _onSearchChanged,
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFE53E3E)))
                  : _hasSearched
                      ? SearchResults(results: _searchResults)
                      : const SearchSuggestions(),
            ),
          ],
        ),
      ),
    );
  }
}


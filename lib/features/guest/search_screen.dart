import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../data/repositories.dart'; // Unused
// import '../../domain/models.dart'; // Unused
import '../guest/guest_home_screen.dart'; // Reuse provider

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final packagesAsync = ref.watch(providerOfPackages);

    return Scaffold(
      appBar: AppBar(title: const Text('Search Menu')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for dishes, ingredients...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
              ),
              onChanged: (val) => setState(() => _query = val),
            ),
          ),
          Expanded(
            child: packagesAsync.when(
              data: (packages) {
                final filtered = packages.where((p) {
                  final q = _query.toLowerCase();
                  return p.name.toLowerCase().contains(q) ||
                      p.description.toLowerCase().contains(q) ||
                      p.dietaryInfo.any((d) => d.toLowerCase().contains(q));
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text("No matching menu items found."),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final pkg = filtered[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(pkg.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        title: Text(pkg.name),
                        // subtitle: Text(pkg.dietaryInfo.join(", ")),
                        onTap: () {
                          // Navigate to details (GoRouter extra)
                          // For now we just print, router integration coming next
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text("Error: $e")),
            ),
          ),
        ],
      ),
    );
  }
}

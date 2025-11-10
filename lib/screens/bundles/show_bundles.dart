import 'package:flutter/material.dart';
import 'package:tugas_akhir_valorant/model/bundles_models.dart';
import 'package:tugas_akhir_valorant/services/bundles_services.dart';
import 'package:tugas_akhir_valorant/screens/bundles/bundles_details.dart';

class ShowBundlesPage extends StatefulWidget {
  const ShowBundlesPage({super.key});

  @override
  State<ShowBundlesPage> createState() => _ShowBundlesPageState();
}

class _ShowBundlesPageState extends State<ShowBundlesPage> {
  late Future<List<BundlesModel>> _futureBundles;

  @override
  void initState() {
    super.initState();
    _futureBundles = BundlesService().fetchBundles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1823),
      appBar: AppBar(
        title: const Text(
          "BUNDLES",
          style: TextStyle(
            fontFamily: 'Teko',
            fontSize: 28,
            letterSpacing: 2,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<List<BundlesModel>>(
        future: _futureBundles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF4655),
                strokeWidth: 3,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Failed to load bundles",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontFamily: 'Teko',
                  fontSize: 24,
                  letterSpacing: 1,
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No bundles found",
                style: TextStyle(
                  color: Colors.white70,
                  fontFamily: 'Teko',
                  fontSize: 24,
                  letterSpacing: 1,
                ),
              ),
            );
          }

          final bundles = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 20,
            ),
            itemCount: bundles.length,
            itemBuilder: (context, index) {
              final bundle = bundles[index];
              final imageUrl = bundle.displayIcon.isNotEmpty
                  ? bundle.displayIcon
                  : bundle.verticalPromoImage;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BundleDetailPage(bundle: bundle),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2332),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 6),
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 7,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.3),
                                  Colors.black.withOpacity(0.1),
                                ],
                              ),
                            ),
                            child: imageUrl.isNotEmpty
                                ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.black12,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                          : null,
                                      color: const Color(0xFFFF4655),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Colors.black12,
                                    child: const Center(
                                      child: Icon(
                                        Icons.image_not_supported_outlined,
                                        color: Colors.white30,
                                        size: 42,
                                      ),
                                    ),
                                  ),
                            )
                                : Container(
                              color: Colors.black12,
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.white30,
                                  size: 42,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 3,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                bundle.displayName.toUpperCase(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Teko',
                                  fontSize: 22,
                                  color: Colors.white,
                                  letterSpacing: 1.1,
                                  fontWeight: FontWeight.w500,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
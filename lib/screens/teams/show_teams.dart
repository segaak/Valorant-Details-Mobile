import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tugas_akhir_valorant/model/teams_models.dart';
import 'package:tugas_akhir_valorant/services/teams_services.dart';
import 'package:tugas_akhir_valorant/services/location_services.dart';

class ShowTeamsPage extends StatefulWidget {
  const ShowTeamsPage({super.key});

  @override
  State<ShowTeamsPage> createState() => _ShowTeamsPageState();
}

class _ShowTeamsPageState extends State<ShowTeamsPage> {
  Future<Map<String, List<TeamModel>>>? _teamsFuture;
  final TeamsService _teamsService = TeamsService();
  String _userRegion = "Unknown";
  String _userCountry = "Mendeteksi lokasi...";
  final TextEditingController _searchController = TextEditingController();
  String? _selectedRegion;
  String? _searchedLocation;
  bool _hasSearchText = false;

  @override
  void initState() {
    super.initState();
    _initPage();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initPage() async {
    await _detectRegionFromLocation();
    setState(() {
      _teamsFuture = _teamsService.fetchTeamsByRegion();
    });
  }

  /// 🔹 Gunakan LocationService untuk ambil posisi & tentukan region
  Future<void> _detectRegionFromLocation() async {
    try {
      final position = await LocationService.getUserLocation();
      if (position == null) {
        setState(() => _userCountry = "Tidak dapat mendeteksi lokasi");
        return;
      }

      final country = await LocationService.getCountryFromPosition(position);
      if (country == null) {
        setState(() => _userCountry = "Negara tidak terdeteksi");
        return;
      }

      // Tentukan region berdasarkan negara
      String region;
      if (country.toLowerCase().contains("indonesia")) {
        region = "APAC";
      } else if (country.toLowerCase().contains("united states") ||
          country.toLowerCase().contains("canada")) {
        region = "Americas";
      } else if (country.toLowerCase().contains("france") ||
          country.toLowerCase().contains("germany")) {
        region = "EMEA";
      } else {
        region = "Unknown Region";
      }

      setState(() {
        _userCountry = country;
        _userRegion = region;
      });

      print("📍 Country: $country → Region: $_userRegion");
    } catch (e) {
      print("❌ Gagal mendapatkan lokasi: $e");
      setState(() => _userCountry = "Error lokasi");
    }
  }

  /// 🔍 Fungsi untuk mengkonversi lokasi yang dicari ke region
  String? _locationToRegion(String location) {
    final loc = location.toLowerCase().trim();

    // North America (NA)
    if (loc.contains('california') ||
        loc.contains('cali') ||
        loc.contains('los angeles') ||
        loc.contains('san francisco') ||
        loc.contains('new york') ||
        loc.contains('nyc') ||
        loc.contains('texas') ||
        loc.contains('houston') ||
        loc.contains('dallas') ||
        loc.contains('florida') ||
        loc.contains('miami') ||
        loc.contains('chicago') ||
        loc.contains('boston') ||
        loc.contains('seattle') ||
        loc.contains('washington') ||
        loc.contains('united states') ||
        loc.contains('usa') ||
        loc.contains('us') ||
        loc.contains('america') ||
        loc.contains('canada') ||
        loc.contains('toronto') ||
        loc.contains('vancouver')) {
      return 'North America (NA)';
    }
    // Europe (EU)
    else if (loc.contains('london') ||
        loc.contains('paris') ||
        loc.contains('france') ||
        loc.contains('berlin') ||
        loc.contains('germany') ||
        loc.contains('madrid') ||
        loc.contains('spain') ||
        loc.contains('rome') ||
        loc.contains('italy') ||
        loc.contains('amsterdam') ||
        loc.contains('netherlands') ||
        loc.contains('stockholm') ||
        loc.contains('sweden') ||
        loc.contains('moscow') ||
        loc.contains('russia') ||
        loc.contains('istanbul') ||
        loc.contains('turkey') ||
        loc.contains('uk') ||
        loc.contains('united kingdom') ||
        loc.contains('europe') ||
        loc.contains('eu')) {
      return 'Europe (EU)';
    }
    // Japan
    else if (loc.contains('japan') ||
        loc.contains('tokyo') ||
        loc.contains('osaka') ||
        loc.contains('kyoto')) {
      return 'Japan';
    }
    // Korea
    else if (loc.contains('korea') ||
        loc.contains('seoul') ||
        loc.contains('south korea')) {
      return 'Korea';
    }
    // Asia-Pacific (APAC)
    else if (loc.contains('indonesia') ||
        loc.contains('jakarta') ||
        loc.contains('malaysia') ||
        loc.contains('kuala lumpur') ||
        loc.contains('philippines') ||
        loc.contains('manila') ||
        loc.contains('singapore') ||
        loc.contains('thailand') ||
        loc.contains('bangkok') ||
        loc.contains('vietnam') ||
        loc.contains('ho chi minh') ||
        loc.contains('china') ||
        loc.contains('beijing') ||
        loc.contains('shanghai') ||
        loc.contains('hong kong') ||
        loc.contains('taiwan') ||
        loc.contains('taipei') ||
        loc.contains('australia') ||
        loc.contains('sydney') ||
        loc.contains('melbourne') ||
        loc.contains('new zealand') ||
        loc.contains('auckland') ||
        loc.contains('asia') ||
        loc.contains('pacific') ||
        loc.contains('apac')) {
      return 'Asia-Pacific (APAC)';
    }
    // South America
    else if (loc.contains('brazil') ||
        loc.contains('sao paulo') ||
        loc.contains('rio de janeiro') ||
        loc.contains('argentina') ||
        loc.contains('buenos aires') ||
        loc.contains('chile') ||
        loc.contains('santiago') ||
        loc.contains('colombia') ||
        loc.contains('bogota') ||
        loc.contains('peru') ||
        loc.contains('lima') ||
        loc.contains('south america')) {
      return 'South America';
    }
    // India/Southeast Asia
    else if (loc.contains('india') ||
        loc.contains('mumbai') ||
        loc.contains('delhi') ||
        loc.contains('bangalore') ||
        loc.contains('southeast')) {
      return 'India/Southeast Asia';
    }
    // Middle East/North Africa (MENA)
    else if (loc.contains('saudi') ||
        loc.contains('riyadh') ||
        loc.contains('egypt') ||
        loc.contains('cairo') ||
        loc.contains('uae') ||
        loc.contains('dubai') ||
        loc.contains('middle east') ||
        loc.contains('mena')) {
      return 'Middle East/North Africa (MENA)';
    }

    return null;
  }

  /// 🔍 Fungsi untuk mencari lokasi dan filter teams
  void _searchLocation(String query) {
    setState(() {
      _hasSearchText = query.isNotEmpty;

      if (query.isEmpty) {
        _selectedRegion = null;
        _searchedLocation = null;
      } else {
        final region = _locationToRegion(query);
        _selectedRegion = region;
        _searchedLocation = query;
      }
    });
  }

  /// 🎯 Fungsi untuk filter teams berdasarkan region
  Map<String, List<TeamModel>> _filterTeamsByRegion(
    Map<String, List<TeamModel>> allTeams,
  ) {
    if (_selectedRegion == null) {
      return allTeams;
    }

    return {_selectedRegion!: allTeams[_selectedRegion!] ?? []};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1823),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "VCT TEAMS",
          style: TextStyle(
            fontFamily: 'Tungsten',
            fontSize: 38,
            color: Colors.white,
            letterSpacing: 3,
          ),
        ),
        centerTitle: true,
      ),
      body: _teamsFuture == null
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF4655)),
            )
          : FutureBuilder<Map<String, List<TeamModel>>>(
              future: _teamsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF4655)),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Gagal memuat tim: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  );
                } else if (!snapshot.hasData) {
                  return const Center(
                    child: Text(
                      'Tidak ada data tim.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                final allTeamsByRegion = snapshot.data!;
                final teamsByRegion = _filterTeamsByRegion(allTeamsByRegion);

                return ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  children: [
                    // 🔍 Search bar untuk mencari lokasi
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFF4655).withOpacity(0.5),
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: GoogleFonts.rajdhani(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Cari lokasi (contoh: California, London, Tokyo)',
                          hintStyle: GoogleFonts.rajdhani(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 16,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFFFF4655),
                          ),
                          suffixIcon: _hasSearchText
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    _searchLocation('');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: _searchLocation,
                      ),
                    ),

                    // 🔹 Info lokasi pengguna atau hasil pencarian
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: _selectedRegion != null
                            ? const Color(0xFFFF4655).withOpacity(0.2)
                            : Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedRegion != null
                              ? const Color(0xFFFF4655)
                              : const Color(0xFFFF4655).withOpacity(0.5),
                          width: _selectedRegion != null ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _selectedRegion != null
                                ? Icons.check_circle
                                : Icons.location_on,
                            color: const Color(0xFFFF4655),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedRegion != null
                                  ? "Lokasi: $_searchedLocation → Region: $_selectedRegion"
                                  : "Lokasi kamu: $_userCountry → Region kamu: $_userRegion",
                              style: GoogleFonts.rajdhani(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: _selectedRegion != null
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (_selectedRegion != null)
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white70,
                                size: 20,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _searchLocation('');
                              },
                            ),
                        ],
                      ),
                    ),

                    // 🔹 Pesan jika lokasi tidak ditemukan
                    if (_hasSearchText && _selectedRegion == null)
                      Container(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.location_searching,
                              size: 48,
                              color: Colors.orange.withOpacity(0.7),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Lokasi '$_searchedLocation' tidak dikenali.\nCoba cari dengan nama kota atau negara.",
                              style: GoogleFonts.rajdhani(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                    // 🔹 Pesan jika tidak ada tim untuk region yang dipilih
                    if (_selectedRegion != null &&
                        (teamsByRegion[_selectedRegion!]?.isEmpty ?? true))
                      Container(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: Colors.white.withOpacity(0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Tidak ada tim ditemukan untuk region $_selectedRegion",
                              style: GoogleFonts.rajdhani(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                    // 🔹 Daftar tim per region
                    ...teamsByRegion.entries.map((entry) {
                      final regionName = entry.key;
                      final teams = entry.value;
                      if (teams.isEmpty) return const SizedBox.shrink();

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              regionName.toUpperCase(),
                              style: const TextStyle(
                                fontFamily: 'Tungsten',
                                fontSize: 28,
                                color: Color(0xFFFF4655),
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: teams.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 0.9,
                                  ),
                              itemBuilder: (context, index) {
                                final team = teams[index];
                                return _buildTeamCard(team);
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
    );
  }

  /// 🔹 Widget kartu tim
  Widget _buildTeamCard(TeamModel team) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF4655).withOpacity(0.4),
          width: 1.3,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.network(
              team.img,
              height: 70,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.broken_image,
                color: Colors.white38,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            team.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Tungsten',
              fontSize: 24,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          Text(
            team.country,
            style: TextStyle(
              fontFamily: 'Rajdhani',
              fontSize: 15,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

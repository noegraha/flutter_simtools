import 'package:flutter/material.dart';
import '../services/pasien_service.dart';

class PasienAllHariIniPage extends StatefulWidget {
  const PasienAllHariIniPage({super.key});

  @override
  State<PasienAllHariIniPage> createState() => _PasienAllHariIniPageState();
}

class _PasienAllHariIniPageState extends State<PasienAllHariIniPage> {
  String _rs = '%20';
  String _searchNama = '';
  String _searchRegId = '';
  String _searchRuang = '';
  bool _onlyUnverified = false;
  bool _onlyKonsul = false;

  List<Map<String, dynamic>> pasien = [];
  bool loading = false;
  String error = '';

  // --- Filter logic mirip React, tapi pakai data dari API
  List<Map<String, dynamic>> get filteredPasien {
    var result = pasien
        .where((item) {
          final namaMatch = item['namaPasien'].toLowerCase().contains(
            _searchNama.toLowerCase(),
          );
          final regMatch = item['registrasiId'].toString().contains(
            _searchRegId,
          );
          final ruangMatch = item['ruangDeskripsi'].toLowerCase().contains(
            _searchRuang.toLowerCase(),
          );
          return namaMatch && regMatch && ruangMatch;
        })
        .where((item) => _onlyUnverified ? !(item['verified'] as bool) : true)
        .where((item) => _onlyKonsul ? item['ruangKonsul'] != null : true)
        .toList();
    return result;
  }

  int get anamnesaCount =>
      filteredPasien.where((e) => e['anamnesa'] == true).length;
  int get verifiedCount =>
      filteredPasien.where((e) => e['verified'] == true).length;
  int get fastTrackCount =>
      filteredPasien.where((e) => e['fastTrack'] == true).length;

  List<String> get uniqueRuang =>
      pasien.map((e) => e['ruangDeskripsi'] as String).toSet().toList();

  void _clearAll() {
    setState(() {
      _searchNama = '';
      _searchRegId = '';
      _searchRuang = '';
      _onlyUnverified = false;
      _onlyKonsul = false;
    });
  }

  Future<void> loadPasienAllHariIni() async {
    setState(() {
      loading = true;
      error = '';
    });
    try {
      final user = await getUserName() ?? '';
      final data = await getPasienByUser(
        user: user,
        rs: _rs,
        // searchKey bisa tambahkan jika ingin pencarian via backend
      );
      setState(() {
        pasien = data;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadPasienAllHariIni();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pasien Hari Ini"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh Data",
            onPressed: loadPasienAllHariIni,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // FILTER ATAS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text("RSMS"),
                      selected: _rs == 'RSMS',
                      onSelected: (_) {
                        setState(() => _rs = 'RSMS');
                        loadPasienAllHariIni();
                      },
                    ),
                    const SizedBox(width: 4),
                    ChoiceChip(
                      label: const Text("Abiyasa"),
                      selected: _rs == 'ABIYASA',
                      onSelected: (_) {
                        setState(() => _rs = 'ABIYASA');
                        loadPasienAllHariIni();
                      },
                    ),
                    const SizedBox(width: 4),
                    ChoiceChip(
                      label: const Text("Semua"),
                      selected: _rs == '%20',
                      onSelected: (_) {
                        setState(() => _rs = '%20');
                        loadPasienAllHariIni();
                      },
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.clear),
                      label: const Text("Clear"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red[600],
                        side: BorderSide(color: Colors.red[200]!),
                      ),
                      onPressed: _clearAll,
                    ),
                  ],
                ),
              ),
            ),
            // SEARCH & FILTER FIELD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Search No Registrasi
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: "No. Registrasi",
                            prefixIcon: Icon(Icons.confirmation_number),
                          ),
                          onChanged: (v) => setState(() => _searchRegId = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Search Nama Pasien
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: "Nama Pasien",
                            prefixIcon: Icon(Icons.person),
                          ),
                          onChanged: (v) => setState(() => _searchNama = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _searchRuang.isEmpty ? null : _searchRuang,
                          items: uniqueRuang
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _searchRuang = v ?? ''),
                          decoration: const InputDecoration(
                            labelText: "Filter Ruang",
                            prefixIcon: Icon(Icons.local_hospital),
                          ),
                          isExpanded: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: SwitchListTile(
                          title: const Text("Hanya Belum Verified"),
                          value: _onlyUnverified,
                          dense: true,
                          onChanged: (v) => setState(() => _onlyUnverified = v),
                        ),
                      ),
                      Expanded(
                        child: SwitchListTile(
                          title: const Text("Hanya Pasien Konsul"),
                          value: _onlyKonsul,
                          dense: true,
                          onChanged: (v) => setState(() => _onlyKonsul = v),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // STATISTIK BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statCard("Pasien", filteredPasien.length, theme),
                  _statCard(
                    "Anamnesa",
                    anamnesaCount,
                    theme,
                    color: Colors.green,
                  ),
                  _statCard(
                    "Verified",
                    verifiedCount,
                    theme,
                    color: Colors.blue,
                  ),
                  _statCard(
                    "Fast Track",
                    fastTrackCount,
                    theme,
                    color: Colors.red,
                  ),
                ],
              ),
            ),
            // DAFTAR PASIEN
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : error.isNotEmpty
                  ? Center(
                      child: Text(
                        error,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  : (filteredPasien.isEmpty
                        ? Center(
                            child: Text(
                              "Tidak ada pasien ditemukan.",
                              style: TextStyle(color: theme.hintColor),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filteredPasien.length,
                            separatorBuilder: (_, __) => Divider(height: 1),
                            itemBuilder: (context, i) {
                              final p = filteredPasien[i];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                elevation: 1,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: p['fastTrack']
                                        ? Colors.red[200]
                                        : (p['verified']
                                              ? Colors.blue[100]
                                              : (p['anamnesa']
                                                    ? Colors.yellow[100]
                                                    : Colors.grey[300])),
                                    child: Text(
                                      "${p['noAntrianKlinik']}",
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    p['namaPasien'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.confirmation_number,
                                            size: 14,
                                            color: theme.primaryColor,
                                          ),
                                          const SizedBox(width: 2),
                                          Text("Reg: ${p['registrasiId']}"),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.local_hospital,
                                            size: 14,
                                            color: theme.primaryColor,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(p['ruangDeskripsi']),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.payment,
                                            size: 14,
                                            color: theme.primaryColor,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(p['namaPembayaran']),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.person_outline,
                                            size: 14,
                                            color: theme.primaryColor,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(p['namaDPJP']),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: _statusChip(p),
                                  isThreeLine: true,
                                ),
                              );
                            },
                          )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, int value, ThemeData theme, {Color? color}) {
    return Card(
      color: theme.cardColor,
      elevation: 0,
      child: SizedBox(
        width: 66,
        height: 48,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$value",
              style: TextStyle(
                color: color ?? theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(Map<String, dynamic> p) {
    if (p['fastTrack'] == true) {
      return const Chip(
        label: Text("Fast Track", style: TextStyle(fontSize: 11)),
        backgroundColor: Colors.redAccent,
        labelStyle: TextStyle(color: Colors.white),
      );
    }
    if (p['verified'] == true) {
      return const Chip(
        label: Text("Verified", style: TextStyle(fontSize: 11)),
        backgroundColor: Colors.blue,
        labelStyle: TextStyle(color: Colors.white),
      );
    }
    if (p['anamnesa'] == true) {
      return const Chip(
        label: Text("Anamnesa", style: TextStyle(fontSize: 11)),
        backgroundColor: Colors.amber,
        labelStyle: TextStyle(color: Colors.black87),
      );
    }
    return const SizedBox();
  }
}

import 'package:flutter/material.dart';
import '../services/catatan_medis_service.dart';

class CatatanMedisDoublePage extends StatefulWidget {
  const CatatanMedisDoublePage({super.key});

  @override
  State<CatatanMedisDoublePage> createState() => _CatatanMedisDoublePageState();
}

class _CatatanMedisDoublePageState extends State<CatatanMedisDoublePage> {
  List<Map<String, dynamic>> doubleList = [];
  List<Map<String, dynamic>> listCatatanMedis = [];
  bool loading = false;
  String? error;
  bool showDetail = false;
  String modalRegId = '';

  @override
  void initState() {
    super.initState();
    loadDoubleList();
  }

  Future<void> loadDoubleList() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final data = await fetchCatatanMedisDouble();
      setState(() {
        doubleList = data;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal ambil data: $e')));
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> loadDetailCatatanMedis(String noreg) async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final data = await fetchCatatanMedisByReg(noreg);
      setState(() {
        listCatatanMedis = data;
        showDetail = true;
        modalRegId = noreg;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal ambil detail: $e')));
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> hapusCatatanMedis(String noreg, int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text(
          "Apakah Anda yakin ingin nonaktifkan catatan medis ini?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Non Aktif"),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() {
        loading = true;
      });
      try {
        await deleteCatatanMedisById(noreg, id);
        setState(() {
          listCatatanMedis.removeWhere(
            (e) =>
                e['registrasiId'].toString() == noreg &&
                e['catatanMedisId'] == id,
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Catatan medis dinonaktifkan")),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal nonaktifkan: $e')));
      }
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Catatan Medis Double"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh Data",
            onPressed: loadDoubleList,
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 10,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Catatan Medis Double",
                              style: theme.textTheme.titleMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: loadDoubleList,
                            icon: const Icon(Icons.find_in_page),
                            label: const Text("Cek Data Hari Ini"),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: (loading)
                        ? const Center(child: CircularProgressIndicator())
                        : (error != null)
                        ? Center(
                            child: Text(
                              error!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.red,
                              ),
                            ),
                          )
                        : (doubleList.isEmpty)
                        ? Center(
                            child: Text(
                              "Tidak ada catatan medis double.",
                              style: theme.textTheme.bodyMedium,
                            ),
                          )
                        : ListView.separated(
                            itemCount: doubleList.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 6),
                            itemBuilder: (context, i) {
                              final item = doubleList[i];
                              return Card(
                                color: Colors.blue[50],
                                elevation: 1,
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.description,
                                    color: Colors.teal,
                                  ),
                                  title: Text(
                                    "Reg: ${item['RegistrasiId']}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text("Jumlah: "),
                                          Text(
                                            item['Jumlah'].toString(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Text("Hapus: "),
                                          Text(
                                            item['Hapus'] == true
                                                ? "True"
                                                : "False",
                                            style: TextStyle(
                                              color: item['Hapus'] == true
                                                  ? Colors.red
                                                  : Colors.grey[800],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: OutlinedButton(
                                    onPressed: () => loadDetailCatatanMedis(
                                      item['RegistrasiId'].toString(),
                                    ),
                                    child: const Text("Cek Data"),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            if (showDetail) _buildDetailSheet(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSheet(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.black38,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: 0.6,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      "Detail Catatan Medis Reg. $modalRegId",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  Expanded(
                    child: (loading)
                        ? const Center(child: CircularProgressIndicator())
                        : listCatatanMedis.isEmpty
                        ? const Center(
                            child: Text(
                              "Tidak ada catatan medis aktif untuk registrasi ini.",
                            ),
                          )
                        : ListView.builder(
                            itemCount: listCatatanMedis.length,
                            itemBuilder: (context, i) {
                              final data = listCatatanMedis[i];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.assignment,
                                    color: Colors.teal,
                                  ),
                                  title: Text(
                                    "Catatan Medis ID: ${data['catatanMedisId']}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "Registrasi ID: ${data['registrasiId']}",
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    tooltip: "Non Aktif",
                                    onPressed: () => hapusCatatanMedis(
                                      data['registrasiId'].toString(),
                                      data['catatanMedisId'],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 18,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() => showDetail = false);
                        },
                        child: const Text("Tutup"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

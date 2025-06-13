import 'package:flutter/material.dart';
import '../services/batal_alih_rawat_service.dart';

class BatalAlihRawatPage extends StatefulWidget {
  const BatalAlihRawatPage({super.key});

  @override
  State<BatalAlihRawatPage> createState() => _BatalAlihRawatPageState();
}

class _BatalAlihRawatPageState extends State<BatalAlihRawatPage> {
  final _noregController = TextEditingController();
  List<Map<String, dynamic>> konsulAlih = [];
  bool loading = false;
  String error = '';

  Future<void> cariKonsulAlih() async {
    setState(() {
      loading = true;
      error = '';
      konsulAlih = [];
    });
    try {
      final noreg = _noregController.text.trim();
      if (noreg.isEmpty) {
        setState(() => error = "Masukkan nomor registrasi pasien!");
        loading = false;
        return;
      }
      final data = await fetchKonsulAlihRawat(noreg);
      setState(() {
        konsulAlih = data;
      });
      if (data.isEmpty) {
        setState(() => error = "Tidak ada data konsul alih rawat.");
      }
    } catch (e) {
      setState(() => error = e.toString());
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> konfirmasiBatal(String konsultasiId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text(
          "Apakah Anda yakin akan membatalkan Konsul? Data konsul yang dibatalkan akan terhapus.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Ya, Batalkan"),
          ),
        ],
      ),
    );
    if (ok == true) {
      setState(() {
        loading = true;
      });
      try {
        await deleteAlihRawat(konsultasiId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Berhasil batal konsul!"),
            backgroundColor: Colors.green,
          ),
        );
        await cariKonsulAlih();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal batal konsul: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
      appBar: AppBar(title: const Text("Batal Alih Rawat")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _noregController,
                          decoration: const InputDecoration(
                            hintText: "Masukkan nomor registrasi pasien...",
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => cariKonsulAlih(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: loading ? null : cariKonsulAlih,
                          icon: const Icon(Icons.search),
                          label: const Text("Cari Konsul"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (loading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(error, style: const TextStyle(color: Colors.red)),
                )
              else if (konsulAlih.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(18.0),
                  child: Text(
                    "Masukkan nomor registrasi lalu cari untuk melihat data konsul alih rawat.",
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: konsulAlih.length,
                    itemBuilder: (context, i) {
                      final konsul = konsulAlih[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 2,
                        ),
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Ruangan:",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "Asal: ${konsul['ruangDesk'] ?? '-'}",
                                        ),
                                        Text(
                                          "Tujuan: ${konsul['ruangTujuanDesk'] ?? '-'}",
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    onPressed: loading
                                        ? null
                                        : () => konfirmasiBatal(
                                            "${konsul['konsultasiId']}",
                                          ),
                                    child: const Text("Batal"),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _rowField("Dokter", konsul['dokterDesk']),
                              _rowField("Subjektif", konsul['subjektive']),
                              _rowField("Objektif", konsul['objektive']),
                              _rowField("Assesment", konsul['assesment']),
                              _rowField("Planning", konsul['planning']),
                              _rowField(
                                "Ringkasan Konsul",
                                konsul['ringkasanPemeriksaan'],
                              ),
                              _rowField(
                                "Jawab Konsul",
                                konsul['hasilPemeriksaan'],
                              ),
                              _rowField("Tindakan/Terapi", konsul['tindakan']),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rowField(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              "$title:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text("${value ?? '-'}")),
        ],
      ),
    );
  }
}

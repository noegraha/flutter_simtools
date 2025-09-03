import 'package:flutter/material.dart';
import '../services/list_ip_service.dart';

class ListIPPage extends StatefulWidget {
  const ListIPPage({super.key});

  @override
  State<ListIPPage> createState() => _ListIPPageState();
}

class _ListIPPageState extends State<ListIPPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool loading = false;
  String? error;

  // state data
  List<Map<String, dynamic>> listIP = [];
  List<Map<String, dynamic>> listIPReg = [];
  List<Map<String, dynamic>> listIPRuang = [];
  List<Map<String, dynamic>> listRuangan = [];
  List<Map<String, dynamic>> listResult = [];

  String? selectedRuang;

  final ipController = TextEditingController();
  final macController = TextEditingController();
  final ketController = TextEditingController();

  Widget buildResponsiveTable(
    BuildContext context,
    List<Map<String, dynamic>> data,
    List<String> columns,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    // ✅ Kalau layar kecil (misal < 600px), tampilkan sebagai Card
    if (screenWidth < 600) {
      return ListView.builder(
        itemCount: data.length,
        itemBuilder: (ctx, i) {
          final item = data[i];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(child: Text("${i + 1}")),
              title: Text(item["IPComputer"]?.toString() ?? "-"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("MAC: ${item["MacAddress"] ?? "-"}"),
                  Text("Ruang: ${item["RuangDesk"] ?? "-"}"),
                  Text("Ket: ${item["Keterangan"] ?? "-"}"),
                ],
              ),
            ),
          );
        },
      );
    }

    // ✅ Kalau layar lebar → tampilkan DataTable
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16,
        headingRowColor: MaterialStateProperty.all(Colors.blue[50]),
        border: TableBorder.all(color: Colors.grey.shade300),
        columns: columns
            .map(
              (col) => DataColumn(
                label: Text(
                  col,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )
            .toList(),
        rows: data.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return DataRow(
            cells: [
              DataCell(Text("${i + 1}")),
              DataCell(Text(item["IPComputer"]?.toString() ?? "")),
              DataCell(Text(item["MacAddress"]?.toString() ?? "")),
              DataCell(Text(item["RuangDesk"]?.toString() ?? "")),
              DataCell(Text(item["Keterangan"]?.toString() ?? "")),
            ],
          );
        }).toList(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  void _showSnack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: error ? Colors.red : null),
    );
  }

  Future<void> _loadIpAll() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final data = await fetchIpAll();
      setState(() => listIPReg = data);
    } catch (e) {
      setState(() => error = e.toString());
      _showSnack("Gagal ambil data: $e", error: true);
    }
    setState(() => loading = false);
  }

  Future<void> _loadRuangan() async {
    try {
      final data = await fetchRuangan();
      setState(() => listRuangan = data);
    } catch (e) {
      _showSnack("Gagal ambil ruangan: $e", error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("List IP Tools"),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: "Log IP"),
            Tab(text: "List IP"),
            Tab(text: "List IP by Ruang"),
            Tab(text: "Tools CORS"),
            Tab(text: "IP MAC"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 🟦 Tab 1: Log IP
          // Column(
          //   children: [
          //     ElevatedButton(
          //       onPressed: _loadIpAll,
          //       child: const Text("Cek Log IP"),
          //     ),
          //     if (loading) const CircularProgressIndicator(),
          //     Expanded(
          //       child: ListView.builder(
          //         itemCount: listIPReg.length,
          //         itemBuilder: (ctx, i) => ListTile(
          //           leading: Text("${i + 1}"),
          //           title: Text(listIPReg[i]["IPComputer"] ?? ""),
          //           subtitle: Text(listIPReg[i]["UserId"] ?? ""),
          //         ),
          //       ),
          //     ),
          //   ],
          // ),

          // 🟦 Tab 2: List IP
          Column(
            children: [
              ElevatedButton(
                onPressed: _loadIpAll,
                child: const Text("Cek List IP"),
              ),
              Expanded(
                child: buildResponsiveTable(context, listIPReg, [
                  "No",
                  "IP Computer",
                  "MAC",
                  "Ruang",
                  "Keterangan",
                ]),
              ),
            ],
          ),
          // 🟦 Tab 3: List IP by Ruang
          Column(
            children: [
              DropdownButton<String>(
                hint: const Text("Pilih Ruangan"),
                value: selectedRuang,
                items: listRuangan
                    .map<DropdownMenuItem<String>>(
                      (r) => DropdownMenuItem<String>(
                        value: r["RuangId"]?.toString(),
                        child: Text(r["RuangDesk"]?.toString() ?? "-"),
                      ),
                    )
                    .toList(),
                onChanged: (val) async {
                  setState(() => selectedRuang = val);
                  if (val != null) {
                    listIPRuang = await fetchIpByRuang(val);
                    setState(() {});
                  }
                },
              ),
              ElevatedButton(
                onPressed: _loadRuangan,
                child: const Text("Ambil List Ruangan"),
              ),
              Expanded(
                child: buildResponsiveTable(context, listIPRuang, [
                  "No",
                  "IP Computer",
                  "MAC",
                  "Ruang",
                  "Keterangan",
                ]),
              ),
            ],
          ),

          // 🟦 Tab 4: Tools CORS
          Column(
            children: [
              TextField(
                controller: ipController,
                decoration: const InputDecoration(hintText: "Masukkan IP"),
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      bool ok = await postCors(ipController.text);
                      _showSnack(ok ? "Berhasil tambah" : "Gagal", error: !ok);
                    },
                    child: const Text("Post"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      bool ok = await aktifCors(ipController.text);
                      _showSnack(ok ? "Berhasil aktif" : "Gagal", error: !ok);
                    },
                    child: const Text("Aktif"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      bool ok = await inaktifCors(ipController.text);
                      _showSnack(
                        ok ? "Berhasil nonaktif" : "Gagal",
                        error: !ok,
                      );
                    },
                    child: const Text("Nonaktif"),
                  ),
                ],
              ),
            ],
          ),

          // 🟦 Tab 5: IP MAC
          Column(
            children: [
              TextField(
                controller: ipController,
                decoration: const InputDecoration(labelText: "IP"),
              ),
              TextField(
                controller: macController,
                decoration: const InputDecoration(labelText: "MAC"),
              ),
              ElevatedButton(
                onPressed: () async {
                  listResult = await fetchIpMac(
                    ipController.text,
                    macController.text,
                  );
                  setState(() {});
                },
                child: const Text("Cari"),
              ),
              Expanded(
                child: MediaQuery.of(context).size.width < 600
                    ? ListView.builder(
                        itemCount: listResult.length,
                        itemBuilder: (ctx, i) {
                          final item = listResult[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(child: Text("${i + 1}")),
                              title: Text("${item["IPComputer"]}"),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("MAC: ${item["MacAddress"] ?? "-"}"),
                                  Text("Ruang: ${item["RuangId"] ?? "-"}"),
                                  Text("Ket: ${item["Keterangan"] ?? "-"}"),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  bool ok = await deleteIpMac(
                                    item["IPComputer"],
                                    item["MacAddress"],
                                  );
                                  if (ok)
                                    setState(() => listResult.removeAt(i));
                                },
                              ),
                            ),
                          );
                        },
                      )
                    : buildResponsiveTable(context, listResult, [
                        "No",
                        "IP Computer",
                        "MAC",
                        "Ruang",
                        "Keterangan",
                      ]),
              ),
              TextField(
                controller: ketController,
                decoration: const InputDecoration(labelText: "Keterangan"),
              ),
              ElevatedButton(
                onPressed: () async {
                  bool ok = await postIpMac(
                    ip: ipController.text,
                    mac: macController.text,
                    ruangId: selectedRuang ?? "",
                    keterangan: ketController.text,
                  );
                  _showSnack(
                    ok ? "Berhasil tambah IP/MAC" : "Gagal",
                    error: !ok,
                  );
                },
                child: const Text("Tambah Baru"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

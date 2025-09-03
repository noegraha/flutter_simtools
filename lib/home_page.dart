import 'package:flutter/material.dart';
import 'package:flutter_simtools/batal_alih_rawat_page.dart';
import 'package:flutter_simtools/catatan_medis_double_page.dart';
import 'package:flutter_simtools/list_ip_page.dart';
import 'package:flutter_simtools/pasien_all_hari_ini_page.dart';
import 'main.dart'; // Pastikan ini import AppThemeMode
import 'login_page.dart'; // Import LoginPage sesuai path Anda

// Menu builder
Widget menuPage(String title) => Center(
  child: Text(
    title,
    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
  ),
);

// List menu dan sub-menu
final menuList = [
  {
    'title': 'Rawat Jalan',
    'icon': Icons.home,
    'items': [
      {'label': 'Batal Alih Rawat', 'widget': const BatalAlihRawatPage()},
      {
        'label': 'Catatan Medis Double',
        'widget': const CatatanMedisDoublePage(),
      },
      {'label': 'Pasien All Hari Ini', 'widget': const PasienAllHariIniPage()},
      // {'label': 'Sinkron Master ICD', 'widget': menuPage('Sinkron Master ICD')},
      // {'label': 'Balik Ruang', 'widget': menuPage('Balik Ruang')},
      // {'label': 'List Antal', 'widget': menuPage('List Antal')},
      // {'label': 'Billing', 'widget': menuPage('Billing')},
      // {'label': 'Telemedicine', 'widget': menuPage('Telemedicine')},
      // {
      //   'label': 'Master Penunjang Lain',
      //   'widget': menuPage('Master Penunjang Lain'),
      // },
      {'label': 'List IP Tools', 'widget': const ListIPPage()},
    ],
  },
  {
    'title': 'Askep',
    'icon': Icons.book,
    'items': [
      {'label': 'Diagnosa Askep', 'widget': menuPage('Diagnosa Askep')},
      {'label': 'Intervensi Askep', 'widget': menuPage('Intervensi Askep')},
      {'label': 'Log Book', 'widget': menuPage('Log Book')},
    ],
  },
];

class HomePage extends StatefulWidget {
  final AppThemeMode appThemeMode;
  final void Function(AppThemeMode) onChangeThemeMode;

  const HomePage({
    super.key,
    required this.appThemeMode,
    required this.onChangeThemeMode,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget currentContent(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      SizedBox(
        width: 100,
        height: 100,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.asset('assets/logosmart.png', fit: BoxFit.cover),
        ),
      ),
      const SizedBox(height: 20),
      const Text(
        'Welcome to SIM Tools',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 10),
      ElevatedButton.icon(
        icon: const Icon(Icons.menu),
        label: const Text('Pilih Menu Disamping'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 24, 159, 255),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
    ],
  );

  int? selectedGroup;
  int? selectedMenu;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SIM Tools'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          PopupMenuButton<AppThemeMode>(
            icon: const Icon(Icons.color_lens),
            tooltip: "Ganti Tema",
            initialValue: widget.appThemeMode,
            onSelected: widget.onChangeThemeMode,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: AppThemeMode.system,
                child: Row(
                  children: [
                    Icon(
                      Icons.phone_android,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    const SizedBox(width: 8),
                    const Text("Ikuti Sistem"),
                    if (widget.appThemeMode == AppThemeMode.system)
                      const Spacer(),
                    if (widget.appThemeMode == AppThemeMode.system)
                      const Icon(Icons.check, size: 18, color: Colors.blue),
                  ],
                ),
              ),
              PopupMenuItem(
                value: AppThemeMode.light,
                child: Row(
                  children: [
                    Icon(Icons.wb_sunny, color: Colors.amber[700]),
                    const SizedBox(width: 8),
                    const Text("Terang"),
                    if (widget.appThemeMode == AppThemeMode.light)
                      const Spacer(),
                    if (widget.appThemeMode == AppThemeMode.light)
                      const Icon(Icons.check, size: 18, color: Colors.blue),
                  ],
                ),
              ),
              PopupMenuItem(
                value: AppThemeMode.dark,
                child: Row(
                  children: [
                    Icon(Icons.nights_stay, color: Colors.blueGrey[800]),
                    const SizedBox(width: 8),
                    const Text("Gelap"),
                    if (widget.appThemeMode == AppThemeMode.dark)
                      const Spacer(),
                    if (widget.appThemeMode == AppThemeMode.dark)
                      const Icon(Icons.check, size: 18, color: Colors.blue),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            // HEADER
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              color: isDark ? Colors.grey[900] : Colors.blue[50],
              child: Text(
                "Menu SIM Tools",
                style: TextStyle(
                  fontSize: 20,
                  color: isDark ? Colors.white : Colors.blue[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // BODY: menu-menu utama, scrollable
            Expanded(
              child: ListView(
                children: [
                  ...menuList.asMap().entries.map((group) {
                    final groupIdx = group.key;
                    final groupData = group.value;
                    final expanded = selectedGroup == groupIdx;
                    return ExpansionTile(
                      leading: Icon(
                        groupData['icon'] as IconData,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      title: Text(
                        groupData['title'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      initiallyExpanded: expanded,
                      children: [
                        ...List<Widget>.generate(
                          (groupData['items'] as List).length,
                          (itemIdx) {
                            final item = (groupData['items'] as List)[itemIdx];
                            final isSelected =
                                selectedMenu == itemIdx &&
                                selectedGroup == groupIdx;
                            return ListTile(
                              title: Text(item['label'] as String),
                              selected: isSelected,
                              selectedTileColor: isDark
                                  ? Colors.blueGrey[900]
                                  : Colors.blue[50],
                              onTap: () {
                                setState(() {
                                  selectedGroup = groupIdx;
                                  selectedMenu = itemIdx;
                                });
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        ),
                      ],
                      onExpansionChanged: (open) {
                        setState(() {
                          selectedGroup = open ? groupIdx : null;
                          selectedMenu = null;
                        });
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
            // FOOTER: tombol logout di bawah sendiri
            SafeArea(
              minimum: const EdgeInsets.only(
                bottom: 12,
                left: 8,
                right: 8,
                top: 6,
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 12,
                  left: 8,
                  right: 8,
                  top: 6,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      // Kembali ke LoginPage dan hapus seluruh navigation stack
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LoginPage(
                            appThemeMode: widget.appThemeMode,
                            onChangeThemeMode: widget.onChangeThemeMode,
                          ),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Builder(
        builder: (context) => Container(
          color: isDark ? Colors.grey[900] : Colors.white,
          width: double.infinity,
          child: (selectedGroup != null && selectedMenu != null)
              ? (((menuList[selectedGroup!] as Map<String, dynamic>)['items']
                            as List)[selectedMenu!]
                        as Map<String, dynamic>)['widget']
                    as Widget
              : currentContent(context),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageChannelsPage extends StatelessWidget {
  const ManageChannelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('کۆنتڕۆڵ پانێڵ', style: TextStyle(color: Colors.orange)),
          backgroundColor: const Color(0xFF1E1E1E),
          bottom: const TabBar(
            indicatorColor: Colors.orange,
            labelColor: Colors.orange,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: Icon(Icons.tv), text: 'کەناڵەکان'),
              Tab(icon: Icon(Icons.view_carousel), text: 'سڵایدەر'),
              Tab(icon: Icon(Icons.ad_units), text: 'ڕیکلام'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ChannelsTab(),
            _SlidersTab(),
            _AdsTab(),
          ],
        ),
      ),
    );
  }
}

// ================= بەشی کەناڵەکان =================
class _ChannelsTab extends StatefulWidget { const _ChannelsTab(); @override State<_ChannelsTab> createState() => _ChannelsTabState(); }
class _ChannelsTabState extends State<_ChannelsTab> {
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _logoController = TextEditingController();
  final _categoryController = TextEditingController();
  bool _isVip = false;

  Future<void> _addChannel() async {
    if (_nameController.text.isEmpty || _urlController.text.isEmpty) return;
    await FirebaseFirestore.instance.collection('channels').add({
      'name': _nameController.text, 
      'stream_url': _urlController.text, 
      'logo_url': _logoController.text, 
      'category': _categoryController.text.isNotEmpty ? _categoryController.text : 'گشتی',
      'is_vip': _isVip, 
      'created_at': FieldValue.serverTimestamp(),
    });
    _nameController.clear(); _urlController.clear(); _logoController.clear(); _categoryController.clear();
    setState(() => _isVip = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('کەناڵ زیادکرا')));
  }

  // پەنجەرەی دەستکاریکردنی کەناڵ
  Future<void> _editChannel(DocumentSnapshot doc) async {
    var data = doc.data() as Map<String, dynamic>;
    final editNameCtrl = TextEditingController(text: data['name']);
    final editUrlCtrl = TextEditingController(text: data['stream_url']);
    final editLogoCtrl = TextEditingController(text: data['logo_url']);
    final editCatCtrl = TextEditingController(text: data['category']);
    bool editVip = data['is_vip'] ?? false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2C2C2C),
              title: const Text('دەستکاریکردنی کەناڵ', style: TextStyle(color: Colors.orange)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: editNameCtrl, decoration: const InputDecoration(labelText: 'ناوی کەناڵ')),
                    const SizedBox(height: 10),
                    TextField(controller: editUrlCtrl, decoration: const InputDecoration(labelText: 'لینکی M3U8')),
                    const SizedBox(height: 10),
                    TextField(controller: editLogoCtrl, decoration: const InputDecoration(labelText: 'لینکی لۆگۆ')),
                    const SizedBox(height: 10),
                    TextField(controller: editCatCtrl, decoration: const InputDecoration(labelText: 'کاتیگۆری')),
                    const SizedBox(height: 10),
                    SwitchListTile(title: const Text('VIP'), value: editVip, activeColor: Colors.yellow, onChanged: (v) => setState(() => editVip = v)),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('پاشگەزبوونەوە', style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: () async {
                    await FirebaseFirestore.instance.collection('channels').doc(doc.id).update({
                      'name': editNameCtrl.text,
                      'stream_url': editUrlCtrl.text,
                      'logo_url': editLogoCtrl.text,
                      'category': editCatCtrl.text.isNotEmpty ? editCatCtrl.text : 'گشتی',
                      'is_vip': editVip,
                    });
                    if (context.mounted) Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('گۆڕانکارییەکان سەیڤ کران')));
                  },
                  child: const Text('پاشەکەوتکردن', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'ناوی کەناڵ', border: OutlineInputBorder()))),
              const SizedBox(width: 10),
              Expanded(flex: 2, child: TextField(controller: _urlController, decoration: const InputDecoration(labelText: 'لینکی M3U8', border: OutlineInputBorder()))),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: TextField(controller: _logoController, decoration: const InputDecoration(labelText: 'لینکی لۆگۆ', border: OutlineInputBorder()))),
              const SizedBox(width: 10),
              Expanded(child: TextField(controller: _categoryController, decoration: const InputDecoration(labelText: 'کاتیگۆری', border: OutlineInputBorder()))),
              const SizedBox(width: 10),
              const Text('VIP'), Switch(value: _isVip, activeColor: Colors.yellow, onChanged: (v) => setState(() => _isVip = v)),
              const SizedBox(width: 10),
              ElevatedButton(onPressed: _addChannel, style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text('زیادکردن', style: TextStyle(color: Colors.white))),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('channels').orderBy('created_at', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                var docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    return Card(
                      color: const Color(0xFF2C2C2C),
                      child: ListTile(
                        leading: CircleAvatar(backgroundImage: NetworkImage(data['logo_url'] ?? '')),
                        title: Text(data['name'] ?? ''),
                        subtitle: Text(data['category'] ?? 'گشتی', style: const TextStyle(color: Colors.orange)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _editChannel(docs[index])), // دوگمەی دەستکاریکردن
                            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => FirebaseFirestore.instance.collection('channels').doc(docs[index].id).delete()),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ================= بەشی سڵایدەر =================
class _SlidersTab extends StatefulWidget { const _SlidersTab(); @override State<_SlidersTab> createState() => _SlidersTabState(); }
class _SlidersTabState extends State<_SlidersTab> {
  final _imageController = TextEditingController();

  Future<void> _addSlider() async {
    if (_imageController.text.isEmpty) return;
    await FirebaseFirestore.instance.collection('sliders').add({'image_url': _imageController.text, 'created_at': FieldValue.serverTimestamp()});
    _imageController.clear();
  }

  // پەنجەرەی دەستکاریکردنی سڵایدەر
  Future<void> _editSlider(DocumentSnapshot doc) async {
    final editImgCtrl = TextEditingController(text: doc['image_url']);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2C),
          title: const Text('دەستکاریکردنی سڵایدەر', style: TextStyle(color: Colors.orange)),
          content: TextField(controller: editImgCtrl, decoration: const InputDecoration(labelText: 'لینکی وێنەی نوێ')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('پاشگەزبوونەوە', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () async {
                await FirebaseFirestore.instance.collection('sliders').doc(doc.id).update({'image_url': editImgCtrl.text});
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('پاشەکەوتکردن', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: TextField(controller: _imageController, decoration: const InputDecoration(labelText: 'لینکی وێنەی سڵایدەر', border: OutlineInputBorder()))),
              const SizedBox(width: 10),
              ElevatedButton(onPressed: _addSlider, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue), child: const Text('زیادکردن', style: TextStyle(color: Colors.white))),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('sliders').orderBy('created_at', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    return Card(
                      color: const Color(0xFF2C2C2C),
                      child: ListTile(
                        leading: Image.network(doc['image_url'], width: 80, fit: BoxFit.cover),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _editSlider(doc)), // دوگمەی دەستکاریکردن
                            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => FirebaseFirestore.instance.collection('sliders').doc(doc.id).delete()),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ================= بەشی ڕیکلام =================
// تێبینی: بەشی ڕیکلام لە خۆیدا پرۆسەی "دەستکاریکردنە" چونکە تەنها یەک شریتی ڕیکلاممان هەیە و بەردەوام ئەپدەیت دەکرێتەوە
class _AdsTab extends StatefulWidget { const _AdsTab(); @override State<_AdsTab> createState() => _AdsTabState(); }
class _AdsTabState extends State<_AdsTab> {
  final _adImageController = TextEditingController();

  @override
  void initState() { super.initState(); _loadCurrentAd(); }

  Future<void> _loadCurrentAd() async {
    var doc = await FirebaseFirestore.instance.collection('ads').doc('banner').get();
    if (doc.exists) setState(() => _adImageController.text = doc['image_url'] ?? '');
  }

  Future<void> _updateAd() async {
    await FirebaseFirestore.instance.collection('ads').doc('banner').set({'image_url': _adImageController.text});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ڕیکلامەکە سەیڤ کرا')));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('دەستکاریکردنی شریتی ڕیکلامی نێوان کاتیگۆرییەکان', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(controller: _adImageController, decoration: const InputDecoration(labelText: 'لینکی وێنەی ڕیکلامەکە', border: OutlineInputBorder())),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: _updateAd, 
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)), 
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit, color: Colors.white),
                  SizedBox(width: 8),
                  Text('نوێکردنەوەی ڕیکلام', style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              )
            )
          ),
        ],
      ),
    );
  }
}

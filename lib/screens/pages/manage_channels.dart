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
            indicatorColor: Colors.orange, labelColor: Colors.orange, unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: Icon(Icons.tv), text: 'کەناڵەکان'),
              Tab(icon: Icon(Icons.view_carousel), text: 'سڵایدەر'),
              Tab(icon: Icon(Icons.ad_units), text: 'ڕیکلامەکان'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [ _ChannelsTab(), _SlidersTab(), _AdsTab() ],
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
      'name': _nameController.text, 'stream_url': _urlController.text, 'logo_url': _logoController.text, 
      'category': _categoryController.text.isNotEmpty ? _categoryController.text : 'گشتی',
      'is_vip': _isVip, 'created_at': FieldValue.serverTimestamp(),
    });
    _nameController.clear(); _urlController.clear(); _logoController.clear(); _categoryController.clear();
    setState(() => _isVip = false);
  }

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
                      'name': editNameCtrl.text, 'stream_url': editUrlCtrl.text, 'logo_url': editLogoCtrl.text,
                      'category': editCatCtrl.text.isNotEmpty ? editCatCtrl.text : 'گشتی', 'is_vip': editVip,
                    });
                    if (context.mounted) Navigator.pop(context);
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
              ElevatedButton(onPressed: _addChannel, style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text('زیادکردن')),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('channels').orderBy('created_at', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    var data = doc.data() as Map<String, dynamic>;
                    return Card(
                      color: const Color(0xFF2C2C2C),
                      child: ListTile(
                        leading: CircleAvatar(backgroundImage: NetworkImage(data['logo_url'] ?? '')),
                        title: Text(data['name'] ?? ''), subtitle: Text(data['category'] ?? 'گشتی', style: const TextStyle(color: Colors.orange)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _editChannel(doc)),
                            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => FirebaseFirestore.instance.collection('channels').doc(doc.id).delete()),
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
  final _linkController = TextEditingController();

  Future<void> _addSlider() async {
    if (_imageController.text.isEmpty) return;
    await FirebaseFirestore.instance.collection('sliders').add({'image_url': _imageController.text, 'click_url': _linkController.text, 'created_at': FieldValue.serverTimestamp()});
    _imageController.clear(); _linkController.clear();
  }

  Future<void> _editSlider(DocumentSnapshot doc) async {
    var data = doc.data() as Map<String, dynamic>;
    final editImgCtrl = TextEditingController(text: data['image_url']);
    final editLinkCtrl = TextEditingController(text: data['click_url'] ?? '');
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2C), title: const Text('دەستکاریکردنی سڵایدەر', style: TextStyle(color: Colors.orange)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: editImgCtrl, decoration: const InputDecoration(labelText: 'لینکی وێنە')),
              const SizedBox(height: 10),
              TextField(controller: editLinkCtrl, decoration: const InputDecoration(labelText: 'لینکی دەرەکی (کە کلیکی لێکرا)')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('پاشگەزبوونەوە', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () async {
                await FirebaseFirestore.instance.collection('sliders').doc(doc.id).update({'image_url': editImgCtrl.text, 'click_url': editLinkCtrl.text});
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
              Expanded(child: TextField(controller: _linkController, decoration: const InputDecoration(labelText: 'لینکی دەرەکی (ئارەزوومەندانە)', border: OutlineInputBorder()))),
              const SizedBox(width: 10),
              ElevatedButton(onPressed: _addSlider, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue), child: const Text('زیادکردن')),
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
                        title: Text((doc.data() as Map<String, dynamic>)['click_url'] != null && (doc.data() as Map<String, dynamic>)['click_url'].toString().isNotEmpty ? 'لینکدارە 🔗' : 'بێ لینک'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _editSlider(doc)),
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

// ================= بەشی ڕیکلامەکان =================
class _AdsTab extends StatefulWidget { const _AdsTab(); @override State<_AdsTab> createState() => _AdsTabState(); }
class _AdsTabState extends State<_AdsTab> {
  String _adType = 'image';
  final _imgController = TextEditingController();
  final _linkController = TextEditingController();
  final _scriptController = TextEditingController();

  Future<void> _addAd() async {
    await FirebaseFirestore.instance.collection('ads').add({
      'type': _adType,
      'image_url': _imgController.text,
      'click_url': _linkController.text,
      'script_code': _scriptController.text,
      'created_at': FieldValue.serverTimestamp(),
    });
    _imgController.clear(); _linkController.clear(); _scriptController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              const Text('جۆری ڕیکلام: ', style: TextStyle(color: Colors.orange, fontSize: 16)),
              DropdownButton<String>(
                value: _adType, dropdownColor: const Color(0xFF2C2C2C),
                items: const [
                  DropdownMenuItem(value: 'image', child: Text('وێنە + لینک')),
                  DropdownMenuItem(value: 'script', child: Text('سکریپت / کۆد (Adsterra هتد..)')),
                ],
                onChanged: (val) => setState(() => _adType = val!),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_adType == 'image') ...[
            Row(
              children: [
                Expanded(child: TextField(controller: _imgController, decoration: const InputDecoration(labelText: 'لینکی وێنە', border: OutlineInputBorder()))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _linkController, decoration: const InputDecoration(labelText: 'لینکی دەرەکی بۆ کرتن', border: OutlineInputBorder()))),
              ],
            ),
          ] else ...[
            TextField(controller: _scriptController, maxLines: 3, decoration: const InputDecoration(labelText: 'کۆدی HTML / Script لێرە دابنێ', border: OutlineInputBorder())),
          ],
          const SizedBox(height: 10),
          ElevatedButton(onPressed: _addAd, style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text('زیادکردنی ڕیکلام')),
          const Divider(height: 40, color: Colors.grey),
          
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('ads').orderBy('created_at', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    var data = doc.data() as Map<String, dynamic>;
                    bool isScript = data['type'] == 'script';
                    // بۆ ئەوەی ڕیکلامە کۆنەکەی پێشووتر کە تەنها banner بوو نەیخوێنێتەوە بە هەڵە
                    if(doc.id == 'banner') return const SizedBox(); 
                    
                    return Card(
                      color: const Color(0xFF2C2C2C),
                      child: ListTile(
                        leading: Icon(isScript ? Icons.code : Icons.image, color: Colors.orange, size: 30),
                        title: Text(isScript ? 'ڕیکلامی سکریپت' : 'ڕیکلامی وێنە'),
                        subtitle: Text(isScript ? 'کۆدێکی تێدایە' : (data['click_url'] ?? '')),
                        trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => FirebaseFirestore.instance.collection('ads').doc(doc.id).delete()),
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

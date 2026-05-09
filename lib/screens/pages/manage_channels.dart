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
  bool _isVip = false;

  Future<void> _addChannel() async {
    if (_nameController.text.isEmpty || _urlController.text.isEmpty) return;
    await FirebaseFirestore.instance.collection('channels').add({
      'name': _nameController.text, 'stream_url': _urlController.text, 'logo_url': _logoController.text, 'is_vip': _isVip, 'created_at': FieldValue.serverTimestamp(),
    });
    _nameController.clear(); _urlController.clear(); _logoController.clear();
    setState(() => _isVip = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('کەناڵ زیادکرا')));
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
              Expanded(flex: 2, child: TextField(controller: _logoController, decoration: const InputDecoration(labelText: 'لینکی لۆگۆ', border: OutlineInputBorder()))),
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
                        trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => FirebaseFirestore.instance.collection('channels').doc(docs[index].id).delete()),
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
    await FirebaseFirestore.instance.collection('sliders').add({
      'image_url': _imageController.text, 'created_at': FieldValue.serverTimestamp(),
    });
    _imageController.clear();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('وێنەی سڵایدەر زیادکرا')));
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
                var docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: const Color(0xFF2C2C2C),
                      child: ListTile(
                        leading: Image.network(docs[index]['image_url'], width: 80, fit: BoxFit.cover),
                        title: const Text('وێنەی سڵایدەر'),
                        trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => FirebaseFirestore.instance.collection('sliders').doc(docs[index].id).delete()),
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

// ================= بەشی ڕیکلام (شریتی ناوەڕاست) =================
class _AdsTab extends StatefulWidget { const _AdsTab(); @override State<_AdsTab> createState() => _AdsTabState(); }
class _AdsTabState extends State<_AdsTab> {
  final _adImageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurrentAd();
  }

  Future<void> _loadCurrentAd() async {
    var doc = await FirebaseFirestore.instance.collection('ads').doc('banner').get();
    if (doc.exists) setState(() => _adImageController.text = doc['image_url'] ?? '');
  }

  Future<void> _updateAd() async {
    await FirebaseFirestore.instance.collection('ads').doc('banner').set({
      'image_url': _adImageController.text,
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ڕیکلامەکە نوێکرایەوە')));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('شریتی ڕیکلامی نێوان کەناڵەکان', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(controller: _adImageController, decoration: const InputDecoration(labelText: 'لینکی وێنەی ڕیکلامەکە (Banner Image)', border: OutlineInputBorder())),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: _updateAd, 
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)), 
              child: const Text('پاشەکەوتکردنی ڕیکلام', style: TextStyle(color: Colors.white, fontSize: 16))
            ),
          ),
        ],
      ),
    );
  }
}

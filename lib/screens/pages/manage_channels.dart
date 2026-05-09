import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageChannelsPage extends StatefulWidget {
  const ManageChannelsPage({super.key});

  @override
  State<ManageChannelsPage> createState() => _ManageChannelsPageState();
}

class _ManageChannelsPageState extends State<ManageChannelsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _logoController = TextEditingController(); // فایلی لۆگۆ زیادکرا
  bool _isVip = false;

  Future<void> _addChannel() async {
    // دڵنیابوون لەوەی ناو و لینک و لۆگۆ پڕکراونەتەوە
    if (_nameController.text.isEmpty || _urlController.text.isEmpty || _logoController.text.isEmpty) return;

    await FirebaseFirestore.instance.collection('channels').add({
      'name': _nameController.text,
      'stream_url': _urlController.text,
      'logo_url': _logoController.text, // لۆگۆکە دەنێرێت بۆ فایەربەیس
      'is_vip': _isVip,
      'created_at': FieldValue.serverTimestamp(),
    });

    _nameController.clear();
    _urlController.clear();
    _logoController.clear(); // پاککردنەوەی شوێنی لۆگۆکە
    setState(() => _isVip = false);
    
    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('کەناڵەکە بە سەرکەوتوویی زیادکرا')));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('زیادکردنی کەناڵی نوێ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(8)),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'ناوی کەناڵ', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _urlController,
                      decoration: const InputDecoration(labelText: 'لینکی پەخش (M3U8)', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _logoController,
                      decoration: const InputDecoration(labelText: 'لینکی لۆگۆ (بۆ نموونە: .png یان .jpg)', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Row(
                    children: [
                      const Text('VIP'),
                      Switch(
                        value: _isVip,
                        activeColor: Colors.yellow,
                        onChanged: (val) => setState(() => _isVip = val),
                      ),
                    ],
                  ),
                  const SizedBox(width: 15),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20)),
                    onPressed: _addChannel,
                    child: const Text('پاشەکەوتکردن', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        const Text('لیستی کەناڵەکان', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        
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
                      // پیشاندانی لۆگۆکە لەناو لیستی ئەدمین بە بچووکی
                      leading: data['logo_url'] != null && data['logo_url'].toString().isNotEmpty
                          ? Image.network(data['logo_url'], width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.error))
                          : const Icon(Icons.tv, size: 50),
                      title: Text(data['name'] ?? ''),
                      subtitle: Text(data['stream_url'] ?? '', style: const TextStyle(color: Colors.grey)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (data['is_vip'] == true) 
                            Container(padding: const EdgeInsets.all(4), color: Colors.yellow, child: const Text('VIP', style: TextStyle(color: Colors.black, fontSize: 10))),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => FirebaseFirestore.instance.collection('channels').doc(docs[index].id).delete(),
                          ),
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
    );
  }
}

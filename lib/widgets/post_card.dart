import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/post.dart';

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(child: Text(post.userName[0])),
            title: Text(post.userName),
            subtitle: Text(
              DateFormat('MMM d, y • h:mm a').format(post.timestamp),
            ),
          ),
          Image.network(
            post.imageUrl,
            width: double.infinity,
            fit: BoxFit.cover,
            height: 200,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(post.description),
          ),
        ],
      ),
    );
  }
}

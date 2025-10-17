import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Quick verification script for Supabase Storage bucket
/// 
/// Run with: dart run .kiro/specs/01-file-upload-system/verify-bucket.dart
/// 
/// This script checks:
/// - Bucket exists and is accessible
/// - Can list files in the bucket
/// - Provides bucket information

void main() async {
  print('🔍 Verifying Supabase Storage Bucket Configuration...\n');

  // Load environment variables from .env.local
  final envFile = File('.env.local');
  if (!await envFile.exists()) {
    print('❌ Error: .env.local file not found');
    exit(1);
  }

  final envContent = await envFile.readAsString();
  final envLines = envContent.split('\n');
  
  String? supabaseUrl;
  String? supabaseAnonKey;
  
  for (final line in envLines) {
    if (line.startsWith('SUPABASE_URL=')) {
      supabaseUrl = line.split('=')[1].trim();
    } else if (line.startsWith('SUPABASE_ANON_KEY=')) {
      supabaseAnonKey = line.split('=')[1].trim();
    }
  }

  if (supabaseUrl == null || supabaseAnonKey == null) {
    print('❌ Error: SUPABASE_URL or SUPABASE_ANON_KEY not found in .env.local');
    exit(1);
  }

  print('📡 Connecting to Supabase...');
  print('   URL: $supabaseUrl\n');

  try {
    // Initialize Supabase
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );

    final supabase = Supabase.instance.client;
    const bucketName = 'property-media';

    print('✅ Connected to Supabase\n');
    print('🗂️  Checking bucket: $bucketName...\n');

    // Try to list files in the bucket
    try {
      final files = await supabase.storage.from(bucketName).list();
      
      print('✅ Bucket "$bucketName" exists and is accessible!');
      print('   Files/folders in bucket: ${files.length}');
      
      if (files.isNotEmpty) {
        print('\n📁 Contents:');
        for (final file in files.take(5)) {
          print('   - ${file.name} (${file.metadata?['size'] ?? 'unknown size'})');
        }
        if (files.length > 5) {
          print('   ... and ${files.length - 5} more');
        }
      } else {
        print('   (Bucket is empty - this is normal for a new setup)');
      }

      print('\n✅ Bucket verification successful!');
      print('\n📋 Next steps:');
      print('   1. Configure bucket policies using the SQL script');
      print('   2. Run the Flutter app and test file upload');
      print('   3. Check the Supabase dashboard to see uploaded files');
      
    } catch (e) {
      if (e.toString().contains('not found') || e.toString().contains('does not exist')) {
        print('❌ Bucket "$bucketName" does not exist!');
        print('\n📝 To create the bucket:');
        print('   1. Go to: https://app.supabase.com/project/jwbdrjcddfkirzcxzbjv/storage/buckets');
        print('   2. Click "New bucket"');
        print('   3. Name: property-media');
        print('   4. Check "Public bucket"');
        print('   5. Click "Create bucket"');
      } else {
        print('❌ Error accessing bucket: $e');
      }
      exit(1);
    }

  } catch (e) {
    print('❌ Error connecting to Supabase: $e');
    exit(1);
  }
}

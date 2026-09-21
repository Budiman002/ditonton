import 'package:ditonton/common/constants.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  static const ROUTE_NAME = '/about';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TODO HAPUS SEBELUM SUBMIT - tombol uji coba Firebase
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'debugAnalytics',
            backgroundColor: Colors.green,
            icon: Icon(Icons.analytics),
            label: Text('Test Analytics'),
            onPressed: () async {
              await FirebaseAnalytics.instance.logEvent(
                name: 'test_event',
                parameters: {'source': 'debug_button'},
              );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('test_event terkirim ke Analytics')),
              );
            },
          ),
          SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'debugCrash',
            backgroundColor: Colors.red,
            icon: Icon(Icons.bug_report),
            label: Text('Test Crash'),
            onPressed: () {
              FirebaseCrashlytics.instance.log('Crash uji coba dari AboutPage');
              FirebaseCrashlytics.instance.crash();
            },
          ),
        ],
      ),
      // TODO HAPUS SEBELUM SUBMIT - sampai sini
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  color: kPrussianBlue,
                  child: Center(
                    child: Image.asset(
                      'assets/circle-g.png',
                      width: 128,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(32.0),
                  color: kMikadoYellow,
                  child: Text(
                    'Ditonton merupakan sebuah aplikasi katalog film yang dikembangkan oleh Dicoding Indonesia sebagai contoh proyek aplikasi untuk kelas Menjadi Flutter Developer Expert.',
                    style: TextStyle(color: Colors.black87, fontSize: 16),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
            ],
          ),
          SafeArea(
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back),
            ),
          )
        ],
      ),
    );
  }
}

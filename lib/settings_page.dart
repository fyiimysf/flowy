import 'package:floi/main.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}


class _SettingsPageState extends State<SettingsPage> {
  late Box<DailyData> dailyDataBox = Hive.box<DailyData>('dailyData');

  Future<void> _deleteAllData() async {
    // Clear Hive data
    dailyDataBox.clear();

    // Reset local state
    // _predictedPeriods = [];

    // Force UI refresh
    setState(() {});

    // Optional: Show confirmation snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        backgroundColor: Color.fromARGB(113, 233, 30, 98),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(40),
        content: Column(
          children: [
            Icon(Icons.delete, size: 40, color: Colors.white),
            Text('All data has been deleted', style: TextStyle(fontSize: 16, color: Colors.white), textAlign: TextAlign.center,),
          ],
        ),
        duration: Duration(seconds: 4),
      ),
    );
  }

  Future<void> _confirmDataDeletion() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Factory Reset'),
          content: Text(
              'Are you sure you want to delete all data? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteAllData();

                // Add your data deletion logic here
                Navigator.of(context).pop();
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text('Flowy', style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
          SizedBox(height: 40),
          Text('General', style: Theme.of(context).textTheme.titleLarge),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About', style: Theme.of(context).textTheme.titleMedium),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Show about dialog
            },
          ),
          ListTile(
            leading: Icon(Icons.language),
            title:
                Text('Language', style: Theme.of(context).textTheme.titleMedium),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Handle language selection
            },
          ),
          ListTile(
            leading: Icon(Icons.color_lens),
            title: Text('Theme', style: Theme.of(context).textTheme.titleMedium),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Handle theme selection
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Advanced Settings',
                style: Theme.of(context).textTheme.titleMedium),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Handle advanced settings
            },
          ),
          SizedBox(height: 40),
          Text('Other Settings', style: Theme.of(context).textTheme.titleLarge),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Help', style: Theme.of(context).textTheme.titleMedium),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Handle help
            },
          ),
          ListTile(
            leading: Icon(Icons.feedback),
            title: Text('Feedback',
                style: Theme.of(context).textTheme.titleMedium),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Handle feedback
            },
          ),
          SizedBox(height: 40),
          
          ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text('Factory Reset',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.red)),
            subtitle: Text('Delete all data and settings',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.red)),
            onTap: _confirmDataDeletion,
            // Handle logout
          ),
        ],
      ),
    );
  }
}

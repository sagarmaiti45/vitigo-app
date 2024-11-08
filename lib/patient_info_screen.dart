import 'package:flutter/material.dart';
import 'package:vitogo_1/treatment_plans_screen.dart';
import 'medical_history_screen.dart';
import 'medications_screen.dart';
import 'vitiligo_assessments_screen.dart';
import 'patient_details_screen.dart'; // Import individual screens

class PatientInfoScreen extends StatelessWidget {
  const PatientInfoScreen({Key? key}) : super(key: key);

  void navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Info'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildNavigationCard(
              context,
              'Patient Details',
              Icons.person,
              Colors.blue,
              const PatientDetailsScreen(),
            ),
            _buildNavigationCard(
              context,
              'Medical History',
              Icons.history,
              Colors.green,
              const MedicalHistoryScreen(),
            ),
            _buildNavigationCard(
              context,
              'Medications',
              Icons.medication,
              Colors.orange,
              const MedicationsScreen(),
            ),
            _buildNavigationCard(
              context,
              'Vitiligo Assessments',
              Icons.assessment,
              Colors.purple,
              const VitiligoAssessmentsScreen(),
            ),
            _buildNavigationCard(
              context,
              'Treatment Plans',
              Icons.local_hospital,
              Colors.red,
              const TreatmentPlansScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationCard(BuildContext context, String title, IconData icon, Color color, Widget destination) {
    return GestureDetector(
      onTap: () => navigateTo(context, destination),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        color: color.withOpacity(0.7),
        child: ListTile(
          leading: Icon(icon, size: 40, color: Colors.white),
          title: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/services/firestore_service.dart';
import '../../../../data/models/appointment_model.dart';
import '../../../../data/models/doctor_model.dart';
import '../../../../data/models/screening_model.dart';
import '../chat/doctor_chat_list_screen.dart';

class DoctorDashboardScreen extends ConsumerStatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  ConsumerState<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends ConsumerState<DoctorDashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Doctor Dashboard',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.pushNamed(context, '/doctor-profile');
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildStatisticsView(user.uid),
          _buildAppointmentsView(user.uid),
          _buildPatientsView(user.uid),
          _buildChatsView(),
          _buildHistoryView(user.uid),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.analytics,
                  label: 'Statistics',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.calendar_today,
                  label: 'Appointments',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.people,
                  label: 'Patients',
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.chat_rounded,
                  label: 'Chats',
                  index: 3,
                ),
                _buildNavItem(
                  icon: Icons.history,
                  label: 'History',
                  index: 4,
                ),
                _buildLogoutButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentsView(String doctorId) {
    return StreamBuilder<List<AppointmentModel>>(
      stream: _firestoreService.streamAllAppointments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print('Error loading appointments: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.dangerRed,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading appointments',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: AppColors.dangerRed,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${snapshot.error}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textLight,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final appointments = snapshot.data ?? [];
        print('Loaded ${appointments.length} appointments');
        
        final pendingAppointments = appointments.where((a) => a.status == 'in_progress').toList();
        final confirmedAppointments = appointments.where((a) => a.status == 'confirmed').toList();
        final deniedAppointments = appointments.where((a) => a.status == 'denied').toList();

        if (appointments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 64,
                  color: AppColors.textLight,
                ),
                const SizedBox(height: 16),
                Text(
                  'No appointments yet',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          );
        }

        return DefaultTabController(
          length: 3,
          child: Column(
            children: [
              TabBar(
                labelColor: AppColors.primaryBlue,
                unselectedLabelColor: AppColors.textLight,
                indicatorColor: AppColors.primaryBlue,
                tabs: [
                  Tab(text: 'Pending (${pendingAppointments.length})'),
                  Tab(text: 'Confirmed (${confirmedAppointments.length})'),
                  Tab(text: 'Denied (${deniedAppointments.length})'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildAppointmentList(pendingAppointments, doctorId, true),
                    _buildAppointmentList(confirmedAppointments, doctorId, false),
                    _buildAppointmentList(deniedAppointments, doctorId, false),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppointmentList(List<AppointmentModel> appointments, String doctorId, bool showActions) {
    if (appointments.isEmpty) {
      return Center(
        child: Text(
          'No appointments in this category',
          style: GoogleFonts.poppins(
            color: AppColors.textLight,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return _buildAppointmentCard(appointment, doctorId, showActions);
      },
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appointment, String doctorId, bool showActions) {
    // Handle empty userId
    if (appointment.userId.isEmpty) {
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Unknown Patient',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
          ),
        ),
      );
    }
    
    return StreamBuilder<Map<String, dynamic>?>(
      stream: _firestoreService.streamUserInfo(appointment.userId),
      builder: (context, snapshot) {
        final patientName = snapshot.data?['name'] ?? 
                            snapshot.data?['displayName'] ?? 
                            snapshot.data?['email'] ?? 
                            'Patient ${appointment.userId.length > 8 ? appointment.userId.substring(0, 8) : appointment.userId}';
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        patientName,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    appointment.status.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(appointment.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: AppColors.textLight),
                const SizedBox(width: 8),
                Text(
                  '${appointment.appointmentDate.day}/${appointment.appointmentDate.month}/${appointment.appointmentDate.year}',
                  style: GoogleFonts.poppins(
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: AppColors.textLight),
                const SizedBox(width: 8),
                Text(
                  appointment.timeSlot,
                  style: GoogleFonts.poppins(
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
            if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Patient Note: ${appointment.notes}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textLight,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            if (showActions) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showApprovalDialog(appointment, doctorId),
                      icon: const Icon(Icons.check, size: 16),
                      label: Text(
                        'Approve',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successGreen,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showDenialDialog(appointment, doctorId),
                      icon: const Icon(Icons.close, size: 16),
                      label: Text(
                        'Deny',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.dangerRed,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'in_progress':
        return Colors.orange;
      case 'confirmed':
        return AppColors.successGreen;
      case 'denied':
        return AppColors.dangerRed;
      default:
        return AppColors.textLight;
    }
  }

  void _showApprovalDialog(AppointmentModel appointment, String doctorId) {
    final TextEditingController notesController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.successGreen,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Approve Appointment',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Add optional notes for the patient:',
              style: GoogleFonts.poppins(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter notes here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).cardTheme.color,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _firestoreService.approveAppointment(
                  appointment.userId,
                  appointment.id,
                  doctorId,
                  notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Appointment approved'),
                      backgroundColor: AppColors.successGreen,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error approving appointment: ${e.toString()}'),
                      backgroundColor: AppColors.dangerRed,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            child: Text(
              'Approve',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDenialDialog(AppointmentModel appointment, String doctorId) {
    final TextEditingController reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.dangerRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.cancel_rounded,
                color: AppColors.dangerRed,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Deny Appointment',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Please provide a reason for denial:',
              style: GoogleFonts.poppins(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter reason here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).cardTheme.color,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentWarningRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accentWarningRed.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.accentWarningRed,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.accentWarningRed,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a reason'),
                    backgroundColor: AppColors.dangerRed,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              try {
                await _firestoreService.denyAppointment(
                  appointment.userId,
                  appointment.id,
                  doctorId,
                  reasonController.text.trim(),
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Appointment denied'),
                      backgroundColor: AppColors.dangerRed,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error denying appointment: ${e.toString()}'),
                      backgroundColor: AppColors.dangerRed,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            child: Text(
              'Deny',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientsView(String doctorId) {
    return StreamBuilder<List<ScreeningModel>>(
      stream: _firestoreService.streamAllScreenings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading patients',
              style: GoogleFonts.poppins(),
            ),
          );
        }

        final screenings = snapshot.data ?? [];
        
        // Get unique patient IDs from all screenings, filtering out invalid IDs
        final uniquePatientIds = screenings
            .map((s) => s.userId)
            .where((uid) => uid.isNotEmpty && uid != 'current_practitioner' && uid.length > 10)
            .toSet()
            .toList();
        
        if (uniquePatientIds.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: AppColors.textLight,
                ),
                const SizedBox(height: 16),
                Text(
                  'No patients yet',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Patients will appear here when they take screenings',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: uniquePatientIds.length,
          itemBuilder: (context, index) {
            final patientId = uniquePatientIds[index];
            return _buildPatientCard(patientId, doctorId);
          },
        );
      },
    );
  }

  Widget _buildPatientCard(String patientId, String doctorId) {
    print('DoctorDashboard: Building patient card for patientId: $patientId');
    return StreamBuilder<Map<String, dynamic>?>(
      stream: _firestoreService.streamUserInfo(patientId),
      builder: (context, snapshot) {
        print('DoctorDashboard: Patient data snapshot: ${snapshot.data}');
        final patientName = snapshot.data?['name'] ?? 
                            snapshot.data?['displayName'] ?? 
                            snapshot.data?['email'] ?? 
                            'Patient ${patientId.substring(0, 8)}';
        print('DoctorDashboard: Patient name: $patientName');
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
              child: Icon(
                Icons.person,
                color: AppColors.primaryBlue,
              ),
            ),
            title: Text(
              patientName,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            subtitle: Text(
              patientId,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textLight,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _showEditNameDialog(patientId, patientName),
                  tooltip: 'Edit Patient Name',
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/doctor-schedule',
                      arguments: {'patientId': patientId},
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatsView() {
    return const DoctorChatListScreen();
  }

  Widget _buildHistoryView(String doctorId) {
    return StreamBuilder<List<ScreeningModel>>(
      stream: _firestoreService.streamAllScreenings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading history',
              style: GoogleFonts.poppins(),
            ),
          );
        }

        final screenings = snapshot.data ?? [];
        
        // Get unique patient IDs from all screenings, filtering out invalid IDs
        final uniquePatientIds = screenings
            .map((s) => s.userId)
            .where((uid) => uid.isNotEmpty && uid != 'current_practitioner' && uid.length > 10)
            .toSet()
            .toList();
        
        if (uniquePatientIds.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: AppColors.textLight,
                ),
                const SizedBox(height: 16),
                Text(
                  'No patient history yet',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: uniquePatientIds.length,
          itemBuilder: (context, index) {
            final patientId = uniquePatientIds[index];
            return _buildHistoryPatientCard(patientId);
          },
        );
      },
    );
  }

  Widget _buildHistoryPatientCard(String patientId) {
    print('DoctorDashboard: Building history patient card for patientId: $patientId');
    return StreamBuilder<Map<String, dynamic>?>(
      stream: _firestoreService.streamUserInfo(patientId),
      builder: (context, snapshot) {
        print('DoctorDashboard: History patient data snapshot: ${snapshot.data}');
        final patientName = snapshot.data?['name'] ?? 
                            snapshot.data?['displayName'] ?? 
                            snapshot.data?['email'] ?? 
                            'Patient ${patientId.substring(0, 8)}';
        print('DoctorDashboard: History patient name: $patientName');
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
              child: Icon(
                Icons.person,
                color: AppColors.primaryBlue,
              ),
            ),
            title: Text(
              patientName,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            subtitle: Text(
              'Tap to view recordings',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textLight,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _showEditNameDialog(patientId, patientName),
                  tooltip: 'Edit Patient Name',
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/doctor-patient-recordings',
                arguments: {'patientId': patientId, 'patientName': patientName},
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatisticsView(String doctorId) {
    return StreamBuilder<List<ScreeningModel>>(
      stream: _firestoreService.streamAllScreenings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print('Statistics error: ${snapshot.error}');
          // If there's an error, show empty state instead of error
          // This handles cases where permissions might not allow collectionGroup queries
          return _buildEmptyStatisticsState();
        }

        final screenings = snapshot.data ?? [];
        
        // Calculate statistics
        final totalScreenings = screenings.length;
        final pdDetected = screenings.where((s) => s.prediction == 1).length;
        final healthy = screenings.where((s) => s.prediction == 0).length;
        final pdRate = totalScreenings > 0 ? (pdDetected / totalScreenings * 100) : 0.0;
        final uniquePatients = screenings.map((s) => s.userId).toSet().length;
        final avgConfidence = totalScreenings > 0 
            ? screenings.fold<double>(0.0, (sum, s) => sum + s.confidenceScore) / totalScreenings 
            : 0.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview Cards
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(
                    'Total Screenings',
                    totalScreenings.toString(),
                    Icons.analytics,
                    AppColors.primaryBlue,
                  ),
                  _buildStatCard(
                    'PD Detected',
                    pdDetected.toString(),
                    Icons.warning,
                    AppColors.dangerRed,
                  ),
                  _buildStatCard(
                    'Healthy',
                    healthy.toString(),
                    Icons.check_circle,
                    AppColors.successGreen,
                  ),
                  _buildStatCard(
                    'Unique Patients',
                    uniquePatients.toString(),
                    Icons.people,
                    AppColors.accentWarningRed,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Detection Rate Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Parkinson\'s Detection Rate',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: pdRate / 100,
                        backgroundColor: AppColors.backgroundLight,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          pdRate > 50 ? AppColors.dangerRed : AppColors.successGreen,
                        ),
                        minHeight: 12,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${pdRate.toStringAsFixed(1)}%',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: pdRate > 50 ? AppColors.dangerRed : AppColors.successGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Average Confidence
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Average Confidence',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${(avgConfidence * 100).toStringAsFixed(1)}%',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Recent Screenings
              Text(
                'Recent Screenings',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 16),
              
              if (screenings.isEmpty)
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No screenings yet',
                        style: GoogleFonts.poppins(
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: screenings.take(3).length,
                  itemBuilder: (context, index) {
                    final screening = screenings[index];
                    return _buildScreeningCard(screening);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreeningCard(ScreeningModel screening) {
    final isDetected = screening.prediction == 1;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isDetected 
              ? AppColors.dangerRed.withOpacity(0.1)
              : AppColors.successGreen.withOpacity(0.1),
          child: Icon(
            isDetected ? Icons.warning : Icons.check,
            color: isDetected ? AppColors.dangerRed : AppColors.successGreen,
          ),
        ),
        title: Text(
          screening.diagnosis,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        subtitle: Text(
          '${screening.userId.substring(0, 8)}... • ${(screening.confidenceScore * 100).toStringAsFixed(1)}% confidence',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textLight,
          ),
        ),
        trailing: Text(
          _formatDate(screening.timestamp),
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: AppColors.textLight,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  Widget _buildEmptyStatisticsState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview Cards with zeros
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                'Total Screenings',
                '0',
                Icons.analytics,
                AppColors.primaryBlue,
              ),
              _buildStatCard(
                'PD Detected',
                '0',
                Icons.warning,
                AppColors.dangerRed,
              ),
              _buildStatCard(
                'Healthy',
                '0',
                Icons.check_circle,
                AppColors.successGreen,
              ),
              _buildStatCard(
                'Unique Patients',
                '0',
                Icons.people,
                AppColors.accentWarningRed,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Detection Rate Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Parkinson\'s Detection Rate',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: 0,
                    backgroundColor: AppColors.backgroundLight,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.successGreen,
                    ),
                    minHeight: 12,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '0.0%',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.successGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Average Confidence
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Average Confidence',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '0.0%',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Recent Screenings
          Text(
            'Recent Screenings',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 16),
          
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: AppColors.textLight,
                ),
                const SizedBox(height: 16),
                Text(
                  'No screenings yet',
                  style: GoogleFonts.poppins(
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Statistics will appear here once patients start using the app',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.dangerRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: AppColors.dangerRed,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Logout',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to logout?',
              style: GoogleFonts.poppins(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentWarningRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accentWarningRed.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.accentWarningRed,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You will need to log in again to access your account',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.accentWarningRed,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/doctor-login',
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryBlue : Theme.of(context).textTheme.bodySmall?.color,
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primaryBlue : Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return InkWell(
      onTap: _showLogoutDialog,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.dangerRed.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.logout_rounded,
              color: AppColors.dangerRed,
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              'Logout',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.dangerRed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditNameDialog(String patientId, String currentName) {
    final TextEditingController nameController = TextEditingController(text: currentName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.edit_outlined,
                color: AppColors.primaryBlue,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Edit Patient Name',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Patient ID: $patientId',
              style: GoogleFonts.poppins(
                color: AppColors.textLight,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Patient Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).cardTheme.color,
              ),
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                try {
                  await _firestoreService.updateUserName(patientId, newName);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Patient name updated successfully'),
                        backgroundColor: AppColors.successGreen,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error updating name: ${e.toString()}'),
                        backgroundColor: AppColors.dangerRed,
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            child: Text(
              'Save',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

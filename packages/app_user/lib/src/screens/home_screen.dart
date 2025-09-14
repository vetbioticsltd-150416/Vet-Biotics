import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vet_biotics_shared/shared.dart';

import '../providers/app_user_provider.dart';
import '../widgets/bottom_navigation_bar.dart';
import 'appointments/appointments_screen.dart';
import 'appointments/book_appointment_screen.dart';
import 'medical/medical_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Widget> _screens = [_DashboardScreen(), _PetsScreen(), const AppointmentsScreen(), _ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppUserProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: _screens[provider.currentIndex],
          bottomNavigationBar: AppBottomNavigationBar(
            currentIndex: provider.currentIndex,
            onTap: provider.setCurrentIndex,
          ),
        );
      },
    );
  }
}

class _DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppUserProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              _buildWelcomeHeader(context, provider.currentUser),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 24),
              _buildUpcomingAppointments(context, provider.appointments),
              const SizedBox(height: 24),
              _buildRecentPets(context, provider.pets),
              const SizedBox(height: 24),
              _buildHealthTips(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, User? user) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
        ? 'Good Afternoon'
        : 'Good Evening';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$greeting${user?.name != null ? ', ${user!.name}' : ''}!', style: AppTheme.headline1),
        const SizedBox(height: 8),
        Text(
          'How can we help your pets today?',
          style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: AppTheme.headline2),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                'Book Appointment',
                Icons.calendar_today,
                AppTheme.primaryColor,
                () => context.go('/appointments/book'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickActionCard(
                context,
                'Add Pet',
                Icons.pets,
                AppTheme.secondaryColor,
                () => Navigator.pushNamed(context, '/add-pet'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                'Medical History',
                Icons.medical_services,
                AppTheme.accentColor,
                () => _showPetSelectionDialog(context, 'medical'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickActionCard(
                context,
                'Billing',
                Icons.receipt,
                AppTheme.infoColor,
                () => Navigator.pushNamed(context, '/billing'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTheme.bodyText2.copyWith(color: color, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingAppointments(BuildContext context, List<Appointment> appointments) {
    final upcomingAppointments = appointments
        .where(
          (appointment) =>
              appointment.status == AppointmentStatus.confirmed && appointment.dateTime.isAfter(DateTime.now()),
        )
        .take(3)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Upcoming Appointments', style: AppTheme.headline2),
            TextButton(
              onPressed: () => context.go('/appointments'),
              child: Text(
                'View All',
                style: AppTheme.bodyText2.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (upcomingAppointments.isEmpty)
          _buildEmptyState('No upcoming appointments')
        else
          ...upcomingAppointments.map((appointment) => _buildAppointmentCard(context, appointment)),
      ],
    );
  }

  Widget _buildAppointmentCard(BuildContext context, Appointment appointment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.calendar_today, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(appointment.petName, style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(
                    '${appointment.dateTime.day}/${appointment.dateTime.month}/${appointment.dateTime.year} at ${appointment.dateTime.hour}:${appointment.dateTime.minute.toString().padLeft(2, '0')}',
                    style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
                  ),
                  const SizedBox(height: 4),
                  Text(appointment.clinicName, style: AppTheme.bodyText2.copyWith(color: AppTheme.primaryColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPets(BuildContext context, List<Pet> pets) {
    final recentPets = pets.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('My Pets', style: AppTheme.headline2),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/pets'),
              child: Text(
                'View All',
                style: AppTheme.bodyText2.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (recentPets.isEmpty)
          _buildEmptyState('No pets added yet')
        else
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recentPets.length,
              itemBuilder: (context, index) {
                final pet = recentPets[index];
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        child: Icon(Icons.pets, color: AppTheme.primaryColor, size: 32),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        pet.name,
                        style: AppTheme.bodyText2.copyWith(fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildHealthTips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Health Tips', style: AppTheme.headline2),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: AppTheme.accentColor),
                    const SizedBox(width: 8),
                    Text('Did you know?', style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Regular veterinary check-ups can help detect health issues early and keep your pets healthy longer.',
                  style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.info_outline, size: 48, color: AppTheme.textHintColor),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showPetSelectionDialog(BuildContext context, String action) async {
    final provider = context.read<AppUserProvider>();
    final pets = provider.pets;

    if (pets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng thêm thú cưng trước')));
      return;
    }

    final selectedPet = await showDialog<Pet>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(action == 'medical' ? 'Chọn thú cưng' : 'Chọn thú cưng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: pets.map((pet) {
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.pets)),
              title: Text(pet.name),
              subtitle: Text(pet.species.name),
              onTap: () => Navigator.of(context).pop(pet),
            );
          }).toList(),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Hủy'))],
      ),
    );

    if (selectedPet != null) {
      if (action == 'medical') {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MedicalHistoryScreen(petId: selectedPet.id!, petName: selectedPet.name),
          ),
        );
      }
    }
  }
}

class _PetsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Pets Screen - Coming Soon'));
  }
}

class _ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Profile Screen - Coming Soon'));
  }
}

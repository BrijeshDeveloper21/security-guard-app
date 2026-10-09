import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';

class JoinSocietyScreen extends ConsumerStatefulWidget {
  const JoinSocietyScreen({super.key});

  @override
  ConsumerState<JoinSocietyScreen> createState() => _JoinSocietyScreenState();
}

class _JoinSocietyScreenState extends ConsumerState<JoinSocietyScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _searchController = TextEditingController();

  int _currentStep = 0;

  // Selections
  String? _selectedSociety;
  String? _selectedWing;
  String? _selectedFlat;
  String? _selectedRole; // 'Owner' or 'Tenant'
  String? _selectedStatus;

  // Mock Data
  final List<String> _mockSocieties = [
    'Sunrise Heights',
    'Green Valley Apartments',
    'Lodha Bellissimo',
    'Hiranandani Estate',
    'Oberoi Splendor',
  ];
  
  final List<String> _mockWings = ['Wing A', 'Wing B', 'Wing C', 'Society Office'];
  final List<String> _mockFlats = ['101', '102', '103', '201', '202', '304', '405', '1204'];

  List<String> _filteredSocieties = [];

  @override
  void initState() {
    super.initState();
    _filteredSocieties = _mockSocieties;
    _searchController.addListener(() {
      setState(() {
        _filteredSocieties = _mockSocieties
            .where((s) => s.toLowerCase().contains(_searchController.text.toLowerCase()))
            .toList();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentStep++);
    } else {
      _submitRequest();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context); // Go back to login
    }
  }

  void _submitRequest() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: AppColors.statusApproved, size: 64),
            const SizedBox(height: 16),
            const Text('Request Sent!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Your request to join $_selectedSociety has been sent to the Admin. You will be able to log in once approved.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx); // close dialog
                Navigator.pop(context); // close wizard, return to login
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, elevation: 0),
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: _prevStep,
        ),
        title: Text(
          'Step ${_currentStep + 1} of 5',
          style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            LinearProgressIndicator(
              value: (_currentStep + 1) / 5,
              backgroundColor: AppColors.borderLight,
              color: AppColors.primary,
              minHeight: 4,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Disable swipe, force button clicks
                children: [
                  _buildStep1SocietySearch(),
                  _buildStep2WingSelection(),
                  _buildStep3FlatSelection(),
                  _buildStep4RoleSelection(),
                  _buildStep5StatusSelection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 1: Search Society
  Widget _buildStep1SocietySearch() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Search your society', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimaryLight)),
          const SizedBox(height: 8),
          const Text('Enter the name of your building or society to join.', style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 14)),
          const SizedBox(height: 24),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'e.g. Sunrise Heights',
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              filled: true,
              fillColor: AppColors.bgLight,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredSocieties.length,
              itemBuilder: (context, index) {
                final society = _filteredSocieties[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(backgroundColor: AppColors.primary.withValues(alpha: 0.1), child: const Icon(Icons.apartment, color: AppColors.primary)),
                  title: Text(society, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.textMutedLight),
                  onTap: () {
                    setState(() => _selectedSociety = society);
                    _nextStep();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // STEP 2: Select Wing
  Widget _buildStep2WingSelection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_selectedSociety ?? '', style: const TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Select your Block / Wing', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimaryLight)),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.5,
              ),
              itemCount: _mockWings.length,
              itemBuilder: (context, index) {
                final wing = _mockWings[index];
                final isSelected = _selectedWing == wing;
                return InkWell(
                  onTap: () {
                    setState(() => _selectedWing = wing);
                    _nextStep();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight),
                      boxShadow: const [BoxShadow(color: AppColors.shadowLight, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: Text(
                      wing,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // STEP 3: Select Flat
  Widget _buildStep3FlatSelection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$_selectedSociety • $_selectedWing', style: const TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Select your Flat No.', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimaryLight)),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
              ),
              itemCount: _mockFlats.length,
              itemBuilder: (context, index) {
                final flat = _mockFlats[index];
                return InkWell(
                  onTap: () {
                    setState(() => _selectedFlat = flat);
                    _nextStep();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                      boxShadow: const [BoxShadow(color: AppColors.shadowLight, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: Text(
                      flat,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimaryLight),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // STEP 4: Owner or Tenant
  Widget _buildStep4RoleSelection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppColors.bgLight, borderRadius: BorderRadius.circular(8)),
            child: Text('$_selectedSociety • $_selectedWing • Flat $_selectedFlat', style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 24),
          const Text('Who are you?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimaryLight)),
          const SizedBox(height: 32),
          _buildSelectionCard(
            title: 'I am an Owner',
            icon: Icons.vpn_key,
            isSelected: _selectedRole == 'Owner',
            onTap: () {
              setState(() => _selectedRole = 'Owner');
              _nextStep();
            },
          ),
          const SizedBox(height: 16),
          _buildSelectionCard(
            title: 'I am a Tenant',
            icon: Icons.luggage,
            isSelected: _selectedRole == 'Tenant',
            onTap: () {
              setState(() => _selectedRole = 'Tenant');
              _nextStep();
            },
          ),
        ],
      ),
    );
  }

  // STEP 5: Status based on Role
  Widget _buildStep5StatusSelection() {
    List<String> options = [];
    if (_selectedRole == 'Owner') {
      options = ['Currently Residing (Self)', 'Home Vacant', 'Tenants Residing', 'Moving In'];
    } else {
      options = ['Currently Residing', 'Moving In'];
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Text('Role: $_selectedRole', style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 24),
          const Text('Occupancy Status', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimaryLight)),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: options.length,
              itemBuilder: (context, index) {
                final status = options[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildSelectionCard(
                    title: status,
                    icon: Icons.check_circle_outline,
                    isSelected: _selectedStatus == status,
                    onTap: () {
                      setState(() => _selectedStatus = status);
                    },
                  ),
                );
              },
            ),
          ),
          // Final Submit Button
          if (_selectedStatus != null)
            ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.statusApproved,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('SUBMIT JOIN REQUEST', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
            ),
        ],
      ),
    );
  }

  // Helper Widget for large selectable cards
  Widget _buildSelectionCard({required String title, required IconData icon, required bool isSelected, required VoidCallback onTap}) {
    return Semantics(
      button: true,
      label: title,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight, width: isSelected ? 2 : 1),
            boxShadow: const [BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: Offset(0, 2))],
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondaryLight, size: 28),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.primary : AppColors.textPrimaryLight,
                ),
              ),
              const Spacer(),
              if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
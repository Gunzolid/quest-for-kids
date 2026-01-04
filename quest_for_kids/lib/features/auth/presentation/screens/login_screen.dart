import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Toggle State
  bool _isParentMode = true;

  // Parent Form Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _parentFormKey = GlobalKey<FormState>();

  // Child Login Step State
  int _childLoginStep = 0; // 0: Find Family, 1: Select Profile, 2: PIN
  String _parentEmail = '';
  String? _selectedParentId;
  List<UserEntity> _siblings = [];
  UserEntity? _selectedChild;
  String _childPasscode = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onParentSubmit() {
    if (_parentFormKey.currentState?.validate() ?? false) {
      ref.read(authControllerProvider.notifier).loginParent(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
    }
  }

  // Child Flow - Step 1: Find Family
  Future<void> _findFamily() async {
    if (_parentEmail.trim().isEmpty) return;

    final controller = ref.read(authControllerProvider.notifier);
    final parent = await controller.findParentByEmail(_parentEmail.trim());

    if (parent != null) {
      final children = await controller.fetchChildren(parent.id);
      setState(() {
        _selectedParentId = parent.id;
        _siblings = children;
        _childLoginStep = 1; // Move to Select Profile
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Family not found')),
        );
      }
    }
  }

  // Child Flow - Step 2: Select Profile
  void _selectChild(UserEntity child) {
    setState(() {
      _selectedChild = child;
      _childPasscode = '';
      _childLoginStep = 2; // Move to PIN
    });
  }

  // Child Flow - Step 3: Verify PIN
  void _onChildPinSubmit() {
    if (_childPasscode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN must be 6 digits')),
      );
      return;
    }
    if (_selectedChild == null || _selectedParentId == null) return;

    ref.read(authControllerProvider.notifier).loginChild(
          _selectedChild!.id,
          _selectedParentId!,
          _childPasscode,
        );
  }

  void _onKeypadTap(String value) {
    if (value == 'DEL') {
      if (_childPasscode.isNotEmpty) {
        setState(() {
          _childPasscode =
              _childPasscode.substring(0, _childPasscode.length - 1);
        });
      }
    } else {
      if (_childPasscode.length < 6) {
        setState(() {
          _childPasscode += value;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for Auth State Changes (Success/Error)
    ref.listen(authControllerProvider, (previous, next) {
      if (!next.isLoading && !next.hasError && next.value != null) {
        // Check user role to decide destination
        final user = next.value!;
        if (user.role == UserRole.parent) {
          context.go('/parent-dashboard');
        } else {
          context.go('/child-dashboard');
        }
      }

      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.error.toString().replaceAll('Exception:', '').trim(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_childLoginStep == 0 || _isParentMode) ...[
                  Text(
                    'QuestForKids',
                    style: GoogleFonts.kanit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildRoleToggle(),
                  const SizedBox(height: 30),
                ],

                // Form Content
                if (_isParentMode)
                  _buildParentForm(isLoading)
                else
                  _buildChildFlow(isLoading),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton('Parent', true),
          _buildToggleButton('Child', false),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isParent) {
    final isSelected = _isParentMode == isParent;
    return GestureDetector(
      onTap: () {
        setState(() {
          _isParentMode = isParent;
          _childLoginStep = 0; // Reset child flow on toggle
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildParentForm(bool isLoading) {
    return Form(
      key: _parentFormKey,
      child: Column(
        children: [
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
            ),
          ),
          const SizedBox(height: 24),
          if (isLoading)
            const CircularProgressIndicator()
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onParentSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Login'),
              ),
            ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.push('/register'),
            child: const Text('Don\'t have an account? Create one'),
          ),
        ],
      ),
    );
  }

  Widget _buildChildFlow(bool isLoading) {
    if (_childLoginStep == 0) return _buildStep1FindFamily(isLoading);
    if (_childLoginStep == 1) return _buildStep2SelectProfile();
    if (_childLoginStep == 2) return _buildStep3EnterPin(isLoading);
    return const SizedBox.shrink();
  }

  Widget _buildStep1FindFamily(bool isLoading) {
    return Column(
      children: [
        const Text(
          'Find Your Family',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          onChanged: (v) => _parentEmail = v,
          decoration: const InputDecoration(
            labelText: "Parent's Email",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 24),
        if (isLoading)
          const CircularProgressIndicator()
        else
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _findFamily,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.orange,
              ),
              child: const Text('Find Family'),
            ),
          ),
      ],
    );
  }

  Widget _buildStep2SelectProfile() {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => setState(() => _childLoginStep = 0),
            ),
            const Text(
              'Who are you?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (_siblings.isEmpty)
          const Text('No child profiles found.')
        else
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: _siblings.map((child) {
              return GestureDetector(
                onTap: () => _selectChild(child),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        child.name[0].toUpperCase(),
                        style: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      child.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildStep3EnterPin(bool isLoading) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => setState(() => _childLoginStep = 1),
            ),
            Text(
              'Hello, ${_selectedChild?.name}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const Text('Enter your 6-digit PIN'),
        const SizedBox(height: 20),

        // Passcode Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            6,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index < _childPasscode.length
                    ? Colors.orange
                    : Colors.grey.shade300,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Keypad
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          childAspectRatio: 1.5,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            ...List.generate(9, (index) => '${index + 1}')
                .map(_buildKeypadButton),
            const SizedBox.shrink(),
            _buildKeypadButton('0'),
            _buildKeypadButton('DEL'),
          ],
        ),
        const SizedBox(height: 24),
        if (isLoading)
          const CircularProgressIndicator()
        else
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _onChildPinSubmit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Enter Quest'),
            ),
          ),
      ],
    );
  }

  Widget _buildKeypadButton(String value) {
    final isDel = value == 'DEL';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onKeypadTap(value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: isDel ? Colors.red.shade50 : Colors.white,
          ),
          alignment: Alignment.center,
          child: isDel
              ? const Icon(Icons.backspace_outlined, color: Colors.red)
              : Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}

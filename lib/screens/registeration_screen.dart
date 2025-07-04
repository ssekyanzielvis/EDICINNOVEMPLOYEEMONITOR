import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../entities/employee.dart';
import '../entities/admin.dart';
import '../provider/auth_provider.dart';
import '../repository/employee_repository_impl.dart';
import '../repository/admin_repository_impl.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _employeeCodeController = TextEditingController();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _departmentController = TextEditingController();
  final _positionController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = 'employee';
  bool _isActive = true;
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _hireDate;
  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _checkEnvConfig();
  }

  void _checkEnvConfig() {
    final serviceRoleKey = dotenv.env['SUPABASE_SERVICE_ROLE_KEY'];
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    if (serviceRoleKey == null || serviceRoleKey.isEmpty) {
      print(
        'Critical Error: SUPABASE_SERVICE_ROLE_KEY is not set or empty in .env',
      );
    }
    if (supabaseUrl == null || supabaseUrl.isEmpty) {
      print('Critical Error: SUPABASE_URL is not set or empty in .env');
    }
  }

  @override
  void dispose() {
    _employeeCodeController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _positionController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final supabase = Supabase.instance.client;
      final userId =
          supabase.auth.currentUser?.id ??
          DateTime.now().millisecondsSinceEpoch.toString();
      final fileName = 'profile_$userId${image.path.split('.').last}';
      await supabase.storage
          .from('profile_images')
          .uploadBinary(
            fileName,
            await image.readAsBytes(),
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );
      final publicUrl = supabase.storage
          .from('profile_images')
          .getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      print('Image upload error: $e');
      if (context.mounted) {
        setState(() {
          _errorMessage = 'Image upload failed: ${e.toString()}';
        });
      }
      return null;
    }
  }

  Future<void> _register() async {
    print('Starting registration for role: $_role');
    if (!_formKey.currentState!.validate()) {
      print('Form validation failed. Field values:');
      print(
        'Email: ${_emailController.text}, Password: ${_passwordController.text}, '
        'Employee Code: ${_employeeCodeController.text}, Name: ${_nameController.text}, '
        'First Name: ${_firstNameController.text}, Last Name: ${_lastNameController.text}, '
        'Department: ${_departmentController.text}, Phone: ${_phoneController.text}, '
        'Position: ${_positionController.text}',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String? profileImageUrl =
        _selectedImage != null ? await _uploadImage(_selectedImage!) : null;

    try {
      final serviceRoleKey = dotenv.env['SUPABASE_SERVICE_ROLE_KEY'];
      final supabaseUrl = dotenv.env['SUPABASE_URL'];
      if (serviceRoleKey == null ||
          serviceRoleKey.isEmpty ||
          supabaseUrl == null ||
          supabaseUrl.isEmpty) {
        throw Exception(
          'Environment misconfiguration: SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY missing',
        );
      }

      final adminClient = SupabaseClient(supabaseUrl, serviceRoleKey);
      print('Admin client initialized with URL: $supabaseUrl');

      print('Attempting to create user with email: ${_emailController.text}');
      final authResponse = await adminClient.auth.admin.createUser(
        AdminUserAttributes(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          emailConfirm: true,
        ),
      );

      if (authResponse.user == null) {
        throw Exception('User creation failed: No user returned from Supabase');
      }

      final userId = authResponse.user!.id;
      print('User created successfully with ID: $userId');

      if (_role == 'admin') {
        print('Registering admin with name: ${_nameController.text}');
        final admin = Admin(
          id: userId,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone:
              _phoneController.text.trim().isEmpty
                  ? null
                  : _phoneController.text.trim(),
          department:
              _departmentController.text.trim().isEmpty
                  ? null
                  : _departmentController.text.trim(),
          position:
              _positionController.text.trim().isEmpty
                  ? null
                  : _positionController.text.trim(),
          hireDate: _hireDate,
          isActive: _isActive,
          role: _role,
          profileImageUrl: profileImageUrl,
          createdAt: DateTime.now(),
        );
        await context.read<AdminRepositoryImpl>().insertAdmin(admin);
        print('Admin registered successfully');
      } else {
        print(
          'Registering employee with code: ${_employeeCodeController.text}',
        );
        final employee = Employee(
          id: userId,
          employeeCode: _employeeCodeController.text.trim(),
          email: _emailController.text.trim(),
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phone:
              _phoneController.text.trim().isEmpty
                  ? null
                  : _phoneController.text.trim(),
          department: _departmentController.text.trim(),
          position:
              _positionController.text.trim().isEmpty
                  ? null
                  : _positionController.text.trim(),
          hireDate: _hireDate,
          isActive: _isActive,
          role: _role,
          profileImageUrl: profileImageUrl,
          createdAt: DateTime.now(),
        );
        await context.read<EmployeeRepositoryImpl>().insertEmployee(employee);
        print('Employee registered successfully');
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful')),
        );
        Navigator.pushReplacementNamed(
          context,
          _role == 'admin' ? '/admin-choice' : '/dashboard',
        );
      }
    } catch (e) {
      print('Registration error details: $e');
      if (context.mounted) {
        setState(() {
          _errorMessage =
              'Registration failed: ${e.toString()}'; // Initial assignment
          if (e.toString().contains('duplicate key value')) {
            _errorMessage =
                _errorMessage! +
                '\n(Possible duplicate email or employee code)';
          } else if (e is AuthApiException && e.statusCode == 422) {
            _errorMessage =
                _errorMessage! +
                '\n(Email already registered, use a unique email)';
          } else if (e is AuthApiException && e.statusCode == 403) {
            _errorMessage =
                _errorMessage! +
                '\n(Verify SUPABASE_SERVICE_ROLE_KEY in .env and Supabase permissions)';
          } else if (e.toString().contains('Environment misconfiguration')) {
            _errorMessage =
                _errorMessage! +
                '\n(Check .env file for SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY)';
          }
        });
      }
    } finally {
      if (context.mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectHireDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _hireDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Register'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await context.read<AuthProvider>().signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _role,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        prefixIcon: Icon(Icons.group),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'employee',
                          child: Text('Employee'),
                        ),
                        DropdownMenuItem(
                          value: 'supervisor',
                          child: Text('Supervisor'),
                        ),
                        DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _role = value!;
                        });
                      },
                      validator:
                          (value) =>
                              value == null ? 'Please select a role' : null,
                    ),
                    const SizedBox(height: 16),
                    if (_role != 'admin') ...[
                      TextFormField(
                        controller: _employeeCodeController,
                        decoration: const InputDecoration(
                          labelText: 'Employee Code',
                          prefixIcon: Icon(Icons.badge),
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value?.isEmpty ?? true
                                    ? 'Employee Code is required'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      validator:
                          (value) =>
                              value?.isEmpty ?? true
                                  ? 'Email is required'
                                  : null,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      validator:
                          (value) =>
                              value?.isEmpty ?? true
                                  ? 'Password is required'
                                  : null,
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    if (_role == 'admin')
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value?.isEmpty ?? true
                                    ? 'Name is required'
                                    : null,
                      ),
                    if (_role != 'admin') ...[
                      TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value?.isEmpty ?? true
                                    ? 'First Name is required'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value?.isEmpty ?? true
                                    ? 'Last Name is required'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone (Optional)',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _departmentController,
                        decoration: const InputDecoration(
                          labelText: 'Department',
                          prefixIcon: Icon(Icons.business),
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value?.isEmpty ?? true
                                    ? 'Department is required'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _positionController,
                        decoration: const InputDecoration(
                          labelText: 'Position (Optional)',
                          prefixIcon: Icon(Icons.work),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: Text(
                          _hireDate == null
                              ? 'Select Hire Date'
                              : 'Hire Date: ${DateFormat.yMMMd().format(_hireDate!)}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: _selectHireDate,
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Active Status'),
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                      ),
                    ],
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : const AssetImage('assets/default_profile.png')
                                    as ImageProvider,
                        child:
                            _selectedImage == null
                                ? const Icon(Icons.camera_alt, size: 40)
                                : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 24),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Register',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      child: const Text('Back to Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

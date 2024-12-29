import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:walkathan/constants/constants.dart';
import '../../../config/router/route_names.dart';
import '../../../models/custom_error.dart';
import '../../../utils/error_dialog.dart';
import '../../widgets/buttons.dart';
import '../../widgets/form_fields.dart';
import 'signup_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  // AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  // final _nameController = TextEditingController();
  // final _emailController = TextEditingController();
  // final _passwordController = TextEditingController();
  // final _genderController = ValueNotifier<String?>(null);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String _gender = 'male'; // Default value
  bool _status = true; // Default value
  String _role = 'member'; //


  void _registerUser() async {
    final url = '${ApiConstants.baseUrl}${ApiConstants.registerEndpoint}';
    final Map<String, String> headers = {"Content-type": "application/json"};
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode({
        'name': _nameController.text,
        'username': _usernameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'c_password': _confirmPasswordController.text,
        'gender': _gender,
        'status': _status,
        'role': _role,
      }),
    );

    if (response.statusCode == 200) {
      // Handle success, possibly save token, navigate to another screen, etc.
      var data = jsonDecode(response.body);
      print('User registered: ${data['name']}');
      // Here you might save the token and navigate to the home screen or login screen
    } else {
      // Handle error
      print('Failed to register user: ${response.body}');
      // Show error message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(
      signupProvider,
      (previous, next) {
        next.whenOrNull(
          error: (e, st) => errorDialog(
            context,
            (e as CustomError),
          ),
        );
      },
    );

    final signupState = ref.watch(signupProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: Text('Register')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(16.0),
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter a name' : null,
              ),
              // Add similar TextFormFields for username, email, password, and confirm password
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter a username' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter an email';
                  }
                  // Basic email validation
                  if (!value!.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value?.isEmpty ?? true ? 'Please enter a password' : null,
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _gender,
                onChanged: (String? newValue) {
                  setState(() {
                    _gender = newValue!;
                  });
                },
                items: <String>['male', 'female', 'other'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Gender'),
                validator: (value) => value == null ? 'Select gender' : null,
              ),
              SwitchListTile(
                title: Text('Active'),
                value: _status,
                onChanged: (bool value) {
                  setState(() {
                    _status = value;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: _role,
                onChanged: (String? newValue) {
                  setState(() {
                    _role = newValue!;
                  });
                },
                items: <String>['admin', 'moderator', 'member'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Role'),
                validator: (value) => value == null ? 'Select role' : null,
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _registerUser();
                  }
                },
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

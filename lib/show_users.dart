import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  List<dynamic> users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8081/ecommerce/ecommerce/project/show_users.php'));
      if (response.statusCode == 200) {
        setState(() {
          users = json.decode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load users')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return users.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  title: Text(
                    '${user['name']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    user['username'] ?? 'No Username',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserDetail(user: user),
                      ),
                    );
                    if (result == true) {
                      fetchUsers();
                    }
                  },
                ),
              );
            },
          );
  }
}

class UserDetail extends StatefulWidget {
  final Map<String, dynamic> user;

  const UserDetail({super.key, required this.user});

  @override
  _UserDetailState createState() => _UserDetailState();
}

class _UserDetailState extends State<UserDetail> {
  bool isEditing = false;
  late TextEditingController NameController;
  late TextEditingController addressController;
  late TextEditingController phoneController;
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  Uint8List? _selectedImageBytes;
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    NameController = TextEditingController(text: widget.user['name'] ?? '');
    addressController = TextEditingController(text: widget.user['address'] ?? '');
    phoneController = TextEditingController(text: widget.user['phone'] ?? '');
    usernameController = TextEditingController(text: widget.user['username'] ?? '');
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    NameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _selectedImagePath = pickedFile.path;
      });
    }
  }

  Future<void> _updateUser() async {
    if (NameController.text.isEmpty ||
        addressController.text.isEmpty ||
        phoneController.text.isEmpty ||
        usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required fields')));
      return;
    }

    if (passwordController.text.isNotEmpty && passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password must be at least 6 characters')));
      return;
    }

    try {
      final url = Uri.parse('http://localhost:8081/ecommerce/ecommerce/project/update_user.php');
      var request = http.MultipartRequest('POST', url);

      request.fields['id'] = widget.user['id'].toString();
      request.fields['name'] = NameController.text;
      request.fields['address'] = addressController.text;
      request.fields['phone'] = phoneController.text;
      request.fields['username'] = usernameController.text;
      request.fields['password'] = passwordController.text;


      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      print('Update user response: $responseBody');

      final responseData = json.decode(responseBody);
      if (responseData['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User updated successfully')));
        setState(() {
          isEditing = false;
          widget.user['name'] = NameController.text;
          widget.user['address'] = addressController.text;
          widget.user['phone'] = phoneController.text;
          widget.user['username'] = usernameController.text;
          passwordController.clear();
          _selectedImageBytes = null;
          _selectedImagePath = null;
        });
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${responseData['message']}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _deleteUser() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8081/ecommerce/ecommerce/project/delete_user.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': widget.user['id'].toString()}),
      );

      final responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User deleted successfully')));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${responseData['message']}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.user['name']}'),
        automaticallyImplyLeading: false, // ลบปุ่มย้อนกลับ
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: isEditing
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: NameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'New Password (optional)',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _updateUser,
                        child: const Text('Save'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isEditing = false;
                            NameController.text = widget.user['name'] ?? '';
                            addressController.text = widget.user['address'] ?? '';
                            phoneController.text = widget.user['phone'] ?? '';
                            usernameController.text = widget.user['username'] ?? '';
                            passwordController.clear();
                            _selectedImageBytes = null;
                            _selectedImagePath = null;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.user['name']}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Username: ${widget.user['username'] ?? 'No Username'}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Address: ${widget.user['address'] ?? 'No Address'}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Phone: ${widget.user['phone'] ?? 'No Phone'}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            isEditing = true;
                          });
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit User'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (widget.user['username'] != 'admin')
                        ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Confirm Delete'),
                                  content: Text(
                                      'Are you sure you want to delete ${widget.user['username']}?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _deleteUser();
                                      },
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.delete),
                          label: const Text('Delete User'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
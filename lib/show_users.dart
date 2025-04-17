import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  List users = [];
  List filteredUsers = [];
  TextEditingController searchController = TextEditingController();
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      print('Fetching users from http://localhost/ecommerce/api/show_users.php');
      final response = await http.get(
        Uri.parse('http://localhost/ecommerce/api/show_users.php'),
      ).timeout(const Duration(seconds: 10));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          setState(() {
            if (data is List) {
              users = data;
              filteredUsers = users;
              errorMessage = users.isEmpty ? 'No users found' : '';
            } else if (data is Map && data.containsKey('status') && data['status'] == 'error') {
              errorMessage = 'Failed to load users: ${data['message']}';
            } else {
              errorMessage = 'Invalid data format: Expected a JSON list';
            }
          });
        } catch (e) {
          setState(() {
            errorMessage = 'Failed to parse JSON: $e\nResponse: ${response.body}';
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load users: ${response.statusCode}\nResponse: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching users: $e';
      });
      print('Error: $e');
    }
  }

  void filterUsers(String query) {
    setState(() {
      filteredUsers = users.where((user) {
        final name = '${user['first_name']} ${user['last_name']}'.toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search by name',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                filled: true,
                fillColor: Colors.orange[50],
              ),
              onChanged: filterUsers,
            ),
          ),
          Expanded(
            child: errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage, style: const TextStyle(fontSize: 16)))
                : filteredUsers.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          String imageUrl = user['profile_image'] ??
                              'https://via.placeholder.com/150';

                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: Hero(
                                tag: 'user-${user['id']}',
                                child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.error);
                                    },
                                  ),
                                ),
                              ),
                              title: Text(
                                '${user['first_name']} ${user['last_name']}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(user['username'] ?? 'No Username'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserDetail(user: user),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class UserDetail extends StatefulWidget {
  final dynamic user;
  const UserDetail({super.key, required this.user});

  @override
  _UserDetailState createState() => _UserDetailState();
}

class _UserDetailState extends State<UserDetail> {
  bool isEditing = false;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController addressController;
  late TextEditingController phoneController;
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  Uint8List? _selectedImageBytes;
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.user['first_name'] ?? '');
    lastNameController = TextEditingController(text: widget.user['last_name'] ?? '');
    addressController = TextEditingController(text: widget.user['address'] ?? '');
    phoneController = TextEditingController(text: widget.user['phone'] ?? '');
    usernameController = TextEditingController(text: widget.user['username'] ?? '');
    passwordController = TextEditingController();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      String? mimeType = lookupMimeType(pickedFile.path);

      // ถ้า lookupMimeType คืนค่า null ลองใช้นามสกุลไฟล์เพื่อคาดเดา MIME type
      if (mimeType == null) {
        final extension = path.extension(pickedFile.path).toLowerCase();
        switch (extension) {
          case '.jpg':
          case '.jpeg':
            mimeType = 'image/jpeg';
            break;
          case '.png':
            mimeType = 'image/png';
            break;
          case '.gif':
            mimeType = 'image/gif';
            break;
          default:
            mimeType = null;
        }
      }

      print('Selected file path: ${pickedFile.path}');
      print('Selected file MIME type: $mimeType');

      const allowedTypes = ['image/jpeg', 'image/png', 'image/gif'];
      if (mimeType != null && allowedTypes.contains(mimeType)) {
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImagePath = pickedFile.path;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid file type. Please select a JPEG, PNG, or GIF image.'),
          ),
        );
      }
    }
  }

  Future<void> _updateUser() async {
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
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
      final url = Uri.parse('http://localhost/ecommerce/api/update_user.php');
      var request = http.MultipartRequest('POST', url);

      request.fields['id'] = widget.user['id'].toString();
      request.fields['first_name'] = firstNameController.text;
      request.fields['last_name'] = lastNameController.text;
      request.fields['address'] = addressController.text;
      request.fields['phone'] = phoneController.text;
      request.fields['username'] = usernameController.text;
      request.fields['password'] = passwordController.text;

      if (_selectedImageBytes != null) {
        // ใช้ path หรือนามสกุลไฟล์เพื่อตั้งชื่อไฟล์ที่เหมาะสม
        String extension = path.extension(_selectedImagePath ?? '').toLowerCase();
        if (extension.isEmpty) {
          extension = '.jpg'; // ค่าเริ่มต้นถ้าไม่มีนามสกุล
        } else if (extension == '.jpeg') {
          extension = '.jpg';
        }
        request.files.add(http.MultipartFile.fromBytes(
          'profile_image',
          _selectedImageBytes!,
          filename: 'user_${widget.user['id']}_${DateTime.now().millisecondsSinceEpoch}$extension',
        ));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      print('Update user response: $responseBody');

      try {
        final responseData = json.decode(responseBody);
        if (responseData['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User updated successfully')));
          setState(() {
            isEditing = false;
            widget.user['first_name'] = firstNameController.text;
            widget.user['last_name'] = lastNameController.text;
            widget.user['address'] = addressController.text;
            widget.user['phone'] = phoneController.text;
            widget.user['username'] = usernameController.text;
            if (_selectedImageBytes != null) {
              String extension = path.extension(_selectedImagePath ?? '').toLowerCase();
              if (extension.isEmpty) {
                extension = '.jpg';
              } else if (extension == '.jpeg') {
                extension = '.jpg';
              }
              widget.user['profile_image'] =
                  'http://localhost/ecommerce/uploads/user_${widget.user['id']}_${DateTime.now().millisecondsSinceEpoch}$extension';
            }
            passwordController.clear();
            _selectedImageBytes = null;
            _selectedImagePath = null;
          });
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed: ${responseData['message']}')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to parse JSON: $e\nResponse: $responseBody')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = widget.user['profile_image'] ?? 'https://via.placeholder.com/150';

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.user['first_name']} ${widget.user['last_name']}'),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
                if (!isEditing) {
                  firstNameController.text = widget.user['first_name'] ?? '';
                  lastNameController.text = widget.user['last_name'] ?? '';
                  addressController.text = widget.user['address'] ?? '';
                  phoneController.text = widget.user['phone'] ?? '';
                  usernameController.text = widget.user['username'] ?? '';
                  passwordController.clear();
                  _selectedImageBytes = null;
                  _selectedImagePath = null;
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Hero(
                      tag: 'user-${widget.user['id']}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _selectedImageBytes != null
                            ? Image.memory(
                                _selectedImageBytes!,
                                height: 150,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                imageUrl,
                                height: 150,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.error, size: 100);
                                },
                              ),
                      ),
                    ),
                  ),
                  if (isEditing) ...[
                    const SizedBox(height: 10),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text('Pick Image (JPEG, PNG, GIF only)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[700],
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  isEditing
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: firstNameController,
                              decoration: InputDecoration(
                                labelText: 'First Name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.orange[50],
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: lastNameController,
                              decoration: InputDecoration(
                                labelText: 'Last Name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.orange[50],
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: addressController,
                              decoration: InputDecoration(
                                labelText: 'Address',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.orange[50],
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: 'Phone',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.orange[50],
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: usernameController,
                              decoration: InputDecoration(
                                labelText: 'Username',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.orange[50],
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Password (leave blank to keep unchanged)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.orange[50],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _updateUser,
                                  icon: const Icon(Icons.save),
                                  label: const Text('Save'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      isEditing = false;
                                      firstNameController.text = widget.user['first_name'] ?? '';
                                      lastNameController.text = widget.user['last_name'] ?? '';
                                      addressController.text = widget.user['address'] ?? '';
                                      phoneController.text = widget.user['phone'] ?? '';
                                      usernameController.text = widget.user['username'] ?? '';
                                      passwordController.clear();
                                      _selectedImageBytes = null;
                                      _selectedImagePath = null;
                                    });
                                  },
                                  icon: const Icon(Icons.cancel),
                                  label: const Text('Cancel'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red[400],
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.user['first_name']} ${widget.user['last_name']}',
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
                              'Phone: ${widget.user['phone'] ?? 'No Phone'}',
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
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
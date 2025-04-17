import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  List products = [];
  List filteredProducts = [];
  TextEditingController searchController = TextEditingController();
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      print('Fetching products from http://localhost/ecommerce/api/show_data.php');
      final response = await http.get(
        Uri.parse('http://localhost/ecommerce/api/show_data.php'),
      ).timeout(const Duration(seconds: 10));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          setState(() {
            if (data is List) {
              products = data;
              filteredProducts = products;
              errorMessage = products.isEmpty ? 'No products found' : '';
            } else if (data is Map && data.containsKey('status') && data['status'] == 'error') {
              errorMessage = 'Failed to load products: ${data['message']}';
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
          errorMessage = 'Failed to load products: ${response.statusCode}\nResponse: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching products: $e';
      });
      print('Error: $e');
    }
  }

  void filterProducts(String query) {
    setState(() {
      filteredProducts = products.where((product) {
        final name = product['name']?.toLowerCase() ?? '';
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
                labelText: 'Search products',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                filled: true,
                fillColor: Colors.orange[50],
              ),
              onChanged: filterProducts,
            ),
          ),
          Expanded(
            child: errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage, style: const TextStyle(fontSize: 16)))
                : filteredProducts.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          String imageUrl = product['image'] ?? 'https://via.placeholder.com/150';

                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: SizedBox(
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
                              title: Text(
                                product['name'] ?? 'No Name',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('Price: ${product['price'] ?? 'N/A'}'),
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
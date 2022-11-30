import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shop_app/providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const roueName = '/edit-product-screen';
  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _decriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _imageUrl = '';
  Product _editedProduct;
  var _isInit = true;
  var _isLoading = false;
  // var _editedProduct =
  //     Product(id: null, title: '', description: '', price: 0, imageUrl: '');

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _decriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final _args = ModalRoute.of(context).settings.arguments as String;
      _editedProduct = _args == null
          ? Product(
              id: null,
              title: '',
              description: '',
              price: null,
              imageUrl: '',
              isFavorite: false)
          : Provider.of<Products>(context).findById(_args);
      _imageUrlController.text = _editedProduct.imageUrl;
      setState(() {
        _imageUrl = _editedProduct.imageUrl;
      });
    }

    super.didChangeDependencies();
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id == null) {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        print(error);
        await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('An error accured!'),
                  content: Text('Something went wrong'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text('Okey'),
                    )
                  ],
                ));
      }
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .updateProduct(_editedProduct.id, _editedProduct);
      } catch (error) {
        print(error);
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(onPressed: _saveForm, icon: const Icon(Icons.save))
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _form,
                child: ListView(children: [
                  TextFormField(
                    initialValue: _editedProduct.title,
                    decoration: const InputDecoration(labelText: 'Title'),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please provide a title';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_priceFocusNode),
                    onSaved: (value) {
                      _editedProduct = Product(
                        id: _editedProduct.id,
                        title: value,
                        description: _editedProduct.description,
                        price: _editedProduct.price,
                        imageUrl: _editedProduct.imageUrl,
                        isFavorite: _editedProduct.isFavorite,
                      );
                    },
                  ),
                  TextFormField(
                    initialValue: _editedProduct.price == null
                        ? ''
                        : _editedProduct.price.toString(),
                    decoration: const InputDecoration(labelText: 'Price'),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    focusNode: _priceFocusNode,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a price';
                      } else if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      } else if (double.parse(value) <= 0) {
                        return 'Please enter a number greater than zero';
                      } else {
                        return null;
                      }
                    },
                    onFieldSubmitted: (_) => FocusScope.of(context)
                        .requestFocus(_decriptionFocusNode),
                    onSaved: (value) {
                      _editedProduct = Product(
                        id: _editedProduct.id,
                        title: _editedProduct.title,
                        description: _editedProduct.description,
                        price: double.parse(value),
                        imageUrl: _editedProduct.imageUrl,
                        isFavorite: _editedProduct.isFavorite,
                      );
                    },
                  ),
                  TextFormField(
                    initialValue: _editedProduct.description,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                    focusNode: _decriptionFocusNode,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a description';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value) {
                      _editedProduct = Product(
                        id: _editedProduct.id,
                        title: _editedProduct.title,
                        description: value,
                        price: _editedProduct.price,
                        imageUrl: _editedProduct.imageUrl,
                        isFavorite: _editedProduct.isFavorite,
                      );
                    },
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.only(top: 8, right: 10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.grey,
                          ),
                        ),
                        child: _imageUrl.isEmpty
                            ? const Center(child: Text('Enter a URL'))
                            : Center(
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: _imageUrl,
                                  placeholder: (context, url) => const SizedBox(
                                    height: 50,
                                    width: 50,
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),

                                  // loadingBuilder: (context, child, loadingProgress) {
                                  //   if (loadingProgress == null) {
                                  //     return child;
                                  //   } else {
                                  //     return Center(
                                  //       child: CircularProgressIndicator(),
                                  //     );
                                  //   }
                                  // },
                                ),
                              ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _imageUrlController,
                          decoration: const InputDecoration(
                            labelText: 'Image URL',
                          ),
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.done,
                          validator: (value) {
                            if (value.isEmpty) return 'Please enter a URL';
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              _imageUrl = value;
                            });
                          },
                          onFieldSubmitted: (_) {
                            _saveForm();
                          },
                          onSaved: (value) {
                            _editedProduct = Product(
                              id: _editedProduct.id,
                              title: _editedProduct.title,
                              description: _editedProduct.description,
                              price: _editedProduct.price,
                              imageUrl: value,
                              isFavorite: _editedProduct.isFavorite,
                            );
                          },
                        ),
                      ),
                    ],
                  )
                ]),
              ),
            ),
    );
  }
}

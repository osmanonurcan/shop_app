import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/widgets/user_products_item.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products-screen';

  Future<void> refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchAndSetData(true);
  }

  @override
  Widget build(BuildContext context) {
    //final productsData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.roueName);
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: FutureBuilder(
        future: refreshProducts(context),
        builder: (_, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => refreshProducts(context),
                    child: Consumer<Products>(
                      builder: (ctx, productsData, _) => Padding(
                        padding: const EdgeInsets.all(8),
                        child: ListView.builder(
                          itemBuilder: (context, index) => Column(
                            children: [
                              UserProductsItem(
                                productsData.items[index].id,
                                productsData.items[index].title,
                                productsData.items[index].imageUrl,
                              ),
                              Divider(),
                            ],
                          ),
                          itemCount: productsData.items.length,
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}

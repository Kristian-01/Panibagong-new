import 'package:flutter/material.dart';
import '/common/color_extension.dart';
import '/common_widget/round_textfield.dart';

import '../../common/globs.dart';
import '../../common/service_call.dart';
import '../../common_widget/category_cell.dart';
import '../../common_widget/most_popular_cell.dart';
import '../../common_widget/popular_resutaurant_row.dart';
import '../../common_widget/recent_item_row.dart';
import '../../common_widget/view_all_title_row.dart';
import '../../common_widget/cart_icon.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  TextEditingController txtSearch = TextEditingController();
  bool isSearching = false;
  List searchResults = [];

  List catArr = [
    {"image": "assets/img/med.png", "name": "Medicines"},
    {"image": "assets/img/vitamins.png", "name": "Vitamins"},
    {"image": "assets/img/first aid.png", "name": "First Aid"},
    {"image": "assets/img/cat_4.png", "name": "Others"},
  ];

  List popArr = [
    {
      "image": "assets/img/bio.jpg",
      "name": "Biogesic",
      "price": "₱5.00",
      "description": "For headache and fever relief"
    },
    {
      "image": "assets/img/res_2.png",
      "name": "Café de Noir",
      "price": "₱5.00",
      "description": "For headache and fever relief"
    },
    {
      "image": "assets/img/res_3.png",
      "name": "Bakes by Tella",
      "price": "₱5.00",
      "description": "For headache and fever relief"
    },
  ];

  List mostPopArr = [
    {
      "image": "assets/img/m_res_1.png",
      "name": "Minute by tuk tuk",
      "price": "₱5.00",
      "description": "For headache and fever relief"
    },
    {
      "image": "assets/img/m_res_2.png",
      "name": "Café de Noir",
      "price": "₱5.00",
      "description": "For headache and fever relief"
    },
  ];

  List recentArr = [
    {
      "image": "assets/img/item_1.png",
      "name": "Mulberry Pizza by Josh",
      "price": "₱5.00",
      "description": "For headache and fever relief"
    },
    {
      "image": "assets/img/item_2.png",
      "name": "Barita",
      "price": "₱5.00",
      "description": "For headache and fever relief"
    },
    {
      "image": "assets/img/item_3.png",
      "name": "Pizza Rush Hour",
      "price": "₱5.00",
      "description": "For headache and fever relief"
    },
  ];

  @override
  void initState() {
    super.initState();
    txtSearch.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    txtSearch.removeListener(_onSearchChanged);
    txtSearch.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    String query = txtSearch.text.toLowerCase().trim();

    if (query.isEmpty) {
      setState(() {
        isSearching = false;
        searchResults.clear();
      });
      return;
    }

    // Combine all items from different arrays for searching
    List allItems = [];

    // Add medicines with category
    for (var item in popArr) {
      allItems.add({
        ...item,
        "category": "Medicines",
        "type": "medicine"
      });
    }

    // Add most popular items with category
    for (var item in mostPopArr) {
      allItems.add({
        ...item,
        "category": "Most Popular",
        "type": "popular"
      });
    }

    // Add recent items with category
    for (var item in recentArr) {
      allItems.add({
        ...item,
        "category": "Recent Items",
        "type": "recent"
      });
    }

    // Filter items based on search query
    List filtered = allItems.where((item) {
      String name = (item["name"] ?? "").toLowerCase();
      String description = (item["description"] ?? "").toLowerCase();
      String category = (item["category"] ?? "").toLowerCase();

      return name.contains(query) ||
             description.contains(query) ||
             category.contains(query);
    }).toList();

    setState(() {
      isSearching = true;
      searchResults = filtered;
    });
  }

  void _clearSearch() {
    txtSearch.clear();
    setState(() {
      isSearching = false;
      searchResults.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 46),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Nine27 Pharmacy ${ServiceCall.userPayload[KKey.name] ?? ""}",
                      style: TextStyle(
                        color: TColor.primaryText,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    // ✅ Cart Icon with Counter Badge
                    const CartIcon(size: 28),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Location
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Delivering to",
                        style: TextStyle(
                            color: TColor.secondaryText, fontSize: 11)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text("Current Location",
                            style: TextStyle(
                                color: TColor.secondaryText,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(width: 25),
                        Image.asset("assets/img/dropdown.png",
                            width: 12, height: 12),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Search
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StatefulBuilder(
                  builder: (context, setSearchState) {
                    return RoundTextfield(
                      hintText: "Search medicines, items...",
                      controller: txtSearch,
                      left: Container(
                        alignment: Alignment.center,
                        width: 30,
                        child: Image.asset("assets/img/search.png",
                            width: 20, height: 20),
                      ),
                      right: txtSearch.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _clearSearch();
                                setSearchState(() {});
                              },
                              icon: Icon(Icons.clear, size: 20, color: TColor.secondaryText),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            )
                          : null,
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),

              // Show search results or normal content
              if (isSearching) ...[
                // Search Results
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        "Search Results",
                        style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "(${searchResults.length} found)",
                        style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                if (searchResults.isEmpty)
                  // No results found
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            "No results found",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Try searching with different keywords",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  // Search results list
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      var item = searchResults[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                item["image"] ?? "assets/img/placeholder.png",
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image_not_supported),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item["name"] ?? "Unknown Item",
                                    style: TextStyle(
                                      color: TColor.primaryText,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item["description"] ?? "",
                                    style: TextStyle(
                                      color: TColor.secondaryText,
                                      fontSize: 12,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        item["price"] ?? "₱0.00",
                                        style: TextStyle(
                                          color: Colors.green[700],
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: TColor.primary.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          item["category"] ?? "",
                                          style: TextStyle(
                                            color: TColor.primary,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                addToCart(Map<String, dynamic>.from(item));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: TColor.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              child: const Text(
                                "Add",
                                style: TextStyle(fontSize: 12, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 100), // Bottom spacing
              ] else ...[
                // Normal content when not searching
                // Categories
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: catArr.length,
                    itemBuilder: (context, index) {
                      var cObj = catArr[index] as Map? ?? {};
                      return CategoryCell(cObj: cObj, onTap: () {});
                    },
                  ),
                ),

              // Medicines
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ViewAllTitleRow(title: "Medicines", onView: () {}),
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: popArr.length,
                itemBuilder: (context, index) {
                  var pObj = popArr[index] as Map? ?? {};
                  return PopularRestaurantRow(
                    pObj: pObj,
                    onTap: () {
                      // ✅ Add to Cart Logic
                      addToCart(Map<String, dynamic>.from(pObj));
                    },
                  );
                },
              ),

              // Most Popular
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ViewAllTitleRow(title: "Most Popular", onView: () {}),
              ),
              SizedBox(
                height: 250,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: mostPopArr.length,
                  itemBuilder: (context, index) {
                    var mObj = mostPopArr[index] as Map? ?? {};
                    return MostPopularCell(
                      mObj: mObj,
                      onTap: () {
                        addToCart(Map<String, dynamic>.from(mObj));
                      },
                    );
                  },
                ),
              ),

              // Recent Items
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ViewAllTitleRow(title: "Recent Items", onView: () {}),
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: recentArr.length,
                itemBuilder: (context, index) {
                  var rObj = recentArr[index] as Map? ?? {};
                  return RecentItemRow(
                    rObj: rObj,
                    onTap: () {
                      addToCart(Map<String, dynamic>.from(rObj));
                    },
                  );
                },
              ),
              const SizedBox(height: 100), // Add bottom spacing for navigation bar
              ], // End of normal content
            ],
          ),
        ),
      ),
    );
  }
}

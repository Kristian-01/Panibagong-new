import 'package:flutter/material.dart';

import '../../common/color_extension.dart';
import '../../common_widget/round_textfield.dart';
import '../../common_widget/cart_icon.dart';
import '../menu/staff_order_management_view.dart';

class MenuView extends StatefulWidget {
  const MenuView({super.key});

  @override
  State<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {
  List prescriptionActions = [
    {
      "name": "Upload Prescription",
      "image": "assets/img/menu_1.png",
      "description": "Take photo or upload prescription",
      "icon": Icons.camera_alt,
      "color": Colors.blue,
    },
    {
      "name": "My Prescriptions",
      "image": "assets/img/menu_2.png",
      "description": "View and manage prescriptions",
      "icon": Icons.receipt_long,
      "color": Colors.green,
    },
    {
      "name": "Prescription History",
      "image": "assets/img/menu_3.png",
      "description": "Past prescriptions and refills",
      "icon": Icons.history,
      "color": Colors.orange,
    },
    {
      "name": "Doctor Consultations",
      "image": "assets/img/menu_4.png",
      "description": "Online doctor consultations",
      "icon": Icons.video_call,
      "color": Colors.purple,
    },
  ];

  List recentPrescriptions = [
    {
      "id": "RX001",
      "doctor": "Dr. Maria Santos",
      "date": "Dec 22, 2024",
      "status": "Ready for Pickup",
      "medicines": ["Amoxicillin 500mg", "Paracetamol 500mg"],
      "statusColor": Colors.green,
    },
    {
      "id": "RX002",
      "doctor": "Dr. Juan Cruz",
      "date": "Dec 20, 2024",
      "status": "Processing",
      "medicines": ["Metformin 850mg", "Losartan 50mg"],
      "statusColor": Colors.orange,
    },
    {
      "id": "RX003",
      "doctor": "Dr. Ana Reyes",
      "date": "Dec 18, 2024",
      "status": "Completed",
      "medicines": ["Vitamin D3", "Calcium Carbonate"],
      "statusColor": Colors.blue,
    },
  ];
  TextEditingController txtSearch = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 180),
            width: media.width * 0.27,
            height: media.height * 0.6,
            decoration: BoxDecoration(
              color: TColor.primary,
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(35),
                  bottomRight: Radius.circular(35)),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  const SizedBox(
                    height: 46,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Prescriptions",
                          style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 20,
                              fontWeight: FontWeight.w800),
                        ),
                        const CartIcon(size: 25),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: RoundTextfield(
                      hintText: "Search Medicines",
                      controller: txtSearch,
                      left: Container(
                        alignment: Alignment.center,
                        width: 30,
                        child: Image.asset(
                          "assets/img/search.png",
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // Quick Actions Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Quick Actions",
                      style: TextStyle(
                        color: TColor.primaryText,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Action Cards Grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 1.4,
                      ),
                      itemCount: prescriptionActions.length,
                      itemBuilder: (context, index) {
                        var action = prescriptionActions[index] as Map? ?? {};
                        return _buildActionCard(action);
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Recent Prescriptions Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Recent Prescriptions",
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to all prescriptions
                          },
                          child: Text(
                            "View All",
                            style: TextStyle(
                              color: TColor.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Recent Prescriptions List
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: recentPrescriptions.length,
                    itemBuilder: (context, index) {
                      var prescription = recentPrescriptions[index] as Map? ?? {};
                      return _buildPrescriptionCard(prescription);
                    },
                  ),

                  // Staff Section (if user is staff)
                  if (true) // TODO: Replace with actual staff role check
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Staff Management",
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 15),

                        _buildMenuItem(
                          icon: Icons.assignment,
                          title: "Order Management",
                          subtitle: "Manage customer orders",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const StaffOrderManagementView(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(Map action) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _handleActionTap(action["name"]);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: (action["color"] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Icon(
                    action["icon"] as IconData,
                    color: action["color"] as Color,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  action["name"],
                  style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  action["description"],
                  style: TextStyle(
                    color: TColor.secondaryText,
                    fontSize: 9,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrescriptionCard(Map prescription) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to prescription details
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Prescription ${prescription["id"]}",
                      style: TextStyle(
                        color: TColor.primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (prescription["statusColor"] as Color).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        prescription["status"],
                        style: TextStyle(
                          color: prescription["statusColor"] as Color,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: TColor.secondaryText,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      prescription["doctor"],
                      style: TextStyle(
                        color: TColor.secondaryText,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.calendar_today,
                      color: TColor.secondaryText,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      prescription["date"],
                      style: TextStyle(
                        color: TColor.secondaryText,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Medicines:",
                  style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                ...((prescription["medicines"] as List).map((medicine) =>
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 2),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: TColor.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          medicine,
                          style: TextStyle(
                            color: TColor.secondaryText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: TColor.primary,
                  size: 24,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: TColor.secondaryText,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleActionTap(String actionName) {
    switch (actionName) {
      case "Upload Prescription":
        // Handle prescription upload
        _showUploadDialog();
        break;
      case "My Prescriptions":
        // Navigate to prescriptions list
        break;
      case "Prescription History":
        // Navigate to prescription history
        break;
      case "Doctor Consultations":
        // Navigate to consultations
        break;
    }
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Upload Prescription",
            style: TextStyle(
              color: TColor.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: TColor.primary),
                title: const Text("Take Photo"),
                onTap: () {
                  Navigator.pop(context);
                  // Handle camera
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: TColor.primary),
                title: const Text("Choose from Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  // Handle gallery
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import '../../common_widget/round_button.dart';
import 'package:image_picker/image_picker.dart';

import '../../common/color_extension.dart';
import '../../common_widget/round_textfield.dart';
import '../../common_widget/cart_icon.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ImagePicker picker = ImagePicker();
  XFile? image;
  bool isEditMode = false;

  TextEditingController txtName = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtMobile = TextEditingController();
  TextEditingController txtAddress = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  TextEditingController txtConfirmPassword = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with sample data
    txtName.text = "Emilia Rodriguez";
    txtEmail.text = "emilia.rodriguez@email.com";
    txtMobile.text = "+63 912 345 6789";
    txtAddress.text = "123 Makati Ave, Makati City, Metro Manila";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const SizedBox(
            height: 46,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Profile",
                  style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 20,
                      fontWeight: FontWeight.w800),
                ),
                Row(
                  children: [
                    if (!isEditMode)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isEditMode = true;
                          });
                        },
                        child: Text(
                          "Edit",
                          style: TextStyle(
                            color: TColor.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (isEditMode)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isEditMode = false;
                          });
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: TColor.secondaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    const CartIcon(size: 25),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: TColor.placeholder,
              borderRadius: BorderRadius.circular(50),
            ),
            alignment: Alignment.center,
            child: image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.file(File(image!.path),
                        width: 100, height: 100, fit: BoxFit.cover),
                  )
                : Icon(
                    Icons.person,
                    size: 65,
                    color: TColor.secondaryText,
                  ),
          ),
          if (isEditMode)
            TextButton.icon(
              onPressed: () async {
                image = await picker.pickImage(source: ImageSource.gallery);
                setState(() {});
              },
              icon: Icon(
                Icons.camera_alt,
                color: TColor.primary,
                size: 12,
              ),
              label: Text(
                "Change Photo",
                style: TextStyle(color: TColor.primary, fontSize: 12),
              ),
            ),
          Text(
            "Hi there Emilia!",
            style: TextStyle(
                color: TColor.primaryText,
                fontSize: 16,
                fontWeight: FontWeight.w700),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              "Sign Out",
              style: TextStyle(
                  color: TColor.secondaryText,
                  fontSize: 11,
                  fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            child: RoundTitleTextfield(
              title: "Name",
              hintText: "Enter Name",
              controller: txtName,
              readOnly: !isEditMode,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            child: RoundTitleTextfield(
              title: "Email",
              hintText: "Enter Email",
              keyboardType: TextInputType.emailAddress,
              controller: txtEmail,
              readOnly: !isEditMode,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            child: RoundTitleTextfield(
              title: "Mobile No",
              hintText: "Enter Mobile No",
              controller: txtMobile,
              keyboardType: TextInputType.phone,
              readOnly: !isEditMode,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            child: RoundTitleTextfield(
              title: "Address",
              hintText: "Enter Address",
              controller: txtAddress,
              readOnly: !isEditMode,
            ),
          ),
          if (isEditMode) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: RoundTitleTextfield(
                title: "Password",
                hintText: "* * * * * *",
                obscureText: true,
                controller: txtPassword,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: RoundTitleTextfield(
                title: "Confirm Password",
                hintText: "* * * * * *",
                obscureText: true,
                controller: txtConfirmPassword,
              ),
            ),
          ],
          const SizedBox(
            height: 20,
          ),
          if (isEditMode)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: RoundButton(
                title: "Save Changes",
                onPressed: () {
                  // Validate and save changes
                  if (txtPassword.text.isNotEmpty &&
                      txtPassword.text != txtConfirmPassword.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Passwords do not match"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Save changes (in a real app, this would save to a database)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Profile updated successfully!"),
                      backgroundColor: Colors.green,
                    ),
                  );

                  setState(() {
                    isEditMode = false;
                  });
                }
              ),
            ),
          const SizedBox(
            height: 20,
          ),
        ]),
      ),
    ));
  }
}

import 'package:flutter/material.dart';

import '../common/color_extension.dart';

class CategoryCell extends StatelessWidget {
  final Map cObj;
  final VoidCallback onTap;
  const CategoryCell({super.key, required this.cObj, required this.onTap });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: 90,
          child: Column(
            children: [
              Container(
                width: 85,
                height: 85,
                decoration: BoxDecoration(
                  color: cObj["color"] ?? TColor.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    cObj["image"].toString(),
                    width: 85,
                    height: 85,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback icon based on category
                      IconData fallbackIcon;
                      Color iconColor;
                      
                      switch (cObj["category"]) {
                        case 'medicines':
                          fallbackIcon = Icons.medication;
                          iconColor = Colors.blue[600]!;
                          break;
                        case 'vitamins':
                          fallbackIcon = Icons.health_and_safety;
                          iconColor = Colors.green[600]!;
                          break;
                        case 'first_aid':
                          fallbackIcon = Icons.medical_services;
                          iconColor = Colors.red[600]!;
                          break;
                        case 'prescription_drugs':
                          fallbackIcon = Icons.local_pharmacy;
                          iconColor = Colors.orange[600]!;
                          break;
                        default:
                          fallbackIcon = Icons.medical_services;
                          iconColor = TColor.primary;
                      }
                      
                      return Container(
                        width: 85,
                        height: 85,
                        decoration: BoxDecoration(
                          color: cObj["color"] ?? TColor.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          fallbackIcon,
                          color: iconColor,
                          size: 35,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                cObj["name"] ?? "Category",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (cObj["description"] != null) ...[
                const SizedBox(height: 2),
                Text(
                  cObj["description"],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: TColor.secondaryText,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
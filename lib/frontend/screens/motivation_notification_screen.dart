import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/quote_category_model.dart';
import '../widgets/notification_toggle_card.dart';
import '../widgets/delivery_time_card.dart';
import '../widgets/quote_category_chip.dart';

class MotivationNotificationScreen extends StatefulWidget {
  const MotivationNotificationScreen({super.key});

  @override
  State<MotivationNotificationScreen> createState() =>
      _MotivationNotificationScreenState();
}

class _MotivationNotificationScreenState
    extends State<MotivationNotificationScreen> {
  bool notificationsEnabled = true;
  String deliveryTime = '9.00 AM';

  final categories = [
    QuoteCategoryModel(title: 'Growth Mindset', selected: true),
    QuoteCategoryModel(title: 'Focus'),
    QuoteCategoryModel(title: 'Well-being'),
    QuoteCategoryModel(title: 'Productivity'),
    QuoteCategoryModel(title: 'Mindfulness'),
    QuoteCategoryModel(title: 'Success', selected: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Top bar
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white70,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Motivation Notifications',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),

              const SizedBox(height: 20),

              NotificationToggleCard(
                value: notificationsEnabled,
                onChanged: (v) => setState(() => notificationsEnabled = v),
              ),

              const SizedBox(height: 14),

              DeliveryTimeCard(time: deliveryTime, onTap: () {}),

              const SizedBox(height: 24),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Quote Categories',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: categories.map((c) {
                  return QuoteCategoryChip(
                    category: c,
                    onTap: () {
                      setState(() => c.selected = !c.selected);
                    },
                  );
                }).toList(),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

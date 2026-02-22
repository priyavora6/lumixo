// lib/screens/settings/terms_screen.dart

import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildLastUpdated(),
                    const SizedBox(height: 24),
                    _buildSection(
                      '1. Acceptance of Terms',
                      '''By accessing and using Lumixo, you accept and agree to be bound by these Terms of Service.

• You must be at least 13 years old to use this app
• You agree to use the app lawfully and responsibly
• You agree to comply with all applicable laws
• Violation may result in account termination''',
                    ),
                    _buildSection(
                      '2. User Account',
                      '''Account Registration:
• You must provide accurate information
• Keep your account credentials secure
• You are responsible for all account activity
• Notify us immediately of unauthorized access
• One account per user

Account Termination:
• We may suspend/terminate accounts for violations
• You can delete your account anytime
• Deleted accounts cannot be recovered''',
                    ),
                    _buildSection(
                      '3. Subscription & Payment',
                      '''Premium Subscription:
• Auto-renewal unless cancelled 24 hours before renewal
• Charged through your app store account
• No refunds for partial subscription periods
• Cancel anytime through app store settings

Coins & Credits:
• Non-refundable once purchased
• Expire if account is inactive for 12 months
• Cannot be transferred or exchanged for cash''',
                    ),
                    _buildSection(
                      '4. Content & Intellectual Property',
                      '''Your Content:
• You retain ownership of your uploaded photos
• You grant us license to process your photos
• You must have rights to upload content
• Don't upload copyrighted/inappropriate content

Our Content:
• Lumixo app, AI models, designs are our property
• Generated images can be used by you personally
• Commercial use requires premium license
• Don't reverse engineer our technology''',
                    ),
                    _buildSection(
                      '5. Acceptable Use',
                      '''You agree NOT to:
• Upload illegal, harmful, or offensive content
• Violate others' privacy or rights
• Attempt to hack or disrupt services
• Use for automated/bulk processing
• Share accounts with others
• Resell or redistribute our services
• Create fake or misleading images
• Use for deepfakes or misinformation''',
                    ),
                    _buildSection(
                      '6. AI-Generated Content',
                      '''Understanding AI:
• AI results may vary in quality
• We don't guarantee specific outcomes
• Generated images may contain artifacts
• Some styles work better with certain photos

Usage Rights:
• Free users: Personal use only, with watermark
• Premium users: Commercial use allowed, no watermark
• Don't claim AI art as original photography
• Credit Lumixo when sharing publicly (optional)''',
                    ),
                    _buildSection(
                      '7. Service Availability',
                      '''We strive for 99% uptime but:
• Service may be interrupted for maintenance
• Features may be added, changed, or removed
• We may limit usage to prevent abuse
• No guarantee of error-free operation

Limitations:
• Free users: Limited daily generations
• Premium users: Fair use policy applies
• Excessive usage may be restricted''',
                    ),
                    _buildSection(
                      '8. Disclaimer of Warranties',
                      '''The service is provided "AS IS":
• No warranty of specific results
• AI accuracy not guaranteed
• Compatible devices not guaranteed
• Third-party services may affect functionality

We are not liable for:
• Data loss
• Service interruptions
• AI generation errors
• Third-party payment issues''',
                    ),
                    _buildSection(
                      '9. Limitation of Liability',
                      '''To the maximum extent permitted by law:
• Our liability is limited to subscription fees paid
• No liability for indirect or consequential damages
• No liability for user-generated content
• No liability for third-party services

Exceptions:
• Fraudulent actions by us
• Gross negligence
• As required by law''',
                    ),
                    _buildSection(
                      '10. Indemnification',
                      '''You agree to indemnify Lumixo from:
• Your violation of these terms
• Your uploaded content
• Your use of generated images
• Claims from third parties related to your use''',
                    ),
                    _buildSection(
                      '11. Modifications',
                      '''We may update these terms:
• You'll be notified of significant changes
• Continued use means acceptance
• If you disagree, stop using the service
• Changes effective upon posting''',
                    ),
                    _buildSection(
                      '12. Termination',
                      '''We may terminate your access if:
• You violate these terms
• You engage in fraudulent activity
• Required by law
• Service is discontinued

Upon termination:
• Your access ends immediately
• Unused credits/subscriptions are forfeited
• Generated images may be deleted
• No refunds for early termination''',
                    ),
                    _buildSection(
                      '13. Governing Law',
                      '''These terms are governed by:
• Laws of [Your Country/State]
• Disputes handled in [Your Jurisdiction]
• Arbitration may be required
• Class action waiver may apply''',
                    ),
                    _buildSection(
                      '14. Contact Us',
                      '''Questions about Terms of Service?

📧 Email: legal@lumixo.app
🌐 Website: www.lumixo.app/terms
📱 Support: In-app chat

We respond within 48 hours.''',
                    ),
                    const SizedBox(height: 32),
                    _buildFooter(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_rounded,
                color: AppColors.primary,
                size: 18,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            'Terms of Service',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.1),
            Colors.purple.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.gavel,
            size: 60,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          const Text(
            'Terms of Service',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Please read these terms carefully before using Lumixo.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMedium.withOpacity(0.8),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdated() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.update,
            color: Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            'Effective Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppColors.textMedium.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.handshake,
            color: Colors.blue,
            size: 40,
          ),
          const SizedBox(height: 12),
          const Text(
            'Thank you for using Lumixo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'By using our service, you agree to these terms and conditions.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMedium.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
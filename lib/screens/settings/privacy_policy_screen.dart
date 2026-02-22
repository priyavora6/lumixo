
// lib/screens/settings/privacy_policy_screen.dart

import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
                      '1. Information We Collect',
                      '''To provide and improve our service, we collect the following types of information:

Personal Information:
• Account Data: Name, email address, and profile picture from your Google account.
• User ID: A unique ID assigned to your Lumixo account.

Usage Data:
• App Interactions: Features used, styles selected, and actions taken.
• Device Information: Device model, OS version, and unique device identifiers.
• Analytics: Anonymized data about app performance and crashes.

Content Data:
• Uploaded Photos: The photos you upload for processing. These are temporarily stored and automatically deleted after 24 hours.
• Generated Images: The AI-generated images are stored in your history until you delete them or your account.''',
                    ),
                    _buildSection(
                      '2. How We Use Your Information',
                      '''We use your information for several purposes:

To Provide the Service:
• To create and manage your account.
• To process your photos and generate AI images.
• To save your image history and preferences.

To Improve the Service:
• To analyze usage patterns and improve app functionality.
• To diagnose and fix technical issues.
• To train our AI models (only with anonymized or explicitly permitted data).

To Communicate with You:
• To send important account notifications.
• To notify you when your images are ready.
• To send marketing messages if you opt in.''',
                    ),
                    _buildSection(
                      '3. Data Sharing & Disclosure',
                      '''We do not sell your personal data. We only share it in the following circumstances:

With Service Providers:
• We use third-party services for cloud hosting (e.g., Google Cloud, AWS) and AI processing. They only have access to the data necessary to perform these tasks and are obligated to protect it.

For Legal Reasons:
• If required by law, subpoena, or other legal process.
• To protect the rights, property, or safety of Lumixo, our users, or the public.''',
                    ),
                    _buildSection(
                      '4. Data Security',
                      '''We take data security seriously:
• Encryption: Data is encrypted in transit (using TLS) and at rest.
• Access Controls: Strict internal access controls limit who can view user data.
• Data Deletion: Uploaded photos are automatically deleted after 24 hours. Your account data is deleted upon account deletion request.

While we implement robust security measures, no system is 100% secure.''',
                    ),
                    _buildSection(
                      '5. Your Rights & Choices',
                      '''You have control over your data:
• Access & Correction: You can view and update your account information in the app.
• Data Deletion: You can delete your account from the settings screen, which will permanently remove your personal information and generated images.
• Communication: You can unsubscribe from promotional emails and disable push notifications.
• Object to Processing: You can object to certain data processing activities by contacting our support.''',
                    ),
                    _buildSection(
                      '6. Children’s Privacy',
                      '''Our service is not directed to individuals under the age of 13. We do not knowingly collect personal information from children under 13. If we become aware that a child has provided us with personal information, we will take steps to delete such information.''',
                    ),
                    _buildSection(
                      '7. Changes to This Policy',
                      '''We may update this Privacy Policy from time to time. We will notify you of any significant changes by email or through an in-app notification. Your continued use of the service after the changes take effect constitutes your acceptance of the new policy.''',
                    ),
                    _buildSection(
                      '8. Contact Us',
                      '''If you have any questions about this Privacy Policy, please contact us:

📧 Email: privacy@lumixo.app
🌐 Website: www.lumixo.app/privacy
📱 Support: Via the in-app settings screen''',
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
            'Privacy Policy',
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
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.privacy_tip,
            size: 60,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          const Text(
            'Privacy Policy',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Your privacy is important to us. This policy explains how we collect, use, and protect your information.',
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
            'Last Updated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
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
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.health_and_safety,
            color: AppColors.primary,
            size: 40,
          ),
          const SizedBox(height: 12),
          const Text(
            'Your Trust is Our Priority',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We are committed to protecting your data and providing a transparent experience.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMedium.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

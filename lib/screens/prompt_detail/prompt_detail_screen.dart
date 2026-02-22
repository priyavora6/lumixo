import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lumixo/models/prompt_model.dart';
import 'package:lumixo/utils/colors.dart';

class PromptDetailScreen extends StatefulWidget {
final PromptModel prompt;
const PromptDetailScreen({Key? key, required this.prompt}) : super(key: key);

@override
State<PromptDetailScreen> createState() => _PromptDetailScreenState();
}

class _PromptDetailScreenState extends State<PromptDetailScreen> {
bool _isFavorited = false;
bool _isExpanded = false;

void _copyPrompt() {
Clipboard.setData(ClipboardData(text: widget.prompt.prompt));
HapticFeedback.mediumImpact();
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Row(
children: const [
Icon(Icons.check_circle, color: Colors.white, size: 20),
SizedBox(width: 10),
Text('✅ Prompt copied to clipboard!'),
],
),
backgroundColor: AppColors.successColor, // ✅ Fixed: successColor not success
behavior: SnackBarBehavior.floating,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
duration: const Duration(seconds: 2),
),
);
}

void _copyNegativePrompt() {
// ✅ Fixed: Check if negativePrompt exists in your model
// If your PromptModel doesn't have negativePrompt, remove this method
// For now, we'll assume it might not exist
final negativePrompt = widget.prompt.negativePrompt ?? '';
if (negativePrompt.isNotEmpty) {
Clipboard.setData(ClipboardData(text: negativePrompt));
HapticFeedback.lightImpact();
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: const Text('✅ Negative prompt copied!'),
backgroundColor: AppColors.successColor, // ✅ Fixed: successColor not success
behavior: SnackBarBehavior.floating,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
),
);
}
}

@override
Widget build(BuildContext context) {
final prompt = widget.prompt;

return Scaffold(
backgroundColor: AppColors.bgDark,
body: CustomScrollView(
slivers: [
// ── Image Header ──
SliverAppBar(
expandedHeight: 300,
pinned: true,
backgroundColor: AppColors.bgDark,
flexibleSpace: FlexibleSpaceBar(
background: Container(
decoration: BoxDecoration(
gradient: LinearGradient(
begin: Alignment.topCenter,
end: Alignment.bottomCenter,
colors: [
AppColors.primary.withOpacity(0.8),
AppColors.bgDark,
],
),
image: prompt.previewImageUrl.isNotEmpty
? DecorationImage(
image: NetworkImage(prompt.previewImageUrl),
fit: BoxFit.cover,
)
    : null,
),
child: Container(
decoration: BoxDecoration(
gradient: LinearGradient(
begin: Alignment.topCenter,
end: Alignment.bottomCenter,
colors: [Colors.transparent, AppColors.bgDark],
),
),
),
),
),
actions: [
IconButton(
onPressed: () => setState(() => _isFavorited = !_isFavorited),
icon: Icon(
_isFavorited ? Icons.favorite : Icons.favorite_border,
color: _isFavorited ? AppColors.errorColor : Colors.white,
),
),
IconButton(
onPressed: () {
// Share prompt
},
icon: const Icon(Icons.share_rounded, color: Colors.white),
),
],
),

// ── Content ──
SliverToBoxAdapter(
child: Padding(
padding: const EdgeInsets.all(20),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// Title & Premium Badge
Row(
children: [
Expanded(
child: Text(
prompt.title,
style: const TextStyle(
color: AppColors.textDark,
fontSize: 24,
fontWeight: FontWeight.bold,
),
),
),
if (prompt.isPremium)
Container(
padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
decoration: BoxDecoration(
gradient: AppColors.premiumGradient,
borderRadius: BorderRadius.circular(8),
),
child: const Text(
'👑 PREMIUM',
style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
),
),
],
),

const SizedBox(height: 16),

// Stats Row
Row(
children: [
_statChip(Icons.favorite, '${prompt.likesCount}', AppColors.errorColor),
const SizedBox(width: 12),
_statChip(Icons.copy, '${prompt.copiesCount}', AppColors.primary),
const SizedBox(width: 12),
_statChip(Icons.smart_toy, prompt.aiModel, AppColors.secondary),
const SizedBox(width: 12),
_statChip(Icons.aspect_ratio, prompt.aspectRatio, AppColors.coinColor),
],
),

const SizedBox(height: 24),

// ── MAIN PROMPT ──
_buildPromptSection(
title: '✨ Prompt',
content: prompt.prompt,
onCopy: _copyPrompt,
),

const SizedBox(height: 16),

// ── NEGATIVE PROMPT ──
// ✅ Only show if negativePrompt exists and is not empty
if ((prompt.negativePrompt ?? '').isNotEmpty)
_buildPromptSection(
title: '🚫 Negative Prompt',
content: prompt.negativePrompt ?? '',
onCopy: _copyNegativePrompt,
isNegative: true,
),

const SizedBox(height: 20),

// ── TAGS ──
if (prompt.tags.isNotEmpty) ...[
const Text(
'🏷️ Tags',
style: TextStyle(
color: AppColors.textDark,
fontSize: 16,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 10),
Wrap(
spacing: 8,
runSpacing: 8,
children: prompt.tags.map((tag) {
return Container(
padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
decoration: BoxDecoration(
color: Colors.white.withOpacity(0.8),
borderRadius: BorderRadius.circular(20),
border: Border.all(color: AppColors.lightGrey),
),
child: Text(
'#$tag',
style: const TextStyle(color: AppColors.textMedium, fontSize: 13),
),
);
}).toList(),
),
],

const SizedBox(height: 24),

// ── SETTINGS INFO ──
const Text(
'⚙️ Recommended Settings',
style: TextStyle(
color: AppColors.textDark,
fontSize: 16,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 12),
_settingRow('AI Model', prompt.aiModel),
_settingRow('Aspect Ratio', prompt.aspectRatio),
_settingRow('Style', prompt.style.isNotEmpty ? prompt.style : 'Default'),
_settingRow('Category', prompt.categoryName),

const SizedBox(height: 100),
],
),
),
),
],
),

// ── COPY BUTTON (Fixed Bottom) ──
bottomSheet: Container(
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: Colors.white.withOpacity(0.9),
border: Border(top: BorderSide(color: AppColors.lightGrey)),
),
child: Row(
children: [
// Favorite Button
GestureDetector(
onTap: () => setState(() => _isFavorited = !_isFavorited),
child: Container(
width: 56,
height: 56,
decoration: BoxDecoration(
color: _isFavorited ? AppColors.errorColor.withOpacity(0.15) : Colors.white.withOpacity(0.8),
borderRadius: BorderRadius.circular(16),
border: Border.all(color: AppColors.lightGrey),
),
child: Icon(
_isFavorited ? Icons.favorite : Icons.favorite_border,
color: _isFavorited ? AppColors.errorColor : AppColors.textMedium,
),
),
),

const SizedBox(width: 12),

// Copy Button
Expanded(
child: GestureDetector(
onTap: _copyPrompt,
child: Container(
height: 56,
decoration: BoxDecoration(
gradient: AppColors.primaryGradient,
borderRadius: BorderRadius.circular(16),
boxShadow: [
BoxShadow(
color: AppColors.primary.withOpacity(0.4),
blurRadius: 16,
offset: const Offset(0, 6),
),
],
),
child: const Center(
child: Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(Icons.copy_rounded, color: Colors.white, size: 20),
SizedBox(width: 10),
Text(
'Copy Prompt',
style: TextStyle(
color: Colors.white,
fontSize: 16,
fontWeight: FontWeight.bold,
),
),
],
),
),
),
),
),
],
),
),
);
}

Widget _buildPromptSection({
required String title,
required String content,
required VoidCallback onCopy,
bool isNegative = false,
}) {
return Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.white.withOpacity(0.9),
borderRadius: BorderRadius.circular(16),
border: Border.all(
color: isNegative ? AppColors.errorColor.withOpacity(0.3) : AppColors.primary.withOpacity(0.3),
),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text(
title,
style: const TextStyle(
color: AppColors.textDark,
fontSize: 16,
fontWeight: FontWeight.bold,
),
),
GestureDetector(
onTap: onCopy,
child: Container(
padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
decoration: BoxDecoration(
color: AppColors.primary.withOpacity(0.15),
borderRadius: BorderRadius.circular(8),
),
child: Row(
children: const [
Icon(Icons.copy, size: 14, color: AppColors.primary),
SizedBox(width: 6),
Text(
'Copy',
style: TextStyle(
color: AppColors.primary,
fontSize: 13,
fontWeight: FontWeight.w600,
),
),
],
),
),
),
],
),
const SizedBox(height: 12),
Text(
content,
style: const TextStyle(
color: AppColors.textMedium,
fontSize: 14,
height: 1.6,
),
),
],
),
);
}

Widget _statChip(IconData icon, String text, Color color) {
return Container(
padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
decoration: BoxDecoration(
color: color.withOpacity(0.1),
borderRadius: BorderRadius.circular(8),
),
child: Row(
children: [
Icon(icon, size: 14, color: color),
const SizedBox(width: 4),
Text(text, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
],
),
);
}

Widget _settingRow(String label, String value) {
return Padding(
padding: const EdgeInsets.symmetric(vertical: 6),
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text(label, style: const TextStyle(color: AppColors.textMedium, fontSize: 14)),
Container(
padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
decoration: BoxDecoration(
color: Colors.white.withOpacity(0.8),
borderRadius: BorderRadius.circular(6),
),
child: Text(value, style: const TextStyle(color: AppColors.textDark, fontSize: 13)),
),
],
),
);
}
}
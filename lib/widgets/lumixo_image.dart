// lib/screens/admin/seed_data_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SeedDataScreen extends StatefulWidget {
  const SeedDataScreen({super.key});
  @override
  State<SeedDataScreen> createState() => _SeedDataScreenState();
}

class _SeedDataScreenState extends State<SeedDataScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _isLoading = false;
  String _status = '✨ Ready to seed Lumixo data';
  final List<String> _logs = [];
  int _totalDone = 0;
  int _totalItems = 0;
  double _progress = 0.0;

  // ─────────────────────────────────────────────────
  // FIXED IMAGE URL GENERATOR (with seed for consistency)
  // ─────────────────────────────────────────────────
  String _imgUrl(String prompt) {
    final cleanPrompt = prompt
        .trim()
        .replaceAll(RegExp(r'[^\w\s,]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (cleanPrompt.isEmpty) {
      return 'https://via.placeholder.com/400x400/6C3483/FFFFFF?text=Lumixo';
    }
    final seed = cleanPrompt.hashCode.abs();
    final encoded = Uri.encodeComponent(
      '$cleanPrompt, portrait photo, photorealistic, high quality, 4K',
    );
    return 'https://image.pollinations.ai/prompt/$encoded?width=400&height=400&nologo=true&seed=$seed';
  }

  // ─────────────────────────────────────────────────
  // APP CONFIG
  // ─────────────────────────────────────────────────
  Map<String, dynamic> get _appConfig => {
    'pollinations_base_url': 'https://image.pollinations.ai',
    'free_edits_per_day': 3,
    'free_history_days': 30,
    'free_max_edits': 50,
    'coins_per_ad': 2,
    'coins_per_edit': 3,
    'premium_monthly': 199,
    'premium_yearly': 999,
    'app_version': '1.0.0',
    'watermark_text': 'Lumixo',
  };

  // ═══════════════════════════════════════════════════
  // 1. 💼 BUSINESS
  // ═══════════════════════════════════════════════════
  Map<String, dynamic> get _businessCategory => {
    'id': 'business',
    'data': {
      'name': 'Business',
      'icon': '💼',
      'order': 1,
      'is_active': true,
      'description': 'Professional portraits for your career',
      'image_url': ''
    },
    'styles': [
      {'id': 'linkedin_headshot', 'name': 'LinkedIn Headshot', 'is_premium': false, 'order': 1, 'prompt': 'Transform into professional LinkedIn headshot, clean white background, sharp business attire, confident smile, studio lighting, ultra-realistic corporate photography 4K', 'img': 'professional LinkedIn headshot portrait clean white background business suit studio lighting'},
      {'id': 'ceo_portrait', 'name': 'CEO Portrait', 'is_premium': true, 'order': 2, 'prompt': 'Transform into powerful CEO portrait, premium tailored suit, executive office background city skyline, Forbes magazine cover style photography, commanding presence', 'img': 'CEO executive portrait luxury office premium suit Forbes magazine cover style'},
      {'id': 'startup_founder', 'name': 'Startup Founder', 'is_premium': false, 'order': 3, 'prompt': 'Transform into modern startup founder, smart casual outfit, coworking space background, approachable yet confident, tech entrepreneur vibe', 'img': 'startup founder portrait smart casual coworking space tech entrepreneur'},
      {'id': 'formal_suit_navy', 'name': 'Formal Navy Suit', 'is_premium': false, 'order': 4, 'prompt': 'Transform wearing elegant navy blue formal business suit, classic fit with tie, professional studio background, polished grooming', 'img': 'formal navy blue business suit portrait classic tie professional studio'},
      {'id': 'formal_suit_charcoal', 'name': 'Formal Charcoal Suit', 'is_premium': false, 'order': 5, 'prompt': 'Transform wearing sophisticated charcoal gray formal suit, slim fit modern style, crisp white shirt, professional backdrop', 'img': 'formal charcoal gray suit portrait slim fit white shirt executive style'},
      {'id': 'corporate_headshot', 'name': 'Corporate Headshot', 'is_premium': false, 'order': 6, 'prompt': 'Transform into clean corporate headshot, professional business attire, neutral gray background, friendly approachable smile, soft studio lighting', 'img': 'corporate headshot portrait business attire neutral gray background friendly smile'},
      {'id': 'passport_photo', 'name': 'Passport Photo', 'is_premium': false, 'order': 7, 'prompt': 'Transform into official passport photo, plain white background, neutral expression, face centered, proper even lighting, formal attire', 'img': 'official passport photo white background neutral expression formal attire'},
      {'id': 'resume_photo', 'name': 'Resume Photo', 'is_premium': false, 'order': 8, 'prompt': 'Transform into perfect resume CV photo, clean professional background, friendly confident smile, business casual attire', 'img': 'resume CV professional photo clean background friendly smile business casual'},
      {'id': 'doctor_physician', 'name': 'Doctor Look', 'is_premium': false, 'order': 9, 'prompt': 'Transform into professional Doctor portrait, white lab coat, stethoscope around neck, hospital background, trustworthy expression', 'img': 'professional doctor portrait white coat stethoscope hospital background'},
      {'id': 'lawyer_attorney', 'name': 'Lawyer Look', 'is_premium': false, 'order': 10, 'prompt': 'Transform into professional Lawyer portrait, formal suit, law library with books background, serious authoritative expression', 'img': 'professional lawyer portrait formal suit law library books authoritative'},
      {'id': 'tech_professional', 'name': 'Tech Professional', 'is_premium': false, 'order': 11, 'prompt': 'Transform into tech industry professional, smart casual attire, modern tech office background, innovative expression', 'img': 'tech professional portrait smart casual modern tech office Silicon Valley style'},
      {'id': 'finance_pro', 'name': 'Finance Pro', 'is_premium': true, 'order': 12, 'prompt': 'Transform into Wall Street finance professional, sharp suit, financial district background, confident expression', 'img': 'Wall Street finance professional portrait sharp suit financial district'},
      {'id': 'marketing_manager', 'name': 'Marketing Manager', 'is_premium': false, 'order': 13, 'prompt': 'Transform into creative marketing manager, trendy business casual, colorful modern office background', 'img': 'marketing manager creative portrait business casual colorful modern office'},
      {'id': 'consultant', 'name': 'Business Consultant', 'is_premium': false, 'order': 14, 'prompt': 'Transform into Business Consultant portrait, polished business attire, modern consulting firm office background', 'img': 'business consultant portrait polished attire consulting firm office'},
      {'id': 'real_estate_agent', 'name': 'Real Estate Agent', 'is_premium': false, 'order': 15, 'prompt': 'Transform into Real Estate Agent portrait, polished professional attire, luxury property background', 'img': 'real estate agent portrait polished professional luxury property'},
      {'id': 'hr_professional', 'name': 'HR Professional', 'is_premium': false, 'order': 16, 'prompt': 'Transform into HR Professional portrait, business casual attire, welcoming office environment', 'img': 'HR professional portrait business casual welcoming office warm approachable'},
      {'id': 'engineer', 'name': 'Engineer', 'is_premium': false, 'order': 17, 'prompt': 'Transform into professional Engineer portrait, business casual with hard hat optional, engineering workspace', 'img': 'engineer portrait business casual engineering workspace analytical expert'},
      {'id': 'architect', 'name': 'Architect', 'is_premium': false, 'order': 18, 'prompt': 'Transform into professional Architect portrait, smart casual creative attire, architecture studio with blueprints', 'img': 'architect portrait smart casual architecture studio blueprints creative'},
      {'id': 'teacher_professor', 'name': 'Teacher / Professor', 'is_premium': false, 'order': 19, 'prompt': 'Transform into respected teacher professor portrait, smart professional attire, classroom or library background', 'img': 'teacher professor portrait smart professional classroom library background'},
      {'id': 'business_coach', 'name': 'Business Coach', 'is_premium': true, 'order': 20, 'prompt': 'Transform into Business Coach portrait, polished professional attire, coaching studio background, wise motivating expression', 'img': 'business coach portrait polished professional coaching studio wise motivating'},
      {'id': 'executive_boardroom', 'name': 'Executive Boardroom', 'is_premium': true, 'order': 21, 'prompt': 'Transform into executive boardroom portrait, premium suit, luxurious boardroom background with mahogany table', 'img': 'executive boardroom portrait premium suit luxury boardroom mahogany table'},
      {'id': 'managing_director', 'name': 'Managing Director', 'is_premium': true, 'order': 22, 'prompt': 'Transform into Managing Director portrait, bespoke tailored suit, corner office panoramic view', 'img': 'managing director portrait bespoke suit corner office panoramic city view'},
      {'id': 'vice_president', 'name': 'Vice President', 'is_premium': true, 'order': 23, 'prompt': 'Transform into Vice President executive portrait, premium business attire, modern executive suite background', 'img': 'vice president executive portrait premium attire executive suite'},
      {'id': 'chairman_portrait', 'name': 'Chairman Portrait', 'is_premium': true, 'order': 24, 'prompt': 'Transform into distinguished Chairman portrait, impeccable formal attire, prestigious office setting', 'img': 'chairman portrait impeccable formal attire prestigious office'},
      {'id': 'venture_capitalist', 'name': 'Venture Capitalist', 'is_premium': true, 'order': 25, 'prompt': 'Transform into Venture Capitalist portrait, sophisticated smart casual, premium office setting', 'img': 'venture capitalist portrait sophisticated premium office'},
      {'id': 'tech_ceo', 'name': 'Tech CEO', 'is_premium': true, 'order': 26, 'prompt': 'Transform into Silicon Valley tech CEO, black turtleneck or casual blazer, minimalist tech office', 'img': 'tech CEO portrait black turtleneck minimalist tech office visionary'},
      {'id': 'product_manager', 'name': 'Product Manager', 'is_premium': false, 'order': 27, 'prompt': 'Transform into Product Manager portrait, business casual attire, modern tech office with whiteboards', 'img': 'product manager portrait business casual tech office whiteboards'},
      {'id': 'software_engineer', 'name': 'Software Engineer', 'is_premium': false, 'order': 28, 'prompt': 'Transform into Software Engineer portrait, casual tech company attire, modern development workspace', 'img': 'software engineer portrait casual tech attire development workspace'},
      {'id': 'data_scientist', 'name': 'Data Scientist', 'is_premium': false, 'order': 29, 'prompt': 'Transform into Data Scientist portrait, smart casual attire, modern analytics workspace', 'img': 'data scientist portrait smart casual analytics workspace'},
      {'id': 'creative_director', 'name': 'Creative Director', 'is_premium': true, 'order': 30, 'prompt': 'Transform into Creative Director portrait, trendy artistic attire, creative agency studio background', 'img': 'creative director portrait trendy artistic creative agency studio'},
      {'id': 'sales_executive', 'name': 'Sales Executive', 'is_premium': false, 'order': 31, 'prompt': 'Transform into Sales Executive portrait, sharp professional attire, dynamic sales floor background', 'img': 'sales executive portrait sharp professional sales floor'},
      {'id': 'accountant_cpa', 'name': 'Accountant CPA', 'is_premium': false, 'order': 32, 'prompt': 'Transform into professional Accountant portrait, business formal attire, office with financial documents', 'img': 'accountant CPA portrait business formal office financial documents'},
      {'id': 'financial_advisor', 'name': 'Financial Advisor', 'is_premium': false, 'order': 33, 'prompt': 'Transform into Financial Advisor portrait, professional business attire, wealth management office', 'img': 'financial advisor portrait professional attire wealth management office'},
      {'id': 'investment_banker', 'name': 'Investment Banker', 'is_premium': true, 'order': 34, 'prompt': 'Transform into Wall Street Investment Banker portrait, sharp premium suit, financial district skyscraper', 'img': 'investment banker portrait premium suit Wall Street skyscraper'},
      {'id': 'brand_strategist', 'name': 'Brand Strategist', 'is_premium': false, 'order': 35, 'prompt': 'Transform into Brand Strategist portrait, stylish professional attire, modern branding agency', 'img': 'brand strategist portrait stylish professional branding agency'},
      {'id': 'content_creator_biz', 'name': 'Content Creator', 'is_premium': false, 'order': 36, 'prompt': 'Transform into Content Creator portrait, trendy influencer style, creative studio setup', 'img': 'content creator portrait influencer style creative studio'},
      {'id': 'social_media_manager_biz', 'name': 'Social Media Manager', 'is_premium': false, 'order': 37, 'prompt': 'Transform into Social Media Manager portrait, trendy casual, modern digital agency', 'img': 'social media manager portrait trendy casual digital agency'},
      {'id': 'graphic_designer_biz', 'name': 'Graphic Designer', 'is_premium': false, 'order': 38, 'prompt': 'Transform into Graphic Designer portrait, creative casual attire, design studio with artwork', 'img': 'graphic designer portrait creative casual design studio artwork'},
      {'id': 'ux_designer', 'name': 'UX Designer', 'is_premium': false, 'order': 39, 'prompt': 'Transform into UX Designer portrait, modern smart casual, tech design studio', 'img': 'UX designer portrait smart casual tech design studio'},
      {'id': 'business_development', 'name': 'Business Development', 'is_premium': false, 'order': 40, 'prompt': 'Transform into Business Development Manager portrait, polished business attire, modern corporate office', 'img': 'business development portrait polished attire corporate office'},
      {'id': 'account_manager', 'name': 'Account Manager', 'is_premium': false, 'order': 41, 'prompt': 'Transform into Account Manager portrait, professional business attire, client-facing office', 'img': 'account manager portrait professional attire client office'},
      {'id': 'insurance_agent', 'name': 'Insurance Agent', 'is_premium': false, 'order': 42, 'prompt': 'Transform into Insurance Agent portrait, professional business attire, clean office', 'img': 'insurance agent portrait professional attire clean office'},
      {'id': 'team_leader', 'name': 'Team Leader', 'is_premium': false, 'order': 43, 'prompt': 'Transform into Team Leader portrait, smart business casual, collaborative workspace', 'img': 'team leader portrait business casual collaborative workspace'},
      {'id': 'pilot_uniform', 'name': 'Pilot', 'is_premium': false, 'order': 44, 'prompt': 'Transform into airline pilot portrait, pilot uniform with wings badge, airport background', 'img': 'pilot portrait airline uniform wings airport cockpit'},
      {'id': 'chef_culinary', 'name': 'Chef', 'is_premium': false, 'order': 45, 'prompt': 'Transform into chef portrait, professional chef whites and hat, kitchen background', 'img': 'chef portrait professional chef whites hat kitchen'},
      {'id': 'visa_photo', 'name': 'Visa Photo', 'is_premium': false, 'order': 46, 'prompt': 'Transform into visa application photo, clean white background, neutral professional expression', 'img': 'visa application photo white background neutral professional'},
      {'id': 'id_card_photo', 'name': 'ID Card Photo', 'is_premium': false, 'order': 47, 'prompt': 'Transform into official ID card photo, plain background, clear face visible, neutral expression', 'img': 'official ID card photo plain background clear face neutral expression'},
      {'id': 'office_background', 'name': 'Office Background', 'is_premium': false, 'order': 48, 'prompt': 'Transform with modern corporate office background, glass walls city view, professional workspace', 'img': 'corporate office background portrait glass walls city view'},
      {'id': 'surgeon', 'name': 'Surgeon', 'is_premium': true, 'order': 49, 'prompt': 'Transform into Surgeon portrait, surgical scrubs and cap, operating room background', 'img': 'surgeon portrait surgical scrubs operating room'},
      {'id': 'magazine_cover_biz', 'name': 'Magazine Cover', 'is_premium': true, 'order': 50, 'prompt': 'Transform into magazine cover portrait, high-end photography, perfect styling, GQ Esquire cover worthy', 'img': 'magazine cover portrait high-end photography perfect styling GQ Esquire cover'},
    ]
  };

  // ═══════════════════════════════════════════════════
  // 2. 💒 WEDDING
  // ═══════════════════════════════════════════════════
  Map<String, dynamic> get _weddingCategory => {
    'id': 'wedding',
    'data': {'name': 'Wedding', 'icon': '💒', 'order': 2, 'is_active': true, 'description': 'Beautiful wedding portraits and styles', 'image_url': ''},
    'styles': [
      {'id': 'classic_bride', 'name': 'Classic Bride', 'is_premium': false, 'order': 1, 'prompt': 'Transform into beautiful classic bride, elegant white wedding gown, delicate veil, soft romantic makeup, dreamy wedding photography', 'img': 'classic bride portrait white wedding gown delicate veil romantic makeup'},
      {'id': 'royal_bride', 'name': 'Royal Bride', 'is_premium': true, 'order': 2, 'prompt': 'Transform into royal princess bride, luxurious ball gown, sparkling tiara crown, cathedral veil, palace ballroom', 'img': 'royal princess bride ball gown tiara crown palace ballroom'},
      {'id': 'bohemian_bride', 'name': 'Bohemian Bride', 'is_premium': false, 'order': 3, 'prompt': 'Transform into bohemian bride, flowy lace wedding dress, flower crown, natural makeup, garden forest background', 'img': 'bohemian bride flowy lace dress flower crown garden forest'},
      {'id': 'classic_groom', 'name': 'Classic Groom', 'is_premium': false, 'order': 4, 'prompt': 'Transform into classic handsome groom, elegant black tuxedo, bow tie, boutonniere, sophisticated wedding photography', 'img': 'classic groom black tuxedo bow tie boutonniere sophisticated'},
      {'id': 'modern_groom', 'name': 'Modern Groom', 'is_premium': false, 'order': 5, 'prompt': 'Transform into modern stylish groom, slim fit navy suit, contemporary tie, trendy hairstyle, urban venue', 'img': 'modern groom slim fit navy suit contemporary tie trendy hairstyle'},
      {'id': 'indian_bride', 'name': 'Indian Bride', 'is_premium': true, 'order': 6, 'prompt': 'Transform into beautiful Indian bride, stunning red lehenga, intricate gold jewelry, mehndi henna, maang tikka', 'img': 'Indian bride red lehenga gold jewelry mehndi henna maang tikka'},
      {'id': 'indian_groom', 'name': 'Indian Groom', 'is_premium': true, 'order': 7, 'prompt': 'Transform into handsome Indian groom, elegant sherwani, turban safa, traditional jewelry, mandap background', 'img': 'Indian groom elegant sherwani turban safa traditional jewelry mandap'},
      {'id': 'beach_bride', 'name': 'Beach Bride', 'is_premium': false, 'order': 8, 'prompt': 'Transform into beach bride, flowy lightweight wedding dress, barefoot, ocean sunset background, tropical destination', 'img': 'beach bride flowy dress barefoot ocean sunset tropical'},
      {'id': 'beach_groom', 'name': 'Beach Groom', 'is_premium': false, 'order': 9, 'prompt': 'Transform into beach wedding groom, light linen suit, relaxed tropical style, ocean sunset background', 'img': 'beach groom light linen suit ocean sunset tropical'},
      {'id': 'vintage_bride', 'name': 'Vintage Bride', 'is_premium': false, 'order': 10, 'prompt': 'Transform into vintage 1920s bride, art deco inspired gown, finger wave hairstyle, pearl accessories', 'img': 'vintage 1920s bride art deco gown finger waves pearl accessories'},
      {'id': 'rustic_bride', 'name': 'Rustic Bride', 'is_premium': false, 'order': 11, 'prompt': 'Transform into rustic country bride, simple lace dress, wildflower bouquet, barn vineyard background', 'img': 'rustic bride simple lace dress wildflower bouquet barn vineyard'},
      {'id': 'rustic_groom', 'name': 'Rustic Groom', 'is_premium': false, 'order': 12, 'prompt': 'Transform into rustic country groom, tan suit suspenders, boots, wildflower boutonniere, barn background', 'img': 'rustic groom tan suit suspenders boots wildflower barn'},
      {'id': 'fairytale_bride', 'name': 'Fairytale Bride', 'is_premium': true, 'order': 13, 'prompt': 'Transform into fairytale princess bride, magical sparkling ball gown, crystal tiara, enchanted castle', 'img': 'fairytale princess bride sparkling ball gown crystal tiara castle'},
      {'id': 'muslim_bride', 'name': 'Muslim Bride', 'is_premium': true, 'order': 14, 'prompt': 'Transform into beautiful Muslim bride, elegant wedding dress with hijab, stunning jewelry, modest glamorous', 'img': 'Muslim bride elegant dress hijab stunning jewelry modest glamorous'},
      {'id': 'chinese_bride', 'name': 'Chinese Bride', 'is_premium': true, 'order': 15, 'prompt': 'Transform into Chinese bride, stunning red qipao, gold phoenix crown, traditional jewelry', 'img': 'Chinese bride red qipao gold phoenix crown traditional jewelry'},
      {'id': 'korean_bride', 'name': 'Korean Bride', 'is_premium': true, 'order': 16, 'prompt': 'Transform into Korean bride, elegant hanbok wedding dress, traditional norigae accessories, Korean palace', 'img': 'Korean bride hanbok wedding dress norigae Korean palace'},
      {'id': 'japanese_bride', 'name': 'Japanese Bride', 'is_premium': true, 'order': 17, 'prompt': 'Transform into Japanese bride, white shiromuku, kanzashi hair ornaments, temple garden', 'img': 'Japanese bride white shiromuku kanzashi ornaments temple garden'},
      {'id': 'african_bride', 'name': 'African Bride', 'is_premium': true, 'order': 18, 'prompt': 'Transform into African bride, stunning traditional attire, vibrant colors and patterns, gold accessories', 'img': 'African bride traditional attire vibrant colors patterns gold accessories'},
      {'id': 'winter_bride', 'name': 'Winter Bride', 'is_premium': false, 'order': 19, 'prompt': 'Transform into winter wonderland bride, elegant long sleeve gown, faux fur wrap, snowy landscape', 'img': 'winter bride long sleeve gown faux fur wrap snowy landscape'},
      {'id': 'garden_bride', 'name': 'Garden Bride', 'is_premium': false, 'order': 20, 'prompt': 'Transform into garden party bride, romantic floral dress, fresh flower accessories, lush garden', 'img': 'garden bride floral dress flower accessories lush garden'},
      {'id': 'glamorous_bride', 'name': 'Glamorous Bride', 'is_premium': true, 'order': 21, 'prompt': 'Transform into glamorous Hollywood bride, stunning embellished gown, dramatic makeup, sparkling jewelry', 'img': 'glamorous Hollywood bride embellished gown dramatic makeup sparkling jewelry'},
      {'id': 'elegant_bride', 'name': 'Elegant Bride', 'is_premium': false, 'order': 22, 'prompt': 'Transform into elegant sophisticated bride, classic A-line gown, polished updo, grand venue', 'img': 'elegant sophisticated bride A-line gown polished updo grand venue'},
      {'id': 'ethereal_bride', 'name': 'Ethereal Bride', 'is_premium': true, 'order': 23, 'prompt': 'Transform into ethereal angelic bride, flowing gossamer dress, soft dreamy lighting, flower crown halo', 'img': 'ethereal angelic bride gossamer dress dreamy lighting flower crown halo'},
      {'id': 'royal_groom', 'name': 'Royal Groom', 'is_premium': true, 'order': 24, 'prompt': 'Transform into royal prince groom, military style formal jacket, medals sash, palace background', 'img': 'royal prince groom military jacket medals sash palace'},
      {'id': 'vintage_groom', 'name': 'Vintage Groom', 'is_premium': false, 'order': 25, 'prompt': 'Transform into vintage classic groom, three-piece tweed suit, pocket watch, old world charm', 'img': 'vintage groom three-piece tweed suit pocket watch old world charm'},
      {'id': 'castle_wedding', 'name': 'Castle Wedding', 'is_premium': true, 'order': 26, 'prompt': 'Transform into castle wedding portrait, royal attire, medieval castle backdrop, grand staircase', 'img': 'castle wedding portrait royal attire medieval castle grand staircase'},
      {'id': 'vineyard_wedding', 'name': 'Vineyard Wedding', 'is_premium': false, 'order': 27, 'prompt': 'Transform into vineyard wedding portrait, elegant romantic attire, rolling vineyard hills, golden hour', 'img': 'vineyard wedding portrait elegant romantic vineyard hills golden hour'},
      {'id': 'forest_wedding', 'name': 'Forest Wedding', 'is_premium': false, 'order': 28, 'prompt': 'Transform into enchanted forest wedding portrait, whimsical attire, magical forest, dappled sunlight', 'img': 'forest wedding whimsical attire magical forest dappled sunlight'},
      {'id': 'sunset_wedding', 'name': 'Sunset Wedding', 'is_premium': false, 'order': 29, 'prompt': 'Transform into golden sunset wedding portrait, romantic attire, stunning sunset sky, golden hour magic', 'img': 'golden sunset wedding romantic attire sunset sky golden hour magic'},
      {'id': 'tropical_wedding', 'name': 'Tropical Wedding', 'is_premium': false, 'order': 30, 'prompt': 'Transform into tropical paradise wedding, breezy elegant attire, palm trees ocean, exotic flowers', 'img': 'tropical paradise wedding breezy elegant palm trees ocean exotic flowers'},
    ]
  };

  // ═══════════════════════════════════════════════════
  // 3. 🎂 BIRTHDAY
  // ═══════════════════════════════════════════════════
  Map<String, dynamic> get _birthdayCategory => {
    'id': 'birthday',
    'data': {'name': 'Birthday', 'icon': '🎂', 'order': 3, 'is_active': true, 'description': 'Fun birthday party portraits and themes', 'image_url': ''},
    'styles': [
      {'id': 'first_birthday', 'name': 'First Birthday', 'is_premium': false, 'order': 1, 'prompt': 'Transform into adorable first birthday portrait, cute party outfit, big number one balloon, cake smash, pastel colors', 'img': 'first birthday portrait party outfit number one balloon cake smash pastel'},
      {'id': 'sweet_sixteen', 'name': 'Sweet 16', 'is_premium': false, 'order': 2, 'prompt': 'Transform into glamorous sweet sixteen portrait, elegant party dress, sweet 16 tiara, pink gold sparkling', 'img': 'sweet sixteen portrait elegant dress tiara pink gold sparkling'},
      {'id': 'eighteenth_birthday', 'name': '18th Birthday', 'is_premium': false, 'order': 3, 'prompt': 'Transform into 18th birthday portrait, stylish young adult, gold black decorations, number 18 balloons', 'img': '18th birthday portrait stylish gold black number 18'},
      {'id': 'twenty_first', 'name': '21st Birthday', 'is_premium': false, 'order': 4, 'prompt': 'Transform into 21st birthday portrait, glamorous party outfit, champagne sparkles, gold balloons', 'img': '21st birthday portrait glamorous champagne sparkles gold balloons'},
      {'id': 'thirty_birthday', 'name': '30th Birthday', 'is_premium': false, 'order': 5, 'prompt': 'Transform into 30th birthday portrait, chic stylish, dirty thirty, gold rose gold theme', 'img': '30th birthday portrait chic stylish dirty thirty gold rose gold'},
      {'id': 'fifty_birthday', 'name': '50th Birthday', 'is_premium': false, 'order': 6, 'prompt': 'Transform into golden 50th birthday portrait, distinguished elegant, golden fifty, gold white theme', 'img': '50th birthday portrait distinguished elegant golden fifty gold white'},
      {'id': 'princess_birthday', 'name': 'Princess Birthday', 'is_premium': false, 'order': 7, 'prompt': 'Transform into princess birthday portrait, princess dress, sparkling tiara, magical castle background', 'img': 'princess birthday portrait princess dress sparkling tiara magical castle'},
      {'id': 'superhero_birthday', 'name': 'Superhero Birthday', 'is_premium': false, 'order': 8, 'prompt': 'Transform into superhero birthday portrait, superhero costume, cape flowing, comic book style', 'img': 'superhero birthday portrait superhero costume cape comic book style'},
      {'id': 'unicorn_birthday', 'name': 'Unicorn Birthday', 'is_premium': false, 'order': 9, 'prompt': 'Transform into magical unicorn birthday, rainbow pastel, unicorn horn, sparkles stars magical', 'img': 'unicorn birthday portrait rainbow pastel unicorn horn sparkles stars'},
      {'id': 'space_astronaut', 'name': 'Space Astronaut Birthday', 'is_premium': false, 'order': 10, 'prompt': 'Transform into space astronaut birthday, astronaut suit, galaxy space, planets stars', 'img': 'space astronaut birthday astronaut suit galaxy space planets stars'},
      {'id': 'mermaid_birthday', 'name': 'Mermaid Birthday', 'is_premium': false, 'order': 11, 'prompt': 'Transform into mermaid birthday portrait, shimmering tail, underwater ocean, seashells pearls', 'img': 'mermaid birthday portrait shimmering tail underwater ocean seashells'},
      {'id': 'pirate_birthday', 'name': 'Pirate Birthday', 'is_premium': false, 'order': 12, 'prompt': 'Transform into pirate birthday portrait, pirate costume hat, treasure chest, ship ocean', 'img': 'pirate birthday portrait pirate costume hat treasure chest ship'},
      {'id': 'gaming_birthday', 'name': 'Gaming Birthday', 'is_premium': false, 'order': 13, 'prompt': 'Transform into gamer birthday portrait, gamer outfit, neon game room, controllers consoles', 'img': 'gaming birthday portrait gamer outfit neon game room controllers'},
      {'id': 'black_gold_birthday', 'name': 'Black and Gold Birthday', 'is_premium': false, 'order': 14, 'prompt': 'Transform into black and gold birthday portrait, sophisticated black outfit, gold accents, luxurious', 'img': 'black and gold birthday sophisticated black gold accents luxurious'},
      {'id': 'neon_glow_birthday', 'name': 'Neon Glow Birthday', 'is_premium': false, 'order': 15, 'prompt': 'Transform into neon glow birthday portrait, bright neon outfit, glow dark, UV blacklight', 'img': 'neon glow birthday bright neon glow dark UV blacklight'},
      {'id': 'hollywood_birthday', 'name': 'Hollywood Glam Birthday', 'is_premium': true, 'order': 16, 'prompt': 'Transform into Hollywood glamour birthday, red carpet outfit, star studded, paparazzi', 'img': 'Hollywood glamour birthday red carpet outfit star studded paparazzi'},
      {'id': 'masquerade_birthday', 'name': 'Masquerade Birthday', 'is_premium': true, 'order': 17, 'prompt': 'Transform into masquerade birthday portrait, elegant formal, ornate mask, Venetian ballroom', 'img': 'masquerade birthday elegant formal ornate mask Venetian ballroom'},
      {'id': 'beach_birthday', 'name': 'Beach Birthday', 'is_premium': false, 'order': 18, 'prompt': 'Transform into beach birthday portrait, tropical outfit, ocean palm trees, sandcastle surfboards', 'img': 'beach birthday portrait tropical outfit ocean palm trees sandcastle'},
      {'id': 'rockstar_birthday', 'name': 'Rockstar Birthday', 'is_premium': false, 'order': 19, 'prompt': 'Transform into rockstar birthday portrait, rock band outfit, concert stage, guitar lights', 'img': 'rockstar birthday rock outfit concert stage guitar lights'},
      {'id': 'wizard_birthday', 'name': 'Wizard Birthday', 'is_premium': false, 'order': 20, 'prompt': 'Transform into wizard birthday portrait, wizard robe hat, magical library castle, spellbooks', 'img': 'wizard birthday wizard robe hat magical library spellbooks'},
      {'id': 'bollywood_birthday', 'name': 'Bollywood Birthday', 'is_premium': true, 'order': 21, 'prompt': 'Transform into Bollywood star birthday, glamorous Indian outfit, colorful Bollywood set, dance', 'img': 'Bollywood star birthday glamorous Indian outfit colorful set dance'},
      {'id': 'circus_birthday', 'name': 'Circus Birthday', 'is_premium': false, 'order': 22, 'prompt': 'Transform into circus carnival birthday, ringmaster costume, big top tent, colorful stripes', 'img': 'circus carnival birthday ringmaster costume big top tent colorful'},
      {'id': 'disco_birthday', 'name': 'Disco 70s Birthday', 'is_premium': false, 'order': 23, 'prompt': 'Transform into groovy disco birthday, 70s bell bottoms, disco ball lights, retro dance floor', 'img': 'disco 70s birthday bell bottoms disco ball retro dance floor'},
      {'id': 'retro_80s_birthday', 'name': 'Retro 80s Birthday', 'is_premium': false, 'order': 24, 'prompt': 'Transform into 80s birthday portrait, neon outfit leg warmers, boombox arcade, synthwave', 'img': 'retro 80s birthday neon outfit boombox arcade synthwave'},
      {'id': 'safari_birthday', 'name': 'Safari Birthday', 'is_premium': false, 'order': 25, 'prompt': 'Transform into safari jungle birthday, explorer outfit hat, jungle animals, tropical leaves', 'img': 'safari jungle birthday explorer outfit jungle animals tropical'},
    ]
  };

  // ═══════════════════════════════════════════════════
  // 4. 🎉 FESTIVAL
  // ═══════════════════════════════════════════════════
  Map<String, dynamic> get _festivalCategory => {
    'id': 'festival',
    'data': {'name': 'Festival', 'icon': '🎉', 'order': 4, 'is_active': true, 'description': 'Celebrate festivals with stunning portraits', 'image_url': ''},
    'styles': [
      {'id': 'holi_colors', 'name': 'Holi Colors', 'is_premium': false, 'order': 1, 'prompt': 'Transform into vibrant Holi portrait, colorful powder gulal splash, pink purple green yellow, joyful expression, festival of colors', 'img': 'Holi festival portrait colorful powder gulal splash joyful'},
      {'id': 'diwali_diyas', 'name': 'Diwali Diyas', 'is_premium': false, 'order': 2, 'prompt': 'Transform into Diwali portrait holding lit diyas oil lamps, warm golden glow, traditional attire, festival of lights', 'img': 'Diwali portrait holding diyas oil lamps warm golden glow traditional'},
      {'id': 'diwali_ethnic', 'name': 'Diwali Ethnic', 'is_premium': false, 'order': 3, 'prompt': 'Transform into elegant Diwali portrait, ethnic wear saree kurta, gold jewelry, sparklers lights', 'img': 'Diwali ethnic portrait saree kurta gold jewelry sparklers lights'},
      {'id': 'diwali_sparklers', 'name': 'Diwali Sparklers', 'is_premium': false, 'order': 4, 'prompt': 'Transform into joyful Diwali portrait holding sparklers, sparks illuminating face, excited happy, night', 'img': 'Diwali sparklers portrait sparks illuminating face excited happy night'},
      {'id': 'navratri_garba', 'name': 'Navratri Garba', 'is_premium': false, 'order': 5, 'prompt': 'Transform into Navratri garba portrait, colorful chaniya choli kurta, dandiya sticks, dancing, garba night', 'img': 'Navratri garba portrait chaniya choli dandiya sticks dancing'},
      {'id': 'ganesh_chaturthi', 'name': 'Ganesh Chaturthi', 'is_premium': false, 'order': 6, 'prompt': 'Transform into Ganesh Chaturthi portrait, traditional attire, Ganpati decorations, modak, festive', 'img': 'Ganesh Chaturthi portrait traditional attire Ganpati modak festive'},
      {'id': 'eid_mubarak', 'name': 'Eid Mubarak', 'is_premium': false, 'order': 7, 'prompt': 'Transform into elegant Eid portrait, ethnic attire, crescent moon mosque, peaceful blessed', 'img': 'Eid Mubarak portrait ethnic attire crescent moon mosque peaceful'},
      {'id': 'ramadan', 'name': 'Ramadan Kareem', 'is_premium': false, 'order': 8, 'prompt': 'Transform into serene Ramadan portrait, modest elegant, lantern dates, crescent moon, spiritual', 'img': 'Ramadan Kareem portrait modest elegant lantern dates crescent moon'},
      {'id': 'christmas_festive', 'name': 'Christmas Festive', 'is_premium': false, 'order': 9, 'prompt': 'Transform into Christmas portrait, cozy sweater, tree lights background, warm festive glow', 'img': 'Christmas festive portrait sweater tree lights warm festive glow'},
      {'id': 'christmas_santa', 'name': 'Santa Claus', 'is_premium': false, 'order': 10, 'prompt': 'Transform into Santa Claus portrait, red Santa hat outfit, snowy background, jolly expression', 'img': 'Santa Claus portrait red Santa hat snowy jolly expression'},
      {'id': 'new_year', 'name': 'New Year Celebration', 'is_premium': false, 'order': 11, 'prompt': 'Transform into New Year portrait, party glitter outfit, champagne confetti, midnight celebration', 'img': 'New Year portrait party glitter champagne confetti midnight'},
      {'id': 'halloween_costume', 'name': 'Halloween Costume', 'is_premium': false, 'order': 12, 'prompt': 'Transform into Halloween portrait, creative costume makeup, pumpkins spiderwebs, spooky', 'img': 'Halloween costume portrait creative makeup pumpkins spooky'},
      {'id': 'halloween_vampire', 'name': 'Halloween Vampire', 'is_premium': true, 'order': 13, 'prompt': 'Transform into vampire Halloween portrait, gothic elegant, fangs pale skin, dark castle', 'img': 'Halloween vampire portrait gothic fangs dark castle'},
      {'id': 'valentines_fest', 'name': 'Valentines Day', 'is_premium': false, 'order': 14, 'prompt': 'Transform into Valentine portrait, red pink elegant, hearts roses, loving romantic', 'img': 'Valentines Day portrait red pink hearts roses loving romantic'},
      {'id': 'independence_india', 'name': 'Indian Independence Day', 'is_premium': false, 'order': 15, 'prompt': 'Transform into patriotic Indian Independence Day portrait, tricolor orange white green, flag', 'img': 'Indian Independence Day portrait tricolor orange white green flag'},
      {'id': 'raksha_bandhan', 'name': 'Raksha Bandhan', 'is_premium': false, 'order': 16, 'prompt': 'Transform into Raksha Bandhan portrait, decorated rakhi wrist, traditional attire, sibling bond', 'img': 'Raksha Bandhan portrait decorated rakhi wrist traditional attire'},
      {'id': 'easter', 'name': 'Easter', 'is_premium': false, 'order': 17, 'prompt': 'Transform into Easter portrait, spring pastel colors, Easter eggs bunny, flower garden', 'img': 'Easter portrait spring pastel Easter eggs bunny flower garden'},
      {'id': 'thanksgiving', 'name': 'Thanksgiving', 'is_premium': false, 'order': 18, 'prompt': 'Transform into Thanksgiving portrait, cozy autumn attire, harvest decorations, pumpkins leaves', 'img': 'Thanksgiving portrait cozy autumn harvest pumpkins leaves'},
      {'id': 'chinese_new_year', 'name': 'Chinese New Year', 'is_premium': false, 'order': 19, 'prompt': 'Transform into Chinese New Year portrait, red qipao tangzhuang, lanterns gold, Lunar', 'img': 'Chinese New Year portrait red qipao lanterns gold Lunar'},
      {'id': 'mothers_day', 'name': 'Mothers Day', 'is_premium': false, 'order': 20, 'prompt': 'Transform into Mothers Day portrait, elegant graceful, flowers soft colors, warm loving', 'img': 'Mothers Day portrait elegant graceful flowers warm loving'},
      {'id': 'fathers_day', 'name': 'Fathers Day', 'is_premium': false, 'order': 21, 'prompt': 'Transform into Fathers Day portrait, smart casual formal, warm proud, fatherly love', 'img': 'Fathers Day portrait smart casual warm proud fatherly love'},
      {'id': 'makar_sankranti', 'name': 'Makar Sankranti', 'is_premium': false, 'order': 22, 'prompt': 'Transform into Makar Sankranti portrait, colorful kites flying, traditional attire, blue sky', 'img': 'Makar Sankranti portrait colorful kites traditional attire blue sky'},
      {'id': 'lohri', 'name': 'Lohri Festival', 'is_premium': false, 'order': 23, 'prompt': 'Transform into Lohri portrait, Punjabi attire, bonfire glow, winter, popcorn rewri', 'img': 'Lohri festival portrait Punjabi attire bonfire glow winter'},
      {'id': 'onam', 'name': 'Onam Kerala', 'is_premium': false, 'order': 24, 'prompt': 'Transform into Onam portrait, Kerala kasavu saree mundu, pookalam flowers, gold jewelry', 'img': 'Onam Kerala portrait kasavu saree mundu pookalam flowers gold'},
      {'id': 'pongal', 'name': 'Pongal Festival', 'is_premium': false, 'order': 25, 'prompt': 'Transform into Pongal portrait, Tamil traditional attire, pongal pot, kolam rangoli, harvest', 'img': 'Pongal festival portrait Tamil attire pongal pot kolam harvest'},
    ]
  };

  // ═══════════════════════════════════════════════════
  // 5. 📱 SOCIAL MEDIA
  // ═══════════════════════════════════════════════════
  Map<String, dynamic> get _socialMediaCategory => {
    'id': 'social_media',
    'data': {'name': 'Social Media', 'icon': '📱', 'order': 5, 'is_active': true, 'description': 'Perfect portraits for all social platforms', 'image_url': ''},
    'styles': [
      {'id': 'instagram_influencer', 'name': 'Instagram Influencer', 'is_premium': false, 'order': 1, 'prompt': 'Transform into stunning Instagram influencer, perfect lighting, trendy outfit, aesthetic, flawless', 'img': 'Instagram influencer portrait perfect lighting trendy outfit aesthetic'},
      {'id': 'instagram_aesthetic', 'name': 'Instagram Aesthetic', 'is_premium': false, 'order': 2, 'prompt': 'Transform into dreamy Instagram aesthetic portrait, soft pastel, golden hour, minimalist, feed worthy', 'img': 'Instagram aesthetic portrait soft pastel golden hour minimalist'},
      {'id': 'instagram_model', 'name': 'Instagram Model', 'is_premium': true, 'order': 3, 'prompt': 'Transform into professional Instagram model, high fashion, perfect posing, editorial, agency worthy', 'img': 'Instagram model portrait high fashion perfect posing editorial'},
      {'id': 'perfect_selfie', 'name': 'Perfect Selfie', 'is_premium': false, 'order': 4, 'prompt': 'Transform into perfect selfie portrait, flattering angle, natural lighting, casual polished', 'img': 'perfect selfie portrait flattering angle natural lighting casual'},
      {'id': 'youtube_thumbnail', 'name': 'YouTube Thumbnail', 'is_premium': false, 'order': 5, 'prompt': 'Transform into YouTube thumbnail portrait, expressive surprised, bold colors, click-worthy', 'img': 'YouTube thumbnail portrait expressive surprised bold colors click-worthy'},
      {'id': 'youtube_creator', 'name': 'YouTube Creator', 'is_premium': false, 'order': 6, 'prompt': 'Transform into YouTube creator portrait, studio setup, engaging friendly, content creator', 'img': 'YouTube creator portrait studio setup engaging friendly'},
      {'id': 'tiktok_star', 'name': 'TikTok Star', 'is_premium': false, 'order': 7, 'prompt': 'Transform into TikTok star, trendy Gen-Z, ring light glow, viral creator energy', 'img': 'TikTok star portrait trendy Gen-Z ring light viral creator'},
      {'id': 'linkedin_pro', 'name': 'LinkedIn Professional', 'is_premium': false, 'order': 8, 'prompt': 'Transform into LinkedIn professional portrait, business attire, corporate background, confident', 'img': 'LinkedIn professional portrait business attire corporate confident'},
      {'id': 'whatsapp_dp', 'name': 'WhatsApp DP', 'is_premium': false, 'order': 9, 'prompt': 'Transform into perfect WhatsApp DP, clear friendly face, circular crop ready, messaging', 'img': 'WhatsApp DP portrait clear friendly circular crop ready'},
      {'id': 'dating_app', 'name': 'Dating App Profile', 'is_premium': false, 'order': 10, 'prompt': 'Transform into attractive dating app portrait, genuine smile, flattering, swipe-right worthy', 'img': 'dating app portrait genuine smile flattering swipe-right worthy'},
      {'id': 'twitch_streamer', 'name': 'Twitch Streamer', 'is_premium': false, 'order': 11, 'prompt': 'Transform into Twitch streamer, gaming RGB setup, headset mic, engaging, streaming', 'img': 'Twitch streamer portrait gaming RGB headset mic streaming'},
      {'id': 'podcast_host', 'name': 'Podcast Host', 'is_premium': false, 'order': 12, 'prompt': 'Transform into podcast host portrait, professional microphone, studio, articulate engaging', 'img': 'podcast host portrait professional microphone studio engaging'},
      {'id': 'travel_influencer', 'name': 'Travel Influencer', 'is_premium': false, 'order': 13, 'prompt': 'Transform into travel influencer, exotic destination, adventure style, wanderlust', 'img': 'travel influencer portrait exotic destination adventure wanderlust'},
      {'id': 'fitness_influencer', 'name': 'Fitness Influencer', 'is_premium': false, 'order': 14, 'prompt': 'Transform into fitness influencer, athletic wear, gym outdoor, fit healthy, motivational', 'img': 'fitness influencer portrait athletic wear gym outdoor motivational'},
      {'id': 'fashion_influencer', 'name': 'Fashion Influencer', 'is_premium': true, 'order': 15, 'prompt': 'Transform into fashion influencer, designer outfit, street style fashion week, haute couture', 'img': 'fashion influencer portrait designer outfit street style haute couture'},
      {'id': 'beauty_influencer', 'name': 'Beauty Influencer', 'is_premium': false, 'order': 16, 'prompt': 'Transform into beauty influencer, flawless makeup, glowing skin, beauty guru', 'img': 'beauty influencer portrait flawless makeup glowing skin beauty guru'},
      {'id': 'food_blogger', 'name': 'Food Blogger', 'is_premium': false, 'order': 17, 'prompt': 'Transform into food blogger, foodie style, restaurant kitchen, culinary, food creator', 'img': 'food blogger portrait foodie style restaurant kitchen culinary'},
      {'id': 'verified_influencer', 'name': 'Verified Influencer', 'is_premium': true, 'order': 18, 'prompt': 'Transform into verified influencer, celebrity photography, blue checkmark worthy, PR', 'img': 'verified influencer portrait celebrity blue checkmark worthy PR'},
      {'id': 'personal_brand', 'name': 'Personal Brand', 'is_premium': true, 'order': 19, 'prompt': 'Transform into personal brand portrait, signature style, brand aesthetic, entrepreneur CEO', 'img': 'personal brand portrait signature style brand aesthetic entrepreneur'},
      {'id': 'social_headshot', 'name': 'Universal Social Headshot', 'is_premium': false, 'order': 20, 'prompt': 'Transform into universal social media headshot, all platforms, professional approachable', 'img': 'social media headshot portrait all platforms professional approachable'},
    ]
  };

  // ═══════════════════════════════════════════════════
  // 6. 👑 TRADITIONAL & CHARACTERS
  // ═══════════════════════════════════════════════════
  Map<String, dynamic> get _traditionalCategory => {
    'id': 'traditional_characters',
    'data': {'name': 'Traditional & Characters', 'icon': '👑', 'order': 6, 'is_active': true, 'description': 'Royal, mythological and character transformations', 'image_url': ''},
    'styles': [
      {'id': 'indian_king', 'name': 'Indian Maharaja', 'is_premium': true, 'order': 1, 'prompt': 'Transform into majestic Indian Maharaja, royal sherwani embroidery, jeweled crown pagdi, palace throne', 'img': 'Indian Maharaja king royal sherwani jeweled crown palace throne'},
      {'id': 'indian_queen', 'name': 'Indian Maharani', 'is_premium': true, 'order': 2, 'prompt': 'Transform into Indian Maharani queen, royal silk saree, kundan jewelry, royal crown, palace', 'img': 'Indian Maharani queen royal silk saree kundan jewelry palace'},
      {'id': 'rajput_warrior', 'name': 'Rajput Warrior', 'is_premium': true, 'order': 3, 'prompt': 'Transform into fierce Rajput warrior, traditional armor, rajputi turban, sword shield, desert fort', 'img': 'Rajput warrior armor rajputi turban sword shield desert fort'},
      {'id': 'lord_krishna', 'name': 'Lord Krishna', 'is_premium': true, 'order': 4, 'prompt': 'Transform into Lord Krishna, blue skin, peacock feather crown, yellow pitambara, flute, Vrindavan', 'img': 'Lord Krishna blue skin peacock feather crown flute Vrindavan'},
      {'id': 'lord_shiva', 'name': 'Lord Shiva', 'is_premium': true, 'order': 5, 'prompt': 'Transform into Lord Shiva, matted locks Ganga, third eye, trident trishul, Kailash', 'img': 'Lord Shiva matted locks third eye trident Kailash mountain'},
      {'id': 'goddess_durga', 'name': 'Goddess Durga', 'is_premium': true, 'order': 6, 'prompt': 'Transform into Goddess Durga, multiple arms weapons, red saree, riding lion, fierce divine', 'img': 'Goddess Durga multiple arms weapons red saree riding lion'},
      {'id': 'classical_dancer', 'name': 'Classical Dancer', 'is_premium': false, 'order': 7, 'prompt': 'Transform into Indian classical dancer, Bharatanatyam Kathak costume, jewelry, dance pose mudra', 'img': 'Indian classical dancer Bharatanatyam Kathak jewelry dance pose'},
      {'id': 'knight_armor', 'name': 'Knight in Armor', 'is_premium': false, 'order': 8, 'prompt': 'Transform into knight shining armor, full plate armor, sword shield, castle battlefield', 'img': 'knight shining armor plate armor sword shield castle battlefield'},
      {'id': 'samurai_warrior', 'name': 'Samurai Warrior', 'is_premium': true, 'order': 9, 'prompt': 'Transform into Samurai warrior, traditional armor yoroi, katana sword, Japanese castle, bushido', 'img': 'Samurai warrior armor yoroi katana sword Japanese castle'},
      {'id': 'viking_warrior', 'name': 'Viking Warrior', 'is_premium': false, 'order': 10, 'prompt': 'Transform into Viking warrior, leather armor furs, horned helmet, battle axe, Norse fjord', 'img': 'Viking warrior leather armor furs horned helmet battle axe Norse'},
      {'id': 'spartan_warrior', 'name': 'Spartan Warrior', 'is_premium': false, 'order': 11, 'prompt': 'Transform into Spartan warrior, bronze armor red cape, Corinthian helmet, spear shield, 300 style', 'img': 'Spartan warrior bronze armor red cape Corinthian helmet 300'},
      {'id': 'egyptian_pharaoh', 'name': 'Egyptian Pharaoh', 'is_premium': true, 'order': 12, 'prompt': 'Transform into Egyptian Pharaoh, nemes headdress, gold collar jewelry, pyramid, god-king', 'img': 'Egyptian Pharaoh nemes headdress gold collar pyramid'},
      {'id': 'wizard_mage', 'name': 'Wizard Mage', 'is_premium': false, 'order': 13, 'prompt': 'Transform into wizard mage, long robes pointed hat, magical staff, mystical energy, fantasy castle', 'img': 'wizard mage robes pointed hat magical staff fantasy castle'},
      {'id': 'angel_divine', 'name': 'Divine Angel', 'is_premium': true, 'order': 14, 'prompt': 'Transform into divine angel, white feathered wings, flowing white robes, golden halo, heavenly', 'img': 'divine angel white wings flowing robes golden halo heavenly'},
      {'id': 'dark_demon', 'name': 'Dark Demon', 'is_premium': true, 'order': 15, 'prompt': 'Transform into dark demon, horns dark wings, dark armor, hellfire, menacing, underworld', 'img': 'dark demon horns wings dark armor hellfire underworld'},
      {'id': 'fairy_sprite', 'name': 'Forest Fairy', 'is_premium': false, 'order': 16, 'prompt': 'Transform into forest fairy, delicate wings, flower crown, sparkle dust, enchanted forest', 'img': 'forest fairy delicate wings flower crown sparkle enchanted forest'},
      {'id': 'mermaid_char', 'name': 'Mermaid', 'is_premium': false, 'order': 17, 'prompt': 'Transform into mermaid, shimmering fish tail, seashell accessories, underwater ocean, coral reef', 'img': 'mermaid shimmering tail seashell underwater ocean coral reef'},
      {'id': 'dragon_rider', 'name': 'Dragon Rider', 'is_premium': true, 'order': 18, 'prompt': 'Transform into dragon rider, fantasy armor, riding majestic dragon, mountain sky, Game of Thrones', 'img': 'dragon rider fantasy armor riding dragon Game of Thrones'},
      {'id': 'vampire_lord', 'name': 'Vampire Lord', 'is_premium': true, 'order': 19, 'prompt': 'Transform into vampire lord, elegant gothic, pale skin red eyes, fangs, dark castle, immortal', 'img': 'vampire lord elegant gothic pale skin fangs dark castle'},
      {'id': 'geisha', 'name': 'Japanese Geisha', 'is_premium': true, 'order': 20, 'prompt': 'Transform into Japanese Geisha, white face makeup, elaborate kimono, hair kanzashi, tea house', 'img': 'Japanese Geisha white face elaborate kimono kanzashi tea house'},
      {'id': 'elf_warrior', 'name': 'Elf Warrior', 'is_premium': false, 'order': 21, 'prompt': 'Transform into Elf warrior, pointed ears, elven armor, bow arrows, enchanted forest, Legolas', 'img': 'Elf warrior pointed ears elven armor bow arrows enchanted forest'},
      {'id': 'medieval_king', 'name': 'Medieval King', 'is_premium': true, 'order': 22, 'prompt': 'Transform into Medieval European king, royal robes crown, throne room castle, scepter orb', 'img': 'Medieval king royal robes crown throne room castle scepter'},
      {'id': 'medieval_queen', 'name': 'Medieval Queen', 'is_premium': true, 'order': 23, 'prompt': 'Transform into Medieval queen, flowing royal gown, golden crown, castle throne, graceful', 'img': 'Medieval queen flowing royal gown golden crown castle throne'},
      {'id': 'indian_soldier', 'name': 'Indian Soldier', 'is_premium': false, 'order': 24, 'prompt': 'Transform into Indian Army soldier, military uniform medals, patriotic, flag border, brave defender', 'img': 'Indian Army soldier military uniform medals patriotic flag'},
      {'id': 'kathakali', 'name': 'Kathakali Artist', 'is_premium': true, 'order': 25, 'prompt': 'Transform into Kathakali artist, elaborate green face makeup, ornate costume crown, Kerala', 'img': 'Kathakali artist green face makeup ornate costume Kerala'},
    ]
  };

  // ═══════════════════════════════════════════════════
  // 7. 👔 MENS STYLES
  // ═══════════════════════════════════════════════════
  Map<String, dynamic> get _mensCategory => {
    'id': 'mens_styles',
    'data': {'name': 'Mens Styles', 'icon': '👔', 'order': 7, 'is_active': true, 'description': 'Stylish transformations for men', 'image_url': ''},
    'styles': [
      {'id': 'bollywood_hero', 'name': 'Bollywood Hero', 'is_premium': false, 'order': 1, 'prompt': 'Transform into Bollywood hero, stylish movie star, intense romantic eyes, dramatic lighting, poster', 'img': 'Bollywood hero stylish movie star intense romantic dramatic lighting'},
      {'id': 'bollywood_action', 'name': 'Bollywood Action Hero', 'is_premium': true, 'order': 2, 'prompt': 'Transform into Bollywood action hero, rugged muscular, torn shirt, fierce, explosion', 'img': 'Bollywood action hero rugged muscular torn shirt fierce explosion'},
      {'id': 'james_bond', 'name': 'James Bond', 'is_premium': true, 'order': 3, 'prompt': 'Transform into James Bond 007, sleek black tuxedo, sophisticated suave, casino, secret agent', 'img': 'James Bond 007 black tuxedo sophisticated suave casino'},
      {'id': 'streetwear', 'name': 'Streetwear King', 'is_premium': false, 'order': 4, 'prompt': 'Transform into streetwear fashion, hypebeast outfit, sneakers, urban city, street style', 'img': 'streetwear fashion portrait hypebeast sneakers urban city'},
      {'id': 'fashion_model_m', 'name': 'Fashion Model', 'is_premium': true, 'order': 5, 'prompt': 'Transform into male fashion model, editorial high fashion, designer outfit, GQ Vogue', 'img': 'male fashion model editorial high fashion designer outfit GQ'},
      {'id': 'ethnic_kurta', 'name': 'Ethnic Kurta', 'is_premium': false, 'order': 6, 'prompt': 'Transform into ethnic portrait, designer kurta pajama, traditional modern, festive, Indian', 'img': 'ethnic portrait designer kurta pajama traditional festive Indian'},
      {'id': 'sherwani', 'name': 'Elegant Sherwani', 'is_premium': true, 'order': 7, 'prompt': 'Transform into elegant sherwani portrait, rich embroidered, royal Indian groom, wedding', 'img': 'elegant sherwani portrait embroidered royal Indian groom wedding'},
      {'id': 'biker_leather', 'name': 'Biker Style', 'is_premium': false, 'order': 8, 'prompt': 'Transform into biker portrait, leather jacket, motorcycle, rebellious cool, bad boy', 'img': 'biker portrait leather jacket motorcycle rebellious bad boy'},
      {'id': 'hip_hop', 'name': 'Hip Hop Style', 'is_premium': false, 'order': 9, 'prompt': 'Transform into hip hop style, urban rapper fashion, chains, graffiti, hip hop culture', 'img': 'hip hop style portrait rapper fashion chains graffiti'},
      {'id': 'vintage_gentleman', 'name': 'Vintage Gentleman', 'is_premium': false, 'order': 10, 'prompt': 'Transform into vintage gentleman, 1920s style, three-piece suit, pocket watch, Peaky Blinders', 'img': 'vintage gentleman 1920s three-piece suit pocket watch Peaky Blinders'},
      {'id': 'fitness_body', 'name': 'Fitness Bodybuilder', 'is_premium': false, 'order': 11, 'prompt': 'Transform into fitness bodybuilder, muscular physique, gym workout pose, fitness motivation', 'img': 'fitness bodybuilder portrait muscular gym workout fitness motivation'},
      {'id': 'cricket_player', 'name': 'Cricket Player', 'is_premium': false, 'order': 12, 'prompt': 'Transform into cricket player, cricket jersey gear, bat ball, stadium, IPL style', 'img': 'cricket player portrait jersey bat ball stadium IPL'},
      {'id': 'football_player', 'name': 'Football Player', 'is_premium': false, 'order': 13, 'prompt': 'Transform into football player, football kit, dynamic action, stadium field', 'img': 'football player portrait football kit dynamic action stadium'},
      {'id': 'kdrama_hero', 'name': 'K-Drama Hero', 'is_premium': false, 'order': 14, 'prompt': 'Transform into Korean drama hero oppa, flawless skin, stylish Korean fashion, romantic, K-drama', 'img': 'K-drama hero oppa flawless skin Korean fashion romantic'},
      {'id': 'cowboy', 'name': 'Hollywood Cowboy', 'is_premium': false, 'order': 15, 'prompt': 'Transform into rugged cowboy, western outfit hat, desert sunset, Wild West, Clint Eastwood', 'img': 'cowboy western outfit hat desert sunset Wild West'},
      {'id': 'army_officer', 'name': 'Army Officer Hero', 'is_premium': false, 'order': 16, 'prompt': 'Transform into Army officer movie hero, military uniform medals, patriotic intense, war movie', 'img': 'Army officer hero military uniform medals patriotic war movie'},
      {'id': 'beach_vibes', 'name': 'Beach Vibes', 'is_premium': false, 'order': 17, 'prompt': 'Transform into beach vibes portrait, casual beach outfit, tanned relaxed, tropical beach', 'img': 'beach vibes portrait casual beach tanned relaxed tropical'},
      {'id': 'graduation_m', 'name': 'Graduation Portrait', 'is_premium': false, 'order': 18, 'prompt': 'Transform into graduation portrait, cap gown, holding diploma, proud accomplished, university', 'img': 'graduation portrait cap gown diploma proud university'},
      {'id': 'gentleman_classic', 'name': 'Classic Gentleman', 'is_premium': false, 'order': 19, 'prompt': 'Transform into classic gentleman, impeccable tailored suit, refined sophisticated, old money', 'img': 'classic gentleman tailored suit refined sophisticated old money'},
      {'id': 'formal_black_suit', 'name': 'Formal Black Suit', 'is_premium': false, 'order': 20, 'prompt': 'Transform into formal black suit portrait, elegant tie, power dressing, studio lighting', 'img': 'formal black suit portrait elegant tie power dressing studio'},
      {'id': 'magazine_cover_m', 'name': 'Magazine Cover', 'is_premium': true, 'order': 21, 'prompt': 'Transform into magazine cover, high-end photography, perfect styling, GQ Esquire cover', 'img': 'magazine cover portrait high-end perfect styling GQ Esquire'},
      {'id': 'valentine_romantic', 'name': 'Valentine Romantic', 'is_premium': false, 'order': 22, 'prompt': 'Transform into romantic Valentine portrait, holding red roses, loving tender, hearts', 'img': 'Valentine romantic portrait holding roses loving tender hearts'},
      {'id': 'pathani_suit', 'name': 'Pathani Suit', 'is_premium': false, 'order': 23, 'prompt': 'Transform into Pathani suit portrait, classic Pathani kurta, masculine elegant, Eid festive', 'img': 'Pathani suit portrait Pathani kurta masculine elegant Eid'},
      {'id': 'rock_star', 'name': 'Rock Star', 'is_premium': false, 'order': 24, 'prompt': 'Transform into rock star portrait, edgy rock outfit, guitar, concert stage, rock and roll', 'img': 'rock star portrait edgy rock guitar concert stage'},
      {'id': 'yoga_spiritual', 'name': 'Yoga Spiritual', 'is_premium': false, 'order': 25, 'prompt': 'Transform into yoga spiritual portrait, meditation pose, peaceful serene, nature, wellness', 'img': 'yoga spiritual portrait meditation peaceful serene nature'},
    ]
  };

  // ═══════════════════════════════════════════════════
  // 8. 👗 WOMENS STYLES
  // ═══════════════════════════════════════════════════
  Map<String, dynamic> get _womensCategory => {
    'id': 'womens_styles',
    'data': {'name': 'Womens Styles', 'icon': '👗', 'order': 8, 'is_active': true, 'description': 'Elegant and trendy styles for women', 'image_url': ''},
    'styles': [
      {'id': 'bollywood_diva', 'name': 'Bollywood Diva', 'is_premium': false, 'order': 1, 'prompt': 'Transform into Bollywood diva, glamorous saree or gown, stunning makeup jewelry, Bollywood movie poster style', 'img': 'Bollywood diva glamorous saree gown stunning makeup jewelry movie poster'},
      {'id': 'bollywood_retro', 'name': 'Retro Bollywood', 'is_premium': false, 'order': 2, 'prompt': 'Transform into retro Bollywood actress, vintage 70s Indian cinema, bell sleeves, dramatic eyeliner, old Hindi movie', 'img': 'retro Bollywood actress vintage 70s Indian cinema dramatic eyeliner'},
      {'id': 'saree_elegant', 'name': 'Elegant Saree', 'is_premium': false, 'order': 3, 'prompt': 'Transform into elegant saree portrait, designer silk saree, traditional jewelry, graceful pose, ethnic beauty', 'img': 'elegant saree portrait designer silk saree traditional jewelry graceful'},
      {'id': 'lehenga_queen', 'name': 'Lehenga Queen', 'is_premium': true, 'order': 4, 'prompt': 'Transform into lehenga queen, stunning designer lehenga choli, heavy embroidery, royal Indian, wedding reception', 'img': 'lehenga queen stunning designer lehenga choli heavy embroidery royal Indian'},
      {'id': 'anarkali_suit', 'name': 'Anarkali Suit', 'is_premium': false, 'order': 5, 'prompt': 'Transform into Anarkali suit portrait, flowing Anarkali dress, Mughal inspired, elegant, festive', 'img': 'Anarkali suit portrait flowing dress Mughal inspired elegant festive'},
      {'id': 'fashion_model_f', 'name': 'Fashion Model', 'is_premium': true, 'order': 6, 'prompt': 'Transform into female fashion model, haute couture editorial, designer runway, Vogue cover style', 'img': 'female fashion model haute couture editorial designer runway Vogue cover'},
      {'id': 'red_carpet_gown', 'name': 'Red Carpet Gown', 'is_premium': true, 'order': 7, 'prompt': 'Transform into red carpet gown portrait, stunning designer evening gown, glamorous Hollywood, awards ceremony', 'img': 'red carpet gown portrait designer evening gown glamorous Hollywood awards'},
      {'id': 'casual_chic_f', 'name': 'Casual Chic', 'is_premium': false, 'order': 8, 'prompt': 'Transform into casual chic portrait, stylish everyday outfit, effortlessly cool, street style', 'img': 'casual chic portrait stylish everyday outfit effortlessly cool street style'},
      {'id': 'boho_style', 'name': 'Boho Style', 'is_premium': false, 'order': 9, 'prompt': 'Transform into bohemian style portrait, flowy boho outfit, accessories, free spirit, nature festival', 'img': 'bohemian style portrait flowy boho outfit free spirit nature festival'},
      {'id': 'power_suit_f', 'name': 'Power Suit', 'is_premium': false, 'order': 10, 'prompt': 'Transform into power suit woman, sharp tailored blazer pants, boss lady, confident corporate', 'img': 'power suit woman sharp tailored blazer boss lady confident corporate'},
      {'id': 'kdrama_heroine', 'name': 'K-Drama Heroine', 'is_premium': false, 'order': 11, 'prompt': 'Transform into Korean drama heroine, flawless glass skin, stylish Korean fashion, cute elegant, K-drama', 'img': 'K-drama heroine flawless glass skin Korean fashion cute elegant'},
      {'id': 'vintage_pinup', 'name': 'Vintage Pin-Up', 'is_premium': false, 'order': 12, 'prompt': 'Transform into vintage 1950s pin-up style, retro dress, victory rolls hair, classic beauty', 'img': 'vintage 1950s pin-up style retro dress victory rolls classic beauty'},
      {'id': 'gothic_elegant', 'name': 'Gothic Elegant', 'is_premium': false, 'order': 13, 'prompt': 'Transform into elegant gothic portrait, dark romantic, black lace, mysterious, dark beauty', 'img': 'elegant gothic portrait dark romantic black lace mysterious beauty'},
      {'id': 'beach_goddess', 'name': 'Beach Goddess', 'is_premium': false, 'order': 14, 'prompt': 'Transform into beach goddess portrait, flowing beach dress, golden hour sunset, tropical paradise', 'img': 'beach goddess portrait flowing beach dress golden hour sunset tropical'},
      {'id': 'fitness_queen', 'name': 'Fitness Queen', 'is_premium': false, 'order': 15, 'prompt': 'Transform into fitness queen portrait, athletic sportswear, strong confident, gym, fitness motivation', 'img': 'fitness queen portrait athletic sportswear strong confident gym motivation'},
      {'id': 'hijab_elegance', 'name': 'Hijab Elegance', 'is_premium': false, 'order': 16, 'prompt': 'Transform into elegant hijab portrait, beautiful modest fashion, stylish hijab, graceful, modern modest', 'img': 'elegant hijab portrait beautiful modest fashion stylish graceful modern'},
      {'id': 'graduation_f', 'name': 'Graduation Portrait', 'is_premium': false, 'order': 17, 'prompt': 'Transform into graduation portrait, cap gown, holding diploma flowers, proud accomplished, university', 'img': 'graduation portrait cap gown diploma flowers proud university'},
      {'id': 'valentines_queen', 'name': 'Valentine Queen', 'is_premium': false, 'order': 18, 'prompt': 'Transform into Valentine queen portrait, red elegant dress, roses hearts, romantic loving', 'img': 'Valentine queen portrait red elegant dress roses hearts romantic'},
      {'id': 'cocktail_dress', 'name': 'Cocktail Dress', 'is_premium': false, 'order': 19, 'prompt': 'Transform into cocktail party portrait, chic cocktail dress, sophisticated evening, upscale lounge', 'img': 'cocktail party portrait chic cocktail dress sophisticated evening lounge'},
      {'id': 'mehndi_queen', 'name': 'Mehndi Queen', 'is_premium': false, 'order': 20, 'prompt': 'Transform into mehndi queen, beautiful henna hands, green yellow outfit, mehndi ceremony, Indian wedding', 'img': 'mehndi queen beautiful henna hands green yellow outfit Indian wedding'},
      {'id': 'punjabi_suit', 'name': 'Punjabi Suit', 'is_premium': false, 'order': 21, 'prompt': 'Transform into Punjabi suit portrait, colorful salwar kameez, phulkari dupatta, vibrant Punjabi', 'img': 'Punjabi suit portrait colorful salwar kameez phulkari dupatta vibrant'},
      {'id': 'south_silk_saree', 'name': 'South Indian Silk Saree', 'is_premium': true, 'order': 22, 'prompt': 'Transform into South Indian portrait, traditional Kanchipuram silk saree, temple jewelry, jasmine flowers', 'img': 'South Indian portrait Kanchipuram silk saree temple jewelry jasmine'},
      {'id': 'indo_western', 'name': 'Indo-Western Fusion', 'is_premium': false, 'order': 23, 'prompt': 'Transform into Indo-western fusion, modern traditional blend, stylish contemporary Indian', 'img': 'Indo-western fusion portrait modern traditional blend contemporary Indian'},
      {'id': 'magazine_cover_f', 'name': 'Magazine Cover', 'is_premium': true, 'order': 24, 'prompt': 'Transform into magazine cover, high-end photography, perfect styling, Vogue Elle cover worthy', 'img': 'magazine cover portrait high-end photography perfect Vogue Elle cover'},
      {'id': 'classic_beauty', 'name': 'Classic Beauty', 'is_premium': false, 'order': 25, 'prompt': 'Transform into timeless classic beauty, elegant natural, soft lighting, Hollywood golden age glamour', 'img': 'classic beauty portrait elegant natural soft lighting Hollywood golden age'},
    ]
  };

  // ═══════════════════════════════════════════════════
  // 9. 🎨 CREATIVE & ART
  // ═══════════════════════════════════════════════════
  Map<String, dynamic> get _creativeCategory => {
    'id': 'creative_art',
    'data': {'name': 'Creative & Art', 'icon': '🎨', 'order': 9, 'is_active': true, 'description': 'Artistic and creative transformations', 'image_url': ''},
    'styles': [
      {'id': 'oil_painting', 'name': 'Oil Painting', 'is_premium': false, 'order': 1, 'prompt': 'Transform into classical oil painting portrait, Renaissance style, rich colors, canvas texture, museum quality', 'img': 'classical oil painting portrait Renaissance rich colors canvas museum'},
      {'id': 'watercolor', 'name': 'Watercolor', 'is_premium': false, 'order': 2, 'prompt': 'Transform into watercolor painting portrait, soft flowing colors, artistic brushstrokes, dreamy watercolor', 'img': 'watercolor painting portrait soft flowing colors artistic brushstrokes dreamy'},
      {'id': 'pop_art', 'name': 'Pop Art', 'is_premium': false, 'order': 3, 'prompt': 'Transform into Andy Warhol pop art style, bold bright colors, halftone dots, comic style', 'img': 'Andy Warhol pop art style bold bright colors halftone dots comic'},
      {'id': 'anime_portrait', 'name': 'Anime Portrait', 'is_premium': false, 'order': 4, 'prompt': 'Transform into anime character portrait, Japanese anime art style, big expressive eyes, manga', 'img': 'anime character portrait Japanese anime art big expressive eyes manga'},
      {'id': 'comic_book', 'name': 'Comic Book Hero', 'is_premium': false, 'order': 5, 'prompt': 'Transform into comic book hero, Marvel DC style illustration, bold lines, dynamic action pose', 'img': 'comic book hero Marvel DC style bold lines dynamic action pose'},
      {'id': 'pencil_sketch', 'name': 'Pencil Sketch', 'is_premium': false, 'order': 6, 'prompt': 'Transform into detailed pencil sketch portrait, graphite drawing, realistic shading, artist notebook', 'img': 'detailed pencil sketch portrait graphite drawing realistic shading'},
      {'id': 'charcoal_drawing', 'name': 'Charcoal Drawing', 'is_premium': false, 'order': 7, 'prompt': 'Transform into dramatic charcoal drawing portrait, dark shadows, artistic texture, gallery quality', 'img': 'dramatic charcoal drawing portrait dark shadows artistic texture gallery'},
      {'id': 'cyberpunk', 'name': 'Cyberpunk', 'is_premium': false, 'order': 8, 'prompt': 'Transform into cyberpunk portrait, neon lights, futuristic tech, cybernetic implants, Blade Runner', 'img': 'cyberpunk portrait neon lights futuristic tech cybernetic Blade Runner'},
      {'id': 'steampunk', 'name': 'Steampunk', 'is_premium': false, 'order': 9, 'prompt': 'Transform into steampunk portrait, Victorian sci-fi, brass gears goggles, industrial aesthetic', 'img': 'steampunk portrait Victorian sci-fi brass gears goggles industrial'},
      {'id': 'vaporwave', 'name': 'Vaporwave', 'is_premium': false, 'order': 10, 'prompt': 'Transform into vaporwave aesthetic portrait, pink purple blue, retro digital, Greek statue, 90s internet', 'img': 'vaporwave aesthetic portrait pink purple blue retro digital Greek statue'},
      {'id': 'pixel_art', 'name': 'Pixel Art', 'is_premium': false, 'order': 11, 'prompt': 'Transform into pixel art portrait, retro 8-bit game style, pixelated, classic gaming nostalgia', 'img': 'pixel art portrait retro 8-bit game style pixelated classic gaming'},
      {'id': 'graffiti_art', 'name': 'Graffiti Art', 'is_premium': false, 'order': 12, 'prompt': 'Transform into graffiti street art portrait, spray paint style, urban wall, colorful bold', 'img': 'graffiti street art portrait spray paint urban wall colorful bold'},
      {'id': 'neon_portrait', 'name': 'Neon Portrait', 'is_premium': false, 'order': 13, 'prompt': 'Transform into neon light portrait, glowing neon outlines, dark background, vibrant electric', 'img': 'neon light portrait glowing neon outlines dark background vibrant electric'},
      {'id': 'double_exposure', 'name': 'Double Exposure', 'is_premium': true, 'order': 14, 'prompt': 'Transform into double exposure portrait, face merged with nature forest mountains, artistic overlay', 'img': 'double exposure portrait face merged nature forest mountains artistic'},
      {'id': 'stained_glass', 'name': 'Stained Glass', 'is_premium': true, 'order': 15, 'prompt': 'Transform into stained glass portrait, church window style, colorful glass pieces, divine light', 'img': 'stained glass portrait church window colorful glass pieces divine light'},
      {'id': 'mosaic_art', 'name': 'Mosaic Art', 'is_premium': false, 'order': 16, 'prompt': 'Transform into mosaic art portrait, colorful tile pieces, ancient Roman Byzantine, artistic', 'img': 'mosaic art portrait colorful tile pieces ancient Roman Byzantine artistic'},
      {'id': 'renaissance', 'name': 'Renaissance', 'is_premium': true, 'order': 17, 'prompt': 'Transform into Renaissance masterpiece, Leonardo da Vinci Raphael style, classical painting, museum', 'img': 'Renaissance masterpiece da Vinci Raphael classical painting museum'},
      {'id': 'impressionist', 'name': 'Impressionist', 'is_premium': false, 'order': 18, 'prompt': 'Transform into Impressionist painting, Monet Renoir style, soft light brushstrokes, garden', 'img': 'Impressionist painting Monet Renoir soft light brushstrokes garden'},
      {'id': 'surrealism', 'name': 'Surrealism', 'is_premium': true, 'order': 19, 'prompt': 'Transform into surrealist portrait, Salvador Dali style, melting reality, dreamlike, abstract', 'img': 'surrealist portrait Dali style melting reality dreamlike abstract'},
      {'id': 'minimalist_art', 'name': 'Minimalist Art', 'is_premium': false, 'order': 20, 'prompt': 'Transform into minimalist line art portrait, simple clean lines, single continuous line, modern', 'img': 'minimalist line art portrait simple clean lines single continuous modern'},
      {'id': 'art_nouveau', 'name': 'Art Nouveau', 'is_premium': true, 'order': 21, 'prompt': 'Transform into Art Nouveau portrait, Alphonse Mucha style, decorative flowing lines, floral ornamental', 'img': 'Art Nouveau portrait Mucha style decorative flowing lines floral ornamental'},
      {'id': 'clay_sculpture', 'name': 'Clay Sculpture', 'is_premium': true, 'order': 22, 'prompt': 'Transform into clay sculpture portrait, 3D rendered clay figure, studio lighting, art exhibition', 'img': 'clay sculpture portrait 3D rendered clay figure studio art exhibition'},
      {'id': 'lego_portrait', 'name': 'LEGO Portrait', 'is_premium': false, 'order': 23, 'prompt': 'Transform into LEGO brick portrait, colorful LEGO blocks, playful fun, pixel mosaic', 'img': 'LEGO brick portrait colorful blocks playful fun pixel mosaic'},
      {'id': 'low_poly', 'name': 'Low Poly', 'is_premium': false, 'order': 24, 'prompt': 'Transform into low poly geometric portrait, triangular facets, modern digital art, colorful polygons', 'img': 'low poly geometric portrait triangular facets modern digital colorful'},
      {'id': 'glitch_art', 'name': 'Glitch Art', 'is_premium': false, 'order': 25, 'prompt': 'Transform into glitch art portrait, digital distortion, RGB split, corrupted data, cyberpunk', 'img': 'glitch art portrait digital distortion RGB split corrupted data cyberpunk'},
    ]
  };

  // ═══════════════════════════════════════════════════
  // 10. 🎬 PIC TO VIDEO (NEW CATEGORY!)
  // ═══════════════════════════════════════════════════
  Map<String, dynamic> get _picToVideoCategory => {
    'id': 'pic_to_video',
    'data': {'name': 'Pic to Video', 'icon': '🎬', 'order': 10, 'is_active': true, 'description': 'Transform your photos into stunning videos', 'image_url': ''},
    'styles': [
      // CAMERA MOTION
      {'id': 'cinematic_zoom_in', 'name': 'Cinematic Zoom In', 'is_premium': false, 'order': 1, 'prompt': 'Create cinematic slow zoom in video effect, dramatic camera push forward, shallow depth of field, movie atmosphere, 4K smooth motion', 'img': 'cinematic zoom in camera movement dramatic shallow depth of field movie', 'video_type': 'zoom_in', 'duration': 5, 'motion_type': 'camera'},
      {'id': 'cinematic_zoom_out', 'name': 'Cinematic Zoom Out', 'is_premium': false, 'order': 2, 'prompt': 'Create cinematic slow zoom out reveal video, dramatic camera pull back, epic wide reveal, movie quality', 'img': 'cinematic zoom out camera reveal dramatic wide shot epic movie quality', 'video_type': 'zoom_out', 'duration': 5, 'motion_type': 'camera'},
      {'id': 'slow_pan_left', 'name': 'Slow Pan Left', 'is_premium': false, 'order': 3, 'prompt': 'Create smooth slow pan left camera movement video, cinematic horizontal tracking, elegant motion', 'img': 'slow pan left camera movement cinematic horizontal tracking elegant', 'video_type': 'pan_left', 'duration': 5, 'motion_type': 'camera'},
      {'id': 'slow_pan_right', 'name': 'Slow Pan Right', 'is_premium': false, 'order': 4, 'prompt': 'Create smooth slow pan right camera movement video, cinematic horizontal tracking, elegant motion', 'img': 'slow pan right camera movement cinematic tracking elegant motion', 'video_type': 'pan_right', 'duration': 5, 'motion_type': 'camera'},
      {'id': 'tilt_up_reveal', 'name': 'Tilt Up Reveal', 'is_premium': false, 'order': 5, 'prompt': 'Create dramatic tilt up reveal video, camera moves upward, epic reveal moment, cinematic vertical', 'img': 'dramatic tilt up reveal camera upward epic reveal cinematic vertical', 'video_type': 'tilt_up', 'duration': 5, 'motion_type': 'camera'},
      {'id': 'orbit_around', 'name': 'Orbit Around', 'is_premium': true, 'order': 6, 'prompt': 'Create smooth orbit rotation around subject video, 3D camera orbit clockwise, dramatic reveal, cinematic 360', 'img': 'orbit rotation around subject 3D camera orbit dramatic reveal cinematic', 'video_type': 'orbit', 'duration': 6, 'motion_type': 'camera'},
      {'id': 'dolly_forward', 'name': 'Dolly Forward', 'is_premium': false, 'order': 7, 'prompt': 'Create smooth dolly forward push in video, camera glides forward into scene, cinematic tracking shot', 'img': 'dolly forward push in camera glides forward cinematic tracking shot', 'video_type': 'dolly_forward', 'duration': 5, 'motion_type': 'camera'},
      {'id': 'ken_burns', 'name': 'Ken Burns Effect', 'is_premium': false, 'order': 8, 'prompt': 'Create classic Ken Burns documentary effect video, slow zoom with subtle pan, storytelling motion', 'img': 'Ken Burns documentary effect slow zoom subtle pan storytelling motion', 'video_type': 'ken_burns', 'duration': 7, 'motion_type': 'camera'},
      {'id': 'parallax_3d', 'name': '3D Parallax', 'is_premium': true, 'order': 9, 'prompt': 'Create stunning 3D parallax depth effect video, layers moving at different speeds, immersive depth', 'img': '3D parallax depth effect layers different speeds immersive depth', 'video_type': 'parallax', 'duration': 6, 'motion_type': '3d'},

      // WEATHER EFFECTS
      {'id': 'rain_effect', 'name': 'Rain Effect', 'is_premium': false, 'order': 10, 'prompt': 'Add realistic falling rain animation to photo, raindrops, puddle reflections, moody rainy day atmosphere', 'img': 'realistic rain effect animation raindrops falling moody atmosphere', 'video_type': 'weather', 'duration': 8, 'motion_type': 'effect'},
      {'id': 'snow_falling', 'name': 'Snow Falling', 'is_premium': false, 'order': 11, 'prompt': 'Add beautiful falling snow animation to photo, gentle snowflakes drifting, winter wonderland, magical', 'img': 'falling snow animation gentle snowflakes winter wonderland magical', 'video_type': 'weather', 'duration': 8, 'motion_type': 'effect'},
      {'id': 'fog_mist', 'name': 'Fog and Mist', 'is_premium': false, 'order': 12, 'prompt': 'Add drifting fog mist animation to photo, mysterious atmospheric haze, rolling fog, ethereal moody', 'img': 'drifting fog mist animation mysterious atmospheric rolling fog ethereal', 'video_type': 'weather', 'duration': 8, 'motion_type': 'effect'},
      {'id': 'wind_leaves', 'name': 'Wind and Leaves', 'is_premium': false, 'order': 13, 'prompt': 'Add wind blowing leaves animation, autumn leaves floating, hair wind movement, dynamic natural', 'img': 'wind blowing leaves animation autumn leaves floating dynamic natural', 'video_type': 'weather', 'duration': 7, 'motion_type': 'effect'},
      {'id': 'lightning_storm', 'name': 'Lightning Storm', 'is_premium': true, 'order': 14, 'prompt': 'Add dramatic lightning storm animation, thunder flashes, dark stormy sky, dramatic atmosphere', 'img': 'lightning storm animation thunder flashes dark stormy dramatic', 'video_type': 'weather', 'duration': 6, 'motion_type': 'effect'},
      {'id': 'sunrise_effect', 'name': 'Sunrise Effect', 'is_premium': false, 'order': 15, 'prompt': 'Add beautiful sunrise lighting animation, golden hour transition, warm rays appearing, dawn light', 'img': 'sunrise lighting animation golden hour warm rays dawn light', 'video_type': 'lighting', 'duration': 8, 'motion_type': 'effect'},
      {'id': 'sunset_golden', 'name': 'Golden Sunset', 'is_premium': false, 'order': 16, 'prompt': 'Add golden sunset animation effect, warm orange golden light transition, magic hour glow, romantic', 'img': 'golden sunset animation warm orange light magic hour glow romantic', 'video_type': 'lighting', 'duration': 8, 'motion_type': 'effect'},
      {'id': 'cherry_blossom', 'name': 'Cherry Blossom Fall', 'is_premium': false, 'order': 17, 'prompt': 'Add falling cherry blossom petals animation, pink sakura petals floating, Japanese spring, dreamy', 'img': 'falling cherry blossom petals pink sakura Japanese spring dreamy', 'video_type': 'nature', 'duration': 8, 'motion_type': 'effect'},
      {'id': 'fireflies_night', 'name': 'Fireflies Night', 'is_premium': true, 'order': 18, 'prompt': 'Add magical fireflies animation, glowing fireflies floating, enchanted night, warm flickering lights', 'img': 'magical fireflies animation glowing floating enchanted night warm lights', 'video_type': 'nature', 'duration': 8, 'motion_type': 'effect'},

      // PARTICLES
      {'id': 'sparkle_dust', 'name': 'Sparkle Dust', 'is_premium': false, 'order': 19, 'prompt': 'Add magical sparkle dust particles animation, glittering light particles, fairy dust, enchanting shimmer', 'img': 'magical sparkle dust particles glittering light fairy dust shimmer', 'video_type': 'particles', 'duration': 6, 'motion_type': 'effect'},
      {'id': 'fire_embers', 'name': 'Fire Embers', 'is_premium': false, 'order': 20, 'prompt': 'Add floating fire embers particles animation, glowing orange sparks rising, warm firelight, dramatic', 'img': 'floating fire embers particles glowing orange sparks warm firelight', 'video_type': 'particles', 'duration': 7, 'motion_type': 'effect'},
      {'id': 'confetti', 'name': 'Confetti Celebration', 'is_premium': false, 'order': 21, 'prompt': 'Add colorful confetti falling animation, celebration party confetti, festive joyful, birthday party', 'img': 'confetti falling celebration colorful party confetti festive joyful', 'video_type': 'particles', 'duration': 5, 'motion_type': 'effect'},
      {'id': 'bubbles_floating', 'name': 'Floating Bubbles', 'is_premium': false, 'order': 22, 'prompt': 'Add floating soap bubbles animation, iridescent bubbles rising, dreamy whimsical, soft colorful', 'img': 'floating soap bubbles animation iridescent rising dreamy whimsical', 'video_type': 'particles', 'duration': 7, 'motion_type': 'effect'},
      {'id': 'bokeh_lights', 'name': 'Bokeh Lights', 'is_premium': false, 'order': 23, 'prompt': 'Add animated bokeh light circles, colorful out-of-focus lights moving, dreamy night city, romantic', 'img': 'animated bokeh light circles colorful out-of-focus dreamy night romantic', 'video_type': 'particles', 'duration': 6, 'motion_type': 'effect'},
      {'id': 'smoke_effect', 'name': 'Smoke Effect', 'is_premium': false, 'order': 24, 'prompt': 'Add flowing colored smoke animation, ethereal swirling smoke, dramatic atmospheric, mysterious', 'img': 'flowing colored smoke animation ethereal swirling dramatic atmospheric', 'video_type': 'particles', 'duration': 7, 'motion_type': 'effect'},

      // DIGITAL
      {'id': 'glitch_digital', 'name': 'Digital Glitch', 'is_premium': false, 'order': 25, 'prompt': 'Add digital glitch distortion video effect, RGB split, scan lines, cyberpunk data corruption', 'img': 'digital glitch distortion RGB split scan lines cyberpunk', 'video_type': 'digital', 'duration': 4, 'motion_type': 'effect'},
      {'id': 'neon_glow_effect', 'name': 'Neon Glow', 'is_premium': false, 'order': 26, 'prompt': 'Add pulsing neon glow animation effect, neon light outlines pulsing, cyberpunk retro wave, colorful', 'img': 'pulsing neon glow animation neon outlines cyberpunk retro wave glow', 'video_type': 'digital', 'duration': 6, 'motion_type': 'effect'},
      {'id': 'matrix_rain', 'name': 'Matrix Rain', 'is_premium': true, 'order': 27, 'prompt': 'Add Matrix digital rain code animation, green falling characters, hacker cyberpunk, digital', 'img': 'Matrix digital rain code green falling characters hacker cyberpunk', 'video_type': 'digital', 'duration': 6, 'motion_type': 'effect'},

      // FACE ANIMATION
      {'id': 'smile_animation', 'name': 'Smile Animation', 'is_premium': false, 'order': 28, 'prompt': 'Animate face to create natural warm smile, subtle lip movement, eyes light up, genuine happiness', 'img': 'natural warm smile animation subtle lip movement genuine happiness', 'video_type': 'face', 'duration': 3, 'motion_type': 'face'},
      {'id': 'blink_animation', 'name': 'Natural Blink', 'is_premium': false, 'order': 29, 'prompt': 'Animate face with natural blinking, subtle eye movement, realistic living portrait, breathing', 'img': 'natural blinking animation subtle eye movement living portrait', 'video_type': 'face', 'duration': 4, 'motion_type': 'face'},
      {'id': 'head_turn', 'name': 'Head Turn', 'is_premium': true, 'order': 30, 'prompt': 'Animate face with gentle head turn, subtle left to right movement, natural portrait animation', 'img': 'gentle head turn animation subtle movement natural portrait', 'video_type': 'face', 'duration': 4, 'motion_type': 'face'},
      {'id': 'hair_wind', 'name': 'Hair in Wind', 'is_premium': true, 'order': 31, 'prompt': 'Animate hair flowing in wind, breeze movement, dramatic hair flow, cinematic beauty shot', 'img': 'hair flowing in wind breeze movement dramatic flow cinematic beauty', 'video_type': 'face', 'duration': 5, 'motion_type': 'face'},

      // TRANSITIONS
      {'id': 'photo_dissolve', 'name': 'Photo Dissolve', 'is_premium': false, 'order': 32, 'prompt': 'Create artistic photo dissolve animation, particles dispersing and reforming, artistic breaking apart', 'img': 'artistic photo dissolve particles dispersing reforming breaking apart', 'video_type': 'transition', 'duration': 5, 'motion_type': 'transition'},
      {'id': 'sketch_to_photo', 'name': 'Sketch to Photo', 'is_premium': true, 'order': 33, 'prompt': 'Create sketch to photo transformation video, pencil drawing transforms into realistic photo', 'img': 'sketch to photo transformation pencil drawing to realistic artistic', 'video_type': 'transition', 'duration': 6, 'motion_type': 'transition'},
      {'id': 'color_splash', 'name': 'Color Splash', 'is_premium': false, 'order': 34, 'prompt': 'Create color splash animation, black white to full color transition, dramatic colorization', 'img': 'color splash animation black white to color dramatic colorization', 'video_type': 'transition', 'duration': 5, 'motion_type': 'transition'},
      {'id': 'paint_reveal', 'name': 'Paint Reveal', 'is_premium': true, 'order': 35, 'prompt': 'Create paint brush stroke reveal animation, photo appears through artistic brush strokes, watercolor', 'img': 'paint brush stroke reveal photo appears brush strokes watercolor', 'video_type': 'transition', 'duration': 6, 'motion_type': 'transition'},

      // STYLE ANIMATIONS
      {'id': 'day_to_night', 'name': 'Day to Night', 'is_premium': true, 'order': 36, 'prompt': 'Create day to night timelapse transformation, daylight fading to night, stars appearing, dramatic', 'img': 'day to night timelapse daylight to night stars appearing dramatic', 'video_type': 'style', 'duration': 8, 'motion_type': 'transition'},
      {'id': 'season_change', 'name': 'Season Change', 'is_premium': true, 'order': 37, 'prompt': 'Create season change animation, spring to summer autumn winter, foliage changing, timelapse cycle', 'img': 'season change animation spring summer autumn winter foliage changing', 'video_type': 'style', 'duration': 10, 'motion_type': 'transition'},
      {'id': 'comic_transform', 'name': 'Comic Transform', 'is_premium': false, 'order': 38, 'prompt': 'Create comic book transformation animation, photo to comic book style, halftone dots, bold outlines', 'img': 'comic book transformation halftone dots bold outlines comic', 'video_type': 'style', 'duration': 5, 'motion_type': 'transition'},

      // SOCIAL MEDIA VIDEO
      {'id': 'instagram_story_vid', 'name': 'Instagram Story Video', 'is_premium': false, 'order': 39, 'prompt': 'Create Instagram story video, vertical 9:16, subtle zoom with sparkle effects, story-ready', 'img': 'Instagram story video vertical subtle zoom sparkle story-ready', 'video_type': 'social', 'duration': 5, 'motion_type': 'camera', 'aspect_ratio': '9:16'},
      {'id': 'tiktok_video', 'name': 'TikTok Video', 'is_premium': false, 'order': 40, 'prompt': 'Create TikTok viral video, dynamic transitions, trendy effects, vertical video, engaging zoom', 'img': 'TikTok viral video dynamic transitions trendy effects vertical', 'video_type': 'social', 'duration': 5, 'motion_type': 'camera', 'aspect_ratio': '9:16'},
      {'id': 'youtube_shorts', 'name': 'YouTube Shorts', 'is_premium': false, 'order': 41, 'prompt': 'Create YouTube Shorts video, engaging motion, vertical format, professional transition, eye-catching', 'img': 'YouTube Shorts video engaging motion vertical professional transition', 'video_type': 'social', 'duration': 5, 'motion_type': 'camera', 'aspect_ratio': '9:16'},
      {'id': 'whatsapp_status_vid', 'name': 'WhatsApp Status', 'is_premium': false, 'order': 42, 'prompt': 'Create WhatsApp status video, beautiful motion effect, personal touch, short engaging loop', 'img': 'WhatsApp status video beautiful motion personal engaging loop', 'video_type': 'social', 'duration': 5, 'motion_type': 'camera', 'aspect_ratio': '9:16'},
      {'id': 'cinemagraph', 'name': 'Cinemagraph Loop', 'is_premium': true, 'order': 43, 'prompt': 'Create perfect cinemagraph, most of image static while one element moves, seamless loop', 'img': 'cinemagraph static image one element moves seamless loop mesmerizing', 'video_type': 'cinemagraph', 'duration': 6, 'motion_type': 'effect'},

      // SPECIAL EFFECTS
      {'id': 'clouds_moving', 'name': 'Moving Clouds', 'is_premium': false, 'order': 44, 'prompt': 'Add moving clouds sky animation, timelapse cloud movement, dramatic sky changes, epic atmosphere', 'img': 'moving clouds sky animation timelapse dramatic sky epic atmosphere', 'video_type': 'weather', 'duration': 8, 'motion_type': 'effect'},
      {'id': 'water_ripple', 'name': 'Water Ripple', 'is_premium': false, 'order': 45, 'prompt': 'Add water ripple reflection animation, gentle water surface movement, peaceful serene, dreamy reflection', 'img': 'water ripple reflection animation gentle surface movement peaceful dreamy', 'video_type': 'nature', 'duration': 7, 'motion_type': 'effect'},
      {'id': 'aurora_borealis', 'name': 'Aurora Borealis', 'is_premium': true, 'order': 46, 'prompt': 'Add northern lights aurora borealis animation, green purple lights dancing sky, magical Arctic', 'img': 'aurora borealis northern lights green purple lights dancing sky magical', 'video_type': 'nature', 'duration': 8, 'motion_type': 'effect'},
      {'id': 'flower_bloom', 'name': 'Flower Bloom', 'is_premium': false, 'order': 47, 'prompt': 'Add flower blooming animation around portrait, petals opening, spring growth, beautiful natural', 'img': 'flower blooming animation petals opening spring growth beautiful natural', 'video_type': 'nature', 'duration': 6, 'motion_type': 'effect'},
      {'id': 'butterfly_effect', 'name': 'Butterfly Effect', 'is_premium': false, 'order': 48, 'prompt': 'Add colorful butterflies flying animation around portrait, magical nature, whimsical beautiful', 'img': 'colorful butterflies flying animation magical nature whimsical beautiful', 'video_type': 'nature', 'duration': 7, 'motion_type': 'effect'},
      {'id': 'hologram_effect', 'name': 'Hologram Effect', 'is_premium': true, 'order': 49, 'prompt': 'Add futuristic hologram scan effect, blue light scanning, sci-fi technology, Iron Man JARVIS', 'img': 'futuristic hologram scan effect blue light scanning sci-fi technology', 'video_type': 'digital', 'duration': 5, 'motion_type': 'effect'},
      {'id': 'galaxy_portal', 'name': 'Galaxy Portal', 'is_premium': true, 'order': 50, 'prompt': 'Add galaxy space portal animation around portrait, cosmic swirling energy, stars nebula, epic space', 'img': 'galaxy space portal animation cosmic swirling energy stars nebula epic', 'video_type': 'digital', 'duration': 7, 'motion_type': 'effect'},
    ]
  };

  // ─────────────────────────────────────────────────
  // ALL CATEGORIES LIST
  // ─────────────────────────────────────────────────
  List<Map<String, dynamic>> get _allCategories => [
    _businessCategory,
    _weddingCategory,
    _birthdayCategory,
    _festivalCategory,
    _socialMediaCategory,
    _traditionalCategory,
    _mensCategory,
    _womensCategory,
    _creativeCategory,
    _picToVideoCategory,
  ];

  // ═══════════════════════════════════════════════════
  // SEEDING LOGIC
  // ═══════════════════════════════════════════════════
  Future<void> _seedAll() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _logs.clear();
      _totalDone = 0;
      _progress = 0.0;
    });

    try {
      int totalStyles = 0;
      for (final cat in _allCategories) {
        totalStyles += (cat['styles'] as List).length;
      }
      _totalItems = totalStyles + _allCategories.length + 1;

      // 1. App Config
      _addLog('📦 Seeding app config...');
      await _db.collection('app_config').doc('settings').set(_appConfig);
      _incrementProgress();
      _addLog('✅ App config done');

      // 2. Categories & Styles
      for (final cat in _allCategories) {
        final catId = cat['id'] as String;
        final catData = Map<String, dynamic>.from(cat['data']);
        final styles = cat['styles'] as List;

        _addLog('📁 ${catData['name']} (${styles.length} styles)...');

        // Use first style image for category thumbnail
        final firstStyle = styles.first;
        catData['image_url'] = _imgUrl(firstStyle['img']);

        await _db.collection('categories').doc(catId).set(catData);
        _incrementProgress();

        for (final style in styles) {
          final styleData = <String, dynamic>{
            'name': style['name'],
            'prompt': style['prompt'],
            'image_url': _imgUrl(style['img']),
            'is_premium': style['is_premium'] ?? false,
            'order': style['order'] ?? 0,
            'category_id': catId,
            'is_active': true,
            'created_at': FieldValue.serverTimestamp(),
          };

          // Add video-specific fields for pic_to_video
          if (catId == 'pic_to_video') {
            styleData['video_type'] = style['video_type'] ?? 'camera';
            styleData['duration'] = style['duration'] ?? 5;
            styleData['motion_type'] = style['motion_type'] ?? 'camera';
            if (style.containsKey('aspect_ratio')) {
              styleData['aspect_ratio'] = style['aspect_ratio'];
            }
          }

          await _db
              .collection('categories')
              .doc(catId)
              .collection('styles')
              .doc(style['id'])
              .set(styleData);

          _incrementProgress();
        }

        _addLog('✅ ${catData['name']} done (${styles.length})');
      }

      setState(() {
        _status = '🎉 SUCCESS! All $_totalItems items seeded!';
        _isLoading = false;
        _progress = 1.0;
      });
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
        _isLoading = false;
      });
      _addLog('❌ Error: $e');
    }
  }

  // Seed only Pic to Video
  Future<void> _seedPicToVideo() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _logs.clear();
      _totalDone = 0;
      _progress = 0.0;
    });

    try {
      final cat = _picToVideoCategory;
      final catId = cat['id'] as String;
      final catData = Map<String, dynamic>.from(cat['data']);
      final styles = cat['styles'] as List;
      _totalItems = styles.length + 1;

      _addLog('🎬 Seeding Pic to Video (${styles.length} styles)...');

      final firstStyle = styles.first;
      catData['image_url'] = _imgUrl(firstStyle['img']);
      await _db.collection('categories').doc(catId).set(catData);
      _incrementProgress();

      for (final style in styles) {
        final styleData = <String, dynamic>{
          'name': style['name'],
          'prompt': style['prompt'],
          'image_url': _imgUrl(style['img']),
          'is_premium': style['is_premium'] ?? false,
          'order': style['order'] ?? 0,
          'category_id': catId,
          'is_active': true,
          'video_type': style['video_type'] ?? 'camera',
          'duration': style['duration'] ?? 5,
          'motion_type': style['motion_type'] ?? 'camera',
          'created_at': FieldValue.serverTimestamp(),
        };
        if (style.containsKey('aspect_ratio')) {
          styleData['aspect_ratio'] = style['aspect_ratio'];
        }

        await _db
            .collection('categories')
            .doc(catId)
            .collection('styles')
            .doc(style['id'])
            .set(styleData);
        _incrementProgress();
      }

      _addLog('✅ Pic to Video done (${styles.length})');
      setState(() {
        _status = '🎉 Pic to Video seeded!';
        _isLoading = false;
        _progress = 1.0;
      });
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
        _isLoading = false;
      });
      _addLog('❌ Error: $e');
    }
  }

  void _incrementProgress() {
    setState(() {
      _totalDone++;
      _progress = _totalDone / _totalItems;
    });
  }

  void _addLog(String msg) {
    setState(() {
      _logs.add('[${DateTime.now().toString().substring(11, 19)}] $msg');
    });
  }

  int _countPremium() {
    int count = 0;
    for (final cat in _allCategories) {
      for (final style in cat['styles']) {
        if (style['is_premium'] == true) count++;
      }
    }
    return count;
  }

  // ═══════════════════════════════════════════════════
  // BUILD METHOD
  // ═══════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    int totalStyles = 0;
    for (final cat in _allCategories) {
      totalStyles += (cat['styles'] as List).length;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🌱 Seed Lumixo Database'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Stats Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple.shade400, Colors.purple.shade300],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    '📊 Lumixo Seed Data',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statItem('📁 Categories', '${_allCategories.length}'),
                      _statItem('🎨 Styles', '$totalStyles'),
                      _statItem('⭐ Premium', '${_countPremium()}'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Category List
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📋 Categories:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ..._allCategories.map((cat) {
                    final styles = cat['styles'] as List;
                    final premium = styles.where((s) => s['is_premium'] == true).length;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        '${cat['data']['icon']} ${cat['data']['name']}: ${styles.length} styles ($premium premium)',
                        style: const TextStyle(fontSize: 13),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(_status, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
            ),
            const SizedBox(height: 12),

            // Progress
            if (_isLoading) ...[
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.grey.shade300,
                valueColor: const AlwaysStoppedAnimation(Colors.deepPurple),
              ),
              const SizedBox(height: 8),
              Text(
                '${(_progress * 100).toStringAsFixed(1)}% ($_totalDone / $_totalItems)',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
            ],

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _seedAll,
                    icon: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.rocket_launch),
                    label: Text(_isLoading ? 'Seeding...' : 'Seed All Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _seedPicToVideo,
                    icon: const Icon(Icons.videocam),
                    label: const Text('Seed Pic→Video'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Logs
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: _logs.length,
                  itemBuilder: (_, i) => Text(
                    _logs[i],
                    style: TextStyle(
                      color: _logs[i].contains('✅')
                          ? Colors.greenAccent
                          : _logs[i].contains('❌')
                          ? Colors.redAccent
                          : Colors.white70,
                      fontFamily: 'monospace',
                      fontSize: 12,
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

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
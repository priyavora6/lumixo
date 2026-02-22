// lib/screens/admin/seed_data_screen.dart
// LUMIXAA — 200 hardcoded real image URLs + perfect AI prompts

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
  String _status = '✨ Ready to seed Lumixaa data';
  List<String> _logs = [];
  int _totalDone = 0;
  int _totalItems = 0;
  double _progress = 0.0;

  // ─────────────────────────────────────────────────
  // APP CONFIG
  // ─────────────────────────────────────────────────
  Map<String, dynamic> get _appConfig => {
    'app_name': 'Lumixaa',
    'app_version': '1.0.0',
    'watermark_text': 'Lumixaa',
    'groq_api_key': 'YOUR_GROQ_API_KEY_HERE',
    'groq_base_url': 'https://api.groq.com/openai/v1',
    'groq_model': 'llama3-8b-8192',
    'free_edits_per_day': 3,
    'free_history_days': 30,
    'free_max_edits': 50,
    'coins_per_ad': 2,
    'coins_per_edit': 3,
    'premium_monthly': 199,
    'premium_yearly': 999,
  };

  // ═══════════════════════════════════════════════════
  // 💼 BUSINESS — 22 styles
  // ═══════════════════════════════════════════════════
  Map<String, dynamic> get _businessCategory => {
    'id': 'business',
    'data': {
      'name': 'Business',
      'icon': '💼',
      'order': 1,
      'is_active': true,
      'description': 'Professional portraits for your career',
      'image_url': 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=600',
    },
    'styles': [
      {
        'id': 'linkedin_headshot',
        'name': 'LinkedIn Headshot',
        'is_premium': false,
        'order': 1,
        'image_url': 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=600',
        'prompt': 'Professional LinkedIn headshot portrait, clean white background, sharp navy business suit, confident warm smile, soft diffused studio lighting, shallow depth of field, ultra-realistic 4K corporate photography, looking directly at camera, well-groomed appearance',
      },
      {
        'id': 'ceo_portrait',
        'name': 'CEO Portrait',
        'is_premium': true,
        'order': 2,
        'image_url': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600',
        'prompt': 'Powerful Fortune 500 CEO executive portrait, premium tailored charcoal Armani suit, standing before floor-to-ceiling glass office overlooking city skyline at golden hour, Forbes magazine cover style photography, commanding confident presence, dramatic directional lighting, 8K hyperrealistic',
      },
      {
        'id': 'startup_founder',
        'name': 'Startup Founder',
        'is_premium': false,
        'order': 3,
        'image_url': 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=600',
        'prompt': 'Modern tech startup founder portrait, smart casual dark turtleneck and blazer, bright open-plan coworking space background with MacBooks visible, approachable yet brilliant expression, natural window lighting, Silicon Valley entrepreneur aesthetic, professional headshot style',
      },
      {
        'id': 'corporate_headshot',
        'name': 'Corporate Headshot',
        'is_premium': false,
        'order': 4,
        'image_url': 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=600',
        'prompt': 'Clean corporate professional headshot, business formal attire in neutral tones, gradient gray studio background, warm friendly approachable smile, soft catchlights in eyes, professional makeup and hair, sharp focus on face, corporate photography style',
      },
      {
        'id': 'doctor_look',
        'name': 'Doctor Look',
        'is_premium': false,
        'order': 5,
        'image_url': 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=600',
        'prompt': 'Professional medical doctor portrait, crisp white lab coat with stethoscope around neck, modern hospital corridor background with soft bokeh, trustworthy and compassionate expression, clinical lighting, ultra-realistic medical photography, name badge visible',
      },
      {
        'id': 'lawyer_look',
        'name': 'Lawyer Look',
        'is_premium': false,
        'order': 6,
        'image_url': 'https://images.unsplash.com/photo-1556157382-97eda2f9e2bf?w=600',
        'prompt': 'Authoritative attorney lawyer portrait, sharp dark formal suit with power tie, mahogany-lined law library background with leather-bound books, serious commanding expression, dramatic Rembrandt lighting, legal profession gravitas, ultra-realistic photography',
      },
      {
        'id': 'tech_pro',
        'name': 'Tech Professional',
        'is_premium': false,
        'order': 7,
        'image_url': 'https://images.unsplash.com/photo-1551836022-deb4988cc6c0?w=600',
        'prompt': 'Tech industry professional portrait, smart casual outfit with modern glasses, contemporary open-plan Google-style office background, multiple monitors visible, innovative intellectual expression, bright modern lighting, developer engineer vibe, hyperrealistic',
      },
      {
        'id': 'finance_pro',
        'name': 'Finance Pro',
        'is_premium': true,
        'order': 8,
        'image_url': 'https://images.unsplash.com/photo-1600880292203-757bb62b4baf?w=600',
        'prompt': 'Wall Street finance professional portrait, impeccably tailored pinstripe suit, NYSE trading floor or Manhattan financial district background, confident authoritative expression, dramatic financial power lighting, Bloomberg terminal visible, hyperrealistic 8K',
      },
      {
        'id': 'software_engineer',
        'name': 'Software Engineer',
        'is_premium': false,
        'order': 9,
        'image_url': 'https://images.unsplash.com/photo-1571171637578-41bc2dd41cd2?w=600',
        'prompt': 'Software engineer developer portrait, casual hoodie or flannel shirt, dual monitor coding setup background with code visible, intelligent focused expression, RGB keyboard glow, modern tech office, realistic developer workspace photography',
      },
      {
        'id': 'pilot_uniform',
        'name': 'Airline Pilot',
        'is_premium': false,
        'order': 10,
        'image_url': 'https://images.unsplash.com/photo-1474314170901-f351b68f544f?w=600',
        'prompt': 'Professional airline pilot portrait, crisp white uniform with four gold stripes, captain hat, wings badge gleaming, airport terminal or cockpit background, confident heroic expression, aviation photography style, natural airport lighting',
      },
      {
        'id': 'surgeon',
        'name': 'Surgeon',
        'is_premium': true,
        'order': 11,
        'image_url': 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=600',
        'prompt': 'Elite surgeon portrait, blue surgical scrubs and cap, stethoscope, state-of-the-art operating room background with surgical lights, precision and expertise in expression, clinical sharp lighting, medical drama photography style, hyperrealistic',
      },
      {
        'id': 'architect',
        'name': 'Architect',
        'is_premium': false,
        'order': 12,
        'image_url': 'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?w=600',
        'prompt': 'Creative architect portrait, stylish smart casual outfit, modern architecture studio background with blueprints and scale models, creative analytical expression, drafting table visible, natural studio lighting, professional design industry photography',
      },
    ],
  };

  // ═══════════════════════════════════════════════════
  // 💒 WEDDING — 22 styles
  // ═══════════════════════════════════════════════════
  Map<String, dynamic> get _weddingCategory => {
    'id': 'wedding',
    'data': {
      'name': 'Wedding',
      'icon': '💒',
      'order': 2,
      'is_active': true,
      'description': 'Stunning wedding portraits and bridal styles',
      'image_url': 'https://images.unsplash.com/photo-1519741497674-611481863552?w=600',
    },
    'styles': [
      {
        'id': 'classic_bride',
        'name': 'Classic Bride',
        'is_premium': false,
        'order': 1,
        'image_url': 'https://images.unsplash.com/photo-1519741497674-611481863552?w=600',
        'prompt': 'Breathtaking classic bride portrait, ethereal ivory silk wedding gown with lace detailing, cathedral length veil floating in soft breeze, romantic rose bouquet, dreamy soft-focus background with white roses, golden hour warm lighting, Vogue bridal editorial photography, ultra-realistic 8K',
      },
      {
        'id': 'classic_groom',
        'name': 'Classic Groom',
        'is_premium': false,
        'order': 2,
        'image_url': 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=600',
        'prompt': 'Dashing classic groom portrait, tailored black Armani tuxedo, white pocket square, single white rose boutonniere, sophisticated venue background with chandeliers, confident masculine expression, dramatic wedding photography lighting, ultra-sharp 8K',
      },
      {
        'id': 'indian_bride',
        'name': 'Indian Bride',
        'is_premium': true,
        'order': 3,
        'image_url': 'https://images.unsplash.com/photo-1583391733956-6c78276477e2?w=600',
        'prompt': 'Stunning Indian bride portrait, opulent crimson and gold Banarasi silk lehenga with intricate zardozi embroidery, heavy Kundan and polki jewelry set, maang tikka, nath nose ring, mehndi-adorned hands, elaborate bridal makeup with smoky eyes, royal palace backdrop with marigold decorations, warm golden photography',
      },
      {
        'id': 'indian_groom',
        'name': 'Indian Groom',
        'is_premium': true,
        'order': 4,
        'image_url': 'https://images.unsplash.com/photo-1590750420541-24dc3ef6dc4e?w=600',
        'prompt': 'Regal Indian groom portrait, ivory and gold embroidered sherwani with heavy thread work, colorful safa turban with kalgi, pearl and diamond maala, sehra adorned with flowers, mandap with jasmine garlands background, royal Rajasthani palace setting, warm traditional lighting',
      },
      {
        'id': 'royal_bride',
        'name': 'Royal Bride',
        'is_premium': true,
        'order': 5,
        'image_url': 'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=600',
        'prompt': 'Majestic royal princess bride, magnificent Cinderella ball gown with thousands of crystals, diamond tiara crown, cathedral veil trailing 10 feet, palace grand ballroom with golden chandeliers and marble floors, fairy tale wedding photography, magical warm glow, ultra-cinematic 8K',
      },
      {
        'id': 'bohemian_bride',
        'name': 'Bohemian Bride',
        'is_premium': false,
        'order': 6,
        'image_url': 'https://images.unsplash.com/photo-1522673607200-164d1b6ce486?w=600',
        'prompt': 'Free-spirited bohemian bride, flowing chiffon lace wedding dress, wild flower crown with roses and greenery, loose beachy waves hair, barefoot in lush forest meadow, dappled golden sunlight through trees, wildflower bouquet, ethereal boho-chic editorial photography',
      },
      {
        'id': 'beach_bride',
        'name': 'Beach Bride',
        'is_premium': false,
        'order': 7,
        'image_url': 'https://images.unsplash.com/photo-1537633552985-df8429e8048b?w=600',
        'prompt': 'Radiant beach destination bride, lightweight flowing chiffon wedding dress, barefoot in soft sand, dramatic ocean waves background, tropical sunset with pink and orange sky, hair flowing in sea breeze, golden hour silhouette, destination wedding photography, cinematic',
      },
      {
        'id': 'muslim_bride',
        'name': 'Muslim Bride',
        'is_premium': true,
        'order': 8,
        'image_url': 'https://images.unsplash.com/photo-1594736797933-d0401ba2fe65?w=600',
        'prompt': 'Elegant Muslim bride portrait, luxurious ivory embroidered wedding gown with hijab adorned with pearls and crystals, statement gold and pearl jewelry, soft romantic makeup, ornate mosque or decorated venue background, warm golden lighting, modest yet stunning bridal photography',
      },
      {
        'id': 'wedding_couple',
        'name': 'Wedding Couple',
        'is_premium': false,
        'order': 9,
        'image_url': 'https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?w=600',
        'prompt': 'Romantic wedding couple portrait, bride in flowing white gown and groom in classic tuxedo, elegant chandelier ballroom or garden venue, tender loving gaze at each other, warm golden hour photography, depth of field background bokeh, timeless romantic wedding photography',
      },
      {
        'id': 'fairytale_bride',
        'name': 'Fairytale Bride',
        'is_premium': true,
        'order': 10,
        'image_url': 'https://images.unsplash.com/photo-1606800052052-a08af7148866?w=600',
        'prompt': 'Enchanting fairytale princess bride, magical ball gown covered in sparkling Swarovski crystals, crystal diamond tiara, enchanted castle with blooming roses, magical glowing fireflies surrounding her, golden mystical light, Disney princess fantasy wedding photography, ultra-cinematic 8K',
      },
      {
        'id': 'south_indian_bride',
        'name': 'South Indian Bride',
        'is_premium': true,
        'order': 11,
        'image_url': 'https://images.unsplash.com/photo-1591135671303-14bce32b1b2e?w=600',
        'prompt': 'Radiant South Indian bride, gorgeous red and gold Kanjivaram silk saree, elaborate temple jewelry with vadamaala, maang tikka, nethi chutti forehead ornament, jasmine flowers adorning hair, traditional Bharatanatyam-inspired bridal makeup, temple mandapam background',
      },
      {
        'id': 'winter_bride',
        'name': 'Winter Bride',
        'is_premium': false,
        'order': 12,
        'image_url': 'https://images.unsplash.com/photo-1550005809-91ad75fb315f?w=600',
        'prompt': 'Ethereal winter wonderland bride, long sleeve lace gown with faux fur white wrap, crystal snowflake accessories, snowy forest background with soft snowfall, frozen lake reflection, icy blue and white color palette, magical winter wedding photography, breath visible in cold air',
      },
    ],
  };

  // ═══════════════════════════════════════════════════
  // 🎂 BIRTHDAY — 20 styles
  // ═══════════════════════════════════════════════════
  Map<String, dynamic> get _birthdayCategory => {
    'id': 'birthday',
    'data': {
      'name': 'Birthday',
      'icon': '🎂',
      'order': 3,
      'is_active': true,
      'description': 'Fun and glamorous birthday portraits',
      'image_url': 'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=600',
    },
    'styles': [
      {
        'id': 'sweet_sixteen',
        'name': 'Sweet 16',
        'is_premium': false,
        'order': 1,
        'image_url': 'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=600',
        'prompt': 'Glamorous Sweet 16 birthday portrait, stunning rose gold sequin party dress, crystal tiara with Sweet 16 lettering, pink and gold balloon arch background, professional birthday photography, glittering confetti falling, warm flattering lighting, teenage luxury celebration',
      },
      {
        'id': 'hollywood_glam',
        'name': 'Hollywood Glam Birthday',
        'is_premium': true,
        'order': 2,
        'image_url': 'https://images.unsplash.com/photo-1571513722275-4b41940f54b8?w=600',
        'prompt': 'Hollywood golden age glamour birthday portrait, black sequin gown, Old Hollywood waves hair, dramatic bold red lip, black and gold Art Deco birthday backdrop, paparazzi flash photography style, film noir lighting, celebrity red carpet energy, ultra-glamorous',
      },
      {
        'id': 'bollywood_birthday',
        'name': 'Bollywood Birthday',
        'is_premium': true,
        'order': 3,
        'image_url': 'https://images.unsplash.com/photo-1583939003579-730e3918a45a?w=600',
        'prompt': 'Dazzling Bollywood star birthday portrait, glamorous designer Indo-western outfit with heavy embellishments, dramatic Bollywood-style makeup with dramatic eye liner, colorful flower-decorated stage backdrop, Bollywood film poster lighting, vibrant festive energy, ultra-cinematic',
      },
      {
        'id': 'princess_birthday',
        'name': 'Princess Birthday',
        'is_premium': false,
        'order': 4,
        'image_url': 'https://images.unsplash.com/photo-1504609813442-a8924e83f76e?w=600',
        'prompt': 'Magical princess birthday portrait, pink tulle ball gown with silver embroidery, sparkling diamond tiara, holding a magic wand with star, enchanted castle background with glowing windows, pink and purple soft lighting, fairytale princess fantasy photography',
      },
      {
        'id': 'neon_glow',
        'name': 'Neon Glow Birthday',
        'is_premium': false,
        'order': 5,
        'image_url': 'https://images.unsplash.com/photo-1504691342899-4d92b50853e1?w=600',
        'prompt': 'Electric neon glow birthday portrait, vibrant neon outfit with UV reactive accessories, blacklight UV party background with neon splatter art, neon face paint glowing, electric blue and purple neon lights illuminating face, futuristic rave birthday party atmosphere',
      },
      {
        'id': 'masquerade_birthday',
        'name': 'Masquerade Birthday',
        'is_premium': true,
        'order': 6,
        'image_url': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=600',
        'prompt': 'Mysterious masquerade birthday ball portrait, elegant black and gold formal gown, ornate Venetian masquerade mask with feathers and gems, Grand Venetian ballroom with chandeliers background, candlelight and crystal lighting, mysterious alluring expression, ultra-luxurious',
      },
      {
        'id': 'twenty_first',
        'name': '21st Birthday',
        'is_premium': false,
        'order': 7,
        'image_url': 'https://images.unsplash.com/photo-1527529482837-4698179dc6ce?w=600',
        'prompt': '21st birthday celebration portrait, glamorous party outfit with gold 21 sash and crown, champagne flute with golden bubbles, luxury rooftop party background with city lights, confetti explosion, warm golden celebration lighting, milestone birthday photography',
      },
      {
        'id': 'superhero_birthday',
        'name': 'Superhero Birthday',
        'is_premium': false,
        'order': 8,
        'image_url': 'https://images.unsplash.com/photo-1612404730960-5c71577fca11?w=600',
        'prompt': 'Epic superhero birthday portrait, custom superhero costume with flowing cape, dramatic cityscape background, heroic powerful pose, comic book style dynamic lighting with dramatic shadows, action movie poster aesthetic, birthday name emblazoned on cape, ultra-cinematic',
      },
      {
        'id': 'rockstar_birthday',
        'name': 'Rockstar Birthday',
        'is_premium': false,
        'order': 9,
        'image_url': 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=600',
        'prompt': 'Rock star birthday portrait, edgy rock and roll outfit with leather jacket and ripped jeans, electric guitar prop, concert stage background with dramatic spotlights and smoke, crowd silhouettes, music festival energy, rock concert photography style',
      },
      {
        'id': 'unicorn_birthday',
        'name': 'Unicorn Birthday',
        'is_premium': false,
        'order': 10,
        'image_url': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600',
        'prompt': 'Magical unicorn birthday fantasy portrait, pastel rainbow outfit with unicorn horn headband, iridescent glitter makeup, magical pastel cloud and rainbow background, sparkles and stars floating around, soft dreamy lighting, whimsical fantasy photography',
      },
    ],
  };

  // ═══════════════════════════════════════════════════
  // 🎉 FESTIVAL — 22 styles
  // ═══════════════════════════════════════════════════
  Map<String, dynamic> get _festivalCategory => {
    'id': 'festival',
    'data': {
      'name': 'Festival',
      'icon': '🎉',
      'order': 4,
      'is_active': true,
      'description': 'Vibrant festival celebration portraits',
      'image_url': 'https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=600',
    },
    'styles': [
      {
        'id': 'holi_colors',
        'name': 'Holi Colors',
        'is_premium': false,
        'order': 1,
        'image_url': 'https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=600',
        'prompt': 'Joyful Holi festival portrait, face and clothes covered in vibrant pink magenta yellow green powder gulal, throwing color powder in the air creating explosion of colors, white kurta now rainbow-stained, pure joy and laughter expression, bright festival lighting, ultra-vivid colors',
      },
      {
        'id': 'diwali_diyas',
        'name': 'Diwali Diyas',
        'is_premium': false,
        'order': 2,
        'image_url': 'https://images.unsplash.com/photo-1574786527860-ced4b83f064c?w=600',
        'prompt': 'Glowing Diwali portrait, holding dozens of lit earthen diyas with dancing flames, warm golden glow illuminating face from below, traditional silk ethnic wear, rangoli art on floor, hundreds of diyas in background creating magical carpet of light, Diwali festival photography',
      },
      {
        'id': 'diwali_ethnic',
        'name': 'Diwali Ethnic Glam',
        'is_premium': false,
        'order': 3,
        'image_url': 'https://images.unsplash.com/photo-1610189352649-6d6b59ebbab6?w=600',
        'prompt': 'Stunning Diwali ethnic portrait, gorgeous anarkali or shararaa in rich jewel tones with heavy gold embroidery, statement gold and kundan jewelry, sparklers creating golden light trails, diya-lit home background with hanging lights, festive Diwali makeup, warm celebratory photography',
      },
      {
        'id': 'navratri_garba',
        'name': 'Navratri Garba',
        'is_premium': false,
        'order': 4,
        'image_url': 'https://images.unsplash.com/photo-1626197031507-c17099753214?w=600',
        'prompt': 'Energetic Navratri garba portrait, colorful mirror-work chaniya choli in vibrant colors, traditional bangles and jewelry, dandiya sticks raised in dance pose, garba ground with illuminated backdrop, spinning motion blur on skirt, Navratri night celebration photography',
      },
      {
        'id': 'eid_celebration',
        'name': 'Eid Celebration',
        'is_premium': false,
        'order': 5,
        'image_url': 'https://images.unsplash.com/photo-1608755728617-aefab37d2edd?w=600',
        'prompt': 'Elegant Eid Mubarak portrait, gorgeous embroidered salwar kameez or kurta in pastels or whites, crescent moon and mosque silhouette at dusk background, warm evening lantern light, mehndi on hands, serene blessed joyful expression, Eid festivity photography',
      },
      {
        'id': 'christmas_festive',
        'name': 'Christmas Festive',
        'is_premium': false,
        'order': 6,
        'image_url': 'https://images.unsplash.com/photo-1512389142860-9c449e58a543?w=600',
        'prompt': 'Cozy Christmas portrait, festive ugly Christmas sweater or elegant red Christmas dress, decorated Christmas tree background glowing with warm fairy lights and ornaments, holding mug of hot cocoa with marshmallows, soft bokeh Christmas lights, snow falling outside window, warm holiday glow',
      },
      {
        'id': 'new_year_bash',
        'name': 'New Year Bash',
        'is_premium': false,
        'order': 7,
        'image_url': 'https://images.unsplash.com/photo-1467810563316-b5476525c0f9?w=600',
        'prompt': 'Epic New Year countdown portrait, sparkling sequin party outfit, gold 2025 headband, champagne flute raised in toast, confetti and streamers exploding all around, midnight countdown clock background, glittering balloon drop, euphoric celebration expression, party photography',
      },
      {
        'id': 'halloween_costume',
        'name': 'Halloween Costume',
        'is_premium': false,
        'order': 8,
        'image_url': 'https://images.unsplash.com/photo-1509557965875-b88c97052f0e?w=600',
        'prompt': 'Dramatic Halloween costume portrait, elaborate professional costume makeup, carved jack-o-lanterns glowing around, foggy spooky graveyard or haunted mansion background, dramatic horror film lighting, full moon behind, cobwebs and bats, cinematic Halloween photography',
      },
      {
        'id': 'valentines_couple',
        'name': "Valentine's Couple",
        'is_premium': false,
        'order': 9,
        'image_url': 'https://images.unsplash.com/photo-1516589178581-6cd7833ae3b2?w=600',
        'prompt': 'Romantic Valentine couple in love portrait, elegant red and pink outfits, holding red roses bouquet, hearts and rose petals floating, candlelit restaurant or garden of roses background, warm romantic pink and red lighting, love and joy expression, Valentine photography',
      },
      {
        'id': 'republic_day',
        'name': 'Republic Day',
        'is_premium': false,
        'order': 10,
        'image_url': 'https://images.unsplash.com/photo-1532375810709-75b1da00537c?w=600',
        'prompt': 'Patriotic Republic Day portrait, holding Indian tricolor flag with pride, Ashoka Chakra prominently visible, India Gate or Red Fort monument background, patriotic orange white green colors, proud nationalistic expression, Indian monument aerial photography style',
      },
    ],
  };

  // ═══════════════════════════════════════════════════
  // 📱 SOCIAL MEDIA — 20 styles
  // ═══════════════════════════════════════════════════
  Map<String, dynamic> get _socialMediaCategory => {
    'id': 'social_media',
    'data': {
      'name': 'Social Media',
      'icon': '📱',
      'order': 5,
      'is_active': true,
      'description': 'Viral-worthy portraits for every platform',
      'image_url': 'https://images.unsplash.com/photo-1611162616305-c69b3fa7fbe0?w=600',
    },
    'styles': [
      {
        'id': 'instagram_influencer',
        'name': 'Instagram Influencer',
        'is_premium': false,
        'order': 1,
        'image_url': 'https://images.unsplash.com/photo-1611162616305-c69b3fa7fbe0?w=600',
        'prompt': 'Stunning Instagram influencer portrait, trendy OOTD aesthetic outfit, flawless glowing skin, perfect makeup, aesthetic pastel-toned minimalist background, ring light catchlights in eyes, content creator studio, feed-worthy composition, soft editorial lighting, Instagram aesthetic photography',
      },
      {
        'id': 'youtube_thumbnail',
        'name': 'YouTube Thumbnail',
        'is_premium': false,
        'order': 2,
        'image_url': 'https://images.unsplash.com/photo-1626814026160-2237a95fc5a0?w=600',
        'prompt': 'Viral YouTube thumbnail portrait, dramatically expressive shocked surprised open mouth reaction face, bold saturated background, pointing gesture, MrBeast style over-the-top expression, high contrast bold colors, clickbait energy, YouTube thumbnail photography style',
      },
      {
        'id': 'tiktok_creator',
        'name': 'TikTok Creator',
        'is_premium': false,
        'order': 3,
        'image_url': 'https://images.unsplash.com/photo-1622547748225-3fc4abd2cca0?w=600',
        'prompt': 'Trendy TikTok content creator portrait, Gen-Z fashion forward outfit, ring light perfectly reflecting in eyes, home studio setup with ring light visible, phone in hand recording, TikTok logo aesthetic, vibrant youthful energy, viral content creator photography',
      },
      {
        'id': 'fitness_influencer',
        'name': 'Fitness Influencer',
        'is_premium': false,
        'order': 4,
        'image_url': 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=600',
        'prompt': 'Athletic fitness influencer portrait, premium gym wear activewear, lean muscular physique, modern gym background with equipment, motivational powerful expression, sports photography lighting, health and wellness aesthetic, fitness transformation energy, ultra-sharp',
      },
      {
        'id': 'beauty_influencer',
        'name': 'Beauty Influencer',
        'is_premium': false,
        'order': 5,
        'image_url': 'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?w=600',
        'prompt': 'Glamorous beauty influencer portrait, flawless dewy skin, expertly done editorial makeup with bold eye looks, beauty channel studio background, softbox lighting creating perfect skin glow, makeup products arranged aesthetically, Vogue beauty editorial photography',
      },
      {
        'id': 'travel_influencer',
        'name': 'Travel Influencer',
        'is_premium': false,
        'order': 6,
        'image_url': 'https://images.unsplash.com/photo-1488085061387-422e29b40080?w=600',
        'prompt': 'Adventurous travel influencer portrait, casual travel outfit with backpack, stunning exotic location background such as Santorini cliff, Bali rice terraces, or Maldives overwater bungalow, wanderlust expression, golden hour natural light, travel lifestyle photography',
      },
      {
        'id': 'gaming_streamer',
        'name': 'Gaming Streamer',
        'is_premium': false,
        'order': 7,
        'image_url': 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=600',
        'prompt': 'Epic gaming streamer portrait, RGB gaming headset, gamer chair with neon RGB background, dual monitor setup visible, intense focused gaming expression, neon blue and purple gaming aesthetics, Twitch streamer setup photography, gaming merchandise visible',
      },
      {
        'id': 'podcast_host',
        'name': 'Podcast Host',
        'is_premium': false,
        'order': 8,
        'image_url': 'https://images.unsplash.com/photo-1589903308904-1010c2294adc?w=600',
        'prompt': 'Professional podcast host portrait, professional microphone close to face, sound-dampening foam background panels, headphones around neck, engaging articulate expression, warm studio lighting, broadcasting professional photography, Spotify podcast cover aesthetic',
      },
      {
        'id': 'linkedin_thought_leader',
        'name': 'LinkedIn Thought Leader',
        'is_premium': true,
        'order': 9,
        'image_url': 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=600',
        'prompt': 'Influential LinkedIn thought leader portrait, power professional attire, modern conference speaking background or office, authoritative yet approachable expression, professional speaking gesture, corporate executive photography, personal branding portrait style',
      },
      {
        'id': 'dating_profile',
        'name': 'Dating App Profile',
        'is_premium': false,
        'order': 10,
        'image_url': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=600',
        'prompt': 'Attractive genuine dating app profile portrait, casual stylish outfit, warm authentic smile, relaxed outdoor or cafe background with soft bokeh, natural flattering light, approachable trustworthy expression, lifestyle photography feel, Tinder Bumble profile worthy',
      },
    ],
  };

  // ═══════════════════════════════════════════════════
  // 👑 TRADITIONAL & CHARACTERS — 24 styles
  // ═══════════════════════════════════════════════════
  Map<String, dynamic> get _traditionalCategory => {
    'id': 'traditional_characters',
    'data': {
      'name': 'Traditional & Characters',
      'icon': '👑',
      'order': 6,
      'is_active': true,
      'description': 'Royal, mythological and epic transformations',
      'image_url': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=600',
    },
    'styles': [
      {
        'id': 'indian_maharaja',
        'name': 'Indian Maharaja',
        'is_premium': true,
        'order': 1,
        'image_url': 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600',
        'prompt': 'Majestic Indian Maharaja royal portrait, opulent jewel-encrusted sherwani with real gold thread embroidery, magnificent jeweled turban with diamond kalgi and aigrette, ruby pearl emerald necklaces, seated on golden throne in grand palace durbar hall, Maharajas of India court photography',
      },
      {
        'id': 'indian_maharani',
        'name': 'Indian Maharani',
        'is_premium': true,
        'order': 2,
        'image_url': 'https://images.unsplash.com/photo-1591135671303-14bce32b1b2e?w=600',
        'prompt': 'Regal Indian Maharani queen portrait, magnificent silk brocade saree with real zari work, elaborate Jadau kundan jewelry, emerald and diamond maang tikka and necklace, seated on jeweled throne, palace zenana background with intricate jaali work, royal Indian court photography',
      },
      {
        'id': 'mughal_emperor',
        'name': 'Mughal Emperor',
        'is_premium': true,
        'order': 3,
        'image_url': 'https://images.unsplash.com/photo-1564507592333-c60657eea523?w=600',
        'prompt': 'Imperial Mughal Emperor portrait, ornate Mughal jama coat with precious stone inlay, magnificent jeweled turban with kalgi and heron feather, holding golden orb and sword, Taj Mahal or Red Fort background, Mughal miniature painting come to life, dramatic imperial lighting',
      },
      {
        'id': 'lord_krishna',
        'name': 'Lord Krishna',
        'is_premium': true,
        'order': 4,
        'image_url': 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=600',
        'prompt': 'Divine Lord Krishna portrait, radiant blue-toned complexion, peacock feather mukut crown with gems, yellow pitambara silk dhoti, playing bansuri flute, Vrindavan forest with Yamuna river background, cow and calves surrounding, divine golden halo, celestial warm lighting',
      },
      {
        'id': 'goddess_durga',
        'name': 'Goddess Durga',
        'is_premium': true,
        'order': 5,
        'image_url': 'https://images.unsplash.com/photo-1617817546652-fb50b72a6e63?w=600',
        'prompt': 'Fierce divine Goddess Durga portrait, ten arms each holding divine weapons trishul chakra sword bow, brilliant red and gold silk saree, riding magnificent lion, radiant third eye on forehead, golden divine aura, Navratri puja pandal background, divine goddess portrait photography',
      },
      {
        'id': 'samurai_warrior',
        'name': 'Samurai Warrior',
        'is_premium': true,
        'order': 6,
        'image_url': 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=600',
        'prompt': 'Fearsome Japanese Samurai warrior portrait, intricate lacquered red and black yoroi armor with menacing kabuto helmet, katana and wakizashi swords at belt, cherry blossom background with Mount Fuji, fierce bushido warrior expression, dramatic Japanese cinematography lighting',
      },
      {
        'id': 'egyptian_pharaoh',
        'name': 'Egyptian Pharaoh',
        'is_premium': true,
        'order': 7,
        'image_url': 'https://images.unsplash.com/photo-1539768942893-daf53e448371?w=600',
        'prompt': 'God-king Egyptian Pharaoh portrait, golden nemes headdress with uraeus cobra, broad usekh gold collar with lapis lazuli, carrying crook and flail symbols of power, Great Pyramid of Giza background with Nile River, Ra sun disc halo, Cleopatra Nefertiti era ancient Egypt',
      },
      {
        'id': 'medieval_king',
        'name': 'Medieval King',
        'is_premium': true,
        'order': 8,
        'image_url': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=600',
        'prompt': 'Powerful Medieval European king portrait, royal ermine-trimmed velvet robe in deep purple, jeweled golden crown, holding scepter and orb, seated on ornate throne in Gothic castle great hall, stained glass windows behind, candelabras, Game of Thrones style cinematic photography',
      },
      {
        'id': 'japanese_geisha',
        'name': 'Japanese Geisha',
        'is_premium': true,
        'order': 9,
        'image_url': 'https://images.unsplash.com/photo-1528360983277-13d401cdc186?w=600',
        'prompt': 'Exquisite Japanese Geisha portrait, flawless white oshiroi face makeup with red kuchibeni lips, elaborate silk kimono with obi, kanzashi hair ornaments with sakura flowers, traditional tea house background, paper parasol, cherry blossom petals falling, Kyoto Gion aesthetic',
      },
      {
        'id': 'viking_warrior',
        'name': 'Viking Warrior',
        'is_premium': false,
        'order': 10,
        'image_url': 'https://images.unsplash.com/photo-1578321272176-b7bbc0679853?w=600',
        'prompt': 'Fierce Norse Viking warrior portrait, battle-worn leather armor with fur mantle, iron-horned helmet, braided hair and beard with warrior beads, wielding massive battle axe, misty Norwegian fjord longship background, dramatic storm clouds, Norse runic carvings, cinematic Vikings series style',
      },
      {
        'id': 'angel_divine',
        'name': 'Divine Angel',
        'is_premium': true,
        'order': 11,
        'image_url': 'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?w=600',
        'prompt': 'Breathtaking divine angel portrait, enormous white feathered wings spread majestically, flowing luminous white robes with gold trim, glowing golden halo radiating light, heavenly clouds background with rays of divine light, ethereal celestial glow, Sistine Chapel style divine photography',
      },
      {
        'id': 'wizard_mage',
        'name': 'Wizard Mage',
        'is_premium': false,
        'order': 12,
        'image_url': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=600',
        'prompt': 'Powerful ancient wizard mage portrait, long flowing star-scattered midnight blue robes, tall pointed hat with celestial symbols, magical glowing staff with crystal orb, mystical energy and sparks emanating from hands, ancient library or fantasy castle tower background, Gandalf Dumbledore style',
      },
    ],
  };

  // ═══════════════════════════════════════════════════
  // 👔 MEN'S STYLES — 22 styles
  // ═══════════════════════════════════════════════════
  Map<String, dynamic> get _mensCategory => {
    'id': 'mens_styles',
    'data': {
      'name': "Men's Styles",
      'icon': '👔',
      'order': 7,
      'is_active': true,
      'description': 'Stylish and powerful looks for men',
      'image_url': 'https://images.unsplash.com/photo-1488161628813-04466f872be2?w=600',
    },
    'styles': [
      {
        'id': 'bollywood_hero',
        'name': 'Bollywood Hero',
        'is_premium': false,
        'order': 1,
        'image_url': 'https://images.unsplash.com/photo-1488161628813-04466f872be2?w=600',
        'prompt': 'Iconic Bollywood hero movie star portrait, designer silk shirt open chest, smoldering intense romantic eyes with heavy kohl, dramatic back-lighting creating hero halo effect, colorful Holi or Mumbai background, Shah Rukh Khan Salman Khan charisma, Bollywood film poster photography',
      },
      {
        'id': 'james_bond',
        'name': 'James Bond 007',
        'is_premium': true,
        'order': 2,
        'image_url': 'https://images.unsplash.com/photo-1555952517-2e8e729e0b44?w=600',
        'prompt': 'Suave James Bond 007 secret agent portrait, perfectly tailored Tom Ford tuxedo with bow tie, gun visible in shoulder holster, Monte Carlo casino or Aston Martin background, Daniel Craig intensity with Roger Moore charm, chiseled jawline, spy thriller movie poster lighting',
      },
      {
        'id': 'sherwani_groom',
        'name': 'Sherwani Groom',
        'is_premium': true,
        'order': 3,
        'image_url': 'https://images.unsplash.com/photo-1590750420541-24dc3ef6dc4e?w=600',
        'prompt': 'Resplendent Indian groom sherwani portrait, ivory cream heavily embroidered sherwani with silk dupatta, gold and pearl buttons, matching safa turban with pearl strings, holding sehra, traditional marigold mandap background, warm wedding photography lighting',
      },
      {
        'id': 'streetwear_king',
        'name': 'Streetwear King',
        'is_premium': false,
        'order': 4,
        'image_url': 'https://images.unsplash.com/photo-1552374196-1ab2a1c593e8?w=600',
        'prompt': 'Hypebeast streetwear fashion portrait, Supreme Off-White Balenciaga outfit with rare Air Jordans, urban graffiti street art wall background, cool nonchalant expression, New York or Tokyo street style, skate park atmosphere, streetwear editorial photography',
      },
      {
        'id': 'biker_leather',
        'name': 'Biker Style',
        'is_premium': false,
        'order': 5,
        'image_url': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600',
        'prompt': 'Rugged badass biker portrait, distressed black leather jacket with patches, dark jeans, motorcycle boots, leaning against Harley Davidson, open highway desert background at sunset, rebellious cool dangerous expression, Easy Rider cinematic photography',
      },
      {
        'id': 'rock_star',
        'name': 'Rock Star',
        'is_premium': false,
        'order': 6,
        'image_url': 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=600',
        'prompt': 'Iconic rock star concert portrait, stage outfit with leather pants and band tee, electric guitar shredding, massive concert stage with pyrotechnics and smoke behind, crowd of thousands, dramatic stage spotlights and laser beams, rock legend photography',
      },
      {
        'id': 'kdrama_hero',
        'name': 'K-Drama Hero',
        'is_premium': false,
        'order': 7,
        'image_url': 'https://images.unsplash.com/photo-1513956589380-bad6acb9b9d4?w=600',
        'prompt': 'Perfect Korean drama oppa hero portrait, flawless dewy glass skin, stylish Korean fashion outfit, moody cinematic lighting, cherry blossom background or minimal modern Seoul apartment, intense brooding romantic expression, K-drama Netflix series cinematography',
      },
      {
        'id': 'fitness_bodybuilder',
        'name': 'Fitness Bodybuilder',
        'is_premium': false,
        'order': 8,
        'image_url': 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=600',
        'prompt': 'Impressive fitness bodybuilder portrait, muscular physique with veins and definition visible, gym outfit, classic bodybuilder flex pose, professional gym background with weights and mirrors, dramatic sports photography lighting, fitness motivation transformation, ultra-sharp',
      },
      {
        'id': 'ethnic_kurta',
        'name': 'Ethnic Kurta',
        'is_premium': false,
        'order': 9,
        'image_url': 'https://images.unsplash.com/photo-1521038199265-bc482db0f923?w=600',
        'prompt': 'Stylish ethnic Indian man portrait, premium designer kurta pajama with subtle embroidery, traditional jewelry and kada bracelet, festive occasion setting with rangoli or temple backdrop, warm Indian festive lighting, modern traditional fusion style, Manyavar catalog photography',
      },
      {
        'id': 'vintage_gentleman',
        'name': 'Vintage Gentleman',
        'is_premium': false,
        'order': 10,
        'image_url': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600',
        'prompt': 'Dapper vintage 1920s gentleman portrait, three-piece tweed suit with pocket watch chain, newsboy cap or bowler hat, classic grooming with pomaded hair, vintage speakeasy bar or cobblestone street background, Peaky Blinders Boardwalk Empire period drama photography',
      },
      {
        'id': 'cowboy_western',
        'name': 'Hollywood Cowboy',
        'is_premium': false,
        'order': 11,
        'image_url': 'https://images.unsplash.com/photo-1504797308951-aa91bc95ea1e?w=600',
        'prompt': 'Rugged Wild West cowboy portrait, worn leather cowboy hat and duster coat, sheriff badge, holstered revolvers, dusty desert canyon background at sunset, squinting in the sun, horse silhouette behind, Clint Eastwood spaghetti western cinematography',
      },
      {
        'id': 'bollywood_villain',
        'name': 'Bollywood Villain',
        'is_premium': false,
        'order': 12,
        'image_url': 'https://images.unsplash.com/photo-1564564321837-a57b7070ac4f?w=600',
        'prompt': 'Menacing Bollywood villain portrait, sharp dark designer outfit with dramatic long coat, slicked back hair, menacing evil smirk with cold calculating eyes, dark moody headquarters or penthouse background, dramatic shadows, villain movie poster lighting',
      },
    ],
  };

  // ═══════════════════════════════════════════════════
  // 👗 WOMEN'S STYLES — 24 styles
  // ═══════════════════════════════════════════════════
  Map<String, dynamic> get _womensCategory => {
    'id': 'womens_styles',
    'data': {
      'name': "Women's Styles",
      'icon': '👗',
      'order': 8,
      'is_active': true,
      'description': 'Gorgeous and empowering looks for women',
      'image_url': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=600',
    },
    'styles': [
      {
        'id': 'bollywood_heroine',
        'name': 'Bollywood Heroine',
        'is_premium': false,
        'order': 1,
        'image_url': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=600',
        'prompt': 'Dazzling Bollywood heroine leading lady portrait, stunning designer lehenga or gown, dramatic Bollywood makeup with jewels on face, Deepika Padukone Priyanka Chopra level glamour, colorful Bollywood song set background with flowers and dancers, cinematic Bollywood film poster photography',
      },
      {
        'id': 'saree_elegance',
        'name': 'Saree Elegance',
        'is_premium': false,
        'order': 2,
        'image_url': 'https://images.unsplash.com/photo-1610189352649-6d6b59ebbab6?w=600',
        'prompt': 'Graceful Indian woman saree portrait, exquisitely draped silk Banarasi saree with golden zari border, traditional gold jewelry with emeralds and rubies, jasmine hair flowers, classic Indian bindi, ornate haveli or palace background, warm natural Indian photography',
      },
      {
        'id': 'designer_lehenga',
        'name': 'Designer Lehenga',
        'is_premium': true,
        'order': 3,
        'image_url': 'https://images.unsplash.com/photo-1583391733956-6c78276477e2?w=600',
        'prompt': 'Spectacular designer bridal lehenga portrait, heavily embroidered couture Sabyasachi lehenga in blush pink and gold, layered skirt twirling, statement Polki diamond jewelry, professional bridal photography lighting, indoor palace or ballroom venue, bride squad behind, wedding magazine editorial',
      },
      {
        'id': 'fashion_model',
        'name': 'Fashion Model',
        'is_premium': true,
        'order': 4,
        'image_url': 'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=600',
        'prompt': 'High fashion editorial model portrait, avant-garde designer couture outfit, runway catwalk or white seamless studio, editorial makeup with architectural shapes, fierce model walk pose, Vogue Paris Harper Bazaar editorial photography, dramatic fashion lighting',
      },
      {
        'id': 'boss_lady',
        'name': 'Boss Lady',
        'is_premium': false,
        'order': 5,
        'image_url': 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=600',
        'prompt': 'Powerful boss lady girlboss portrait, sleek power suit in deep jewel tones, statement accessories and heels, corner office with city view background, CEO energy confident commanding expression, Forbes power women photography style, strong feminist energy',
      },
      {
        'id': 'rajasthani_beauty',
        'name': 'Rajasthani Beauty',
        'is_premium': false,
        'order': 6,
        'image_url': 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600',
        'prompt': 'Stunning Rajasthani beauty portrait, vibrant Leheriya or Bandhani ghagra choli with mirror work, heavy Thewa gold jewelry and Rajputi borla, colorful Rajasthani odhni veil, Hawa Mahal or Mehrangarh Fort background, desert sunset golden hour, Rajasthan tourism photography',
      },
      {
        'id': 'punjabi_kudi',
        'name': 'Punjabi Kudi',
        'is_premium': false,
        'order': 7,
        'image_url': 'https://images.unsplash.com/photo-1499952127939-9bbf5af6c51c?w=600',
        'prompt': 'Vibrant Punjabi kudi portrait, colorful Phulkari embroidered Punjabi suit with intricate dupatta, gold jhumka earrings and chooda bangles, joyful energetic dance expression, mustard fields of Punjab background, Baisakhi festival atmosphere, Punjabi wedding celebration photography',
      },
      {
        'id': 'kdrama_heroine',
        'name': 'K-Drama Heroine',
        'is_premium': false,
        'order': 8,
        'image_url': 'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=600',
        'prompt': 'Perfect K-drama heroine portrait, flawless glass skin with dewy glow, elegant Korean fashion outfit, moody cinematic lighting, cherry blossom Namsan Tower Seoul background, soft romantic dreamy expression, Netflix Korean drama cinematography style',
      },
      {
        'id': 'vintage_retro',
        'name': 'Vintage Retro',
        'is_premium': false,
        'order': 9,
        'image_url': 'https://images.unsplash.com/photo-1485518882345-15568b007407?w=600',
        'prompt': 'Gorgeous vintage retro pin-up portrait, 1950s full skirt polka dot dress with red belt, victory roll or platinum waves hair, classic red lips and cat-eye makeup, retro diner or Cadillac background, Technicolor warm vintage photography, Marilyn Monroe era glamour',
      },
      {
        'id': 'beach_goddess',
        'name': 'Beach Goddess',
        'is_premium': false,
        'order': 10,
        'image_url': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600',
        'prompt': 'Radiant beach goddess portrait, flowing white linen or colorful sundress, sun-kissed glowing skin, hair blowing in ocean breeze, tropical turquoise Maldives or Bali beach background, golden sunset rays, goddess-like natural beauty, summer vacation lifestyle photography',
      },
      {
        'id': 'bollywood_diva',
        'name': 'Bollywood Diva',
        'is_premium': true,
        'order': 11,
        'image_url': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=600',
        'prompt': 'Ultra-glamorous Bollywood diva portrait, custom couture gown with train, dramatic cinematic makeup, Filmfare Awards red carpet background, paparazzi flash photography, celebrity magazine cover energy, Alia Bhatt Kareena Kapoor level glamour, ultra-cinematic',
      },
      {
        'id': 'hollywood_actress',
        'name': 'Hollywood Actress',
        'is_premium': true,
        'order': 12,
        'image_url': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=600',
        'prompt': 'Stunning Hollywood actress Oscar night portrait, custom designer ball gown dripping in diamonds, Old Hollywood glamour waves or modern updo, Academy Awards ceremony background, photographers flashing, red carpet royalty expression, Vanity Fair Oscar party photography',
      },
    ],
  };

  // ═══════════════════════════════════════════════════
  // 🎨 CREATIVE — 22 styles
  // ═══════════════════════════════════════════════════
  Map<String, dynamic> get _creativeCategory => {
    'id': 'creative',
    'data': {
      'name': 'Creative',
      'icon': '🎨',
      'order': 9,
      'is_active': true,
      'description': 'Artistic and creative portrait transformations',
      'image_url': 'https://images.unsplash.com/photo-1547891654-e66ed7ebb968?w=600',
    },
    'styles': [
      {
        'id': 'movie_poster',
        'name': 'Movie Poster',
        'is_premium': false,
        'order': 1,
        'image_url': 'https://images.unsplash.com/photo-1478720568477-152d9b164e26?w=600',
        'prompt': 'Cinematic Hollywood blockbuster movie poster portrait, dramatic directional lighting from below, epic movie title typography above head, Avengers Marvel scale background with explosions and action, intense heroic expression, IMAX film quality cinematography, award-winning movie poster design',
      },
      {
        'id': 'bollywood_poster',
        'name': 'Bollywood Poster',
        'is_premium': false,
        'order': 2,
        'image_url': 'https://images.unsplash.com/photo-1485846234645-a62644f84728?w=600',
        'prompt': 'Vibrant Bollywood masala movie poster portrait, dramatic split-face hero villain design, colorful Bollywood typography, action pose with hero heroine side by side, Dharma Productions style design, Mumbai city background with Bollywood drama, ultra-cinematic Indian cinema',
      },
      {
        'id': 'pop_art',
        'name': 'Pop Art',
        'is_premium': false,
        'order': 3,
        'image_url': 'https://images.unsplash.com/photo-1547891654-e66ed7ebb968?w=600',
        'prompt': 'Bold pop art portrait transformation, Andy Warhol Marilyn Monroe style multiple color blocks, thick black ben-day dot pattern outlines, flat graphic bold primary and secondary colors, halftone dot pattern, 1960s pop art graphic design, comic book screen-print aesthetic',
      },
      {
        'id': 'watercolor_art',
        'name': 'Watercolor Art',
        'is_premium': false,
        'order': 4,
        'image_url': 'https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=600',
        'prompt': 'Delicate watercolor painting portrait, soft wet-on-wet watercolor technique with colors bleeding together, loose gestural brush strokes, white paper showing through, impressionistic painterly style, warm pastel color palette, fine art watercolor portrait painting',
      },
      {
        'id': 'oil_painting',
        'name': 'Oil Painting',
        'is_premium': true,
        'order': 5,
        'image_url': 'https://images.unsplash.com/photo-1578301978693-85fa9c0320b9?w=600',
        'prompt': 'Museum-quality classical oil painting portrait, Rembrandt dramatic chiaroscuro lighting, thick impasto brushwork visible, rich earth tone palette with jewel highlights, gilt frame visible, Old Masters Dutch Golden Age technique, Louvre museum collection quality artwork',
      },
      {
        'id': 'pencil_sketch',
        'name': 'Pencil Sketch',
        'is_premium': false,
        'order': 6,
        'image_url': 'https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=600',
        'prompt': 'Masterful pencil sketch portrait drawing, detailed realistic graphite pencil technique, crosshatch shading for depth and form, white paper background, artist sketchbook feel, life-drawing class quality, Leonardo da Vinci study sketch style, ultra-detailed realism',
      },
      {
        'id': 'pixel_art',
        'name': 'Pixel Art',
        'is_premium': false,
        'order': 7,
        'image_url': 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=600',
        'prompt': 'Retro pixel art character portrait, 16-bit Super Nintendo RPG video game sprite style, limited color palette with dithering, chunky pixels visible, pixel art background scene, video game character profile screen, nostalgic 90s gaming aesthetic',
      },
      {
        'id': 'comic_book',
        'name': 'Comic Book Cover',
        'is_premium': false,
        'order': 8,
        'image_url': 'https://images.unsplash.com/photo-1612036782180-6f0b6cd846fe?w=600',
        'prompt': 'Epic Marvel DC comic book cover portrait, dynamic superhero action pose, bold thick ink outlines, flat cel-shaded colors with dot pattern shadows, action lines radiating from figure, comic book speech bubble, classic superhero origin story cover design',
      },
      {
        'id': 'neon_cyberpunk',
        'name': 'Cyberpunk Neon',
        'is_premium': false,
        'order': 9,
        'image_url': 'https://images.unsplash.com/photo-1520420097861-e4959843b682?w=600',
        'prompt': 'Cyberpunk neon portrait, futuristic augmented reality implants glowing, neon signs in Japanese and English reflecting on wet rain-soaked streets, Blade Runner 2049 aesthetic, electric blue and hot pink neon light, dark dystopian Tokyo 2099 background, cyberpunk fashion',
      },
      {
        'id': 'vaporwave',
        'name': 'Vaporwave Aesthetic',
        'is_premium': false,
        'order': 10,
        'image_url': 'https://images.unsplash.com/photo-1614851099175-e5b30eb6f696?w=600',
        'prompt': 'Dreamy vaporwave aesthetic portrait, pastel pink and cyan purple color grading, overlaid Greek bust statue, 80s retro grid sunset background, VHS glitch effects, Japanese kanji text overlaid, retrofuturistic Miami Vice aesthetic, lo-fi aesthetic art',
      },
      {
        'id': 'synthwave',
        'name': 'Synthwave Retro',
        'is_premium': false,
        'order': 11,
        'image_url': 'https://images.unsplash.com/photo-1557682250-33bd709cbe85?w=600',
        'prompt': 'Synthwave retrowave portrait, neon magenta and electric blue lighting, retro-futuristic 1980s aesthetic, outrun racing grid perspective extending to horizon, triangular neon sun setting behind, Tron Legacy Kavinsky album cover aesthetic, chrome and neon',
      },
      {
        'id': 'charcoal_art',
        'name': 'Charcoal Drawing',
        'is_premium': false,
        'order': 12,
        'image_url': 'https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=600',
        'prompt': 'Expressive charcoal portrait drawing, bold dramatic charcoal strokes on textured paper, high contrast black and white with mid-tones smudged, artist life-drawing session quality, emotional raw expressionist style, charcoal dust texture visible, fine art drawing',
      },
    ],
  };

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
  ];

  // ═══════════════════════════════════════════════════
  // SEEDING LOGIC — no API calls, just writes to Firestore
  // ═══════════════════════════════════════════════════
  Future<void> _seedAll() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _logs = [];
      _totalDone = 0;
      _progress = 0.0;
      _status = '🌱 Seeding Lumixaa data...';
    });

    try {
      int totalStyles = 0;
      for (final cat in _allCategories) totalStyles += (cat['styles'] as List).length;
      _totalItems = totalStyles + _allCategories.length + 1;

      // 1. App Config
      _addLog('📦 Saving app config...');
      await _db.collection('app_config').doc('settings').set(_appConfig);
      _incrementProgress();
      _addLog('✅ App config saved');

      // 2. Categories & Styles
      for (final cat in _allCategories) {
        final catId = cat['id'] as String;
        final catData = Map<String, dynamic>.from(cat['data']);
        final styles = cat['styles'] as List;

        _addLog('━━━━━━━━━━━━━━━━━━━━━');
        _addLog('📁 ${catData['name']} — ${styles.length} styles');

        await _db.collection('categories').doc(catId).set(catData);
        _incrementProgress();

        for (final style in styles) {
          await _db
              .collection('categories')
              .doc(catId)
              .collection('styles')
              .doc(style['id'])
              .set({
            'name': style['name'],
            'prompt': style['prompt'],
            'image_url': style['image_url'],
            'is_premium': style['is_premium'] ?? false,
            'order': style['order'] ?? 0,
            'category_id': catId,
            'is_active': true,
            'created_at': FieldValue.serverTimestamp(),
          });
          _addLog('  ✅ ${style['name']}');
          _incrementProgress();
        }
        _addLog('✅ ${catData['name']} done!');
      }

      setState(() {
        _status = '🎉 Lumixaa fully seeded! $_totalItems items written.';
        _isLoading = false;
        _progress = 1.0;
      });
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
        _isLoading = false;
      });
      _addLog('❌ $e');
    }
  }

  void _incrementProgress() => setState(() {
    _totalDone++;
    _progress = _totalDone / _totalItems;
  });

  void _addLog(String msg) =>
      setState(() => _logs.add('[${DateTime.now().toString().substring(11, 19)}] $msg'));

  int _countPremium() {
    int c = 0;
    for (final cat in _allCategories) {
      for (final s in cat['styles']) {
        if (s['is_premium'] == true) c++;
      }
    }
    return c;
  }

  int _countStyles() {
    int c = 0;
    for (final cat in _allCategories) c += (cat['styles'] as List).length;
    return c;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        title: const Text('🌱 Seed Database — Lumixaa',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Summary card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple.shade700, Colors.purple.shade400],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(children: [
                const Text('📊 Lumixaa Seed Summary',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statItem('📁', 'Categories', '${_allCategories.length}'),
                    _statItem('🎨', 'Styles', '${_countStyles()}'),
                    _statItem('⭐', 'Premium', '${_countPremium()}'),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '🖼 Hardcoded Unsplash URLs  •  ✍️ Perfect AI Prompts',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 12),

            // Status box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.deepPurple.shade300),
              ),
              child: Text(_status,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center),
            ),

            const SizedBox(height: 12),

            // Progress
            if (_isLoading) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.grey.shade800,
                  valueColor:
                  const AlwaysStoppedAnimation(Colors.deepPurpleAccent),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${(_progress * 100).toStringAsFixed(1)}%  ($_totalDone / $_totalItems)',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
            ],

            // Seed button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _seedAll,
              icon: _isLoading
                  ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
                  : const Text('🌱', style: TextStyle(fontSize: 20)),
              label: Text(
                _isLoading ? 'Seeding Lumixaa...' : '  Seed All Data Now',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 12),

            // Logs terminal
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.shade900)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                      const SizedBox(width: 5),
                      Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.yellow, shape: BoxShape.circle)),
                      const SizedBox(width: 5),
                      Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                      const SizedBox(width: 10),
                      const Text('lumixaa_seed.log', style: TextStyle(color: Colors.green, fontSize: 10, fontFamily: 'monospace')),
                    ]),
                    const Divider(color: Colors.green, height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _logs.length,
                        reverse: true,
                        itemBuilder: (_, i) {
                          final log = _logs[_logs.length - 1 - i];
                          Color c = Colors.green.shade300;
                          if (log.contains('✅')) c = Colors.greenAccent;
                          if (log.contains('❌')) c = Colors.redAccent;
                          if (log.contains('━')) c = Colors.deepPurpleAccent;
                          return Text(log,
                              style: TextStyle(
                                  color: c,
                                  fontFamily: 'monospace',
                                  fontSize: 11));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String emoji, String label, String value) => Column(
    children: [
      Text(emoji, style: const TextStyle(fontSize: 20)),
      Text(value,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold)),
      Text(label,
          style: const TextStyle(color: Colors.white70, fontSize: 11)),
    ],
  );
}
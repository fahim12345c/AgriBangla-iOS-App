import Foundation

struct LocalizedStrings {
    private static let strings: [String: [String: String]] = [
        // App
        "app_name": ["en": "Agri BD", "bn": "এগ্রি বিডি"],

        // Tabs
        "tab_home": ["en": "Home", "bn": "হোম"],
        "tab_weather": ["en": "Weather", "bn": "আবহাওয়া"],
        "tab_chat": ["en": "Chat", "bn": "চ্যাট"],
        "tab_community": ["en": "Community", "bn": "কমিউনিটি"],
        "tab_diseases": ["en": "Diseases", "bn": "রোগ শনাক্ত"],

        // Drawer
        "drawer_community": ["en": "Community", "bn": "কমিউনিটি"],
        "drawer_chat": ["en": "Chat", "bn": "চ্যাট"],
        "drawer_weather": ["en": "Weather", "bn": "আবহাওয়া"],
        "drawer_disease_scanner": ["en": "Disease Scanner", "bn": "রোগ শনাক্তকারী"],
        "drawer_news": ["en": "Agri BD News", "bn": "এগ্রি বিডি নিউজ"],
        "drawer_change_language": ["en": "Change Language", "bn": "ভাষা পরিবর্তন"],
        "drawer_profile": ["en": "Profile", "bn": "প্রোফাইল"],
        "drawer_tutorials": ["en": "Tutorials Agri BD", "bn": "এগ্রি বিডি টিউটোরিয়াল"],
        "drawer_help": ["en": "Help", "bn": "সাহায্য"],
        "drawer_about": ["en": "About", "bn": "সম্পর্কে"],
        "drawer_logout": ["en": "Logout", "bn": "লগ আউট"],
        "drawer_subtitle": ["en": "Your Smart Farming Assistant", "bn": "আপনার স্মার্ট ফার্মিং সহায়ক"],
        "drawer_community_new": ["en": "Community", "bn": "কমিউনিটি"],

        // Home
        "home_welcome": ["en": "Welcome 👋", "bn": "স্বাগতম 👋"],
        "home_search": ["en": "Search", "bn": "অনুসন্ধান"],
        "home_weather_conditions": ["en": "Weather Conditions", "bn": "আবহাওয়ার অবস্থা"],
        "home_smart_support": ["en": "Agri BD Smart Support", "bn": "এগ্রি বিডি স্মার্ট সাপোর্ট"],

        // Weather
        "weather_title": ["en": "আবহাওয়া · Weather", "bn": "আবহাওয়া · Weather"],
        "weather_dashboard": ["en": "Farmer Dashboard", "bn": "কৃষকের ড্যাশবোর্ড"],
        "weather_loading": ["en": "Fetching weather data...", "bn": "আবহাওয়া তথ্য আনা হচ্ছে..."],
        "weather_spray_tab": ["en": "💧 কীটনাশক · Spray", "bn": "💧 কীটনাশক · Spray"],
        "weather_details_tab": ["en": "📋 বিস্তারিত · Details", "bn": "📋 বিস্তারিত · Details"],

        // Spraying
        "spray_window": ["en": "এখন স্প্রে করা যাবে? · Spray Window", "bn": "এখন স্প্রে করা যাবে? · Spray Window"],
        "spray_optimal": ["en": "✓ এখন স্প্রে করুন — Good to spray", "bn": "✓ এখন স্প্রে করুন — Good to spray"],
        "spray_marginal": ["en": "⚠️ সাবধানে করুন — Spray carefully", "bn": "⚠️ সাবধানে করুন — Spray carefully"],
        "spray_poor": ["en": "✗ এখন করবেন না — Do not spray now", "bn": "✗ এখন করবেন না — Do not spray now"],
        "spray_advice": ["en": "পরামর্শ · Advice", "bn": "পরামর্শ · Advice"],
        "spray_application_type": ["en": "কী দিচ্ছেন · Application Type", "bn": "কী দিচ্ছেন · Application Type"],
        "weather_current_conditions": ["en": "এখনকার অবস্থা · Current Conditions", "bn": "এখনকার অবস্থা · Current Conditions"],
        "weather_precipitation": ["en": "বৃষ্টিপাত · Precipitation", "bn": "বৃষ্টিপাত · Precipitation"],
        "weather_bamis_title": ["en": "বাংলাদেশ আবহাওয়া অধিদপ্তর", "bn": "বাংলাদেশ আবহাওয়া অধিদপ্তর"],
        "weather_bamis_subtitle": ["en": "BAMIS — বিস্তারিত আবহাওয়া তথ্য", "bn": "BAMIS — বিস্তারিত আবহাওয়া তথ্য"],
        "weather_feels_like": ["en": "Feels Like", "bn": "গরম অনুভব"],
        "weather_humidity": ["en": "Humidity", "bn": "আর্দ্রতা"],
        "weather_wind": ["en": "Wind", "bn": "বাতাস"],
        "weather_pressure": ["en": "Pressure", "bn": "বায়ুচাপ"],
        "weather_rain_1h": ["en": "Rain (1h)", "bn": "বৃষ্টি (১ ঘণ্টা)"],
        "weather_clouds": ["en": "Clouds", "bn": "মেঘ"],

        // Disease Scanner
        "disease_title": ["en": "Disease Scanner", "bn": "রোগ শনাক্তকারী"],
        "disease_scan_leaf": ["en": "Scan a Plant Leaf", "bn": "গাছের পাতা স্ক্যান করুন"],
        "disease_scan_desc": ["en": "Take a photo or choose from your library\nto identify plant diseases", "bn": "ছবি তুলুন বা লাইব্রেরি থেকে নির্বাচন করুন\nউদ্ভিদের রোগ শনাক্ত করতে"],
        "disease_take_photo": ["en": "Take Photo", "bn": "ছবি তুলুন"],
        "disease_choose_library": ["en": "Choose from Library", "bn": "লাইব্রেরি থেকে নির্বাচন করুন"],
        "disease_new_scan": ["en": "New Scan", "bn": "নতুন স্ক্যান"],
        "disease_loading_model": ["en": "Loading model...", "bn": "মডেল লোড হচ্ছে..."],
        "disease_analyzing": ["en": "Analyzing...", "bn": "বিশ্লেষণ করা হচ্ছে..."],
        "disease_results": ["en": "Diagnosis Results", "bn": "নির্ণয়ের ফলাফল"],
        "disease_other": ["en": "Other possibilities", "bn": "অন্যান্য সম্ভাবনা"],
        "disease_generate_report": ["en": "Generate Advice Report (বাংলা)", "bn": "পরামর্শ রিপোর্ট তৈরি করুন"],
        "disease_download_pdf": ["en": "Download PDF", "bn": "পিডিএফ ডাউনলোড"],
        "disease_report_title": ["en": "📋 রোগ নির্ণয় রিপোর্ট", "bn": "📋 রোগ নির্ণয় রিপোর্ট"],
        "disease_generating": ["en": "Generating Bangla report...", "bn": "বাংলা রিপোর্ট তৈরি হচ্ছে..."],
        "disease_select_source": ["en": "Select Image Source", "bn": "ছবির উৎস নির্বাচন করুন"],

        // Chat
        "chat_title": ["en": "এগ্রি বিডি · Agri BD", "bn": "এগ্রি বিডি · Agri BD"],
        "chat_placeholder": ["en": "Ask a question...", "bn": "একটি প্রশ্ন জিজ্ঞাসা করুন..."],
        "chat_send": ["en": "Send", "bn": "পাঠান"],

        // Community
        "community_title": ["en": "কমিউনিটি · Community", "bn": "কমিউনিটি · Community"],
        "community_create_post": ["en": "Create Post", "bn": "পোস্ট তৈরি করুন"],
        "community_no_posts": ["en": "No posts yet. Be the first to share!", "bn": "এখনো কোনো পোস্ট নেই। প্রথম শেয়ার করুন!"],
        "community_loading": ["en": "Loading posts...", "bn": "পোস্ট লোড হচ্ছে..."],
        "community_delete_confirm": ["en": "Delete Post", "bn": "পোস্ট মুছুন"],
        "community_delete_message": ["en": "Are you sure you want to delete this post?", "bn": "আপনি কি এই পোস্টটি মুছে ফেলতে চান?"],
        "community_cancel": ["en": "Cancel", "bn": "বাতিল"],
        "community_delete": ["en": "Delete", "bn": "মুছুন"],

        // General
        "general_ok": ["en": "OK", "bn": "ঠিক আছে"],
        "general_cancel": ["en": "Cancel", "bn": "বাতিল"],
        "general_try_again": ["en": "Try Again", "bn": "আবার চেষ্টা করুন"],
        "general_error": ["en": "Something went wrong", "bn": "কোনো সমস্যা হয়েছে"],
        "general_edit": ["en": "Edit", "bn": "সম্পাদনা"],
        "general_save": ["en": "Save", "bn": "সংরক্ষণ"],
        "general_post": ["en": "Post", "bn": "পোস্ট"],

        // Community extra
        "community_comment_placeholder": ["en": "Write a comment...", "bn": "একটি মন্তব্য লিখুন..."],
        "community_comment_send": ["en": "Send", "bn": "পাঠান"],
        "community_edit_post": ["en": "Edit Post", "bn": "পোস্ট সম্পাদনা করুন"],
        "community_create_title": ["en": "Create Post", "bn": "পোস্ট তৈরি করুন"],
        "community_confirm_delete": ["en": "Delete", "bn": "মুছুন"],
        "community_confirm_title": ["en": "Delete Post", "bn": "পোস্ট মুছুন"],
        "community_confirm_message": ["en": "Are you sure you want to delete this post?", "bn": "আপনি কি এই পোস্টটি মুছে ফেলতে চান?"],
        "community_post_button": ["en": "Post", "bn": "পোস্ট"],

        // Login
        "login_welcome_back": ["en": "Welcome Back", "bn": "ফিরে আসার জন্য স্বাগতম"],
        "login_subtitle": ["en": "Sign in to your Agri BD account", "bn": "আপনার এগ্রি বিডি অ্যাকাউন্টে সাইন ইন করুন"],
        "login_email": ["en": "Email Address", "bn": "ইমেইল ঠিকানা"],
        "login_password": ["en": "Password", "bn": "পাসওয়ার্ড"],
        "login_remember_me": ["en": "Remember me", "bn": "আমাকে মনে রাখুন"],
        "login_forgot_password": ["en": "Forgot Password?", "bn": "পাসওয়ার্ড ভুলে গেছেন?"],
        "login_forgot_password_message": ["en": "Enter your email address to receive a password reset link.", "bn": "পাসওয়ার্ড রিসেট লিংক পেতে আপনার ইমেইল দিন।"],
        "login_send_reset_link": ["en": "Send Reset Link", "bn": "রিসেট লিংক পাঠান"],
        "login_sign_in": ["en": "Sign In", "bn": "সাইন ইন"],
        "login_or_continue": ["en": "or continue with", "bn": "অথবা চালিয়ে যান"],
        "login_continue_google": ["en": "Continue with Google", "bn": "গুগল দিয়ে চালিয়ে যান"],
        "login_signing_in_google": ["en": "Signing in with Google...", "bn": "গুগল দিয়ে সাইন ইন হচ্ছে..."],
        "login_no_account": ["en": "Don't have an account?", "bn": "অ্যাকাউন্ট নেই?"],
        "login_sign_up": ["en": "Sign Up", "bn": "সাইন আপ"],
        "login_signing_in": ["en": "Signing you in...", "bn": "আপনাকে সাইন ইন করানো হচ্ছে..."],
        "login_welcome_back_success": ["en": "Welcome Back!", "bn": "ফিরে আসার জন্য স্বাগতম!"],
        "login_signed_in_message": ["en": "You're signed in to Agri BD \u{1F33E}", "bn": "আপনি এগ্রি বিডিতে সাইন ইন করেছেন \u{1F33E}"],
        "login_failed": ["en": "Login Failed", "bn": "লগইন ব্যর্থ হয়েছে"],
        "login_reset_password": ["en": "Reset Password", "bn": "পাসওয়ার্ড রিসেট"],

        // Register
        "register_join": ["en": "Join Agri BD", "bn": "এগ্রি বিডিতে যোগ দিন"],
        "register_subtitle": ["en": "Create your account to get started", "bn": "শুরু করতে আপনার অ্যাকাউন্ট তৈরি করুন"],
        "register_first_name": ["en": "First Name", "bn": "নামের প্রথম অংশ"],
        "register_last_name": ["en": "Last Name", "bn": "নামের শেষ অংশ"],
        "register_email": ["en": "Email Address", "bn": "ইমেইল ঠিকানা"],
        "register_password": ["en": "Password", "bn": "পাসওয়ার্ড"],
        "register_confirm_password": ["en": "Confirm Password", "bn": "পাসওয়ার্ড নিশ্চিত করুন"],
        "register_create_account": ["en": "Create Account", "bn": "অ্যাকাউন্ট তৈরি করুন"],
        "register_terms": ["en": "By creating an account, you agree to our\nTerms of Service and Privacy Policy.", "bn": "অ্যাকাউন্ট তৈরি করে, আপনি আমাদের\nসেবার শর্তাবলী এবং গোপনীয়তা নীতিতে সম্মত হচ্ছেন।"],
        "register_have_account": ["en": "Already have an account?", "bn": "ইতিমধ্যে অ্যাকাউন্ট আছে?"],
        "register_sign_in": ["en": "Sign In", "bn": "সাইন ইন"],
        "register_creating": ["en": "Creating your account...", "bn": "আপনার অ্যাকাউন্ট তৈরি হচ্ছে..."],
        "register_account_created": ["en": "Account Created!", "bn": "অ্যাকাউন্ট তৈরি হয়েছে!"],
        "register_welcome_message": ["en": "Welcome to Agri BD \u{1F33E}", "bn": "এগ্রি বিডিতে স্বাগতম \u{1F33E}"],
        "register_error": ["en": "Error", "bn": "ত্রুটি"],
        "register_date_of_birth": ["en": "Date of Birth", "bn": "জন্ম তারিখ"],
    ]

    static func string(for key: String, language: LocalizationManager.Language) -> String {
        strings[key]?[language.rawValue] ?? strings[key]?["bn"] ?? key
    }
}

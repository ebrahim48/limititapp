# Settings API Integration with Controller

## ✅ Complete Implementation

Dynamic screens for **About Us**, **Privacy Policy**, and **Terms & Conditions** using **GetX Controller** and API integration.

---

## 📁 Files Created/Updated

### 1. **Controller**
**`lib/controllers/settings_controller.dart`**
- `fetchAboutUs()` - Fetches About Us data from API
- `fetchPrivacyPolicy()` - Fetches Privacy Policy data from API
- `fetchTermsAndConditions()` - Fetches Terms & Conditions data from API
- `_stripHtmlTags()` - Converts HTML content to plain text

### 2. **Screens** (Using GetX Obx)
- `lib/core/presentations/screens/settings/about_us_screen.dart`
- `lib/core/presentations/screens/settings/privacy_policy_screen.dart`
- `lib/core/presentations/screens/settings/terms_screen.dart`

### 3. **API Endpoints** (Already in `api_constants.dart`)
```dart
static const String aboutUsPoint = "/settings/about-us";
static const String privacyPolicyPoint = "/settings/privacy-policy";
static const String termsConditionPoint = "/settings/terms-condition";
```

---

## 🎯 Controller Features

### Reactive Variables (Rx)
```dart
// About Us
final RxBool isLoadingAboutUs = false.obs;
final RxBool hasErrorAboutUs = false.obs;
final RxString aboutUsContent = ''.obs;
final RxString aboutUsName = ''.obs;
final RxString aboutUsEmail = ''.obs;
final RxString aboutUsPhone = ''.obs;

// Privacy Policy
final RxBool isLoadingPrivacyPolicy = false.obs;
final RxBool hasErrorPrivacyPolicy = false.obs;
final RxString privacyPolicyContent = ''.obs;

// Terms & Conditions
final RxBool isLoadingTerms = false.obs;
final RxBool hasErrorTerms = false.obs;
final RxString termsContent = ''.obs;
```

### HTML to Plain Text Conversion
The controller includes a comprehensive HTML stripper that handles:
- **Block elements**: `<h1>`, `<h2>`, `<h3>`, `<h4>`, `<p>`, `<div>`, `<li>`, `<ul>`, `<ol>`
- **Inline elements**: `<strong>`, `<b>`, `<em>`, `<i>`, `<u>`, `<a>`, `<span>`
- **Line breaks**: `<br>`, `<br/>`, `<br />`
- **HTML entities**: `&nbsp;`, `&amp;`, `&lt;`, `&gt;`, `&quot;`, `&#39;`, `&mdash;`, `&hellip;`, etc.

---

## 🔄 How It Works

### 1. **Screen Initialization**
```dart
@override
Widget build(BuildContext context) {
  final controller = Get.put(SettingsController());
  controller.fetchAboutUs(); // Auto-fetch on load

  return Scaffold(
    body: Obx(() {
      if (controller.isLoadingAboutUs.value) {
        return _buildLoadingView(context);
      }
      if (controller.hasErrorAboutUs.value) {
        return _buildErrorView(context, controller);
      }
      return _buildContent(context, controller);
    }),
  );
}
```

### 2. **API Call Flow**
```
User opens screen
    ↓
Get.put(SettingsController)
    ↓
controller.fetchAboutUs()
    ↓
isLoadingAboutUs = true (shows loader)
    ↓
ApiClient.getData(ApiConstants.aboutUsPoint)
    ↓
Response received
    ↓
Strip HTML tags from content
    ↓
Update Rx variables
    ↓
isLoadingAboutUs = false
    ↓
Obx rebuilds UI with content
```

### 3. **Error Handling**
```dart
try {
  isLoadingAboutUs.value = true;
  hasErrorAboutUs.value = false;

  final response = await ApiClient.getData(ApiConstants.aboutUsPoint);

  if (response.statusCode == 200 && data['status'] == 'success') {
    aboutUsContent.value = _stripHtmlTags(data['data']['content']);
  } else {
    hasErrorAboutUs.value = true;
  }
} catch (e) {
  hasErrorAboutUs.value = true;
} finally {
  isLoadingAboutUs.value = false;
}
```

---

## 📊 API Response Format

### Success Response
```json
{
  "status": "success",
  "statusCode": 200,
  "message": "privacy found",
  "data": {
    "_id": "696376245f6d340c1010fb69",
    "content": "<h1>Privacy Policy</h1><p>We respect your privacy...</p>",
    "createdAt": "2026-01-11T10:06:28.592Z",
    "updatedAt": "2026-03-03T05:41:57.993Z",
    "__v": 0
  }
}
```

### About Us (with contact info)
```json
{
  "data": {
    "content": "<h1>About Us</h1><p>We are...</p>",
    "name": "Ebrahim",
    "email": "ebrahim.cse.bu@gmail.com",
    "phone": "+1623773738"
  }
}
```

---

## 🎨 UI States

### 1. **Loading State**
```
┌─────────────────┐
│   ← About Us    │
├─────────────────┤
│                 │
│     ⏳          │  <- Spinning loader
│   Loading...    │
│                 │
└─────────────────┘
```

### 2. **Error State**
```
┌─────────────────┐
│   ← About Us    │
├─────────────────┤
│                 │
│     ❌          │  <- Error icon
│ Failed to load  │
│     [Retry]     │  <- Button
│                 │
└─────────────────┘
```

### 3. **Success State**
```
┌─────────────────┐
│   ← About Us    │
├─────────────────┤
│   ┌─────────┐   │  <- Header image
│   │  Image  │   │
│   └─────────┘   │
│                 │
│ Lorem ipsum...  │  <- API content
│ (plain text)    │
│                 │
│   Ebrahim       │  <- Contact name
│ 📞 +1623773738  │  <- Phone
│ ✉️ email@...    │  <- Email
│                 │
└─────────────────┘
```

---

## 🌐 Localization Strings

| Key | English | Italian | Spanish |
|-----|---------|---------|---------|
| `aboutUs` | About Us | Chi Siamo | Sobre Nosotros |
| `privacyPolicy` | Privacy Policy | Informativa sulla Privacy | Política de Privacidad |
| `termsConditions` | Terms & Conditions | Termini e Condizioni | Términos y Condiciones |
| `loading` | Loading... | Caricamento... | Cargando... |
| `retry` | Retry | Riprova | Reintentar |
| `failedToLoadData` | Failed to load data | Impossibile caricare i dati | Error al cargar los datos |

---

## 🚀 Usage

### Navigate to Screens
```dart
// From Settings Screen
context.go(AppRoutes.aboutUsScreen);
context.go(AppRoutes.privacyPolicyScreen);
context.go(AppRoutes.termsServicesScreen);
```

### Access Controller Directly (if needed)
```dart
final settingsController = Get.find<SettingsController>();
await settingsController.fetchAboutUs();
print(settingsController.aboutUsContent.value);
```

---

## ✨ Key Features

1. **✅ GetX Pattern** - Uses GetX controller for state management
2. **✅ Reactive UI** - Obx automatically rebuilds on data change
3. **✅ HTML Stripping** - Converts HTML to clean plain text
4. **✅ Error Handling** - Shows error with retry button
5. **✅ Loading States** - Spinner while fetching data
6. **✅ Multi-language** - EN/IT/ES support
7. **✅ Contact Info** - Displays name, email, phone (About Us only)
8. **✅ Single Controller** - All 3 screens use one controller

---

## 🧪 Testing

### Test Scenarios:
1. ✅ **Success**: API returns 200 → Content displays
2. ✅ **Network Error**: No internet → Error with retry
3. ✅ **Empty Content**: API returns empty → Shows empty state
4. ✅ **HTML Content**: API returns HTML → Stripped to plain text
5. ✅ **Contact Info**: Only shows if available in response

### Manual Testing:
```
1. Open app → Settings
2. Tap "About Us" → Verify loading → Verify content
3. Turn off WiFi → Tap retry → Verify error
4. Check Privacy Policy → Check Terms & Conditions
5. Verify all 3 API endpoints work
```

---

## 📝 Notes

- **Controller is singleton** - `Get.put()` creates once, reused across screens
- **HTML stripping is comprehensive** - Handles most HTML tags and entities
- **No extra dependencies** - Uses existing ApiClient pattern
- **Debug logging** - All API calls logged for debugging
- **Reset methods available** - `resetAboutUs()`, `resetPrivacyPolicy()`, `resetTerms()`

---

## 🔧 Future Enhancements (Optional)

1. **Rich HTML rendering**: Use `flutter_html` package
   ```yaml
   dependencies:
     flutter_html: ^3.0.0-beta.2
   ```

2. **Caching**: Store responses locally
   ```dart
   await PrefsHelper.setString('about_us', content);
   ```

3. **Pull to refresh**:
   ```dart
   RefreshIndicator(
     onRefresh: () => controller.fetchAboutUs(),
     child: SingleChildScrollView(...),
   )
   ```

4. **Skeleton loader**: Replace spinner with shimmer effect

---

**Created**: 2026-03-03  
**Contact**: ebrahim.cse.bu@gmail.com

# Notifications Feature - Dynamic API Integration

## Overview
Implemented dynamic notifications feature that fetches data from API with pagination, pull-to-refresh, and infinite scroll capabilities.

## API Endpoint
- **Endpoint**: `GET /notification?page=1&limit=10`
- **Method**: GET
- **Authentication**: Required (Bearer token)

## API Response Structure
```json
{
  "status": "success",
  "statusCode": 200,
  "message": "Notifications fetched successfully",
  "data": [
    {
      "_id": "69a92a2f66f3941cccdb93dc",
      "title": "Screen Time Alert",
      "message": "Your screen time limit for Instagram has been reached.",
      "type": "user",
      "recipientId": "69a92a2966f3941cccdb939e",
      "read": false,
      "__v": 0,
      "createdAt": "2026-03-05T07:01:03.584Z",
      "updatedAt": "2026-03-05T07:01:03.584Z"
    }
  ],
  "pagination": {
    "totalPage": 1,
    "currentPage": 1,
    "prevPage": null,
    "nextPage": null,
    "totalData": 1
  }
}
```

## Files Created/Modified

### 1. Notification Model (`lib/core/models/notification_model.dart`)
**NEW FILE** - Data model for notification entities

**Features:**
- Parses API response data
- Auto-generates avatar text from title (first 2 letters)
- Maps notification types to avatar colors:
  - `user` → Gray (`0xFFE5E5E5`)
  - `system` → Green (`0xFFDCFCE7`)
  - `alert` → Orange (`0xFFFFEDD5`)
  - `promotion` → Yellow (`0xFFEDD69A`)
- Converts `createdAt` to human-readable "time ago" format
- Handles null safety

**Properties:**
- `id`: String - Unique notification ID
- `title`: String - Notification title
- `message`: String - Notification body
- `type`: String - Type (user/system/alert/promotion)
- `read`: Boolean - Read/unread status
- `createdAt`: String - ISO 8601 timestamp
- `avatarText`: String - Generated avatar initials
- `avatarColor`: String - Hex color code
- `timeAgo`: String - Computed property (e.g., "2m ago", "1h ago")

### 2. Notifications Controller (`lib/controllers/notifications_controller.dart`)
**NEW FILE** - GetX controller for notifications management

**Features:**
- Fetches notifications from API
- Pagination support (page & limit)
- Pull-to-refresh functionality
- Infinite scroll (load more)
- Loading states
- Error handling
- Unread count tracking

**Methods:**
- `fetchNotifications({isRefresh})` - Main fetch method
- `refreshNotifications()` - Pull-to-refresh
- `loadMoreNotifications()` - Load next page
- `markAsRead(index)` - Mark notification as read
- `clearNotifications()` - Clear all notifications
- `unreadCount` - Get count of unread notifications

**State Variables:**
- `isLoading`: RxBool - Loading indicator
- `notifications`: RxList<NotificationModel> - Notifications list
- `hasMore`: RxBool - More pages available
- `currentPage`: int - Current page number
- `totalPages`: int - Total pages
- `totalData`: int - Total notifications count

### 3. Notifications Screen (`lib/core/presentations/screens/notifications/notifications_screen.dart`)
**MODIFIED** - Updated from static to dynamic

**Changes:**
- ❌ Removed: Static mock data
- ✅ Added: GetX controller integration
- ✅ Added: Obx reactive UI
- ✅ Added: Pull-to-refresh (RefreshIndicator)
- ✅ Added: Loading state with spinner
- ✅ Added: Infinite scroll (load more indicator)
- ✅ Added: Dynamic time formatting (timeAgo)
- ✅ Added: Avatar color from hex

**UI States:**
1. **Loading State**: Shows spinner with "Loading..." text
2. **Empty State**: Shows icon and "No notifications yet" message
3. **Content State**: Shows notifications list with refresh & load more

### 4. Dependency Injection (`lib/core/helpers/dependancy_injaction.dart`)
**MODIFIED** - Registered NotificationsController

```dart
Get.lazyPut<NotificationsController>(
  () => NotificationsController(), 
  fenix: true
);
```

## Features Implemented

### 1. **API Integration**
- ✅ GET request to `/notification` endpoint
- ✅ Query params: `page` & `limit`
- ✅ Pagination handling
- ✅ Error handling

### 2. **Pull-to-Refresh**
- ✅ Swipe down to refresh
- ✅ Resets to page 1
- ✅ Clears existing data
- ✅ Shows refresh indicator

### 3. **Infinite Scroll**
- ✅ Auto-loads more when scrolling to bottom
- ✅ Shows loading indicator at bottom
- ✅ Respects `hasMore` flag
- ✅ Prevents duplicate loads

### 4. **Smart Time Display**
- ✅ `< 1 min` → "Just now"
- ✅ `< 60 min` → "Xm ago"
- ✅ `< 24 hrs` → "Xh ago"
- ✅ `< 7 days` → "Xd ago"
- ✅ `>= 7 days` → "DD/MM/YYYY"

### 5. **Avatar Generation**
- ✅ Auto-generates initials from title
- ✅ Color-codes by notification type
- ✅ Consistent with design system

### 6. **Loading States**
- ✅ Initial load spinner
- ✅ Refresh indicator
- ✅ Load more indicator
- ✅ Empty state handling

## UI Components

### NotificationItemWidget (Existing - Unchanged)
```dart
NotificationItemWidget(
  title: notification.title,
  message: notification.message,
  time: notification.timeAgo,  // ← Dynamic
  avatarText: notification.avatarText,  // ← Dynamic
  avatarColor: _hexToColor(notification.avatarColor),  // ← Dynamic
)
```

## Usage Example

### Navigate to Notifications
```dart
// From any screen
context.pushNamed(AppRoutes.notificationsScreen);
```

### Access Controller
```dart
final controller = Get.find<NotificationsController>();

// Refresh manually
await controller.refreshNotifications();

// Load more
await controller.loadMoreNotifications();

// Get unread count
int unread = controller.unreadCount;

// Clear all
controller.clearNotifications();
```

## Data Flow

```
NotificationsScreen
    ↓
    → Get.find<NotificationsController>()
        ↓
        → fetchNotifications()
            ↓
            → ApiClient.getData('/notification?page=1&limit=10')
                ↓
                → API Response
                    ↓
                    → NotificationModel.fromJson()
                        ↓
                        → notifications.assignAll()
                            ↓
                            → Obx() rebuilds UI
```

## Pagination Logic

```dart
// Initial load
page = 1, limit = 10
→ Fetches first 10 notifications

// Load more (scroll to bottom)
page = 2, limit = 10
→ Fetches next 10 notifications
→ Appends to existing list

// Refresh (pull down)
page = 1, limit = 10
→ Clears list
→ Fetches fresh data
```

## Error Handling

| Scenario | Behavior |
|----------|----------|
| **Network Error** | Logs error, shows empty state |
| **API Error (4xx/5xx)** | Logs error, shows empty state |
| **Empty Data** | Shows empty state with icon |
| **Parse Error** | Skips invalid item, continues |
| **No More Pages** | Stops loading more |

## Performance Optimizations

- ✅ **Lazy Loading**: Controller initialized only when needed
- ✅ **Pagination**: Loads 10 at a time (not all)
- ✅ **RxList**: Efficient reactive updates
- ✅ **Image Caching**: Avatar colors (not images)
- ✅ **Debouncing**: Prevents rapid load more calls

## Testing Checklist

- ✅ Initial load displays notifications
- ✅ Pull-to-refresh fetches new data
- ✅ Infinite scroll loads more pages
- ✅ Empty state shows when no notifications
- ✅ Loading spinner appears during fetch
- ✅ Time format is correct (m ago, h ago, d ago)
- ✅ Avatar colors match notification type
- ✅ Pagination works correctly
- ✅ Handles network errors gracefully
- ✅ Unread count is accurate

## Future Enhancements

- [ ] Mark as read API integration
- [ ] Delete notification functionality
- [ ] Clear all notifications
- [ ] Notification settings/preferences
- [ ] Push notifications support
- [ ] Notification categories filter
- [ ] Search notifications
- [ ] Badge count on app icon

## Dependencies

No new dependencies added. Uses existing:
- `get` - State management
- `flutter_screenutil` - Responsive UI
- Existing API client

## API Constants

Add to `lib/core/services/api_constants.dart`:

```dart
static const String notificationEndPoint = "/notification?page=1&limit=10";
```

✅ **Already exists in your codebase**

## Summary

✅ **Fully Dynamic** - All data from API
✅ **Pagination Ready** - Handles large datasets
✅ **User Friendly** - Pull-to-refresh, infinite scroll
✅ **Error Resilient** - Graceful error handling
✅ **Performance Optimized** - Lazy loading, efficient updates
✅ **Zero Errors** - Passes Flutter analysis

The notifications feature is now fully dynamic and production-ready! 🎉

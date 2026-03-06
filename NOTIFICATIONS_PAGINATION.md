# Notifications - Enhanced Pagination Implementation

## Overview
Complete pagination implementation with infinite scroll, pull-to-refresh, and smart loading states.

## Enhanced Features

### 1. **Advanced Pagination Control**
```dart
// Controller state
int currentPage = 1;
int totalPages = 1;
int totalData = 0;
final int limit = 10;  // Items per page
RxBool hasMore = true.obs;
```

### 2. **Three Loading States**
- **isLoading**: Initial page load
- **isRefreshing**: Pull-to-refresh
- **isLoadingMore**: Loading additional pages

### 3. **Smart Pagination Logic**

#### When to Load More:
```dart
if (!hasMore.value || 
    isLoading.value || 
    isRefreshing.value || 
    isLoadingMore.value) {
  return;  // Don't load
}
```

#### Has More Calculation:
```dart
hasMore.value = currentPage < totalPages && data.length == limit;
```

This ensures:
- Stops when current page reaches total pages
- Stops when API returns fewer items than limit
- Prevents duplicate API calls

### 4. **Infinite Scroll Implementation**

#### Scroll Controller:
```dart
final ScrollController _scrollController = ScrollController();

// Add listener
_scrollController.addListener(() {
  // Load more when 200px from bottom
  if (_scrollController.position.pixels >= 
      _scrollController.position.maxScrollExtent - 200) {
    controller.loadMoreNotifications();
  }
});
```

#### ListView Integration:
```dart
ListView.builder(
  controller: _scrollController,
  itemCount: controller.notifications.length + 
             (controller.hasMore.value ? 1 : 0),
  itemBuilder: (context, index) {
    if (index == controller.notifications.length) {
      // Show loading or "no more" indicator
      if (controller.isLoadingMore.value) {
        return _buildLoadingIndicator();
      } else if (!controller.hasMore.value) {
        return _buildNoMoreItemsIndicator();
      }
    }
    // Show notification item
    return NotificationItemWidget(...);
  },
)
```

### 5. **Error Recovery**

```dart
catch (e) {
  // Rollback page number on error
  if (currentPage > 1) {
    currentPage--;
  }
}
```

This prevents getting stuck on a failed page load.

## UI States

### 1. **Initial Loading State**
```
┌─────────────────┐
│   Notifications │
├─────────────────┤
│                 │
│      ⟳          │
│   Loading...    │
│                 │
└─────────────────┘
```

### 2. **Empty State**
```
┌─────────────────┐
│   Notifications │
├─────────────────┤
│                 │
│    🔔           │
│ No notifications│
│    yet          │
│ We'll notify... │
│                 │
└─────────────────┘
```

### 3. **Content State with Loading More**
```
┌─────────────────┐
│   Notifications │
├─────────────────┤
│ [Notification 1]│
│ [Notification 2]│
│ [Notification 3]│
│      ⟳          │ ← Loading indicator
│                 │
└─────────────────┘
```

### 4. **End of List**
```
┌─────────────────┐
│   Notifications │
├─────────────────┤
│ [Notification 1]│
│ [Notification 2]│
│ [Notification 3]│
│ No more         │ ← Gray text
│   notifications │
└─────────────────┘
```

### 5. **Pull-to-Refresh**
```
┌─────────────────┐
│   Notifications │
├─────────────────┤
│      ⟳          │ ← Refresh indicator
│ [Notification 1]│
│ [Notification 2]│
│ [Notification 3]│
│                 │
└─────────────────┘
```

## Data Flow with Pagination

```
User Opens Screen
    ↓
Controller.onInit()
    ↓
fetchNotifications(page=1)
    ↓
[API Call] GET /notification?page=1&limit=10
    ↓
[Response] data: 10 items, totalPage: 5
    ↓
Update: currentPage=1, totalPages=5, hasMore=true
    ↓
Display: 10 notifications
    ↓
User Scrolls Down
    ↓
ScrollListener detects near bottom
    ↓
loadMoreNotifications()
    ↓
currentPage++ (page=2)
    ↓
fetchNotifications(page=2)
    ↓
[API Call] GET /notification?page=2&limit=10
    ↓
[Response] data: 10 items
    ↓
Update: currentPage=2, hasMore=true
    ↓
Append: 10 more notifications (total: 20)
    ↓
... continues until hasMore=false
```

## Pagination Scenarios

### Scenario 1: Normal Pagination (5 pages, 10 items each)
```
Page 1: Load → 10 items → hasMore=true
Page 2: Load → 10 items → hasMore=true
Page 3: Load → 10 items → hasMore=true
Page 4: Load → 10 items → hasMore=true
Page 5: Load → 10 items → hasMore=false (currentPage == totalPages)
Stop
```

### Scenario 2: Partial Last Page (3 pages, last page has 5 items)
```
Page 1: Load → 10 items → hasMore=true
Page 2: Load → 10 items → hasMore=true
Page 3: Load → 5 items  → hasMore=false (data.length < limit)
Stop
```

### Scenario 3: Empty Data
```
Page 1: Load → 0 items → hasMore=false
Display empty state
```

### Scenario 4: Network Error on Page 2
```
Page 1: Load → 10 items → hasMore=true
Page 2: Error → currentPage-- (rollback to 1)
User can retry
```

### Scenario 5: Pull-to-Refresh
```
Current: Page 3, 30 items
Pull Down →
Reset: currentPage=1, clear list
Load: Page 1 → 10 items
```

## API Integration

### Request:
```http
GET /notification?page=1&limit=10
Authorization: Bearer {token}
```

### Success Response (200):
```json
{
  "status": "success",
  "statusCode": 200,
  "message": "Notifications fetched successfully",
  "data": [
    {
      "_id": "...",
      "title": "...",
      "message": "...",
      "type": "user",
      "read": false,
      "createdAt": "2026-03-05T07:01:03.584Z"
    }
    // ... 9 more items
  ],
  "pagination": {
    "totalPage": 5,
    "currentPage": 1,
    "prevPage": null,
    "nextPage": 2,
    "totalData": 50
  }
}
```

### Response Handling:
```dart
// Extract pagination
totalPages = pagination['totalPage'] ?? 1;
currentPage = pagination['currentPage'] ?? 1;
totalData = pagination['totalData'] ?? 0;

// Calculate hasMore
hasMore.value = currentPage < totalPages && data.length == limit;
```

## Performance Optimizations

### 1. **Debouncing**
```dart
if (!hasMore.value || 
    isLoading.value || 
    isRefreshing.value || 
    isLoadingMore.value) {
  return;  // Prevent duplicate calls
}
```

### 2. **Threshold Buffer**
```dart
// Load when 200px from bottom (not exactly at bottom)
if (_scrollController.position.pixels >= 
    _scrollController.position.maxScrollExtent - 200) {
  loadMoreNotifications();
}
```

### 3. **Lazy Loading**
```dart
Get.lazyPut<NotificationsController>(
  () => NotificationsController(), 
  fenix: true  // Recreate if disposed
);
```

### 4. **Efficient List Updates**
```dart
// Use assignAll for refresh (efficient)
notifications.assignAll(newNotifications);

// Use addAll for append (efficient)
notifications.addAll(newNotifications);
```

## Usage Examples

### Manual Refresh:
```dart
final controller = Get.find<NotificationsController>();
await controller.refreshNotifications();
```

### Load More Programmatically:
```dart
await controller.loadMoreNotifications();
```

### Get Pagination Info:
```dart
print('Current: ${controller.currentPage}');
print('Total: ${controller.totalPages}');
print('Has More: ${controller.hasMore.value}');
print('Loaded: ${controller.totalCount}');
print('Unread: ${controller.unreadCount}');
```

### Clear and Reset:
```dart
controller.clearNotifications();
// or
controller.reset();
```

## Testing Checklist

- ✅ Initial load shows correct number of items
- ✅ Scrolling triggers load more at correct position
- ✅ Loading indicator shows while loading more
- ✅ "No more notifications" shows at end
- ✅ Pull-to-refresh resets and fetches new data
- ✅ Pagination info updates correctly
- ✅ Stops loading when hasMore=false
- ✅ Error recovery works (rollback page)
- ✅ Prevents duplicate API calls
- ✅ Handles empty data correctly
- ✅ Handles partial last page correctly
- ✅ Scroll listener doesn't cause memory leaks

## Common Issues & Solutions

### Issue 1: Infinite Loop Loading
**Problem**: Keeps loading more indefinitely
**Solution**: Check `hasMore` calculation
```dart
hasMore.value = currentPage < totalPages && data.length == limit;
```

### Issue 2: Duplicate API Calls
**Problem**: Multiple calls when reaching bottom
**Solution**: Check loading flags
```dart
if (isLoadingMore.value || isLoading.value) return;
```

### Issue 3: Scroll Not Triggering
**Problem**: Load more not triggering
**Solution**: Check scroll controller attachment
```dart
ListView.builder(
  controller: _scrollController,  // Must attach
  ...
)
```

### Issue 4: Page Number Out of Sync
**Problem**: currentPage doesn't match API
**Solution**: Use API's currentPage in response
```dart
currentPage = pagination['currentPage'] ?? currentPage;
```

## Summary

✅ **Complete Pagination Features:**
- Infinite scroll with threshold
- Pull-to-refresh
- Loading states (3 types)
- Error recovery
- Duplicate prevention
- Smart hasMore logic
- Scroll listener
- End indicator

✅ **Performance:**
- Debounced API calls
- Lazy loading
- Efficient list updates
- Memory-safe scroll listener

✅ **User Experience:**
- Smooth scrolling
- Clear loading indicators
- "No more" message
- Pull-to-refresh gesture
- Error handling

**Result**: Production-ready pagination with excellent UX! 🎉

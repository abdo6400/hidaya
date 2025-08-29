# Schedule Management Update

## Important Change
The schedule management functionality has been centralized in the `SchedulesService` class. 
Previously, some schedule operations were in `SheiksService`, which caused type conflicts.

## How to Use Schedules

1. Always use `SchedulesService` through the provider:
```dart
// In your widget:
final scheduleAsyncValue = ref.watch(schedulesControllerProvider(sheikhId));

// To perform operations:
await ref.read(schedulesControllerProvider(sheikhId).notifier).addSchedule(schedule);
```

2. Do NOT use the schedule methods from `SheiksService`. They have been deprecated and removed.

3. The `SchedulesService` provides these operations:
- `getAllSchedules()`
- `getSchedulesBySheikh(String sheikhId)`
- `addSchedule(ScheduleModel schedule)`
- `updateSchedule(String id, ScheduleModel schedule)`
- `deleteSchedule(String id)` (soft delete)
- `hardDeleteSchedule(String id)` (permanent delete)

## Examples

```dart
// Get schedules for a sheikh
final schedules = await ref.read(schedulesServiceProvider).getSchedulesBySheikh(sheikhId);

// Add a new schedule
final id = await ref.read(schedulesServiceProvider).addSchedule(newSchedule);

// Update a schedule
await ref.read(schedulesServiceProvider).updateSchedule(scheduleId, updatedSchedule);
```

# Timetable Management System Project

A PostgreSQL schema for managing course timetables, lecturers, rooms, days, and room-allocation tracking.

## Quick Start

Create a local PostgreSQL database, then load the schema:

```bash
createdb timetable_management
psql -d timetable_management -f schema.sql
```

Verify the tables:

```sql
\dt
```

## Schema Overview

- `Days`: available timetable days.
- `Lecturers`: lecturer records.
- `Courses`: course/unit records keyed by `unit_code`.
- `Timetable`: scheduled teaching sessions.
- `RoomAllocation`: room occupancy records created by trigger logic.

## Conflict Constraints

The `Timetable` table prevents three common clashes:

- A lecturer cannot be scheduled in two places for the same day/time.
- A stream cannot have two sessions at the same day/time.
- A room cannot be double-booked for the same day/time.

## Trigger Behavior

`trg_update_room_allocation` inserts a room-allocation record after a timetable entry is created with a non-null room. The current implementation uses `NOW()` as the allocation start and adds `duration` hours for the allocation end.

## Current Limitations

- `time_slot` is stored as text, so the database cannot yet reason about overlapping time ranges such as `09:00-10:00` and `09:30-10:30`.
- `duration` is a floating-point value; a fixed interval or integer minutes field would be safer for scheduling precision.
- There are no seed data or migration tests yet.

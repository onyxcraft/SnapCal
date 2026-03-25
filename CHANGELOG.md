# Changelog

All notable changes to SnapCal will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-03-25

### Added
- Initial release of SnapCal
- Month view with beautiful calendar grid
- Week view with hourly timeline
- Day view with detailed daily schedule
- Agenda view showing upcoming events
- Natural language event creation
  - Parse dates (today, tomorrow, weekdays, specific dates)
  - Parse times (12-hour and 24-hour formats)
  - Detect all-day events
  - Extract event titles automatically
- Full EventKit integration
  - Sync with Apple Calendar
  - Support for multiple calendars
  - Calendar color coding
- Event management
  - Create new events
  - Edit existing events
  - Delete events
  - View event details
- Recurring events support
  - Daily recurrence
  - Weekly recurrence
  - Monthly recurrence
  - Yearly recurrence
- Home screen widgets
  - Small widget (2 events)
  - Medium widget (4 events)
  - Large widget (8 events)
  - Auto-refresh every 15 minutes
- Dark mode support
- iPad support with adaptive layouts
- Smooth view transitions
- Quick event creation from any view
- Event location support
- Event notes support
- Calendar access permissions handling

### Technical
- Built with SwiftUI
- MVVM architecture
- iOS 17.0+ minimum deployment target
- No external dependencies
- EventKit for calendar integration
- WidgetKit for home screen widgets
- Natural language processing for event parsing
- Comprehensive date extension utilities

[1.0.0]: https://github.com/yourusername/snapcal/releases/tag/v1.0.0

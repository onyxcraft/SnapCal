# SnapCal

A beautiful, minimal calendar app for iOS 17+ with natural language event creation and seamless Apple Calendar integration.

![Platform](https://img.shields.io/badge/platform-iOS%2017.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/license-MIT-green)

## Features

### Core Functionality
- **Multiple View Modes**: Switch seamlessly between Month, Week, Day, and Agenda views
- **Natural Language Input**: Create events by typing naturally - "dentist Friday 3pm" automatically parses to a proper event
- **Apple Calendar Sync**: Full EventKit integration keeps everything in sync with your Apple Calendar
- **Home Screen Widgets**: Beautiful widgets in small, medium, and large sizes showing your upcoming events
- **Event Management**: Create, edit, and delete events with full support for recurring events
- **Color Coding**: Events are automatically color-coded by their calendar for easy visual identification

### UI/UX
- **Smooth Transitions**: Fluid animations between views for a delightful user experience
- **Dark Mode Support**: Looks beautiful in both light and dark mode
- **iPad Support**: Fully optimized for iPad with adaptive layouts
- **Minimal Design**: Clean, distraction-free interface that puts your schedule front and center

### Technical Features
- **No External Dependencies**: Pure Swift and SwiftUI implementation
- **MVVM Architecture**: Clean, maintainable code structure
- **EventKit Integration**: Native calendar access and synchronization
- **WidgetKit**: Modern widget implementation with timeline updates

## Requirements

- iOS 17.0+
- iPadOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/snapcal.git
cd snapcal
```

2. Open the project in Xcode:
```bash
open SnapCal.xcodeproj
```

3. Select your target device and run the project (⌘R)

## Usage

### Natural Language Event Creation

Simply type what you want to create:
- "Lunch with Sarah tomorrow at 1pm"
- "Team meeting Monday 10am"
- "Birthday party Saturday all day"
- "Gym session next Friday 6pm"

The app intelligently parses:
- Event titles
- Dates (today, tomorrow, specific days, dates)
- Times (12-hour and 24-hour formats)
- All-day events

### View Modes

- **Month View**: Traditional calendar grid with event indicators
- **Week View**: Hourly timeline for the week ahead
- **Day View**: Detailed daily schedule with hourly slots
- **Agenda View**: Clean list of upcoming events

### Widgets

Add SnapCal widgets to your home screen:
- **Small**: Shows date and next 2 events
- **Medium**: Shows date and next 4 events with times
- **Large**: Shows date and next 8 events with full details

## Architecture

```
SnapCal/
├── Models/
│   ├── CalendarEvent.swift       # Event data model
│   └── DateExtensions.swift      # Date utility extensions
├── Views/
│   ├── MonthView.swift           # Monthly calendar grid
│   ├── WeekView.swift            # Weekly timeline view
│   ├── DayView.swift             # Daily schedule view
│   ├── AgendaView.swift          # List of upcoming events
│   ├── EventDetailView.swift    # Event details screen
│   └── EventCreationView.swift  # Event creation/editing
├── ViewModels/
│   ├── CalendarViewModel.swift   # Calendar state management
│   └── EventViewModel.swift      # Event CRUD operations
├── Services/
│   ├── EventKitService.swift     # EventKit integration
│   └── NaturalLanguageParser.swift # NLP for event parsing
└── Assets.xcassets/              # App icons and colors

SnapCalWidget/
├── SnapCalWidget.swift           # Widget views and logic
├── SnapCalWidgetBundle.swift     # Widget bundle
└── Assets.xcassets/              # Widget assets
```

## Privacy

SnapCal requires calendar access to function. The app:
- Only accesses your calendar data locally on your device
- Does not send any data to external servers
- Does not collect analytics or personal information
- Stores all data within Apple's Calendar framework

## App Store

- **Bundle ID**: com.lopodragon.snapcal
- **Price**: $3.99 USD (one-time purchase)
- **Category**: Productivity
- **Age Rating**: 4+

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes in each version.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

If you encounter any issues or have questions, please file an issue on the GitHub issue tracker.

## Acknowledgments

- Built with SwiftUI and EventKit
- Designed for iOS 17+
- No external dependencies used

---

Made with ❤️ using Swift and SwiftUI

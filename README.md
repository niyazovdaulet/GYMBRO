# GYMBRO - MVVM Architecture

## Overview
GYMBRO is a fitness app built with SwiftUI using the MVVM (Model-View-ViewModel) architecture pattern.

## Architecture Structure

### Models (`Models.swift`)
- **Exercise**: Represents exercise data with properties like title, category, description, etc.
- **Coach**: Represents coach data with name, experience, etc.
- **Category**: Represents exercise categories
- All models conform to `Identifiable`, `Codable`, and `Hashable` for better data management

### ViewModels (`ViewModels/`)
- **HomeViewModel**: Manages the state and business logic for the main home screen
- **CategoryDetailViewModel**: Handles category-specific exercise data and filtering
- **PopularExercisesViewModel**: Manages popular exercises data and interactions
- **ExerciseDetailViewModel**: Handles exercise detail view state and photo management

### Views
- **HomeView**: Main dashboard with popular exercises, coaches, and categories
- **CategoryDetailView**: Shows exercises for a specific category
- **PopularExercisesView**: Displays popular exercises list
- **ExerciseDetailView**: Detailed view of a specific exercise
- **Components**: Reusable UI components (cards, search bar, etc.)

## MVVM Benefits Implemented

### 1. Separation of Concerns
- **Models**: Pure data structures
- **ViewModels**: Business logic and state management
- **Views**: UI presentation only

### 2. Data Binding
- `@Published` properties in ViewModels automatically update the UI
- `@StateObject` and `@ObservedObject` for reactive updates

### 3. Testability
- ViewModels can be tested independently of UI
- Business logic is separated from presentation logic

### 4. Reusability
- ViewModels can be shared across different views
- Components are stateless and reusable

### 5. Maintainability
- Clear separation makes code easier to understand and modify
- Changes to business logic don't affect UI and vice versa

## Key Features

### State Management
- ViewModels use `@Published` properties for reactive state
- Navigation state is managed in ViewModels
- Data filtering and search logic is in ViewModels

### Data Flow
1. Models define data structure
2. ViewModels manage state and business logic
3. Views observe ViewModels and update UI
4. User interactions trigger ViewModel methods

### Navigation
- Sheet presentations are managed by ViewModels
- Navigation state is centralized in ViewModels
- Views only handle UI presentation

## Usage Examples

### HomeView with HomeViewModel
```swift
@StateObject private var viewModel = HomeViewModel()

// In the view body
ForEach(viewModel.exercises) { exercise in
    ExerciseCardView(exercise: exercise)
        .onTapGesture {
            viewModel.selectExercise(exercise)
        }
}
```

### CategoryDetailView with CategoryDetailViewModel
```swift
@StateObject private var viewModel: CategoryDetailViewModel

init(category: Category) {
    self._viewModel = StateObject(wrappedValue: CategoryDetailViewModel(category: category))
}
```

## Future Enhancements
- Add data persistence layer
- Implement network layer for remote data
- Add unit tests for ViewModels
- Implement dependency injection
- Add error handling and loading states 
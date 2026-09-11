# Ebarge Azbazi System

## Overview
Azbazi is Ebarge's educational quiz-game system that transforms textbook content into interactive learning games. It combines gamification elements with educational content to enhance learning engagement.

## Core Components

### Game Structure
- **Azbazi ID**: Unique identifier for each game
- **Book Association**: Games are linked to specific educational books
- **Question Bank**: Collection of questions derived from book content
- **Scoring System**: Points-based evaluation with time factors
- **Achievement Tracking**: Streaks, coins, and progress monitoring

### Key Models
- `AzbaziModel` - Game metadata and progress tracking
- `QuestionModel` - Individual quiz questions with answers
- `UserModel` - Player statistics and achievements

## Game Flow

### 1. Game Creation
- Educators/Content creators design games based on book content
- Questions are generated (manually or AI-assisted)
- Games are published and made available to users

### 2. Game Discovery
- Users browse available games through book interfaces
- Games are filtered by book, difficulty, or popularity
- User progress is tracked per game

### 3. Gameplay Mechanics
- **Question Presentation**: Interactive display of educational questions
- **Answer Submission**: Multiple choice, text input, or drawing responses
- **Hint System**: Progressive hints with coin cost
- **Time Pressure**: Scoring based on response time
- **Streak Bonuses**: Consecutive correct answers reward bonus points

### 4. Scoring and Rewards
- **Base Points**: Points for correct answers
- **Time Bonuses**: Faster responses earn more points
- **Streak Multipliers**: Consecutive correct answers multiply scores
- **Coin Rewards**: Virtual currency for game performance
- **Zafran Economy**: Special currency for premium achievements

## Technical Implementation

### Provider Layer
- `AzbaziProvider` manages game state and data flow
- Handles API communication for game data retrieval
- Manages local database caching of games and questions
- Tracks user progress and performance metrics

### UI Components
- `landingPage.dart` - Game selection and browsing interface
- `gamePage.dart` - Main gameplay screen with question presentation
- `resultPage.dart` - Score display and achievement notification
- Custom widgets for question types and interactive elements

### Data Flow
```
Game Selection 
    ↓
AzbaziProvider.getAzbaziData()
    ↓
API Request: getazbaziqs
    ↓
Question Data Processing
    ↓
Game Initialization
    ↓
Question-by-Question Gameplay
    ↓
Answer Submission → API: azscorerate
    ↓
Score Calculation and Storage
    ↓
Results Display
```

## Question System

### Question Types
- Multiple Choice Questions (MCQ)
- True/False Questions
- Fill-in-the-Blank
- Image-Based Questions
- Drawing/Annotation Questions

### Question Attributes
- **Difficulty Level**: Easy, Medium, Hard classification
- **Subject Matter**: Linked to specific book chapters/pages
- **Learning Objectives**: Educational goals addressed
- **Hint Availability**: Progressive assistance options
- **Time Allocation**: Optimal response time targets

### AI Question Generation
- Automated question creation from book content
- Quality validation before becoming trusted content
- Manual review and editing capabilities
- Difficulty adjustment algorithms

## Game Features

### Virtual Economy Integration
- **Coins**: Earned through gameplay performance
- **Zafran**: Premium currency for special features
- **Time Balance**: Resource for extended gameplay
- **Shop Integration**: Purchase power-ups and customization

### Social Elements
- **Leaderboards**: Ranking based on scores and achievements
- **Friend Competition**: Challenge-based gameplay
- **Achievement Badges**: Milestone recognition
- **Progress Sharing**: Social media integration

### Personalization
- **Adaptive Difficulty**: Questions adjust to user performance
- **Learning Path**: Suggested games based on progress
- **Weakness Identification**: Focus areas based on incorrect answers
- **Custom Avatars**: Personalized player representation

## Technical Debt Issues

### Session Management
- Multiple cookie jars created per API call causing potential inconsistency
- No centralized session handling for game state

### Data Synchronization
- Scattered API calls instead of centralized service
- Inconsistent error handling across game-related operations

### Performance Concerns
- No batch request implementation for question loading
- Potential for repeated API calls during gameplay

## Security Considerations
- Game scores and achievements require validation
- Coin/currency transactions need verification
- No CSRF protection for game-related API calls
- Session management vulnerabilities affect game integrity

## Future Enhancement Opportunities
1. **Advanced Analytics**: Detailed learning pattern analysis
2. **Multiplayer Modes**: Real-time competitive gameplay
3. **Adaptive Learning**: AI-driven personalized question selection
4. **Offline Gameplay**: Cached questions for offline access
5. **Enhanced Graphics**: Improved visual elements and animations
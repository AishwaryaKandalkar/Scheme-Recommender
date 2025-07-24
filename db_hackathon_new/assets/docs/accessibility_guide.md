# Voice Navigation and Accessibility Guide

## Overview

The Scheme Recommender app has been enhanced with comprehensive voice navigation features to make it accessible for blind users and those who prefer hands-free operation. This guide explains how to use these features and how they are integrated throughout the app.

## Main Features

1. **Voice Navigation**: Navigate through the entire app using voice commands
2. **Voice Input**: Use voice to input text in all fields throughout the app
3. **Text-to-Speech**: Have content read aloud automatically
4. **High Contrast UI**: Enhanced visual elements for better visibility
5. **Gesture Recognition**: Simplified touch interactions
6. **Accessibility Labels**: All elements properly labeled for screen readers

## Getting Started

When you first launch the app, you'll be asked if you want to enable voice navigation. This setting can be changed at any time from the welcome screen or from any screen with the voice toggle button (microphone icon in the app bar).

## Common Voice Commands

- **"Help"**: Get assistance and list of available commands
- **"Go back"**: Return to previous screen
- **"Go home"**: Return to main screen
- **"Read this"**: Have the current content read aloud
- **"Toggle voice"**: Turn voice navigation on/off

## Screen-Specific Commands

### Welcome Screen
- **"Login"**: Navigate to login screen
- **"Register"**: Navigate to registration screen
- **"Chatbot"**: Open the AI chatbot

### Chatbot Screen
- **"Send"**: Send the current message
- **"Clear"**: Clear all messages
- **"Read last"**: Read the last message

### Scheme Details Screen
- **"Details"**: Read scheme details
- **"Benefits"**: Read scheme benefits
- **"Eligibility"**: Read eligibility requirements
- **"Apply"**: Start application process

## Voice Input for Text Fields

1. Tap on any text field to focus it
2. Tap the microphone button next to the field
3. Speak clearly after the prompt
4. Your speech will be converted to text and entered in the field

## For Blind Users

The app has been designed with screen reader compatibility in mind:
- All elements have proper semantic labels
- Voice feedback provides context for current location
- Microphone button is always available for navigation
- All information can be accessed via voice commands

## Customizing Accessibility Settings

To customize voice navigation settings:
1. Go to the Welcome Screen
2. Find the "Voice Navigation" card
3. Toggle voice navigation on/off
4. Additional settings are available in your device's accessibility settings

## Technical Implementation

Developers have integrated:
- A dedicated VoiceNavigationService for consistent voice features across the app
- Screen-specific voice commands registration
- Context-aware voice prompts and responses
- Fallback mechanisms for when voice recognition fails

## Feedback

We are committed to continuous improvement of our accessibility features. Please provide feedback about your experience with the voice navigation system to help us make the app more accessible for everyone.

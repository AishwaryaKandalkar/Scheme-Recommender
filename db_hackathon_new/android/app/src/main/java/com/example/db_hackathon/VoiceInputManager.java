package com.example.db_hackathon;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.speech.RecognitionListener;
import android.speech.RecognizerIntent;
import android.speech.SpeechRecognizer;

import java.util.ArrayList;
import java.util.Locale;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class VoiceInputManager implements MethodChannel.MethodCallHandler {
    private final Context context;
    private SpeechRecognizer speechRecognizer;
    private MethodChannel.Result pendingResult;

    public VoiceInputManager(Context context) {
        this.context = context;
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        if (call.method.equals("startVoiceInput")) {
            startVoiceRecognition(result);
        } else {
            result.notImplemented();
        }
    }

    private void startVoiceRecognition(final MethodChannel.Result result) {
        if (!SpeechRecognizer.isRecognitionAvailable(context)) {
            result.error("SPEECH_RECOGNITION_ERROR", "Speech recognition not available", null);
            return;
        }

        // Save the result object to resolve later
        this.pendingResult = result;

        // Create a new speech recognizer
        if (speechRecognizer != null) {
            speechRecognizer.destroy();
        }
        speechRecognizer = SpeechRecognizer.createSpeechRecognizer(context);
        speechRecognizer.setRecognitionListener(new RecognitionListener() {
            @Override
            public void onReadyForSpeech(Bundle bundle) {
                // Speech recognition engine is ready to listen
            }

            @Override
            public void onBeginningOfSpeech() {
                // User has started speaking
            }

            @Override
            public void onRmsChanged(float v) {
                // Sound level changed
            }

            @Override
            public void onBufferReceived(byte[] bytes) {
                // More sound has been received
            }

            @Override
            public void onEndOfSpeech() {
                // User has stopped speaking
            }

            @Override
            public void onError(int errorCode) {
                String errorMessage;
                switch (errorCode) {
                    case SpeechRecognizer.ERROR_AUDIO:
                        errorMessage = "Audio recording error";
                        break;
                    case SpeechRecognizer.ERROR_CLIENT:
                        errorMessage = "Client side error";
                        break;
                    case SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS:
                        errorMessage = "Insufficient permissions";
                        break;
                    case SpeechRecognizer.ERROR_NETWORK:
                        errorMessage = "Network error";
                        break;
                    case SpeechRecognizer.ERROR_NETWORK_TIMEOUT:
                        errorMessage = "Network timeout";
                        break;
                    case SpeechRecognizer.ERROR_NO_MATCH:
                        errorMessage = "No speech input detected";
                        break;
                    case SpeechRecognizer.ERROR_RECOGNIZER_BUSY:
                        errorMessage = "Recognition service busy";
                        break;
                    case SpeechRecognizer.ERROR_SERVER:
                        errorMessage = "Server error";
                        break;
                    case SpeechRecognizer.ERROR_SPEECH_TIMEOUT:
                        errorMessage = "No speech input";
                        break;
                    default:
                        errorMessage = "Unknown error";
                        break;
                }
                if (pendingResult != null) {
                    pendingResult.error("SPEECH_ERROR", errorMessage, null);
                    pendingResult = null;
                }
                cleanup();
            }

            @Override
            public void onResults(Bundle bundle) {
                ArrayList<String> results = bundle.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION);
                if (results != null && !results.isEmpty()) {
                    if (pendingResult != null) {
                        pendingResult.success(results.get(0)); // Return the top result
                        pendingResult = null;
                    }
                } else {
                    if (pendingResult != null) {
                        pendingResult.error("NO_RESULTS", "No speech results available", null);
                        pendingResult = null;
                    }
                }
                cleanup();
            }

            @Override
            public void onPartialResults(Bundle bundle) {
                // Partial recognition results are available
            }

            @Override
            public void onEvent(int i, Bundle bundle) {
                // Reserved for future events
            }
        });

        // Configure speech recognizer intent
        Intent intent = new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH);
        intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM);
        intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE, Locale.getDefault());
        intent.putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 1);
        intent.putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true);
        intent.putExtra(RecognizerIntent.EXTRA_CALLING_PACKAGE, context.getPackageName());

        // Start listening
        try {
            speechRecognizer.startListening(intent);
        } catch (Exception e) {
            if (pendingResult != null) {
                pendingResult.error("START_LISTENING_ERROR", e.getMessage(), null);
                pendingResult = null;
            }
            cleanup();
        }
    }

    private void cleanup() {
        if (speechRecognizer != null) {
            speechRecognizer.destroy();
            speechRecognizer = null;
        }
    }

    public void dispose() {
        cleanup();
    }
}

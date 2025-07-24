package com.example.db_hackathon;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String VOICE_CHANNEL = "voice_channel";
    private VoiceInputManager voiceInputManager;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        
        // Initialize the voice input manager
        voiceInputManager = new VoiceInputManager(this);
        
        // Set up the method channel
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), VOICE_CHANNEL)
                .setMethodCallHandler(voiceInputManager);
    }

    @Override
    protected void onDestroy() {
        if (voiceInputManager != null) {
            voiceInputManager.dispose();
        }
        super.onDestroy();
    }
}

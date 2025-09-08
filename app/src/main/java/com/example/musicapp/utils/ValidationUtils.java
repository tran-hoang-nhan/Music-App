package com.example.musicapp.utils;

import android.text.TextUtils;
import android.util.Patterns;

public class ValidationUtils {
    
    public static boolean isValidEmail(String email) {
        return !TextUtils.isEmpty(email) && Patterns.EMAIL_ADDRESS.matcher(email).matches();
    }
    
    public static boolean isValidPassword(String password) {
        return !TextUtils.isEmpty(password) && password.length() >= 6;
    }
    
    public static boolean isValidName(String name) {
        return !TextUtils.isEmpty(name) && name.trim().length() >= 2 && name.trim().length() <= 50;
    }
    
    public static String sanitizeInput(String input) {
        if (input == null) return "";
        return input.trim().replaceAll("[<>\"'&]", "");
    }
    
    public static boolean isValidSongId(String songId) {
        return !TextUtils.isEmpty(songId) && songId.matches("^[a-zA-Z0-9_-]+$");
    }
}
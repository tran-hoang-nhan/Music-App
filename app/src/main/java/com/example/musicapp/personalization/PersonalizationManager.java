package com.example.musicapp.personalization;

import android.content.Context;
import android.content.SharedPreferences;

import com.example.musicapp.model.Song;

import java.util.HashMap;
import java.util.Map;

public class PersonalizationManager {
    
    private static PersonalizationManager instance;
    private SharedPreferences prefs;

    public enum Theme {
        DARK, LIGHT, AUTO
    }
    
    private static final String PREF_THEME = "theme";
    private static final String PREF_AUTO_PLAY = "auto_play";
    private static final String PREF_LISTENING_TIME = "total_listening_time";
    private static final String PREF_FAVORITE_GENRE = "favorite_genre";
    
    private PersonalizationManager(Context context) {
        Context context1 = context.getApplicationContext();
        this.prefs = context.getSharedPreferences("personalization_prefs", Context.MODE_PRIVATE);
    }
    
    public static synchronized PersonalizationManager getInstance(Context context) {
        if (instance == null) {
            instance = new PersonalizationManager(context);
        }
        return instance;
    }
    
    public void setTheme(Theme theme) {
        prefs.edit().putString(PREF_THEME, theme.name()).apply();
    }
    
    public Theme getTheme() {
        String themeName = prefs.getString(PREF_THEME, Theme.DARK.name());
        return Theme.valueOf(themeName);
    }
    
    public void setAutoPlay(boolean enabled) {
        prefs.edit().putBoolean(PREF_AUTO_PLAY, enabled).apply();
    }
    
    public boolean isAutoPlayEnabled() {
        return prefs.getBoolean(PREF_AUTO_PLAY, true);
    }
    
    public void addListeningTime(long milliseconds) {
        long currentTime = prefs.getLong(PREF_LISTENING_TIME, 0);
        prefs.edit().putLong(PREF_LISTENING_TIME, currentTime + milliseconds).apply();
    }
    
    public long getTotalListeningTime() {
        return prefs.getLong(PREF_LISTENING_TIME, 0);
    }
    
    public String getFormattedListeningTime() {
        long totalMs = getTotalListeningTime();
        long hours = totalMs / (1000 * 60 * 60);
        long minutes = (totalMs % (1000 * 60 * 60)) / (1000 * 60);
        return String.format("%d giờ %d phút", hours, minutes);
    }
    
    public void updateGenrePreference(String genre, int score) {
        String key = "genre_" + genre.toLowerCase();
        int currentScore = prefs.getInt(key, 0);
        prefs.edit().putInt(key, currentScore + score).apply();
        updateFavoriteGenre();
    }
    
    private void updateFavoriteGenre() {
        Map<String, ?> allPrefs = prefs.getAll();
        String favoriteGenre = "";
        int maxScore = 0;
        
        for (Map.Entry<String, ?> entry : allPrefs.entrySet()) {
            if (entry.getKey().startsWith("genre_") && entry.getValue() instanceof Integer) {
                int score = (Integer) entry.getValue();
                if (score > maxScore) {
                    maxScore = score;
                    favoriteGenre = entry.getKey().substring(6);
                }
            }
        }
        
        prefs.edit().putString(PREF_FAVORITE_GENRE, favoriteGenre).apply();
    }
    
    public String getFavoriteGenre() {
        return prefs.getString(PREF_FAVORITE_GENRE, "unknown");
    }
    
    public void recordComplete(Song song) {
        String genre = song.getArtistName().toLowerCase();
        updateGenrePreference(genre, 2);
    }
    
    public void recordSkip(Song song) {
        String genre = song.getArtistName().toLowerCase();
        updateGenrePreference(genre, -1);
    }
    
    public boolean shouldRecommendUpbeat() {
        int hour = java.util.Calendar.getInstance().get(java.util.Calendar.HOUR_OF_DAY);
        return hour >= 6 && hour <= 18;
    }
    
    public Map<String, Object> getUserInsights() {
        Map<String, Object> insights = new HashMap<>();
        insights.put("totalListeningTime", getFormattedListeningTime());
        insights.put("favoriteGenre", getFavoriteGenre());
        insights.put("theme", getTheme().name());
        insights.put("autoPlay", isAutoPlayEnabled());
        return insights;
    }
}
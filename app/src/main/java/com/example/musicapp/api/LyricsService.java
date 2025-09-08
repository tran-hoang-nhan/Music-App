package com.example.musicapp.api;

import java.io.IOException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

public class LyricsService {
    
    private static final String LYRICS_API_URL = "https://api.lyrics.ovh/v1/";
    private final OkHttpClient client;
    private final ExecutorService executor;
    
    public interface LyricsCallback {
        void onSuccess(String lyrics);
        void onError(String error);
    }
    
    public LyricsService() {
        client = new OkHttpClient();
        executor = Executors.newSingleThreadExecutor();
    }
    
    public void getLyrics(String artist, String title, LyricsCallback callback) {
        executor.execute(() -> {
            try {
                String url = LYRICS_API_URL + cleanString(artist) + "/" + cleanString(title);
                Request request = new Request.Builder()
                        .url(url)
                        .build();
                
                Response response = client.newCall(request).execute();
                if (response.isSuccessful()) {
                    String jsonResponse = response.body().string();
                    String lyrics = parseLyrics(jsonResponse);
                    
                    if (lyrics != null && !lyrics.trim().isEmpty()) {
                        callback.onSuccess(lyrics);
                    } else {
                        callback.onError("Lời bài hát không có sẵn");
                    }
                } else {
                    callback.onError("Không thể tải lời bài hát");
                }
            } catch (IOException e) {
                callback.onError("Lỗi kết nối: " + e.getMessage());
            } catch (Exception e) {
                callback.onError("Lỗi không xác định: " + e.getMessage());
            }
        });
    }
    
    private String cleanString(String input) {
        if (input == null) return "";
        return input.trim()
                .replaceAll("[^a-zA-Z0-9\\s]", "")
                .replaceAll("\\s+", "%20");
    }
    
    private String parseLyrics(String jsonResponse) {
        try {
            // Simple JSON parsing for lyrics field
            int startIndex = jsonResponse.indexOf("\"lyrics\":\"");
            if (startIndex == -1) return null;
            
            startIndex += 10; // Length of "lyrics":"
            int endIndex = jsonResponse.lastIndexOf("\"}");
            if (endIndex == -1) return null;
            
            String lyrics = jsonResponse.substring(startIndex, endIndex);
            return lyrics.replace("\\n", "\n").replace("\\r", "");
        } catch (Exception e) {
            return null;
        }
    }
}
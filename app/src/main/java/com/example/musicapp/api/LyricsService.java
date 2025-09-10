package com.example.musicapp.api;

import java.io.IOException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import android.util.Log;

import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

public class LyricsService {
    
    private static final String TAG = "LyricsService";
    private static final String LYRICS_API_URL = "https://api.lyrics.ovh/v1/";
    private static LyricsService instance;
    private final OkHttpClient client;
    private final ExecutorService executor;
    
    public interface LyricsCallback {
        void onSuccess(String lyrics);
        void onError(String error);
    }
    
    private LyricsService() {
        client = new OkHttpClient();
        executor = Executors.newSingleThreadExecutor();
    }
    
    public static synchronized LyricsService getInstance() {
        if (instance == null) {
            instance = new LyricsService();
        }
        return instance;
    }
    
    public void shutdown() {
        if (executor != null && !executor.isShutdown()) {
            executor.shutdown();
        }
    }
    
    public void getLyrics(String artist, String title, LyricsCallback callback) {
        if (artist == null || title == null || artist.trim().isEmpty() || title.trim().isEmpty()) {
            callback.onError("Thông tin bài hát không hợp lệ");
            return;
        }
        
        executor.execute(() -> {
            Response response = null;
            try {
                String encodedArtist = URLEncoder.encode(artist.trim(), StandardCharsets.UTF_8.toString());
                String encodedTitle = URLEncoder.encode(title.trim(), StandardCharsets.UTF_8.toString());
                String url = LYRICS_API_URL + encodedArtist + "/" + encodedTitle;
                
                Request request = new Request.Builder()
                        .url(url)
                        .build();
                
                response = client.newCall(request).execute();
                if (response.isSuccessful() && response.body() != null) {
                    String jsonResponse = response.body().string();
                    String lyrics = parseLyrics(jsonResponse);
                    
                    if (lyrics != null && !lyrics.trim().isEmpty()) {
                        callback.onSuccess(lyrics);
                    } else {
                        callback.onError("Không tìm thấy lời bài hát cho: " + artist + " - " + title);
                    }
                } else {
                    Log.w(TAG, "API response not successful: " + response.code());
                    callback.onError("Không tìm thấy lời bài hát");
                }
            } catch (IOException e) {
                Log.e(TAG, "Network error fetching lyrics", e);
                callback.onError("Lỗi kết nối API lời bài hát");
            } catch (Exception e) {
                Log.e(TAG, "Unexpected error fetching lyrics", e);
                callback.onError("Không thể tải lời bài hát");
            } finally {
                if (response != null) {
                    response.close();
                }
            }
        });
    }
    

    
    private String parseLyrics(String jsonResponse) {
        try {
            // Use proper JSON parsing
            org.json.JSONObject jsonObject = new org.json.JSONObject(jsonResponse);
            if (jsonObject.has("lyrics")) {
                String lyrics = jsonObject.getString("lyrics");
                if (lyrics != null && !lyrics.trim().isEmpty()) {
                    return lyrics.replace("\\n", "\n")
                                .replace("\\r", "")
                                .trim();
                }
            }
        } catch (org.json.JSONException e) {
            Log.e(TAG, "JSON parsing error, trying fallback", e);
            // Fallback to manual parsing
            try {
                int startIndex = jsonResponse.indexOf("\"lyrics\":\"");
                if (startIndex != -1) {
                    startIndex += 10;
                    int endIndex = jsonResponse.lastIndexOf("\"}");
                    if (endIndex > startIndex) {
                        String lyrics = jsonResponse.substring(startIndex, endIndex);
                        return lyrics.replace("\\n", "\n").replace("\\r", "");
                    }
                }
            } catch (Exception fallbackError) {
                Log.e(TAG, "Fallback parsing failed", fallbackError);
            }
        } catch (Exception e) {
            Log.e(TAG, "Error parsing lyrics", e);
        }
        return null;
    }
}
package com.example.musicapp.recommendation;

import android.content.Context;
import android.content.SharedPreferences;

import com.example.musicapp.model.Song;
import com.example.musicapp.player.MusicPlayerManager;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;

public class MusicRecommendationEngine {
    
    private static MusicRecommendationEngine instance;
    private SharedPreferences prefs;
    private MusicPlayerManager playerManager;
    
    // Scoring weights
    private static final float GENRE_WEIGHT = 0.4f;
    private static final float ARTIST_WEIGHT = 0.3f;
    private static final float RECENT_WEIGHT = 0.2f;
    private static final float FAVORITE_WEIGHT = 0.1f;
    
    private MusicRecommendationEngine(Context context) {
        Context context1 = context.getApplicationContext();
        this.prefs = context.getSharedPreferences("recommendation_prefs", Context.MODE_PRIVATE);
        this.playerManager = MusicPlayerManager.getInstance(context);
    }
    
    public static synchronized MusicRecommendationEngine getInstance(Context context) {
        if (instance == null) {
            instance = new MusicRecommendationEngine(context);
        }
        return instance;
    }
    
    public List<Song> getRecommendations(List<Song> allSongs, int limit) {
        if (allSongs == null || allSongs.isEmpty()) return new ArrayList<>();
        
        List<Song> recentlyPlayed = playerManager.getRecentlyPlayed();
        List<Song> favorites = playerManager.getFavorites();
        Song currentSong = playerManager.getCurrentSong();
        
        Map<Song, Float> scores = new HashMap<>();
        
        // Score all songs
        for (Song song : allSongs) {
            if (isAlreadyInUserLibrary(song, recentlyPlayed, favorites)) continue;
            
            float score = calculateScore(song, currentSong, recentlyPlayed, favorites);
            scores.put(song, score);
        }
        
        // Sort by score and return top recommendations
        List<Map.Entry<Song, Float>> sortedEntries = new ArrayList<>(scores.entrySet());
        Collections.sort(sortedEntries, (a, b) -> Float.compare(b.getValue(), a.getValue()));
        
        List<Song> recommendations = new ArrayList<>();
        for (int i = 0; i < Math.min(limit, sortedEntries.size()); i++) {
            recommendations.add(sortedEntries.get(i).getKey());
        }
        
        return recommendations;
    }
    
    private float calculateScore(Song song, Song currentSong, List<Song> recentlyPlayed, List<Song> favorites) {
        float score = 0f;
        
        // Genre similarity
        score += calculateGenreScore(song, currentSong, recentlyPlayed) * GENRE_WEIGHT;
        
        // Artist similarity
        score += calculateArtistScore(song, currentSong, recentlyPlayed, favorites) * ARTIST_WEIGHT;
        
        // Recent listening patterns
        score += calculateRecentScore(song, recentlyPlayed) * RECENT_WEIGHT;
        
        // Favorite patterns
        score += calculateFavoriteScore(song, favorites) * FAVORITE_WEIGHT;
        
        // Add some randomness to avoid repetitive recommendations
        score += new Random().nextFloat() * 0.1f;
        
        return score;
    }
    
    private float calculateGenreScore(Song song, Song currentSong, List<Song> recentlyPlayed) {
        Map<String, Integer> genreFrequency = new HashMap<>();
        
        // Count genre frequency from recent plays
        for (Song recentSong : recentlyPlayed) {
            String genre = extractGenre(recentSong);
            Integer count = genreFrequency.get(genre);
            genreFrequency.put(genre, (count != null ? count : 0) + 1);
        }
        
        // Add current song genre with higher weight
        if (currentSong != null) {
            String currentGenre = extractGenre(currentSong);
            Integer count = genreFrequency.get(currentGenre);
            genreFrequency.put(currentGenre, (count != null ? count : 0) + 3);
        }
        
        String songGenre = extractGenre(song);
        Integer count = genreFrequency.get(songGenre);
        return (count != null ? count : 0) / (float) Math.max(1, recentlyPlayed.size());
    }
    
    private float calculateArtistScore(Song song, Song currentSong, List<Song> recentlyPlayed, List<Song> favorites) {
        Map<String, Integer> artistFrequency = new HashMap<>();
        
        // Count artist frequency
        for (Song recentSong : recentlyPlayed) {
            String artist = recentSong.getArtistName();
            Integer count = artistFrequency.get(artist);
            artistFrequency.put(artist, (count != null ? count : 0) + 1);
        }
        
        for (Song favSong : favorites) {
            String artist = favSong.getArtistName();
            Integer count = artistFrequency.get(artist);
            artistFrequency.put(artist, (count != null ? count : 0) + 2);
        }
        
        if (currentSong != null && song.getArtistName().equals(currentSong.getArtistName())) {
            return 1.0f; // Same artist as current song
        }
        
        Integer count = artistFrequency.get(song.getArtistName());
        return (count != null ? count : 0) / (float) Math.max(1, recentlyPlayed.size() + favorites.size());
    }
    
    private float calculateRecentScore(Song song, List<Song> recentlyPlayed) {
        // Boost songs similar to recently played
        for (int i = 0; i < Math.min(5, recentlyPlayed.size()); i++) {
            Song recentSong = recentlyPlayed.get(i);
            if (isSimilar(song, recentSong)) {
                return (5 - i) / 5.0f; // More recent = higher score
            }
        }
        return 0f;
    }
    
    private float calculateFavoriteScore(Song song, List<Song> favorites) {
        // Boost songs similar to favorites
        int similarCount = 0;
        for (Song favSong : favorites) {
            if (isSimilar(song, favSong)) {
                similarCount++;
            }
        }
        return similarCount / (float) Math.max(1, favorites.size());
    }
    
    private boolean isSimilar(Song song1, Song song2) {
        // Simple similarity check
        return song1.getArtistName().equals(song2.getArtistName()) ||
               extractGenre(song1).equals(extractGenre(song2));
    }
    
    private String extractGenre(Song song) {
        // Use artist name as genre fallback since Song doesn't have getTags()
        return song.getArtistName().toLowerCase();
    }
    
    private boolean isAlreadyInUserLibrary(Song song, List<Song> recentlyPlayed, List<Song> favorites) {
        return recentlyPlayed.contains(song) || favorites.contains(song);
    }
    
    // Personalization methods
    public void updateUserPreferences(Song song, String action) {
        String key = "pref_" + extractGenre(song);
        int currentScore = prefs.getInt(key, 0);
        
        switch (action) {
            case "play":
                currentScore += 1;
                break;
            case "favorite":
                currentScore += 5;
                break;
            case "skip":
                currentScore -= 1;
                break;
        }
        
        prefs.edit().putInt(key, Math.max(0, currentScore)).apply();
    }
    
    public List<Song> getPersonalizedRecommendations(List<Song> allSongs, int limit) {
        List<Song> recommendations = getRecommendations(allSongs, limit * 2);
        
        // Apply personalization boost
        Map<Song, Float> personalizedScores = new HashMap<>();
        for (Song song : recommendations) {
            String genre = extractGenre(song);
            int preference = prefs.getInt("pref_" + genre, 0);
            float boost = preference / 100.0f; // Convert to 0-1 range
            personalizedScores.put(song, boost);
        }
        
        // Sort by personalized scores
        Collections.sort(recommendations, (a, b) -> {
            Float scoreA = personalizedScores.get(a);
            Float scoreB = personalizedScores.get(b);
            return Float.compare(scoreB != null ? scoreB : 0f, scoreA != null ? scoreA : 0f);
        });
        
        return recommendations.subList(0, Math.min(limit, recommendations.size()));
    }
}
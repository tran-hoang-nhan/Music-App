package com.example.musicapp.storage;

import android.content.Context;

import androidx.annotation.NonNull;

import com.example.musicapp.database.AppDatabase;
import com.example.musicapp.model.Song;
import com.example.musicapp.repository.MusicRepository;
import com.example.musicapp.utils.ValidationUtils;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class FavoritesManager {
    
    private static FavoritesManager instance;
    private FirebaseAuth auth;
    private DatabaseReference database;
    private List<Song> favorites = new ArrayList<>();
    private OnFavoritesChangeListener listener;
    private MusicRepository repository;
    private boolean isUpdating = false;
    
    public interface OnFavoritesChangeListener {
        void onFavoritesLoaded(List<Song> favorites);
        void onFavoriteAdded(Song song);
        void onFavoriteRemoved(Song song);
    }
    
    public interface OnFavoritesLoadedCallback {
        void onLoaded();
    }
    
    private FavoritesManager(Context context) {
        Context context1 = context.getApplicationContext();
        this.auth = FirebaseAuth.getInstance();
        this.database = FirebaseDatabase.getInstance("https://dacn-8a822-default-rtdb.asia-southeast1.firebasedatabase.app/").getReference();
        
        // Initialize Repository for sync
        AppDatabase db = AppDatabase.getDatabase(context);
        com.example.musicapp.api.ApiService apiService = com.example.musicapp.network.RetrofitClient.getClient().create(com.example.musicapp.api.ApiService.class);
        this.repository = MusicRepository.getInstance(db, apiService);
        
        loadFavorites();
    }
    
    public static synchronized FavoritesManager getInstance(Context context) {
        if (instance == null) {
            instance = new FavoritesManager(context);
        }
        // Always ensure favorites are loaded for current user
        instance.ensureFavoritesLoaded();
        return instance;
    }
    
    // Force reload favorites (call from MainActivity.onCreate)
    public void forceReloadFavorites() {
        String userId = getCurrentUserId();
        android.util.Log.d("FavoritesManager", "forceReloadFavorites - userId: " + userId);
        if (!"guest".equals(userId)) {
            isUpdating = false; // Reset flag
            loadFavorites();
        } else {
            android.util.Log.w("FavoritesManager", "User is guest, cannot load favorites");
        }
    }
    
    private void ensureFavoritesLoaded() {
        String currentUserId = getCurrentUserId();
        if (!"guest".equals(currentUserId)) {
            loadFavorites();
        }
    }
    
    // Force reload favorites and callback when done
    public void loadFavoritesWithCallback(OnFavoritesLoadedCallback callback) {
        String userId = getCurrentUserId();
        if ("guest".equals(userId)) {
            if (callback != null) callback.onLoaded();
            return;
        }
        
        database.child("users").child(userId).child("favorites")
            .get()
            .addOnSuccessListener(snapshot -> {
                favorites.clear();
                for (DataSnapshot child : snapshot.getChildren()) {
                    Song song = parseSongFromSnapshot(child);
                    if (song != null) {
                        favorites.add(song);
                    }
                }
                android.util.Log.d("FavoritesManager", "Loaded " + favorites.size() + " favorites");
                if (callback != null) callback.onLoaded();
            })
            .addOnFailureListener(e -> {
                android.util.Log.e("FavoritesManager", "Failed to load favorites", e);
                if (callback != null) callback.onLoaded();
            });
    }
    
    public void setOnFavoritesChangeListener(OnFavoritesChangeListener listener) {
        this.listener = listener;
    }
    
    private String getCurrentUserId() {
        FirebaseUser user = auth.getCurrentUser();
        String userId = user != null ? user.getUid() : "guest";
        android.util.Log.d("FavoritesManager", "getCurrentUserId: " + userId + ", user: " + (user != null ? user.getEmail() : "null"));
        return userId;
    }
    
    public void addFavorite(Song song) {
        if (song == null || isFavorite(song)) return;
        
        // Validate song data
        if (!ValidationUtils.isValidSongId(song.getId())) {
            android.util.Log.w("FavoritesManager", "Invalid song ID");
            return;
        }
        
        String userId = getCurrentUserId();
        android.util.Log.d("FavoritesManager", "Adding favorite for user: " + userId + ", song: " + song.getName());
        if ("guest".equals(userId)) {
            android.util.Log.w("FavoritesManager", "User not logged in, cannot add favorite");
            return;
        }
        
        String favoritePath = "users/" + userId + "/favorites/" + song.getId();
        android.util.Log.d("FavoritesManager", "Adding to Firebase path: " + favoritePath);
        
        String songId = song.getId();
        Map<String, Object> songData = new HashMap<>();
        songData.put("id", ValidationUtils.sanitizeInput(song.getId()));
        songData.put("name", ValidationUtils.sanitizeInput(song.getName()));
        songData.put("artistName", ValidationUtils.sanitizeInput(song.getArtistName()));
        songData.put("artistId", ValidationUtils.sanitizeInput(song.getArtistId()));
        songData.put("imageUrl", song.getImageUrl());
        songData.put("audioUrl", song.getAudioUrl());
        songData.put("duration", song.getDuration());
        songData.put("timestamp", System.currentTimeMillis());
        
        database.child("users").child(userId).child("favorites").child(songId)
            .setValue(songData)
            .addOnSuccessListener(aVoid -> {
                android.util.Log.d("FavoritesManager", "Successfully added favorite: " + song.getName());
                isUpdating = true;
                favorites.add(song);
                
                // Sync with Repository
                if (repository != null) {
                    repository.updateFavoriteStatus(songId, true);
                }
                
                if (listener != null) listener.onFavoriteAdded(song);
                
                // Reset updating flag after delay
                new android.os.Handler().postDelayed(() -> isUpdating = false, 2000);
            })
            .addOnFailureListener(e -> android.util.Log.e("FavoritesManager", "Failed to add favorite", e));
    }
    
    public void removeFavorite(Song song) {
        if (song == null || !isFavorite(song)) return;
        
        String userId = getCurrentUserId();
        if ("guest".equals(userId)) return;
        
        database.child("users").child(userId).child("favorites").child(song.getId())
            .removeValue()
            .addOnSuccessListener(aVoid -> {
                isUpdating = true;
                favorites.remove(song);
                
                // Sync with Repository
                if (repository != null) {
                    repository.updateFavoriteStatus(song.getId(), false);
                }
                
                if (listener != null) listener.onFavoriteRemoved(song);
                
                // Reset updating flag after delay
                new android.os.Handler().postDelayed(() -> isUpdating = false, 2000);
            });
    }
    
    public void toggleFavorite(Song song) {
        if (isFavorite(song)) {
            removeFavorite(song);
        } else {
            addFavorite(song);
        }
    }
    
    public boolean isFavorite(Song song) {
        if (song == null) return false;
        for (Song fav : favorites) {
            if (fav.getId().equals(song.getId())) {
                return true;
            }
        }
        return false;
    }
    
    public List<Song> getFavorites() {
        return new ArrayList<>(favorites);
    }
    
    public int getFavoritesCount() {
        return favorites.size();
    }
    
    private void loadFavorites() {
        String userId = getCurrentUserId();
        if ("guest".equals(userId)) {
            android.util.Log.w("FavoritesManager", "Cannot load favorites - user is guest");
            return;
        }
        
        String path = "users/" + userId + "/favorites";
        android.util.Log.d("FavoritesManager", "Loading favorites from path: " + path);
        
        // Use single read instead of ValueEventListener to avoid UI override
        database.child("users").child(userId).child("favorites")
            .get()
            .addOnSuccessListener(snapshot -> {
                android.util.Log.d("FavoritesManager", "Firebase snapshot exists: " + snapshot.exists());
                android.util.Log.d("FavoritesManager", "Firebase snapshot children count: " + snapshot.getChildrenCount());
                
                favorites.clear();
                for (DataSnapshot child : snapshot.getChildren()) {
                    android.util.Log.d("FavoritesManager", "Processing child: " + child.getKey());
                    Song song = parseSongFromSnapshot(child);
                    if (song != null) {
                        favorites.add(song);
                        android.util.Log.d("FavoritesManager", "Added song: " + song.getName());
                    }
                }
                android.util.Log.d("FavoritesManager", "Loaded " + favorites.size() + " favorites from Firebase");
                if (listener != null) {
                    listener.onFavoritesLoaded(favorites);
                }
            })
            .addOnFailureListener(e -> {
                android.util.Log.e("FavoritesManager", "Failed to load favorites from path: " + path, e);
            });
    }
    
    private Song parseSongFromSnapshot(DataSnapshot snapshot) {
        try {
            String id = getStringValue(snapshot, "id");
            String name = getStringValue(snapshot, "name");
            String artistName = getStringValue(snapshot, "artistName");
            String artistId = getStringValue(snapshot, "artistId");
            String imageUrl = getStringValue(snapshot, "imageUrl");
            String audioUrl = getStringValue(snapshot, "audioUrl");
            String duration = getStringValue(snapshot, "duration");
            
            return new Song(id, name, artistName, artistId, imageUrl, audioUrl, duration);
        } catch (Exception e) {
            android.util.Log.e("FavoritesManager", "Error parsing song", e);
            return null;
        }
    }
    
    private String getStringValue(DataSnapshot snapshot, String key) {
        Object value = snapshot.child(key).getValue();
        if (value == null) return "";
        return String.valueOf(value); // Convert any type to String
    }
    
    public void clearFavorites() {
        String userId = getCurrentUserId();
        if ("guest".equals(userId)) return;
        
        database.child("users").child(userId).child("favorites").removeValue();
        favorites.clear();
    }
}
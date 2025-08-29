package com.example.musicapp.ui.library;

import android.util.Log;
import androidx.annotation.NonNull;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.example.musicapp.model.Playlist;
import com.example.musicapp.model.Song;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.List;

public class LibraryViewModel extends ViewModel {

    private final MutableLiveData<List<Playlist>> playlists = new MutableLiveData<>();
    private final MutableLiveData<String> error = new MutableLiveData<>();
    
    private final DatabaseReference database;
    private final FirebaseAuth auth;

    public LibraryViewModel() {
        FirebaseDatabase firebaseDatabase = FirebaseDatabase.getInstance("https://dacn-8a822-default-rtdb.asia-southeast1.firebasedatabase.app");
        database = firebaseDatabase.getReference();
        auth = FirebaseAuth.getInstance();
        Log.d("LibraryViewModel", "Firebase initialized with Asia Southeast region");
    }

    public void testFirebaseConnection() {
        String userId = getCurrentUserId();
        if (userId != null) {
            database.child("test").setValue("connection_test")
                    .addOnSuccessListener(aVoid -> Log.d("LibraryViewModel", "Firebase connection successful"))
                    .addOnFailureListener(e -> Log.e("LibraryViewModel", "Firebase connection failed: " + e.getMessage()));
        }
    }

    public LiveData<List<Playlist>> getPlaylists() {
        return playlists;
    }

    public LiveData<String> getError() {
        return error;
    }

    public void loadUserPlaylists() {
        String userId = getCurrentUserId();
        if (userId == null) {
            error.setValue("User not logged in");
            return;
        }

        database.child("users").child(userId).child("playlists")
                .addValueEventListener(new ValueEventListener() {
                    @Override
                    public void onDataChange(@NonNull DataSnapshot snapshot) {
                        List<Playlist> playlistList = new ArrayList<>();
                        for (DataSnapshot child : snapshot.getChildren()) {
                            Playlist playlist = child.getValue(Playlist.class);
                            if (playlist != null) {
                                playlist.setId(child.getKey());
                                playlistList.add(playlist);
                            }
                        }
                        playlists.setValue(playlistList);
                    }

                    @Override
                    public void onCancelled(@NonNull DatabaseError error) {
                        LibraryViewModel.this.error.setValue(error.getMessage());
                    }
                });
    }

    public void createPlaylist(String name) {
        String userId = getCurrentUserId();
        Log.d("LibraryViewModel", "Creating playlist for user: " + userId);
        
        if (userId == null) {
            error.setValue("User not logged in");
            Log.e("LibraryViewModel", "User not logged in");
            return;
        }

        String playlistId = database.child("users").child(userId).child("playlists").push().getKey();
        if (playlistId == null) {
            error.setValue("Failed to generate playlist ID");
            return;
        }

        Playlist playlist = new Playlist(playlistId, name, new ArrayList<>());
        Log.d("LibraryViewModel", "Saving playlist: " + name + " with ID: " + playlistId);
        
        database.child("users").child(userId).child("playlists").child(playlistId)
                .setValue(playlist)
                .addOnSuccessListener(aVoid -> {
                    Log.d("LibraryViewModel", "Playlist created successfully");
                })
                .addOnFailureListener(e -> {
                    Log.e("LibraryViewModel", "Failed to create playlist: " + e.getMessage());
                    error.setValue("Failed to create playlist: " + e.getMessage());
                });
    }

    public void addSongToPlaylist(String playlistId, Song song) {
        String userId = getCurrentUserId();
        if (userId == null) {
            error.setValue("User not logged in");
            return;
        }

        database.child("users").child(userId).child("playlists").child(playlistId).child("songs")
                .push().setValue(song)
                .addOnSuccessListener(aVoid -> {
                    // Success handled by listener
                })
                .addOnFailureListener(e -> error.setValue("Failed to add song to playlist"));
    }

    private String getCurrentUserId() {
        if (auth.getCurrentUser() != null) {
            String uid = auth.getCurrentUser().getUid();
            Log.d("LibraryViewModel", "Current user ID: " + uid);
            return uid;
        }
        Log.e("LibraryViewModel", "No current user found");
        return null;
    }
}
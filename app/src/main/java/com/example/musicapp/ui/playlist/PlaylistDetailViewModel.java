package com.example.musicapp.ui.playlist;

import androidx.annotation.NonNull;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.example.musicapp.model.Song;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.List;

public class PlaylistDetailViewModel extends ViewModel {

    private final MutableLiveData<List<Song>> songs = new MutableLiveData<>();
    private final DatabaseReference database;
    private final FirebaseAuth auth;

    public PlaylistDetailViewModel() {
        FirebaseDatabase firebaseDatabase = FirebaseDatabase.getInstance("https://dacn-8a822-default-rtdb.asia-southeast1.firebasedatabase.app");
        database = firebaseDatabase.getReference();
        auth = FirebaseAuth.getInstance();
    }

    public LiveData<List<Song>> getSongs() {
        return songs;
    }

    public void loadPlaylistSongs(String playlistId) {
        String userId = getCurrentUserId();
        if (userId == null) return;

        database.child("users").child(userId).child("playlists").child(playlistId)
                .addValueEventListener(new ValueEventListener() {
                    @Override
                    public void onDataChange(@NonNull DataSnapshot snapshot) {
                        com.example.musicapp.model.Playlist playlist = snapshot.getValue(com.example.musicapp.model.Playlist.class);
                        if (playlist != null) {
                            songs.setValue(playlist.getSongsList());
                        } else {
                            songs.setValue(new ArrayList<>());
                        }
                    }

                    @Override
                    public void onCancelled(@NonNull DatabaseError error) {
                        // Handle error
                    }
                });
    }

    private String getCurrentUserId() {
        return auth.getCurrentUser() != null ? auth.getCurrentUser().getUid() : null;
    }
}
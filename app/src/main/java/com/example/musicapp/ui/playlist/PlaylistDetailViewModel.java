package com.example.musicapp.ui.playlist;

import android.util.Log;

import androidx.annotation.NonNull;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.example.musicapp.api.ApiService;
import com.example.musicapp.model.Song;
import com.example.musicapp.model.SongResponse;
import com.example.musicapp.network.RetrofitClient;

import java.util.ArrayList;
import java.util.List;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class PlaylistDetailViewModel extends ViewModel {

    private final MutableLiveData<List<Song>> songs = new MutableLiveData<>();

    public LiveData<List<Song>> getSongs() {
        return songs;
    }

    public void loadPlaylistSongs(String playlistName) {
        Log.d("PlaylistDetail", "Loading songs for playlist: " + playlistName);
        
        ApiService apiService = RetrofitClient.getClient().create(ApiService.class);
        Call<SongResponse> call = apiService.getPlaylistTracks(
                ApiService.CLIENT_ID,
                "json",
                50,
                playlistName,
                "albumtrack"
        );

        call.enqueue(new Callback<>() {
            @Override
            public void onResponse(@NonNull Call<SongResponse> call, @NonNull Response<SongResponse> response) {
                if (response.isSuccessful() && response.body() != null) {
                    List<Song> songsList = response.body().getResults();
                    songs.setValue(songsList);
                } else {
                    songs.setValue(new ArrayList<>());
                }
            }

            @Override
            public void onFailure(@NonNull Call<SongResponse> call, @NonNull Throwable t) {
                songs.setValue(new ArrayList<>());
            }
        });
    }
}
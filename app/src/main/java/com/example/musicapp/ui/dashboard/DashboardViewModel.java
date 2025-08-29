package com.example.musicapp.ui.dashboard;

import androidx.annotation.NonNull;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.example.musicapp.api.ApiService;
import com.example.musicapp.model.ArtistResponse;
import com.example.musicapp.model.PlaylistResponse;
import com.example.musicapp.model.Song;
import com.example.musicapp.model.SongResponse;
import com.example.musicapp.network.RetrofitClient;

import java.util.List;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class DashboardViewModel extends ViewModel {

    private static final String CLIENT_ID = "923ff030";
    private static final String FORMAT = "json";
    private static final int LIMIT = 20;


    private final ApiService apiService = RetrofitClient.getClient().create(ApiService.class);
    private final MutableLiveData<List<Song>> topHits = new MutableLiveData<>();
    private final MutableLiveData<List<Song>> randomTracks = new MutableLiveData<>();
    private final MutableLiveData<List<ArtistResponse.Artist>> topArtists = new MutableLiveData<>();
    private final MutableLiveData<List<PlaylistResponse.Playlist>> playlists = new MutableLiveData<>();


    public LiveData<List<Song>> getTopHits() { return topHits; }
    public LiveData<List<Song>> getRandomTracks() { return randomTracks; }
    public LiveData<List<ArtistResponse.Artist>> getTopArtists() { return topArtists; }
    public LiveData<List<PlaylistResponse.Playlist>> getPlaylists() { return playlists; }


    public void fetchTopHits() {
        apiService.getTopHits(CLIENT_ID, FORMAT, LIMIT, "popularity_total")
                .enqueue(new Callback<>() {
                    @Override
                    public void onResponse(@NonNull Call<SongResponse> call, @NonNull Response<SongResponse> response) {
                        if (response.isSuccessful() && response.body() != null) {
                            topHits.setValue(response.body().getResults());
                        }
                    }

                    @Override
                    public void onFailure(@NonNull Call<SongResponse> call, @NonNull Throwable t) {}
                });
    }

    public void fetchRandomTracks() {
        apiService.getRandomTracks(CLIENT_ID, FORMAT, LIMIT, "relevance")
                .enqueue(new Callback<>() {
                    @Override
                    public void onResponse(@NonNull Call<SongResponse> call, @NonNull Response<SongResponse> response) {
                        if (response.isSuccessful() && response.body() != null) {
                            randomTracks.setValue(response.body().getResults());
                        }
                    }

                    @Override
                    public void onFailure(@NonNull Call<SongResponse> call, @NonNull Throwable t) {}
                });
    }

    public void fetchPlaylists() {
        ApiService apiService = RetrofitClient.getClient().create(ApiService.class);
        apiService.getPlaylists("923ff030", "creationdate_asc",10).enqueue(new Callback<>() {
            @Override
            public void onResponse(@NonNull Call<PlaylistResponse> call, @NonNull Response<PlaylistResponse> response) {
                if (response.isSuccessful() && response.body() != null) {
                    playlists.setValue(response.body().getResults());
                }
            }

            @Override
            public void onFailure(@NonNull Call<PlaylistResponse> call, @NonNull Throwable t) {
                // handle error
            }
        });
    }

    public void fetchTopArtists() {
        apiService.getTopArtists(CLIENT_ID, FORMAT, LIMIT, "popularity_total")
                .enqueue(new Callback<>() {
                    @Override
                    public void onResponse(@NonNull Call<ArtistResponse> call, @NonNull Response<ArtistResponse> response) {
                        if (response.isSuccessful() && response.body() != null) {
                            topArtists.setValue(response.body().getArtists());
                        }
                    }
                    @Override
                    public void onFailure(@NonNull Call<ArtistResponse> call, @NonNull Throwable t) {}
                });
    }


    // Gọi tất cả API cùng lúc
    public void fetchAll() {
        fetchTopHits();
        fetchRandomTracks();
        fetchPlaylists();
        fetchTopArtists();
    }
}

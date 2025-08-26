package com.example.musicapp.ui.artist;

import androidx.annotation.NonNull;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.example.musicapp.api.ApiService;
import com.example.musicapp.model.AlbumResponse;
import com.example.musicapp.model.Song;
import com.example.musicapp.model.SongResponse;
import com.example.musicapp.network.RetrofitClient;

import java.util.List;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class ArtistViewModel extends ViewModel {

    private final MutableLiveData<List<Song>> topSongsLiveData = new MutableLiveData<>();
    private final MutableLiveData<List<AlbumResponse.Album>> albumsLiveData = new MutableLiveData<>();
    private final MutableLiveData<Boolean> loading = new MutableLiveData<>(false);

    public LiveData<List<Song>> getTopSongs() {
        return topSongsLiveData;
    }

    public LiveData<List<AlbumResponse.Album>> getAlbums() {
        return albumsLiveData;
    }

    public LiveData<Boolean> isLoading() {
        return loading;
    }

    public void loadArtistData(String artistName) {
        loading.setValue(true);

        ApiService apiService = RetrofitClient.getClient().create(ApiService.class);

        // load top songs
        apiService.getTracksByArtist(ApiService.CLIENT_ID, artistName, "json", 10, "popularity_total")
                .enqueue(new Callback<>() {
                    @Override
                    public void onResponse(@NonNull Call<SongResponse> call, @NonNull Response<SongResponse> response) {
                        if (response.isSuccessful() && response.body() != null) {
                            topSongsLiveData.setValue(response.body().getResults());
                        }
                        loading.setValue(false);
                    }

                    @Override
                    public void onFailure(@NonNull Call<SongResponse> call, @NonNull Throwable t) {
                        loading.setValue(false);
                        t.printStackTrace();
                    }
                });

        // load albums
        apiService.getAlbumsByArtist(ApiService.CLIENT_ID, artistName, "json", 10, "releasedate")
                .enqueue(new Callback<>() {
                    @Override
                    public void onResponse(@NonNull Call<AlbumResponse> call, @NonNull Response<AlbumResponse> response) {
                        if (response.isSuccessful() && response.body() != null) {
                            albumsLiveData.setValue(response.body().getAlbums());
                        }
                    }

                    @Override
                    public void onFailure(@NonNull Call<AlbumResponse> call, @NonNull Throwable t) {
                        t.printStackTrace();
                    }
                });
    }
}

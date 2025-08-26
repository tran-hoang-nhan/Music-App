package com.example.musicapp.ui.album;

import androidx.annotation.NonNull;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.example.musicapp.api.ApiService;
import com.example.musicapp.model.AlbumResponse;
import com.example.musicapp.model.Song;
import com.example.musicapp.network.RetrofitClient;

import java.util.List;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class AlbumViewModel extends ViewModel {
    private final MutableLiveData<AlbumResponse.Album> albumLiveData = new MutableLiveData<>();
    private final MutableLiveData<List<Song>> tracksLiveData = new MutableLiveData<>();
    private final MutableLiveData<Boolean> loading = new MutableLiveData<>(false);

    public LiveData<AlbumResponse.Album> getAlbum() {
        return albumLiveData;
    }

    public LiveData<List<Song>> getTracks() {
        return tracksLiveData;
    }

    public LiveData<Boolean> isLoading() {
        return loading;
    }

    public void loadAlbum(String albumId) {
        loading.setValue(true);

        ApiService apiService = RetrofitClient.getClient().create(ApiService.class);

        Call<AlbumResponse> call = apiService.getAlbumTracks(
                ApiService.CLIENT_ID, "json", albumId, "track_id_desc", "mp32"
        );

        call.enqueue(new Callback<>() {
            @Override
            public void onResponse(@NonNull Call<AlbumResponse> call, @NonNull Response<AlbumResponse> response) {
                loading.setValue(false);
                if (response.isSuccessful() && response.body() != null) {
                    List<AlbumResponse.Album> albums = response.body().getAlbums();
                    if (albums != null && !albums.isEmpty()) {
                        AlbumResponse.Album album = albums.get(0);
                        albumLiveData.setValue(album);

                        List<Song> songs = album.getTracks();
                        if (songs != null) {
                            for (Song song : songs) {
                                song.setArtistName(album.getArtistName());
                                song.setImageUrl(album.getImage());
                            }
                        }
                        tracksLiveData.setValue(songs);
                    }
                }
            }

            @Override
            public void onFailure(@NonNull Call<AlbumResponse> call, @NonNull Throwable t) {
                loading.setValue(false);
                t.printStackTrace();
            }
        });
    }
}

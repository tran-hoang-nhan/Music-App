package com.example.musicapp.api;

import com.example.musicapp.model.ArtistResponse;
import com.example.musicapp.model.SongResponse;
import com.example.musicapp.model.AlbumResponse;

import retrofit2.Call;
import retrofit2.http.GET;
import retrofit2.http.Query;

public interface ApiService {
    String CLIENT_ID = "923ff030";

    @GET("tracks/")
    Call<SongResponse> getTopHits(
            @Query("client_id") String clientId,
            @Query("format") String format,
            @Query("limit") int limit,
            @Query("order") String order
    );

    // Album mới phát hành
    @GET("albums/")
    Call<AlbumResponse> getNewAlbums(
            @Query("client_id") String clientId,
            @Query("format") String format,
            @Query("limit") int limit,
            @Query("order") String order
    );

    @GET("tracks/")
    Call<SongResponse> getByGenre(
            @Query("client_id") String clientId,
            @Query("format") String format,
            @Query("limit") int limit,
            @Query("order") String order,
            @Query("fuzzytags") String genre
    );

    @GET("tracks/")
    Call<SongResponse> getRandomTracks(
            @Query("client_id") String clientId,
            @Query("format") String format,
            @Query("limit") int limit,
            @Query("order") String order
    );
    @GET("artists/")
    Call<ArtistResponse> getTopArtists(
            @Query("client_id") String clientId,
            @Query("format") String format,
            @Query("limit") int limit,
            @Query("order") String order
    );
}

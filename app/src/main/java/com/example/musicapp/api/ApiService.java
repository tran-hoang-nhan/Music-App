package com.example.musicapp.api;

import com.example.musicapp.model.ArtistResponse;
import com.example.musicapp.model.SearchResponse;
import com.example.musicapp.model.Song;
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
    @GET("albums/tracks/")
    Call<AlbumResponse  > getAlbumTracks(
            @Query("client_id") String clientId,
            @Query("format") String format,
            @Query("id") String albumId,
            @Query("order") String order,
            @Query("audioformat") String audioFormat
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
    // Tracks by artist
    @GET("tracks/")
    Call<SongResponse> getTracksByArtist(
            @Query("client_id") String clientId,
            @Query("artist_name") String artistName, // đổi từ artist_id -> artist_name
            @Query("format") String format,
            @Query("limit") int limit,
            @Query("order") String order
    );

    // Albums by artist
    @GET("albums/")
    Call<AlbumResponse> getAlbumsByArtist(
            @Query("client_id") String clientId,
            @Query("artist_name") String artistName, // đổi ở đây luôn
            @Query("format") String format,
            @Query("limit") int limit,
            @Query("order") String order
    );

    // Singles by artist
    @GET("albums/")
    Call<AlbumResponse> getSinglesByArtist(
            @Query("client_id") String clientId,
            @Query("artist_name") String artistName,
            @Query("format") String format,
            @Query("limit") int limit,
            @Query("order") String order
    );
    @GET("tracks")
    Call<SearchResponse<Song>> searchTracks(
            @Query("client_id") String clientId,
            @Query("format") String format,
            @Query("limit") int limit,
            @Query("search") String query
    );

    @GET("albums")
    Call<SearchResponse<AlbumResponse.Album>> searchAlbums(
            @Query("client_id") String clientId,
            @Query("format") String format,
            @Query("limit") int limit,
            @Query("search") String query
    );
}

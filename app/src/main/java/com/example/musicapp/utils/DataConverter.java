package com.example.musicapp.utils;

import com.example.musicapp.database.SongEntity;
import com.example.musicapp.model.Song;

import java.util.ArrayList;
import java.util.List;

public class DataConverter {
    
    public static Song entityToSong(SongEntity entity) {
        if (entity == null) return null;
        
        return new Song(
            entity.id,
            entity.name,
            entity.artistName,
            entity.artistId,
            entity.imageUrl,
            entity.audioUrl,
            String.valueOf(entity.duration)
        );
    }
    
    public static SongEntity songToEntity(Song song) {
        if (song == null) return null;
        
        SongEntity entity = new SongEntity();
        entity.id = song.getId();
        entity.name = song.getName();
        entity.artistName = song.getArtistName();
        entity.artistId = song.getArtistId();
        entity.imageUrl = song.getImageUrl();
        entity.audioUrl = song.getAudioUrl();
        entity.duration = song.getDuration();
        entity.timestamp = System.currentTimeMillis();
        entity.isFavorite = false;
        entity.isDownloaded = false;
        return entity;
    }
    
    public static List<Song> entitiesToSongs(List<SongEntity> entities) {
        List<Song> songs = new ArrayList<>();
        if (entities != null) {
            for (SongEntity entity : entities) {
                Song song = entityToSong(entity);
                if (song != null) {
                    songs.add(song);
                }
            }
        }
        return songs;
    }
    
    public static List<SongEntity> songsToEntities(List<Song> songs) {
        List<SongEntity> entities = new ArrayList<>();
        if (songs != null) {
            for (Song song : songs) {
                SongEntity entity = songToEntity(song);
                if (entity != null) {
                    entities.add(entity);
                }
            }
        }
        return entities;
    }
}
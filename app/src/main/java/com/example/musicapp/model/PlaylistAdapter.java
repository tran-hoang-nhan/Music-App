// PlaylistAdapter.java
package com.example.musicapp.model;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.example.musicapp.R;

import java.util.List;

public class PlaylistAdapter extends RecyclerView.Adapter<PlaylistAdapter.PlaylistViewHolder> {

    private final Context context;
    private List<?> playlists;
    private OnItemClickListener listener;
    private OnUserPlaylistClickListener userPlaylistListener;
    private String currentPlayingPlaylistId;
    private boolean useSimpleLayout = false;

    public interface OnItemClickListener {
        void onItemClick(PlaylistResponse.Playlist playlist);
    }

    public interface OnUserPlaylistClickListener {
        void onUserPlaylistClick(Playlist playlist);
    }

    public PlaylistAdapter(Context context, List<?> playlists) {
        this.context = context;
        this.playlists = playlists;
    }

    public PlaylistAdapter(Context context, List<?> playlists, boolean useSimpleLayout) {
        this.context = context;
        this.playlists = playlists;
        this.useSimpleLayout = useSimpleLayout;
    }

    public void updatePlaylists(List<?> newPlaylists) {
        int oldSize = playlists != null ? playlists.size() : 0;
        this.playlists = newPlaylists;
        int newSize = newPlaylists != null ? newPlaylists.size() : 0;
        
        if (oldSize > 0) {
            notifyItemRangeRemoved(0, oldSize);
        }
        if (newSize > 0) {
            notifyItemRangeInserted(0, newSize);
        }
    }

    public void setOnUserPlaylistClickListener(OnUserPlaylistClickListener listener) {
        this.userPlaylistListener = listener;
    }

    public void setOnItemClickListener(OnItemClickListener listener) {
        this.listener = listener;
    }

    public void setCurrentPlayingPlaylist(String playlistId) {
        this.currentPlayingPlaylistId = playlistId;
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public PlaylistViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        int layoutId = useSimpleLayout ? R.layout.item_playlist_simple : R.layout.item_playlist_default;
        View view = LayoutInflater.from(context).inflate(layoutId, parent, false);
        return new PlaylistViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull PlaylistViewHolder holder, int position) {
        Object item = playlists.get(position);
        
        if (item instanceof PlaylistResponse.Playlist) {
            PlaylistResponse.Playlist playlist = (PlaylistResponse.Playlist) item;
            holder.name.setText(playlist.getName());
            Glide.with(context).load(playlist.getImage()).into(holder.image);
            holder.itemView.setOnClickListener(v -> {
                if (listener != null) listener.onItemClick(playlist);
            });
        } else if (item instanceof Playlist) {
            Playlist playlist = (Playlist) item;
            
            // Show "Now Playing" indicator
            if (playlist.getId().equals(currentPlayingPlaylistId)) {
                holder.name.setText(playlist.getName() + " - Đang được phát");
                holder.name.setTextColor(context.getResources().getColor(android.R.color.holo_blue_light));
            } else {
                holder.name.setText(playlist.getName());
                holder.name.setTextColor(context.getResources().getColor(android.R.color.white));
            }
            
            if (holder.image != null) {
                holder.image.setImageResource(R.drawable.placeholder);
            }
            holder.itemView.setOnClickListener(v -> {
                if (userPlaylistListener != null) userPlaylistListener.onUserPlaylistClick(playlist);
            });
        }
    }

    @Override
    public int getItemCount() {
        return playlists != null ? playlists.size() : 0;
    }

    static class PlaylistViewHolder extends RecyclerView.ViewHolder {
        TextView name;
        ImageView image;

        public PlaylistViewHolder(@NonNull View itemView) {
            super(itemView);
            name = itemView.findViewById(R.id.playlist_name);
            image = itemView.findViewById(R.id.playlist_image);
        }
    }
}

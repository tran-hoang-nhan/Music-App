package com.example.musicapp.model;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Color;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.example.musicapp.R;
import com.example.musicapp.storage.FavoritesManager;
import android.widget.ImageButton;

import java.util.ArrayList;
import java.util.List;

public class SongAdapter extends RecyclerView.Adapter<SongAdapter.ViewHolder> {

    private final Context context;
    private final List<Song> fullList;
    private final List<Song> visibleList;
    private static final int LIMIT = 5;
    private boolean expanded = false;

    private OnItemClickListener listener;
    private OnArtistClickListener artistListener;
    private OnFavoriteClickListener favoriteListener;
    private OnRemoveFromPlaylistListener removeListener;
    private int selectedPosition = RecyclerView.NO_POSITION;
    private FavoritesManager favoritesManager;
    private boolean showRemoveButton = false;

    public SongAdapter(Context context, List<Song> songList) {
        this.context = context;
        this.fullList = songList != null ? songList : new ArrayList<>();
        this.visibleList = new ArrayList<>();
        this.favoritesManager = FavoritesManager.getInstance(context);
        collapse(); // mặc định hiển thị 5 bài
    }

    public interface OnItemClickListener {
        void onItemClick(Song song, int position);
    }

    public interface OnArtistClickListener {
        void onArtistClick(String artistName);
    }
    
    public interface OnFavoriteClickListener {
        void onFavoriteClick(Song song, boolean isFavorite);
    }
    
    public interface OnRemoveFromPlaylistListener {
        void onRemoveFromPlaylist(Song song, int position);
    }

    public void setOnItemClickListener(OnItemClickListener listener) {
        this.listener = listener;
    }

    public void setOnArtistClickListener(OnArtistClickListener listener) {
        this.artistListener = listener;
    }
    
    public void setOnFavoriteClickListener(OnFavoriteClickListener listener) {
        this.favoriteListener = listener;
    }
    
    public void setOnRemoveFromPlaylistListener(OnRemoveFromPlaylistListener listener) {
        this.removeListener = listener;
    }
    
    public void setShowRemoveButton(boolean show) {
        this.showRemoveButton = show;
        notifyDataSetChanged();
    }

    // Hiển thị toàn bộ danh sách
    public void showMore() {
        int oldSize = visibleList.size();
        visibleList.addAll(fullList.subList(oldSize, fullList.size()));
        expanded = true;
        notifyItemRangeInserted(oldSize, fullList.size() - oldSize);
    }

    // Thu gọn về LIMIT bài
    public void collapse() {
        int oldSize = visibleList.size();
        int newSize = Math.min(LIMIT, fullList.size());
        if (oldSize > newSize) {
            visibleList.subList(newSize, oldSize).clear();
            notifyItemRangeRemoved(newSize, oldSize - newSize);
        }
        expanded = false;
    }

    public boolean isExpanded() {
        return expanded;
    }

    // Cập nhật list mới
    public void updateSongs(List<Song> newSongs) {
        int oldSize = visibleList.size();
        fullList.clear();
        visibleList.clear();
        
        if (newSongs != null) {
            fullList.addAll(newSongs);
            int end = Math.min(LIMIT, fullList.size());
            visibleList.addAll(fullList.subList(0, end));
        }
        expanded = false;
        
        if (oldSize > 0) {
            notifyItemRangeRemoved(0, oldSize);
        }
        if (!visibleList.isEmpty()) {
            notifyItemRangeInserted(0, visibleList.size());
        }
    }

    public void setSelectedPosition(int position) {
        int prevPos = selectedPosition;
        selectedPosition = position;
        if (prevPos != RecyclerView.NO_POSITION) notifyItemChanged(prevPos);
        notifyItemChanged(selectedPosition);
    }

    @NonNull
    @Override
    public SongAdapter.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(context).inflate(R.layout.item_song, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull SongAdapter.ViewHolder holder, int position) {
        Song song = visibleList.get(position);
        holder.tvTitle.setText(song.getName());
        holder.tvArtist.setText(song.getArtistName());
        holder.txDuration.setText(formatDuration(song.getDuration()));
        Glide.with(context)
                .load(song.getImageUrl())
                .placeholder(R.drawable.placeholder)
                .into(holder.ivCover);

        holder.itemView.setOnClickListener(v -> {
            if (listener != null) {
                listener.onItemClick(song, position);
            }
        });

        holder.tvArtist.setOnClickListener(v -> {
            if (artistListener != null) {
                artistListener.onArtistClick(song.getArtistName());
            }
        });

        // Update favorite button - check current state
        updateFavoriteButton(holder.btnFavorite, song);
        holder.btnFavorite.setOnClickListener(v -> {
            if (favoriteListener != null) {
                boolean isFavorite = favoritesManager.isFavorite(song);
                favoriteListener.onFavoriteClick(song, !isFavorite);
            }
        });

        // Handle remove button for playlists
        // Trong onBindViewHolder
        if (showRemoveButton) {
            holder.btnFavorite.setImageResource(R.drawable.ic_remove);
            holder.btnFavorite.setOnClickListener(v -> {
                if (removeListener != null) {
                    removeListener.onRemoveFromPlaylist(song, position);
                }
            });
        } else {
            updateFavoriteButton(holder.btnFavorite, song);
            holder.btnFavorite.setOnClickListener(v -> {
                if (favoriteListener != null) {
                    boolean isFavorite = favoritesManager.isFavorite(song);
                    favoriteListener.onFavoriteClick(song, !isFavorite);
                }
            });
        }


        if (position == selectedPosition) {
            holder.itemView.setBackgroundColor(Color.parseColor("#FFDDDD")); // highlight
        } else {
            holder.itemView.setBackgroundColor(Color.TRANSPARENT);
        }
    }

    @SuppressLint("DefaultLocale")
    private String formatDuration(int seconds) {
        int minutes = seconds / 60;
        int sec = seconds % 60;
        return String.format("%d:%02d", minutes, sec);
    }
    
    private void updateFavoriteButton(ImageButton btnFavorite, Song song) {
        // Don't update if user just clicked (button disabled)
        if (!btnFavorite.isEnabled()) {
            return;
        }
        
        if (showRemoveButton) {
            // Show remove icon for playlists
            btnFavorite.setImageResource(R.drawable.ic_remove);
            btnFavorite.setImageTintList(android.content.res.ColorStateList.valueOf(Color.parseColor("#FF5722")));
        } else {
            // Check current favorite state
            boolean isFavorite = favoritesManager.isFavorite(song);
            
            if (isFavorite) {
                btnFavorite.setImageResource(R.drawable.ic_favorite_filled);
                btnFavorite.setImageTintList(android.content.res.ColorStateList.valueOf(Color.parseColor("#E91E63")));
            } else {
                btnFavorite.setImageResource(R.drawable.ic_favorite_border);
                btnFavorite.setImageTintList(android.content.res.ColorStateList.valueOf(Color.parseColor("#888888")));
            }
        }
    }

    @Override
    public int getItemCount() {
        return visibleList.size();
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        ImageView ivCover;
        TextView tvTitle, tvArtist, txDuration;
        ImageButton btnFavorite;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            ivCover = itemView.findViewById(R.id.imageCover);
            tvTitle = itemView.findViewById(R.id.textTitle);
            tvArtist = itemView.findViewById(R.id.textArtist);
            txDuration = itemView.findViewById(R.id.textDuration);
            btnFavorite = itemView.findViewById(R.id.btnFavorite);
        }
    }
}

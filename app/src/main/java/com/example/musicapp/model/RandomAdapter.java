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

public class RandomAdapter extends RecyclerView.Adapter<RandomAdapter.ViewHolder> {

    private final Context context;
    private final List<Song> randomList;
    private OnItemClickListener listener;
    private OnFavoriteClickListener favoriteListener;
    private final int itemsToShow = 5;
    private int selectedPosition = RecyclerView.NO_POSITION;
    private FavoritesManager favoritesManager;

    public RandomAdapter(Context context, List<Song> randomList) {
        this.context = context;
        this.randomList = randomList != null ? randomList : new ArrayList<>();
        this.favoritesManager = FavoritesManager.getInstance(context);
    }
    public interface OnItemClickListener {
        void onItemClick(Song song, int position);
    }
    
    public interface OnFavoriteClickListener {
        void onFavoriteClick(Song song, boolean isFavorite);
    }

    public void setOnItemClickListener(RandomAdapter.OnItemClickListener listener) {
        this.listener = listener;
    }
    
    public void setOnFavoriteClickListener(OnFavoriteClickListener listener) {
        this.favoriteListener = listener;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(context).inflate(R.layout.item_song, parent, false);
        return new ViewHolder(view);
    }
    public void setSelectedPosition(int position) {
        int prevPos = selectedPosition;
        selectedPosition = position;
        notifyItemChanged(prevPos);
        notifyItemChanged(selectedPosition);
    }
    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        Song song = randomList.get(position);
        holder.tvTitle.setText(song.getName());
        holder.tvArtist.setText(song.getArtistName());
        holder.txDuration.setText(formatDuration(song.getDuration()));
        Glide.with(context).load(song.getImageUrl()).into(holder.ivCover);


        holder.itemView.setOnClickListener(v -> {
            if (listener != null) {
                listener.onItemClick(song, position);
            }
        });


        // Update favorite button - check current state
        updateFavoriteButton(holder.btnFavorite, song);
            
        holder.btnFavorite.setOnClickListener(v -> {
            // Disable button temporarily to prevent double clicks
            holder.btnFavorite.setEnabled(false);
            
            boolean currentState = favoritesManager.isFavorite(song);
            boolean newState = !currentState;
            
            // Update UI immediately
            if (newState) {
                holder.btnFavorite.setImageResource(R.drawable.ic_favorite_filled);
                holder.btnFavorite.setImageTintList(android.content.res.ColorStateList.valueOf(Color.parseColor("#E91E63")));
            } else {
                holder.btnFavorite.setImageResource(R.drawable.ic_favorite_border);
                holder.btnFavorite.setImageTintList(android.content.res.ColorStateList.valueOf(Color.parseColor("#888888")));
            }
            
            // Update Firebase without triggering UI refresh
            if (newState) {
                favoritesManager.addFavorite(song);
            } else {
                favoritesManager.removeFavorite(song);
            }
            
            // Re-enable button after delay
            holder.btnFavorite.postDelayed(() -> holder.btnFavorite.setEnabled(true), 1000);
                
            if (favoriteListener != null) {
                favoriteListener.onFavoriteClick(song, newState);
            }
        });

        if (position == selectedPosition) {
            holder.itemView.setBackgroundColor(Color.parseColor("#FFDDDD")); // highlight nền
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
    @Override
    public int getItemCount() {
        return randomList.size();
    }

    public void updateRandom(List<Song> newList) {
        int oldSize = randomList.size();
        randomList.clear();
        
        if (oldSize > 0) {
            notifyItemRangeRemoved(0, oldSize);
        }
        
        if (newList != null) {
            randomList.addAll(newList);
            notifyItemRangeInserted(0, newList.size());
        }
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


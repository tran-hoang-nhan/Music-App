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

import java.util.ArrayList;
import java.util.List;

public class RandomAdapter extends RecyclerView.Adapter<RandomAdapter.ViewHolder> {

    private final Context context;
    private final List<Song> randomList;
    private OnItemClickListener listener;
    private final int itemsToShow = 5;
    private int selectedPosition = RecyclerView.NO_POSITION;

    public RandomAdapter(Context context, List<Song> randomList) {
        this.context = context;
        this.randomList = randomList != null ? randomList : new ArrayList<>();
    }
    public interface OnItemClickListener {
        void onItemClick(Song song, int position);
    }

    public void setOnItemClickListener(RandomAdapter.OnItemClickListener listener) {
        this.listener = listener;
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

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            ivCover = itemView.findViewById(R.id.imageCover);
            tvTitle = itemView.findViewById(R.id.textTitle);
            tvArtist = itemView.findViewById(R.id.textArtist);
            txDuration = itemView.findViewById(R.id.textDuration);
        }
    }
}


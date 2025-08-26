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

public class SongAdapter extends RecyclerView.Adapter<SongAdapter.ViewHolder> {

    private final Context context;
    private final List<Song> fullList;
    private final List<Song> visibleList;
    private static final int LIMIT = 5;
    private boolean expanded = false;

    private OnItemClickListener listener;
    private int selectedPosition = RecyclerView.NO_POSITION;

    public SongAdapter(Context context, List<Song> songList) {
        this.context = context;
        this.fullList = songList != null ? songList : new ArrayList<>();
        this.visibleList = new ArrayList<>();
        collapse(); // mặc định hiển thị 5 bài
    }

    public interface OnItemClickListener {
        void onItemClick(Song song, int position);
    }

    public void setOnItemClickListener(OnItemClickListener listener) {
        this.listener = listener;
    }

    // Hiển thị toàn bộ danh sách
    public void showMore() {
        visibleList.clear();
        visibleList.addAll(fullList);
        expanded = true;
        notifyDataSetChanged();
    }

    // Thu gọn về LIMIT bài
    public void collapse() {
        visibleList.clear();
        int end = Math.min(LIMIT, fullList.size());
        visibleList.addAll(fullList.subList(0, end));
        expanded = false;
        notifyDataSetChanged();
    }

    public boolean isExpanded() {
        return expanded;
    }

    // Cập nhật list mới
    public void updateSongs(List<Song> newSongs) {
        fullList.clear();
        if (newSongs != null) {
            fullList.addAll(newSongs);
        }
        collapse();
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

    @Override
    public int getItemCount() {
        return visibleList.size();
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

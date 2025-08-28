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

public class GenreAdapter extends RecyclerView.Adapter<GenreAdapter.GenreViewHolder> {

    private List<Genre> genres;
    private Context context;
    private OnGenreClickListener listener;

    public interface OnGenreClickListener {
        void onGenreClick(Genre genre);
    }

    public GenreAdapter(Context context, List<Genre> genres, OnGenreClickListener listener) {
        this.context = context;
        this.genres = genres;
        this.listener = listener;
    }

    @NonNull
    @Override
    public GenreViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(context).inflate(R.layout.item_genre, parent, false);
        return new GenreViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull GenreViewHolder holder, int position) {
        Genre genre = genres.get(position);
        holder.txtGenreName.setText(genre.getName());

        if (genre.getImageUrl() != null && !genre.getImageUrl().isEmpty()) {
            Glide.with(context).load(genre.getImageUrl()).into(holder.imgGenre);
        } else {
            holder.imgGenre.setImageResource(R.drawable.placeholder);
        }

        holder.itemView.setOnClickListener(v -> listener.onGenreClick(genre));
    }

    @Override
    public int getItemCount() {
        return genres.size();
    }

    static class GenreViewHolder extends RecyclerView.ViewHolder {
        ImageView imgGenre;
        TextView txtGenreName;

        public GenreViewHolder(@NonNull View itemView) {
            super(itemView);
            imgGenre = itemView.findViewById(R.id.imgGenre);
            txtGenreName = itemView.findViewById(R.id.txtGenreName);
        }
    }
}

package com.example.musicapp.ui.profile;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.navigation.fragment.NavHostFragment;

import com.example.musicapp.R;
import com.example.musicapp.databinding.FragmentLoginBinding;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import java.util.Objects;

public class LoginFragment extends Fragment {

    private FragmentLoginBinding binding;
    private FirebaseAuth auth;
    private DatabaseReference database;

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        binding = FragmentLoginBinding.inflate(inflater, container, false);

        auth = FirebaseAuth.getInstance();
        database = FirebaseDatabase.getInstance("https://dacn-8a822-default-rtdb.asia-southeast1.firebasedatabase.app/").getReference("users");

        binding.btnLogin.setOnClickListener(v -> loginUser());
        binding.tvGoRegister.setOnClickListener(v ->
                NavHostFragment.findNavController(this)
                        .navigate(R.id.action_login_to_register));

        return binding.getRoot();
    }

    private void loginUser() {
        String email = Objects.requireNonNull(binding.etLoginEmail.getText()).toString().trim();
        String password = Objects.requireNonNull(binding.etLoginPassword.getText()).toString().trim();

        if (TextUtils.isEmpty(email) || TextUtils.isEmpty(password)) {
            Toast.makeText(getContext(), "Vui lòng nhập đủ thông tin", Toast.LENGTH_SHORT).show();
            return;
        }

        auth.signInWithEmailAndPassword(email, password)
                .addOnCompleteListener(requireActivity(), task -> {
                    if (task.isSuccessful()) {
                        FirebaseUser user = auth.getCurrentUser();
                        if (user != null) {
                            String uid = user.getUid();

                            // Lấy tên người dùng từ Realtime Database
                            database.child(uid).addListenerForSingleValueEvent(new ValueEventListener() {
                                @Override
                                public void onDataChange(@NonNull DataSnapshot snapshot) {
                                    if (snapshot.exists()) {
                                        String name = snapshot.child("name").getValue(String.class);
                                        String userEmail = snapshot.child("email").getValue(String.class);

                                        Toast.makeText(getContext(),
                                                "Đăng nhập thành công\nEmail: " + userEmail + "\nTên: " + name,
                                                Toast.LENGTH_SHORT).show();

                                        // Quay về ProfileFragment
                                        NavHostFragment.findNavController(LoginFragment.this)
                                                .popBackStack(R.id.navigation_profile, false);
                                    } else {
                                        Toast.makeText(getContext(),
                                                "Không tìm thấy thông tin user trong database",
                                                Toast.LENGTH_SHORT).show();
                                    }
                                }

                                @Override
                                public void onCancelled(@NonNull DatabaseError error) {
                                    Toast.makeText(getContext(),
                                            "Lỗi đọc dữ liệu: " + error.getMessage(),
                                            Toast.LENGTH_SHORT).show();
                                }
                            });
                        }
                    } else {
                        Toast.makeText(getContext(),
                                "Lỗi: " + Objects.requireNonNull(task.getException()).getMessage(),
                                Toast.LENGTH_SHORT).show();
                    }
                });
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        binding = null;
    }
}

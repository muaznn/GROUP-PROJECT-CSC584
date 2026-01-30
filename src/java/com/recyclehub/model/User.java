package com.recyclehub.model;

import java.io.Serializable;

public class User implements Serializable {
    private int userId;
    private String name;
    private String password;
    private String email;
    private String address;
    private String phone;
    private String role; // 'user' or 'admin'
    private int currentPoints;

    public User() {}

    public User(int userId, String name, String password, String email, String address, String phone, String role, int currentPoints) {
        this.userId = userId;
        this.name = name;
        this.password = password;
        this.email = email;
        this.address = address;
        this.phone = phone;
        this.role = role;
        this.currentPoints = currentPoints;
    }

    // Getters and Setters
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public int getCurrentPoints() { return currentPoints; }
    public void setCurrentPoints(int currentPoints) { this.currentPoints = currentPoints; }
}
package com.recyclehub.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    // ADJUST THESE IF NEEDED
    private static final String URL = "jdbc:derby://localhost:1527/recycleDB;create=true";
    private static final String USER = "app"; 
    private static final String PASSWORD = "app";

    public static Connection getConnection() throws SQLException {
        try {
            // Load the driver (Standard for Derby/JavaDB)
            Class.forName("org.apache.derby.jdbc.ClientDriver");
            return DriverManager.getConnection(URL, USER, PASSWORD);
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            throw new SQLException("Database Driver not found!");
        }
    }
}
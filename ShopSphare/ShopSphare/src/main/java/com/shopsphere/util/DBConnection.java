package com.shopsphere.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final String DEFAULT_URL = 
        "jdbc:mysql://localhost:3306/shopsphere?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    private static final String DEFAULT_USER = "root";
    private static final String DRIVER_CLASS = "com.mysql.cj.jdbc.Driver";

    static {
        try {
            Class.forName(DRIVER_CLASS);
        } catch (ClassNotFoundException e) {
            // Driver may also be loaded automatically by modern JDBC SPI
        }
    }

    private DBConnection() {
    }

    public static Connection getConnection() throws SQLException {
        String url = System.getProperty("DB_URL");
        if (url == null || url.isBlank()) {
            url = System.getenv("DB_URL");
        }
        if (url == null || url.isBlank()) {
            url = DEFAULT_URL;
        }

        String user = System.getProperty("DB_USER");
        if (user == null || user.isBlank()) {
            user = System.getenv("DB_USER");
        }
        if (user == null || user.isBlank()) {
            user = DEFAULT_USER;
        }

        String password = System.getProperty("DB_PASSWORD");
        if (password == null) {
            password = System.getenv("DB_PASSWORD");
        }
        if (password == null) {
            password = "";
        }

        return DriverManager.getConnection(url, user, password);
    }
}


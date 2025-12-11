package DAO;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Database Connection Utility Class Manages MySQL database connections
 */
public class DBConnection {

 private static final String DB_URL =
        "jdbc:mysql://localhost:3306/swp_card_store?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "123456";
    private static final String DB_DRIVER = "com.mysql.cj.jdbc.Driver";

    static {
        try {
            Class.forName(DB_DRIVER);
            System.out.println("Loaded MySQL driver: " + DB_DRIVER);
        } catch (ClassNotFoundException e) {
            System.out.println("KHÔNG load được driver MySQL!");
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
    }

    public static boolean testConnection() {
        try (Connection conn = getConnection()) {
            return conn != null && !conn.isClosed();
        } catch (SQLException e) {
            e.printStackTrace();
            System.err.println("Connection test failed: " + e.getMessage());
            return false;
        }
    }

    public static void main(String[] args) {
        if (testConnection()) {
            System.out.println("Kết nối MySQL THÀNH CÔNG!");
        } else {
            System.out.println("Kết nối MySQL THẤT BẠI!");
        }
    }
}
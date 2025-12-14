package dao.user;

import dao.DBConnection;
import models.User;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

/**
 * Register DAO - Xử lý đăng ký user
 */
public class RegisterDAO {
    
    /**
     * Kiểm tra email đã tồn tại chưa
     * @param email Email cần kiểm tra
     * @return true nếu email đã tồn tại, false nếu chưa
     */
    public boolean checkEmailExists(String email) {
        if (email == null || email.trim().isEmpty()) {
            return false;
        }
        
        // Normalize email: trim và lowercase
        String normalizedEmail = email.trim().toLowerCase();
        
        // Sử dụng LOWER() trong SQL để so sánh case-insensitive
        String sql = "SELECT COUNT(*) FROM users WHERE LOWER(TRIM(email)) = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, normalizedEmail);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int count = rs.getInt(1);
                    System.out.println("Check email: " + normalizedEmail + " - Count: " + count);
                    return count > 0;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in RegisterDAO.checkEmailExists: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Kiểm tra username đã tồn tại chưa
     * @param username Username cần kiểm tra
     * @return true nếu username đã tồn tại, false nếu chưa
     */
    public boolean checkUsernameExists(String username) {
        String sql = "SELECT COUNT(*) FROM users WHERE username = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, username);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in RegisterDAO.checkUsernameExists: " + e.getMessage());
        }
        
        return false;
    }
    
    /**
     * Thêm user mới vào database
     * @param user User object cần thêm
     * @return true nếu thêm thành công, false nếu thất bại
     */
    public boolean insertUser(User user) {
        String sql = "INSERT INTO users (username, password, email, full_name, phone_number, balance, role, status, image_url, created_at, updated_at, is_deleted) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        System.out.println("=== RegisterDAO.insertUser ===");
        System.out.println("SQL: " + sql);
        System.out.println("Username: " + user.getUsername());
        System.out.println("Email: " + user.getEmail());
        System.out.println("FullName: " + user.getFullName());
        System.out.println("Phone: " + user.getPhoneNumber());
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            System.out.println("Đã kết nối database");
            
            Timestamp now = new Timestamp(System.currentTimeMillis());
            
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getPassword());
            ps.setString(3, user.getEmail());
            ps.setString(4, user.getFullName());
            ps.setString(5, user.getPhoneNumber());
            ps.setBigDecimal(6, user.getBalance() != null ? user.getBalance() : java.math.BigDecimal.ZERO);
            ps.setString(7, user.getRole() != null ? user.getRole() : "CUSTOMER");
            ps.setString(8, user.getStatus() != null ? user.getStatus() : "ACTIVE");
            ps.setString(9, user.getImage() != null && !user.getImage().trim().isEmpty() ? user.getImage() : "image2"); // Avatar mặc định
            ps.setTimestamp(10, now);
            ps.setTimestamp(11, now);
            ps.setBoolean(12, false);
            
            System.out.println("Đã set parameters, đang execute...");
            
            int rowsAffected = ps.executeUpdate();
            
            System.out.println("Rows affected: " + rowsAffected);
            
            boolean result = rowsAffected > 0;
            System.out.println("Kết quả: " + result);
            System.out.println("=== END RegisterDAO.insertUser ===");
            
            return result;
            
        } catch (SQLException e) {
            System.err.println("=== LỖI RegisterDAO.insertUser ===");
            System.err.println("Error: " + e.getMessage());
            System.err.println("SQLState: " + e.getSQLState());
            System.err.println("ErrorCode: " + e.getErrorCode());
            e.printStackTrace();
            System.err.println("=== END LỖI ===");
            return false;
        }
    }
}


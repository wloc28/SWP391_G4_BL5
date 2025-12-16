/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package DAO.user;

import DAO.DBConnection;
import Models.User;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;

/**
 *
 * @author Dell XPS
 */
public class daoUser {
    public User login(String email, String password) {
    // 1. Truy vấn SQL không đổi
    String sql = "SELECT * FROM users WHERE email = ? AND password = ?";
    
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setString(1, email);
        ps.setString(2, password);
        
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                // Đăng nhập thành công, ánh xạ dữ liệu trực tiếp
                User user = new User();
                
                
                user.setUserId(rs.getInt("user_id")); 
                user.setUsername(rs.getString("username"));
                user.setPassword(rs.getString("password"));
                user.setEmail(rs.getString("email"));
                user.setFullName(rs.getString("full_name"));
                user.setPhoneNumber(rs.getString("phone_number"));
                user.setBalance(rs.getBigDecimal("balance"));
                user.setRole(rs.getString("role"));
                user.setStatus(rs.getString("status"));
                user.setCreatedAt(rs.getTimestamp("created_at"));
                user.setUpdatedAt(rs.getTimestamp("updated_at"));
                user.setDeleted(rs.getBoolean("is_deleted"));
                
                return user;
            }
        }
    } catch (SQLException e) {
        // Xử lý lỗi kết nối hoặc truy vấn
        System.err.println("Error in daoUser.login: " + e.getMessage());
    }
    
    // Đăng nhập thất bại hoặc có lỗi
    return null;
}
    
    /**
     * Lấy thông tin user theo user_id
     * @param userId ID của user
     * @return User object nếu tìm thấy, null nếu không
     */
    public User getUserById(int userId) {
        String sql = "SELECT * FROM users WHERE user_id = ? AND is_deleted = 0";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User user = new User();
                    user.setUserId(rs.getInt("user_id"));
                    user.setUsername(rs.getString("username"));
                    user.setPassword(rs.getString("password"));
                    user.setEmail(rs.getString("email"));
                    user.setFullName(rs.getString("full_name"));
                    user.setPhoneNumber(rs.getString("phone_number"));
                    user.setBalance(rs.getBigDecimal("balance"));
                    user.setRole(rs.getString("role"));
                    user.setImage(rs.getString("image_url"));
                    user.setStatus(rs.getString("status"));
                    user.setCreatedAt(rs.getTimestamp("created_at"));
                    user.setUpdatedAt(rs.getTimestamp("updated_at"));
                    user.setDeleted(rs.getBoolean("is_deleted"));
                    return user;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in daoUser.getUserById: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Cập nhật thông tin user
     * @param user User object với thông tin cần cập nhật
     * @return true nếu cập nhật thành công, false nếu thất bại
     */
    public boolean updateUser(User user) {
        String sql = "UPDATE users SET username = ?, full_name = ?, phone_number = ?, image_url = ?, updated_at = ? WHERE user_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
            
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getFullName());
            ps.setString(3, user.getPhoneNumber());
            ps.setString(4, user.getImage()); // image_url
            ps.setTimestamp(5, now);
            ps.setInt(6, user.getUserId());
            
            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("Error in daoUser.updateUser: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Đổi mật khẩu
     * @param userId ID của user
     * @param oldPassword Mật khẩu cũ
     * @param newPassword Mật khẩu mới
     * @return true nếu đổi thành công, false nếu thất bại
     */
    public boolean changePassword(int userId, String oldPassword, String newPassword) {
        // Kiểm tra mật khẩu cũ
        String checkSql = "SELECT user_id FROM users WHERE user_id = ? AND password = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
            
            checkPs.setInt(1, userId);
            checkPs.setString(2, oldPassword);
            
            try (ResultSet rs = checkPs.executeQuery()) {
                if (!rs.next()) {
                    // Mật khẩu cũ không đúng
                    return false;
                }
            }
            
            // Mật khẩu cũ đúng, cập nhật mật khẩu mới
            String updateSql = "UPDATE users SET password = ?, updated_at = ? WHERE user_id = ?";
            
            try (PreparedStatement updatePs = conn.prepareStatement(updateSql)) {
                java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
                
                updatePs.setString(1, newPassword);
                updatePs.setTimestamp(2, now);
                updatePs.setInt(3, userId);
                
                int rowsAffected = updatePs.executeUpdate();
                return rowsAffected > 0;
            }
            
        } catch (SQLException e) {
            System.err.println("Error in daoUser.changePassword: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Cập nhật mật khẩu theo email (dùng cho quên mật khẩu)
     * @param email Email tài khoản
     * @param newPassword Mật khẩu mới
     * @return true nếu cập nhật thành công, false nếu thất bại hoặc không tìm thấy email
     */
    public boolean updatePasswordByEmail(String email, String newPassword) {
        if (email == null || email.trim().isEmpty()) {
            System.out.println("Email is null or empty");
            return false;
        }
        
        String normalizedEmail = email.trim().toLowerCase();
        
        System.out.println("=== daoUser.updatePasswordByEmail ===");
        System.out.println("Email (normalized): " + normalizedEmail);
        System.out.println("New password: " + newPassword);
        
        // Kiểm tra user có tồn tại không trước khi update
        String checkSql = "SELECT user_id, email, is_deleted FROM users WHERE LOWER(TRIM(email)) = ?";
        
        try (Connection conn = DBConnection.getConnection()) {
            int userId = -1;
            String dbEmail = null;
            boolean isDeleted = false;
            
            // Check user exists và lấy user_id
            try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                checkPs.setString(1, normalizedEmail);
                try (var rs = checkPs.executeQuery()) {
                    if (rs.next()) {
                        userId = rs.getInt("user_id");
                        dbEmail = rs.getString("email");
                        isDeleted = rs.getBoolean("is_deleted");
                        System.out.println("Found user - ID: " + userId + ", Email: " + dbEmail + ", is_deleted: " + isDeleted);
                        
                        if (isDeleted) {
                            System.out.println("✗ User is deleted, cannot update password");
                            return false;
                        }
                    } else {
                        System.out.println("✗ User not found with email: " + normalizedEmail);
                        return false;
                    }
                }
            }
            
            // Update password bằng user_id (chính xác hơn)
            String updateSql = "UPDATE users SET password = ?, updated_at = ? WHERE user_id = ?";
            
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
                
                ps.setString(1, newPassword);
                ps.setTimestamp(2, now);
                ps.setInt(3, userId);
                
                System.out.println("Executing UPDATE with user_id: " + userId);
                int rows = ps.executeUpdate();
                System.out.println("Rows affected: " + rows);
                
                if (rows > 0) {
                    System.out.println("✓ Password updated successfully for user_id: " + userId);
                } else {
                    System.out.println("✗ No rows updated - unexpected error");
                }
                
                System.out.println("=== END daoUser.updatePasswordByEmail ===");
                return rows > 0;
            }
            
        } catch (SQLException e) {
            System.err.println("Error in daoUser.updatePasswordByEmail: " + e.getMessage());
            System.err.println("SQLState: " + e.getSQLState());
            System.err.println("ErrorCode: " + e.getErrorCode());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Main method để test login và reset password
     */
    public static void main(String[] args) {
        System.out.println("========================================");
        System.out.println("TEST RESET PASSWORD FUNCTION");
        System.out.println("========================================");
        
        daoUser userDao = new daoUser();
        
        // Test reset password
        String testEmail = "cuanlanhchanh01@gmail.com";
        String newPassword = "quan2003";
        
        System.out.println("\nĐang test RESET PASSWORD với:");
        System.out.println("Email: " + testEmail);
        System.out.println("Mật khẩu mới: " + newPassword);
        System.out.println("\n");
        
        boolean updated = userDao.updatePasswordByEmail(testEmail, newPassword);
        
        System.out.println("\n========================================");
        if (updated) {
            System.out.println("KẾT QUẢ: RESET PASSWORD THÀNH CÔNG!");
            System.out.println("========================================");
            System.out.println("Mật khẩu đã được cập nhật trong database.");
            System.out.println("\nĐang test LOGIN với mật khẩu mới...");
            
            // Test login với mật khẩu mới
            User user = userDao.login(testEmail, newPassword);
            if (user != null) {
                System.out.println("✓ LOGIN THÀNH CÔNG với mật khẩu mới!");
                System.out.println("  - User ID: " + user.getUserId());
                System.out.println("  - Username: " + user.getUsername());
                System.out.println("  - Email: " + user.getEmail());
                System.out.println("  - Full Name: " + user.getFullName());
            } else {
                System.out.println("✗ LOGIN THẤT BẠI với mật khẩu mới!");
                System.out.println("  Có thể mật khẩu chưa được cập nhật đúng trong DB.");
            }
        } else {
            System.out.println("KẾT QUẢ: RESET PASSWORD THẤT BẠI!");
            System.out.println("========================================");
            System.out.println("Không thể cập nhật mật khẩu.");
            System.out.println("Hãy kiểm tra:");
            System.out.println("  1. Email có tồn tại trong database không?");
            System.out.println("  2. Email có đúng format không?");
            System.out.println("  3. Tên bảng trong database có đúng là 'users' không?");
            System.out.println("  4. Tên các cột có đúng không?");
            System.out.println("  5. Database có kết nối được không?");
            System.out.println("  6. User có bị is_deleted = 1 không?");
        }
        System.out.println("========================================\n");
    }
}

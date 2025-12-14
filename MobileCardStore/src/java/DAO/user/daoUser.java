/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao.user;

import dao.DBConnection;
import models.User;
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
     * Main method để test login
     */
    public static void main(String[] args) {
        System.out.println("========================================");
        System.out.println("TEST LOGIN FUNCTION");
        System.out.println("========================================");
        
        daoUser customerLogin = new daoUser();
        
        // Test với thông tin đã cho
        String testEmail = "quanpham@gmail.com";
        String testPassword = "12345";
        
        System.out.println("\nĐang test với:");
        System.out.println("Email: " + testEmail);
        System.out.println("Password: " + testPassword);
        System.out.println("\n");
        
        User user = customerLogin.login(testEmail, testPassword);
        
        System.out.println("\n========================================");
        if (user != null) {
            System.out.println("KẾT QUẢ: LOGIN THÀNH CÔNG!");
            System.out.println("========================================");
            System.out.println("Thông tin user:");
            System.out.println("  - User ID: " + user.getUserId());
            System.out.println("  - Username: " + user.getUsername());
            System.out.println("  - Email: " + user.getEmail());
            System.out.println("  - Full Name: " + user.getFullName());
            System.out.println("  - Phone: " + user.getPhoneNumber());
            System.out.println("  - Balance: " + user.getBalance());
            System.out.println("  - Role: " + user.getRole());
            System.out.println("  - Status: " + user.getStatus());
            System.out.println("  - Is Deleted: " + user.isDeleted());
        } else {
            System.out.println("KẾT QUẢ: LOGIN THẤT BẠI!");
            System.out.println("========================================");
            System.out.println("Không tìm thấy user với email và password này.");
            System.out.println("Hãy kiểm tra:");
            System.out.println("  1. Email và password có đúng không?");
            System.out.println("  2. Tên bảng trong database có đúng là 'users' không?");
            System.out.println("  3. Tên các cột có đúng không?");
            System.out.println("  4. Database có kết nối được không?");
        }
        System.out.println("========================================\n");
    }
}

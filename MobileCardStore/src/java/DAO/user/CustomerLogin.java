
/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package DAO.user;

/**
 *
 * @author Dell XPS
 */
public class CustomerLogin {
    

package dao.user;

import dao.DBConnection;
import models.User;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Customer Login DAO
 */
public class CustomerLogin {
    
    public User login(String email, String password) {
        String sql = "SELECT * FROM users WHERE email = ? AND password = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, email);
            ps.setString(2, password);
            
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
                user.setStatus(rs.getString("status"));
                user.setImage(rs.getString("image_url"));
                user.setCreatedAt(rs.getTimestamp("created_at"));
                user.setUpdatedAt(rs.getTimestamp("updated_at"));
                user.setDeleted(rs.getBoolean("is_deleted"));
                    
                    return user;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in CustomerLogin.login: " + e.getMessage());
        }
        
        return null;
    }

}

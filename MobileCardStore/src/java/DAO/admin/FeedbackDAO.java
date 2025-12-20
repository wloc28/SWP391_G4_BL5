package DAO.admin;

import DAO.DBConnection;
import Models.Feedback;
import Models.User;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class FeedbackDAO {
    
    public List<Feedback> getAllFeedbacks() throws SQLException {
        return getAllFeedbacks(null, null, null, null, null);
    }
    
    public List<Feedback> getAllFeedbacks(String search, Integer productId, Integer rating, 
                                       Boolean hasReply, String sortBy) throws SQLException {
        return getAllFeedbacks(search, productId, rating, hasReply, sortBy, 0, 0);
    }
    
    public List<Feedback> getAllFeedbacks(String search, Integer productId, Integer rating, 
                                       Boolean hasReply, String sortBy, int page, int pageSize) throws SQLException {
        List<Feedback> feedbacks = new ArrayList<>();
        
        // Build SQL với WHERE và ORDER BY động
        StringBuilder sql = new StringBuilder(
            "SELECT f.*, u.full_name, u.email, ps.product_name " +
            "FROM feedbacks f " +
            "INNER JOIN users u ON f.user_id = u.user_id " +
            "INNER JOIN provider_storage ps ON f.provider_storage_id = ps.provider_storage_id " +
            "WHERE f.is_deleted = 0 "
        );
        
        List<Object> params = new ArrayList<>();
        
        // Filter theo search
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (u.full_name LIKE ? OR u.email LIKE ? OR f.content LIKE ?) ");
            String searchPattern = "%" + search.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }
        
        // Filter theo productId
        if (productId != null && productId > 0) {
            sql.append("AND f.provider_storage_id = ? ");
            params.add(productId);
        }
        
        // Filter theo rating
        if (rating != null) {
            if (rating == 0) {
                sql.append("AND f.rating IS NULL ");
            } else {
                sql.append("AND f.rating = ? ");
                params.add(rating);
            }
        }
        
        // Filter theo hasReply
        if (hasReply != null) {
            if (hasReply) {
                sql.append("AND f.admin_reply IS NOT NULL ");
            } else {
                sql.append("AND f.admin_reply IS NULL ");
            }
        }
        
        // Sort
        if (sortBy != null) {
            switch (sortBy) {
                case "oldest":
                    sql.append("ORDER BY f.created_at ASC");
                    break;
                case "rating_high":
                    sql.append("ORDER BY f.rating DESC, f.created_at DESC");
                    break;
                case "rating_low":
                    sql.append("ORDER BY f.rating ASC, f.created_at DESC");
                    break;
                case "no_reply":
                    sql.append("ORDER BY CASE WHEN f.admin_reply IS NULL THEN 0 ELSE 1 END, f.created_at DESC");
                    break;
                default: // newest
                    sql.append("ORDER BY f.created_at DESC");
            }
        } else {
            sql.append("ORDER BY f.created_at DESC");
        }
        
        // Add pagination
        if (page > 0 && pageSize > 0) {
            sql.append(" LIMIT ? OFFSET ?");
            int offset = (page - 1) * pageSize;
            params.add(pageSize);
            params.add(offset);
        }
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            // Set parameters
            for (int i = 0; i < params.size(); i++) {
                Object param = params.get(i);
                if (param instanceof String) {
                    ps.setString(i + 1, (String) param);
                } else if (param instanceof Integer) {
                    ps.setInt(i + 1, (Integer) param);
                }
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Feedback feedback = mapFeedbackFromResultSet(rs);
                    User user = new User();
                    user.setFullName(rs.getString("full_name"));
                    user.setEmail(rs.getString("email"));
                    feedback.setUser(user);
                    feedback.setProductName(rs.getString("product_name"));
                    feedbacks.add(feedback);
                }
            }
        }
        return feedbacks;
    }
    
    // Method đếm tổng số feedbacks (cho pagination)
    public int countFeedbacks(String search, Integer productId, Integer rating, 
                             Boolean hasReply) throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) as total " +
            "FROM feedbacks f " +
            "INNER JOIN users u ON f.user_id = u.user_id " +
            "INNER JOIN provider_storage ps ON f.provider_storage_id = ps.provider_storage_id " +
            "WHERE f.is_deleted = 0 "
        );
        
        List<Object> params = new ArrayList<>();
        
        // Filter theo search
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (u.full_name LIKE ? OR u.email LIKE ? OR f.content LIKE ?) ");
            String searchPattern = "%" + search.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }
        
        // Filter theo productId
        if (productId != null && productId > 0) {
            sql.append("AND f.provider_storage_id = ? ");
            params.add(productId);
        }
        
        // Filter theo rating
        if (rating != null) {
            if (rating == 0) {
                sql.append("AND f.rating IS NULL ");
            } else {
                sql.append("AND f.rating = ? ");
                params.add(rating);
            }
        }
        
        // Filter theo hasReply
        if (hasReply != null) {
            if (hasReply) {
                sql.append("AND f.admin_reply IS NOT NULL ");
            } else {
                sql.append("AND f.admin_reply IS NULL ");
            }
        }
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < params.size(); i++) {
                Object param = params.get(i);
                if (param instanceof String) {
                    ps.setString(i + 1, (String) param);
                } else if (param instanceof Integer) {
                    ps.setInt(i + 1, (Integer) param);
                }
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total");
                }
            }
        }
        return 0;
    }
    
    public boolean addAdminReply(int feedbackId, String replyContent) throws SQLException {
        String sql = "UPDATE feedbacks SET admin_reply = ?, admin_reply_at = NOW(), updated_at = NOW() " +
                     "WHERE feedback_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, replyContent);
            ps.setInt(2, feedbackId);
            
            return ps.executeUpdate() > 0;
        }
    }
    
    public boolean removeAdminReply(int feedbackId) throws SQLException {
        String sql = "UPDATE feedbacks SET admin_reply = NULL, admin_reply_at = NULL, updated_at = NOW() " +
                     "WHERE feedback_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, feedbackId);
            return ps.executeUpdate() > 0;
        }
    }
    
    public boolean updateFeedbackVisibility(int feedbackId, boolean isVisible) throws SQLException {
        String sql = "UPDATE feedbacks SET is_visible = ?, updated_at = NOW() WHERE feedback_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setBoolean(1, isVisible);
            ps.setInt(2, feedbackId);
            
            return ps.executeUpdate() > 0;
        }
    }
    
    public boolean deleteFeedback(int feedbackId) throws SQLException {
        String sql = "UPDATE feedbacks SET is_deleted = 1, updated_at = NOW() WHERE feedback_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, feedbackId);
            return ps.executeUpdate() > 0;
        }
    }
    
    private Feedback mapFeedbackFromResultSet(ResultSet rs) throws SQLException {
        Feedback feedback = new Feedback();
        feedback.setFeedbackId(rs.getInt("feedback_id"));
        feedback.setUserId(rs.getInt("user_id"));
        feedback.setProductId(rs.getInt("provider_storage_id"));
        feedback.setContent(rs.getString("content"));
        feedback.setRating(rs.getObject("rating") != null ? rs.getInt("rating") : null);
        feedback.setStatus(rs.getString("status"));
        feedback.setVisible(rs.getBoolean("is_visible"));
        feedback.setDeleted(rs.getBoolean("is_deleted"));
        feedback.setCreatedAt(rs.getTimestamp("created_at"));
        feedback.setUpdatedAt(rs.getTimestamp("updated_at"));
        feedback.setAdminReply(rs.getString("admin_reply"));
        feedback.setAdminReplyAt(rs.getTimestamp("admin_reply_at"));
        return feedback;
    }
}


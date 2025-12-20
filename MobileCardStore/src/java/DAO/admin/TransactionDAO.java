package DAO.admin;

import DAO.DBConnection;
import Models.Transaction;
import Models.User;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * TransactionDAO - handles wallet transactions and balance updates.
 */
public class TransactionDAO {

    /**
     * Create a transaction record.
     */
    public boolean createTransaction(int userId, Integer orderId, BigDecimal amount,
                                     String transactionType, String description) throws SQLException {
        String sql = "INSERT INTO transactions (user_id, order_id, amount, transaction_type, description, status, created_at, updated_at, is_deleted) "
                   + "VALUES (?, ?, ?, ?, ?, 'SUCCESS', NOW(), NOW(), 0)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            if (orderId != null) {
                ps.setInt(2, orderId);
            } else {
                ps.setNull(2, java.sql.Types.INTEGER);
            }
            ps.setBigDecimal(3, amount);
            ps.setString(4, transactionType);
            ps.setString(5, description);

            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Create a transaction record and return the generated transaction_id.
     * @return transaction_id if successful, -1 otherwise
     */
    public int createTransactionAndGetId(int userId, Integer orderId, BigDecimal amount,
                                         String transactionType, String description) throws SQLException {
        String sql = "INSERT INTO transactions (user_id, order_id, amount, transaction_type, description, status, created_at, updated_at, is_deleted) "
                   + "VALUES (?, ?, ?, ?, ?, 'SUCCESS', NOW(), NOW(), 0)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, userId);
            if (orderId != null) {
                ps.setInt(2, orderId);
            } else {
                ps.setNull(2, java.sql.Types.INTEGER);
            }
            ps.setBigDecimal(3, amount);
            ps.setString(4, transactionType);
            ps.setString(5, description);

            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                try (java.sql.ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
            return -1;
        }
    }

    /**
     * Update user balance.
     */
    public boolean updateUserBalance(int userId, BigDecimal newBalance) throws SQLException {
        String sql = "UPDATE users SET balance = ?, updated_at = NOW() WHERE user_id = ? AND is_deleted = 0";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setBigDecimal(1, newBalance);
            ps.setInt(2, userId);

            return ps.executeUpdate() > 0;
        }
    }
    
    /**
     * Lấy lịch sử giao dịch của user (cho User) với phân trang
     * @param userId ID của user
     * @param transactionType Lọc theo loại (null = tất cả)
     * @param fromDate Từ ngày (null = không lọc)
     * @param toDate Đến ngày (null = không lọc)
     * @param page Số trang (bắt đầu từ 1)
     * @param pageSize Số bản ghi mỗi trang
     * @return Danh sách transaction
     */
    public List<Transaction> getUserTransactions(int userId, String transactionType, 
                                                  java.sql.Date fromDate, java.sql.Date toDate,
                                                  int page, int pageSize) 
            throws SQLException {
        List<Transaction> transactions = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT t.*, u.username, u.full_name, u.balance ");
        sql.append("FROM transactions t ");
        sql.append("INNER JOIN users u ON t.user_id = u.user_id ");
        sql.append("WHERE t.user_id = ? AND t.is_deleted = 0 ");
        
        List<Object> params = new ArrayList<>();
        params.add(userId);
        
        if (transactionType != null && !transactionType.isEmpty()) {
            sql.append("AND t.transaction_type = ? ");
            params.add(transactionType);
        }
        
        if (fromDate != null) {
            sql.append("AND DATE(t.created_at) >= ? ");
            params.add(fromDate);
        }
        
        if (toDate != null) {
            sql.append("AND DATE(t.created_at) <= ? ");
            params.add(toDate);
        }
        
        sql.append("ORDER BY t.created_at DESC ");
        
        // Add pagination
        if (page > 0 && pageSize > 0) {
            sql.append("LIMIT ? OFFSET ?");
            int offset = (page - 1) * pageSize;
            params.add(pageSize);
            params.add(offset);
        }
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int index = 1;
            for (Object param : params) {
                if (param instanceof Integer) {
                    ps.setInt(index++, (Integer) param);
                } else if (param instanceof String) {
                    ps.setString(index++, (String) param);
                } else if (param instanceof java.sql.Date) {
                    ps.setDate(index++, (java.sql.Date) param);
                }
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    transactions.add(mapResultSetToTransaction(rs));
                }
            }
        }
        
        return transactions;
    }
    
    /**
     * Đếm tổng số giao dịch của user (cho phân trang)
     */
    public int countUserTransactions(int userId, String transactionType, 
                                     java.sql.Date fromDate, java.sql.Date toDate) 
            throws SQLException {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) as total ");
        sql.append("FROM transactions t ");
        sql.append("WHERE t.user_id = ? AND t.is_deleted = 0 ");
        
        List<Object> params = new ArrayList<>();
        params.add(userId);
        
        if (transactionType != null && !transactionType.isEmpty()) {
            sql.append("AND t.transaction_type = ? ");
            params.add(transactionType);
        }
        
        if (fromDate != null) {
            sql.append("AND DATE(t.created_at) >= ? ");
            params.add(fromDate);
        }
        
        if (toDate != null) {
            sql.append("AND DATE(t.created_at) <= ? ");
            params.add(toDate);
        }
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int index = 1;
            for (Object param : params) {
                if (param instanceof Integer) {
                    ps.setInt(index++, (Integer) param);
                } else if (param instanceof String) {
                    ps.setString(index++, (String) param);
                } else if (param instanceof java.sql.Date) {
                    ps.setDate(index++, (java.sql.Date) param);
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
    
    /**
     * Lấy số dư hiện tại của user
     */
    public BigDecimal getCurrentBalance(int userId) throws SQLException {
        String sql = "SELECT balance FROM users WHERE user_id = ? AND is_deleted = 0";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getBigDecimal("balance");
                }
            }
        }
        
        return BigDecimal.ZERO;
    }
    
    /**
     * Lấy tất cả giao dịch nạp tiền (cho Admin) với phân trang
     * @param userId Lọc theo user (null = tất cả)
     * @param fromDate Từ ngày
     * @param toDate Đến ngày
     * @param page Số trang (bắt đầu từ 1)
     * @param pageSize Số bản ghi mỗi trang
     * @return Danh sách transaction DEPOSIT
     */
    public List<Transaction> getAllDepositTransactions(Integer userId, 
                                                       java.sql.Date fromDate, 
                                                       java.sql.Date toDate,
                                                       int page, int pageSize) 
            throws SQLException {
        List<Transaction> transactions = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT t.*, u.username, u.full_name, u.email, u.phone_number ");
        sql.append("FROM transactions t ");
        sql.append("INNER JOIN users u ON t.user_id = u.user_id ");
        sql.append("WHERE t.transaction_type = 'DEPOSIT' AND t.is_deleted = 0 ");
        
        List<Object> params = new ArrayList<>();
        
        if (userId != null) {
            sql.append("AND t.user_id = ? ");
            params.add(userId);
        }
        
        if (fromDate != null) {
            sql.append("AND DATE(t.created_at) >= ? ");
            params.add(fromDate);
        }
        
        if (toDate != null) {
            sql.append("AND DATE(t.created_at) <= ? ");
            params.add(toDate);
        }
        
        sql.append("ORDER BY t.created_at DESC ");
        
        // Add pagination
        if (page > 0 && pageSize > 0) {
            sql.append("LIMIT ? OFFSET ?");
            int offset = (page - 1) * pageSize;
            params.add(pageSize);
            params.add(offset);
        }
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int index = 1;
            for (Object param : params) {
                if (param instanceof Integer) {
                    ps.setInt(index++, (Integer) param);
                } else if (param instanceof java.sql.Date) {
                    ps.setDate(index++, (java.sql.Date) param);
                }
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    transactions.add(mapResultSetToTransaction(rs));
                }
            }
        }
        
        return transactions;
    }
    
    /**
     * Đếm tổng số giao dịch nạp tiền (cho phân trang)
     */
    public int countDepositTransactions(Integer userId, 
                                        java.sql.Date fromDate, 
                                        java.sql.Date toDate) 
            throws SQLException {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) as total ");
        sql.append("FROM transactions t ");
        sql.append("WHERE t.transaction_type = 'DEPOSIT' AND t.is_deleted = 0 ");
        
        List<Object> params = new ArrayList<>();
        
        if (userId != null) {
            sql.append("AND t.user_id = ? ");
            params.add(userId);
        }
        
        if (fromDate != null) {
            sql.append("AND DATE(t.created_at) >= ? ");
            params.add(fromDate);
        }
        
        if (toDate != null) {
            sql.append("AND DATE(t.created_at) <= ? ");
            params.add(toDate);
        }
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int index = 1;
            for (Object param : params) {
                if (param instanceof Integer) {
                    ps.setInt(index++, (Integer) param);
                } else if (param instanceof java.sql.Date) {
                    ps.setDate(index++, (java.sql.Date) param);
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
    
    /**
     * Tính tổng số tiền nạp vào (cho Admin)
     */
    public BigDecimal getTotalDepositAmount(Integer userId, 
                                           java.sql.Date fromDate, 
                                           java.sql.Date toDate) 
            throws SQLException {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COALESCE(SUM(amount), 0) as total ");
        sql.append("FROM transactions ");
        sql.append("WHERE transaction_type = 'DEPOSIT' AND status = 'SUCCESS' AND is_deleted = 0 ");
        
        List<Object> params = new ArrayList<>();
        
        if (userId != null) {
            sql.append("AND user_id = ? ");
            params.add(userId);
        }
        
        if (fromDate != null) {
            sql.append("AND DATE(created_at) >= ? ");
            params.add(fromDate);
        }
        
        if (toDate != null) {
            sql.append("AND DATE(created_at) <= ? ");
            params.add(toDate);
        }
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int index = 1;
            for (Object param : params) {
                if (param instanceof Integer) {
                    ps.setInt(index++, (Integer) param);
                } else if (param instanceof java.sql.Date) {
                    ps.setDate(index++, (java.sql.Date) param);
                }
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getBigDecimal("total");
                }
            }
        }
        
        return BigDecimal.ZERO;
    }
    
    /**
     * Map ResultSet to Transaction
     */
    private Transaction mapResultSetToTransaction(ResultSet rs) throws SQLException {
        Transaction transaction = new Transaction();
        transaction.setTransactionId(rs.getInt("transaction_id"));
        transaction.setUserId(rs.getInt("user_id"));
        
        int orderId = rs.getInt("order_id");
        if (!rs.wasNull()) {
            transaction.setOrderId(orderId);
        }
        
        transaction.setAmount(rs.getBigDecimal("amount"));
        transaction.setTransactionType(rs.getString("transaction_type"));
        transaction.setDescription(rs.getString("description"));
        transaction.setStatus(rs.getString("status"));
        
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            transaction.setCreatedAt(createdAt);
        }
        
        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            transaction.setUpdatedAt(updatedAt);
        }
        
        transaction.setDeleted(rs.getBoolean("is_deleted"));
        
        // Map User info if available
        try {
            User user = new User();
            user.setUserId(rs.getInt("user_id"));
            if (rs.getString("username") != null) {
                user.setUsername(rs.getString("username"));
            }
            if (rs.getString("full_name") != null) {
                user.setFullName(rs.getString("full_name"));
            }
            if (rs.getString("email") != null) {
                user.setEmail(rs.getString("email"));
            }
            if (rs.getString("phone_number") != null) {
                user.setPhoneNumber(rs.getString("phone_number"));
            }
            transaction.setUser(user);
        } catch (SQLException e) {
            // Ignore if columns don't exist
        }
        
        return transaction;
    }
}



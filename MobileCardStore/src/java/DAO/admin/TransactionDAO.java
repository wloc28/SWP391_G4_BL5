package DAO.admin;

import DAO.DBConnection;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

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
}



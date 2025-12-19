package DAO.admin;

import DAO.DBConnection;
import Models.PaymentGatewayTransaction;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * PaymentGatewayTransactionDAO - handles payment_gateway_transactions table operations.
 */
public class PaymentGatewayTransactionDAO {

    /**
     * Create a payment gateway transaction record.
     * @return true if successful, false otherwise
     */
    public boolean createPaymentGatewayTransaction(int transactionId, String gatewayName,
                                                   String paymentRefId, String gatewayTransactionId,
                                                   BigDecimal amount, String bankCode,
                                                   String responseCode, String fullResponseLog,
                                                   Integer createdBy) {
        String sql = "INSERT INTO payment_gateway_transactions " +
                     "(transaction_id, gateway_name, payment_ref_id, gateway_transaction_id, " +
                     "amount, bank_code, response_code, full_response_log, created_at, updated_at, " +
                     "is_deleted, created_by) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW(), 0, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, transactionId);
            ps.setString(2, gatewayName); // 'VNPAY', 'MOMO', hoặc 'PAYOS' (cần update enum trong DB)
            ps.setString(3, paymentRefId);
            ps.setString(4, gatewayTransactionId);
            if (amount != null) {
                ps.setBigDecimal(5, amount);
            } else {
                ps.setNull(5, java.sql.Types.DECIMAL);
            }
            ps.setString(6, bankCode);
            ps.setString(7, responseCode);
            ps.setString(8, fullResponseLog);
            if (createdBy != null) {
                ps.setInt(9, createdBy);
            } else {
                ps.setNull(9, java.sql.Types.INTEGER);
            }

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Update payment gateway transaction with gateway transaction ID and response code.
     */
    public boolean updatePaymentGatewayTransaction(int transactionId, String gatewayTransactionId,
                                                   String responseCode, String fullResponseLog) {
        String sql = "UPDATE payment_gateway_transactions " +
                     "SET gateway_transaction_id = ?, response_code = ?, full_response_log = ?, " +
                     "updated_at = NOW() " +
                     "WHERE transaction_id = ? AND is_deleted = 0";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, gatewayTransactionId);
            ps.setString(2, responseCode);
            ps.setString(3, fullResponseLog);
            ps.setInt(4, transactionId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Get payment gateway transaction by transaction_id.
     */
    public PaymentGatewayTransaction getByTransactionId(int transactionId) {
        String sql = "SELECT pg_id, transaction_id, gateway_name, payment_ref_id, " +
                     "gateway_transaction_id, amount, bank_code, response_code, " +
                     "full_response_log, created_at " +
                     "FROM payment_gateway_transactions " +
                     "WHERE transaction_id = ? AND is_deleted = 0";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, transactionId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                PaymentGatewayTransaction pgt = new PaymentGatewayTransaction();
                pgt.setPgId(rs.getInt("pg_id"));
                pgt.setTransactionId(rs.getInt("transaction_id"));
                pgt.setGatewayName(rs.getString("gateway_name"));
                pgt.setPaymentRefId(rs.getString("payment_ref_id"));
                pgt.setGatewayTransactionId(rs.getString("gateway_transaction_id"));
                pgt.setAmount(rs.getBigDecimal("amount"));
                pgt.setBankCode(rs.getString("bank_code"));
                pgt.setResponseCode(rs.getString("response_code"));
                pgt.setFullResponseLog(rs.getString("full_response_log"));
                pgt.setCreatedAt(rs.getTimestamp("created_at"));
                return pgt;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}


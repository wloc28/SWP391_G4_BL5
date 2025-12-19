package DAO.admin;

import DAO.DBConnection;
import Models.Card;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * Card DAO
 * Xử lý các thao tác database cho Cards (thẻ từ nhà cung cấp)
 */
public class CardDAO {
    
    /**
     * Lấy các thẻ AVAILABLE từ provider_storage_id
     */
    public List<Card> getAvailableCardsByProviderStorageId(int providerStorageId, int limit) throws SQLException {
        List<Card> cards = new ArrayList<>();
        String sql = "SELECT * FROM cards " +
                     "WHERE provider_storage_id = ? AND status = 'AVAILABLE' AND is_deleted = 0 " +
                     "ORDER BY created_at ASC " +
                     "LIMIT ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, providerStorageId);
            ps.setInt(2, limit);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    cards.add(mapResultSetToCard(rs));
                }
            }
        }
        
        return cards;
    }
    
    /**
     * Cập nhật trạng thái thẻ thành IMPORTED
     */
    public boolean markCardsAsImported(List<Integer> cardIds, int importedBy) throws SQLException {
        if (cardIds == null || cardIds.isEmpty()) {
            return false;
        }
        
        // Tạo placeholders cho IN clause
        StringBuilder placeholders = new StringBuilder();
        for (int i = 0; i < cardIds.size(); i++) {
            if (i > 0) placeholders.append(",");
            placeholders.append("?");
        }
        
        String sql = "UPDATE cards SET status = 'IMPORTED', imported_at = NOW(), imported_by = ?, updated_at = NOW() " +
                     "WHERE card_id IN (" + placeholders.toString() + ") " +
                     "AND is_deleted = 0";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, importedBy);
            
            // Set card IDs
            for (int i = 0; i < cardIds.size(); i++) {
                ps.setInt(i + 2, cardIds.get(i));
            }
            
            return ps.executeUpdate() > 0;
        }
    }
    
    /**
     * Map ResultSet to Card object
     */
    private Card mapResultSetToCard(ResultSet rs) throws SQLException {
        Card card = new Card();
        card.setCardId(rs.getInt("card_id"));
        card.setProviderStorageId(rs.getInt("provider_storage_id"));
        card.setSerialNumber(rs.getString("serial_number"));
        card.setCardCode(rs.getString("card_code"));
        
        Date expiryDate = rs.getDate("expiry_date");
        if (expiryDate != null) {
            card.setExpiryDate(expiryDate);
        }
        
        card.setStatus(rs.getString("status"));
        
        Timestamp importedAt = rs.getTimestamp("imported_at");
        if (importedAt != null) {
            card.setImportedAt(importedAt);
        }
        
        int importedBy = rs.getInt("imported_by");
        if (!rs.wasNull()) {
            card.setImportedBy(importedBy);
        }
        
        card.setErrorMessage(rs.getString("error_message"));
        card.setCreatedAt(rs.getTimestamp("created_at"));
        card.setUpdatedAt(rs.getTimestamp("updated_at"));
        card.setDeleted(rs.getBoolean("is_deleted"));
        
        return card;
    }
}


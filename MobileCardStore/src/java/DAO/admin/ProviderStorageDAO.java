package DAO.admin;

import DAO.DBConnection;
import Models.ProviderStorage;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * ProviderStorage DAO
 * Xử lý các thao tác database cho ProviderStorage (sản phẩm từ nhà cung cấp)
 */
public class ProviderStorageDAO {
    
    /**
     * Lấy tất cả sản phẩm của provider (grouped by provider_name)
     */
    public Map<String, List<ProviderStorage>> getProviderStoragesGrouped() throws SQLException {
        Map<String, List<ProviderStorage>> result = new LinkedHashMap<>();
        String sql = "SELECT ps.*, p.provider_name " +
                     "FROM provider_storage ps " +
                     "INNER JOIN providers p ON ps.provider_id = p.provider_id " +
                     "WHERE ps.is_deleted = 0 AND ps.status = 'ACTIVE' " +
                     "ORDER BY p.provider_name, ps.price ASC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                ProviderStorage providerStorage = mapResultSetToProviderStorage(rs);
                String providerName = rs.getString("provider_name");
                
                if (!result.containsKey(providerName)) {
                    result.put(providerName, new ArrayList<>());
                }
                result.get(providerName).add(providerStorage);
            }
        }
        
        return result;
    }
    
    /**
     * Lấy tất cả sản phẩm của một provider cụ thể
     */
    public List<ProviderStorage> getProviderStoragesByProviderName(String providerName) throws SQLException {
        List<ProviderStorage> storages = new ArrayList<>();
        String sql = "SELECT ps.*, p.provider_name " +
                     "FROM provider_storage ps " +
                     "INNER JOIN providers p ON ps.provider_id = p.provider_id " +
                     "WHERE p.provider_name = ? AND ps.is_deleted = 0 AND ps.status = 'ACTIVE' " +
                     "ORDER BY ps.price ASC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, providerName);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    storages.add(mapResultSetToProviderStorage(rs));
                }
            }
        }
        
        return storages;
    }
    
    /**
     * Lấy sản phẩm provider_storage theo ID
     */
    public ProviderStorage getProviderStorageById(int providerStorageId) throws SQLException {
        String sql = "SELECT ps.*, p.provider_name " +
                     "FROM provider_storage ps " +
                     "INNER JOIN providers p ON ps.provider_id = p.provider_id " +
                     "WHERE ps.provider_storage_id = ? AND ps.is_deleted = 0";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, providerStorageId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToProviderStorage(rs);
                }
            }
        }
        
        return null;
    }
    
    /**
     * Cập nhật available_quantity trong provider_storage
     */
    public void updateAvailableQuantity(int providerStorageId) throws SQLException {
        String sql = "UPDATE provider_storage ps " +
                     "SET ps.available_quantity = (" +
                     "    SELECT COUNT(*) " +
                     "    FROM cards c " +
                     "    WHERE c.provider_storage_id = ps.provider_storage_id " +
                     "    AND c.status = 'AVAILABLE' " +
                     "    AND c.is_deleted = 0" +
                     ") " +
                     "WHERE ps.provider_storage_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, providerStorageId);
            stmt.executeUpdate();
        }
    }
    
    /**
     * Lấy danh sách tất cả provider names (unique)
     */
    public List<String> getAllProviderNames() throws SQLException {
        List<String> names = new ArrayList<>();
        String sql = "SELECT DISTINCT p.provider_name " +
                     "FROM providers p " +
                     "INNER JOIN provider_storage ps ON p.provider_id = ps.provider_id " +
                     "WHERE ps.is_deleted = 0 AND ps.status = 'ACTIVE' " +
                     "ORDER BY p.provider_name";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                names.add(rs.getString("provider_name"));
            }
        }
        
        return names;
    }
    
    /**
     * Map ResultSet to ProviderStorage object
     */
    private ProviderStorage mapResultSetToProviderStorage(ResultSet rs) throws SQLException {
        ProviderStorage storage = new ProviderStorage();
        storage.setProviderStorageId(rs.getInt("provider_storage_id"));
        storage.setProviderId(rs.getInt("provider_id"));
        storage.setProductCode(rs.getString("product_code"));
        storage.setProductName(rs.getString("product_name"));
        
        if (rs.getObject("price") != null) {
            storage.setPrice(rs.getBigDecimal("price"));
        }
        if (rs.getObject("purchase_price") != null) {
            storage.setPurchasePrice(rs.getBigDecimal("purchase_price"));
        }
        
        storage.setAvailableQuantity(rs.getInt("available_quantity"));
        storage.setImageUrl(rs.getString("image_url"));
        storage.setStatus(rs.getString("status"));
        storage.setCreatedAt(rs.getTimestamp("created_at"));
        storage.setUpdatedAt(rs.getTimestamp("updated_at"));
        storage.setDeleted(rs.getBoolean("is_deleted"));
        
        int createdBy = rs.getInt("created_by");
        if (!rs.wasNull()) {
            storage.setCreatedBy(createdBy);
        }
        
        int deletedBy = rs.getInt("deleted_by");
        if (!rs.wasNull()) {
            storage.setDeletedBy(deletedBy);
        }
        
        // Set provider name if available
        if (rs.getString("provider_name") != null) {
            Models.Provider provider = new Models.Provider();
            provider.setProviderName(rs.getString("provider_name"));
            storage.setProvider(provider);
        }
        
        return storage;
    }
}




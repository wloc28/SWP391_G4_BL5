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
     * Lấy tất cả sản phẩm của một provider cụ thể với phân trang
     */
    public List<ProviderStorage> getProviderStoragesByProviderName(String providerName, int page, int pageSize) throws SQLException {
        List<ProviderStorage> storages = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT ps.*, p.provider_name ");
        sql.append("FROM provider_storage ps ");
        sql.append("INNER JOIN providers p ON ps.provider_id = p.provider_id ");
        sql.append("WHERE p.provider_name = ? AND ps.is_deleted = 0 AND ps.status = 'ACTIVE' ");
        sql.append("ORDER BY ps.price ASC");
        
        // Add pagination
        if (page > 0 && pageSize > 0) {
            sql.append(" LIMIT ? OFFSET ?");
        }
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            stmt.setString(paramIndex++, providerName);
            
            if (page > 0 && pageSize > 0) {
                int offset = (page - 1) * pageSize;
                stmt.setInt(paramIndex++, pageSize);
                stmt.setInt(paramIndex++, offset);
            }
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    storages.add(mapResultSetToProviderStorage(rs));
                }
            }
        }
        
        return storages;
    }
    
    /**
     * Lấy tất cả sản phẩm của một provider cụ thể (không phân trang - để tương thích)
     */
    public List<ProviderStorage> getProviderStoragesByProviderName(String providerName) throws SQLException {
        return getProviderStoragesByProviderName(providerName, 0, 0);
    }
    
    /**
     * Lấy tất cả sản phẩm với phân trang (không group)
     */
    public List<ProviderStorage> getAllProviderStorages(int page, int pageSize) throws SQLException {
        List<ProviderStorage> storages = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT ps.*, p.provider_name ");
        sql.append("FROM provider_storage ps ");
        sql.append("INNER JOIN providers p ON ps.provider_id = p.provider_id ");
        sql.append("WHERE ps.is_deleted = 0 AND ps.status = 'ACTIVE' ");
        sql.append("ORDER BY p.provider_name, ps.price ASC");
        
        // Add pagination
        if (page > 0 && pageSize > 0) {
            sql.append(" LIMIT ? OFFSET ?");
        }
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            
            if (page > 0 && pageSize > 0) {
                int offset = (page - 1) * pageSize;
                stmt.setInt(1, pageSize);
                stmt.setInt(2, offset);
            }
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    storages.add(mapResultSetToProviderStorage(rs));
                }
            }
        }
        
        return storages;
    }
    
    /**
     * Đếm tổng số provider storages
     */
    public int countProviderStorages(String providerName) throws SQLException {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) as total ");
        sql.append("FROM provider_storage ps ");
        sql.append("INNER JOIN providers p ON ps.provider_id = p.provider_id ");
        sql.append("WHERE ps.is_deleted = 0 AND ps.status = 'ACTIVE' ");
        
        if (providerName != null && !providerName.trim().isEmpty()) {
            sql.append("AND p.provider_name = ?");
        }
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            
            if (providerName != null && !providerName.trim().isEmpty()) {
                stmt.setString(1, providerName);
            }
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total");
                }
            }
        }
        
        return 0;
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




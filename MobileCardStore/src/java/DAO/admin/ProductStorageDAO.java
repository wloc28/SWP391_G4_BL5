package DAO.admin;

import DAO.DBConnection;
import Models.ProductStorage;
import Models.ProductStorageGroup;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Product Storage DAO
 * Xử lý các thao tác database cho Product Storage
 */
public class ProductStorageDAO {
    
    /**
     * Lấy tất cả storage items (không bị xóa)
     */
    public List<ProductStorage> getAllStorageItems() throws SQLException {
        List<ProductStorage> items = new ArrayList<>();
        String sql = "SELECT * FROM product_storage " +
                     "WHERE is_deleted = 0 " +
                     "ORDER BY created_at DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                ProductStorage item = mapResultSetToStorage(rs);
                items.add(item);
            }
        }
        
        return items;
    }
    
    /**
     * Lấy storage item theo ID
     */
    public ProductStorage getStorageItemById(int storageId) throws SQLException {
        String sql = "SELECT * FROM product_storage " +
                     "WHERE storage_id = ? AND is_deleted = 0";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, storageId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToStorage(rs);
                }
            }
        }
        
        return null;
    }
    
    /**
     * Lấy storage items theo product_code
     */
    public List<ProductStorage> getStorageItemsByProductCode(String productCode) throws SQLException {
        List<ProductStorage> items = new ArrayList<>();
        String sql = "SELECT * FROM product_storage " +
                     "WHERE product_code = ? AND is_deleted = 0 " +
                     "ORDER BY created_at DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, productCode);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductStorage item = mapResultSetToStorage(rs);
                    items.add(item);
                }
            }
        }
        
        return items;
    }
    
    /**
     * Thêm storage item mới
     */
    public boolean addStorageItem(ProductStorage item) throws SQLException {
        String sql = "INSERT INTO product_storage " +
                     "(card_id, provider_storage_id, provider_id, provider_name, product_code, product_name, " +
                     "price, purchase_price, serial_number, card_code, expiry_date, status, created_by, created_at, updated_at, is_deleted) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW(), 0)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            int paramIndex = 1;
            if (item.getCardId() != null) {
                ps.setInt(paramIndex++, item.getCardId());
            } else {
                ps.setNull(paramIndex++, java.sql.Types.INTEGER);
            }
            
            if (item.getProviderStorageId() != null) {
                ps.setInt(paramIndex++, item.getProviderStorageId());
            } else {
                ps.setNull(paramIndex++, java.sql.Types.INTEGER);
            }
            
            ps.setInt(paramIndex++, item.getProviderId());
            ps.setString(paramIndex++, item.getProviderName());
            ps.setString(paramIndex++, item.getProductCode());
            ps.setString(paramIndex++, item.getProductName());
            ps.setBigDecimal(paramIndex++, item.getPrice());
            
            if (item.getPurchasePrice() != null) {
                ps.setBigDecimal(paramIndex++, item.getPurchasePrice());
            } else {
                ps.setNull(paramIndex++, java.sql.Types.DECIMAL);
            }
            
            ps.setString(paramIndex++, item.getSerialNumber());
            ps.setString(paramIndex++, item.getCardCode());
            
            if (item.getExpiryDate() != null) {
                ps.setDate(paramIndex++, item.getExpiryDate());
            } else {
                ps.setNull(paramIndex++, java.sql.Types.DATE);
            }
            
            ps.setString(paramIndex++, item.getStatus());
            
            if (item.getCreatedBy() != null) {
                ps.setInt(paramIndex++, item.getCreatedBy());
            } else {
                ps.setNull(paramIndex++, java.sql.Types.INTEGER);
            }
            
            return ps.executeUpdate() > 0;
        }
    }
    
    /**
     * Cập nhật storage item
     */
    public boolean updateStorageItem(ProductStorage item) throws SQLException {
        String sql = "UPDATE product_storage SET " +
                     "serial_number = ?, card_code = ?, expiry_date = ?, status = ?, " +
                     "error_message = ?, updated_at = NOW() " +
                     "WHERE storage_id = ? AND is_deleted = 0";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, item.getSerialNumber());
            ps.setString(2, item.getCardCode());
            
            if (item.getExpiryDate() != null) {
                ps.setDate(3, item.getExpiryDate());
            } else {
                ps.setNull(3, java.sql.Types.DATE);
            }
            
            ps.setString(4, item.getStatus());
            
            if (item.getErrorMessage() != null) {
                ps.setString(5, item.getErrorMessage());
            } else {
                ps.setNull(5, java.sql.Types.VARCHAR);
            }
            
            ps.setInt(6, item.getStorageId());
            
            return ps.executeUpdate() > 0;
        }
    }
    
    /**
     * Xóa storage item (soft delete)
     */
    public boolean deleteStorageItem(int storageId) throws SQLException {
        String sql = "UPDATE product_storage SET is_deleted = 1, updated_at = NOW() WHERE storage_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, storageId);
            
            return ps.executeUpdate() > 0;
        }
    }
    
    /**
     * Đếm số lượng items available theo product_code
     */
    public int countAvailableItemsByProductCode(String productCode) throws SQLException {
        String sql = "SELECT COUNT(*) as count FROM product_storage " +
                     "WHERE product_code = ? AND status = 'AVAILABLE' AND is_deleted = 0";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, productCode);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count");
                }
            }
        }
        
        return 0;
    }
    
    /**
     * Tìm kiếm storage items theo nhiều tiêu chí
     * @param searchKeyword từ khóa tìm kiếm (tìm trong product name, serial, card code)
     * @param status trạng thái (AVAILABLE, SOLD, ERROR, hoặc null/empty cho tất cả)
     * @return danh sách storage items phù hợp
     */
    public List<ProductStorage> searchStorageItems(String searchKeyword, String status) throws SQLException {
        List<ProductStorage> items = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT * FROM product_storage ")
           .append("WHERE is_deleted = 0 ");
        
        // Thêm điều kiện tìm kiếm theo từ khóa
        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            sql.append("AND (product_name LIKE ? OR serial_number LIKE ? OR card_code LIKE ? OR product_code LIKE ?) ");
        }
        
        // Thêm điều kiện lọc theo trạng thái
        if (status != null && !status.trim().isEmpty() && !status.equals("ALL")) {
            sql.append("AND status = ? ");
        }
        
        sql.append("ORDER BY created_at DESC");
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            
            // Set parameters cho từ khóa tìm kiếm
            if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
                String searchPattern = "%" + searchKeyword.trim() + "%";
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
            }
            
            // Set parameter cho trạng thái
            if (status != null && !status.trim().isEmpty() && !status.equals("ALL")) {
                ps.setString(paramIndex++, status);
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductStorage item = mapResultSetToStorage(rs);
                    items.add(item);
                }
            }
        }
        
        return items;
    }
    
    /**
     * Tìm kiếm storage items với phân trang
     * @param searchKeyword từ khóa tìm kiếm
     * @param status trạng thái
     * @param offset vị trí bắt đầu
     * @param limit số lượng items mỗi trang
     * @return danh sách storage items
     */
    public List<ProductStorage> searchStorageItemsWithPagination(String searchKeyword, String status, int offset, int limit) throws SQLException {
        List<ProductStorage> items = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT * FROM product_storage ")
           .append("WHERE is_deleted = 0 ");
        
        // Thêm điều kiện tìm kiếm theo từ khóa
        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            sql.append("AND (product_name LIKE ? OR serial_number LIKE ? OR card_code LIKE ? OR product_code LIKE ?) ");
        }
        
        // Thêm điều kiện lọc theo trạng thái
        if (status != null && !status.trim().isEmpty() && !status.equals("ALL")) {
            sql.append("AND status = ? ");
        }
        
        sql.append("ORDER BY created_at DESC ");
        sql.append("LIMIT ? OFFSET ?");
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            
            // Set parameters cho từ khóa tìm kiếm
            if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
                String searchPattern = "%" + searchKeyword.trim() + "%";
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
            }
            
            // Set parameter cho trạng thái
            if (status != null && !status.trim().isEmpty() && !status.equals("ALL")) {
                ps.setString(paramIndex++, status);
            }
            
            // Set pagination parameters
            ps.setInt(paramIndex++, limit);
            ps.setInt(paramIndex++, offset);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductStorage item = mapResultSetToStorage(rs);
                    items.add(item);
                }
            }
        }
        
        return items;
    }
    
    /**
     * Đếm tổng số storage items theo điều kiện tìm kiếm
     * @param searchKeyword từ khóa tìm kiếm
     * @param status trạng thái
     * @return tổng số items
     */
    public int countStorageItems(String searchKeyword, String status) throws SQLException {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) as total ")
           .append("FROM product_storage ")
           .append("WHERE is_deleted = 0 ");
        
        // Thêm điều kiện tìm kiếm theo từ khóa
        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            sql.append("AND (product_name LIKE ? OR serial_number LIKE ? OR card_code LIKE ? OR product_code LIKE ?) ");
        }
        
        // Thêm điều kiện lọc theo trạng thái
        if (status != null && !status.trim().isEmpty() && !status.equals("ALL")) {
            sql.append("AND status = ? ");
        }
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            
            // Set parameters cho từ khóa tìm kiếm
            if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
                String searchPattern = "%" + searchKeyword.trim() + "%";
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
            }
            
            // Set parameter cho trạng thái
            if (status != null && !status.trim().isEmpty() && !status.equals("ALL")) {
                ps.setString(paramIndex++, status);
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
     * Lấy danh sách nhóm theo product_code (group by) với phân trang
     * @param providerName Lọc theo nhà cung cấp (null = tất cả)
     * @param status Lọc theo trạng thái (null = tất cả)
     * @param page Số trang (bắt đầu từ 1)
     * @param pageSize Số bản ghi mỗi trang
     * @return Danh sách ProductStorageGroup
     */
    public List<ProductStorageGroup> getStorageGroupsByProviderAndStatus(String providerName, String status, 
                                                                          int page, int pageSize) throws SQLException {
        List<ProductStorageGroup> groups = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        
        sql.append("SELECT ")
           .append("    ps.product_code, ")
           .append("    ps.product_name, ")
           .append("    ps.provider_name, ")
           .append("    ps.provider_id, ")
           .append("    MAX(ps.price) as price, ")
           .append("    MAX(ps.purchase_price) as purchase_price, ")
           .append("    COUNT(*) as total_quantity, ")
           .append("    SUM(CASE WHEN ps.status = 'AVAILABLE' THEN 1 ELSE 0 END) as available_quantity, ")
           .append("    SUM(CASE WHEN ps.status = 'SOLD' THEN 1 ELSE 0 END) as sold_quantity, ")
           .append("    SUM(CASE WHEN ps.status = 'ERROR' THEN 1 ELSE 0 END) as error_quantity, ")
           .append("    SUM(CASE WHEN ps.status = 'EXPIRED' THEN 1 ELSE 0 END) as expired_quantity ")
           .append("FROM product_storage ps ")
           .append("WHERE ps.is_deleted = 0 ");
        
        List<Object> params = new ArrayList<>();
        
        if (providerName != null && !providerName.trim().isEmpty()) {
            sql.append("AND provider_name = ? ");
            params.add(providerName);
        }
        
        if (status != null && !status.trim().isEmpty() && !status.equals("ALL")) {
            sql.append("AND status = ? ");
            params.add(status);
        }
        
        sql.append("GROUP BY ps.product_code, ps.product_name, ps.provider_name, ps.provider_id ")
           .append("ORDER BY ps.provider_name, ps.product_code");
        
        // Add pagination
        if (page > 0 && pageSize > 0) {
            sql.append(" LIMIT ? OFFSET ?");
            int offset = (page - 1) * pageSize;
            params.add(pageSize);
            params.add(offset);
        }
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            for (Object param : params) {
                if (param instanceof String) {
                    ps.setString(paramIndex++, (String) param);
                } else if (param instanceof Integer) {
                    ps.setInt(paramIndex++, (Integer) param);
                }
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductStorageGroup group = new ProductStorageGroup();
                    group.setProductCode(rs.getString("product_code"));
                    group.setProductName(rs.getString("product_name"));
                    group.setProviderName(rs.getString("provider_name"));
                    group.setProviderId(rs.getInt("provider_id"));
                    
                    if (rs.getObject("price") != null) {
                        group.setPrice(rs.getBigDecimal("price"));
                    }
                    if (rs.getObject("purchase_price") != null) {
                        group.setPurchasePrice(rs.getBigDecimal("purchase_price"));
                    }
                    
                    group.setTotalQuantity(rs.getInt("total_quantity"));
                    group.setAvailableQuantity(rs.getInt("available_quantity"));
                    group.setSoldQuantity(rs.getInt("sold_quantity"));
                    group.setErrorQuantity(rs.getInt("error_quantity"));
                    group.setExpiredQuantity(rs.getInt("expired_quantity"));
                    
                    // Try to get status from product_status table
                    try {
                        String statusSql = "SELECT status FROM product_status WHERE product_code = ? AND provider_id = ?";
                        try (Connection conn2 = DBConnection.getConnection();
                             PreparedStatement statusPs = conn2.prepareStatement(statusSql)) {
                            statusPs.setString(1, rs.getString("product_code"));
                            statusPs.setInt(2, rs.getInt("provider_id"));
                            try (ResultSet statusRs = statusPs.executeQuery()) {
                                if (statusRs.next()) {
                                    group.setProductStatus(statusRs.getString("status"));
                                } else {
                                    // Default: ACTIVE if has available quantity, else INACTIVE
                                    group.setProductStatus(rs.getInt("available_quantity") > 0 ? "ACTIVE" : "INACTIVE");
                                }
                            }
                        }
                    } catch (SQLException e) {
                        // Table doesn't exist, calculate from available_quantity
                        group.setProductStatus(rs.getInt("available_quantity") > 0 ? "ACTIVE" : "INACTIVE");
                    }
                    
                    groups.add(group);
                }
            }
        }
        
        return groups;
    }
    
    /**
     * Đếm tổng số storage groups (cho phân trang)
     */
    public int countStorageGroups(String providerName, String status) throws SQLException {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(DISTINCT CONCAT(ps.product_code, '_', ps.provider_id)) as total ");
        sql.append("FROM product_storage ps ");
        sql.append("WHERE ps.is_deleted = 0 ");
        
        List<Object> params = new ArrayList<>();
        
        if (providerName != null && !providerName.trim().isEmpty()) {
            sql.append("AND provider_name = ? ");
            params.add(providerName);
        }
        
        if (status != null && !status.trim().isEmpty() && !status.equals("ALL")) {
            sql.append("AND status = ? ");
            params.add(status);
        }
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            for (Object param : params) {
                if (param instanceof String) {
                    ps.setString(paramIndex++, (String) param);
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
     * Lấy danh sách tất cả provider names có trong product_storage
     */
    public List<String> getAllProviderNames() throws SQLException {
        List<String> names = new ArrayList<>();
        String sql = "SELECT DISTINCT provider_name FROM product_storage " +
                     "WHERE is_deleted = 0 " +
                     "ORDER BY provider_name";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                names.add(rs.getString("provider_name"));
            }
        }
        
        return names;
    }
    
    /**
     * Cập nhật status cho tất cả thẻ có cùng product_code và provider_id
     * Nếu status = 'INACTIVE', sẽ đổi tất cả thẻ AVAILABLE thành một status đặc biệt để ẩn
     * Nếu status = 'ACTIVE', sẽ đổi lại các thẻ về AVAILABLE (nếu chúng chưa bị SOLD)
     * 
     * Note: Thực tế, ta sẽ dùng một cách khác - tạo bảng product_status hoặc dùng một field đặc biệt
     * Nhưng để đơn giản, ta sẽ dùng một status đặc biệt 'HIDDEN' để ẩn sản phẩm
     */
    /**
     * Cập nhật status của sản phẩm trong bảng product_status
     */
    public boolean updateProductStatus(String productCode, int providerId, String status, Integer updatedBy) throws SQLException {
        // Kiểm tra xem bảng product_status có tồn tại không
        String sql = """
            INSERT INTO product_status (product_code, provider_id, status, updated_by, updated_at)
            VALUES (?, ?, ?, ?, NOW())
            ON DUPLICATE KEY UPDATE 
                status = VALUES(status),
                updated_by = VALUES(updated_by),
                updated_at = NOW()
            """;
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, productCode);
            ps.setInt(2, providerId);
            ps.setString(3, status);
            if (updatedBy != null) {
                ps.setInt(4, updatedBy);
            } else {
                ps.setNull(4, java.sql.Types.INTEGER);
            }
            
            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            // Nếu bảng product_status chưa tồn tại, tạo nó tự động
            if (e.getMessage().contains("doesn't exist") || e.getMessage().contains("Unknown table")) {
                // Tạo bảng product_status
                String createTableSql = """
                    CREATE TABLE IF NOT EXISTS product_status (
                      id int NOT NULL AUTO_INCREMENT,
                      product_code varchar(50) NOT NULL,
                      provider_id int NOT NULL,
                      status enum('ACTIVE','INACTIVE') DEFAULT 'ACTIVE',
                      updated_at timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                      updated_by int DEFAULT NULL,
                      PRIMARY KEY (id),
                      UNIQUE KEY unique_product_provider (product_code, provider_id)
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
                    """;
                
                try (Connection conn = DBConnection.getConnection();
                     PreparedStatement createPs = conn.prepareStatement(createTableSql)) {
                    createPs.executeUpdate();
                }
                
                // Thử lại insert
                return updateProductStatus(productCode, providerId, status, updatedBy);
            }
            throw e;
        }
    }
    
    /**
     * Lấy status hiện tại của sản phẩm từ bảng product_status
     * Nếu không có trong product_status, sẽ tính từ available_count
     */
    public String getProductStatus(String productCode, int providerId) throws SQLException {
        // Thử lấy từ product_status trước
        try {
            String sql1 = "SELECT status FROM product_status WHERE product_code = ? AND provider_id = ?";
            
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql1)) {
                
                ps.setString(1, productCode);
                ps.setInt(2, providerId);
                
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getString("status");
                    }
                }
            }
        } catch (SQLException e) {
            // Bảng product_status chưa tồn tại, bỏ qua
        }
        
        // Nếu không có trong product_status, tính từ available_count
        String sql2 = """
            SELECT 
                CASE 
                    WHEN COUNT(CASE WHEN status = 'AVAILABLE' THEN 1 END) > 0 THEN 'ACTIVE'
                    ELSE 'INACTIVE'
                END as product_status
            FROM product_storage
            WHERE product_code = ? AND provider_id = ? AND is_deleted = 0
            """;
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql2)) {
            
            ps.setString(1, productCode);
            ps.setInt(2, providerId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String calculatedStatus = rs.getString("product_status");
                    // Tự động tạo record trong product_status với status tính được
                    if (calculatedStatus != null) {
                        try {
                            updateProductStatus(productCode, providerId, calculatedStatus, null);
                        } catch (Exception ex) {
                            // Ignore if table doesn't exist yet
                        }
                    }
                    return calculatedStatus;
                }
            }
        }
        
        return "INACTIVE";
    }
    
    /**
     * Lấy và đánh dấu sản phẩm là SOLD khi thanh toán
     * Trả về danh sách ProductStorage với serial_number và card_code
     */
    public List<ProductStorage> getAndMarkAsSold(String productCode, int providerId, int quantity, int orderId) throws SQLException {
        List<ProductStorage> soldItems = new ArrayList<>();
        
        // Lấy các sản phẩm AVAILABLE
        String selectSql = """
            SELECT * FROM product_storage 
            WHERE product_code = ? AND provider_id = ? 
            AND status = 'AVAILABLE' AND is_deleted = 0 
            ORDER BY created_at ASC 
            LIMIT ?
            """;
        
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false); // Bắt đầu transaction
            
            try (PreparedStatement selectPs = conn.prepareStatement(selectSql)) {
                selectPs.setString(1, productCode);
                selectPs.setInt(2, providerId);
                selectPs.setInt(3, quantity);
                
                try (ResultSet rs = selectPs.executeQuery()) {
                    while (rs.next()) {
                        ProductStorage item = mapResultSetToStorage(rs);
                        soldItems.add(item);
                    }
                }
            }
            
            // Kiểm tra đủ số lượng không
            if (soldItems.size() < quantity) {
                conn.rollback();
                throw new SQLException("Không đủ sản phẩm trong kho. Yêu cầu: " + quantity + ", có sẵn: " + soldItems.size());
            }
            
            // Đánh dấu các sản phẩm là SOLD
            String updateSql = """
                UPDATE product_storage 
                SET status = 'SOLD', 
                    sold_at = NOW(), 
                    sold_to_order_id = ?, 
                    updated_at = NOW() 
                WHERE storage_id = ?
                """;
            
            try (PreparedStatement updatePs = conn.prepareStatement(updateSql)) {
                for (ProductStorage item : soldItems) {
                    updatePs.setInt(1, orderId);
                    updatePs.setInt(2, item.getStorageId());
                    updatePs.addBatch();
                }
                updatePs.executeBatch();
            }
            
            conn.commit(); // Commit transaction
            return soldItems;
            
        } catch (SQLException e) {
            // Rollback sẽ được thực hiện trong finally hoặc catch
            throw e;
        }
    }
    
    /**
     * Map ResultSet to ProductStorage object
     */
    private ProductStorage mapResultSetToStorage(ResultSet rs) throws SQLException {
        ProductStorage item = new ProductStorage();
        item.setStorageId(rs.getInt("storage_id"));
        
        int cardId = rs.getInt("card_id");
        if (!rs.wasNull()) {
            item.setCardId(cardId);
        }
        
        int providerStorageId = rs.getInt("provider_storage_id");
        if (!rs.wasNull()) {
            item.setProviderStorageId(providerStorageId);
        }
        
        item.setProviderId(rs.getInt("provider_id"));
        item.setProviderName(rs.getString("provider_name"));
        item.setProductCode(rs.getString("product_code"));
        item.setProductName(rs.getString("product_name"));
        item.setPrice(rs.getBigDecimal("price"));
        
        if (rs.getObject("purchase_price") != null) {
            item.setPurchasePrice(rs.getBigDecimal("purchase_price"));
        }
        
        item.setSerialNumber(rs.getString("serial_number"));
        item.setCardCode(rs.getString("card_code"));
        item.setExpiryDate(rs.getDate("expiry_date"));
        item.setStatus(rs.getString("status"));
        
        item.setSoldAt(rs.getTimestamp("sold_at"));
        
        int soldToOrderId = rs.getInt("sold_to_order_id");
        if (!rs.wasNull()) {
            item.setSoldToOrderId(soldToOrderId);
        }
        
        item.setErrorMessage(rs.getString("error_message"));
        item.setCreatedAt(rs.getTimestamp("created_at"));
        item.setUpdatedAt(rs.getTimestamp("updated_at"));
        item.setDeleted(rs.getBoolean("is_deleted"));
        
        int createdBy = rs.getInt("created_by");
        if (!rs.wasNull()) {
            item.setCreatedBy(createdBy);
        }
        
        int deletedBy = rs.getInt("deleted_by");
        if (!rs.wasNull()) {
            item.setDeletedBy(deletedBy);
        }
        
        return item;
    }
}


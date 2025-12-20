package DAO.admin;

import DAO.DBConnection;
import Models.ImportTransaction;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * ImportTransaction DAO
 * Xử lý các thao tác database cho ImportTransaction (lịch sử nhập hàng)
 */
public class ImportTransactionDAO {
    
    /**
     * Tạo transaction nhập hàng
     */
    public boolean createImportTransaction(ImportTransaction transaction) throws SQLException {
        String sql = "INSERT INTO import_transactions " +
                     "(provider_storage_id, quantity, purchase_price, total_cost, imported_by, note, created_at, is_deleted) " +
                     "VALUES (?, ?, ?, ?, ?, ?, NOW(), 0)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, transaction.getProviderStorageId());
            ps.setInt(2, transaction.getQuantity());
            ps.setBigDecimal(3, transaction.getPurchasePrice());
            ps.setBigDecimal(4, transaction.getTotalCost());
            ps.setInt(5, transaction.getImportedBy());
            
            if (transaction.getNote() != null) {
                ps.setString(6, transaction.getNote());
            } else {
                ps.setNull(6, java.sql.Types.VARCHAR);
            }
            
            return ps.executeUpdate() > 0;
        }
    }
    
    /**
     * Lấy lịch sử nhập hàng với phân trang
     */
    public List<ImportTransaction> getImportHistory(String providerName, Date fromDate, Date toDate, 
                                                     int page, int pageSize) throws SQLException {
        List<ImportTransaction> transactions = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT it.*, ps.product_code, ps.product_name, ps.price, p.provider_name ");
        sql.append("FROM import_transactions it ");
        sql.append("INNER JOIN provider_storage ps ON it.provider_storage_id = ps.provider_storage_id ");
        sql.append("INNER JOIN providers p ON ps.provider_id = p.provider_id ");
        sql.append("WHERE it.is_deleted = 0 ");
        
        List<Object> params = new ArrayList<>();
        
        if (providerName != null && !providerName.isEmpty()) {
            sql.append("AND p.provider_name = ? ");
            params.add(providerName);
        }
        
        if (fromDate != null) {
            sql.append("AND DATE(it.created_at) >= ? ");
            params.add(fromDate);
        }
        
        if (toDate != null) {
            sql.append("AND DATE(it.created_at) <= ? ");
            params.add(toDate);
        }
        
        sql.append("ORDER BY it.created_at DESC");
        
        // Add pagination
        if (page > 0 && pageSize > 0) {
            sql.append(" LIMIT ? OFFSET ?");
            int offset = (page - 1) * pageSize;
            params.add(pageSize);
            params.add(offset);
        }
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int index = 1;
            for (Object param : params) {
                if (param instanceof String) {
                    ps.setString(index++, (String) param);
                } else if (param instanceof Date) {
                    ps.setDate(index++, (Date) param);
                } else if (param instanceof Integer) {
                    ps.setInt(index++, (Integer) param);
                }
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    transactions.add(mapResultSetToImportTransaction(rs));
                }
            }
        }
        
        return transactions;
    }
    
    /**
     * Đếm tổng số import transactions (cho phân trang)
     */
    public int countImportHistory(String providerName, Date fromDate, Date toDate) throws SQLException {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) as total ");
        sql.append("FROM import_transactions it ");
        sql.append("INNER JOIN provider_storage ps ON it.provider_storage_id = ps.provider_storage_id ");
        sql.append("INNER JOIN providers p ON ps.provider_id = p.provider_id ");
        sql.append("WHERE it.is_deleted = 0 ");
        
        List<Object> params = new ArrayList<>();
        
        if (providerName != null && !providerName.isEmpty()) {
            sql.append("AND p.provider_name = ? ");
            params.add(providerName);
        }
        
        if (fromDate != null) {
            sql.append("AND DATE(it.created_at) >= ? ");
            params.add(fromDate);
        }
        
        if (toDate != null) {
            sql.append("AND DATE(it.created_at) <= ? ");
            params.add(toDate);
        }
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int index = 1;
            for (Object param : params) {
                if (param instanceof String) {
                    ps.setString(index++, (String) param);
                } else if (param instanceof Date) {
                    ps.setDate(index++, (Date) param);
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
     * Tính tổng chi phí nhập hàng trong khoảng thời gian
     */
    public BigDecimal getTotalImportCost(Date fromDate, Date toDate) throws SQLException {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT SUM(total_cost) as total FROM import_transactions ");
        sql.append("WHERE is_deleted = 0 ");
        
        List<Object> params = new ArrayList<>();
        
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
                if (param instanceof Date) {
                    ps.setDate(index++, (Date) param);
                }
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    BigDecimal total = rs.getBigDecimal("total");
                    return total != null ? total : BigDecimal.ZERO;
                }
            }
        }
        
        return BigDecimal.ZERO;
    }
    
    /**
     * Map ResultSet to ImportTransaction object
     */
    private ImportTransaction mapResultSetToImportTransaction(ResultSet rs) throws SQLException {
        ImportTransaction transaction = new ImportTransaction();
        transaction.setImportId(rs.getInt("import_id"));
        transaction.setProviderStorageId(rs.getInt("provider_storage_id"));
        transaction.setQuantity(rs.getInt("quantity"));
        transaction.setPurchasePrice(rs.getBigDecimal("purchase_price"));
        transaction.setTotalCost(rs.getBigDecimal("total_cost"));
        transaction.setImportedBy(rs.getInt("imported_by"));
        transaction.setNote(rs.getString("note"));
        transaction.setCreatedAt(rs.getTimestamp("created_at"));
        transaction.setDeleted(rs.getBoolean("is_deleted"));
        
        // Set provider storage info if available
        if (rs.getString("product_code") != null) {
            Models.ProviderStorage providerStorage = new Models.ProviderStorage();
            providerStorage.setProductCode(rs.getString("product_code"));
            providerStorage.setProductName(rs.getString("product_name"));
            providerStorage.setPrice(rs.getBigDecimal("price"));
            
            if (rs.getString("provider_name") != null) {
                Models.Provider provider = new Models.Provider();
                provider.setProviderName(rs.getString("provider_name"));
                providerStorage.setProvider(provider);
            }
            
            transaction.setProviderStorage(providerStorage);
        }
        
        return transaction;
    }
}



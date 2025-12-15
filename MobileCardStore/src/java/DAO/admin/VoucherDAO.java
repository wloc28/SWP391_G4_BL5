package DAO.admin;

import DAO.DBConnection;
import Models.Voucher;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * Voucher DAO
 * Xử lý các thao tác database cho Voucher
 */
public class VoucherDAO {
    
    /**
     * Lấy tất cả voucher (không bị xóa)
     */
    public List<Voucher> getAllVouchers() throws SQLException {
        List<Voucher> vouchers = new ArrayList<>();
        String sql = "SELECT * FROM vouchers WHERE is_deleted = 0 ORDER BY created_at DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Voucher voucher = mapResultSetToVoucher(rs);
                vouchers.add(voucher);
            }
        }
        
        return vouchers;
    }
    
    /**
     * Tìm kiếm và filter voucher với phân trang
     */
    public List<Voucher> searchVouchers(String keyword, String status, String discountType, 
                                         String expiryFilter, int page, int pageSize) throws SQLException {
        List<Voucher> vouchers = new ArrayList<>();
        
        // Xây dựng SQL query động
        StringBuilder sql = new StringBuilder("SELECT * FROM vouchers WHERE is_deleted = 0");
        List<Object> params = new ArrayList<>();
        
        // Filter theo keyword (code)
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND code LIKE ?");
            params.add("%" + keyword.trim() + "%");
        }
        
        // Filter theo status
        if (status != null && !status.trim().isEmpty() && !status.equals("ALL")) {
            sql.append(" AND status = ?");
            params.add(status);
        }
        
        // Filter theo discount type
        if (discountType != null && !discountType.trim().isEmpty() && !discountType.equals("ALL")) {
            sql.append(" AND discount_type = ?");
            params.add(discountType);
        }
        
        // Filter theo expiry (sắp hết hạn hoặc đã hết hạn)
        if (expiryFilter != null && !expiryFilter.trim().isEmpty()) {
            if ("EXPIRING_SOON".equals(expiryFilter)) {
                // Sắp hết hạn trong 7 ngày tới
                sql.append(" AND expiry_date IS NOT NULL");
                sql.append(" AND expiry_date BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 7 DAY)");
                sql.append(" AND status = 'ACTIVE'");
            } else if ("EXPIRED".equals(expiryFilter)) {
                // Đã hết hạn
                sql.append(" AND expiry_date IS NOT NULL");
                sql.append(" AND expiry_date < NOW()");
            }
        }
        
        // Order by
        sql.append(" ORDER BY created_at DESC");
        
        // Phân trang
        sql.append(" LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            // Set parameters
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Voucher voucher = mapResultSetToVoucher(rs);
                    vouchers.add(voucher);
                }
            }
        }
        
        return vouchers;
    }
    
    /**
     * Đếm tổng số voucher theo filter (để phân trang)
     */
    public int countVouchers(String keyword, String status, String discountType, String expiryFilter) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) as total FROM vouchers WHERE is_deleted = 0");
        List<Object> params = new ArrayList<>();
        
        // Filter theo keyword (code)
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND code LIKE ?");
            params.add("%" + keyword.trim() + "%");
        }
        
        // Filter theo status
        if (status != null && !status.trim().isEmpty() && !status.equals("ALL")) {
            sql.append(" AND status = ?");
            params.add(status);
        }
        
        // Filter theo discount type
        if (discountType != null && !discountType.trim().isEmpty() && !discountType.equals("ALL")) {
            sql.append(" AND discount_type = ?");
            params.add(discountType);
        }
        
        // Filter theo expiry
        if (expiryFilter != null && !expiryFilter.trim().isEmpty()) {
            if ("EXPIRING_SOON".equals(expiryFilter)) {
                sql.append(" AND expiry_date IS NOT NULL");
                sql.append(" AND expiry_date BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 7 DAY)");
                sql.append(" AND status = 'ACTIVE'");
            } else if ("EXPIRED".equals(expiryFilter)) {
                sql.append(" AND expiry_date IS NOT NULL");
                sql.append(" AND expiry_date < NOW()");
            }
        }
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            // Set parameters
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
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
     * Lấy voucher theo ID
     */
    public Voucher getVoucherById(int voucherId) throws SQLException {
        String sql = "SELECT * FROM vouchers WHERE voucher_id = ? AND is_deleted = 0";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, voucherId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToVoucher(rs);
                }
            }
        }
        
        return null;
    }
    
    /**
     * Lấy voucher theo code
     */
    public Voucher getVoucherByCode(String code) throws SQLException {
        String sql = "SELECT * FROM vouchers WHERE code = ? AND is_deleted = 0";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, code);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToVoucher(rs);
                }
            }
        }
        
        return null;
    }
    
    /**
     * Kiểm tra code đã tồn tại chưa (trừ voucher hiện tại nếu đang edit)
     */
    public boolean isCodeExists(String code, int excludeVoucherId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM vouchers WHERE code = ? AND voucher_id != ? AND is_deleted = 0";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, code);
            ps.setInt(2, excludeVoucherId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        
        return false;
    }
    
    /**
     * Kiểm tra code đã tồn tại chưa (dùng khi thêm mới)
     */
    public boolean isCodeExists(String code) throws SQLException {
        String sql = "SELECT COUNT(*) FROM vouchers WHERE code = ? AND is_deleted = 0";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, code);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        
        return false;
    }
    
    /**
     * Thêm voucher mới
     */
    public boolean addVoucher(Voucher voucher) throws SQLException {
        String sql = "INSERT INTO vouchers (code, discount_type, discount_value, min_order_value, " +
                     "usage_limit, used_count, expiry_date, status, created_at, updated_at, is_deleted) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW(), 0)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, voucher.getCode());
            ps.setString(2, voucher.getDiscountType());
            ps.setBigDecimal(3, voucher.getDiscountValue());
            ps.setBigDecimal(4, voucher.getMinOrderValue());
            
            if (voucher.getUsageLimit() != null) {
                ps.setInt(5, voucher.getUsageLimit());
            } else {
                ps.setNull(5, java.sql.Types.INTEGER);
            }
            
            ps.setInt(6, voucher.getUsedCount());
            
            if (voucher.getExpiryDate() != null) {
                ps.setTimestamp(7, new Timestamp(voucher.getExpiryDate().getTime()));
            } else {
                ps.setNull(7, java.sql.Types.TIMESTAMP);
            }
            
            ps.setString(8, voucher.getStatus());
            
            return ps.executeUpdate() > 0;
        }
    }
    
    /**
     * Cập nhật voucher
     */
    public boolean updateVoucher(Voucher voucher) throws SQLException {
        String sql = "UPDATE vouchers SET discount_type = ?, discount_value = ?, min_order_value = ?, " +
                     "usage_limit = ?, expiry_date = ?, status = ?, updated_at = NOW() " +
                     "WHERE voucher_id = ? AND is_deleted = 0";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, voucher.getDiscountType());
            ps.setBigDecimal(2, voucher.getDiscountValue());
            ps.setBigDecimal(3, voucher.getMinOrderValue());
            
            if (voucher.getUsageLimit() != null) {
                ps.setInt(4, voucher.getUsageLimit());
            } else {
                ps.setNull(4, java.sql.Types.INTEGER);
            }
            
            if (voucher.getExpiryDate() != null) {
                ps.setTimestamp(5, new Timestamp(voucher.getExpiryDate().getTime()));
            } else {
                ps.setNull(5, java.sql.Types.TIMESTAMP);
            }
            
            ps.setString(6, voucher.getStatus());
            ps.setInt(7, voucher.getVoucherId());
            
            return ps.executeUpdate() > 0;
        }
    }
    
    /**
     * Xóa voucher (soft delete)
     */
    public boolean deleteVoucher(int voucherId) throws SQLException {
        String sql = "UPDATE vouchers SET is_deleted = 1, updated_at = NOW() WHERE voucher_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, voucherId);
            
            return ps.executeUpdate() > 0;
        }
    }
    
    /**
     * Map ResultSet to Voucher object
     */
    private Voucher mapResultSetToVoucher(ResultSet rs) throws SQLException {
        Voucher voucher = new Voucher();
        voucher.setVoucherId(rs.getInt("voucher_id"));
        voucher.setCode(rs.getString("code"));
        voucher.setDiscountType(rs.getString("discount_type"));
        voucher.setDiscountValue(rs.getBigDecimal("discount_value"));
        voucher.setMinOrderValue(rs.getBigDecimal("min_order_value"));
        
        int usageLimit = rs.getInt("usage_limit");
        if (rs.wasNull()) {
            voucher.setUsageLimit(null);
        } else {
            voucher.setUsageLimit(usageLimit);
        }
        
        voucher.setUsedCount(rs.getInt("used_count"));
        
        Timestamp expiryTimestamp = rs.getTimestamp("expiry_date");
        if (expiryTimestamp != null) {
            voucher.setExpiryDate(new java.util.Date(expiryTimestamp.getTime()));
        } else {
            voucher.setExpiryDate(null);
        }
        
        voucher.setStatus(rs.getString("status"));
        voucher.setCreatedAt(rs.getTimestamp("created_at"));
        voucher.setUpdatedAt(rs.getTimestamp("updated_at"));
        voucher.setDeleted(rs.getBoolean("is_deleted"));
        
        return voucher;
    }
}


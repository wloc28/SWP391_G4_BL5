package DAO.admin;

import DAO.DBConnection;
import Models.User;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * UserDAO for admin user management.
 */
public class UserDAO {

    /**
     * List users with filters and pagination.
     */
    public List<User> listUsers(String keyword, String role, String status,
                                String sortBy, String sortDir,
                                int page, int pageSize) throws SQLException {
        List<User> users = new ArrayList<>();

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT * FROM users WHERE is_deleted = 0 ");

        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (username LIKE ? OR email LIKE ? OR full_name LIKE ? OR phone_number LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        if (role != null && !role.equalsIgnoreCase("ALL") && !role.isEmpty()) {
            sql.append("AND role = ? ");
            params.add(role);
        }

        if (status != null && !status.equalsIgnoreCase("ALL") && !status.isEmpty()) {
            sql.append("AND status = ? ");
            params.add(status);
        }

        String orderBy = "created_at";
        if ("balance".equalsIgnoreCase(sortBy)) {
            orderBy = "balance";
        } else if ("username".equalsIgnoreCase(sortBy)) {
            orderBy = "username";
        }

        String direction = "DESC";
        if ("ASC".equalsIgnoreCase(sortDir)) {
            direction = "ASC";
        }

        sql.append("ORDER BY ").append(orderBy).append(" ").append(direction).append(" ");
        sql.append("LIMIT ? OFFSET ?");

        int offset = (page - 1) * pageSize;
        params.add(pageSize);
        params.add(offset);

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                Object p = params.get(i);
                if (p instanceof String) {
                    ps.setString(i + 1, (String) p);
                } else if (p instanceof Integer) {
                    ps.setInt(i + 1, (Integer) p);
                }
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    users.add(mapUser(rs));
                }
            }
        }

        return users;
    }

    /**
     * Count users for pagination with filters.
     */
    public int countUsers(String keyword, String role, String status) throws SQLException {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) AS total FROM users WHERE is_deleted = 0 ");

        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (username LIKE ? OR email LIKE ? OR full_name LIKE ? OR phone_number LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        if (role != null && !role.equalsIgnoreCase("ALL") && !role.isEmpty()) {
            sql.append("AND role = ? ");
            params.add(role);
        }

        if (status != null && !status.equalsIgnoreCase("ALL") && !status.isEmpty()) {
            sql.append("AND status = ? ");
            params.add(status);
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                Object p = params.get(i);
                if (p instanceof String) {
                    ps.setString(i + 1, (String) p);
                } else if (p instanceof Integer) {
                    ps.setInt(i + 1, (Integer) p);
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
     * Get user detail by id.
     */
    public User getUserById(int userId) throws SQLException {
        String sql = "SELECT * FROM users WHERE user_id = ? AND is_deleted = 0";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        }
        return null;
    }

    /**
     * Update status ACTIVE/BANNED.
     */
    public boolean updateStatus(int userId, String status) throws SQLException {
        String sql = "UPDATE users SET status = ?, updated_at = ? WHERE user_id = ? AND is_deleted = 0";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setTimestamp(2, new Timestamp(System.currentTimeMillis()));
            ps.setInt(3, userId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Admin cập nhật thông tin người dùng (username, full name, phone, balance, role, status).
     */
    public boolean updateUser(User user) throws SQLException {
        String sql = "UPDATE users SET username = ?, full_name = ?, phone_number = ?, balance = ?, role = ?, status = ?, updated_at = ? "
                + "WHERE user_id = ? AND is_deleted = 0";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, user.getUsername());
            ps.setString(2, user.getFullName());
            ps.setString(3, user.getPhoneNumber());
            ps.setBigDecimal(4, user.getBalance());
            ps.setString(5, user.getRole());
            ps.setString(6, user.getStatus());
            ps.setTimestamp(7, new Timestamp(System.currentTimeMillis()));
            ps.setInt(8, user.getUserId());

            return ps.executeUpdate() > 0;
        }
    }

    private User mapUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setUserId(rs.getInt("user_id"));
        user.setUsername(rs.getString("username"));
        user.setPassword(rs.getString("password"));
        user.setEmail(rs.getString("email"));
        user.setFullName(rs.getString("full_name"));
        user.setPhoneNumber(rs.getString("phone_number"));
        user.setBalance(rs.getBigDecimal("balance"));
        user.setRole(rs.getString("role"));
        user.setStatus(rs.getString("status"));
        // Cột image_url có thể không tồn tại trong schema, nên kiểm tra trước khi đọc
        if (columnExists(rs, "image_url")) {
            user.setImage(rs.getString("image_url"));
        } else {
            user.setImage(null);
        }
        user.setCreatedAt(rs.getTimestamp("created_at"));
        user.setUpdatedAt(rs.getTimestamp("updated_at"));
        user.setDeleted(rs.getBoolean("is_deleted"));
        return user;
    }

    /**
     * Helper: check column exists to avoid SQLException when schema differs.
     */
    private boolean columnExists(ResultSet rs, String columnName) {
        try {
            rs.findColumn(columnName);
            return true;
        } catch (SQLException e) {
            return false;
        }
    }
}


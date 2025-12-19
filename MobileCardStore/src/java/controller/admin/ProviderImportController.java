package controller.admin;

import DAO.admin.ProviderStorageDAO;
import DAO.admin.ProductStorageDAO;
import DAO.admin.ImportTransactionDAO;
import DAO.DBConnection;
import Models.ProviderStorage;
import Models.ProductStorage;
import Models.ImportTransaction;
import Models.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * ProviderImportController
 * Xử lý nghiệp vụ nhập hàng từ provider
 */
@WebServlet(name = "ProviderImportController", urlPatterns = {"/admin/provider-import", "/provider-import"})
public class ProviderImportController extends HttpServlet {
    
    private ProviderStorageDAO providerStorageDAO;
    private ProductStorageDAO storageDAO;
    private ImportTransactionDAO importDAO;
    
    @Override
    public void init() throws ServletException {
        providerStorageDAO = new ProviderStorageDAO();
        storageDAO = new ProductStorageDAO();
        importDAO = new ImportTransactionDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra quyền admin
        if (!checkAdminPermission(request, response)) {
            return;
        }
        
        String action = request.getParameter("action");
        
        try {
            if (action == null || action.isEmpty() || "list".equals(action)) {
                // Hiển thị danh sách provider và sản phẩm
                showProviderProducts(request, response);
            } else if ("history".equals(action)) {
                // Lịch sử nhập hàng
                showImportHistory(request, response);
            } else {
                showProviderProducts(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            try {
                showProviderProducts(request, response);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra quyền admin
        if (!checkAdminPermission(request, response)) {
            return;
        }
        
        String action = request.getParameter("action");
        
        try {
            if ("import".equals(action)) {
                // Xử lý nhập hàng
                processImport(request, response);
            } else {
                showProviderProducts(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/provider-import?error=import_failed");
        }
    }
    
    private boolean checkAdminPermission(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            user = (User) session.getAttribute("info");
        }
        
        String role = null;
        if (user != null) {
            role = user.getRole();
        }
        if (role == null) {
            role = (String) session.getAttribute("role");
        }
        
        if (user == null || (role == null || !"ADMIN".equalsIgnoreCase(role))) {
            response.sendRedirect(request.getContextPath() + "/view/login.jsp");
            return false;
        }
        
        return true;
    }
    
    /**
     * Hiển thị danh sách sản phẩm của provider
     */
    private void showProviderProducts(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String providerName = request.getParameter("providerName");
            
            // Lấy danh sách provider names
            List<String> providerNames = providerStorageDAO.getAllProviderNames();
            request.setAttribute("providerNames", providerNames);
            
            // Lấy sản phẩm của provider được chọn hoặc tất cả
            Map<String, List<ProviderStorage>> providerProducts;
            if (providerName != null && !providerName.isEmpty()) {
                List<ProviderStorage> products = providerStorageDAO.getProviderStoragesByProviderName(providerName);
                providerProducts = new java.util.LinkedHashMap<>();
                providerProducts.put(providerName, products);
            } else {
                providerProducts = providerStorageDAO.getProviderStoragesGrouped();
            }
            
            request.setAttribute("providerProducts", providerProducts);
            request.setAttribute("selectedProviderName", providerName);
            
            request.getRequestDispatcher("/view/ManageProviderImport.jsp").forward(request, response);
            
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi kết nối database: " + e.getMessage());
            try {
                request.getRequestDispatcher("/view/ManageProviderImport.jsp").forward(request, response);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            try {
                request.getRequestDispatcher("/view/ManageProviderImport.jsp").forward(request, response);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }
    
    /**
     * Xử lý nhập hàng từ provider
     * Logic: Nhập trực tiếp vào product_storage, không check số lượng thẻ, không thanh toán
     * Chỉ đơn giản là chuyển dữ liệu từ provider_storage sang product_storage
     */
    private void processImport(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int providerStorageId = Integer.parseInt(request.getParameter("providerStorageId"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));
            
            // Validate input
            if (quantity <= 0) {
                response.sendRedirect(request.getContextPath() + "/provider-import?error=invalid_quantity");
                return;
            }
            
            // Lấy thông tin provider_storage
            ProviderStorage providerStorage = providerStorageDAO.getProviderStorageById(providerStorageId);
            if (providerStorage == null) {
                response.sendRedirect(request.getContextPath() + "/provider-import?error=provider_not_found");
                return;
            }
            
            // Lấy admin ID (không check số dư, không thanh toán)
            HttpSession session = request.getSession();
            User user = (User) session.getAttribute("user");
            if (user == null) {
                user = (User) session.getAttribute("info");
            }
            int adminId = user != null ? user.getUserId() : 1;
            
            // Lấy provider name
            String providerName = providerStorage.getProvider() != null ? 
                providerStorage.getProvider().getProviderName() : "Unknown";
            
            // Tạo product_storage cho mỗi thẻ (tạo trực tiếp, không cần lấy từ cards)
            long timestamp = System.currentTimeMillis();
            int successCount = 0;
            
            for (int i = 0; i < quantity; i++) {
                ProductStorage storage = new ProductStorage();
                storage.setProviderStorageId(providerStorageId);
                storage.setProviderId(providerStorage.getProviderId());
                storage.setProviderName(providerName);
                storage.setProductCode(providerStorage.getProductCode());
                storage.setProductName(providerStorage.getProductName());
                storage.setPrice(providerStorage.getPrice());
                storage.setPurchasePrice(providerStorage.getPurchasePrice());
                
                // Tạo serial_number và card_code tự động
                String serialNumber = providerStorage.getProductCode() + "_SER_" + timestamp + "_" + String.format("%04d", i + 1);
                String cardCode = providerStorage.getProductCode() + "_CARD_" + timestamp + "_" + String.format("%06d", i + 1);
                storage.setSerialNumber(serialNumber);
                storage.setCardCode(cardCode);
                
                storage.setStatus("AVAILABLE");
                storage.setCreatedBy(adminId);
                
                if (storageDAO.addStorageItem(storage)) {
                    successCount++;
                }
            }
            
            // Giảm available_quantity trong provider_storage (nếu có)
            if (providerStorage.getAvailableQuantity() > 0) {
                try {
                    // Giảm số lượng trong provider_storage
                    String updateSql = "UPDATE provider_storage SET available_quantity = GREATEST(0, available_quantity - ?), updated_at = NOW() WHERE provider_storage_id = ?";
                    try (java.sql.Connection conn = DBConnection.getConnection();
                         java.sql.PreparedStatement ps = conn.prepareStatement(updateSql)) {
                        ps.setInt(1, successCount);
                        ps.setInt(2, providerStorageId);
                        ps.executeUpdate();
                    }
                } catch (Exception e) {
                    // Nếu lỗi khi giảm quantity, vẫn tiếp tục (không block việc nhập hàng)
                    e.printStackTrace();
                }
            }
            
            // Tạo import transaction để ghi lại lịch sử
            ImportTransaction transaction = new ImportTransaction();
            transaction.setProviderStorageId(providerStorageId);
            transaction.setQuantity(successCount);
            transaction.setPurchasePrice(providerStorage.getPurchasePrice());
            transaction.setTotalCost(providerStorage.getPurchasePrice().multiply(new BigDecimal(successCount)));
            transaction.setImportedBy(adminId);
            transaction.setNote("Nhập " + successCount + " thẻ " + providerStorage.getProductCode() + " vào kho hệ thống");
            
            importDAO.createImportTransaction(transaction);
            
            response.sendRedirect(request.getContextPath() + "/provider-import?success=import_success&providerName=" + 
                                java.net.URLEncoder.encode(providerName, "UTF-8"));
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/provider-import?error=import_failed");
        }
    }
    
    /**
     * Hiển thị lịch sử nhập hàng
     */
    private void showImportHistory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String providerName = request.getParameter("providerName");
            String fromDateStr = request.getParameter("fromDate");
            String toDateStr = request.getParameter("toDate");
            
            java.sql.Date fromDate = null;
            java.sql.Date toDate = null;
            
            if (fromDateStr != null && !fromDateStr.isEmpty()) {
                fromDate = java.sql.Date.valueOf(fromDateStr);
            }
            if (toDateStr != null && !toDateStr.isEmpty()) {
                toDate = java.sql.Date.valueOf(toDateStr);
            }
            
            // Lấy danh sách provider names để hiển thị trong filter
            List<String> providerNames = providerStorageDAO.getAllProviderNames();
            
            // Lấy lịch sử nhập hàng
            List<ImportTransaction> history = importDAO.getImportHistory(providerName, fromDate, toDate);
            
            // Tính tổng chi phí
            java.math.BigDecimal totalCost = importDAO.getTotalImportCost(fromDate, toDate);
            
            request.setAttribute("importHistory", history);
            request.setAttribute("providerNames", providerNames);
            request.setAttribute("selectedProviderName", providerName);
            request.setAttribute("fromDate", fromDateStr);
            request.setAttribute("toDate", toDateStr);
            request.setAttribute("totalCost", totalCost);
            
            request.getRequestDispatcher("/view/ImportHistory.jsp").forward(request, response);
            
        } catch (java.sql.SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi kết nối database: " + e.getMessage());
            request.setAttribute("importHistory", new java.util.ArrayList<>());
            request.setAttribute("providerNames", new java.util.ArrayList<>());
            try {
                request.getRequestDispatcher("/view/ImportHistory.jsp").forward(request, response);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            request.setAttribute("importHistory", new java.util.ArrayList<>());
            request.setAttribute("providerNames", new java.util.ArrayList<>());
            try {
                request.getRequestDispatcher("/view/ImportHistory.jsp").forward(request, response);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }
    
}


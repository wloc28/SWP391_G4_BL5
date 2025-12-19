package controller.admin;

import DAO.admin.OrderDAO;
import DAO.admin.UserDAO;
import Models.Order;
import Models.User;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

/**
 * Order Controller
 * Xử lý các request liên quan đến quản lý đơn hàng cho admin
 */
@WebServlet(name = "OrderController", urlPatterns = {"/admin/orders", "/admin/orders/*"})
public class OrderController extends HttpServlet {
    
    private OrderDAO orderDAO;
    private UserDAO userDAO;
    
    @Override
    public void init() throws ServletException {
        orderDAO = new OrderDAO();
        userDAO = new UserDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check admin authentication
        if (!checkAdminPermission(request, response)) {
            return;
        }
        
        String pathInfo = request.getPathInfo();
        
        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                // Main orders list page
                handleOrdersList(request, response);
            } else if (pathInfo.startsWith("/detail/")) {
                // Order detail page
                String orderIdStr = pathInfo.substring("/detail/".length());
                handleOrderDetail(request, response, orderIdStr);
            } else if (pathInfo.startsWith("/history/")) {
                // User order history page
                String userIdStr = pathInfo.substring("/history/".length());
                handleUserOrderHistory(request, response, userIdStr);
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi kết nối cơ sở dữ liệu: " + e.getMessage());
            request.getRequestDispatcher("/view/error.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check admin authentication
        if (!checkAdminPermission(request, response)) {
            return;
        }
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null) {
            currentUser = (User) session.getAttribute("info");
        }
        
        String action = request.getParameter("action");
        
        try {
            if ("updateStatus".equals(action)) {
                handleUpdateStatus(request, response, currentUser != null ? currentUser.getUserId() : 1);
            } else if ("deleteOrder".equals(action)) {
                handleDeleteOrder(request, response, currentUser != null ? currentUser.getUserId() : 1);
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi kết nối cơ sở dữ liệu: " + e.getMessage());
            request.getRequestDispatcher("/view/error.jsp").forward(request, response);
        }
    }
    
    /**
     * Handle orders list page
     */
    private void handleOrdersList(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        
        // Get pagination parameters
        int page = 1;
        int pageSize = 15;
        
        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            try {
                page = Integer.parseInt(pageParam);
                if (page < 1) page = 1;
            } catch (NumberFormatException e) {
                page = 1;
            }
        }
        
        String pageSizeParam = request.getParameter("pageSize");
        if (pageSizeParam != null && !pageSizeParam.trim().isEmpty()) {
            try {
                int requestedPageSize = Integer.parseInt(pageSizeParam);
                // Validate pageSize - only allow valid values
                if (requestedPageSize == 10 || requestedPageSize == 15 || 
                    requestedPageSize == 20 || requestedPageSize == 50 || 
                    requestedPageSize == 100) {
                    pageSize = requestedPageSize;
                }
            } catch (NumberFormatException e) {
                // Keep default pageSize = 15
            }
        }
        
        // Get search and filter parameters
        String searchTerm = request.getParameter("search");
        String statusFilter = request.getParameter("status");
        String providerFilter = request.getParameter("provider");
        String minPrice = request.getParameter("minPrice");
        String maxPrice = request.getParameter("maxPrice");
        String sortBy = request.getParameter("sortBy");
        String sortDir = request.getParameter("sortDir");
        
        // Sanitize search term - only trim whitespace, allow _ and % characters
        if (searchTerm != null) {
            searchTerm = searchTerm.trim();
        }
        
        if (statusFilter != null) {
            statusFilter = statusFilter.trim();
        }
        
        if (providerFilter != null) {
            providerFilter = providerFilter.trim();
        }
        
        if (minPrice != null) {
            minPrice = minPrice.trim();
        }
        
        if (maxPrice != null) {
            maxPrice = maxPrice.trim();
        }
        
        if (sortBy != null) {
            sortBy = sortBy.trim();
        }
        
        if (sortDir != null) {
            sortDir = sortDir.trim();
        }
        
        // Calculate offset
        int offset = (page - 1) * pageSize;
        
        // Get orders and total count (productNameFilter removed, now part of search)
        List<Order> orders = orderDAO.getOrdersPaginated(offset, pageSize, searchTerm, statusFilter, 
                                                         null, providerFilter, 
                                                         minPrice, maxPrice, sortBy, sortDir);
        int totalOrders = orderDAO.countOrders(searchTerm, statusFilter, null, 
                                               providerFilter, minPrice, maxPrice);
        
        // Calculate pagination info
        int totalPages = (int) Math.ceil((double) totalOrders / pageSize);
        
        // Get order statistics
        Map<String, Integer> orderStats = orderDAO.getOrderStatistics();
        
        // Set attributes
        request.setAttribute("orders", orders);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalOrders", totalOrders);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("searchTerm", searchTerm);
        request.setAttribute("statusFilter", statusFilter);
        request.setAttribute("providerFilter", providerFilter);
        request.setAttribute("minPrice", minPrice);
        request.setAttribute("maxPrice", maxPrice);
        request.setAttribute("sortBy", sortBy);
        request.setAttribute("sortDir", sortDir);
        request.setAttribute("orderStats", orderStats);
        
        // Get unique providers for filter dropdown
        try {
            List<String> providers = orderDAO.getDistinctProviders();
            request.setAttribute("providers", providers != null ? providers : new java.util.ArrayList<String>());
        } catch (SQLException e) {
            // If error occurs, set empty list
            request.setAttribute("providers", new java.util.ArrayList<String>());
        }
        
        // Calculate pagination range
        int startPage = Math.max(1, page - 2);
        int endPage = Math.min(totalPages, page + 2);
        request.setAttribute("startPage", startPage);
        request.setAttribute("endPage", endPage);
        
        // Forward to JSP
        request.getRequestDispatcher("/view/ManageOrders.jsp").forward(request, response);
    }
    
    /**
     * Handle order detail page
     */
    private void handleOrderDetail(HttpServletRequest request, HttpServletResponse response, String orderIdStr)
            throws SQLException, ServletException, IOException {
        
        try {
            int orderId = Integer.parseInt(orderIdStr);
            Order order = orderDAO.getOrderById(orderId);
            
            if (order == null) {
                request.setAttribute("error", "Không tìm thấy đơn hàng với ID: " + orderId);
                request.getRequestDispatcher("/view/error.jsp").forward(request, response);
                return;
            }
            
            request.setAttribute("order", order);
            request.getRequestDispatcher("/view/OrderDetail.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "ID đơn hàng không hợp lệ: " + orderIdStr);
            request.getRequestDispatcher("/view/error.jsp").forward(request, response);
        }
    }
    
    /**
     * Handle user order history page
     */
    private void handleUserOrderHistory(HttpServletRequest request, HttpServletResponse response, String userIdStr)
            throws SQLException, ServletException, IOException {
        
        try {
            int userId = Integer.parseInt(userIdStr);
            
            // Get user info from database first
            User user = userDAO.getUserById(userId);
            if (user == null) {
                request.setAttribute("error", "Không tìm thấy người dùng với ID: " + userId);
                request.getRequestDispatcher("/view/error.jsp").forward(request, response);
                return;
            }
            
            // Get order history
            List<Order> orders = orderDAO.getOrderHistoryByUserId(userId);
            
            // Set attributes
            request.setAttribute("orders", orders);
            request.setAttribute("userId", userId);
            request.setAttribute("user", user);
            
            request.getRequestDispatcher("/view/UserOrderHistory.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "ID người dùng không hợp lệ: " + userIdStr);
            request.getRequestDispatcher("/view/error.jsp").forward(request, response);
        }
    }
    
    /**
     * Handle update order status
     */
    private void handleUpdateStatus(HttpServletRequest request, HttpServletResponse response, int updatedBy)
            throws SQLException, IOException {
        
        String orderIdStr = request.getParameter("orderId");
        String newStatus = request.getParameter("status");
        
        if (orderIdStr == null || newStatus == null) {
            response.sendRedirect(request.getContextPath() + "/admin/orders?error=missing_params");
            return;
        }
        
        try {
            int orderId = Integer.parseInt(orderIdStr);
            
            // Validate status format
            if (!isValidStatus(newStatus)) {
                response.sendRedirect(request.getContextPath() + "/admin/orders?error=invalid_status");
                return;
            }
            
            // Get current order to check current status
            Order currentOrder = orderDAO.getOrderById(orderId);
            if (currentOrder == null) {
                response.sendRedirect(request.getContextPath() + "/admin/orders?error=order_not_found");
                return;
            }
            
            String currentStatus = currentOrder.getStatus();
            
            // Validate status transition
            if (!isValidStatusTransition(currentStatus, newStatus)) {
                response.sendRedirect(request.getContextPath() + "/admin/orders?error=invalid_transition&current=" + currentStatus);
                return;
            }
            
            boolean success = orderDAO.updateOrderStatus(orderId, newStatus, updatedBy);
            
            if (success) {
                // Redirect back to detail page if coming from detail page
                String referer = request.getHeader("Referer");
                if (referer != null && referer.contains("/admin/orders/detail/")) {
                    response.sendRedirect(request.getContextPath() + "/admin/orders/detail/" + orderId + "?success=status_updated");
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/orders?success=status_updated");
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/orders?error=update_failed");
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/orders?error=invalid_order_id");
        }
    }
    
    /**
     * Handle delete order (soft delete)
     */
    private void handleDeleteOrder(HttpServletRequest request, HttpServletResponse response, int deletedBy)
            throws SQLException, IOException {
        
        String orderIdStr = request.getParameter("orderId");
        
        if (orderIdStr == null) {
            response.sendRedirect(request.getContextPath() + "/admin/orders?error=missing_order_id");
            return;
        }
        
        try {
            int orderId = Integer.parseInt(orderIdStr);
            boolean success = orderDAO.softDeleteOrder(orderId, deletedBy);
            
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/orders?success=order_deleted");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/orders?error=delete_failed");
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/orders?error=invalid_order_id");
        }
    }
    
    /**
     * Check admin permission
     */
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
        
        // Ensure info attribute is set for header
        if (session.getAttribute("info") == null && user != null) {
            session.setAttribute("info", user);
        }
        
        return true;
    }
    
    /**
     * Validate order status format
     */
    private boolean isValidStatus(String status) {
        return "PENDING".equals(status) || 
               "PROCESSING".equals(status) || 
               "COMPLETED".equals(status) || 
               "FAILED".equals(status);
    }
    
    /**
     * Validate status transition
     * Rules:
     * - PENDING -> PROCESSING (allowed)
     * - PROCESSING -> COMPLETED (allowed)
     * - PROCESSING -> FAILED (allowed)
     * - COMPLETED -> (no transitions allowed, final state)
     * - FAILED -> (no transitions allowed, final state)
     * - PENDING -> COMPLETED (not allowed, must go through PROCESSING)
     * - PENDING -> FAILED (not allowed, must go through PROCESSING)
     */
    private boolean isValidStatusTransition(String currentStatus, String newStatus) {
        // Cannot change status if already in final state
        if ("COMPLETED".equals(currentStatus) || "FAILED".equals(currentStatus)) {
            return false;
        }
        
        // Same status is not a valid transition
        if (currentStatus.equals(newStatus)) {
            return false;
        }
        
        // Valid transitions
        if ("PENDING".equals(currentStatus)) {
            // PENDING can only go to PROCESSING
            return "PROCESSING".equals(newStatus);
        }
        
        if ("PROCESSING".equals(currentStatus)) {
            // PROCESSING can go to COMPLETED or FAILED
            return "COMPLETED".equals(newStatus) || "FAILED".equals(newStatus);
        }
        
        // Any other transition is invalid
        return false;
    }
}

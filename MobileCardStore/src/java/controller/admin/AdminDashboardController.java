package controller.admin;

import DAO.admin.AdminDashboardDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import Models.Order;
import Models.User;

/**
 * Admin Dashboard Controller
 * Xử lý request cho trang dashboard admin
 */
@WebServlet(name = "AdminDashboardController", urlPatterns = {"/admin/dashboard"})
public class AdminDashboardController extends HttpServlet {
    
    private AdminDashboardDAO dashboardDAO;
    
    @Override
    public void init() throws ServletException {
        dashboardDAO = new AdminDashboardDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra quyền admin
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        // Fallback: kiểm tra session attribute "info" nếu "user" không có
        if (user == null) {
            user = (User) session.getAttribute("info");
        }
        
        // Kiểm tra role từ session attribute nếu user object không có role
        String role = null;
        if (user != null) {
            role = user.getRole();
        }
        if (role == null) {
            role = (String) session.getAttribute("role");
        }
        
        if (user == null || (role == null || !"ADMIN".equalsIgnoreCase(role))) {
            response.sendRedirect(request.getContextPath() + "/view/login.jsp");
            return;
        }
        
        // Đảm bảo sessionScope.info được set để header_v2.jsp có thể sử dụng
        if (session.getAttribute("info") == null && user != null) {
            session.setAttribute("info", user);
        }
        
        try {
            // Lấy thống kê với xử lý lỗi từng phần
            int totalUsers = 0;
            int totalProducts = 0;
            int totalOrders = 0;
            int totalVouchers = 0;
            int activeVouchers = 0;
            int expiringSoonVouchers = 0;
            BigDecimal totalRevenue = BigDecimal.ZERO;
            BigDecimal monthlyRevenue = BigDecimal.ZERO;
            int newUsersThisMonth = 0;
            Map<String, Integer> ordersByStatus = new java.util.HashMap<>();
            List<Order> recentOrders = new java.util.ArrayList<>();
            
            try {
                totalUsers = dashboardDAO.getTotalUsers();
            } catch (Exception e) {
                System.err.println("Error getting totalUsers: " + e.getMessage());
            }
            
            try {
                totalProducts = dashboardDAO.getTotalProducts();
            } catch (Exception e) {
                System.err.println("Error getting totalProducts: " + e.getMessage());
            }
            
            try {
                totalOrders = dashboardDAO.getTotalOrders();
            } catch (Exception e) {
                System.err.println("Error getting totalOrders: " + e.getMessage());
            }
            
            try {
                totalRevenue = dashboardDAO.getTotalRevenue();
                if (totalRevenue == null) totalRevenue = BigDecimal.ZERO;
            } catch (Exception e) {
                System.err.println("Error getting totalRevenue: " + e.getMessage());
            }
            
            try {
                monthlyRevenue = dashboardDAO.getMonthlyRevenue();
                if (monthlyRevenue == null) monthlyRevenue = BigDecimal.ZERO;
            } catch (Exception e) {
                System.err.println("Error getting monthlyRevenue: " + e.getMessage());
            }
            
            try {
                newUsersThisMonth = dashboardDAO.getNewUsersThisMonth();
            } catch (Exception e) {
                System.err.println("Error getting newUsersThisMonth: " + e.getMessage());
            }
            
            try {
                ordersByStatus = dashboardDAO.getOrdersByStatus();
                if (ordersByStatus == null) ordersByStatus = new java.util.HashMap<>();
            } catch (Exception e) {
                System.err.println("Error getting ordersByStatus: " + e.getMessage());
            }
            
            try {
                recentOrders = dashboardDAO.getRecentOrders(10);
                if (recentOrders == null) recentOrders = new java.util.ArrayList<>();
            } catch (Exception e) {
                System.err.println("Error getting recentOrders: " + e.getMessage());
            }
            
            try {
                totalVouchers = dashboardDAO.getTotalVouchers();
            } catch (Exception e) {
                System.err.println("Error getting totalVouchers: " + e.getMessage());
            }
            
            try {
                activeVouchers = dashboardDAO.getActiveVouchers();
            } catch (Exception e) {
                System.err.println("Error getting activeVouchers: " + e.getMessage());
            }
            
            try {
                expiringSoonVouchers = dashboardDAO.getExpiringSoonVouchers();
            } catch (Exception e) {
                System.err.println("Error getting expiringSoonVouchers: " + e.getMessage());
            }
            
            // Set attributes
            request.setAttribute("totalUsers", totalUsers);
            request.setAttribute("totalProducts", totalProducts);
            request.setAttribute("totalOrders", totalOrders);
            request.setAttribute("totalVouchers", totalVouchers);
            request.setAttribute("activeVouchers", activeVouchers);
            request.setAttribute("expiringSoonVouchers", expiringSoonVouchers);
            request.setAttribute("totalRevenue", totalRevenue);
            request.setAttribute("monthlyRevenue", monthlyRevenue);
            request.setAttribute("newUsersThisMonth", newUsersThisMonth);
            request.setAttribute("ordersByStatus", ordersByStatus);
            request.setAttribute("recentOrders", recentOrders);
            request.setAttribute("currentUser", user); // Thêm user vào request để hiển thị trong header
            
            // Forward to JSP
            request.getRequestDispatcher("/view/AdminDashboard.jsp").forward(request, response);
            
        } catch (Exception e) {
            System.err.println("Error in AdminDashboardController: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading dashboard: " + e.getMessage());
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}


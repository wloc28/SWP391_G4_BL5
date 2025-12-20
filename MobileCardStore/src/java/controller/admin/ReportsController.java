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
import Models.User;

/**
 * Reports Controller
 * Xử lý request cho trang reports admin
 */
@WebServlet(name = "ReportsController", urlPatterns = {"/admin/reports"})
public class ReportsController extends HttpServlet {
    
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
            return;
        }
        
        // Đảm bảo sessionScope.info được set
        if (session.getAttribute("info") == null && user != null) {
            session.setAttribute("info", user);
        }
        
        try {
            // Lấy các thống kê tổng quan với xử lý lỗi từng phần
            int totalUsers = 0;
            int totalProducts = 0;
            int totalOrders = 0;
            BigDecimal totalRevenue = BigDecimal.ZERO;
            BigDecimal monthlyRevenue = BigDecimal.ZERO;
            Map<String, BigDecimal> revenueByMonth = new java.util.HashMap<>();
            Map<String, BigDecimal> revenueByDay = new java.util.HashMap<>();
            List<Map<String, Object>> topProducts = new java.util.ArrayList<>();
            List<Map<String, Object>> topCustomers = new java.util.ArrayList<>();
            Map<String, Integer> ordersByStatus = new java.util.HashMap<>();
            int totalVouchers = 0;
            int activeVouchers = 0;
            int expiringSoonVouchers = 0;
            Map<String, Integer> ordersByMonth = new java.util.HashMap<>();
            Map<String, Integer> newUsersByMonth = new java.util.HashMap<>();
            
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
                revenueByMonth = dashboardDAO.getRevenueByMonth(12);
                if (revenueByMonth == null) revenueByMonth = new java.util.HashMap<>();
            } catch (Exception e) {
                System.err.println("Error getting revenueByMonth: " + e.getMessage());
            }
            
            try {
                revenueByDay = dashboardDAO.getRevenueByDay(30);
                if (revenueByDay == null) revenueByDay = new java.util.HashMap<>();
            } catch (Exception e) {
                System.err.println("Error getting revenueByDay: " + e.getMessage());
            }
            
            try {
                topProducts = dashboardDAO.getTopProducts(10);
                if (topProducts == null) topProducts = new java.util.ArrayList<>();
            } catch (Exception e) {
                System.err.println("Error getting topProducts: " + e.getMessage());
            }
            
            try {
                topCustomers = dashboardDAO.getTopCustomers(10);
                if (topCustomers == null) topCustomers = new java.util.ArrayList<>();
            } catch (Exception e) {
                System.err.println("Error getting topCustomers: " + e.getMessage());
            }
            
            try {
                ordersByStatus = dashboardDAO.getOrdersByStatus();
                if (ordersByStatus == null) ordersByStatus = new java.util.HashMap<>();
            } catch (Exception e) {
                System.err.println("Error getting ordersByStatus: " + e.getMessage());
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
            
            try {
                ordersByMonth = dashboardDAO.getOrdersByMonth(12);
                if (ordersByMonth == null) ordersByMonth = new java.util.HashMap<>();
            } catch (Exception e) {
                System.err.println("Error getting ordersByMonth: " + e.getMessage());
            }
            
            try {
                newUsersByMonth = dashboardDAO.getNewUsersByMonth(12);
                if (newUsersByMonth == null) newUsersByMonth = new java.util.HashMap<>();
            } catch (Exception e) {
                System.err.println("Error getting newUsersByMonth: " + e.getMessage());
            }
            
            // Set attributes
            request.setAttribute("totalUsers", totalUsers);
            request.setAttribute("totalProducts", totalProducts);
            request.setAttribute("totalOrders", totalOrders);
            request.setAttribute("totalRevenue", totalRevenue);
            request.setAttribute("monthlyRevenue", monthlyRevenue);
            request.setAttribute("revenueByMonth", revenueByMonth);
            request.setAttribute("revenueByDay", revenueByDay);
            request.setAttribute("topProducts", topProducts);
            request.setAttribute("topCustomers", topCustomers);
            request.setAttribute("ordersByStatus", ordersByStatus);
            request.setAttribute("totalVouchers", totalVouchers);
            request.setAttribute("activeVouchers", activeVouchers);
            request.setAttribute("expiringSoonVouchers", expiringSoonVouchers);
            request.setAttribute("ordersByMonth", ordersByMonth);
            request.setAttribute("newUsersByMonth", newUsersByMonth);
            request.setAttribute("currentUser", user);
            
            // Forward to JSP
            request.getRequestDispatcher("/view/DashboardReports.jsp").forward(request, response);
            
        } catch (Exception e) {
            System.err.println("Error in ReportsController: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading reports: " + e.getMessage());
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}


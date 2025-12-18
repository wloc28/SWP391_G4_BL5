package controller.user;

import DAO.admin.OrderDAO;
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

/**
 * Order History Controller for Users
 * Xử lý lịch sử đơn hàng cho người dùng
 */
@WebServlet(name = "OrderHistoryController", urlPatterns = {"/order-history", "/order-detail/*"})
public class OrderHistoryController extends HttpServlet {
    
    private OrderDAO orderDAO;
    
    @Override
    public void init() throws ServletException {
        orderDAO = new OrderDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check user authentication
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null) {
            currentUser = (User) session.getAttribute("info");
        }
        
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/view/login.jsp");
            return;
        }
        
        String pathInfo = request.getPathInfo();
        
        try {
            if (pathInfo != null && pathInfo.startsWith("/")) {
                // Order detail page
                String orderIdStr = pathInfo.substring(1);
                handleOrderDetail(request, response, orderIdStr, currentUser);
            } else {
                // Order history list page
                handleOrderHistory(request, response, currentUser);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi kết nối cơ sở dữ liệu: " + e.getMessage());
            request.getRequestDispatcher("/view/error.jsp").forward(request, response);
        }
    }
    
    /**
     * Handle order history list
     */
    private void handleOrderHistory(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws SQLException, ServletException, IOException {
        
        // Get order history for current user
        List<Order> orders = orderDAO.getOrderHistoryByUserId(currentUser.getUserId());
        
        // Set attributes
        request.setAttribute("orders", orders);
        request.setAttribute("user", currentUser);
        
        // Forward to JSP
        request.getRequestDispatcher("/view/OrderHistory.jsp").forward(request, response);
    }
    
    /**
     * Handle order detail page
     */
    private void handleOrderDetail(HttpServletRequest request, HttpServletResponse response, String orderIdStr, User currentUser)
            throws SQLException, ServletException, IOException {
        
        try {
            int orderId = Integer.parseInt(orderIdStr);
            Order order = orderDAO.getOrderById(orderId);
            
            if (order == null) {
                request.setAttribute("error", "Không tìm thấy đơn hàng với ID: " + orderId);
                request.getRequestDispatcher("/view/error.jsp").forward(request, response);
                return;
            }
            
            // Check if order belongs to current user
            if (order.getUserId() != currentUser.getUserId()) {
                request.setAttribute("error", "Bạn không có quyền xem đơn hàng này");
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
}


package controller.admin;

import DAO.admin.TransactionDAO;
import DAO.admin.UserDAO;
import Models.Transaction;
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
import java.util.List;

@WebServlet(name = "ManageTransactionsController", urlPatterns = {"/admin/transactions"})
public class ManageTransactionsController extends HttpServlet {
    
    private TransactionDAO transactionDAO;
    private UserDAO userDAO;
    
    @Override
    public void init() throws ServletException {
        transactionDAO = new TransactionDAO();
        userDAO = new UserDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check admin permission
        HttpSession session = request.getSession();
        User currentUser = (User) (session.getAttribute("user") != null 
                ? session.getAttribute("user") 
                : session.getAttribute("info"));
        
        if (currentUser == null || !"ADMIN".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/view/login.jsp");
            return;
        }
        
        try {
            // Lấy tham số filter
            String userIdStr = request.getParameter("userId");
            String fromDateStr = request.getParameter("fromDate");
            String toDateStr = request.getParameter("toDate");
            
            // Lấy tham số phân trang
            String pageStr = request.getParameter("page");
            String pageSizeStr = request.getParameter("pageSize");
            
            int page = 1;
            if (pageStr != null && !pageStr.isEmpty()) {
                try {
                    page = Integer.parseInt(pageStr);
                    if (page < 1) page = 1;
                } catch (NumberFormatException e) {
                    page = 1;
                }
            }
            
            int pageSize = 5; // Mặc định 5 giao dịch mỗi trang
            if (pageSizeStr != null && !pageSizeStr.isEmpty()) {
                try {
                    int requestedPageSize = Integer.parseInt(pageSizeStr);
                    // Chỉ cho phép 5, 10, hoặc 15
                    if (requestedPageSize == 5 || requestedPageSize == 10 || requestedPageSize == 15) {
                        pageSize = requestedPageSize;
                    }
                } catch (NumberFormatException e) {
                    pageSize = 5;
                }
            }
            
            Integer userId = null;
            if (userIdStr != null && !userIdStr.isEmpty()) {
                try {
                    userId = Integer.parseInt(userIdStr);
                } catch (NumberFormatException e) {
                    // Ignore
                }
            }
            
            java.sql.Date fromDate = null;
            java.sql.Date toDate = null;
            
            if (fromDateStr != null && !fromDateStr.isEmpty()) {
                fromDate = java.sql.Date.valueOf(fromDateStr);
            }
            if (toDateStr != null && !toDateStr.isEmpty()) {
                toDate = java.sql.Date.valueOf(toDateStr);
            }
            
            // Lấy danh sách user để hiển thị trong filter
            List<User> users = userDAO.getAllUsers();
            
            // Đếm tổng số giao dịch
            int totalCount = transactionDAO.countDepositTransactions(userId, fromDate, toDate);
            
            // Tính tổng số trang
            int totalPages = (int) Math.ceil((double) totalCount / pageSize);
            if (totalPages == 0) totalPages = 1;
            if (page > totalPages) page = totalPages;
            
            // Lấy lịch sử nạp tiền với phân trang
            List<Transaction> deposits = transactionDAO.getAllDepositTransactions(
                    userId, fromDate, toDate, page, pageSize);
            
            // Tính tổng số tiền nạp vào
            BigDecimal totalDeposit = transactionDAO.getTotalDepositAmount(
                    userId, fromDate, toDate);
            
            // Set attributes
            request.setAttribute("deposits", deposits);
            request.setAttribute("totalDeposit", totalDeposit);
            request.setAttribute("users", users);
            request.setAttribute("selectedUserId", userIdStr);
            request.setAttribute("fromDate", fromDateStr);
            request.setAttribute("toDate", toDateStr);
            
            // Pagination attributes
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalCount", totalCount);
            request.setAttribute("pageSize", pageSize);
            request.setAttribute("selectedPageSize", pageSizeStr != null ? pageSizeStr : "5");
            request.setAttribute("startItem", totalCount > 0 ? (page - 1) * pageSize + 1 : 0);
            request.setAttribute("endItem", Math.min(page * pageSize, totalCount));
            
            // Forward to JSP
            request.getRequestDispatcher("/view/ManageTransactions.jsp").forward(request, response);
            
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi kết nối cơ sở dữ liệu: " + e.getMessage());
            request.getRequestDispatcher("/view/error.jsp").forward(request, response);
        }
    }
}


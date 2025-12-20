package controller.user;

import DAO.admin.TransactionDAO;
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

@WebServlet(name = "TransactionHistoryController", urlPatterns = {"/transaction-history"})
public class TransactionHistoryController extends HttpServlet {
    
    private TransactionDAO transactionDAO;
    
    @Override
    public void init() throws ServletException {
        transactionDAO = new TransactionDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) (session.getAttribute("info") != null 
                ? session.getAttribute("info") 
                : session.getAttribute("user"));
        
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/view/login.jsp");
            return;
        }
        
        try {
            // Lấy tham số filter
            String transactionType = request.getParameter("type");
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
            
            java.sql.Date fromDate = null;
            java.sql.Date toDate = null;
            
            if (fromDateStr != null && !fromDateStr.isEmpty()) {
                fromDate = java.sql.Date.valueOf(fromDateStr);
            }
            if (toDateStr != null && !toDateStr.isEmpty()) {
                toDate = java.sql.Date.valueOf(toDateStr);
            }
            
            // Đếm tổng số giao dịch
            int totalCount = transactionDAO.countUserTransactions(
                    currentUser.getUserId(), transactionType, fromDate, toDate);
            
            // Tính tổng số trang
            int totalPages = (int) Math.ceil((double) totalCount / pageSize);
            if (totalPages == 0) totalPages = 1;
            if (page > totalPages) page = totalPages;
            
            // Lấy lịch sử giao dịch với phân trang
            List<Transaction> transactions = transactionDAO.getUserTransactions(
                    currentUser.getUserId(), transactionType, fromDate, toDate, page, pageSize);
            
            // Lấy số dư hiện tại
            BigDecimal currentBalance = transactionDAO.getCurrentBalance(currentUser.getUserId());
            
            // Tính tổng nạp và tổng trừ (từ tất cả giao dịch, không chỉ trang hiện tại)
            // Lấy tất cả để tính tổng
            List<Transaction> allTransactions = transactionDAO.getUserTransactions(
                    currentUser.getUserId(), transactionType, fromDate, toDate, 0, 0);
            BigDecimal totalDeposit = BigDecimal.ZERO;
            BigDecimal totalPayment = BigDecimal.ZERO;
            
            for (Transaction t : allTransactions) {
                if ("DEPOSIT".equals(t.getTransactionType()) && "SUCCESS".equals(t.getStatus())) {
                    totalDeposit = totalDeposit.add(t.getAmount());
                } else if ("PAYMENT".equals(t.getTransactionType()) && "SUCCESS".equals(t.getStatus())) {
                    totalPayment = totalPayment.add(t.getAmount());
                }
            }
            
            // Set attributes
            request.setAttribute("transactions", transactions);
            request.setAttribute("currentBalance", currentBalance);
            request.setAttribute("totalDeposit", totalDeposit);
            request.setAttribute("totalPayment", totalPayment);
            request.setAttribute("selectedType", transactionType);
            request.setAttribute("fromDate", fromDateStr);
            request.setAttribute("toDate", toDateStr);
            request.setAttribute("user", currentUser);
            
            // Pagination attributes
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalCount", totalCount);
            request.setAttribute("pageSize", pageSize);
            request.setAttribute("selectedPageSize", pageSizeStr != null ? pageSizeStr : "5");
            request.setAttribute("startItem", totalCount > 0 ? (page - 1) * pageSize + 1 : 0);
            request.setAttribute("endItem", Math.min(page * pageSize, totalCount));
            
            // Forward to JSP
            request.getRequestDispatcher("/view/TransactionHistory.jsp").forward(request, response);
            
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi kết nối cơ sở dữ liệu: " + e.getMessage());
            request.getRequestDispatcher("/view/error.jsp").forward(request, response);
        }
    }
}


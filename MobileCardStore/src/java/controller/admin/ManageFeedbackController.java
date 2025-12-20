package controller.admin;

import DAO.admin.FeedbackDAO;
import DAO.admin.ProductDAO;
import Models.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "ManageFeedbackController", urlPatterns = {"/admin/feedback"})
public class ManageFeedbackController extends HttpServlet {
    
    private FeedbackDAO feedbackDAO;
    private ProductDAO productDAO;
    
    @Override
    public void init() throws ServletException {
        super.init();
        feedbackDAO = new FeedbackDAO();
        productDAO = new ProductDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Handle remove_reply action from GET request
            String action = request.getParameter("action");
            if ("remove_reply".equals(action)) {
                String feedbackIdStr = request.getParameter("feedbackId");
                if (feedbackIdStr != null) {
                    try {
                        User admin = (User) request.getSession().getAttribute("user");
                        if (admin != null && "ADMIN".equals(admin.getRole())) {
                            int feedbackId = Integer.parseInt(feedbackIdStr);
                            feedbackDAO.removeAdminReply(feedbackId);
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
            
            // Get filter parameters
            String search = request.getParameter("search");
            String productIdStr = request.getParameter("productId");
            String ratingStr = request.getParameter("rating");
            String hasReplyStr = request.getParameter("hasReply");
            String sortBy = request.getParameter("sortBy");
            
            Integer productId = null;
            if (productIdStr != null && !productIdStr.isEmpty()) {
                try {
                    productId = Integer.parseInt(productIdStr);
                } catch (NumberFormatException e) {
                    productId = null;
                }
            }
            
            Integer rating = null;
            if (ratingStr != null && !ratingStr.isEmpty()) {
                try {
                    rating = Integer.parseInt(ratingStr);
                } catch (NumberFormatException e) {
                    rating = null;
                }
            }
            
            Boolean hasReply = null;
            if (hasReplyStr != null && !hasReplyStr.isEmpty()) {
                if ("yes".equals(hasReplyStr)) {
                    hasReply = true;
                } else if ("no".equals(hasReplyStr)) {
                    hasReply = false;
                }
            }
            
            // Get pagination parameters
            String pageStr = request.getParameter("page");
            int page = 1;
            if (pageStr != null && !pageStr.isEmpty()) {
                try {
                    page = Integer.parseInt(pageStr);
                    if (page < 1) page = 1;
                } catch (NumberFormatException e) {
                    page = 1;
                }
            }
            
            int pageSize = 5; // 5 feedbacks mỗi trang
            
            // Get total count
            int totalCount = feedbackDAO.countFeedbacks(search, productId, rating, hasReply);
            
            // Calculate total pages
            int totalPages = (int) Math.ceil((double) totalCount / pageSize);
            if (totalPages == 0) totalPages = 1;
            if (page > totalPages) page = totalPages;
            
            // Get feedbacks with filters and pagination
            request.setAttribute("feedbacks", 
                feedbackDAO.getAllFeedbacks(search, productId, rating, hasReply, sortBy, page, pageSize));
            
            // Get products for filter dropdown
            request.setAttribute("products", productDAO.getAllProducts());
            
            // Keep filter values for form
            request.setAttribute("searchValue", search);
            request.setAttribute("productIdValue", productIdStr);
            request.setAttribute("ratingValue", ratingStr);
            request.setAttribute("hasReplyValue", hasReplyStr);
            request.setAttribute("sortByValue", sortBy);
            
            // Pagination info
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalCount", totalCount);
            request.setAttribute("pageSize", pageSize);
            request.setAttribute("startItem", totalCount > 0 ? (page - 1) * pageSize + 1 : 0);
            request.setAttribute("endItem", Math.min(page * pageSize, totalCount));
            
            request.getRequestDispatcher("/view/ManageFeedback.jsp").forward(request, response);
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi khi tải danh sách feedback");
            request.getRequestDispatcher("/view/ManageFeedback.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        String feedbackIdStr = request.getParameter("feedbackId");
        
        try {
            User admin = (User) request.getSession().getAttribute("user");
            if (admin == null || !"ADMIN".equals(admin.getRole())) {
                response.sendRedirect(request.getContextPath() + "/view/login.jsp");
                return;
            }
            
            int feedbackId = Integer.parseInt(feedbackIdStr);
            
            if ("reply".equals(action)) {
                String replyContent = request.getParameter("replyContent");
                
                // Validate reply length (tối đa 100 ký tự)
                if (replyContent != null && replyContent.length() > 100) {
                    response.sendRedirect(request.getContextPath() + "/admin/feedback?error=reply_too_long");
                    return;
                }
                
                if (replyContent != null && !replyContent.trim().isEmpty()) {
                    feedbackDAO.addAdminReply(feedbackId, replyContent.trim());
                }
            } else if ("remove_reply".equals(action)) {
                feedbackDAO.removeAdminReply(feedbackId);
            } else if ("delete".equals(action)) {
                feedbackDAO.deleteFeedback(feedbackId);
            }
            
            // Get referer to preserve filter parameters
            String referer = request.getHeader("Referer");
            if (referer != null && referer.contains("/admin/feedback")) {
                // Extract query string from referer
                int queryIndex = referer.indexOf("?");
                if (queryIndex > 0) {
                    String queryString = referer.substring(queryIndex);
                    response.sendRedirect(request.getContextPath() + "/admin/feedback" + queryString);
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/feedback");
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/feedback");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/feedback?error=action_failed");
        }
    }
}


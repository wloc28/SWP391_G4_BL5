package controller.user;

import DAO.user.FeedbackDAO;
import Models.Feedback;
import Models.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "FeedbackController", urlPatterns = {"/feedback/add", "/feedback/update-rating"})
public class FeedbackController extends HttpServlet {
    
    private FeedbackDAO feedbackDAO;
    
    @Override
    public void init() throws ServletException {
        super.init();
        feedbackDAO = new FeedbackDAO();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        
        if ("/feedback/add".equals(path)) {
            handleAddFeedback(request, response);
        } else if ("/feedback/update-rating".equals(path)) {
            handleUpdateRating(request, response);
        }
    }
    
    private void handleAddFeedback(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            User user = (User) request.getSession().getAttribute("user");
            if (user == null) {
                response.sendRedirect(request.getContextPath() + "/view/login.jsp");
                return;
            }
            
            String productIdStr = request.getParameter("productId");
            String content = request.getParameter("content");
            String ratingStr = request.getParameter("rating");
            
            if (productIdStr == null) {
                response.sendRedirect(request.getContextPath() + "/product-detail?id=" + productIdStr + "&error=missing_fields");
                return;
            }
            
            int productId = Integer.parseInt(productIdStr);
            Integer rating = null;
            if (ratingStr != null && !ratingStr.isEmpty()) {
                rating = Integer.parseInt(ratingStr);
                if (rating < 1 || rating > 5) rating = null;
            }
            
            // Kiểm tra phải có ít nhất rating hoặc content
            if (rating == null && (content == null || content.trim().isEmpty())) {
                response.sendRedirect(request.getContextPath() + "/product-detail?id=" + productId + "&error=rating_or_content_required");
                return;
            }
            
            // Validate content length (tối đa 100 ký tự)
            if (content != null && content.length() > 100) {
                response.sendRedirect(request.getContextPath() + "/product-detail?id=" + productId + "&error=content_too_long");
                return;
            }
            
            Feedback feedback = new Feedback();
            feedback.setUserId(user.getUserId());
            feedback.setProductId(productId);
            feedback.setContent(content != null ? content.trim() : null);
            feedback.setRating(rating);
            
            if (feedbackDAO.addFeedback(feedback)) {
                response.sendRedirect(request.getContextPath() + "/product-detail?id=" + productId + "&success=feedback_added");
            } else {
                response.sendRedirect(request.getContextPath() + "/product-detail?id=" + productId + "&error=feedback_failed");
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            String productId = request.getParameter("productId");
            if (e.getMessage() != null && e.getMessage().contains("đã feedback")) {
                response.sendRedirect(request.getContextPath() + "/product-detail?id=" + productId + "&error=already_feedbacked");
            } else {
                response.sendRedirect(request.getContextPath() + "/product-detail?id=" + productId + "&error=server_error");
            }
        } catch (Exception e) {
            e.printStackTrace();
            String productId = request.getParameter("productId");
            response.sendRedirect(request.getContextPath() + "/product-detail?id=" + productId + "&error=server_error");
        }
    }
    
    private void handleUpdateRating(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            User user = (User) request.getSession().getAttribute("user");
            if (user == null) {
                response.sendRedirect(request.getContextPath() + "/view/login.jsp");
                return;
            }
            
            String feedbackIdStr = request.getParameter("feedbackId");
            String productIdStr = request.getParameter("productId");
            String ratingStr = request.getParameter("rating");
            
            if (feedbackIdStr == null || productIdStr == null) {
                response.sendRedirect(request.getContextPath() + "/product-detail?id=" + productIdStr);
                return;
            }
            
            int feedbackId = Integer.parseInt(feedbackIdStr);
            int productId = Integer.parseInt(productIdStr);
            Integer rating = null;
            if (ratingStr != null && !ratingStr.isEmpty()) {
                rating = Integer.parseInt(ratingStr);
                if (rating < 1 || rating > 5) rating = null;
            }
            
            // Verify that this feedback belongs to the current user
            Feedback feedback = feedbackDAO.getUserFeedback(user.getUserId(), productId);
            if (feedback == null || feedback.getFeedbackId() != feedbackId) {
                response.sendRedirect(request.getContextPath() + "/product-detail?id=" + productId + "&error=unauthorized");
                return;
            }
            
            if (feedbackDAO.updateRating(feedbackId, rating)) {
                response.sendRedirect(request.getContextPath() + "/product-detail?id=" + productId + "&success=rating_updated");
            } else {
                response.sendRedirect(request.getContextPath() + "/product-detail?id=" + productId + "&error=rating_update_failed");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            String productId = request.getParameter("productId");
            response.sendRedirect(request.getContextPath() + "/product-detail?id=" + productId);
        }
    }
}


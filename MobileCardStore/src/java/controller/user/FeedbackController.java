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
            String code = request.getParameter("code");
            String providerIdStr = request.getParameter("providerId");
            String content = request.getParameter("content");
            String ratingStr = request.getParameter("rating");
            
            if (productIdStr == null) {
                response.sendRedirect(request.getContextPath() + "/products?error=missing_fields");
                return;
            }
            
            int providerStorageId = Integer.parseInt(productIdStr); // productId thực ra là provider_storage_id
            Integer rating = null;
            if (ratingStr != null && !ratingStr.isEmpty()) {
                rating = Integer.parseInt(ratingStr);
                if (rating < 1 || rating > 5) rating = null;
            }
            
            // Kiểm tra phải có ít nhất rating hoặc content
            if (rating == null && (content == null || content.trim().isEmpty())) {
                String redirectUrl = buildProductDetailUrl(request, code, providerIdStr, "rating_or_content_required");
                response.sendRedirect(redirectUrl);
                return;
            }
            
            // Validate content length (tối đa 100 ký tự)
            if (content != null && content.length() > 100) {
                String redirectUrl = buildProductDetailUrl(request, code, providerIdStr, "content_too_long");
                response.sendRedirect(redirectUrl);
                return;
            }
            
            Feedback feedback = new Feedback();
            feedback.setUserId(user.getUserId());
            feedback.setProductId(providerStorageId); // Lưu provider_storage_id vào productId field
            feedback.setContent(content != null ? content.trim() : null);
            feedback.setRating(rating);
            
            if (feedbackDAO.addFeedback(feedback)) {
                String redirectUrl = buildProductDetailUrl(request, code, providerIdStr, "success=feedback_added");
                response.sendRedirect(redirectUrl);
            } else {
                String redirectUrl = buildProductDetailUrl(request, code, providerIdStr, "error=feedback_failed");
                response.sendRedirect(redirectUrl);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            String code = request.getParameter("code");
            String providerIdStr = request.getParameter("providerId");
            if (e.getMessage() != null && e.getMessage().contains("đã feedback")) {
                String redirectUrl = buildProductDetailUrl(request, code, providerIdStr, "error=already_feedbacked");
                response.sendRedirect(redirectUrl);
            } else {
                String redirectUrl = buildProductDetailUrl(request, code, providerIdStr, "error=server_error");
                response.sendRedirect(redirectUrl);
            }
        } catch (Exception e) {
            e.printStackTrace();
            String code = request.getParameter("code");
            String providerIdStr = request.getParameter("providerId");
            String redirectUrl = buildProductDetailUrl(request, code, providerIdStr, "error=server_error");
            response.sendRedirect(redirectUrl);
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
            String code = request.getParameter("code");
            String providerIdStr = request.getParameter("providerId");
            String ratingStr = request.getParameter("rating");
            
            if (feedbackIdStr == null || productIdStr == null) {
                String redirectUrl = buildProductDetailUrl(request, code, providerIdStr, null);
                response.sendRedirect(redirectUrl);
                return;
            }
            
            int feedbackId = Integer.parseInt(feedbackIdStr);
            int providerStorageId = Integer.parseInt(productIdStr); // productId thực ra là provider_storage_id
            Integer rating = null;
            if (ratingStr != null && !ratingStr.isEmpty()) {
                rating = Integer.parseInt(ratingStr);
                if (rating < 1 || rating > 5) rating = null;
            }
            
            // Verify that this feedback belongs to the current user
            Feedback feedback = feedbackDAO.getUserFeedback(user.getUserId(), providerStorageId);
            if (feedback == null || feedback.getFeedbackId() != feedbackId) {
                String redirectUrl = buildProductDetailUrl(request, code, providerIdStr, "error=unauthorized");
                response.sendRedirect(redirectUrl);
                return;
            }
            
            if (feedbackDAO.updateRating(feedbackId, rating)) {
                String redirectUrl = buildProductDetailUrl(request, code, providerIdStr, "success=rating_updated");
                response.sendRedirect(redirectUrl);
            } else {
                String redirectUrl = buildProductDetailUrl(request, code, providerIdStr, "error=rating_update_failed");
                response.sendRedirect(redirectUrl);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            String code = request.getParameter("code");
            String providerIdStr = request.getParameter("providerId");
            String redirectUrl = buildProductDetailUrl(request, code, providerIdStr, null);
            response.sendRedirect(redirectUrl);
        }
    }
    
    // Helper method để build URL redirect về product detail
    private String buildProductDetailUrl(HttpServletRequest request, String code, String providerIdStr, String param) {
        String contextPath = request.getContextPath();
        
        // Nếu thiếu code hoặc providerId, redirect về products
        if (code == null || code.isEmpty() || providerIdStr == null || providerIdStr.isEmpty()) {
            StringBuilder url = new StringBuilder(contextPath).append("/products");
            if (param != null && !param.isEmpty()) {
                url.append("?").append(param);
            }
            return url.toString();
        }
        
        StringBuilder url = new StringBuilder(contextPath);
        url.append("/product-detail?code=");
        try {
            url.append(java.net.URLEncoder.encode(code, java.nio.charset.StandardCharsets.UTF_8));
        } catch (Exception e) {
            url.append(code);
        }
        url.append("&providerId=").append(providerIdStr);
        
        if (param != null && !param.isEmpty()) {
            url.append("&").append(param);
        }
        return url.toString();
    }
}


package controller.user;

import DAO.user.ProductDAO;
import DAO.user.FeedbackDAO;
import Models.ProductDisplay;
import Models.Provider;
import Models.Feedback;
import Models.User;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * ProductServlet - Handles product listing and detail views
 * URL patterns: /products, /product-detail
 */
@WebServlet(name = "ProductServlet", urlPatterns = { "/products", "/product-detail" })
public class ProductServlet extends HttpServlet {

    private ProductDAO productDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            productDAO = new ProductDAO();
        } catch (Exception e) {
            throw new ServletException("Failed to initialize ProductDAO", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        if ("/product-detail".equals(path)) {
            handleProductDetail(request, response);
        } else {
            handleProductList(request, response);
        }
    }

    /**
     * Handle product list page with search, filter, sort, and pagination
     */
    private void handleProductList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Get search parameters
            String searchKeyword = request.getParameter("search");
            if (searchKeyword == null)
                searchKeyword = "";

            // Get filter parameters
            String providerIdStr = request.getParameter("providerId");
            int providerId = 0;
            if (providerIdStr != null && !providerIdStr.isEmpty()) {
                try {
                    providerId = Integer.parseInt(providerIdStr);
                } catch (NumberFormatException e) {
                    providerId = 0;
                }
            }

            String providerType = request.getParameter("providerType");
            if (providerType == null)
                providerType = "ALL";

            String minPriceStr = request.getParameter("minPrice");
            BigDecimal minPrice = null;
            if (minPriceStr != null && !minPriceStr.isEmpty()) {
                try {
                    minPrice = new BigDecimal(minPriceStr);
                } catch (NumberFormatException e) {
                    minPrice = null;
                }
            }

            String maxPriceStr = request.getParameter("maxPrice");
            BigDecimal maxPrice = null;
            if (maxPriceStr != null && !maxPriceStr.isEmpty()) {
                try {
                    maxPrice = new BigDecimal(maxPriceStr);
                } catch (NumberFormatException e) {
                    maxPrice = null;
                }
            }

            // Get sort parameters
            String sortBy = request.getParameter("sortBy");
            if (sortBy == null || sortBy.isEmpty()) {
                sortBy = "created_at";
            }

            String sortOrder = request.getParameter("sortOrder");
            if (sortOrder == null || sortOrder.isEmpty()) {
                sortOrder = "DESC";
            }

            // Get pagination parameters
            String pageStr = request.getParameter("page");
            int page = 1;
            if (pageStr != null && !pageStr.isEmpty()) {
                try {
                    page = Integer.parseInt(pageStr);
                    if (page < 1)
                        page = 1;
                } catch (NumberFormatException e) {
                    page = 1;
                }
            }

            // Fixed page size: 12 items per page
            int pageSize = 12;

            // Get products with filters
            List<ProductDisplay> products = productDAO.searchAndFilterProducts(
                    searchKeyword, providerId, providerType, minPrice, maxPrice,
                    sortBy, sortOrder, page, pageSize);

            // Get total count for pagination
            int totalCount = productDAO.countProducts(
                    searchKeyword, providerId, providerType, minPrice, maxPrice);

            // Calculate pagination info
            int totalPages = (int) Math.ceil((double) totalCount / pageSize);
            if (totalPages == 0)
                totalPages = 1;
            if (page > totalPages)
                page = totalPages;

            // Get all providers for filter dropdown
            List<Provider> providers = productDAO.getAllProviders();

            // Debug logging
            System.out.println("ProductServlet: Found " + products.size() + " products, total: " + totalCount);
            
            // Set request attributes
            request.setAttribute("products", products);
            request.setAttribute("providers", providers);
            request.setAttribute("searchKeyword", searchKeyword);
            request.setAttribute("selectedProviderId", providerId);
            request.setAttribute("selectedProviderType", providerType);
            request.setAttribute("minPrice", minPriceStr);
            request.setAttribute("maxPrice", maxPriceStr);
            request.setAttribute("sortBy", sortBy);
            request.setAttribute("sortOrder", sortOrder);
            request.setAttribute("currentPage", page);
            request.setAttribute("pageSize", pageSize);
            request.setAttribute("totalCount", totalCount);
            request.setAttribute("totalPages", totalPages);

            // Forward to JSP
            request.getRequestDispatcher("/view/ViewProducts.jsp").forward(request, response);

        } catch (SQLException e) {
            System.err.println("ProductServlet SQL Error: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Lỗi khi tải danh sách sản phẩm: " + e.getMessage());
            request.setAttribute("products", new java.util.ArrayList<>());
            request.setAttribute("totalCount", 0);
            request.setAttribute("totalPages", 1);
            request.getRequestDispatcher("/view/ViewProducts.jsp").forward(request, response);
        } catch (Exception e) {
            System.err.println("ProductServlet General Error: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            request.setAttribute("products", new java.util.ArrayList<>());
            request.setAttribute("totalCount", 0);
            request.setAttribute("totalPages", 1);
            request.getRequestDispatcher("/view/ViewProducts.jsp").forward(request, response);
        }
    }

    /**
     * Handle product detail page
     */
    private void handleProductDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String productCode = request.getParameter("code");
            String providerIdStr = request.getParameter("providerId");

            if (productCode == null || productCode.isEmpty() || providerIdStr == null || providerIdStr.isEmpty()) {
                request.setAttribute("error", "Thông tin sản phẩm không hợp lệ");
                request.getRequestDispatcher("/view/ProductDetail.jsp").forward(request, response);
                return;
            }

            int providerId;
            try {
                providerId = Integer.parseInt(providerIdStr);
            } catch (NumberFormatException e) {
                request.setAttribute("error", "ID nhà cung cấp không hợp lệ");
                request.getRequestDispatcher("/view/ProductDetail.jsp").forward(request, response);
                return;
            }

            ProductDisplay product = productDAO.getProductByCode(productCode, providerId);

            if (product == null) {
                request.setAttribute("error", "Không tìm thấy sản phẩm");
                request.getRequestDispatcher("/view/ProductDetail.jsp").forward(request, response);
                return;
            }

            // Get available stock
            int stock = productDAO.getAvailableStock(productCode, providerId);
            request.setAttribute("product", product);
            request.setAttribute("stock", stock);
            // Get related products (same provider, max 8 products)
            List<ProductDisplay> relatedProducts = productDAO.getRelatedProducts(productCode, providerId, product.getProviderId(), 8);
            request.setAttribute("relatedProducts", relatedProducts);
            
            // Load feedbacks for this product
            FeedbackDAO feedbackDAO = new FeedbackDAO();
            int providerStorageId = product.getProviderStorageId(); // Lấy provider_storage_id từ product
            List<Feedback> feedbacks = feedbackDAO.getFeedbacksByProductId(providerStorageId);
            
            // Check if current user has already feedbacked
            User currentUser = (User) request.getSession().getAttribute("user");
            Feedback currentUserFeedback = null;
            if (currentUser != null) {
                // Check if current user has already feedbacked
                boolean hasFeedbacked = feedbackDAO.hasUserFeedbackedProduct(currentUser.getUserId(), providerStorageId);
                request.setAttribute("hasFeedbacked", hasFeedbacked);
                
                // Get current user's feedback (để có thể sửa rating)
                if (hasFeedbacked) {
                    currentUserFeedback = feedbackDAO.getUserFeedback(currentUser.getUserId(), providerStorageId);
                }
            }
            
            request.setAttribute("feedbacks", feedbacks);
            request.setAttribute("currentUserFeedback", currentUserFeedback);
            // Forward to JSP
            request.getRequestDispatcher("/view/ProductDetail.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi khi tải chi tiết sản phẩm: " + e.getMessage());
            request.getRequestDispatcher("/view/ProductDetail.jsp").forward(request, response);
        }
    }
}

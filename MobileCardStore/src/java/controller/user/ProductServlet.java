package controller.user;

import DAO.user.ProductDAO;
import Models.Product;
import Models.Provider;
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
            List<Product> products = productDAO.searchAndFilterProducts(
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

            // Get available stock for each product
            for (Product product : products) {
                int stock = productDAO.getAvailableStock(product.getProductId());
                // You can add a stock field to Product model or use a Map
                // For now, we'll pass it separately if needed
            }

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
            e.printStackTrace();
            request.setAttribute("error", "Lỗi khi tải danh sách sản phẩm: " + e.getMessage());
            request.getRequestDispatcher("/view/ViewProducts.jsp").forward(request, response);
        }
    }

    /**
     * Handle product detail page
     */
    private void handleProductDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String productIdStr = request.getParameter("id");

            if (productIdStr == null || productIdStr.isEmpty()) {
                request.setAttribute("error", "Không tìm thấy sản phẩm");
                request.getRequestDispatcher("/view/ProductDetail.jsp").forward(request, response);
                return;
            }

            int productId;
            try {
                productId = Integer.parseInt(productIdStr);
            } catch (NumberFormatException e) {
                request.setAttribute("error", "ID sản phẩm không hợp lệ");
                request.getRequestDispatcher("/view/ProductDetail.jsp").forward(request, response);
                return;
            }

            Product product = productDAO.getProductById(productId);

            if (product == null) {
                request.setAttribute("error", "Không tìm thấy sản phẩm");
                request.getRequestDispatcher("/view/ProductDetail.jsp").forward(request, response);
                return;
            }

            // Get available stock
            int stock = productDAO.getAvailableStock(productId);
            request.setAttribute("product", product);
            request.setAttribute("stock", stock);

            // Get related products (same provider, max 8 products)
            List<Product> relatedProducts = productDAO.getRelatedProducts(productId, product.getProviderId(), 8);
            request.setAttribute("relatedProducts", relatedProducts);

            // Forward to JSP
            request.getRequestDispatcher("/view/ProductDetail.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi khi tải chi tiết sản phẩm: " + e.getMessage());
            request.getRequestDispatcher("/view/ProductDetail.jsp").forward(request, response);
        }
    }
}

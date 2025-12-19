package controller.user;

import DAO.user.ProductDAO;
import Models.Provider;
import Models.ProductDisplay;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet. http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "HomeServlet", urlPatterns = {"/home"})
public class HomeServlet extends HttpServlet {

    private ProductDAO productDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        productDAO = new ProductDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        try {
            List<Provider> providers = productDAO.getAllProviders();
            request.setAttribute("providers", providers);

            Map<Provider, List<ProductDisplay>> productsByProvider =
                    productDAO.getProductsGroupedByProvider();
            
            // Debug logging
            System.out.println("HomeServlet: Found " + productsByProvider.size() + " providers with products");
            for (Provider p : productsByProvider.keySet()) {
                System.out.println("  Provider: " + p.getProviderName() + " - " + productsByProvider.get(p).size() + " products");
            }
            
            request.setAttribute("productsByProvider", productsByProvider);

            request.getRequestDispatcher("/view/Home.jsp").forward(request, response);

        } catch (SQLException e) {
            System.err.println("HomeServlet SQL Error: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Không thể tải dữ liệu. Lỗi: " + e.getMessage());
            request.setAttribute("productsByProvider", new java.util.LinkedHashMap<>());
            request.getRequestDispatcher("/view/Home.jsp").forward(request, response);
        } catch (Exception e) {
            System.err.println("HomeServlet General Error: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Không thể tải dữ liệu. Vui lòng thử lại sau.");
            request.setAttribute("productsByProvider", new java.util.LinkedHashMap<>());
            request.getRequestDispatcher("/view/Home.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Home Page Servlet - Mobile Card Store";
    }
}
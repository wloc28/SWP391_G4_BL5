package controller.admin;

import DAO.admin.ProductDAO;
import DAO.admin.ProductStorageDAO;
import Models.ProductStorage;
import Models.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;



@WebServlet(name = "ProductStorageController", urlPatterns = {"/pklist", "/admin/storage"})
public class ProductStorageController extends HttpServlet {
    
    private ProductStorageDAO storageDAO;
    private ProductDAO productDAO;
    
    @Override
    public void init() throws ServletException {
        storageDAO = new ProductStorageDAO();
        productDAO = new ProductDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Ki?m tra quy?n admin
        if (!checkAdminPermission(request, response)) {
            return;
        }
        
        String action = request.getParameter("action");
        
        try {
            if (action == null || action.isEmpty() || action.equals("list")) {
                // List all storage items
                listStorageItems(request, response);
            } else if (action.equals("add")) {
                // Show add form
                showAddForm(request, response);
            } else if (action.equals("edit")) {
                // Show edit form
                String idParam = request.getParameter("id");
                if (idParam == null || idParam.isEmpty()) {
                    response.sendRedirect(request.getContextPath() + "/pklist?error=invalid_id");
                    return;
                }
                showEditForm(request, response, Integer.parseInt(idParam));
            } else if (action.equals("delete")) {
                // Delete storage item
                String idParam = request.getParameter("id");
                if (idParam == null || idParam.isEmpty()) {
                    response.sendRedirect(request.getContextPath() + "/pklist?error=invalid_id");
                    return;
                }
                deleteStorageItem(request, response, Integer.parseInt(idParam));
            } else {
                listStorageItems(request, response);
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/pklist?error=invalid_id");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/pklist?error=server_error");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Ki?m tra quy?n admin
        if (!checkAdminPermission(request, response)) {
            return;
        }
        
        String action = request.getParameter("action");
        
        try {
            if ("add".equals(action)) {
                addStorageItem(request, response);
            } else if ("edit".equals(action)) {
                updateStorageItem(request, response);
            } else {
                listStorageItems(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/pklist?error=server_error");
        }
    }
    
    private boolean checkAdminPermission(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
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
            return false;
        }
        
        return true;
    }
    
    private void listStorageItems(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            request.setAttribute("storageItems", storageDAO.getAllStorageItems());
            request.setAttribute("products", productDAO.getAllProducts());
            request.getRequestDispatcher("/view/ManageStorage.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/pklist?error=load_failed");
        }
    }
    
    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            request.setAttribute("products", productDAO.getAllProducts());
            request.getRequestDispatcher("/view/ManageStorage.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/pklist?error=load_failed");
        }
    }
    
    private void showEditForm(HttpServletRequest request, HttpServletResponse response, int storageId)
            throws ServletException, IOException {
        try {
            ProductStorage item = storageDAO.getStorageItemById(storageId);
            if (item == null) {
                response.sendRedirect(request.getContextPath() + "/pklist?error=item_not_found");
                return;
            }
            request.setAttribute("storageItem", item);
            request.setAttribute("products", productDAO.getAllProducts());
            request.getRequestDispatcher("/view/ManageStorage.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/pklist?error=load_failed");
        }
    }
    
    private void addStorageItem(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            ProductStorage item = new ProductStorage();
            item.setProductId(Integer.parseInt(request.getParameter("productId")));
            item.setSerialNumber(request.getParameter("serialNumber"));
            item.setCardCode(request.getParameter("cardCode"));
            item.setStatus(request.getParameter("status"));
            
            String expiryDateStr = request.getParameter("expiryDate");
            if (expiryDateStr != null && !expiryDateStr.isEmpty()) {
                item.setExpiryDate(Date.valueOf(expiryDateStr));
            }
            
            if (storageDAO.addStorageItem(item)) {
                response.sendRedirect(request.getContextPath() + "/pklist?success=add_success");
            } else {
                response.sendRedirect(request.getContextPath() + "/pklist?error=add_failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/pklist?error=add_failed");
        }
    }
    
    private void updateStorageItem(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int storageId = Integer.parseInt(request.getParameter("storageId"));
            ProductStorage item = storageDAO.getStorageItemById(storageId);
            
            if (item == null) {
                response.sendRedirect(request.getContextPath() + "/pklist?error=item_not_found");
                return;
            }
            
            item.setProductId(Integer.parseInt(request.getParameter("productId")));
            item.setSerialNumber(request.getParameter("serialNumber"));
            item.setCardCode(request.getParameter("cardCode"));
            item.setStatus(request.getParameter("status"));
            
            String expiryDateStr = request.getParameter("expiryDate");
            if (expiryDateStr != null && !expiryDateStr.isEmpty()) {
                item.setExpiryDate(Date.valueOf(expiryDateStr));
            } else {
                item.setExpiryDate(null);
            }
            
            if (storageDAO.updateStorageItem(item)) {
                response.sendRedirect(request.getContextPath() + "/pklist?success=update_success");
            } else {
                response.sendRedirect(request.getContextPath() + "/pklist?error=update_failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/pklist?error=update_failed");
        }
    }
    
    private void deleteStorageItem(HttpServletRequest request, HttpServletResponse response, int storageId)
            throws IOException {
        try {
            if (storageDAO.deleteStorageItem(storageId)) {
                response.sendRedirect(request.getContextPath() + "/pklist?success=delete_success");
            } else {
                response.sendRedirect(request.getContextPath() + "/pklist?error=delete_failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/pklist?error=delete_failed");
        }
    }
}

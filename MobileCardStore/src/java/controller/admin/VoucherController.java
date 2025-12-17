package controller.admin;

import DAO.admin.VoucherDAO;
import Models.User;
import Models.Voucher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

/**
 * Voucher Controller
 * Xử lý CRUD operations cho quản lý voucher
 */
@WebServlet(name = "VoucherController", urlPatterns = {"/vlist", "/admin/vouchers"})
public class VoucherController extends HttpServlet {
    
    private VoucherDAO voucherDAO;
    
    @Override
    public void init() throws ServletException {
        voucherDAO = new VoucherDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra quyền admin
        if (!checkAdminPermission(request, response)) {
            return;
        }
        
        String action = request.getParameter("action");
        
        try {
            if (action == null || action.isEmpty() || action.equals("list")) {
                // List all vouchers
                listVouchers(request, response);
            } else if (action.equals("add")) {
                // Show add form
                showAddForm(request, response);
            } else if (action.equals("edit")) {
                // Show edit form
                String idParam = request.getParameter("id");
                if (idParam == null || idParam.isEmpty()) {
                    response.sendRedirect(request.getContextPath() + "/vlist?error=invalid_id");
                    return;
                }
                showEditForm(request, response, Integer.parseInt(idParam));
            } else if (action.equals("delete")) {
                // Delete voucher
                String idParam = request.getParameter("id");
                if (idParam == null || idParam.isEmpty()) {
                    response.sendRedirect(request.getContextPath() + "/vlist?error=invalid_id");
                    return;
                }
                deleteVoucher(request, response, Integer.parseInt(idParam));
            } else {
                listVouchers(request, response);
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/vlist?error=invalid_id");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/vlist?error=server_error");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra quyền admin
        if (!checkAdminPermission(request, response)) {
            return;
        }
        
        String action = request.getParameter("action");
        
        try {
            if ("add".equals(action)) {
                addVoucher(request, response);
            } else if ("edit".equals(action)) {
                updateVoucher(request, response);
            } else {
                listVouchers(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/vlist?error=server_error");
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
    
    private void listVouchers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Lấy các tham số filter
            String keyword = request.getParameter("keyword");
            String status = request.getParameter("status");
            String discountType = request.getParameter("discountType");
            String expiryFilter = request.getParameter("expiryFilter");
            
            // Lấy tham số phân trang
            int page = 1;
            int pageSize = 10; // Số voucher mỗi trang
            
            try {
                String pageParam = request.getParameter("page");
                if (pageParam != null && !pageParam.isEmpty()) {
                    page = Integer.parseInt(pageParam);
                    if (page < 1) page = 1;
                }
            } catch (NumberFormatException e) {
                page = 1;
            }
            
            // Lấy danh sách voucher với filter và phân trang
            List<Voucher> vouchers = voucherDAO.searchVouchers(keyword, status, discountType, expiryFilter, page, pageSize);
            int totalCount = voucherDAO.countVouchers(keyword, status, discountType, expiryFilter);
            
            // Tính tổng số trang
            int totalPages = (int) Math.ceil((double) totalCount / pageSize);
            if (totalPages == 0) totalPages = 1;
            if (page > totalPages) page = totalPages;
            
            // Set attributes
            request.setAttribute("vouchers", vouchers);
            request.setAttribute("keyword","thanh");// keyword != null ? keyword : "");
            request.setAttribute("status", status != null ? status : "ALL");
            request.setAttribute("discountType", discountType != null ? discountType : "ALL");
            request.setAttribute("expiryFilter", expiryFilter != null ? expiryFilter : "");
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalCount", totalCount);
            request.setAttribute("pageSize", pageSize);
            
            request.getRequestDispatcher("/view/ManageVouchers.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/vlist?error=load_failed");
        }
    }
    
    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            request.getRequestDispatcher("/view/ManageVouchers.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/vlist?error=load_failed");
        }
    }
    
    private void showEditForm(HttpServletRequest request, HttpServletResponse response, int voucherId)
            throws ServletException, IOException {
        try {
            Voucher voucher = voucherDAO.getVoucherById(voucherId);
            if (voucher == null) {
                response.sendRedirect(request.getContextPath() + "/vlist?error=voucher_not_found");
                return;
            }
            request.setAttribute("voucher", voucher);
            request.getRequestDispatcher("/view/ManageVouchers.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/vlist?error=load_failed");
        }
    }
    
    private void addVoucher(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            String code = request.getParameter("code");
            if (code == null || code.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/vlist?error=code_required&action=add");
                return;
            }
            
            // Kiểm tra code đã tồn tại chưa
            if (voucherDAO.isCodeExists(code)) {
                response.sendRedirect(request.getContextPath() + "/vlist?error=code_exists&action=add");
                return;
            }
            
            Voucher voucher = new Voucher();
            voucher.setCode(code.trim().toUpperCase());
            voucher.setDiscountType(request.getParameter("discountType"));
            voucher.setDiscountValue(new BigDecimal(request.getParameter("discountValue")));
            
            String minOrderValue = request.getParameter("minOrderValue");
            if (minOrderValue != null && !minOrderValue.trim().isEmpty()) {
                voucher.setMinOrderValue(new BigDecimal(minOrderValue));
            } else {
                voucher.setMinOrderValue(BigDecimal.ZERO);
            }
            
            String usageLimit = request.getParameter("usageLimit");
            if (usageLimit != null && !usageLimit.trim().isEmpty()) {
                voucher.setUsageLimit(Integer.parseInt(usageLimit));
            } else {
                voucher.setUsageLimit(null);
            }
            
            String expiryDateStr = request.getParameter("expiryDate");
            if (expiryDateStr != null && !expiryDateStr.trim().isEmpty()) {
                try {
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
                    Date expiryDate = sdf.parse(expiryDateStr);
                    voucher.setExpiryDate(expiryDate);
                } catch (ParseException e) {
                    // Nếu parse lỗi, để null
                    voucher.setExpiryDate(null);
                }
            } else {
                voucher.setExpiryDate(null);
            }
            
            voucher.setStatus(request.getParameter("status"));
            
            // Validation
            if (voucher.getDiscountType().equals("PERCENT")) {
                if (voucher.getDiscountValue().compareTo(new BigDecimal("100")) > 0) {
                    response.sendRedirect(request.getContextPath() + "/vlist?error=invalid_percent&action=add");
                    return;
                }
            }
            
            if (voucherDAO.addVoucher(voucher)) {
                response.sendRedirect(request.getContextPath() + "/vlist?success=add_success");
            } else {
                response.sendRedirect(request.getContextPath() + "/vlist?error=add_failed&action=add");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/vlist?error=add_failed&action=add");
        }
    }
    
    private void updateVoucher(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int voucherId = Integer.parseInt(request.getParameter("voucherId"));
            Voucher voucher = voucherDAO.getVoucherById(voucherId);
            
            if (voucher == null) {
                response.sendRedirect(request.getContextPath() + "/vlist?error=voucher_not_found");
                return;
            }
            
            // Không cho sửa code khi đã có người dùng
            // Code được giữ nguyên từ database
            
            voucher.setDiscountType(request.getParameter("discountType"));
            voucher.setDiscountValue(new BigDecimal(request.getParameter("discountValue")));
            
            String minOrderValue = request.getParameter("minOrderValue");
            if (minOrderValue != null && !minOrderValue.trim().isEmpty()) {
                voucher.setMinOrderValue(new BigDecimal(minOrderValue));
            } else {
                voucher.setMinOrderValue(BigDecimal.ZERO);
            }
            
            String usageLimit = request.getParameter("usageLimit");
            if (usageLimit != null && !usageLimit.trim().isEmpty()) {
                voucher.setUsageLimit(Integer.parseInt(usageLimit));
            } else {
                voucher.setUsageLimit(null);
            }
            
            String expiryDateStr = request.getParameter("expiryDate");
            if (expiryDateStr != null && !expiryDateStr.trim().isEmpty()) {
                try {
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
                    Date expiryDate = sdf.parse(expiryDateStr);
                    voucher.setExpiryDate(expiryDate);
                } catch (ParseException e) {
                    voucher.setExpiryDate(null);
                }
            } else {
                voucher.setExpiryDate(null);
            }
            
            voucher.setStatus(request.getParameter("status"));
            
            // Validation
            if (voucher.getDiscountType().equals("PERCENT")) {
                if (voucher.getDiscountValue().compareTo(new BigDecimal("100")) > 0) {
                    response.sendRedirect(request.getContextPath() + "/vlist?error=invalid_percent&action=edit&id=" + voucherId);
                    return;
                }
            }
            
            if (voucherDAO.updateVoucher(voucher)) {
                response.sendRedirect(request.getContextPath() + "/vlist?success=update_success");
            } else {
                response.sendRedirect(request.getContextPath() + "/vlist?error=update_failed&action=edit&id=" + voucherId);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/vlist?error=update_failed");
        }
    }
    
    private void deleteVoucher(HttpServletRequest request, HttpServletResponse response, int voucherId)
            throws IOException {
        try {
            if (voucherDAO.deleteVoucher(voucherId)) {
                response.sendRedirect(request.getContextPath() + "/vlist?success=delete_success");
            } else {
                response.sendRedirect(request.getContextPath() + "/vlist?error=delete_failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/vlist?error=delete_failed");
        }
    }
}


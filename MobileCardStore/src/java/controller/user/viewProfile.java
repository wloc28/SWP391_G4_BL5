package controller.user;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import dao.user.daoUser;
import models.User;

/**
 * View Profile Controller
 */
@WebServlet(name = "viewProfile", urlPatterns = {"/viewProfile"})
public class viewProfile extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        
        // Kiểm tra đã đăng nhập chưa
        if (session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        // Lấy userId từ session
        Integer userId = (Integer) session.getAttribute("userId");
        
        if (userId == null) {
            request.setAttribute("error", "Không tìm thấy thông tin user!");
            request.getRequestDispatcher("/login").forward(request, response);
            return;
        }
        
        // Lấy thông tin user từ database
        daoUser userDAO = new daoUser();
        User user = userDAO.getUserById(userId);
        
        if (user == null) {
            request.setAttribute("error", "Không tìm thấy thông tin user!");
            request.getRequestDispatcher("/login").forward(request, response);
            return;
        }
        
        // Cập nhật thông tin user trong session
        session.setAttribute("user", user);
        session.setAttribute("username", user.getUsername());
        session.setAttribute("email", user.getEmail());
        
        // Set user vào request để hiển thị
        request.setAttribute("user", user);
        
        // Forward đến trang ViewProfile
        request.getRequestDispatcher("/view/ViewProfile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}

package authentication_controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Logout Controller để đăng xuất user và admin
 * Sau khi đăng xuất sẽ redirect về trang home
 */
@WebServlet(name = "LogoutServlet", urlPatterns = {"/logout"})
public class LogoutController extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        
        if (session != null) {
            // Xóa tất cả attributes trong session
            session.invalidate();
        }
        
        // Redirect về trang home
        response.sendRedirect(request.getContextPath() + "/home");
    }
}





